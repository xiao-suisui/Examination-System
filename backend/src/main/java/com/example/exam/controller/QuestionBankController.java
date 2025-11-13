package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.BankType;
import com.example.exam.common.result.Result;
import com.example.exam.entity.question.QuestionBank;
import com.example.exam.service.QuestionBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 题库管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "题库管理", description = "题库的创建、管理、导入导出等功能")
@RestController
@RequestMapping("/api/question-bank")
@RequiredArgsConstructor
@lombok.extern.slf4j.Slf4j
public class QuestionBankController {

    private final QuestionBankService questionBankService;

    @Operation(summary = "分页查询题库", description = "查询题库列表，支持关键词搜索")
    @com.example.exam.annotation.OperationLog(module = "题库管理", type = "查询", description = "分页查询题库", recordParams = false)
    @GetMapping("/page")
    public Result<IPage<QuestionBank>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "题库名称关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "题库类型（1-公共题库,2-私有题库）", example = "1") @RequestParam(required = false) Integer bankType) {

        // 手动转换枚举
        BankType bankTypeEnum = bankType != null ? BankType.fromCode(bankType) : null;

        Page<QuestionBank> page = new Page<>(current, size);
        IPage<QuestionBank> result = questionBankService.pageQuestionBanks(page, keyword, bankTypeEnum);
        return Result.success(result);
    }

    @Operation(summary = "查询所有题库", description = "查询所有可用题库（用于下拉选择）")
    @GetMapping("/list")
    public Result<List<QuestionBank>> list() {
        List<QuestionBank> list = questionBankService.list();
        return Result.success(list);
    }

    @Operation(summary = "查询题库详情", description = "根据ID查询题库详细信息")
    @GetMapping("/{id}")
    public Result<QuestionBank> getById(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        QuestionBank questionBank = questionBankService.getById(id);
        return questionBank != null ? Result.success(questionBank) : Result.error("题库不存在");
    }

    @Operation(summary = "创建题库", description = "创建新的题库")
    @com.example.exam.annotation.OperationLog(module = "题库管理", type = "创建", description = "创建题库")
    @PostMapping
    public Result<Long> create(
            @Parameter(description = "题库信息", required = true) @RequestBody QuestionBank questionBank) {
        boolean success = questionBankService.save(questionBank);
        return success ? Result.success("创建成功", questionBank.getBankId()) : Result.error("创建失败");
    }

    @Operation(summary = "更新题库", description = "更新题库信息")
    @com.example.exam.annotation.OperationLog(module = "题库管理", type = "更新", description = "更新题库")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id,
            @Parameter(description = "题库信息", required = true) @RequestBody QuestionBank questionBank) {
        questionBank.setBankId(id);
        boolean success = questionBankService.updateById(questionBank);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除题库", description = "删除题库（题库下无题目时可删除）")
    @com.example.exam.annotation.OperationLog(module = "题库管理", type = "删除", description = "删除题库")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        boolean success = questionBankService.removeById(id);
        return success ? Result.success() : Result.error("删除失败，题库下可能还有题目");
    }

    @Operation(summary = "题库统计", description = "查询题库中的题目统计信息（包含题型分布、难度分布、审核状态）")
    @com.example.exam.annotation.OperationLog(module = "题库管理", type = "查询", description = "查询题库统计信息", recordParams = false)
    @GetMapping("/{id:[0-9]+}/statistics")
    public Result<com.example.exam.dto.QuestionBankStatisticsDTO> statistics(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        com.example.exam.dto.QuestionBankStatisticsDTO statistics = questionBankService.getQuestionBankStatistics(id);
        if (statistics == null) {
            return Result.error("题库不存在");
        }
        return Result.success(statistics);
    }

    @Operation(summary = "导入题目到题库", description = "批量导入题目到指定题库")
    @PostMapping("/{id}/import")
    public Result<Object> importQuestions(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id,
            @Parameter(description = "导入文件内容", required = true) @RequestBody String fileContent) {
        Object result = questionBankService.importQuestions(id, fileContent);
        return Result.success("导入成功", result);
    }

    @Operation(summary = "导出题库题目", description = "导出题库中的所有题目")
    @GetMapping("/{id}/export")
    public Result<Object> exportQuestions(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        Object exportData = questionBankService.exportQuestions(id);
        return Result.success(exportData);
    }
}

