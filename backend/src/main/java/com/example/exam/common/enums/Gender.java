package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 性别枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum Gender {

    /**
     * 未知
     */
    UNKNOWN(0, "未知"),

    /**
     * 男性
     */
    MALE(1, "男"),

    /**
     * 女性
     */
    FEMALE(2, "女");

    /**
     * 性别编码（数据库存储值 - TINYINT）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 性别名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取枚举
     *
     * @param code 性别编码
     * @return 性别枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static Gender of(Integer code) {
        if (code == null) {
            return null;
        }
        for (Gender gender : values()) {
            if (gender.getCode() == code) {
                return gender;
            }
        }
        throw new IllegalArgumentException("无效的性别编码: " + code);
    }

    /**
     * 是否是男性
     */
    public boolean isMale() {
        return this == MALE;
    }

    /**
     * 是否是女性
     */
    public boolean isFemale() {
        return this == FEMALE;
    }
}
