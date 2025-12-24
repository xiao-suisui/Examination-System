package com.example.exam.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 组卷方式枚举
 *
 * @author Exam System
 * @version 2.0
 */
@Getter
@AllArgsConstructor
public enum PaperGenerateType {

    /**
     * 手动组卷
     */
    MANUAL("MANUAL", "手动组卷"),

    /**
     * 自动组卷
     */
    AUTO("AUTO", "自动组卷"),

    /**
     * 随机组卷
     */
    RANDOM("RANDOM", "随机组卷");

    /**
     * 类型编码
     */
    private final String code;

    /**
     * 类型名称
     */
    private final String name;

    /**
     * 根据编码获取枚举
     */
    public static PaperGenerateType fromCode(String code) {
        for (PaperGenerateType type : values()) {
            if (type.getCode().equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("未知的组卷方式编码: " + code);
    }
}

