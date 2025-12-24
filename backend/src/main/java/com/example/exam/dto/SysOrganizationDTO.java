package com.example.exam.dto;

import com.example.exam.common.enums.OrgLevel;
import com.example.exam.common.enums.OrgType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

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
    @Schema(description = "组织层级", required = true)
    private OrgLevel orgLevel;

    @Schema(description = "组织类型")
    private OrgType orgType;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "子组织列表")
    private List<SysOrganizationDTO> children;

    @Schema(description = "是否有子组织")
    private Boolean hasChildren;
}

