package com.example.exam.entity.subject;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 科目管理员实体类
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Accessors(chain = true)
@TableName("subject_manager")
public class SubjectManager implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 关联ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 科目ID
     */
    private Long subjectId;

    /**
     * 管理员ID（教师/助教）
     */
    private Long userId;

    /**
     * 是否为创建者：0-否，1-是
     */
    private Integer isCreator;

    /**
     * 管理员类型：1-主讲教师，2-协作教师，3-助教
     */
    private Integer managerType;

    /**
     * 权限列表（JSON数组）
     */
    private String permissions;

    /**
     * 授权开始日期
     */
    private LocalDate validStartDate;

    /**
     * 授权结束日期
     */
    private LocalDate validEndDate;

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
}

