package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.common.result.Result;
import com.example.exam.entity.exam.Exam;
import com.example.exam.service.ExamService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 考试管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "考试管理", description = "考试的创建、发布、监控等管理功能")
@RestController
@RequestMapping("/api/exam")
@RequiredArgsConstructor
public class ExamController {

    private final ExamService examService;

    @Operation(summary = "分页查询考试", description = "支持按状态、时间范围等条件筛选考试列表")
    @GetMapping("/page")
    public Result<IPage<Exam>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "考试状态") @RequestParam(required = false) ExamStatus status,
            @Parameter(description = "考试标题关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "开始时间（起）") @RequestParam(required = false) LocalDateTime startTimeBegin,
            @Parameter(description = "开始时间（止）") @RequestParam(required = false) LocalDateTime startTimeEnd) {

        Page<Exam> page = new Page<>(current, size);
        IPage<Exam> result = examService.pageExams(page, status, keyword, startTimeBegin, startTimeEnd);
        return Result.success(result);
    }

    @Operation(summary = "查询考试详情", description = "根据ID查询考试的详细信息")
    @GetMapping("/{id}")
    public Result<Exam> getById(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        Exam exam = examService.getById(id);
        return exam != null ? Result.success(exam) : Result.error("考试不存在");
    }

    @Operation(summary = "创建考试", description = "创建新的考试，指定试卷、时间、参与人等信息")
    @PostMapping
    public Result<Long> create(
            @Parameter(description = "考试信息", required = true) @RequestBody Exam exam) {
        boolean success = examService.save(exam);
        return success ? Result.success("创建成功", exam.getExamId()) : Result.error("创建失败");
    }

    @Operation(summary = "更新考试", description = "更新考试信息（仅未开始的考试可更新）")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "考试信息", required = true) @RequestBody Exam exam) {
        exam.setExamId(id);
        boolean success = examService.updateById(exam);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除考试", description = "删除考试（仅未开始的考试可删除）")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "发布考试", description = "将草稿状态的考试发布，参与人员将收到通知")
    @PostMapping("/{id}/publish")
    public Result<Void> publish(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.publishExam(id);
        return success ? Result.success() : Result.error("发布失败");
    }

    @Operation(summary = "开始考试", description = "手动开始考试（提前开考或延迟开考）")
    @PostMapping("/{id}/start")
    public Result<Void> start(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.startExam(id);
        return success ? Result.success() : Result.error("启动失败");
    }

    @Operation(summary = "结束考试", description = "手动结束考试（提前结束或延迟结束）")
    @PostMapping("/{id}/end")
    public Result<Void> end(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.endExam(id);
        return success ? Result.success() : Result.error("结束失败");
    }

    @Operation(summary = "考试监控", description = "实时查看考试进行状态，包括参与人数、提交情况等")
    @GetMapping("/{id}/monitor")
    public Result<Object> monitor(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        Object monitorData = examService.getExamMonitorData(id);
        return Result.success(monitorData);
    }

    @Operation(summary = "考试统计", description = "查看考试的统计数据，包括成绩分布、平均分等")
    @GetMapping("/{id}/statistics")
    public Result<Object> statistics(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        Object statistics = examService.getExamStatistics(id);
        return Result.success(statistics);
    }
}

