package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.system.SysPermission;

import java.util.List;

/**
 * 权限Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
public interface SysPermissionService extends IService<SysPermission> {

    /**
     * 获取权限树
     * @return 权限树
     */
    List<SysPermission> getPermissionTree();

    /**
     * 根据父ID获取子权限
     * @param parentId 父权限ID
     * @return 子权限列表
     */
    List<SysPermission> getChildrenByParentId(Long parentId);

    /**
     * 检查权限编码是否存在
     * @param permCode 权限编码
     * @param excludePermId 排除的权限ID
     * @return 是否存在
     */
    boolean isPermCodeExists(String permCode, Long excludePermId);

    /**
     * 检查是否有子权限
     * @param permId 权限ID
     * @return 是否有子权限
     */
    boolean hasChildren(Long permId);

    /**
     * 检查权限是否被角色使用
     * @param permId 权限ID
     * @return 是否被使用
     */
    boolean isUsedByRoles(Long permId);

    /**
     * 获取用户权限列表
     * @param userId 用户ID
     * @return 权限列表
     */
    List<SysPermission> getUserPermissions(Long userId);

    /**
     * 获取用户权限编码列表
     * @param userId 用户ID
     * @return 权限编码列表
     */
    List<String> getUserPermissionCodes(Long userId);

    /**
     * 批量删除权限
     * @param permIds 权限ID列表
     * @return 是否成功
     */
    boolean batchDelete(List<Long> permIds);
}

