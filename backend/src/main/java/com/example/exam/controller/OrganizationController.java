package com.example.exam.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.enums.OrgLevel;
import com.example.exam.common.enums.OrgType;
import com.example.exam.common.result.Result;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.service.OrganizationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 组织管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Tag(name = "组织管理", description = "组织架构的增删改查、树形结构管理")
@RestController
@RequestMapping("/api/organization")
@RequiredArgsConstructor
@Slf4j
public class OrganizationController {

    private final OrganizationService organizationService;

    @Operation(summary = "获取组织树", description = "获取完整的组织树形结构")
    @RequirePermission(value = "org:view", desc = "查看组织")
    @OperationLog(module = "组织管理", type = "查询", description = "查询组织树", recordParams = false)
    @GetMapping("/tree")
    public Result<List<SysOrganization>> getOrganizationTree() {
        List<SysOrganization> tree = organizationService.getOrganizationTree();
        return Result.success(tree);
    }

    @Operation(summary = "分页查询组织", description = "分页查询组织列表，支持关键词搜索")
    @RequirePermission(value = "org:view", desc = "查看组织")
    @OperationLog(module = "组织管理", type = "查询", description = "分页查询组织", recordParams = false)
    @GetMapping("/page")
    public Result<IPage<SysOrganization>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "组织名称") @RequestParam(required = false) String orgName,
            @Parameter(description = "组织代码") @RequestParam(required = false) String orgCode,
            @Parameter(description = "父组织ID") @RequestParam(required = false) Long parentId,
            @Parameter(description = "组织类型：1-学校，2-企业，3-培训机构") @RequestParam(required = false) Integer orgType,
            @Parameter(description = "组织层级：1-一级，2-二级，3-三级，4-四级") @RequestParam(required = false) Integer orgLevel) {

        Page<SysOrganization> page = new Page<>(current, size);

        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(orgName != null && !orgName.isEmpty(), SysOrganization::getOrgName, orgName)
               .like(orgCode != null && !orgCode.isEmpty(), SysOrganization::getOrgCode, orgCode)
               .eq(parentId != null, SysOrganization::getParentId, parentId)
               .eq(orgType != null, SysOrganization::getOrgType, OrgType.of(orgType))
               .eq(orgLevel != null, SysOrganization::getOrgLevel, OrgLevel.of(orgLevel))
               .orderByAsc(SysOrganization::getSort)
               .orderByDesc(SysOrganization::getCreateTime);

        IPage<SysOrganization> result = organizationService.page(page, wrapper);
        return Result.success(result);
    }

    @Operation(summary = "根据ID查询组织", description = "根据组织ID查询详细信息")
    @RequirePermission(value = "org:view", desc = "查看组织")
    @GetMapping("/{id:[0-9]+}")
    public Result<SysOrganization> getById(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id) {
        SysOrganization organization = organizationService.getById(id);
        return organization != null ? Result.success(organization) : Result.error("组织不存在");
    }

    @Operation(summary = "创建组织", description = "创建新组织")
    @RequirePermission(value = "org:create", desc = "创建组织")
    @OperationLog(module = "组织管理", type = "创建", description = "创建组织")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "组织信息", required = true) @RequestBody SysOrganization organization) {
        boolean success = organizationService.save(organization);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新组织", description = "更新组织信息")
    @RequirePermission(value = "org:update", desc = "更新组织")
    @OperationLog(module = "组织管理", type = "更新", description = "更新组织")
    @PutMapping("/{id:[0-9]+}")
    public Result<Void> update(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id,
            @Parameter(description = "组织信息", required = true) @RequestBody SysOrganization organization) {
        organization.setOrgId(id);
        boolean success = organizationService.updateById(organization);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除组织", description = "删除组织（如果有子组织则不允许删除）")
    @RequirePermission(value = "org:delete", desc = "删除组织")
    @OperationLog(module = "组织管理", type = "删除", description = "删除组织")
    @DeleteMapping("/{id:[0-9]+}")
    public Result<Void> delete(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id) {
        // 检查是否有子组织
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getParentId, id);
        long childCount = organizationService.count(wrapper);

        if (childCount > 0) {
            return Result.error("该组织下存在子组织，无法删除");
        }

        boolean success = organizationService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "获取子组织列表", description = "获取指定组织的直接子组织")
    @GetMapping("/{id:[0-9]+}/children")
    public Result<List<SysOrganization>> getChildren(
            @Parameter(description = "父组织ID", required = true) @PathVariable Long id) {
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getParentId, id)
               .orderByAsc(SysOrganization::getSort);

        List<SysOrganization> children = organizationService.list(wrapper);
        return Result.success(children);
    }

    @Operation(summary = "移动组织", description = "将组织移动到新的父组织下")
    @OperationLog(module = "组织管理", type = "更新", description = "移动组织")
    @PutMapping("/{id:[0-9]+}/move")
    public Result<Void> moveOrganization(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id,
            @Parameter(description = "新父组织ID", required = true) @RequestParam Long newParentId) {

        // 不能移动到自己的子组织下
        if (organizationService.isDescendant(newParentId, id)) {
            return Result.error("不能移动到自己的子组织下");
        }

        SysOrganization organization = new SysOrganization();
        organization.setOrgId(id);
        organization.setParentId(newParentId);

        boolean success = organizationService.updateById(organization);
        return success ? Result.success() : Result.error("移动失败");
    }
}

