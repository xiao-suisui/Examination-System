package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 组织层级枚举
 * 模块：公共模块（exam-common）
 * 职责：定义组织层级
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Getter
@AllArgsConstructor
public enum OrgLevel {

    /**
     * 一级（学校/企业）
     */
    LEVEL_1(1, "一级", "学校/企业"),

    /**
     * 二级（学院/部门）
     */
    LEVEL_2(2, "二级", "学院/部门"),

    /**
     * 三级（系/小组）
     */
    LEVEL_3(3, "三级", "系/小组"),

    /**
     * 四级（班级）
     */
    LEVEL_4(4, "四级", "班级");

    /**
     * 编码（存储到数据库）
     */
    @EnumValue
    @JsonValue
    private final Integer code;

    /**
     * 名称
     */
    private final String name;

    /**
     * 说明
     */
    private final String description;

    /**
     * 根据编码获取枚举
     *
     * @param code 编码
     * @return 枚举对象
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static OrgLevel of(Integer code) {
        if (code == null) {
            return null;
        }
        for (OrgLevel level : values()) {
            if (level.code.equals(code)) {
                return level;
            }
        }
        throw new IllegalArgumentException("无效的组织层级编码: " + code);
    }

    /**
     * 根据名称获取枚举
     *
     * @param name 名称
     * @return 枚举对象
     */
    public static OrgLevel fromName(String name) {
        if (name == null || name.isEmpty()) {
            return null;
        }
        for (OrgLevel level : values()) {
            if (level.name.equals(name)) {
                return level;
            }
        }
        return null;
    }
}

