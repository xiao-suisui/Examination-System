package com.example.exam.entity.paper;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 试卷题目关联表实体类
 * 模块：试卷管理模块（exam-paper）
 * 职责：管理试卷与题目的关联关系（固定组卷使用）
 * 表名：paper_question
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
@TableName("paper_question")
public class PaperQuestion implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 关联ID（主键，自增）
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 试卷ID
     */
    @TableField("paper_id")
    private Long paperId;

    /**
     * 题目ID
     */
    @TableField("question_id")
    private Long questionId;

    /**
     * 题库ID（记录题目来源）
     */
    @TableField("bank_id")
    private Long bankId;

    /**
     * 该题在试卷中的分值
     */
    @TableField("question_score")
    private BigDecimal questionScore;

    /**
     * 题目顺序
     */
    @TableField("sort_order")
    private Integer sortOrder;

    /**
     * 关联组卷规则ID（随机组卷用）
     */
    @TableField("rule_id")
    private Long ruleId;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

