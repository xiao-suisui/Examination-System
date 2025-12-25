package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 学生选课DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "学生选课DTO")
public class SubjectEnrollStudentsDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "学生ID列表")
    @NotNull(message = "学生ID列表不能为空")
    private List<Long> studentIds;

    @Schema(description = "选课类型：1-必修，2-选修")
    private Integer enrollType = 1;
}

