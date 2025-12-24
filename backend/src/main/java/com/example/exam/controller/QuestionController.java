package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyLevel;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.common.result.Result;
import com.example.exam.entity.question.Question;
import com.example.exam.service.QuestionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 题目Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "题目管理", description = "题目的增删改查、审核等操作")
@RestController
@RequestMapping("/api/question")
@RequiredArgsConstructor
@lombok.extern.slf4j.Slf4j
public class QuestionController {

    private final QuestionService questionService;

    @Operation(summary = "分页查询题目", description = "支持多条件筛选的题目分页查询")
    @com.example.exam.annotation.OperationLog(module = "题目管理", type = "查询", description = "分页查询题目", recordParams = false)
    @GetMapping("/page")
    public Result<IPage<Question>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "题库ID") @RequestParam(required = false) Long bankId,
            @Parameter(description = "题型") @RequestParam(required = false) QuestionType questionType,
            @Parameter(description = "难度") @RequestParam(required = false) DifficultyLevel difficulty,
            @Parameter(description = "审核状态") @RequestParam(required = false) AuditStatus auditStatus,
            @Parameter(description = "知识点ID") @RequestParam(required = false) Long knowledgeId,
            @Parameter(description = "关键词（题目内容）") @RequestParam(required = false) String keyword) {

        Page<Question> page = new Page<>(current, size);
        IPage<Question> result = questionService.pageQuestions(
                page, bankId, questionType, difficulty, auditStatus, knowledgeId, keyword);

        return Result.success(result);
    }

    @Operation(summary = "查询题目详情", description = "根据ID查询题目详情，包含所有选项信息")
    @GetMapping("/{id}")
    public Result<Question> getById(
            @Parameter(description = "题目ID", required = true, example = "1") @PathVariable Long id) {
        List<Question> questions = questionService.getQuestionsWithOptions(List.of(id));
        if (questions.isEmpty()) {
            return Result.error("题目不存在");
        }
        return Result.success(questions.get(0));
    }

    @Operation(summary = "创建题目", description = "创建新题目，支持8种题型")
    @com.example.exam.annotation.OperationLog(module = "题目管理", type = "创建", description = "创建题目")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "题目信息", required = true) @RequestBody Question question) {
        boolean success = questionService.save(question);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "更新题目", description = "根据ID更新题目信息")
    @com.example.exam.annotation.OperationLog(module = "题目管理", type = "更新", description = "更新题目")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id,
            @Parameter(description = "题目信息", required = true) @RequestBody Question question) {
        question.setQuestionId(id);
        boolean success = questionService.updateById(question);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除题目", description = "逻辑删除题目（软删除）")
    @com.example.exam.annotation.OperationLog(module = "题目管理", type = "删除", description = "删除题目")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id) {
        boolean success = questionService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "审核题目", description = "对题目进行审核（通过/拒绝）")
    @com.example.exam.annotation.OperationLog(module = "题目管理", type = "审核", description = "审核题目")
    @PostMapping("/{id}/audit")
    public Result<Void> audit(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id,
            @Parameter(description = "审核状态", required = true) @RequestParam AuditStatus auditStatus,
            @Parameter(description = "审核备注") @RequestParam(required = false) String remark,
            @Parameter(description = "审核人ID", required = true) @RequestParam Long auditorId) {

        boolean success = questionService.auditQuestion(id, auditStatus, remark, auditorId);
        return success ? Result.success() : Result.error("审核失败");
    }
}

