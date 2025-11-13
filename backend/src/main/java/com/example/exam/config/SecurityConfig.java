package com.example.exam.config;

import com.example.exam.filter.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;

/**
 * Security配置类 - 纯 JWT 认证模式
 *
 * <p>说明：本项目使用 JWT Token 进行身份认证，不依赖 Spring Security 的传统认证流程</p>
 *
 * <p>认证流程：</p>
 * <ul>
 *   <li>1. 用户登录：调用 /api/auth/login，验证用户名密码，返回 JWT Token</li>
 *   <li>2. 携带Token访问：前端在请求头中携带 Authorization: Bearer {token}</li>
 *   <li>3. JWT过滤器验证：JwtAuthenticationFilter 验证 Token 有效性并设置用户上下文</li>
 *   <li>4. 业务处理：Controller 正常处理业务逻辑</li>
 * </ul>
 *
 * <p>不使用的 Spring Security 功能：</p>
 * <ul>
 *   <li>❌ UserDetailsService - 不需要，直接查询数据库验证用户</li>
 *   <li>❌ AuthenticationManager - 不需要，手动验证密码</li>
 *   <li>❌ AuthenticationProvider - 不需要，不使用 Spring Security 认证流程</li>
 *   <li>❌ Session - 不需要，使用无状态 JWT</li>
 *   <li>❌ 默认登录页 - 不需要，前后端分离项目</li>
 * </ul>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-08
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * 密码加密器Bean
     *
     * <p>用于：</p>
     * <ul>
     *   <li>用户注册时加密密码</li>
     *   <li>用户登录时验证密码（BCrypt会自动验证）</li>
     * </ul>
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Security过滤器链配置
     *
     * <p>核心配置：</p>
     * <ul>
     *   <li>禁用 CSRF - 前后端分离项目使用 Token 认证，不需要 CSRF 保护</li>
     *   <li>禁用 Session - 使用无状态 JWT，不需要服务器端 Session</li>
     *   <li>配置 CORS - 允许前端跨域访问</li>
     *   <li>配置白名单 - 登录、注册、API文档等接口无需认证</li>
     *   <li>添加 JWT 过滤器 - 在 UsernamePasswordAuthenticationFilter 之前执行</li>
     * </ul>
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 禁用CSRF（前后端分离项目使用Token认证）
            .csrf(AbstractHttpConfigurer::disable)

            // 配置CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))

            // 配置Session管理（使用无状态JWT）
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // 配置请求授权
            .authorizeHttpRequests(auth -> auth
                // 公开接口（无需认证）
                .requestMatchers(
                    "/api/auth/**",           // 认证接口（登录、登出、刷新Token等）
                    "/api/user/register",     // 用户注册接口
                    "/error",                 // 错误页面
                    "/doc.html",              // Knife4j文档
                    "/swagger-ui.html",       // Swagger文档
                    "/swagger-ui/**",         // Swagger UI资源
                    "/v3/api-docs/**",        // OpenAPI文档
                    "/swagger-resources/**",  // Swagger资源
                    "/webjars/**"             // WebJars资源
                ).permitAll()

                // 其他所有请求需要认证
                .anyRequest().authenticated()
            )

            // 禁用默认登录页（前后端分离项目不需要）
            .formLogin(AbstractHttpConfigurer::disable)

            // 禁用HTTP Basic认证
            .httpBasic(AbstractHttpConfigurer::disable)

            // 添加JWT过滤器（在 UsernamePasswordAuthenticationFilter 之前执行）
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * CORS配置
     *
     * <p>允许前端跨域访问后端API</p>
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 允许的源（前端地址）
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:3001",
            "http://192.168.*.*:*"
        ));

        // 允许的请求方法
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));

        // 允许的请求头
        configuration.setAllowedHeaders(Collections.singletonList("*"));

        // 允许携带凭证（Cookie、Authorization Header等）
        configuration.setAllowCredentials(true);

        // 预检请求的缓存时间（秒）
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}

