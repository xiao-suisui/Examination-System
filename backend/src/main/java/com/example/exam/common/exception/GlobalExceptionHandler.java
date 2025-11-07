package com.example.exam.common.exception;

import com.example.exam.common.result.Result;
import io.jsonwebtoken.JwtException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * 全局异常处理器
 * 统一处理各种异常，返回标准化的错误响应
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e, HttpServletRequest request) {
        log.warn("业务异常：{} - URL: {}", e.getMessage(), request.getRequestURI());
        return Result.error(e.getCode(), e.getMessage());
    }

    /**
     * 处理JWT异常
     */
    @ExceptionHandler(JwtException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public Result<?> handleJwtException(JwtException e, HttpServletRequest request) {
        log.warn("JWT验证失败：{} - URL: {}", e.getMessage(), request.getRequestURI());
        return Result.error(401, "Token验证失败，请重新登录");
    }

    /**
     * 处理参数验证异常 - @Valid 注解
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Map<String, String>> handleValidationException(MethodArgumentNotValidException e) {
        log.warn("参数验证失败：{}", e.getMessage());

        Map<String, String> errors = new HashMap<>();
        e.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });

        return Result.error(400, "参数验证失败", errors);
    }

    /**
     * 处理绑定异常 - @Validated 注解
     */
    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Map<String, String>> handleBindException(BindException e) {
        log.warn("参数绑定失败：{}", e.getMessage());

        Map<String, String> errors = new HashMap<>();
        e.getFieldErrors().forEach(error -> {
            errors.put(error.getField(), error.getDefaultMessage());
        });

        return Result.error(400, "参数验证失败", errors);
    }

    /**
     * 处理数据完整性异常（数据库约束）
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<?> handleDataIntegrityViolationException(DataIntegrityViolationException e, HttpServletRequest request) {
        log.error("数据完整性异常：{} - URL: {}", e.getMessage(), request.getRequestURI());

        String message = "数据操作失败";

        // 解析具体错误
        String rootMsg = e.getRootCause() != null ? e.getRootCause().getMessage() : e.getMessage();
        if (rootMsg != null) {
            if (rootMsg.contains("Duplicate entry")) {
                message = "数据重复，请检查输入";
            } else if (rootMsg.contains("cannot be null") || rootMsg.contains("doesn't have a default value")) {
                message = "必填字段不能为空";
            } else if (rootMsg.contains("foreign key constraint")) {
                message = "数据关联错误，请检查相关数据";
            }
        }

        return Result.error(400, message);
    }

    /**
     * 处理空指针异常
     */
    @ExceptionHandler(NullPointerException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<?> handleNullPointerException(NullPointerException e, HttpServletRequest request) {
        log.error("空指针异常 - URL: {}", request.getRequestURI(), e);
        return Result.error(500, "系统内部错误，请联系管理员");
    }

    /**
     * 处理非法参数异常
     */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<?> handleIllegalArgumentException(IllegalArgumentException e, HttpServletRequest request) {
        log.warn("非法参数异常：{} - URL: {}", e.getMessage(), request.getRequestURI());
        return Result.error(400, e.getMessage() != null ? e.getMessage() : "参数错误");
    }

    /**
     * 处理运行时异常
     */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<?> handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.error("运行时异常：{} - URL: {}", e.getMessage(), request.getRequestURI(), e);
        return Result.error(500, "系统运行异常：" + e.getMessage());
    }

    /**
     * 处理所有未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<?> handleException(Exception e, HttpServletRequest request) {
        log.error("未知异常：{} - URL: {}", e.getMessage(), request.getRequestURI(), e);
        return Result.error(500, "系统异常，请稍后重试");
    }
}

