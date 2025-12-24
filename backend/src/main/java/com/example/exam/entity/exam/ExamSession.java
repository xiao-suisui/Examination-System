package com.example.exam.entity.exam;

import com.baomidou.mybatisplus.annotation.*;
import com.example.exam.common.enums.ExamSessionStatus;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 考试会话表实体类
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：管理考试会话（答题进度、切屏记录）
 * 表名：exam_session
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
@TableName("exam_session")
public class ExamSession implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 会话ID（UUID）
     */
    @TableId(value = "session_id", type = IdType.INPUT)
    private String sessionId;

    /**
     * 考试ID
     */
    @TableField("exam_id")
    private Long examId;

    /**
     * 考生ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 第几次考试（补考用）
     */
    @TableField("attempt_number")
    private Integer attemptNumber;

    /**
     * 开始时间
     */
    @TableField("start_time")
    private LocalDateTime startTime;

    /**
     * 提交时间
     */
    @TableField("submit_time")
    private LocalDateTime submitTime;

    /**
     * 实际用时（分钟）
     */
    @TableField("duration")
    private Integer duration;

    /**
     * 会话状态：IN_PROGRESS-进行中，SUBMITTED-已提交，GRADED-已批改，TERMINATED-已终止
     */
    @TableField("session_status")
    private ExamSessionStatus sessionStatus;

    /**
     * 总得分
     */
    @TableField("total_score")
    private BigDecimal totalScore;

    /**
     * 客观题得分
     */
    @TableField("objective_score")
    private BigDecimal objectiveScore;

    /**
     * 主观题得分
     */
    @TableField("subjective_score")
    private BigDecimal subjectiveScore;

    /**
     * IP地址
     */
    @TableField("ip_address")
    private String ipAddress;

    /**
     * 设备信息
     */
    @TableField("device_info")
    private String deviceInfo;

    /**
     * 切屏次数
     */
    @TableField("tab_switch_count")
    private Integer tabSwitchCount;

    /**
     * 切屏记录（JSON数组）
     */
    @TableField("tab_switch_records")
    private String tabSwitchRecords;

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
}

