package com.example.exam.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.common.result.Result;
import com.example.exam.dto.SysOrganizationDTO;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.service.SysOrganizationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 组织管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Tag(name = "组织管理", description = "组织架构的增删改查功能")
@RestController
@RequestMapping("/api/organization")
@RequiredArgsConstructor
public class SysOrganizationController {

    private final SysOrganizationService organizationService;

    @Operation(summary = "获取组织树", description = "获取树形结构的组织列表")
    @OperationLog(module = "组织管理", type = "查询", description = "获取组织树", recordParams = false)
    @GetMapping("/tree")
    public Result<List<SysOrganizationDTO>> getTree() {
        List<SysOrganization> tree = organizationService.getOrganizationTree();
        List<SysOrganizationDTO> dtoTree = convertToTreeDTO(tree, 0L);
        return Result.success(dtoTree);
    }

    @Operation(summary = "分页查询组织", description = "分页查询组织列表")
    @OperationLog(module = "组织管理", type = "查询", description = "分页查询组织", recordParams = false)
    @GetMapping("/page")
    public Result<IPage<SysOrganizationDTO>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "组织名称关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "父组织ID") @RequestParam(required = false) Long parentId,
            @Parameter(description = "组织层级") @RequestParam(required = false) Integer orgLevel,
            @Parameter(description = "状态") @RequestParam(required = false) Integer status) {

        Page<SysOrganization> page = new Page<>(current, size);
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(SysOrganization::getOrgName, keyword)
                             .or()
                             .like(SysOrganization::getOrgCode, keyword));
        }

        wrapper.eq(parentId != null, SysOrganization::getParentId, parentId)
               .eq(orgLevel != null, SysOrganization::getOrgLevel, orgLevel)
               .eq(status != null, SysOrganization::getStatus, status)
               .orderByAsc(SysOrganization::getSort)
               .orderByAsc(SysOrganization::getOrgId);

        IPage<SysOrganization> result = organizationService.page(page, wrapper);

        // 转换为DTO
        IPage<SysOrganizationDTO> dtoPage = result.convert(org -> {
            SysOrganizationDTO dto = new SysOrganizationDTO();
            BeanUtils.copyProperties(org, dto);
            dto.setHasChildren(organizationService.hasChildren(org.getOrgId()));
            return dto;
        });

        return Result.success(dtoPage);
    }

    @Operation(summary = "查询组织详情", description = "根据ID查询组织详情")
    @GetMapping("/{id}")
    public Result<SysOrganizationDTO> getById(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id) {
        SysOrganization org = organizationService.getById(id);
        if (org == null) {
            return Result.error("组织不存在");
        }

        SysOrganizationDTO dto = new SysOrganizationDTO();
        BeanUtils.copyProperties(org, dto);
        dto.setHasChildren(organizationService.hasChildren(org.getOrgId()));

        return Result.success(dto);
    }

    @Operation(summary = "获取子组织", description = "获取指定组织的直属子组织")
    @GetMapping("/{id}/children")
    public Result<List<SysOrganizationDTO>> getChildren(
            @Parameter(description = "父组织ID", required = true) @PathVariable Long id) {
        List<SysOrganization> children = organizationService.getChildrenByParentId(id);
        List<SysOrganizationDTO> dtoList = children.stream().map(org -> {
            SysOrganizationDTO dto = new SysOrganizationDTO();
            BeanUtils.copyProperties(org, dto);
            dto.setHasChildren(organizationService.hasChildren(org.getOrgId()));
            return dto;
        }).collect(Collectors.toList());

        return Result.success(dtoList);
    }

    @Operation(summary = "创建组织", description = "创建新组织")
    @OperationLog(module = "组织管理", type = "创建", description = "创建组织")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "组织信息", required = true)
            @Validated @RequestBody SysOrganizationDTO dto) {

        // 检查组织编码是否重复
        if (dto.getOrgCode() != null && !dto.getOrgCode().isEmpty()) {
            if (organizationService.isOrgCodeExists(dto.getOrgCode(), null)) {
                return Result.error("组织编码已存在");
            }
        }

        SysOrganization org = new SysOrganization();
        BeanUtils.copyProperties(dto, org);

        // 默认值设置
        if (org.getStatus() == null) {
            org.setStatus(1); // 默认启用
        }
        if (org.getSort() == null) {
            org.setSort(0);
        }

        boolean success = organizationService.save(org);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新组织", description = "更新组织信息")
    @OperationLog(module = "组织管理", type = "更新", description = "更新组织")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id,
            @Parameter(description = "组织信息", required = true)
            @Validated @RequestBody SysOrganizationDTO dto) {

        SysOrganization existOrg = organizationService.getById(id);
        if (existOrg == null) {
            return Result.error("组织不存在");
        }

        // 检查组织编码是否重复
        if (dto.getOrgCode() != null && !dto.getOrgCode().isEmpty()) {
            if (organizationService.isOrgCodeExists(dto.getOrgCode(), id)) {
                return Result.error("组织编码已存在");
            }
        }

        // 检查是否将父组织设置为自己或自己的子组织
        if (dto.getParentId() != null && dto.getParentId().equals(id)) {
            return Result.error("不能将父组织设置为自己");
        }

        SysOrganization org = new SysOrganization();
        BeanUtils.copyProperties(dto, org);
        org.setOrgId(id);

        boolean success = organizationService.updateById(org);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除组织", description = "删除组织（逻辑删除）")
    @OperationLog(module = "组织管理", type = "删除", description = "删除组织")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id) {

        SysOrganization org = organizationService.getById(id);
        if (org == null) {
            return Result.error("组织不存在");
        }

        // 检查是否有子组织
        if (organizationService.hasChildren(id)) {
            return Result.error("该组织存在子组织，无法删除");
        }

        // 检查是否有用户
        if (organizationService.hasUsers(id)) {
            return Result.error("该组织存在用户，无法删除");
        }

        boolean success = organizationService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "批量删除组织", description = "批量删除组织（逻辑删除）")
    @OperationLog(module = "组织管理", type = "删除", description = "批量删除组织")
    @DeleteMapping("/batch")
    public Result<Void> batchDelete(
            @Parameter(description = "组织ID列表", required = true) @RequestBody List<Long> ids) {

        try {
            boolean success = organizationService.batchDelete(ids);
            return success ? Result.success() : Result.error("删除失败");
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @Operation(summary = "更新组织状态", description = "启用或禁用组织")
    @OperationLog(module = "组织管理", type = "更新", description = "更新组织状态")
    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(
            @Parameter(description = "组织ID", required = true) @PathVariable Long id,
            @Parameter(description = "状态：0-禁用，1-启用", required = true) @RequestParam Integer status) {

        SysOrganization org = organizationService.getById(id);
        if (org == null) {
            return Result.error("组织不存在");
        }

        org.setStatus(status);
        boolean success = organizationService.updateById(org);
        return success ? Result.success() : Result.error("状态更新失败");
    }

    /**
     * 递归构建树形DTO
     */
    private List<SysOrganizationDTO> convertToTreeDTO(List<SysOrganization> allOrgs, Long parentId) {
        List<SysOrganizationDTO> result = new ArrayList<>();

        for (SysOrganization org : allOrgs) {
            if (parentId.equals(org.getParentId())) {
                SysOrganizationDTO dto = new SysOrganizationDTO();
                BeanUtils.copyProperties(org, dto);

                // 递归查找子节点
                List<SysOrganizationDTO> children = convertToTreeDTO(allOrgs, org.getOrgId());
                if (!children.isEmpty()) {
                    dto.setChildren(children);
                    dto.setHasChildren(true);
                } else {
                    dto.setHasChildren(false);
                }

                result.add(dto);
            }
        }

        return result;
    }
}

