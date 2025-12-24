package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 难度等级枚举
 *
 * 模块：公共模块（exam-common）
 * 职责：定义题目难度级别
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Getter
@AllArgsConstructor
public enum DifficultyLevel {

    /**
     * 简单：适合基础知识考查
     */
    EASY("EASY", "简单", 1),

    /**
     * 中等：适合综合能力考查
     */
    MEDIUM("MEDIUM", "中等", 2),

    /**
     * 困难：适合高阶能力考查
     */
    HARD("HARD", "困难", 3);

    /**
     * 难度编码（数据库存储值）
     */
    @EnumValue
    @JsonValue
    private final String code;

    /**
     * 难度名称（中文显示）
     */
    private final String name;

    /**
     * 难度等级（用于排序）
     */
    private final int level;

    /**
     * 根据编码获取难度枚举
     *
     * @param code 难度编码
     * @return 难度枚举，未找到则返回null
     */
    public static DifficultyLevel fromCode(String code) {
        for (DifficultyLevel difficulty : values()) {
            if (difficulty.getCode().equals(code)) {
                return difficulty;
            }
        }
        return null;
    }
}

