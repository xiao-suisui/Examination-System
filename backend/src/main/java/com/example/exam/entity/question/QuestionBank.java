package com.example.exam.entity.question;

import com.baomidou.mybatisplus.annotation.*;
import com.example.exam.common.enums.BankType;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 题库表实体类
 * 模块：题库管理模块（exam-question）
 * 职责：管理题库（公共题库、私有题库）
 * 表名：question_bank
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
@TableName("question_bank")
public class QuestionBank implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 题库ID（主键，自增）
     */
    @TableId(value = "bank_id", type = IdType.AUTO)
    private Long bankId;

    /**
     * 所属科目ID
     */
    @TableField("subject_id")
    private Long subjectId;

    /**
     * 题库名称
     */
    @TableField("bank_name")
    private String bankName;

    /**
     * 题库描述
     */
    @TableField("description")
    private String description;

    /**
     * 题库类型：PUBLIC-公共题库，PRIVATE-私有题库
     */
    @TableField("bank_type")
    private BankType bankType;

    /**
     * 封面图片
     */
    @TableField("cover_image")
    private String coverImage;

    /**
     * 题目数量（统计字段）
     */
    @TableField("question_count")
    private Integer questionCount;

    /**
     * 创建者ID（私有题库必填，自动填充）
     */
    @TableField(value = "create_user_id", fill = FieldFill.INSERT)
    private Long createUserId;

    /**
     * 组织ID（数据隔离，自动填充）
     */
    @TableField(value = "org_id", fill = FieldFill.INSERT)
    private Long orgId;

    /**
     * 排序
     */
    @TableField("sort")
    private Integer sort;

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

    }

