package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 角色表实体类
 *
 * 模块：系统管理模块（exam-system）
 * 职责：管理用户角色（管理员、教师、考生等）
 * 表名：sys_role
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
@TableName("sys_role")
public class SysRole implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 角色ID（主键，自增）
     */
    @TableId(value = "role_id", type = IdType.AUTO)
    private Long roleId;

    /**
     * 角色名称
     */
    @TableField("role_name")
    private String roleName;

    /**
     * 角色编码（如：ADMIN、TEACHER、STUDENT）
     */
    @TableField("role_code")
    private String roleCode;

    /**
     * 角色描述
     */
    @TableField("role_desc")
    private String roleDesc;

    /**
     * 是否预设角色：0-自定义，1-预设（不可删除）
     */
    @TableField("is_default")
    private Integer isDefault;

    /**
     * 创建人ID
     */
    @TableField("create_user_id")
    private Long createUserId;

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

