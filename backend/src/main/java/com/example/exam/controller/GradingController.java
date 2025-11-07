package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.result.Result;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.service.GradingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 阅卷管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "阅卷管理", description = "主观题人工阅卷、成绩复核等功能")
@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
public class GradingController {

    private final GradingService gradingService;

    @Operation(summary = "查询待阅卷答题", description = "分页查询需要人工阅卷的主观题答案")
    @GetMapping("/pending")
    public Result<IPage<ExamAnswer>> getPending(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "考试ID") @RequestParam(required = false) Long examId,
            @Parameter(description = "题目ID") @RequestParam(required = false) Long questionId,
            @Parameter(description = "阅卷教师ID") @RequestParam(required = false) Long teacherId) {

        Page<ExamAnswer> page = new Page<>(current, size);
        IPage<ExamAnswer> result = gradingService.getPendingAnswers(page, examId, questionId, teacherId);
        return Result.success(result);
    }

    @Operation(summary = "阅卷", description = "对主观题进行人工评分和批注")
    @PostMapping("/grade")
    public Result<Void> grade(
            @Parameter(description = "答案ID", required = true) @RequestParam Long answerId,
            @Parameter(description = "得分", required = true) @RequestParam Double score,
            @Parameter(description = "批注/评语") @RequestParam(required = false) String comment,
            @Parameter(description = "阅卷教师ID", required = true) @RequestParam Long teacherId) {

        boolean success = gradingService.gradeAnswer(answerId, score, comment, teacherId);
        return success ? Result.success() : Result.error("阅卷失败");
    }

    @Operation(summary = "批量阅卷", description = "批量对多个答案进行评分")
    @PostMapping("/batch-grade")
    public Result<Object> batchGrade(
            @Parameter(description = "批量阅卷数据", required = true) @RequestBody List<Object> gradeData) {
        Object result = gradingService.batchGrade(gradeData);
        return Result.success("批量阅卷完成", result);
    }

    @Operation(summary = "查询我的阅卷任务", description = "查询分配给我的阅卷任务")
    @GetMapping("/my-tasks")
    public Result<List<Object>> myTasks(
            @Parameter(description = "教师ID", required = true) @RequestParam Long teacherId) {
        List<Object> tasks = gradingService.getMyGradingTasks(teacherId);
        return Result.success(tasks);
    }

    @Operation(summary = "分配阅卷任务", description = "将主观题答案分配给指定教师阅卷")
    @PostMapping("/assign")
    public Result<Void> assignTask(
            @Parameter(description = "考试ID", required = true) @RequestParam Long examId,
            @Parameter(description = "题目ID", required = true) @RequestParam Long questionId,
            @Parameter(description = "教师ID列表", required = true) @RequestBody Long[] teacherIds) {
        boolean success = gradingService.assignGradingTask(examId, questionId, teacherIds);
        return success ? Result.success() : Result.error("分配失败");
    }

    @Operation(summary = "阅卷进度", description = "查询考试的阅卷进度统计")
    @GetMapping("/progress/{examId}")
    public Result<Object> progress(
            @Parameter(description = "考试ID", required = true) @PathVariable Long examId) {
        Object progress = gradingService.getGradingProgress(examId);
        return Result.success(progress);
    }

    @Operation(summary = "成绩复核", description = "申请成绩复核")
    @PostMapping("/review-request")
    public Result<Void> reviewRequest(
            @Parameter(description = "会话ID", required = true) @RequestParam Long sessionId,
            @Parameter(description = "题目ID", required = true) @RequestParam Long questionId,
            @Parameter(description = "复核理由", required = true) @RequestParam String reason) {
        boolean success = gradingService.requestReview(sessionId, questionId, reason);
        return success ? Result.success() : Result.error("申请失败");
    }

    @Operation(summary = "处理复核申请", description = "教师处理学生的成绩复核申请")
    @PostMapping("/review-handle")
    public Result<Void> handleReview(
            @Parameter(description = "复核申请ID", required = true) @RequestParam Long reviewId,
            @Parameter(description = "是否通过", required = true) @RequestParam Boolean approved,
            @Parameter(description = "新得分（如果通过）") @RequestParam(required = false) Double newScore,
            @Parameter(description = "处理意见", required = true) @RequestParam String opinion,
            @Parameter(description = "处理人ID", required = true) @RequestParam Long handlerId) {

        boolean success = gradingService.handleReview(reviewId, approved, newScore, opinion, handlerId);
        return success ? Result.success() : Result.error("处理失败");
    }

    @Operation(summary = "查询复核申请列表", description = "查询成绩复核申请列表")
    @GetMapping("/reviews")
    public Result<IPage<Object>> getReviews(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "考试ID") @RequestParam(required = false) Long examId,
            @Parameter(description = "处理状态") @RequestParam(required = false) String status) {

        Page<Object> page = new Page<>(current, size);
        IPage<Object> result = gradingService.getReviewRequests(page, examId, status);
        return Result.success(result);
    }
}

