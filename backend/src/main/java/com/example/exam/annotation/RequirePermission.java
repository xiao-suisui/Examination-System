package com.example.exam.annotation;

import java.lang.annotation.*;

/**
 * 权限校验注解
 * 用于方法级别的权限控制
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequirePermission {

    /**
     * 需要的权限编码
     * 示例：user:create, user:update
     */
    String value();

    /**
     * 权限描述（可选）
     */
    String desc() default "";

    /**
     * 多个权限的逻辑关系
     * AND: 需要同时拥有所有权限
     * OR: 只需要拥有其中一个权限
     */
    Logical logical() default Logical.AND;

    enum Logical {
        AND, OR
    }
}

