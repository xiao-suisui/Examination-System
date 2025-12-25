package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;

import java.io.Serial;
import java.io.Serializable;

/**
 * 科目管理员添加DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目管理员添加DTO")
public class SubjectManagerAddDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "用户ID")
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @Schema(description = "管理员类型：1-主讲教师，2-协作教师，3-助教")
    @NotNull(message = "管理员类型不能为空")
    private Integer managerType;

    @Schema(description = "权限列表")
    private String[] permissions;
}

