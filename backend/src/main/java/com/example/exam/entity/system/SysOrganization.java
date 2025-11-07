package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 组织表实体类
 *
 * 模块：系统管理模块（exam-system）
 * 职责：管理组织架构（学校、学院、班级等）
 * 表名：sys_organization
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
@TableName("sys_organization")
public class SysOrganization implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 组织ID（主键，自增）
     */
    @TableId(value = "org_id", type = IdType.AUTO)
    private Long orgId;

    /**
     * 组织名称
     */
    @TableField("org_name")
    private String orgName;

    /**
     * 组织编码
     */
    @TableField("org_code")
    private String orgCode;

    /**
     * 父组织ID（0为顶级）
     */
    @TableField("parent_id")
    private Long parentId;

    /**
     * 组织层级：1-学校/企业，2-学院/部门，3-班级/小组
     */
    @TableField("org_level")
    private Integer orgLevel;

    /**
     * 组织类型：SCHOOL-学校，ENTERPRISE-企业，TRAINING-培训机构
     */
    @TableField("org_type")
    private String orgType;

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

