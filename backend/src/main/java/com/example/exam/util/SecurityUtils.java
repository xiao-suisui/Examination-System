package com.example.exam.util;

import com.example.exam.security.UserDetailsImpl;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Collection;

/**
 * Security工具类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
public class SecurityUtils {

    /**
     * 获取当前登录用户ID
     */
    public static Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return null;
        }

        Object principal = authentication.getPrincipal();

        // 如果是UserDetailsImpl对象
        if (principal instanceof UserDetailsImpl) {
            return ((UserDetailsImpl) principal).getUserId();
        }

        if (principal instanceof Long) {
            return (Long) principal;
        }

        // 尝试从用户名中解析（如果用户名就是用户ID）
        try {
            return Long.parseLong(authentication.getName());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 获取当前登录用户ID（别名方法，与SubjectServiceImpl中使用保持一致）
     */
    public static Long getUserId() {
        return getCurrentUserId();
    }

    /**
     * 获取当前登录用户名
     */
    public static String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        return authentication.getName();
    }

    /**
     * 获取当前用户角色代码
     */
    public static String getRoleCode() {
        Authentication authentication = getAuthentication();
        if (authentication == null) {
            return null;
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetailsImpl) {
            return ((UserDetailsImpl) principal).getRoleCode();
        }

        // 从权限中获取角色（权限格式：ROLE_ADMIN）
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        if (authorities != null && !authorities.isEmpty()) {
            for (GrantedAuthority authority : authorities) {
                String auth = authority.getAuthority();
                if (auth.startsWith("ROLE_")) {
                    return auth.substring(5); // 移除 "ROLE_" 前缀
                }
            }
        }

        return null;
    }

    /**
     * 获取当前用户组织ID
     */
    public static Long getOrgId() {
        Authentication authentication = getAuthentication();
        if (authentication == null) {
            return null;
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetailsImpl) {
            return ((UserDetailsImpl) principal).getOrgId();
        }

        return null;
    }

    /**
     * 获取当前用户组织ID（别名方法）
     */
    public static Long getCurrentUserOrgId() {
        return getOrgId();
    }

    /**
     * 判断是否是超级管理员
     * 支持多种判断方式：
     * 1. 角色代码为 ADMIN
     * 2. 用户名为 admin
     * 3. 用户ID为 1（第一个用户通常是管理员）
     */
    public static boolean isSuperAdmin() {
        Authentication authentication = getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        // 获取当前用户名
        String username = getCurrentUsername();

        // 方式1：用户名为 admin
        if ("admin".equalsIgnoreCase(username)) {
            return true;
        }

        // 方式2：用户ID为 1
        Long userId = getCurrentUserId();
        if (userId != null && userId == 1L) {
            return true;
        }

        // 方式3：角色代码为 ADMIN 或 SYSTEM_ADMIN
        String roleCode = getRoleCode();
        if ("ADMIN".equals(roleCode) || "SYSTEM_ADMIN".equals(roleCode)) {
            return true;
        }

        // 方式4：从UserDetailsImpl获取角色ID为1（管理员角色）
        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetailsImpl) {
            Long roleId = ((UserDetailsImpl) principal).getRoleId();
            return roleId != null && roleId == 1L;
        }

        return false;
    }

    /**
     * 获取当前认证对象
     */
    public static Authentication getAuthentication() {
        return SecurityContextHolder.getContext().getAuthentication();
    }
}

