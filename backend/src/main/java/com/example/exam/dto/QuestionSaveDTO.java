package com.example.exam.dto;

import com.example.exam.entity.question.QuestionOption;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 题目创建/更新DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-14
 */
@Data
@Schema(description = "题目创建/更新数据传输对象")
public class QuestionSaveDTO {

    @Schema(description = "题目ID（更新时必传）")
    private Long questionId;

    @Schema(description = "题库ID", required = true)
    private Long bankId;

    @Schema(description = "题目内容", required = true)
    private String questionContent;

    @Schema(description = "题型编码：1-单选，2-多选，3-不定项，4-判断，5-匹配，6-排序，7-填空，8-主观", required = true)
    private Integer questionType;

    @Schema(description = "默认分值", required = true)
    private BigDecimal defaultScore;

    @Schema(description = "难度编码：1-简单，2-中等，3-困难", required = true)
    private Integer difficulty;

    @Schema(description = "知识点ID列表（逗号分隔）")
    private String knowledgeIds;

    @Schema(description = "填空题答案")
    private String answerList;

    @Schema(description = "主观题参考答案")
    private String referenceAnswer;

    @Schema(description = "评分标准")
    private String scoreRule;

    @Schema(description = "答案解析")
    private String answerAnalysis;

    @Schema(description = "正确答案（用于填空题、判断题等）")
    private String correctAnswer;

    @Schema(description = "答案解析（简写）")
    private String analysis;

    @Schema(description = "题目图片URL")
    private String questionImage;

    @Schema(description = "选项列表")
    private List<QuestionOption> options;
}

