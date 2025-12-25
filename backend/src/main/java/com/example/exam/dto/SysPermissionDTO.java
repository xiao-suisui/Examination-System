package com.example.exam.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 权限DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "权限DTO")
public class SysPermissionDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "权限ID")
    private Long permId;

    @Schema(description = "权限名称")
    private String permName;

    @Schema(description = "权限编码")
    private String permCode;

    @Schema(description = "权限类型：MENU-菜单，BUTTON-按钮，API-接口")
    private String permType;

    @Schema(description = "权限URL或路由")
    private String permUrl;

    @Schema(description = "父权限ID")
    private Long parentId;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "子权限列表")
    private List<SysPermissionDTO> children;
}

