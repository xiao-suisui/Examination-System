package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 权限表实体类
 *
 * 模块：系统管理模块（exam-system）
 * 职责：管理系统权限（资源级、操作级）
 * 表名：sys_permission
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
@TableName("sys_permission")
public class SysPermission implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 权限ID（主键，自增）
     */
    @TableId(value = "perm_id", type = IdType.AUTO)
    private Long permId;

    /**
     * 权限名称
     */
    @TableField("perm_name")
    private String permName;

    /**
     * 权限编码（如：user:create、exam:publish）
     */
    @TableField("perm_code")
    private String permCode;

    /**
     * 权限类型：MENU-菜单，BUTTON-按钮，API-接口
     */
    @TableField("perm_type")
    private String permType;

    /**
     * 权限URL或路由
     */
    @TableField("perm_url")
    private String permUrl;

    /**
     * 父权限ID
     */
    @TableField("parent_id")
    private Long parentId;

    /**
     * 排序
     */
    @TableField("sort")
    private Integer sort;

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
     * 逻辑删除标记：0-未删除，1-已删除
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}

