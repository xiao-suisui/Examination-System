package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 考试考生DTO
 *
 * @author Exam System
 * @since 2025-12-24
 */
@Data
@Schema(description = "考试考生信息")
public class ExamUserDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "考试用户ID")
    private Long examUserId;

    @Schema(description = "考试ID")
    private Long examId;

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "用户名")
    private String userName;

    @Schema(description = "真实姓名")
    private String realName;

    @Schema(description = "考试状态：0-未参考，1-参考中，2-已提交，3-缺考")
    private Integer examStatus;

    @Schema(description = "开始时间")
    private LocalDateTime startTime;

    @Schema(description = "提交时间")
    private LocalDateTime submitTime;

    @Schema(description = "最终成绩")
    private BigDecimal finalScore;

    @Schema(description = "及格状态：0-不及格，1-及格")
    private Integer passStatus;

    @Schema(description = "补考次数")
    private Integer reexamCount;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}

