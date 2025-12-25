package com.example.exam.filter;

import com.example.exam.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import java.util.concurrent.TimeUnit;

/**
 * JWT认证过滤器
 * 从请求头中提取Token，验证并设置认证信息到SecurityContext
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String TOKEN_PREFIX = "Bearer ";
    private static final String TOKEN_HEADER = "Authorization";
    private static final String TOKEN_BLACKLIST_PREFIX = "token:blacklist:";

    @Override
    protected void doFilterInternal(@NotNull HttpServletRequest request,
                                    @NotNull HttpServletResponse response,
                                    @NotNull FilterChain filterChain)
            throws ServletException, IOException {

        try {
            // 1. 从请求头中提取Token
            String token = extractToken(request);

            if (token == null) {
                filterChain.doFilter(request, response);
                return;
            }

            // 2. 检查Token是否在黑名单中（已登出）
            if (isTokenBlacklisted(token)) {
                log.warn("Token已被列入黑名单：{}", token.substring(0, 20) + "...");
                filterChain.doFilter(request, response);
                return;
            }

            // 3. 验证Token并提取用户信息
            String username = jwtUtil.getUsernameFromToken(token);
            Long userId = jwtUtil.getUserIdFromToken(token);

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                // 4. 验证Token有效性
                if (jwtUtil.validateToken(token, username)) {
                    // 5. 从Token中提取更多用户信息（如果可用）
                    // 注意：这里我们创建一个简单的UserDetailsImpl对象
                    // 如果需要完整的用户信息，应该从数据库加载
                    com.example.exam.security.UserDetailsImpl userDetails = new com.example.exam.security.UserDetailsImpl();
                    userDetails.setUserId(userId);
                    userDetails.setUsername(username);

                    // 尝试从Token中获取roleId（如果有的话）
                    try {
                        Long roleId = jwtUtil.getRoleIdFromToken(token);
                        userDetails.setRoleId(roleId);
                    } catch (Exception ignored) {
                        // Token中可能没有roleId，忽略
                    }

                    // 尝试从Token中获取orgId（如果有的话）
                    try {
                        Long orgId = jwtUtil.getOrgIdFromToken(token);
                        userDetails.setOrgId(orgId);
                    } catch (Exception ignored) {
                        // Token中可能没有orgId，忽略
                    }

                    userDetails.setEnabled(true);

                    // 创建认证对象，使用UserDetailsImpl作为principal
                    UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                            userDetails,  // principal 使用 UserDetailsImpl
                            null,         // credentials
                            userDetails.getAuthorities()
                        );

                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    // 6. 设置到SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    log.debug("JWT认证成功：userId={}, username={}", userId, username);
                } else {
                    log.warn("Token验证失败：username={}", username);
                }
            }

        } catch (Exception e) {
            log.error("JWT认证过滤器异常：{}", e.getMessage(), e);
            // 不阻止请求继续，让后续过滤器处理
        }

        filterChain.doFilter(request, response);
    }

    /**
     * 从请求头中提取Token
     */
    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(TOKEN_HEADER);

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(TOKEN_PREFIX)) {
            return bearerToken.substring(TOKEN_PREFIX.length());
        }

        return null;
    }

    /**
     * 检查Token是否在黑名单中
     */
    private boolean isTokenBlacklisted(String token) {
        try {
            String key = TOKEN_BLACKLIST_PREFIX + token;
            return redisTemplate.hasKey(key);
        } catch (Exception e) {
            log.error("检查Token黑名单失败：{}", e.getMessage());
            return false;
        }
    }

    /**
     * 将Token加入黑名单
     * @param token JWT Token
     * @param expirationTime 过期时间（毫秒）
     */
    public void addTokenToBlacklist(String token, long expirationTime) {
        try {
            String key = TOKEN_BLACKLIST_PREFIX + token;
            // 设置过期时间，与Token过期时间一致
            redisTemplate.opsForValue().set(key, "1", expirationTime, TimeUnit.MILLISECONDS);
            log.debug("Token已加入黑名单：{}", token.substring(0, 20) + "...");
        } catch (Exception e) {
            log.error("添加Token黑名单失败：{}", e.getMessage());
        }
    }
}

