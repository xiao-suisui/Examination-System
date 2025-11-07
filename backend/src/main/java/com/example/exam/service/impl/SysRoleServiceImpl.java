package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysRole;
import com.example.exam.entity.system.SysRolePermission;
import com.example.exam.entity.system.SysUser;
import com.example.exam.mapper.system.SysRoleMapper;
import com.example.exam.mapper.system.SysRolePermissionMapper;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.SysRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 角色Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysRoleServiceImpl extends ServiceImpl<SysRoleMapper, SysRole> implements SysRoleService {

    private final SysRolePermissionMapper rolePermissionMapper;
    private final SysUserMapper userMapper;

    @Override
    public IPage<SysRole> pageRoles(Page<SysRole> page, String keyword, Integer status) {
        LambdaQueryWrapper<SysRole> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(SysRole::getRoleName, keyword)
                             .or()
                             .like(SysRole::getRoleCode, keyword)
                             .or()
                             .like(SysRole::getRoleDesc, keyword));
        }

        wrapper.eq(status != null, SysRole::getStatus, status)
               .orderByAsc(SysRole::getSort)
               .orderByAsc(SysRole::getRoleId);

        return this.page(page, wrapper);
    }

    @Override
    public boolean isRoleCodeExists(String roleCode, Long excludeRoleId) {
        LambdaQueryWrapper<SysRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysRole::getRoleCode, roleCode);
        if (excludeRoleId != null) {
            wrapper.ne(SysRole::getRoleId, excludeRoleId);
        }
        return this.count(wrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean assignPermissions(Long roleId, List<Long> permissionIds) {
        try {
            // 1. 删除角色原有权限
            LambdaQueryWrapper<SysRolePermission> deleteWrapper = new LambdaQueryWrapper<>();
            deleteWrapper.eq(SysRolePermission::getRoleId, roleId);
            rolePermissionMapper.delete(deleteWrapper);

            // 2. 插入新权限
            if (permissionIds != null && !permissionIds.isEmpty()) {
                for (Long permId : permissionIds) {
                    SysRolePermission rolePermission = new SysRolePermission();
                    rolePermission.setRoleId(roleId);
                    rolePermission.setPermId(permId);
                    rolePermissionMapper.insert(rolePermission);
                }
            }

            log.info("角色{}权限分配成功，共{}个权限", roleId, permissionIds != null ? permissionIds.size() : 0);
            return true;
        } catch (Exception e) {
            log.error("角色权限分配失败", e);
            throw new RuntimeException("角色权限分配失败: " + e.getMessage());
        }
    }

    @Override
    public List<Long> getRolePermissionIds(Long roleId) {
        LambdaQueryWrapper<SysRolePermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysRolePermission::getRoleId, roleId);
        List<SysRolePermission> rolePermissions = rolePermissionMapper.selectList(wrapper);
        return rolePermissions.stream()
                .map(SysRolePermission::getPermId)
                .collect(Collectors.toList());
    }

    @Override
    public boolean isRoleInUse(Long roleId) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getRoleId, roleId);
        return userMapper.selectCount(wrapper) > 0;
    }

    @Override
    public List<SysRole> getEnabledRoles() {
        LambdaQueryWrapper<SysRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysRole::getStatus, 1)
               .orderByAsc(SysRole::getSort)
               .orderByAsc(SysRole::getRoleId);
        return this.list(wrapper);
    }
}

