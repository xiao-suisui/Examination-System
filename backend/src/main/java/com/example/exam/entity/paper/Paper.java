package com.example.exam.entity.paper;

import com.baomidou.mybatisplus.annotation.*;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.PaperType;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 试卷表实体类
 * 模块：试卷管理模块（exam-paper）
 * 职责：管理试卷（手动组卷、自动组卷、随机组卷）
 * 表名：paper
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("paper")
public class Paper implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 试卷ID（主键，自增）
     */
    @TableId(value = "paper_id", type = IdType.AUTO)
    private Long paperId;

    /**
     * 试卷名称
     */
    @TableField("paper_name")
    private String paperName;

    /**
     * 试卷描述
     */
    @TableField("description")
    private String description;

    /**
     * 组卷方式：1-手动组卷，2-自动组卷，3-随机组卷
     */
    @TableField("paper_type")
    private PaperType paperType;

    /**
     * 试卷总分
     */
    @TableField("total_score")
    private BigDecimal totalScore;

    /**
     * 及格分
     */
    @TableField("pass_score")
    private BigDecimal passScore;

    /**
     * 组织ID（数据隔离）
     */
    @TableField("org_id")
    private Long orgId;

    /**
     * 创建人ID
     */
    @TableField("create_user_id")
    private Long createUserId;

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
     * 发布状态：0-未发布，1-已发布，2-已过期
     */
    @TableField("publish_status")
    private Integer publishStatus;

    /**
     * 发布时间
     */
    @TableField("publish_time")
    private LocalDateTime publishTime;

    /**
     * 允许查看错题解析：0-否，1-是
     */
    @TableField("allow_view_analysis")
    private Integer allowViewAnalysis;

    /**
     * 允许补考：0-否，1-是
     */
    @TableField("allow_reexam")
    private Integer allowReexam;

    /**
     * 补考次数限制（0表示不限）
     */
    @TableField("reexam_limit")
    private Integer reexamLimit;

    /**
     * 发布后有效天数
     */
    @TableField("valid_days")
    private Integer validDays;

    /**
     * 试卷版本号
     */
    @TableField("version")
    private Integer version;

    /**
     * 父试卷ID（版本管理用）
     */
    @TableField("parent_paper_id")
    private Long parentPaperId;

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

    // ==================== 非数据库字段（用于前端显示） ====================

    /**
     * 题目数量（非数据库字段，从PaperRule或PaperQuestion统计）
     */
    @TableField(exist = false)
    private Integer questionCount;

    /**
     * 题库名称（非数据库字段，关联查询）
     */
    @TableField(exist = false)
    private String bankName;

    /**
     * 题库ID（非数据库字段，从PaperRule或题目中获取）
     */
    @TableField(exist = false)
    private Long bankId;
}

