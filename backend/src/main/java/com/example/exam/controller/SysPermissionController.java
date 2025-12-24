package com.example.exam.controller;

import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.result.Result;
import com.example.exam.dto.SysPermissionDTO;
import com.example.exam.entity.system.SysPermission;
import com.example.exam.service.SysPermissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

/**
 * 权限管理控制器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@RestController
@RequestMapping("/api/permission")
@RequiredArgsConstructor
@Tag(name = "权限管理", description = "权限管理相关接口")
public class SysPermissionController {

    private final SysPermissionService permissionService;

    @RequirePermission(value = "system:permission:view", desc = "查看权限")
    @GetMapping("/tree")
    @Operation(summary = "获取权限树")
    public Result<List<SysPermissionDTO>> getPermissionTree() {
        List<SysPermissionDTO> tree = permissionService.getPermissionTree();
        return Result.success(tree);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "获取用户权限")
    public Result<Set<String>> getUserPermissions(
            @Parameter(description = "用户ID") @PathVariable Long userId) {
        Set<String> permissions = permissionService.getUserPermissionCodes(userId);
        return Result.success(permissions);
    }

    @RequirePermission(value = "system:permission:view", desc = "查看权限")
    @GetMapping("/role/{roleId}")
    @Operation(summary = "获取角色权限")
    public Result<List<SysPermission>> getRolePermissions(
            @Parameter(description = "角色ID") @PathVariable Long roleId) {
        List<SysPermission> permissions = permissionService.getRolePermissions(roleId);
        return Result.success(permissions);
    }

    @RequirePermission(value = "system:permission:update", desc = "更新权限")
    @PostMapping("/role/{roleId}/assign")
    @Operation(summary = "为角色分配权限")
    @OperationLog(module = "权限管理", type = "分配权限", description = "为角色分配权限")
    public Result<Void> assignPermissions(
            @Parameter(description = "角色ID") @PathVariable Long roleId,
            @Parameter(description = "权限ID列表") @RequestBody List<Long> permIds) {
        permissionService.assignPermissionsToRole(roleId, permIds);
        return Result.success();
    }

    @RequirePermission(value = "system:permission:create", desc = "创建权限")
    @PostMapping
    @Operation(summary = "创建权限")
    @OperationLog(module = "权限管理", type = "创建", description = "创建权限")
    public Result<Void> create(@RequestBody SysPermission permission) {
        permissionService.createPermission(permission);
        return Result.success();
    }

    @RequirePermission(value = "system:permission:update", desc = "更新权限")
    @PutMapping("/{id}")
    @Operation(summary = "更新权限")
    @OperationLog(module = "权限管理", type = "更新", description = "更新权限")
    public Result<Void> update(
            @Parameter(description = "权限ID") @PathVariable Long id,
            @RequestBody SysPermission permission) {
        permission.setPermId(id);
        permissionService.updatePermission(permission);
        return Result.success();
    }

    @RequirePermission(value = "system:permission:delete", desc = "删除权限")
    @DeleteMapping("/{id}")
    @Operation(summary = "删除权限")
    @OperationLog(module = "权限管理", type = "删除", description = "删除权限")
    public Result<Void> delete(@Parameter(description = "权限ID") @PathVariable Long id) {
        permissionService.deletePermission(id);
        return Result.success();
    }

    @RequirePermission(value = "system:permission:create", desc = "创建权限")
    @PostMapping("/init")
    @Operation(summary = "初始化默认权限")
    @OperationLog(module = "权限管理", type = "初始化", description = "初始化默认权限")
    public Result<Void> initPermissions() {
        permissionService.initDefaultPermissions();
        return Result.success();
    }

    @RequirePermission(value = "system:permission:view", desc = "查看权限")
    @GetMapping("/check/{userId}/{permCode}")
    @Operation(summary = "检查用户权限")
    public Result<Boolean> checkPermission(
            @Parameter(description = "用户ID") @PathVariable Long userId,
            @Parameter(description = "权限编码") @PathVariable String permCode) {
        boolean hasPermission = permissionService.hasPermission(userId, permCode);
        return Result.success(hasPermission);
    }
}

