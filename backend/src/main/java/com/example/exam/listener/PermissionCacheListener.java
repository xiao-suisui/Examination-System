package com.example.exam.listener;

import com.example.exam.service.PermissionCacheService;
import com.example.exam.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.security.authentication.event.AuthenticationSuccessEvent;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;


/**
 * 权限缓存监听器
 * 在用户登录成功后预加载权限到Redis缓存
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PermissionCacheListener {

    private final SysUserService userService;
    private final PermissionCacheService permissionCacheService;

    @EventListener
    public void onAuthenticationSuccess(AuthenticationSuccessEvent event) {
        try {
            Authentication authentication = event.getAuthentication();
            String username = authentication.getName();

            // 根据用户名获取用户ID并预加载权限
            var user = userService.getByUsername(username);
            if (user != null) {
                permissionCacheService.getUserPermissionCodes(user.getId());
                log.debug("用户登录成功，已预加载权限 - username: {}, userId: {}", username, user.getId());
            }
        } catch (Exception e) {
            log.error("预加载用户权限失败", e);
        }
    }
}
