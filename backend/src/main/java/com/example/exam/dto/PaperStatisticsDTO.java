package com.example.exam.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 试卷统计信息DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaperStatisticsDTO {

    /**
     * 试卷ID
     */
    private Long paperId;

    /**
     * 试卷名称
     */
    private String paperName;

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
     * 总分
     */
    private java.math.BigDecimal totalScore;

    /**
     * 及格分数
     */
    private java.math.BigDecimal passScore;

    /**
     * 考试时长（分钟）
     */
    private Integer duration;

    /**
     * 使用次数（被多少场考试使用）
     */
    private Integer usageCount;
}

