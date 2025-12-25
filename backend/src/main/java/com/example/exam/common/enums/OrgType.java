package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 组织类型枚举
 * 模块：公共模块（exam-common）
 * 职责：定义组织类型
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Getter
@AllArgsConstructor
public enum OrgType {

    /**
     * 学校
     */
    SCHOOL(1, "学校"),

    /**
     * 企业
     */
    ENTERPRISE(2, "企业"),

    /**
     * 培训机构
     */
    TRAINING(3, "培训机构");

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
     * 根据编码获取枚举
     *
     * @param code 编码
     * @return 枚举对象
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static OrgType of(Integer code) {
        if (code == null) {
            return null;
        }
        for (OrgType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("无效的组织类型编码: " + code);
    }

}

