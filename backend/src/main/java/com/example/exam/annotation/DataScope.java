package com.example.exam.annotation;

import com.example.exam.common.enums.DataScopeType;

import java.lang.annotation.*;

/**
 * 数据权限注解
 * <p>用于标记需要进行数据权限过滤的方法</p>
 *
 * <p>使用示例：</p>
 * <pre>
 * {@code
 * @DataScope(value = DataScopeType.SUBJECT, tableAlias = "qb")
 * public PageResult<QuestionBankDTO> pageQuestionBanks(QuestionBankQueryDTO query) {
 *     // 数据权限切面会自动添加科目过滤条件
 * }
 * }
 * </pre>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-20
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataScope {

    /**
     * 数据权限类型
     */
    DataScopeType value() default DataScopeType.SUBJECT;

    /**
     * 表别名（用于多表查询时指定过滤的表）
     */
    String tableAlias() default "";

    /**
     * 科目ID字段名（默认为 subject_id）
     */
    String subjectIdField() default "subject_id";

    /**
     * 组织ID字段名（默认为 org_id）
     */
    String orgIdField() default "org_id";

    /**
     * 创建人ID字段名（默认为 create_user_id）
     */
    String createUserIdField() default "create_user_id";
}

