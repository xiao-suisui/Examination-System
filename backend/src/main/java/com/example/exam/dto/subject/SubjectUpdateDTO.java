package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 科目更新DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "科目更新DTO")
public class SubjectUpdateDTO extends SubjectCreateDTO {

    @Schema(description = "科目ID", required = true)
    private Long subjectId;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;
}

