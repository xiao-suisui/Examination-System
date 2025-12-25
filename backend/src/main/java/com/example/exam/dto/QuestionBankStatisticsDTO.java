package com.example.exam.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 题库统计信息DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionBankStatisticsDTO {

    /**
     * 题库ID
     */
    private Long bankId;

    /**
     * 题库名称
     */
    private String bankName;

    /**
     * 题目总数
     */
    private Integer totalQuestions;

    /**
     * 单选题数量
     */
    private Integer singleChoiceCount;

    /**
     * 多选题数量
     */
    private Integer multipleChoiceCount;

    /**
     * 判断题数量
     */
    private Integer trueFalseCount;

    /**
     * 填空题数量
     */
    private Integer fillBlankCount;

    /**
     * 简答题数量
     */
    private Integer shortAnswerCount;

    /**
     * 其他类型题目数量
     */
    private Integer otherCount;

    /**
     * 简单难度数量
     */
    private Integer easyCount;

    /**
     * 中等难度数量
     */
    private Integer mediumCount;

    /**
     * 困难难度数量
     */
    private Integer hardCount;

    /**
     * 已审核通过题目数量
     */
    private Integer approvedCount;

    /**
     * 待审核题目数量
     */
    private Integer pendingCount;

    /**
     * 已拒绝题目数量
     */
    private Integer rejectedCount;
}

