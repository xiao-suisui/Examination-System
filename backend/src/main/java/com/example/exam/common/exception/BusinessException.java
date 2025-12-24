package com.example.exam.common.exception;

import com.example.exam.common.enums.ErrorCode;
import lombok.Getter;

/**
 * 业务异常类
 * 用于抛出业务逻辑相关的异常
 *
 * <p>使用示例：</p>
 * <pre>{@code
 * // 基本使用
 * if (question == null) {
 *     throw new BusinessException(ErrorCode.QUESTION_NOT_FOUND);
 * }
 *
 * // 带参数的消息
 * throw new BusinessException(ErrorCode.PARAM_INVALID, "题目内容不能为空");
 *
 * // 自定义错误码
 * throw new BusinessException(40001, "题目已被引用，无法删除");
 * }</pre>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-25
 */
@Getter
public class BusinessException extends RuntimeException {

    /**
     * 错误码
     */
    private final Integer code;

    /**
     * 错误消息
     */
    private final String message;

    /**
     * 通过错误码枚举构造异常
     *
     * @param errorCode 错误码枚举
     */
    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.message = errorCode.getMessage();
    }

    /**
     * 通过错误码枚举和自定义消息构造异常
     *
     * @param errorCode 错误码枚举
     * @param message 自定义错误消息
     */
    public BusinessException(ErrorCode errorCode, String message) {
        super(message);
        this.code = errorCode.getCode();
        this.message = message;
    }

    /**
     * 通过错误码和消息构造异常
     *
     * @param code 错误码
     * @param message 错误消息
     */
    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }

    /**
     * 通过消息构造异常（使用默认错误码400）
     *
     * @param message 错误消息
     */
    public BusinessException(String message) {
        super(message);
        this.code = 400;
        this.message = message;
    }

    /**
     * 通过错误码、消息和原始异常构造
     *
     * @param code 错误码
     * @param message 错误消息
     * @param cause 原始异常
     */
    public BusinessException(Integer code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
        this.message = message;
    }
}

