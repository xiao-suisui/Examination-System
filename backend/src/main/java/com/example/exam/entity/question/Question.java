package com.example.exam.entity.question;

import com.baomidou.mybatisplus.annotation.*;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyLevel;
import com.example.exam.common.enums.QuestionType;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 题目表实体类（核心）
 *
 * 模块：题库管理模块（exam-question）
 * 职责：管理题目（支持8种题型）
 * 表名：question
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("question")
public class Question implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 题目ID（主键，自增）
     */
    @TableId(value = "question_id", type = IdType.AUTO)
    private Long questionId;

    /**
     * 题库ID
     */
    @TableField("bank_id")
    private Long bankId;

    /**
     * 组织ID（数据隔离）
     */
    @TableField("org_id")
    private Long orgId;

    /**
     * 题目内容（富文本，支持图片/公式）
     */
    @TableField("question_content")
    private String questionContent;

    /**
     * 题型：SINGLE_CHOICE-单选，MULTIPLE_CHOICE-多选，
     * INDEFINITE_CHOICE-不定项，TRUE_FALSE-判断，
     * MATCHING-匹配，SORT-排序，FILL_BLANK-填空，SUBJECTIVE-主观
     */
    @TableField("question_type")
    private QuestionType questionType;

    /**
     * 默认分值
     */
    @TableField("default_score")
    private BigDecimal defaultScore;

    /**
     * 难度：EASY-简单，MEDIUM-中等，HARD-困难
     */
    @TableField("difficulty")
    private DifficultyLevel difficulty;

    /**
     * 知识点ID列表（逗号分隔，最多3个）
     */
    @TableField("knowledge_ids")
    private String knowledgeIds;

    /**
     * 填空题答案（格式：空1答案1,空1答案2|空2答案1）
     */
    @TableField("answer_list")
    private String answerList;

    /**
     * 主观题参考答案
     */
    @TableField("reference_answer")
    private String referenceAnswer;

    /**
     * 主观题评分标准
     */
    @TableField("score_rule")
    private String scoreRule;

    /**
     * 答案解析
     */
    @TableField("answer_analysis")
    private String answerAnalysis;

    /**
     * 题目图片URL
     */
    @TableField("question_image")
    private String questionImage;

    /**
     * 被组卷使用次数
     */
    @TableField("use_count")
    private Integer useCount;

    /**
     * 历史正确率（百分比）
     */
    @TableField("correct_rate")
    private BigDecimal correctRate;

    /**
     * 审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝
     */
    @TableField("audit_status")
    private AuditStatus auditStatus;

    /**
     * 审核备注
     */
    @TableField("audit_remark")
    private String auditRemark;

    /**
     * 审核人ID
     */
    @TableField("auditor_id")
    private Long auditorId;

    /**
     * 审核时间
     */
    @TableField("audit_time")
    private LocalDateTime auditTime;

    /**
     * 创建人ID
     */
    @TableField("create_user_id")
    private Long createUserId;

    /**
     * 状态：0-禁用，1-启用
     */
    @TableField("status")
    private Integer status;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间（自动填充）
     */
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 是否删除：0-否，1-是（逻辑删除）
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;

    /**
     * 选项列表（非数据库字段，用于查询结果映射）
     */
    @TableField(exist = false)
    private List<QuestionOption> options;
}

