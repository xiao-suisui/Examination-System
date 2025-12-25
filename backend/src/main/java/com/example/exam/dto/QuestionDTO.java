package com.example.exam.dto;

import com.example.exam.entity.question.QuestionOption;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 题目DTO - 用于查询列表/详情展示
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-14
 */
@Data
@Schema(description = "题目数据传输对象")
public class QuestionDTO {

    @Schema(description = "题目ID")
    private Long questionId;

    @Schema(description = "题库ID")
    private Long bankId;

    @Schema(description = "题库名称")
    private String bankName;

    @Schema(description = "组织ID")
    private Long orgId;

    @Schema(description = "题目内容")
    private String questionContent;

    @Schema(description = "题型编码：1-单选，2-多选，3-不定项，4-判断，5-匹配，6-排序，7-填空，8-主观")
    private Integer questionType;

    @Schema(description = "题型名称（前端展示）")
    private String questionTypeName;

    @Schema(description = "默认分值")
    private BigDecimal defaultScore;

    @Schema(description = "难度编码：1-简单，2-中等，3-困难")
    private Integer difficulty;

    @Schema(description = "难度名称（前端展示）")
    private String difficultyName;

    @Schema(description = "知识点ID列表")
    private String knowledgeIds;

    @Schema(description = "知识点名称列表")
    private String knowledgeNames;

    @Schema(description = "填空题答案")
    private String answerList;

    @Schema(description = "主观题参考答案")
    private String referenceAnswer;

    @Schema(description = "评分标准")
    private String scoreRule;

    @Schema(description = "答案解析")
    private String answerAnalysis;

    @Schema(description = "题目图片URL")
    private String questionImage;

    @Schema(description = "使用次数")
    private Integer useCount;

    @Schema(description = "正确率")
    private BigDecimal correctRate;

    @Schema(description = "审核状态编码：0-草稿，1-待审核，2-已通过，3-已拒绝")
    private Integer auditStatus;

    @Schema(description = "审核状态名称（前端展示）")
    private String auditStatusName;

    @Schema(description = "审核备注")
    private String auditRemark;

    @Schema(description = "审核人ID")
    private Long auditorId;

    @Schema(description = "审核人姓名")
    private String auditorName;

    @Schema(description = "审核时间")
    private LocalDateTime auditTime;

    @Schema(description = "创建人ID")
    private Long createUserId;

    @Schema(description = "创建人姓名")
    private String createUserName;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    // ==================== 扩展字段 ====================

    @Schema(description = "选项列表")
    private List<QuestionOption> options;

    @Schema(description = "正确答案ID列表（逗号分隔）")
    private String correctOptionIds;

    @Schema(description = "正确答案内容")
    private String correctAnswer;
}

