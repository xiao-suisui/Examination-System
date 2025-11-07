package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysPermission;
import com.example.exam.entity.system.SysRolePermission;
import com.example.exam.entity.system.SysUser;
import com.example.exam.mapper.system.SysPermissionMapper;
import com.example.exam.mapper.system.SysRolePermissionMapper;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.SysPermissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 权限Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysPermissionServiceImpl extends ServiceImpl<SysPermissionMapper, SysPermission>
        implements SysPermissionService {

    private final SysRolePermissionMapper rolePermissionMapper;
    private final SysUserMapper userMapper;

    @Override
    public List<SysPermission> getPermissionTree() {
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(SysPermission::getSort)
               .orderByAsc(SysPermission::getPermId);

        List<SysPermission> allPerms = this.list(wrapper);
        return buildTree(allPerms, 0L);
    }

    @Override
    public List<SysPermission> getChildrenByParentId(Long parentId) {
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getParentId, parentId)
               .orderByAsc(SysPermission::getSort)
               .orderByAsc(SysPermission::getPermId);
        return this.list(wrapper);
    }

    @Override
    public boolean isPermCodeExists(String permCode, Long excludePermId) {
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getPermCode, permCode);
        if (excludePermId != null) {
            wrapper.ne(SysPermission::getPermId, excludePermId);
        }
        return this.count(wrapper) > 0;
    }

    @Override
    public boolean hasChildren(Long permId) {
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getParentId, permId);
        return this.count(wrapper) > 0;
    }

    @Override
    public boolean isUsedByRoles(Long permId) {
        LambdaQueryWrapper<SysRolePermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysRolePermission::getPermId, permId);
        return rolePermissionMapper.selectCount(wrapper) > 0;
    }

    @Override
    public List<SysPermission> getUserPermissions(Long userId) {
        // 1. 获取用户信息
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            return new ArrayList<>();
        }

        // 2. 获取用户角色的所有权限ID
        LambdaQueryWrapper<SysRolePermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysRolePermission::getRoleId, user.getRoleId());
        List<SysRolePermission> rolePermissions = rolePermissionMapper.selectList(wrapper);

        if (rolePermissions.isEmpty()) {
            return new ArrayList<>();
        }

        // 3. 查询权限详情
        List<Long> permIds = rolePermissions.stream()
                .map(SysRolePermission::getPermId)
                .collect(Collectors.toList());

        return this.listByIds(permIds);
    }

    @Override
    public List<String> getUserPermissionCodes(Long userId) {
        List<SysPermission> permissions = getUserPermissions(userId);
        return permissions.stream()
                .map(SysPermission::getPermCode)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchDelete(List<Long> permIds) {
        try {
            for (Long permId : permIds) {
                // 检查是否有子权限
                if (hasChildren(permId)) {
                    throw new RuntimeException("权限存在子权限，无法删除");
                }
                // 检查是否被角色使用
                if (isUsedByRoles(permId)) {
                    throw new RuntimeException("权限已被角色使用，无法删除");
                }
            }
            return this.removeByIds(permIds);
        } catch (Exception e) {
            log.error("批量删除权限失败", e);
            throw e;
        }
    }

    /**
     * 构建树形结构
     */
    private List<SysPermission> buildTree(List<SysPermission> allPerms, Long parentId) {
        return allPerms.stream()
                .filter(perm -> {
                    Long pid = perm.getParentId();
                    return (pid == null && parentId == 0L) || parentId.equals(pid);
                })
                .peek(perm -> {
                    List<SysPermission> children = buildTree(allPerms, perm.getPermId());
                    // 可以在这里设置children字段（需要在实体类中添加@TableField(exist = false)）
                })
                .collect(Collectors.toList());
    }
}

