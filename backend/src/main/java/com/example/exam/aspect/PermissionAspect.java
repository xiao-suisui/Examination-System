package com.example.exam.aspect;

import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.exception.BusinessException;
import com.example.exam.service.SysPermissionService;
import com.example.exam.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Set;

/**
 * 权限校验切面
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 * MVP版本：临时禁用权限验证，便于快速测试
 * TODO: 正式版本需要启用权限验证
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class PermissionAspect {

    private final SysPermissionService permissionService;

    @Around("@annotation(com.example.exam.annotation.RequirePermission)")
    public Object checkPermission(ProceedingJoinPoint joinPoint) throws Throwable {
        // 获取当前用户ID
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        // 超级管理员跳过权限检查（放在最前面）
        if (SecurityUtils.isSuperAdmin()) {
            log.debug("超级管理员访问，跳过权限检查 - userId: {}, username: {}",
                userId, SecurityUtils.getCurrentUsername());
            return joinPoint.proceed();
        }

        // 获取方法签名
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();

        // 获取注解
        RequirePermission requirePermission = method.getAnnotation(RequirePermission.class);
        if (requirePermission == null) {
            return joinPoint.proceed();
        }

        // 获取需要的权限编码
        String permCode = requirePermission.value();


        // 获取用户权限
        Set<String> userPermissions = permissionService.getUserPermissionCodes(userId);

        // 检查是否有权限
        if (!userPermissions.contains(permCode)) {
            log.warn("用户[{}]没有权限[{}]访问方法[{}]", userId, permCode, method.getName());
            throw new BusinessException("您没有权限执行此操作：" + requirePermission.desc());
        }

        log.debug("用户[{}]拥有权限[{}]，允许访问", userId, permCode);
        return joinPoint.proceed();
    }
}

