package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 考试统计DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "考试统计信息DTO")
public class ExamStatisticsDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "考试ID")
    private Long examId;

    @Schema(description = "考试名称")
    private String examName;

    @Schema(description = "总参与人数")
    private Integer totalParticipants;

    @Schema(description = "已提交人数")
    private Integer submittedCount;

    @Schema(description = "未提交人数")
    private Integer notSubmittedCount;

    @Schema(description = "已批改人数")
    private Integer gradedCount;

    @Schema(description = "待批改人数")
    private Integer pendingGradeCount;

    @Schema(description = "平均分")
    private BigDecimal averageScore;

    @Schema(description = "最高分")
    private BigDecimal highestScore;

    @Schema(description = "最低分")
    private BigDecimal lowestScore;

    @Schema(description = "及格人数")
    private Integer passCount;

    @Schema(description = "不及格人数")
    private Integer failCount;

    @Schema(description = "及格率")
    private BigDecimal passRate;

    @Schema(description = "优秀人数（>=90分）")
    private Integer excellentCount;

    @Schema(description = "良好人数（80-89分）")
    private Integer goodCount;

    @Schema(description = "中等人数（70-79分）")
    private Integer mediumCount;

    @Schema(description = "一般人数（60-69分）")
    private Integer fairCount;
}

