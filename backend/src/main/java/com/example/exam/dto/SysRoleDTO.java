package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

/**
 * 角色DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Data
@Schema(description = "角色DTO")
public class SysRoleDTO {

    @Schema(description = "角色ID")
    private Long roleId;

    @NotBlank(message = "角色名称不能为空")
    @Schema(description = "角色名称", required = true)
    private String roleName;

    @NotBlank(message = "角色编码不能为空")
    @Schema(description = "角色编码", required = true)
    private String roleCode;

    @Schema(description = "角色描述")
    private String roleDesc;

    @Schema(description = "是否预设角色：0-自定义，1-预设")
    private Integer isDefault;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "权限ID列表")
    private List<Long> permissionIds;
}

