package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.UserStatus;
import com.example.exam.dto.UserDTO;
import com.example.exam.entity.system.SysUser;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

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

    @Override
    public IPage<UserDTO> pageUserDTO(Page<?> page, String username, String realName, Integer status) {
        return baseMapper.selectUserDTOPage(page, username, realName, status);
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
    public SysUser validateUser(String username, String password) {
        SysUser user = getUserByUsername(username);
        if (user != null && passwordEncoder.matches(password, user.getPassword())) {
            return user;
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
}

