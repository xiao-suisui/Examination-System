package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 组卷方式枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum PaperType {

    /**
     * 手动组卷：教师手动选择题目
     */
    MANUAL(1, "手动组卷"),

    /**
     * 自动组卷：系统根据规则自动抽题
     */
    AUTO(2, "自动组卷"),

    /**
     * 随机组卷：完全随机抽取题目
     */
    RANDOM(3, "随机组卷");

    /**
     * 组卷方式编码（数据库存储值 - TINYINT）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 组卷方式名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取枚举
     *
     * @param code 组卷方式编码
     * @return 组卷方式枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static PaperType of(Integer code) {
        if (code == null) {
            return null;
        }
        for (PaperType type : values()) {
            if (type.getCode() == code) {
                return type;
            }
        }
        throw new IllegalArgumentException("无效的组卷方式编码: " + code);
    }

    /**
     * 是否是手动组卷
     */
    public boolean isManual() {
        return this == MANUAL;
    }

    /**
     * 是否是自动组卷
     */
    public boolean isAuto() {
        return this == AUTO;
    }

    /**
     * 是否是随机组卷
     */
    public boolean isRandom() {
        return this == RANDOM;
    }

}

