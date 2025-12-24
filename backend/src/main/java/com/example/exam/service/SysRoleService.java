package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.system.SysRole;

import java.util.List;

/**
 * 角色Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
public interface SysRoleService extends IService<SysRole> {

    /**
     * 分页查询角色
     * @param page 分页对象
     * @param keyword 关键词
     * @param status 状态
     * @return 角色分页数据
     */
    IPage<SysRole> pageRoles(Page<SysRole> page, String keyword, Integer status);

    /**
     * 检查角色编码是否存在
     * @param roleCode 角色编码
     * @param excludeRoleId 排除的角色ID
     * @return 是否存在
     */
    boolean isRoleCodeExists(String roleCode, Long excludeRoleId);

    /**
     * 为角色分配权限
     * @param roleId 角色ID
     * @param permissionIds 权限ID列表
     * @return 是否成功
     */
    boolean assignPermissions(Long roleId, List<Long> permissionIds);

    /**
     * 获取角色的权限ID列表
     * @param roleId 角色ID
     * @return 权限ID列表
     */
    List<Long> getRolePermissionIds(Long roleId);

    /**
     * 检查角色是否被使用（是否有用户）
     * @param roleId 角色ID
     * @return 是否被使用
     */
    boolean isRoleInUse(Long roleId);

    /**
     * 获取所有启用的角色
     * @return 角色列表
     */
    List<SysRole> getEnabledRoles();
}

