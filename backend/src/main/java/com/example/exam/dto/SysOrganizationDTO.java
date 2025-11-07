package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * 组织DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Data
@Schema(description = "组织DTO")
public class SysOrganizationDTO {

    @Schema(description = "组织ID")
    private Long orgId;

    @NotBlank(message = "组织名称不能为空")
    @Schema(description = "组织名称", required = true)
    private String orgName;

    @Schema(description = "组织编码")
    private String orgCode;

    @NotNull(message = "父组织ID不能为空")
    @Schema(description = "父组织ID（0为顶级）", required = true)
    private Long parentId;

    @NotNull(message = "组织层级不能为空")
    @Schema(description = "组织层级：1-学校/企业，2-学院/部门，3-班级/小组", required = true)
    private Integer orgLevel;

    @Schema(description = "组织类型：SCHOOL-学校，ENTERPRISE-企业，TRAINING-培训机构")
    private String orgType;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "子组织列表")
    private List<SysOrganizationDTO> children;

    @Schema(description = "是否有子组织")
    private Boolean hasChildren;
}

