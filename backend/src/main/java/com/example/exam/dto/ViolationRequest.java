package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


/**
 * 违规记录请求DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "违规记录请求")
public class ViolationRequest {

    @Schema(description = "违规类型")
    private String violationType;

    @Schema(description = "违规详情（JSON格式）")
    private String violationDetail;

    @Schema(description = "违规时间")
    private String violationTime;

    @Schema(description = "严重程度：1-5")
    private Integer severity;
}

