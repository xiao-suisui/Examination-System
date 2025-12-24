package com.example.exam.controller;

import com.example.exam.annotation.OperationLog;
import com.example.exam.common.result.Result;
import com.example.exam.entity.system.SysPermission;
import com.example.exam.service.SysPermissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 权限管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Tag(name = "权限管理", description = "权限的树形管理和CRUD操作")
@RestController
@RequestMapping("/api/permission")
@RequiredArgsConstructor
public class SysPermissionController {

    private final SysPermissionService permissionService;

    @Operation(summary = "获取权限树", description = "获取树形结构的权限列表")
    @OperationLog(module = "权限管理", type = "查询", description = "获取权限树", recordParams = false)
    @GetMapping("/tree")
    public Result<List<SysPermission>> getTree() {
        List<SysPermission> tree = permissionService.getPermissionTree();
        return Result.success(tree);
    }

    @Operation(summary = "查询权限详情", description = "根据ID查询权限详情")
    @GetMapping("/{id}")
    public Result<SysPermission> getById(
            @Parameter(description = "权限ID", required = true) @PathVariable Long id) {
        SysPermission permission = permissionService.getById(id);
        if (permission == null) {
            return Result.error("权限不存在");
        }
        return Result.success(permission);
    }

    @Operation(summary = "获取子权限", description = "获取指定权限的直属子节点")
    @GetMapping("/{id}/children")
    public Result<List<SysPermission>> getChildren(
            @Parameter(description = "父权限ID", required = true) @PathVariable Long id) {
        List<SysPermission> children = permissionService.getChildrenByParentId(id);
        return Result.success(children);
    }

    @Operation(summary = "获取用户权限", description = "获取指定用户的权限列表")
    @GetMapping("/user/{userId}")
    public Result<List<String>> getUserPermissions(
            @Parameter(description = "用户ID", required = true) @PathVariable Long userId) {
        List<String> permissionCodes = permissionService.getUserPermissionCodes(userId);
        return Result.success(permissionCodes);
    }

    @Operation(summary = "创建权限", description = "创建新权限")
    @OperationLog(module = "权限管理", type = "创建", description = "创建权限")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "权限信息", required = true)
            @Validated @RequestBody SysPermission permission) {

        // 检查权限编码是否重复
        if (permission.getPermCode() != null && !permission.getPermCode().isEmpty()) {
            if (permissionService.isPermCodeExists(permission.getPermCode(), null)) {
                return Result.error("权限编码已存在");
            }
        }

        // 默认值设置
        if (permission.getSort() == null) {
            permission.setSort(0);
        }
        if (permission.getParentId() == null) {
            permission.setParentId(0L);
        }

        boolean success = permissionService.save(permission);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新权限", description = "更新权限信息")
    @OperationLog(module = "权限管理", type = "更新", description = "更新权限")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "权限ID", required = true) @PathVariable Long id,
            @Parameter(description = "权限信息", required = true)
            @Validated @RequestBody SysPermission permission) {

        SysPermission existPerm = permissionService.getById(id);
        if (existPerm == null) {
            return Result.error("权限不存在");
        }

        // 检查权限编码是否重复
        if (permission.getPermCode() != null && !permission.getPermCode().isEmpty()) {
            if (!existPerm.getPermCode().equals(permission.getPermCode())) {
                if (permissionService.isPermCodeExists(permission.getPermCode(), id)) {
                    return Result.error("权限编码已存在");
                }
            }
        }

        // 检查是否将父节点设置为自己
        if (permission.getParentId() != null && permission.getParentId().equals(id)) {
            return Result.error("不能将父节点设置为自己");
        }

        permission.setPermId(id);
        boolean success = permissionService.updateById(permission);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除权限", description = "删除权限（逻辑删除）")
    @OperationLog(module = "权限管理", type = "删除", description = "删除权限")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "权限ID", required = true) @PathVariable Long id) {

        SysPermission permission = permissionService.getById(id);
        if (permission == null) {
            return Result.error("权限不存在");
        }

        // 检查是否有子权限
        if (permissionService.hasChildren(id)) {
            return Result.error("该权限存在子权限，无法删除");
        }

        // 检查是否被角色使用
        if (permissionService.isUsedByRoles(id)) {
            return Result.error("该权限已被角色使用，无法删除");
        }

        boolean success = permissionService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "批量删除权限", description = "批量删除权限（逻辑删除）")
    @OperationLog(module = "权限管理", type = "删除", description = "批量删除权限")
    @DeleteMapping("/batch")
    public Result<Void> batchDelete(
            @Parameter(description = "权限ID列表", required = true) @RequestBody List<Long> ids) {

        try {
            boolean success = permissionService.batchDelete(ids);
            return success ? Result.success() : Result.error("删除失败");
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }
}

