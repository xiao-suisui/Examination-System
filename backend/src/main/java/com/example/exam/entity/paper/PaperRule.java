 package com.example.exam.entity.paper;

import com.baomidou.mybatisplus.annotation.*;
import com.example.exam.common.enums.QuestionType;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 组卷规则表实体类
 *
 * 模块：试卷管理模块（exam-paper）
 * 职责：管理随机组卷规则（题型、数量、难度分布）
 * 表名：paper_rule
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
@TableName("paper_rule")
public class PaperRule implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 规则ID（主键，自增）
     */
    @TableId(value = "rule_id", type = IdType.AUTO)
    private Long ruleId;

    /**
     * 试卷ID
     */
    @TableField("paper_id")
    private Long paperId;

    /**
     * 题库ID（从哪个题库抽题）
     */
    @TableField("bank_id")
    private Long bankId;

    /**
     * 题型
     */
    @TableField("question_type")
    private QuestionType questionType;

    /**
     * 该题型总题量
     */
    @TableField("total_num")
    private Integer totalNum;

    /**
     * 简单题数量
     */
    @TableField("easy_num")
    private Integer easyNum;

    /**
     * 中等题数量
     */
    @TableField("medium_num")
    private Integer mediumNum;

    /**
     * 困难题数量
     */
    @TableField("hard_num")
    private Integer hardNum;

    /**
     * 每题分值
     */
    @TableField("single_score")
    private BigDecimal singleScore;

    /**
     * 指定知识点ID列表（逗号分隔，为空则不限）
     */
    @TableField("knowledge_ids")
    private String knowledgeIds;

    /**
     * 题型顺序
     */
    @TableField("sort_order")
    private Integer sortOrder;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

