package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 题库类型枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum BankType {

    /**
     * 公共题库：所有人可见可用
     */
    PUBLIC(1, "公共题库"),

    /**
     * 私有题库：仅创建者和授权用户可用
     */
    PRIVATE(2, "私有题库");

    /**
     * 类型编码（数据库存储值 - VARCHAR，保持与现有数据兼容）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 类型名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取枚举
     *
     * @param code 类型编码
     * @return 题库类型枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static BankType of(Integer code) {
        if (code == null) {
            return null;
        }
        for (BankType type : values()) {
            if (type.getCode() == code) {
                return type;
            }
        }
        throw new IllegalArgumentException("无效的题库类型编码: " + code);
    }

    /**
     * 是否是公共题库
     */
    public boolean isPublic() {
        return this == PUBLIC;
    }

    /**
     * 是否是私有题库
     */
    public boolean isPrivate() {
        return this == PRIVATE;
    }
}
