package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 权限表实体类
 *
 * 模块：系统管理模块（exam-system）
 * 职责：管理系统权限（菜单、按钮、API接口等）
 * 表名：sys_permission
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("sys_permission")
@Schema(description = "权限实体")
public class SysPermission implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 权限ID（主键，自增）
     */
    @TableId(value = "perm_id", type = IdType.AUTO)
    @Schema(description = "权限ID")
    private Long permId;

    /**
     * 权限名称
     */
    @TableField("perm_name")
    @Schema(description = "权限名称")
    private String permName;

    /**
     * 权限编码（如：user:create、user:update等）
     */
    @TableField("perm_code")
    @Schema(description = "权限编码")
    private String permCode;

    /**
     * 权限类型：MENU-菜单，BUTTON-按钮，API-接口
     */
    @TableField("perm_type")
    @Schema(description = "权限类型：MENU-菜单，BUTTON-按钮，API-接口")
    private String permType;

    /**
     * 权限URL或路由
     */
    @TableField("perm_url")
    @Schema(description = "权限URL或路由")
    private String permUrl;

    /**
     * 父权限ID
     */
    @TableField("parent_id")
    @Schema(description = "父权限ID")
    private Long parentId;

    /**
     * 排序
     */
    @TableField("sort")
    @Schema(description = "排序")
    private Integer sort;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    /**
     * 更新时间（自动填充）
     */
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    /**
     * 是否删除：0-否，1-是（逻辑删除）
     */
    @TableLogic
    @TableField("deleted")
    @Schema(description = "是否删除：0-否，1-是")
    private Integer deleted;
}

