package com.example.exam.controller;

import com.example.exam.common.result.Result;
import com.example.exam.entity.system.SysUser;
import com.example.exam.service.UserService;
import com.example.exam.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Tag(name = "认证授权", description = "用户登录、登出、Token刷新等认证相关操作")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final com.example.exam.filter.JwtAuthenticationFilter jwtAuthenticationFilter;

    @Operation(summary = "用户登录", description = "用户名密码登录，返回JWT Token")
    @com.example.exam.annotation.OperationLog(module = "认证模块", type = "登录", description = "用户登录")
    @PostMapping("/login")
    public Result<Map<String, Object>> login(
            @Parameter(description = "登录信息", required = true) @Valid @RequestBody com.example.exam.dto.LoginDTO loginDTO,
            HttpServletRequest request) {

        // 使用自定义验证（UserService已经包含了密码验证逻辑）
        SysUser user = userService.validateUser(loginDTO.getUsername(), loginDTO.getPassword());

        if (user == null) {
            log.warn("登录失败：用户名或密码错误 - {}", loginDTO.getUsername());
            return Result.error("用户名或密码错误");
        }

        // 检查用户状态
        if (user.getStatus() != null && user.getStatus() == 0) {
            return Result.error("账号已被禁用");
        }

        // 生成Token
        String token = jwtUtil.generateToken(user.getUsername(), user.getUserId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), user.getUserId());

        // 更新最后登录时间和IP
        String ip = getClientIp(request);
        userService.updateLastLogin(user.getUserId(), ip);

        // 返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("refreshToken", refreshToken);
        result.put("userId", user.getUserId());
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("roleId", user.getRoleId());

        return Result.success("登录成功", result);
    }

    @Operation(summary = "用户登出", description = "用户登出，将Token加入黑名单")
    @com.example.exam.annotation.OperationLog(module = "认证模块", type = "登出", description = "用户登出", recordParams = false)
    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String authorization) {
        // 提取Token并加入黑名单
        if (authorization != null && authorization.startsWith("Bearer ")) {
            String token = authorization.substring(7);
            try {
                // 获取Token过期时间
                long expirationTime = jwtUtil.getExpirationDateFromToken(token).getTime() - System.currentTimeMillis();
                if (expirationTime > 0) {
                    // 将Token加入黑名单
                    jwtAuthenticationFilter.addTokenToBlacklist(token, expirationTime);
                }
            } catch (Exception e) {
                // Token无效或已过期，忽略
                log.warn("登出时Token解析失败：{}", e.getMessage());
            }
        }
        return Result.success();
    }

    @Operation(summary = "刷新Token", description = "使用刷新Token获取新的访问Token")
    @PostMapping("/refresh")
    public Result<Map<String, String>> refresh(
            @Parameter(description = "刷新Token", required = true) @RequestParam String refreshToken) {

        try {
            // 从刷新Token中获取用户名
            String username = jwtUtil.getUsernameFromToken(refreshToken);
            Long userId = jwtUtil.getUserIdFromToken(refreshToken);

            // 验证刷新Token
            if (!jwtUtil.validateToken(refreshToken, username)) {
                return Result.error("刷新Token无效或已过期");
            }

            // 生成新的访问Token
            String newToken = jwtUtil.generateToken(username, userId);

            Map<String, String> result = new HashMap<>();
            result.put("token", newToken);

            return Result.success("Token刷新成功", result);
        } catch (Exception e) {
            return Result.error("刷新Token失败");
        }
    }

    @Operation(summary = "获取当前用户信息", description = "根据Token获取当前登录用户的信息")
    @GetMapping("/current-user")
    public Result<Map<String, Object>> getCurrentUser(
            @RequestHeader(value = "Authorization", required = false) String authorization) {

        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return Result.error("未登录或Token无效");
        }

        try {
            String token = authorization.substring(7);
            String username = jwtUtil.getUsernameFromToken(token);

            // 验证Token
            if (!jwtUtil.validateToken(token, username)) {
                return Result.error("Token已过期");
            }

            // 获取用户信息
            SysUser user = userService.getUserByUsername(username);
            if (user == null) {
                return Result.error("用户不存在");
            }

            Map<String, Object> result = new HashMap<>();
            result.put("userId", user.getUserId());
            result.put("username", user.getUsername());
            result.put("realName", user.getRealName());
            result.put("email", user.getEmail());
            result.put("phone", user.getPhone());
            result.put("roleId", user.getRoleId());
            result.put("avatar", user.getAvatar());
            result.put("orgId", user.getOrgId());
            result.put("status", user.getStatus());
            // 不返回密码等敏感信息

            return Result.success("获取成功", result);
        } catch (Exception e) {
            return Result.error("获取用户信息失败");
        }
    }

    /**
     * 获取客户端IP地址
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}

