package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.RequirePermission;
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
    @RequirePermission(value = "exam:view", desc = "查看考试")
    @GetMapping("/page")
    public Result<IPage<Exam>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "考试状态（0-草稿,1-已发布,2-进行中,3-已结束,4-已取消）", example = "1") @RequestParam(required = false) Integer status,
            @Parameter(description = "考试标题关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "开始时间（起）") @RequestParam(required = false) LocalDateTime startTimeBegin,
            @Parameter(description = "开始时间（止）") @RequestParam(required = false) LocalDateTime startTimeEnd) {

        // 手动转换枚举
        ExamStatus statusEnum = status != null ? ExamStatus.of(status) : null;

        Page<Exam> page = new Page<>(current, size);
        IPage<Exam> result = examService.pageExams(page, statusEnum, keyword, startTimeBegin, startTimeEnd);
        return Result.success(result);
    }

    @Operation(summary = "查询考试详情", description = "根据ID查询考试的详细信息")
    @RequirePermission(value = "exam:view", desc = "查看考试")
    @GetMapping("/{id}")
    public Result<Exam> getById(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        Exam exam = examService.getById(id);
        return exam != null ? Result.success(exam) : Result.error("考试不存在");
    }

    @Operation(summary = "创建考试", description = "创建新的考试，指定试卷、时间、参与人等信息")
    @RequirePermission(value = "exam:create", desc = "创建考试")
    @PostMapping
    public Result<Long> create(
            @Parameter(description = "考试信息", required = true) @RequestBody Exam exam) {
        boolean success = examService.save(exam);
        return success ? Result.success("创建成功", exam.getExamId()) : Result.error("创建失败");
    }

    @Operation(summary = "更新考试", description = "更新考试信息（仅未开始的考试可更新）")
    @RequirePermission(value = "exam:update", desc = "更新考试")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "考试信息", required = true) @RequestBody Exam exam) {
        exam.setExamId(id);
        boolean success = examService.updateById(exam);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除考试", description = "删除考试（仅未开始的考试可删除）")
    @RequirePermission(value = "exam:delete", desc = "删除考试")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "发布考试", description = "将草稿状态的考试发布，参与人员将收到通知")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @PostMapping("/{id}/publish")
    public Result<Void> publish(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.publishExam(id);
        return success ? Result.success() : Result.error("发布失败");
    }

    @Operation(summary = "开始考试", description = "手动开始考试（提前开考或延迟开考）")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @PostMapping("/{id}/start")
    public Result<Void> start(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.startExam(id);
        return success ? Result.success() : Result.error("启动失败");
    }

    @Operation(summary = "结束考试", description = "手动结束考试（提前结束或延迟结束）")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @PostMapping("/{id}/end")
    public Result<Void> end(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.endExam(id);
        return success ? Result.success() : Result.error("结束失败");
    }

    @Operation(summary = "取消考试", description = "取消考试")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @PostMapping("/{id}/cancel")
    public Result<Void> cancel(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        boolean success = examService.cancelExam(id);
        return success ? Result.success() : Result.error("取消失败");
    }

    @Operation(summary = "复制考试", description = "复制现有考试，创建新的考试")
    @PostMapping("/{id}/copy")
    public Result<Long> copy(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "新考试标题", required = true) @RequestParam String newTitle) {
        Long newExamId = examService.copyExam(id, newTitle);
        return newExamId != null ? Result.success("复制成功", newExamId) : Result.error("复制失败");
    }

    @Operation(summary = "考试监控", description = "实时查看考试进行状态，包括参与人数、提交情况等")
    @GetMapping("/{id}/monitor")
    public Result<com.example.exam.dto.ExamMonitorDTO> monitor(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        com.example.exam.dto.ExamMonitorDTO monitorData = examService.getExamMonitorData(id);
        return Result.success(monitorData);
    }

    @Operation(summary = "考试统计", description = "查看考试的统计数据，包括成绩分布、平均分等")
    @GetMapping("/{id}/statistics")
    public Result<com.example.exam.dto.ExamStatisticsDTO> statistics(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        com.example.exam.dto.ExamStatisticsDTO statistics = examService.getExamStatistics(id);
        return statistics != null ? Result.success(statistics) : Result.error("获取统计信息失败");
    }

    @Operation(summary = "查询考生的考试列表", description = "根据考生ID查询其可参与的考试列表")
    @GetMapping("/user/{userId}")
    public Result<java.util.List<Exam>> getUserExams(
            @Parameter(description = "考生ID", required = true) @PathVariable Long userId,
            @Parameter(description = "组织ID") @RequestParam(required = false) Long orgId) {
        java.util.List<Exam> exams = examService.getExamsByUser(userId, orgId);
        return Result.success(exams);
    }

    @Operation(summary = "获取当前学生的考试列表", description = "获取当前登录学生可参加的考试列表")
    @GetMapping("/my-exams")
    public Result<java.util.List<com.example.exam.dto.ExamDTO>> getMyExams(
            @Parameter(description = "考试状态筛选", example = "1") @RequestParam(required = false) Integer status) {
        // TODO: 从认证信息中获取当前用户ID
        Long userId = 1L;
        ExamStatus statusEnum = status != null ? ExamStatus.of(status) : null;
        java.util.List<com.example.exam.dto.ExamDTO> exams = examService.getMyExams(userId, statusEnum);
        return Result.success(exams);
    }

    @Operation(summary = "学生进入考试", description = "学生点击进入考试，创建考试会话")
    @PostMapping("/{id}/enter")
    public Result<String> enterExam(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        // TODO: 从认证信息中获取当前用户ID
        Long userId = 1L;
        String sessionId = examService.enterExam(id, userId);
        return sessionId != null ? Result.success("进入考试成功", sessionId) : Result.error("无法进入考试");
    }

    @Operation(summary = "获取考试的考生列表", description = "查询参加该考试的所有考生信息")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @GetMapping("/{id}/students")
    public Result<java.util.List<com.example.exam.dto.ExamUserDTO>> getExamStudents(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id) {
        java.util.List<com.example.exam.dto.ExamUserDTO> students = examService.getExamStudents(id);
        return Result.success(students);
    }

    @Operation(summary = "添加考生到考试", description = "批量添加考生到考试")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @PostMapping("/{id}/students")
    public Result<Void> addStudentsToExam(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "用户ID列表", required = true) @RequestBody java.util.Map<String, java.util.List<Long>> request) {
        java.util.List<Long> userIds = request.get("userIds");
        if (userIds == null || userIds.isEmpty()) {
            return Result.error("请选择至少一个考生");
        }
        boolean success = examService.addStudentsToExam(id, userIds);
        return success ? Result.success("添加成功") : Result.error("添加失败");
    }

    @Operation(summary = "移除考生", description = "从考试中移除某个考生")
    @RequirePermission(value = "exam:manage", desc = "管理考试")
    @DeleteMapping("/{id}/students/{userId}")
    public Result<Void> removeStudent(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "用户ID", required = true) @PathVariable Long userId) {
        boolean success = examService.removeStudentFromExam(id, userId);
        return success ? Result.success("移除成功") : Result.error("移除失败");
    }

    @Operation(summary = "检查考试权限", description = "检查指定用户是否有权限参加该考试")
    @GetMapping("/{id}/students/check-permission")
    public Result<Boolean> checkExamPermission(
            @Parameter(description = "考试ID", required = true) @PathVariable Long id,
            @Parameter(description = "用户ID", required = true) @RequestParam Long userId) {
        boolean hasPermission = examService.checkExamPermission(id, userId);
        return Result.success(hasPermission);
    }
}

