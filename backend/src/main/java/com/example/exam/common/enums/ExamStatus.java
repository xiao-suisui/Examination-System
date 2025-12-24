package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 考试状态枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum ExamStatus {

    /**
     * 草稿：考试创建但未发布
     */
    DRAFT(0, "草稿"),

    /**
     * 已发布：考试已发布，等待开始
     */
    PUBLISHED(1, "已发布"),

    /**
     * 进行中：考试正在进行
     */
    IN_PROGRESS(2, "进行中"),

    /**
     * 已结束：考试已结束
     */
    ENDED(3, "已结束"),

    /**
     * 已取消：考试被取消
     */
    CANCELLED(4, "已取消");

    /**
     * 状态编码（数据库存储值 - TINYINT）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 状态名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取枚举
     *
     * @param code 状态编码
     * @return 考试状态枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static ExamStatus of(Integer code) {
        if (code == null) {
            return null;
        }
        for (ExamStatus status : values()) {
            if (status.getCode() == code) {
                return status;
            }
        }
        throw new IllegalArgumentException("无效的考试状态编码: " + code);
    }

    /**
     * 是否可以开始考试
     */
    public boolean canStart() {
        return this == PUBLISHED;
    }

    /**
     * 是否可以取消考试
     */
    public boolean canCancel() {
        return this == DRAFT || this == PUBLISHED;
    }
}

