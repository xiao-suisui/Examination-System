package com.example.exam.entity.question;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 选项表实体类（核心）
 *
 * 模块：题库管理模块（exam-question）
 * 职责：管理题目选项（支持8种题型的专属属性）
 * 表名：question_option
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
@TableName("question_option")
public class QuestionOption implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 选项ID（主键，自增）
     */
    @TableId(value = "option_id", type = IdType.AUTO)
    private Long optionId;

    /**
     * 题目ID
     */
    @TableField("question_id")
    private Long questionId;

    /**
     * 选项序号（A/B/C/D或1/2/3）
     */
    @TableField("option_seq")
    private String optionSeq;

    /**
     * 选项内容
     */
    @TableField("option_content")
    private String optionContent;

    /**
     * 是否正确答案：0-否，1-是（单选/多选/判断题用）
     */
    @TableField("is_correct")
    private Integer isCorrect;

    /**
     * 分值占比（0-100，不定项选择题专用）
     */
    @TableField("score_ratio")
    private Integer scoreRatio;

    /**
     * 选项类型：NORMAL-普通，STEM-题干（匹配题），MATCH-匹配项（匹配题）
     */
    @TableField("option_type")
    private String optionType;

    /**
     * 关联标识（匹配题专用，如M1、M2）
     */
    @TableField("assoc_flag")
    private String assocFlag;

    /**
     * 正确排序值（排序题专用，如1、2、3）
     */
    @TableField("correct_order")
    private Integer correctOrder;

    /**
     * 选项解析
     */
    @TableField("option_analysis")
    private String optionAnalysis;

    /**
     * 选项图片URL
     */
    @TableField("option_image")
    private String optionImage;

    /**
     * 排序
     */
    @TableField("sort")
    private Integer sort;

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
}

