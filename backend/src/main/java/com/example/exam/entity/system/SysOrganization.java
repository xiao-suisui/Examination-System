package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 组织表实体类
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

    @Serial
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
     * 组织层级：1-一级，2-二级，3-三级，4-四级
     */
    @TableField("org_level")
    private com.example.exam.common.enums.OrgLevel orgLevel;

    /**
     * 组织类型：1-学校，2-企业，3-培训机构
     */
    @TableField("org_type")
    private com.example.exam.common.enums.OrgType orgType;

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

    /**
     * 子组织列表（非数据库字段，用于构建树形结构）
     */
    @TableField(exist = false)
    private java.util.List<SysOrganization> children;
}

