package com.example.exam.controller;

import com.example.exam.common.result.Result;
import com.example.exam.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 统计分析Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "统计分析", description = "考试数据统计、成绩分析、报表生成功能")
@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
public class StatisticsController {

    private final StatisticsService statisticsService;

    @Operation(summary = "考试统计概览", description = "获取考试的整体统计数据")
    @GetMapping("/exam/{examId}/overview")
    public Result<Object> examOverview(
            @Parameter(description = "考试ID", required = true) @PathVariable Long examId) {
        Object overview = statisticsService.getExamOverview(examId);
        return Result.success(overview);
    }

    @Operation(summary = "成绩分布", description = "查询考试成绩的分布情况（分数段统计）")
    @GetMapping("/exam/{examId}/score-distribution")
    public Result<Object> scoreDistribution(
            @Parameter(description = "考试ID", required = true) @PathVariable Long examId) {
        Object distribution = statisticsService.getScoreDistribution(examId);
        return Result.success(distribution);
    }

    @Operation(summary = "题目统计", description = "统计题目的答题情况（正确率、平均分等）")
    @GetMapping("/question/{questionId}")
    public Result<Object> questionStatistics(
            @Parameter(description = "题目ID", required = true) @PathVariable Long questionId,
            @Parameter(description = "考试ID（可选）") @RequestParam(required = false) Long examId) {
        Object statistics = statisticsService.getQuestionStatistics(questionId, examId);
        return Result.success(statistics);
    }

    @Operation(summary = "知识点掌握度", description = "分析学生对各知识点的掌握情况")
    @GetMapping("/knowledge-mastery")
    public Result<Object> knowledgeMastery(
            @Parameter(description = "学生ID") @RequestParam(required = false) Long userId,
            @Parameter(description = "题库ID") @RequestParam(required = false) Long bankId) {
        Object mastery = statisticsService.getKnowledgeMastery(userId, bankId);
        return Result.success(mastery);
    }

    @Operation(summary = "学生成绩报告", description = "生成学生的详细成绩报告")
    @GetMapping("/student/{userId}/report")
    public Result<Object> studentReport(
            @Parameter(description = "学生ID", required = true) @PathVariable Long userId,
            @Parameter(description = "考试ID") @RequestParam(required = false) Long examId,
            @Parameter(description = "开始时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Object report = statisticsService.getStudentReport(userId, examId, startTime, endTime);
        return Result.success(report);
    }

    @Operation(summary = "班级成绩对比", description = "对比不同班级/组织的成绩情况")
    @GetMapping("/class-comparison")
    public Result<Object> classComparison(
            @Parameter(description = "考试ID", required = true) @RequestParam Long examId,
            @Parameter(description = "班级/组织ID列表", required = true) @RequestParam Long[] organizationIds) {
        Object comparison = statisticsService.getClassComparison(examId, organizationIds);
        return Result.success(comparison);
    }

    @Operation(summary = "考试趋势分析", description = "分析学生成绩的趋势变化")
    @GetMapping("/trend/{userId}")
    public Result<Object> trendAnalysis(
            @Parameter(description = "学生ID", required = true) @PathVariable Long userId,
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Object trend = statisticsService.getTrendAnalysis(userId, startTime, endTime);
        return Result.success(trend);
    }

    @Operation(summary = "题库质量分析", description = "分析题库中题目的质量（区分度、难度等）")
    @GetMapping("/bank/{bankId}/quality")
    public Result<Object> bankQualityAnalysis(
            @Parameter(description = "题库ID", required = true) @PathVariable Long bankId) {
        Object analysis = statisticsService.getBankQualityAnalysis(bankId);
        return Result.success(analysis);
    }

    @Operation(summary = "系统使用统计", description = "统计系统的使用情况")
    @GetMapping("/system-usage")
    public Result<Object> systemUsage(
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Object usage = statisticsService.getSystemUsage(startTime, endTime);
        return Result.success(usage);
    }

    @Operation(summary = "导出统计报表", description = "导出统计数据为Excel报表")
    @GetMapping("/export/{type}")
    public Result<Object> exportReport(
            @Parameter(description = "报表类型", required = true) @PathVariable String type,
            @Parameter(description = "考试ID") @RequestParam(required = false) Long examId,
            @Parameter(description = "开始时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Object exportData = statisticsService.exportReport(type, examId, startTime, endTime);
        return Result.success("导出成功", exportData);
    }

    @Operation(summary = "仪表盘数据", description = "获取首页仪表盘展示的关键数据")
    @GetMapping("/dashboard")
    public Result<Object> dashboard(
            @Parameter(description = "用户ID", required = true) @RequestParam Long userId,
            @Parameter(description = "用户角色") @RequestParam String role) {
        Object dashboardData = statisticsService.getDashboardData(userId, role);
        return Result.success(dashboardData);
    }
}

