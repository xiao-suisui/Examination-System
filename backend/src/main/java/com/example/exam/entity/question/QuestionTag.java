package com.example.exam.entity.question;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 题目标签表实体类
 * 模块：题库管理模块（exam-question）
 * 职责：管理题目标签（用于题目分类和检索）
 * 表名：question_tag
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
@TableName("question_tag")
public class QuestionTag implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 标签ID（主键，自增）
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 题目ID
     */
    @TableField("question_id")
    private Long questionId;

    /**
     * 标签名称
     */
    @TableField("tag_name")
    private String tagName;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

