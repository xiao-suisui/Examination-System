package com.example.exam.aspect;

import com.alibaba.fastjson2.JSON;
import com.example.exam.annotation.OperationLog;
import com.example.exam.entity.system.SysOperationLog;
import com.example.exam.service.OperationLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.lang.reflect.Method;
import java.time.LocalDateTime;

/**
 * 操作日志AOP切面
 * 自动记录带有@OperationLog注解的方法的操作日志
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class OperationLogAspect {

    private final OperationLogService operationLogService;

    /**
     * 定义切点：所有带@OperationLog注解的方法
     */
    @Pointcut("@annotation(com.example.exam.annotation.OperationLog)")
    public void operationLogPointcut() {
    }

    /**
     * 环绕通知：记录操作日志
     */
    @Around("operationLogPointcut()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();

        // 获取注解信息
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        OperationLog operationLog = method.getAnnotation(OperationLog.class);

        // 获取请求信息
        HttpServletRequest request = getHttpServletRequest();

        // 构建操作日志对象
        SysOperationLog log = new SysOperationLog();
        log.setOperateModule(operationLog.module());
        log.setOperateType(operationLog.type());
        log.setOperateContent(operationLog.description());
        log.setIpAddress(request != null ? getClientIp(request) : "");

        // 获取当前用户ID
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Long) {
            log.setUserId((Long) authentication.getPrincipal());
        }

        // 记录请求参数（存储在deviceInfo字段，因为原表没有请求参数字段）
        if (operationLog.recordParams()) {
            Object[] args = joinPoint.getArgs();
            try {
                String params = JSON.toJSONString(args);
                log.setDeviceInfo(params.length() > 500 ? params.substring(0, 500) : params);
            } catch (Exception e) {
                log.setDeviceInfo("参数序列化失败");
            }
        }

        // 执行方法
        Object result;
        try {
            result = joinPoint.proceed();
            // 操作成功，不需要设置状态（表中没有status字段）

            // 记录返回结果（可选，存储在operateContent追加）
            if (operationLog.recordResult() && result != null) {
                try {
                    String resultStr = JSON.toJSONString(result);
                    if (resultStr.length() < 200) {
                        log.setOperateContent(log.getOperateContent() + " | 结果: " + resultStr);
                    }
                } catch (Exception e) {
                    // 忽略结果序列化失败
                }
            }

        } catch (Exception e) {
            // 操作失败，记录错误信息
            log.setOperateContent(log.getOperateContent() + " | 错误: " + e.getMessage());
            throw e;
        } finally {
            // 计算执行时间
            long executionTime = System.currentTimeMillis() - startTime;

            // 设置操作时间（自动填充）
            log.setOperateTime(LocalDateTime.now());

            // 记录执行时间到设备信息
            String deviceInfo = log.getDeviceInfo() != null ? log.getDeviceInfo() : "";
            log.setDeviceInfo(deviceInfo + " | 耗时: " + executionTime + "ms");

            // 异步保存日志
            saveLogAsync(log);
        }

        return result;
    }

    /**
     * 异步保存日志
     */
    private void saveLogAsync(SysOperationLog operationLog) {
        try {
            // 使用异步方法保存日志（不阻塞主线程）
            ((com.example.exam.service.impl.OperationLogServiceImpl) operationLogService).saveAsync(operationLog);
        } catch (Exception e) {
            // 日志保存失败不应影响业务
            log.error("操作日志保存失败：{}", e.getMessage());
        }
    }

    /**
     * 获取HttpServletRequest
     */
    private HttpServletRequest getHttpServletRequest() {
        try {
            ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            return attributes != null ? attributes.getRequest() : null;
        } catch (Exception e) {
            return null;
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

