package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.PaperType;
import com.example.exam.common.result.Result;
import com.example.exam.dto.PaperDTO;
import com.example.exam.entity.paper.Paper;
import com.example.exam.entity.paper.PaperRule;
import com.example.exam.service.PaperService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 试卷管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "试卷管理", description = "试卷的创建、编辑、组卷等功能")
@RestController
@RequestMapping("/api/paper")
@RequiredArgsConstructor
@lombok.extern.slf4j.Slf4j
public class PaperController {

    private final PaperService paperService;

    @Operation(summary = "查询试卷列表", description = "查询所有试卷列表（不分页），用于下拉选择")
    @OperationLog(module = "试卷管理", type = "查询", description = "查询试卷列表", recordParams = false)
    @RequirePermission(value = "paper:view", desc = "查看试卷")
    @GetMapping("/list")
    public Result<java.util.List<PaperDTO>> list(
            @Parameter(description = "试卷名称关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "题库ID") @RequestParam(required = false) Long bankId,
            @Parameter(description = "审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝")
            @RequestParam(required = false) Integer auditStatus) {
        // 将 Integer 转换为 AuditStatus 枚举
        AuditStatus status = auditStatus != null ? AuditStatus.of(auditStatus) : null;
        java.util.List<PaperDTO> list = paperService.listPapers(keyword, bankId, status);
        return Result.success(list);
    }

    @Operation(summary = "分页查询试卷", description = "查询试卷列表，支持关键词搜索")
    @OperationLog(module = "试卷管理", type = "查询", description = "分页查询试卷", recordParams = false)
    @RequirePermission(value = "paper:view", desc = "查看试卷")
    @GetMapping("/page")
    public Result<IPage<PaperDTO>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "试卷名称关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "题库ID") @RequestParam(required = false) Long bankId,
            @Parameter(description = "组卷方式：1-手动组卷，2-自动组卷，3-随机组卷")
            @RequestParam(required = false) PaperType paperType,
            @Parameter(description = "审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝")
            @RequestParam(required = false) AuditStatus auditStatus) {

        // Spring MVC 通过 @JsonCreator 自动转换，无需手动处理
        Page<Paper> page = new Page<>(current, size);
        IPage<PaperDTO> result = paperService.pagePapers(page, keyword, bankId, paperType, auditStatus);
        return Result.success(result);
    }

    @Operation(summary = "查询试卷详情", description = "根据ID查询试卷详情，包含所有题目信息")
    @RequirePermission(value = "paper:view", desc = "查看试卷")
    @GetMapping("/{id:[0-9]+}")
    public Result<PaperDTO> getById(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id) {
        PaperDTO paper = paperService.getPaperDTOWithQuestions(id);
        return paper != null ? Result.success(paper) : Result.error("试卷不存在");
    }

    @Operation(summary = "试卷统计", description = "查询试卷统计信息（题型分布、难度分布、使用情况）")
    @OperationLog(module = "试卷管理", type = "查询", description = "查询试卷统计信息", recordParams = false)
    @RequirePermission(value = "paper:view", desc = "查看试卷")
    @GetMapping("/{id:[0-9]+}/statistics")
    public Result<com.example.exam.dto.PaperStatisticsDTO> statistics(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id) {
        com.example.exam.dto.PaperStatisticsDTO statistics = paperService.getPaperStatistics(id);
        if (statistics == null) {
            return Result.error("试卷不存在");
        }
        return Result.success(statistics);
    }

    @Operation(summary = "创建试卷", description = "创建新试卷（手动组卷或自动组卷）")
    @OperationLog(module = "试卷管理", type = "创建", description = "创建试卷")
    @RequirePermission(value = "paper:create", desc = "创建试卷")
    @PostMapping
    public Result<Long> create(
            @Parameter(description = "试卷信息", required = true) @RequestBody Paper paper) {
        boolean success = paperService.save(paper);
        return success ? Result.success("创建成功", paper.getPaperId()) : Result.error("创建失败");
    }

    @Operation(summary = "更新试卷", description = "更新试卷基本信息")
    @OperationLog(module = "试卷管理", type = "更新", description = "更新试卷")
    @RequirePermission(value = "paper:update", desc = "更新试卷")
    @PutMapping("/{id:[0-9]+}")
    public Result<Void> update(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id,
            @Parameter(description = "试卷信息", required = true) @RequestBody Paper paper) {
        paper.setPaperId(id);
        boolean success = paperService.updateById(paper);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除试卷", description = "删除试卷（未被使用的试卷可删除）")
    @OperationLog(module = "试卷管理", type = "删除", description = "删除试卷")
    @RequirePermission(value = "paper:delete", desc = "删除试卷")
    @DeleteMapping("/{id:[0-9]+}")
    public Result<Void> delete(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id) {
        boolean success = paperService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "自动组卷", description = "根据组卷规则自动生成试卷")
    @OperationLog(module = "试卷管理", type = "创建", description = "智能组卷")
    @RequirePermission(value = "paper:create", desc = "创建试卷")
    @PostMapping("/auto-generate")
    public Result<Long> autoGenerate(
            @Parameter(description = "自动组卷请求", required = true)
            @RequestBody com.example.exam.dto.AutoGeneratePaperRequest request) {

        if (request.getPaper() == null || request.getRules() == null || request.getRules().isEmpty()) {
            return Result.error("试卷信息和组卷规则不能为空");
        }

        Long paperId = paperService.autoGeneratePaper(
            request.getPaper(),
            request.getRules().toArray(new PaperRule[0])
        );
        return paperId != null ? Result.success("组卷成功", paperId) : Result.error("组卷失败");
    }

    @Operation(summary = "添加题目到试卷", description = "手动向试卷中添加题目")
    @RequirePermission(value = "paper:update", desc = "更新试卷")
    @PostMapping("/{id:[0-9]+}/questions")
    public Result<Void> addQuestions(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id,
            @Parameter(description = "题目ID列表", required = true) @RequestBody Long[] questionIds) {
        boolean success = paperService.addQuestionsToPaper(id, questionIds);
        return success ? Result.success() : Result.error("添加失败");
    }

    @Operation(summary = "从试卷移除题目", description = "从试卷中移除指定题目")
    @DeleteMapping("/{id:[0-9]+}/questions")
    public Result<Void> removeQuestions(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id,
            @Parameter(description = "题目ID列表", required = true) @RequestBody Long[] questionIds) {
        boolean success = paperService.removeQuestionsFromPaper(id, questionIds);
        return success ? Result.success() : Result.error("移除失败");
    }

    @Operation(summary = "预览试卷", description = "预览试卷内容（不含答案）")
    @GetMapping("/{id:[0-9]+}/preview")
    public Result<Paper> preview(
            @Parameter(description = "试卷ID", required = true) @PathVariable Long id) {
        Paper paper = paperService.previewPaper(id);
        return paper != null ? Result.success(paper) : Result.error("试卷不存在");
    }

    @Operation(summary = "复制试卷", description = "复制现有试卷生成新试卷")
    @PostMapping("/{id:[0-9]+}/copy")
    public Result<Long> copy(
            @Parameter(description = "原试卷ID", required = true) @PathVariable Long id,
            @Parameter(description = "新试卷标题", required = true) @RequestParam String newTitle) {
        Long newPaperId = paperService.copyPaper(id, newTitle);
        return newPaperId != null ? Result.success("复制成功", newPaperId) : Result.error("复制失败");
    }
}

