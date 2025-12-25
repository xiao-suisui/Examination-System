package com.example.exam.controller;

import com.example.exam.annotation.OperationLog;
import com.example.exam.common.result.Result;
import com.example.exam.service.PermissionCacheService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 缓存管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Slf4j
@Tag(name = "缓存管理", description = "权限缓存管理相关操作")
@RestController
@RequestMapping("/api/cache")
@RequiredArgsConstructor
public class CacheManagementController {

    private final PermissionCacheService permissionCacheService;


    @Operation(summary = "清除指定用户的权限缓存", description = "删除指定用户的权限缓存")
    @OperationLog(module = "缓存管理", type = "删除", description = "清除用户权限缓存")
    @DeleteMapping("/permission/user/{userId}")
    public Result<Void> evictUserPermissions(
            @Parameter(description = "用户ID", required = true) @PathVariable Long userId) {

        permissionCacheService.evictUserPermissions(userId);
        log.info("已清除用户权限缓存 - userId: {}", userId);
        return Result.success("清除成功");
    }

    @Operation(summary = "批量清除用户权限缓存", description = "批量删除多个用户的权限缓存")
    @OperationLog(module = "缓存管理", type = "删除", description = "批量清除用户权限缓存")
    @DeleteMapping("/permission/users")
    public Result<Void> evictUserPermissionsBatch(
            @Parameter(description = "用户ID列表", required = true) @RequestBody List<Long> userIds) {

        permissionCacheService.evictUserPermissionsBatch(userIds);
        log.info("已批量清除用户权限缓存 - count: {}", userIds.size());
        return Result.success("批量清除成功");
    }

    @Operation(summary = "清除所有用户权限缓存", description = "清空系统中所有用户的权限缓存")
    @OperationLog(module = "缓存管理", type = "删除", description = "清除所有用户权限缓存")
    @DeleteMapping("/permission/all")
    public Result<Void> evictAllUserPermissions() {

        permissionCacheService.evictAllUserPermissions();
        log.info("已清除所有用户权限缓存");
        return Result.success("清除成功");
    }

    @Operation(summary = "清除角色相关的权限缓存", description = "删除指定角色下所有用户的权限缓存")
    @OperationLog(module = "缓存管理", type = "删除", description = "清除角色权限缓存")
    @DeleteMapping("/permission/role/{roleId}")
    public Result<Void> evictPermissionsByRole(
            @Parameter(description = "角色ID", required = true) @PathVariable Long roleId) {

        permissionCacheService.evictPermissionsByRole(roleId);
        log.info("已清除角色相关的权限缓存 - roleId: {}", roleId);
        return Result.success("清除成功");
    }

    @Operation(summary = "检查用户权限缓存是否存在", description = "检查指定用户的权限缓存是否存在")
    @GetMapping("/permission/exists/{userId}")
    public Result<Boolean> hasUserPermissions(
            @Parameter(description = "用户ID", required = true) @PathVariable Long userId) {

        boolean exists = permissionCacheService.hasUserPermissions(userId);
        return Result.success(exists);
    }
}

