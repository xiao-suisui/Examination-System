package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 科目创建DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目创建DTO")
public class SubjectCreateDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "科目名称")
    @NotBlank(message = "科目名称不能为空")
    private String subjectName;

    @Schema(description = "科目编码")
    @NotBlank(message = "科目编码不能为空")
    private String subjectCode;

    @Schema(description = "归属学院ID")
    @NotNull(message = "归属学院不能为空")
    private Long orgId;

    @Schema(description = "科目描述")
    private String description;

    @Schema(description = "科目封面")
    private String coverImage;

    @Schema(description = "学分")
    private BigDecimal credit;

    @Schema(description = "排序")
    private Integer sort;
}

