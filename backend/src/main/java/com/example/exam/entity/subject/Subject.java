package com.example.exam.entity.subject;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 科目实体类
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Accessors(chain = true)
@TableName("subject")
public class Subject implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 科目ID
     */
    @TableId(value = "subject_id", type = IdType.AUTO)
    private Long subjectId;

    /**
     * 科目名称
     */
    private String subjectName;

    /**
     * 科目编码
     */
    private String subjectCode;

    /**
     * 归属学院ID（org_level=2）
     */
    private Long orgId;

    /**
     * 科目描述
     */
    private String description;

    /**
     * 科目封面
     */
    private String coverImage;

    /**
     * 学分
     */
    private BigDecimal credit;

    /**
     * 状态：0-禁用，1-启用
     */
    private Integer status;

    /**
     * 排序
     */
    private Integer sort;

    /**
     * 创建人ID（科目创建者，自动填充）
     */
    @TableField(value = "create_user_id", fill = FieldFill.INSERT)
    private Long createUserId;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 是否删除：0-否，1-是
     */
    @TableLogic
    private Integer deleted;
}

