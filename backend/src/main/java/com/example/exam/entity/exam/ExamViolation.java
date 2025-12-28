package com.example.exam.entity.exam;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 考试违规记录表实体类
 * 模块：考试管理模块（exam-exam）
 * 职责：记录考试过程中的异常行为
 * 表名：exam_violation
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("exam_violation")
public class ExamViolation implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（自增）
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 考试会话ID
     */
    @TableField("session_id")
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
     * 违规类型：TAB_SWITCH-切屏，COPY-复制，PASTE-粘贴，RIGHT_CLICK-右键，EXIT_FULLSCREEN-退出全屏，IDLE_TIMEOUT-长时间无操作
     */
    @TableField("violation_type")
    private String violationType;

    /**
     * 违规时间
     */
    @TableField("violation_time")
    private LocalDateTime violationTime;

    /**
     * 详细信息（JSON格式）
     */
    @TableField("violation_detail")
    private String violationDetail;

    /**
     * 严重程度：1-轻微，2-一般，3-严重，4-非常严重，5-致命
     */
    @TableField("severity")
    private Integer severity;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

