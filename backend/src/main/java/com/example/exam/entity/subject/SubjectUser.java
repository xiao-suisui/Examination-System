package com.example.exam.entity.subject;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 科目-用户关联实体
 * <p>记录用户在科目中的角色和权限</p>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-20
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("subject_user")
public class SubjectUser {

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 科目ID
     */
    @TableField("subject_id")
    private Long subjectId;

    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 用户类型（1-创建者，2-管理员，3-教师，4-学生）
     */
    @TableField("user_type")
    private Integer userType;

    /**
     * 权限标识（JSON格式存储具体权限）
     */
    @TableField("permissions")
    private String permissions;

    /**
     * 加入时间
     */
    @TableField(value = "join_time", fill = FieldFill.INSERT)
    private LocalDateTime joinTime;

    /**
     * 创建时间
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 逻辑删除标识（0-未删除，1-已删除）
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}

