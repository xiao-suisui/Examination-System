package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.UserStatus;
import com.example.exam.dto.UserDTO;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.entity.system.SysRole;
import com.example.exam.entity.system.SysUser;
import com.example.exam.converter.UserConverter;
import com.example.exam.mapper.system.SysOrganizationMapper;
import com.example.exam.mapper.system.SysRoleMapper;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.PermissionCacheService;
import com.example.exam.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements UserService {

    private final PasswordEncoder passwordEncoder;
    private final UserConverter userConverter;
    private final SysRoleMapper roleMapper;
    private final SysOrganizationMapper organizationMapper;
    private final PermissionCacheService permissionCacheService;

    @Override
    public IPage<UserDTO> pageUserDTO(Page<?> page, String username, String realName, UserStatus status) {
        // 1. 使用LambdaQueryWrapper查询用户
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(username != null && !username.isEmpty(), SysUser::getUsername, username)
               .like(realName != null && !realName.isEmpty(), SysUser::getRealName, realName)
               .eq(status != null, SysUser::getStatus, status)
               .orderByDesc(SysUser::getCreateTime);

        Page<SysUser> userPage = new Page<>(page.getCurrent(), page.getSize());
        IPage<SysUser> userResult = this.page(userPage, wrapper);

        // 2. 转换为DTO
        List<UserDTO> dtoList = userResult.getRecords().stream().map(user -> {
            UserDTO dto = userConverter.toDTO(user);

            // 3. 查询角色名称
            if (user.getRoleId() != null) {
                SysRole role = roleMapper.selectById(user.getRoleId());
                if (role != null) {
                    dto.setRoleName(role.getRoleName());
                }
            }

            // 4. 查询组织名称
            if (user.getOrgId() != null) {
                SysOrganization org = organizationMapper.selectById(user.getOrgId());
                if (org != null) {
                    dto.setOrgName(org.getOrgName());
                }
            }

            return dto;
        }).collect(Collectors.toList());

        // 5. 构建返回结果
        Page<UserDTO> dtoPage = new Page<>(userResult.getCurrent(), userResult.getSize(), userResult.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    @Override
    public SysUser getUserByUsername(String username) {
        return baseMapper.selectByUsername(username);
    }

    public SysUser getUserByPhone(String phone) {
        return baseMapper.selectByPhone(phone);
    }

    public SysUser getUserByEmail(String email) {
        return baseMapper.selectByEmail(email);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean register(SysUser user) {
        // 检查用户名是否已存在
        if (getUserByUsername(user.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }

        // 检查手机号是否已存在
        if (user.getPhone() != null && getUserByPhone(user.getPhone()) != null) {
            throw new RuntimeException("手机号已被注册");
        }

        // 检查邮箱是否已存在
        if (user.getEmail() != null && getUserByEmail(user.getEmail()) != null) {
            throw new RuntimeException("邮箱已被注册");
        }

        // 加密密码
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        // 设置审核状态为草稿
        user.setAuditStatus(AuditStatus.DRAFT);
        return save(user);
    }

    @Override
    public boolean updateById(SysUser entity) {
        // 如果密码为空字符串，设置为null以防止更新
        if (entity.getPassword() != null && entity.getPassword().trim().isEmpty()) {
            entity.setPassword(null);
        }

        // 检查是否更新了角色，如果是则清除用户权限缓存
        if (entity.getRoleId() != null && entity.getUserId() != null) {
            SysUser oldUser = getById(entity.getUserId());
            if (oldUser != null && !entity.getRoleId().equals(oldUser.getRoleId())) {
                // 角色发生变化，清除该用户的权限缓存
                permissionCacheService.evictUserPermissions(entity.getUserId());
            }
        }

        return super.updateById(entity);
    }

    @Override
    public SysUser validateUser(String username, String password) {
        SysUser user = getUserByUsername(username);
        // 检查密码是否为空
        if (user != null && user.getPassword() != null && !user.getPassword().isEmpty()) {
            if (passwordEncoder.matches(password, user.getPassword())) {
                return user;
            }
        }
        return null;
    }

    @Override
    public boolean updateUserStatus(Long userId, UserStatus status) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setStatus(status);
        return updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean resetPassword(Long userId, String newPassword) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setPassword(passwordEncoder.encode(newPassword));
        return updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean changePassword(Long userId, String oldPassword, String newPassword) {
        SysUser user = getById(userId);
        if (user == null) {
            return false;
        }
        // 验证旧密码
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            return false;
        }
        // 更新新密码
        user.setPassword(passwordEncoder.encode(newPassword));
        return updateById(user);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateLastLogin(Long userId, String ip) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setLastLoginTime(LocalDateTime.now());
        user.setLastLoginIp(ip);
        updateById(user);
    }

    @Override
    public SysRole getRoleById(Long roleId) {
        if (roleId == null) {
            return null;
        }
        return roleMapper.selectById(roleId);
    }
}

