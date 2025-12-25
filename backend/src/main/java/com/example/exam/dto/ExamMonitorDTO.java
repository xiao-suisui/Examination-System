package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

/**
 * 考试监控DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "考试监控信息DTO")
public class ExamMonitorDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "考试ID")
    private Long examId;

    @Schema(description = "总参与人数")
    private Integer totalParticipants;

    @Schema(description = "当前在线人数")
    private Integer currentOnline;

    @Schema(description = "已提交人数")
    private Integer submitted;

    @Schema(description = "答题中人数")
    private Integer answering;

    @Schema(description = "切屏异常人数")
    private Integer cutScreenAbnormal;

    @Schema(description = "设备异常人数")
    private Integer deviceAbnormal;

    @Schema(description = "疑似作弊人数")
    private Integer suspectedCheating;
}

