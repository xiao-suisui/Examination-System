package com.example.exam.entity.system;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 操作日志表实体类
 *
 * 模块：系统管理模块（exam-system）
 * 职责：记录系统操作日志
 * 表名：sys_operation_log
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
@TableName("sys_operation_log")
public class SysOperationLog implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 日志ID（主键，自增）
     */
    @TableId(value = "log_id", type = IdType.AUTO)
    private Long logId;

    /**
     * 操作人ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 操作类型：CREATE-新增，UPDATE-修改，DELETE-删除，PUBLISH-发布，TERMINATE-终止
     */
    @TableField("operate_type")
    private String operateType;

    /**
     * 操作模块：PAPER-试卷，EXAM-考试，QUESTION-题目
     */
    @TableField("operate_module")
    private String operateModule;

    /**
     * 操作内容描述
     */
    @TableField("operate_content")
    private String operateContent;

    /**
     * 操作对象ID
     */
    @TableField("target_id")
    private Long targetId;

    /**
     * 操作IP
     */
    @TableField("ip_address")
    private String ipAddress;

    /**
     * 设备信息
     */
    @TableField("device_info")
    private String deviceInfo;

    /**
     * 操作时间（自动填充）
     */
    @TableField(value = "operate_time", fill = FieldFill.INSERT)
    private LocalDateTime operateTime;
}

