package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.result.Result;
import com.example.exam.dto.SysRoleDTO;
import com.example.exam.entity.system.SysRole;
import com.example.exam.service.SysRoleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 角色管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Tag(name = "角色管理", description = "角色的增删改查和权限分配")
@RestController
@RequestMapping("/api/role")
@RequiredArgsConstructor
public class SysRoleController {

    private final SysRoleService roleService;

    @Operation(summary = "分页查询角色", description = "分页查询角色列表")
    @RequirePermission(value = "system:role:view", desc = "查看角色")
    @OperationLog(module = "角色管理", type = "查询", description = "分页查询角色", recordParams = false)
    @GetMapping("/page")
    public Result<IPage<SysRole>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "状态") @RequestParam(required = false) Integer status) {

        Page<SysRole> page = new Page<>(current, size);
        IPage<SysRole> result = roleService.pageRoles(page, keyword, status);
        return Result.success(result);
    }

    @Operation(summary = "获取所有启用的角色", description = "获取所有启用状态的角色")
    @RequirePermission(value = "system:role:view", desc = "查看角色")
    @GetMapping("/enabled")
    public Result<List<SysRole>> getEnabledRoles() {
        List<SysRole> roles = roleService.getEnabledRoles();
        return Result.success(roles);
    }

    @Operation(summary = "查询角色详情", description = "根据ID查询角色详情")
    @RequirePermission(value = "system:role:view", desc = "查看角色")
    @GetMapping("/{id}")
    public Result<SysRoleDTO> getById(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id) {
        SysRole role = roleService.getById(id);
        if (role == null) {
            return Result.error("角色不存在");
        }

        SysRoleDTO dto = new SysRoleDTO();
        BeanUtils.copyProperties(role, dto);

        // 获取角色权限
        List<Long> permissionIds = roleService.getRolePermissionIds(id);
        dto.setPermissionIds(permissionIds);

        return Result.success(dto);
    }

    @Operation(summary = "创建角色", description = "创建新角色")
    @RequirePermission(value = "system:role:create", desc = "创建角色")
    @OperationLog(module = "角色管理", type = "创建", description = "创建角色")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "角色信息", required = true)
            @Validated @RequestBody SysRoleDTO dto) {

        // 检查角色编码是否重复
        if (roleService.isRoleCodeExists(dto.getRoleCode(), null)) {
            return Result.error("角色编码已存在");
        }

        SysRole role = new SysRole();
        BeanUtils.copyProperties(dto, role);

        // 默认值设置
        if (role.getStatus() == null) {
            role.setStatus(1);
        }
        if (role.getSort() == null) {
            role.setSort(0);
        }
        if (role.getIsDefault() == null) {
            role.setIsDefault(0);
        }

        boolean success = roleService.save(role);

        // 分配权限
        if (success && dto.getPermissionIds() != null && !dto.getPermissionIds().isEmpty()) {
            roleService.assignPermissions(role.getRoleId(), dto.getPermissionIds());
        }

        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新角色", description = "更新角色信息")
    @RequirePermission(value = "system:role:update", desc = "更新角色")
    @OperationLog(module = "角色管理", type = "更新", description = "更新角色")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id,
            @Parameter(description = "角色信息", required = true)
            @Validated @RequestBody SysRoleDTO dto) {

        SysRole existRole = roleService.getById(id);
        if (existRole == null) {
            return Result.error("角色不存在");
        }

        // 预设角色不允许修改编码
        if (existRole.getIsDefault() == 1 && !existRole.getRoleCode().equals(dto.getRoleCode())) {
            return Result.error("预设角色不允许修改编码");
        }

        // 检查角色编码是否重复
        if (!existRole.getRoleCode().equals(dto.getRoleCode())) {
            if (roleService.isRoleCodeExists(dto.getRoleCode(), id)) {
                return Result.error("角色编码已存在");
            }
        }

        SysRole role = new SysRole();
        BeanUtils.copyProperties(dto, role);
        role.setRoleId(id);

        boolean success = roleService.updateById(role);

        // 更新权限
        if (success && dto.getPermissionIds() != null) {
            roleService.assignPermissions(id, dto.getPermissionIds());
        }

        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除角色", description = "删除角色（逻辑删除）")
    @RequirePermission(value = "system:role:delete", desc = "删除角色")
    @OperationLog(module = "角色管理", type = "删除", description = "删除角色")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id) {

        SysRole role = roleService.getById(id);
        if (role == null) {
            return Result.error("角色不存在");
        }

        // 预设角色不允许删除
        if (role.getIsDefault() == 1) {
            return Result.error("预设角色不允许删除");
        }

        // 检查是否被使用
        if (roleService.isRoleInUse(id)) {
            return Result.error("该角色已被用户使用，无法删除");
        }

        boolean success = roleService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "更新角色状态", description = "启用或禁用角色")
    @RequirePermission(value = "system:role:update", desc = "更新角色")
    @OperationLog(module = "角色管理", type = "更新", description = "更新角色状态")
    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id,
            @Parameter(description = "状态：0-禁用，1-启用", required = true) @RequestParam Integer status) {

        SysRole role = roleService.getById(id);
        if (role == null) {
            return Result.error("角色不存在");
        }

        role.setStatus(status);
        boolean success = roleService.updateById(role);
        return success ? Result.success() : Result.error("状态更新失败");
    }

    @Operation(summary = "为角色分配权限", description = "为指定角色分配权限")
    @RequirePermission(value = "system:role:update", desc = "更新角色")
    @OperationLog(module = "角色管理", type = "更新", description = "分配角色权限")
    @PostMapping("/{id}/permissions")
    public Result<Void> assignPermissions(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id,
            @Parameter(description = "权限ID列表", required = true) @RequestBody Map<String, List<Long>> params) {

        SysRole role = roleService.getById(id);
        if (role == null) {
            return Result.error("角色不存在");
        }

        List<Long> permissionIds = params.get("permissionIds");
        boolean success = roleService.assignPermissions(id, permissionIds);
        return success ? Result.success() : Result.error("权限分配失败");
    }

    @Operation(summary = "获取角色权限", description = "获取角色已分配的权限ID列表")
    @GetMapping("/{id}/permissions")
    public Result<List<Long>> getRolePermissions(
            @Parameter(description = "角色ID", required = true) @PathVariable Long id) {
        List<Long> permissionIds = roleService.getRolePermissionIds(id);
        return Result.success(permissionIds);
    }
}

