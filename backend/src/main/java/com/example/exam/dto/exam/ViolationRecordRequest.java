package com.example.exam.dto.exam;

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
public class ViolationRecordRequest {

    @Schema(description = "会话ID", required = true)
    private String sessionId;

    @Schema(description = "违规类型：TAB_SWITCH-切屏，COPY-复制，PASTE-粘贴，RIGHT_CLICK-右键，EXIT_FULLSCREEN-退出全屏，IDLE_TIMEOUT-长时间无操作", required = true)
    private String violationType;

    @Schema(description = "详细信息（JSON格式）")
    private String violationDetail;

    @Schema(description = "严重程度：1-轻微，2-一般，3-严重，4-非常严重，5-致命")
    private Integer severity;
}

