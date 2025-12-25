 package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 数据权限类型枚举
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-20
 */
@Getter
@AllArgsConstructor
public enum DataScopeType {

    /**
     * 全部数据权限（超级管理员）
     */
    ALL(0, "全部数据"),

    /**
     * 科目数据权限（教师只能看到管理的科目数据）
     */
    SUBJECT(1, "科目数据"),

    /**
     * 组织数据权限（只能看到本组织及子组织数据）
     */
    ORG(2, "组织数据"),

    /**
     * 仅本人数据权限（只能看到自己创建的数据）
     */
    SELF(3, "仅本人数据");

    @EnumValue
    @JsonValue
    private final Integer code;

    private final String desc;

    /**
     * 根据code获取枚举
     */
    public static DataScopeType getByCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (DataScopeType type : values()) {
            if (type.getCode().equals(code)) {
                return type;
            }
        }
        return null;
    }
}

