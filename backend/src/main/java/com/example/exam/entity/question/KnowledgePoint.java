package com.example.exam.entity.question;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 知识点分类表实体类
 *
 * 模块：题库管理模块（exam-question）
 * 职责：管理知识点3级分类（如：计算机基础→硬件→CPU）
 * 表名：knowledge_point
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
@TableName("knowledge_point")
public class KnowledgePoint implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 知识点ID（主键，自增）
     */
    @TableId(value = "knowledge_id", type = IdType.AUTO)
    private Long knowledgeId;

    /**
     * 知识点名称
     */
    @TableField("knowledge_name")
    private String knowledgeName;

    /**
     * 父知识点ID（0为顶级）
     */
    @TableField("parent_id")
    private Long parentId;

    /**
     * 层级：1-一级，2-二级，3-三级
     */
    @TableField("level")
    private Integer level;

    /**
     * 组织ID（数据隔离）
     */
    @TableField("org_id")
    private Long orgId;

    /**
     * 知识点描述
     */
    @TableField("description")
    private String description;

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
     * 是否删除：0-否，1-是（逻辑删除）
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}

