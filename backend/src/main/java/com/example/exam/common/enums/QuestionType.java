package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 题型枚举（支持8种题型）
 * 模块：公共模块（exam-common）
 * 职责：定义考试系统支持的所有题型
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Getter
@AllArgsConstructor
public enum QuestionType {

    /**
     * 单选题：4个选项，仅1个正确
     * 判分规则：选择正确选项得满分，否则0分
     */
    SINGLE_CHOICE(1, "单选题", "4个选项，仅1个正确"),

    /**
     * 多选题：4-5个选项，≥1个正确
     * 判分规则：选择与正确选项完全一致得满分；多选/少选/错选均0分
     */
    MULTIPLE_CHOICE(2, "多选题", "4-5个选项，至少1个正确"),

    /**
     * 不定项选择题：4个选项，≥1个正确，支持部分得分
     * 判分规则：选对部分正确选项按score_ratio累加得分；选错任何选项0分
     */
    INDEFINITE_CHOICE(3, "不定项选择题", "4个选项，支持部分得分"),

    /**
     * 判断题：2个选项（对/错），仅1个正确
     * 判分规则：选择正确选项得满分，否则0分
     */
    TRUE_FALSE(4, "判断题", "2个选项（对/错）"),

    /**
     * 匹配题：左侧题干选项、右侧匹配选项，一一对应
     * 判分规则：所有匹配正确得满分；每匹配正确1组得1/N分
     */
    MATCHING(5, "匹配题", "左侧题干与右侧选项一一对应"),

    /**
     * 排序题：3-5个选项，需按正确顺序排列
     * 判分规则：完全正确得满分；采用"逆序数法"计算偏差按比例扣分
     */
    SORT(6, "排序题", "3-5个选项，按正确顺序排列"),

    /**
     * 填空题：1-3个空，每个空有固定答案（支持多个正确答案）
     * 判分规则：每个空匹配任一正确答案即得分，支持模糊匹配
     */
    FILL_BLANK(7, "填空题", "1-3个空，支持多个正确答案"),

    /**
     * 主观题：简答题/论述题，无固定选项，需人工批改
     * 判分规则：教师手动打分+批改评语
     */
    SUBJECTIVE(8, "主观题", "简答/论述题，需人工批改");

    /**
     * 题型编码（数据库存储值 - TINYINT）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 题型名称（中文显示）
     */
    private final String name;

    /**
     * 题型描述
     */
    private final String description;

    /**
     * 根据编码获取题型枚举
     *
     * @param code 题型编码
     * @return 题型枚举
     * @throws IllegalArgumentException 如果编码无效
     */
    @com.fasterxml.jackson.annotation.JsonCreator
    public static QuestionType of(Integer code) {
        if (code == null) {
            return null;
        }
        for (QuestionType type : values()) {
            if (type.getCode() == code) {
                return type;
            }
        }
        throw new IllegalArgumentException("无效的题型编码: " + code);
    }


    /**
     * 是否是选择题（单选/多选/不定项/判断）
     */
    public boolean isChoiceType() {
        return this == SINGLE_CHOICE || this == MULTIPLE_CHOICE ||
               this == INDEFINITE_CHOICE || this == TRUE_FALSE;
    }

    /**
     * 是否需要人工批改
     */
    public boolean needsManualGrading() {
        return this == SUBJECTIVE;
    }

    /**
     * 判断是否为客观题（可自动判分）
     *
     * @return true-客观题，false-主观题
     */
    public boolean isObjective() {
        return this != SUBJECTIVE && this != FILL_BLANK;
    }

    /**
     * 判断是否需要选项表
     *
     * @return true-需要选项表，false-不需要选项表（如填空题、主观题）
     */
    public boolean hasOptions() {
        return this != FILL_BLANK && this != SUBJECTIVE;
    }

    /**
     * 判断是否支持部分得分
     *
     * @return true-支持部分得分，false-不支持
     */
    public boolean supportsPartialScore() {
        return this == INDEFINITE_CHOICE || this == MATCHING || this == SORT;
    }
}

