package com.example.exam.controller;

import com.example.exam.annotation.OperationLog;
import com.example.exam.common.result.Result;
import com.example.exam.entity.question.KnowledgePoint;
import com.example.exam.service.KnowledgePointService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 知识点管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Tag(name = "知识点管理", description = "知识点的树形管理和CRUD操作")
@RestController
@RequestMapping("/api/knowledge-point")
@RequiredArgsConstructor
public class KnowledgePointController {

    private final KnowledgePointService knowledgePointService;

    @Operation(summary = "获取知识点树", description = "获取树形结构的知识点列表")
    @OperationLog(module = "知识点管理", type = "创建", description = "获取知识点树", recordParams = false)
    @GetMapping("/tree")
    public Result<List<KnowledgePoint>> getTree(
            @Parameter(description = "组织ID（可选）") @RequestParam(required = false) Long orgId) {
        List<KnowledgePoint> tree = knowledgePointService.getKnowledgeTree(orgId);
        return Result.success(tree);
    }

    @Operation(summary = "查询知识点详情", description = "根据ID查询知识点详情")
    @GetMapping("/{id}")
    public Result<KnowledgePoint> getById(
            @Parameter(description = "知识点ID", required = true) @PathVariable Long id) {
        KnowledgePoint point = knowledgePointService.getById(id);
        if (point == null) {
            return Result.error("知识点不存在");
        }
        return Result.success(point);
    }

    @Operation(summary = "获取子知识点", description = "获取指定知识点的直属子节点")
    @GetMapping("/{id}/children")
    public Result<List<KnowledgePoint>> getChildren(
            @Parameter(description = "父知识点ID", required = true) @PathVariable Long id) {
        List<KnowledgePoint> children = knowledgePointService.getChildrenByParentId(id);
        return Result.success(children);
    }

    @Operation(summary = "获取知识点路径", description = "获取从根节点到当前节点的路径")
    @GetMapping("/{id}/path")
    public Result<List<KnowledgePoint>> getPath(
            @Parameter(description = "知识点ID", required = true) @PathVariable Long id) {
        List<KnowledgePoint> path = knowledgePointService.getKnowledgePath(id);
        return Result.success(path);
    }

    @Operation(summary = "创建知识点", description = "创建新知识点")
    @OperationLog(module = "知识点管理", type = "创建", description = "创建知识点")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "知识点信息", required = true)
            @Validated @RequestBody KnowledgePoint knowledgePoint) {

        // 默认值设置
        if (knowledgePoint.getSort() == null) {
            knowledgePoint.setSort(0);
        }
        if (knowledgePoint.getParentId() == null) {
            knowledgePoint.setParentId(0L);
        }

        boolean success = knowledgePointService.save(knowledgePoint);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新知识点", description = "更新知识点信息")
    @OperationLog(module = "知识点管理", type = "更新", description = "更新知识点")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "知识点ID", required = true) @PathVariable Long id,
            @Parameter(description = "知识点信息", required = true)
            @Validated @RequestBody KnowledgePoint knowledgePoint) {

        KnowledgePoint existPoint = knowledgePointService.getById(id);
        if (existPoint == null) {
            return Result.error("知识点不存在");
        }

        // 检查是否将父节点设置为自己或自己的子节点
        if (knowledgePoint.getParentId() != null && knowledgePoint.getParentId().equals(id)) {
            return Result.error("不能将父节点设置为自己");
        }

        knowledgePoint.setKnowledgeId(id);
        boolean success = knowledgePointService.updateById(knowledgePoint);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除知识点", description = "删除知识点（逻辑删除）")
    @OperationLog(module = "知识点管理", type = "删除", description = "删除知识点")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "知识点ID", required = true) @PathVariable Long id) {

        KnowledgePoint point = knowledgePointService.getById(id);
        if (point == null) {
            return Result.error("知识点不存在");
        }

        // 检查是否有子知识点
        if (knowledgePointService.hasChildren(id)) {
            return Result.error("该知识点存在子知识点，无法删除");
        }

        // 检查是否被题目使用
        if (knowledgePointService.isUsedByQuestions(id)) {
            return Result.error("该知识点已被题目使用，无法删除");
        }

        boolean success = knowledgePointService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "批量删除知识点", description = "批量删除知识点（逻辑删除）")
    @OperationLog(module = "知识点管理", type = "删除", description = "批量删除知识点")
    @DeleteMapping("/batch")
    public Result<Void> batchDelete(
            @Parameter(description = "知识点ID列表", required = true) @RequestBody List<Long> ids) {

        try {
            boolean success = knowledgePointService.batchDelete(ids);
            return success ? Result.success() : Result.error("删除失败");
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }
}

