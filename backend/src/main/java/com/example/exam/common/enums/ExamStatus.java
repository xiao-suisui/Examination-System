package com.example.exam.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 考试状态枚举
 *
 * @author Exam System
 * @version 2.0
 */
@Getter
@AllArgsConstructor
public enum ExamStatus {

    /**
     * 草稿
     */
    DRAFT("DRAFT", "草稿"),

    /**
     * 已发布
     */
    PUBLISHED("PUBLISHED", "已发布"),

    /**
     * 进行中
     */
    IN_PROGRESS("IN_PROGRESS", "进行中"),

    /**
     * 已结束
     */
    ENDED("ENDED", "已结束"),

    /**
     * 已取消
     */
    CANCELLED("CANCELLED", "已取消");

    /**
     * 状态编码
     */
    private final String code;

    /**
     * 状态名称
     */
    private final String name;

    /**
     * 根据编码获取枚举
     */
    public static ExamStatus fromCode(String code) {
        for (ExamStatus status : values()) {
            if (status.getCode().equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("未知的考试状态编码: " + code);
    }
}

