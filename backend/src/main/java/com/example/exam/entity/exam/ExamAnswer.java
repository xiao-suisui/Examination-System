package com.example.exam.entity.exam;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 答题记录表实体类
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：管理考生答题记录（答案、得分、批改）
 * 表名：exam_answer
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
@TableName("exam_answer")
public class ExamAnswer implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 答案ID（主键，自增）
     */
    @TableId(value = "answer_id", type = IdType.AUTO)
    private Long answerId;

    /**
     * 会话ID
     */
    @TableField("session_id")
    private String sessionId;

    /**
     * 考试ID
     */
    @TableField("exam_id")
    private Long examId;

    /**
     * 题目ID
     */
    @TableField("question_id")
    private Long questionId;

    /**
     * 考生ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 选择的选项ID（用逗号分隔，客观题用）
     */
    @TableField("option_ids")
    private String optionIds;

    /**
     * 考生答案（主观题、填空题用）
     */
    @TableField("user_answer")
    private String userAnswer;

    /**
     * 排序题答案（选项ID按顺序，用逗号分隔）
     */
    @TableField("answer_order")
    private String answerOrder;

    /**
     * 该题得分
     */
    @TableField("score")
    private BigDecimal score;

    /**
     * 是否正确：0-错误，1-正确，NULL-未批改
     */
    @TableField("is_correct")
    private Integer isCorrect;

    /**
     * 是否标记（答题时考生标记的不确定题目）
     */
    @TableField("is_marked")
    private Integer isMarked;

    /**
     * 批改人ID
     */
    @TableField("graded_by")
    private Long gradedBy;

    /**
     * 批改时间
     */
    @TableField("grade_time")
    private LocalDateTime gradeTime;

    /**
     * 教师评语（限200字）
     */
    @TableField("teacher_comment")
    private String teacherComment;

    /**
     * 答题时间
     */
    @TableField("answer_time")
    private LocalDateTime answerTime;

    /**
     * 答题耗时（秒）
     */
    @TableField("time_spent")
    private Integer timeSpent;

    /**
     * IP地址
     */
    @TableField("ip_address")
    private String ipAddress;

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

