package com.example.exam.annotation;

import java.lang.annotation.*;

/**
 * 操作日志注解
 * 用于标记需要记录操作日志的方法
 *
 * <p>使用示例：</p>
 * <pre>{@code
 * // 简单使用（自动从类名和方法名提取模块和类型）
 * @OperationLog
 * public Result<Void> create(@RequestBody QuestionDTO dto) { ... }
 *
 * // 自定义描述
 * @OperationLog(description = "创建题目")
 * public Result<Void> create(@RequestBody QuestionDTO dto) { ... }
 *
 * // 完整配置
 * @OperationLog(
 *     module = "题目管理",
 *     type = "创建",
 *     description = "创建题目",
 *     recordParams = true,
 *     recordResult = true
 * )
 * public Result<Void> create(@RequestBody QuestionDTO dto) { ... }
 *
 * // 支持 SpEL 表达式（需要配合 AOP 实现）
 * @OperationLog(
 *     description = "删除题目: #{#id}",
 *     recordParams = false
 * )
 * public Result<Void> delete(@PathVariable Long id) { ... }
 * }</pre>
 *
 * @author Exam System
 * @version 2.1
 * @since 2025-11-06
 * @see com.example.exam.aspect.OperationLogAspect
 */
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OperationLog {

    /**
     * 操作模块
     * <p>如果不指定，将从 Controller 类名自动提取</p>
     * <p>例如：QuestionController → "题目管理"</p>
     *
     * @return 操作模块名称
     */
    String module() default "";

    /**
     * 操作类型（字符串）
     * <p>如果不指定，将从方法名自动识别</p>
     * <p>常用类型：创建、更新、删除、查询、导出、导入、登录、登出、审核、发布、提交、批阅等</p>
     *
     * @return 操作类型字符串
     */
    String type() default "";

    /**
     * 操作描述
     * <p>支持 SpEL 表达式，可以引用方法参数</p>
     * <p>例如：</p>
     * <ul>
     *   <li>"创建题目" - 固定描述</li>
     *   <li>"删除题目: #{#id}" - 引用参数 id</li>
     *   <li>"更新题目: #{#dto.questionContent}" - 引用对象属性</li>
     * </ul>
     *
     * @return 操作描述，可包含 SpEL 表达式
     */
    String description() default "";

    /**
     * 是否记录请求参数
     * <p>默认记录，但对于敏感操作（如登录）建议设为 false</p>
     *
     * @return true 记录参数，false 不记录
     */
    boolean recordParams() default true;

    /**
     * 是否记录返回结果
     * <p>默认不记录，对于关键操作建议设为 true</p>
     *
     * @return true 记录结果，false 不记录
     */
    boolean recordResult() default false;

    /**
     * 是否记录异常信息
     * <p>默认记录，用于排查问题</p>
     *
     * @return true 记录异常，false 不记录
     */
    boolean recordException() default true;

    /**
     * 操作成功时的消息模板
     * <p>支持 SpEL 表达式</p>
     * <p>例如："题目 #{#result.data.questionId} 创建成功"</p>
     *
     * @return 成功消息模板
     */
    String successMessage() default "";

    /**
     * 操作失败时的消息模板
     * <p>支持 SpEL 表达式</p>
     * <p>例如："题目创建失败: #{#exception.message}"</p>
     *
     * @return 失败消息模板
     */
    String failureMessage() default "";
}

