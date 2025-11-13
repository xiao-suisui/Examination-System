package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 难度等级枚举
 * 模块：公共模块（exam-common）
 * 职责：定义题目难度级别
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum DifficultyType {

    /**
     * 简单：适合基础知识考查
     */
    EASY(1, "简单"),

    /**
     * 中等：适合综合能力考查
     */
    MEDIUM(2, "中等"),

    /**
     * 困难：适合高阶能力考查
     */
    HARD(3, "困难");

    /**
     * 难度等级（数据库存储值 - TINYINT，同时用于排序）
     */
    @EnumValue
    @JsonValue
    private final int Type;

    /**
     * 难度名称（中文显示）
     */
    private final String name;

    /**
     * 根据等级获取难度枚举
     *
     * @param code 难度等级
     * @return 难度枚举，未找到则返回null
     */
    public static DifficultyType fromCode(int code) {
        for (DifficultyType difficulty : values()) {
            if (difficulty.getType() == code) {
                return difficulty;
            }
        }
        return null;
    }

    /**
     * 获取难度系数（用于分数计算）
     * 简单: 0.8, 中等: 1.0, 困难: 1.2
     */
    public double getCoefficient() {
        return switch (this) {
            case EASY -> 0.8;
            case MEDIUM -> 1.0;
            case HARD -> 1.2;
        };
    }
}

