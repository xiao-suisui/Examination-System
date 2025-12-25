package com.example.exam.common.enums;

import lombok.Getter;

/**
 * 错误码枚举
 * 统一管理系统中的错误码和错误消息
 *
 * <p>错误码规范：</p>
 * <ul>
 *   <li>200 - 成功</li>
 *   <li>400-499 - 客户端错误（参数错误、业务逻辑错误）</li>
 *   <li>500-599 - 服务器错误（系统异常、数据库异常）</li>
 * </ul>
 *
 * <p>模块划分：</p>
 * <ul>
 *   <li>40001-40099 - 题库相关</li>
 *   <li>40101-40199 - 题目相关</li>
 *   <li>40201-40299 - 试卷相关</li>
 *   <li>40301-40399 - 考试相关</li>
 *   <li>40401-40499 - 阅卷相关</li>
 *   <li>40501-40599 - 用户相关</li>
 *   <li>40601-40699 - 权限相关</li>
 * </ul>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-25
 */
@Getter
public enum ErrorCode {

    // ==================== 通用错误 ====================
    SUCCESS(200, "操作成功"),
    PARAM_INVALID(400, "参数无效"),
    UNAUTHORIZED(401, "未登录"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方法不允许"),
    INTERNAL_ERROR(500, "系统内部错误"),
    SERVICE_UNAVAILABLE(503, "服务不可用"),

    // ==================== 题库模块 (40001-40099) ====================
    QUESTION_BANK_NOT_FOUND(40001, "题库不存在"),
    QUESTION_BANK_NAME_DUPLICATE(40002, "题库名称已存在"),
    QUESTION_BANK_HAS_QUESTIONS(40003, "题库中还有题目，无法删除"),
    QUESTION_BANK_ALREADY_PUBLISHED(40004, "题库已发布，无法修改"),

    // ==================== 题目模块 (40101-40199) ====================
    QUESTION_NOT_FOUND(40101, "题目不存在"),
    QUESTION_CONTENT_EMPTY(40102, "题目内容不能为空"),
    QUESTION_OPTION_INVALID(40103, "题目选项无效"),
    QUESTION_ANSWER_EMPTY(40104, "正确答案不能为空"),
    QUESTION_IN_USE(40105, "题目已被试卷引用，无法删除"),
    QUESTION_TYPE_NOT_MATCH(40106, "题目类型不匹配"),

    // ==================== 试卷模块 (40201-40299) ====================
    PAPER_NOT_FOUND(40201, "试卷不存在"),
    PAPER_NAME_EMPTY(40202, "试卷名称不能为空"),
    PAPER_NO_QUESTIONS(40203, "试卷没有题目"),
    PAPER_ALREADY_PUBLISHED(40204, "试卷已发布，无法修改"),
    PAPER_IN_USE(40205, "试卷已被考试引用，无法删除"),
    PAPER_RULE_INVALID(40206, "组卷规则无效"),
    PAPER_GENERATE_FAILED(40207, "自动组卷失败"),

    // ==================== 考试模块 (40301-40399) ====================
    EXAM_NOT_FOUND(40301, "考试不存在"),
    EXAM_NOT_STARTED(40302, "考试未开始"),
    EXAM_ALREADY_ENDED(40303, "考试已结束"),
    EXAM_ALREADY_SUBMITTED(40304, "考试已提交，无法重复提交"),
    EXAM_TIME_EXPIRED(40305, "考试时间已到"),
    EXAM_NOT_IN_PROGRESS(40306, "考试未进行中"),
    EXAM_NO_PERMISSION(40307, "没有参加此考试的权限"),
    EXAM_ALREADY_STARTED(40308, "考试已开始，无法修改"),

    // ==================== 阅卷模块 (40401-40499) ====================
    GRADING_NOT_FOUND(40401, "阅卷记录不存在"),
    GRADING_ALREADY_COMPLETED(40402, "已完成阅卷"),
    GRADING_SCORE_INVALID(40403, "分数无效"),
    GRADING_NO_PERMISSION(40404, "没有阅卷权限"),

    // ==================== 用户模块 (40501-40599) ====================
    USER_NOT_FOUND(40501, "用户不存在"),
    USERNAME_DUPLICATE(40502, "用户名已存在"),
    PHONE_DUPLICATE(40503, "手机号已存在"),
    EMAIL_DUPLICATE(40504, "邮箱已存在"),
    PASSWORD_INCORRECT(40505, "密码错误"),
    ACCOUNT_DISABLED(40506, "账号已禁用"),
    ACCOUNT_NOT_APPROVED(40507, "账号未审核通过"),
    OLD_PASSWORD_INCORRECT(40508, "原密码错误"),

    // ==================== 权限模块 (40601-40699) ====================
    ROLE_NOT_FOUND(40601, "角色不存在"),
    ROLE_CODE_DUPLICATE(40602, "角色编码已存在"),
    ROLE_IN_USE(40603, "角色已被用户使用，无法删除"),
    PERMISSION_NOT_FOUND(40604, "权限不存在"),
    PERMISSION_DENIED(40605, "权限不足"),

    // ==================== 组织模块 (40701-40799) ====================
    ORGANIZATION_NOT_FOUND(40701, "组织不存在"),
    ORGANIZATION_HAS_CHILDREN(40702, "组织下还有子组织，无法删除"),
    ORGANIZATION_HAS_USERS(40703, "组织下还有用户，无法删除"),

    // ==================== 文件模块 (40801-40899) ====================
    FILE_UPLOAD_FAILED(40801, "文件上传失败"),
    FILE_TOO_LARGE(40802, "文件大小超过限制"),
    FILE_TYPE_NOT_ALLOWED(40803, "文件类型不允许"),
    FILE_NOT_FOUND(40804, "文件不存在");

    /**
     * 错误码
     */
    private final Integer code;

    /**
     * 错误消息
     */
    private final String message;

    /**
     * 构造函数
     *
     * @param code 错误码
     * @param message 错误消息
     */
    ErrorCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
}

