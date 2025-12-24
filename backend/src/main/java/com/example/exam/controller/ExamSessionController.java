package com.example.exam.controller;

import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.result.Result;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.service.ExamSessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 考试会话Controller（学生考试）
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "考试会话", description = "学生参加考试、答题、提交等功能")
@RestController
@RequestMapping("/api/exam-session")
@RequiredArgsConstructor
public class ExamSessionController {

    private final ExamSessionService examSessionService;

    @Operation(summary = "创建考试会话", description = "学生开始考试，创建考试会话")
    @RequirePermission(value = "student:exam:take", desc = "参加考试")
    @PostMapping
    public Result<String> createSession(@RequestBody java.util.Map<String, Object> params) {
        Long examId = Long.valueOf(params.get("examId").toString());
        // TODO: 从认证信息中获取userId
        Long userId = 1L;

        ExamSession session = examSessionService.startExam(examId, userId);
        return session != null ? Result.success("考试开始", session.getSessionId()) : Result.error("无法开始考试");
    }

    @Operation(summary = "开始考试", description = "学生开始考试，创建考试会话")
    @RequirePermission(value = "student:exam:take", desc = "参加考试")
    @PostMapping("/start")
    public Result<ExamSession> startExam(
            @Parameter(description = "考试ID", required = true) @RequestParam Long examId,
            @Parameter(description = "学生ID", required = true) @RequestParam Long userId) {
        ExamSession session = examSessionService.startExam(examId, userId);
        return session != null ? Result.success("考试开始", session) : Result.error("无法开始考试");
    }

    @Operation(summary = "获取考试会话", description = "获取当前考试会话信息")
    @RequirePermission(value = "student:exam:view", desc = "查看考试")
    @GetMapping("/{sessionId}")
    public Result<ExamSession> getSession(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        ExamSession session = examSessionService.getById(sessionId);
        return session != null ? Result.success(session) : Result.error("会话不存在");
    }

    @Operation(summary = "保存答案", description = "保存单题答案（自动保存）")
    @RequirePermission(value = "student:exam:answer", desc = "提交答案")
    @PostMapping("/{sessionId}/answer")
    public Result<Void> saveAnswer(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "答案信息", required = true) @RequestBody ExamAnswer answer) {
        boolean success = examSessionService.saveAnswer(sessionId, answer);
        return success ? Result.success() : Result.error("保存失败");
    }

    @Operation(summary = "批量保存答案", description = "批量保存多题答案")
    @RequirePermission(value = "student:exam:answer", desc = "提交答案")
    @PostMapping("/{sessionId}/answers")
    public Result<Void> saveAnswers(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "答案列表", required = true) @RequestBody List<ExamAnswer> answers) {
        boolean success = examSessionService.saveAnswers(sessionId, answers);
        return success ? Result.success() : Result.error("保存失败");
    }

    @Operation(summary = "提交考试", description = "学生提交考试，触发自动阅卷")
    @RequirePermission(value = "student:exam:submit", desc = "提交试卷")
    @PostMapping("/{sessionId}/submit")
    public Result<Void> submitExam(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        boolean success = examSessionService.submitExam(sessionId);
        return success ? Result.success() : Result.error("提交失败");
    }

    @Operation(summary = "暂停考试", description = "暂停考试（如需中途离开）")
    @RequirePermission(value = "student:exam:take", desc = "参加考试")
    @PostMapping("/{sessionId}/pause")
    public Result<Void> pauseExam(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        boolean success = examSessionService.pauseExam(sessionId);
        return success ? Result.success() : Result.error("暂停失败");
    }

    @Operation(summary = "恢复考试", description = "恢复暂停的考试")
    @RequirePermission(value = "student:exam:take", desc = "参加考试")
    @PostMapping("/{sessionId}/resume")
    public Result<Void> resumeExam(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        boolean success = examSessionService.resumeExam(sessionId);
        return success ? Result.success() : Result.error("恢复失败");
    }

    @Operation(summary = "查询考试成绩", description = "查询考试成绩和答题详情")
    @RequirePermission(value = "student:exam:view", desc = "查看考试")
    @GetMapping("/{sessionId}/result")
    public Result<Object> getResult(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        Object result = examSessionService.getExamResult(sessionId);
        return result != null ? Result.success(result) : Result.error("成绩未出");
    }

    @Operation(summary = "查询我的考试列表", description = "查询当前用户的所有考试记录")
    @GetMapping("/my-exams")
    public Result<List<ExamSession>> myExams(
            @Parameter(description = "用户ID", required = true) @RequestParam Long userId) {
        List<ExamSession> sessions = examSessionService.getMyExamSessions(userId);
        return Result.success(sessions);
    }

    @Operation(summary = "考试倒计时", description = "获取考试剩余时间（秒）")
    @GetMapping("/{sessionId}/remaining-time")
    public Result<Long> getRemainingTime(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        Long remainingSeconds = examSessionService.getRemainingTime(sessionId);
        return Result.success(remainingSeconds);
    }

    @Operation(summary = "标记题目", description = "标记题目（待检查、疑问等）")
    @PostMapping("/{sessionId}/mark-question")
    public Result<Void> markQuestion(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "题目ID", required = true) @RequestParam Long questionId,
            @Parameter(description = "标记类型", required = true) @RequestParam String markType) {
        boolean success = examSessionService.markQuestion(sessionId, questionId, markType);
        return success ? Result.success() : Result.error("标记失败");
    }

    @Operation(summary = "记录切屏", description = "记录考生切屏行为")
    @PostMapping("/{sessionId}/tab-switch")
    public Result<Integer> recordTabSwitch(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        int count = examSessionService.recordTabSwitch(sessionId);
        return Result.success("切屏次数", count);
    }

    @Operation(summary = "心跳", description = "保持在线状态")
    @PostMapping("/{sessionId}/heartbeat")
    public Result<Void> heartbeat(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        examSessionService.updateHeartbeat(sessionId);
        return Result.success();
    }
}

