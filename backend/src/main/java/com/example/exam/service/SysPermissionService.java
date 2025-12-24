package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.dto.SysPermissionDTO;
import com.example.exam.entity.system.SysPermission;

import java.util.List;
import java.util.Set;

/**
 * 权限服务接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
public interface SysPermissionService extends IService<SysPermission> {

    /**
     * 获取用户权限列表
     *
     * @param userId 用户ID
     * @return 权限列表
     */
    List<SysPermission> getUserPermissions(Long userId);

    /**
     * 获取用户权限编码集合
     *
     * @param userId 用户ID
     * @return 权限编码集合
     */
    Set<String> getUserPermissionCodes(Long userId);

    /**
     * 获取角色权限列表
     *
     * @param roleId 角色ID
     * @return 权限列表
     */
    List<SysPermission> getRolePermissions(Long roleId);

    /**
     * 获取权限树（树形结构）
     *
     * @return 权限树
     */
    List<SysPermissionDTO> getPermissionTree();

    /**
     * 为角色分配权限
     *
     * @param roleId 角色ID
     * @param permIds 权限ID列表
     * @return 是否成功
     */
    boolean assignPermissionsToRole(Long roleId, List<Long> permIds);

    /**
     * 检查用户是否有某个权限
     *
     * @param userId 用户ID
     * @param permCode 权限编码
     * @return 是否有权限
     */
    boolean hasPermission(Long userId, String permCode);

    /**
     * 创建权限
     *
     * @param permission 权限信息
     * @return 是否成功
     */
    boolean createPermission(SysPermission permission);

    /**
     * 更新权限
     *
     * @param permission 权限信息
     * @return 是否成功
     */
    boolean updatePermission(SysPermission permission);

    /**
     * 删除权限
     *
     * @param permId 权限ID
     * @return 是否成功
     */
    boolean deletePermission(Long permId);

    /**
     * 初始化默认权限
     */
    void initDefaultPermissions();
}

