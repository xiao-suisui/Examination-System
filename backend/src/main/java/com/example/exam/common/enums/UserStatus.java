package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 用户状态枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum UserStatus {

    /**
     * 禁用：用户被禁用，无法登录
     */
    DISABLED(0, "禁用"),

    /**
     * 启用：用户正常，可以登录
     */
    ENABLED(1, "启用");

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
     * @return 用户状态枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static UserStatus of(Integer code) {
        if (code == null) {
            return null;
        }
        for (UserStatus status : values()) {
            if (status.getCode() == code) {
                return status;
            }
        }
        throw new IllegalArgumentException("无效的用户状态编码: " + code);
    }

    /**
     * 是否启用
     */
    public boolean isEnabled() {
        return this == ENABLED;
    }

    /**
     * 是否禁用
     */
    public boolean isDisabled() {
        return this == DISABLED;
    }
}
