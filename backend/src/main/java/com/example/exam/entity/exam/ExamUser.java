package com.example.exam.entity.exam;

import com.baomidou.mybatisplus.annotation.*;
import lombok.*;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 考试考生关联表实体类
 *
 * 模块：考试管理模块
 * 职责：管理考试与考生的关联关系
 * 表名：exam_user
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
@TableName("exam_user")
public class ExamUser implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 关联ID（主键，自增）
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

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
     * 考试状态：0-未参考，1-参考中，2-已提交，3-缺考
     */
    @TableField("exam_status")
    private Integer examStatus;

    /**
     * 已补考次数
     */
    @TableField("reexam_count")
    private Integer reexamCount;

    /**
     * 最终成绩
     */
    @TableField("final_score")
    private BigDecimal finalScore;

    /**
     * 及格状态：0-不及格，1-及格
     */
    @TableField("pass_status")
    private Integer passStatus;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

