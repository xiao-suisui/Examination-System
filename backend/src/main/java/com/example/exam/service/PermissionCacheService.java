package com.example.exam.service;

import java.util.List;
import java.util.Set;

/**
 * 权限缓存服务接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
public interface PermissionCacheService {

    /**
     * 缓存用户权限编码
     *
     * @param userId 用户ID
     * @param permissionCodes 权限编码集合
     */
    void cacheUserPermissions(Long userId, Set<String> permissionCodes);

    /**
     * 获取缓存的用户权限编码
     *
     * @param userId 用户ID
     * @return 权限编码集合，如果缓存不存在返回null
     */
    Set<String> getCachedUserPermissions(Long userId);

    /**
     * 删除用户权限缓存
     *
     * @param userId 用户ID
     */
    void evictUserPermissions(Long userId);

    /**
     * 批量删除用户权限缓存
     *
     * @param userIds 用户ID列表
     */
    void evictUserPermissionsBatch(List<Long> userIds);

    /**
     * 清空所有用户权限缓存
     */
    void evictAllUserPermissions();

    /**
     * 根据角色ID删除相关用户的权限缓存
     *
     * @param roleId 角色ID
     */
    void evictPermissionsByRole(Long roleId);

    /**
     * 检查权限缓存是否存在
     *
     * @param userId 用户ID
     * @return true-存在，false-不存在
     */
    boolean hasUserPermissions(Long userId);
}

