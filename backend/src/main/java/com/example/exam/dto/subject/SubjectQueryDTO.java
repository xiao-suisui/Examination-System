package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 科目查询DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目查询DTO")
public class SubjectQueryDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "当前页")
    private Long current = 1L;

    @Schema(description = "每页大小")
    private Long size = 10L;

    @Schema(description = "关键词（科目名称/编码）")
    private String keyword;

    @Schema(description = "归属学院ID")
    private Long orgId;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "创建人ID")
    private Long createUserId;
}

