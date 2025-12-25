package com.example.exam.service.impl;

import com.example.exam.service.PermissionCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 权限缓存服务实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PermissionCacheServiceImpl implements PermissionCacheService {

    private final RedisTemplate<String, Object> redisTemplate;

    /**
     * Redis缓存键前缀
     */
    private static final String CACHE_KEY_PREFIX = "permission:user:";

    /**
     * 角色用户关系缓存键前缀
     */
    private static final String ROLE_USERS_KEY_PREFIX = "permission:role:users:";

    /**
     * 缓存过期时间（小时）
     */
    private static final long CACHE_EXPIRE_HOURS = 24;

    /**
     * 构建用户权限缓存键
     */
    private String buildUserPermissionKey(Long userId) {
        return CACHE_KEY_PREFIX + userId;
    }

    /**
     * 构建角色用户关系缓存键
     */
    private String buildRoleUsersKey(Long roleId) {
        return ROLE_USERS_KEY_PREFIX + roleId;
    }

    @Override
    public void cacheUserPermissions(Long userId, Set<String> permissionCodes) {
        try {
            String key = buildUserPermissionKey(userId);
            redisTemplate.opsForValue().set(key, permissionCodes, CACHE_EXPIRE_HOURS, TimeUnit.HOURS);
            log.debug("已缓存用户权限 - userId: {}, permissions: {}", userId, permissionCodes);
        } catch (Exception e) {
            log.error("缓存用户权限失败 - userId: {}", userId, e);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public Set<String> getCachedUserPermissions(Long userId) {
        try {
            String key = buildUserPermissionKey(userId);
            Object cached = redisTemplate.opsForValue().get(key);
            if (cached instanceof Set) {
                log.debug("从缓存获取用户权限 - userId: {}", userId);
                return (Set<String>) cached;
            }
            return null;
        } catch (Exception e) {
            log.error("获取缓存的用户权限失败 - userId: {}", userId, e);
            return null;
        }
    }

    @Override
    public void evictUserPermissions(Long userId) {
        try {
            String key = buildUserPermissionKey(userId);
            redisTemplate.delete(key);
            log.info("已删除用户权限缓存 - userId: {}", userId);
        } catch (Exception e) {
            log.error("删除用户权限缓存失败 - userId: {}", userId, e);
        }
    }

    @Override
    public void evictUserPermissionsBatch(List<Long> userIds) {
        try {
            List<String> keys = userIds.stream()
                    .map(this::buildUserPermissionKey)
                    .collect(Collectors.toList());
            redisTemplate.delete(keys);
            log.info("已批量删除用户权限缓存 - userIds: {}", userIds);
        } catch (Exception e) {
            log.error("批量删除用户权限缓存失败 - userIds: {}", userIds, e);
        }
    }

    @Override
    public void evictAllUserPermissions() {
        try {
            Set<String> keys = redisTemplate.keys(CACHE_KEY_PREFIX + "*");
            if (!keys.isEmpty()) {
                redisTemplate.delete(keys);
                log.info("已清空所有用户权限缓存 - 共{}条", keys.size());
            }
        } catch (Exception e) {
            log.error("清空所有用户权限缓存失败", e);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void evictPermissionsByRole(Long roleId) {
        try {
            // 获取角色下的所有用户ID
            String roleUsersKey = buildRoleUsersKey(roleId);
            Object cached = redisTemplate.opsForValue().get(roleUsersKey);

            if (cached instanceof Set) {
                Set<Long> userIds = (Set<Long>) cached;
                evictUserPermissionsBatch(userIds.stream().collect(Collectors.toList()));
                log.info("已删除角色相关用户的权限缓存 - roleId: {}, userCount: {}", roleId, userIds.size());
            } else {
                // 如果没有缓存角色用户关系，则清空所有权限缓存（保守策略）
                log.warn("未找到角色用户关系缓存，清空所有权限缓存 - roleId: {}", roleId);
                evictAllUserPermissions();
            }
        } catch (Exception e) {
            log.error("删除角色相关权限缓存失败 - roleId: {}", roleId, e);
            // 失败时清空所有权限缓存，确保数据一致性
            evictAllUserPermissions();
        }
    }

    @Override
    public boolean hasUserPermissions(Long userId) {
        try {
            String key = buildUserPermissionKey(userId);
            return redisTemplate.hasKey(key);
        } catch (Exception e) {
            log.error("检查用户权限缓存是否存在失败 - userId: {}", userId, e);
            return false;
        }
    }

    /**
     * 缓存角色用户关系（用于权限更新时清除缓存）
     *
     * @param roleId 角色ID
     * @param userIds 用户ID集合
     */
    public void cacheRoleUsers(Long roleId, Set<Long> userIds) {
        try {
            String key = buildRoleUsersKey(roleId);
            redisTemplate.opsForValue().set(key, userIds, CACHE_EXPIRE_HOURS, TimeUnit.HOURS);
            log.debug("已缓存角色用户关系 - roleId: {}, userCount: {}", roleId, userIds.size());
        } catch (Exception e) {
            log.error("缓存角色用户关系失败 - roleId: {}", roleId, e);
        }
    }

    /**
     * 删除角色用户关系缓存
     *
     * @param roleId 角色ID
     */
    public void evictRoleUsers(Long roleId) {
        try {
            String key = buildRoleUsersKey(roleId);
            redisTemplate.delete(key);
            log.debug("已删除角色用户关系缓存 - roleId: {}", roleId);
        } catch (Exception e) {
            log.error("删除角色用户关系缓存失败 - roleId: {}", roleId, e);
        }
    }
}

