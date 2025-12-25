package com.example.exam.controller;

import com.example.exam.common.result.Result;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.service.ExamAnswerService;
import com.example.exam.service.ExamSessionService;
import com.example.exam.service.ExamUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 学生答卷Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
@Tag(name = "学生答卷", description = "学生参加考试、答题、提交等功能")
@RestController
@RequestMapping("/api/student/exam")
@RequiredArgsConstructor
public class StudentExamController {

    private final ExamSessionService examSessionService;
    private final ExamAnswerService examAnswerService;
    private final ExamUserService examUserService;

    @Operation(summary = "开始考试", description = "学生开始考试，创建考试会话")
    @PostMapping("/{examId}/start")
    public Result<ExamSession> startExam(
            @Parameter(description = "考试ID", required = true) @PathVariable Long examId,
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId) {

        // TODO: 从当前登录用户获取 userId
        if (userId == null) {
            userId = 1L; // 临时使用固定值
        }

        // 检查考试权限
        boolean hasPermission = examUserService.hasExamPermission(examId, userId);
        if (!hasPermission) {
            return Result.error("您没有参加该考试的权限");
        }

        // 开始考试
        ExamSession session = examSessionService.startExam(examId, userId);
        if (session == null) {
            return Result.error("开始考试失败，请检查考试状态和时间");
        }

        return Result.success(session);
    }

    @Operation(summary = "获取考试会话信息", description = "获取当前考试会话的详细信息")
    @GetMapping("/session/{sessionId}")
    public Result<ExamSession> getSession(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        ExamSession session = examSessionService.getById(sessionId);
        return session != null ? Result.success(session) : Result.error("会话不存在");
    }

    @Operation(summary = "保存单个答案", description = "保存学生对某道题的答案")
    @PostMapping("/session/{sessionId}/answer")
    public Result<Void> saveAnswer(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "答案", required = true) @RequestBody ExamAnswer answer) {

        // 设置会话ID
        answer.setSessionId(sessionId);

        boolean success = examAnswerService.saveAnswer(answer);
        return success ? Result.success("保存成功") : Result.error("保存失败");
    }

    @Operation(summary = "批量保存答案", description = "批量保存多道题的答案")
    @PostMapping("/session/{sessionId}/answers")
    public Result<Void> saveAnswers(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "答案列表", required = true) @RequestBody Map<String, List<ExamAnswer>> request) {

        List<ExamAnswer> answers = request.get("answers");
        if (answers == null || answers.isEmpty()) {
            return Result.error("答案列表不能为空");
        }

        // 设置会话ID
        answers.forEach(answer -> answer.setSessionId(sessionId));

        boolean success = examAnswerService.saveAnswers(answers);
        return success ? Result.success("保存成功") : Result.error("保存失败");
    }

    @Operation(summary = "获取答案列表", description = "获取学生在当前会话中的所有答案")
    @GetMapping("/session/{sessionId}/answers")
    public Result<List<ExamAnswer>> getAnswers(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        List<ExamAnswer> answers = examAnswerService.getSessionAnswers(sessionId);
        return Result.success(answers);
    }

    @Operation(summary = "获取单个答案", description = "获取学生对某道题的答案")
    @GetMapping("/session/{sessionId}/answer/{questionId}")
    public Result<ExamAnswer> getAnswer(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "题目ID", required = true) @PathVariable Long questionId) {
        ExamAnswer answer = examAnswerService.getAnswer(sessionId, questionId);
        return Result.success(answer);
    }

    @Operation(summary = "提交考试", description = "学生提交考试，结束答题")
    @PostMapping("/session/{sessionId}/submit")
    public Result<Void> submitExam(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {

        // 提交考试
        boolean success = examSessionService.submitExam(sessionId);
        if (!success) {
            return Result.error("提交失败");
        }

        // 自动批改客观题
        examAnswerService.autoGradeObjectiveQuestions(sessionId);

        return Result.success("提交成功");
    }

    @Operation(summary = "记录切屏", description = "记录学生切屏行为")
    @PostMapping("/session/{sessionId}/tab-switch")
    public Result<Integer> recordTabSwitch(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        int count = examSessionService.recordTabSwitch(sessionId);
        return count > 0 ? Result.success("记录成功", count) : Result.error("记录失败");
    }

    @Operation(summary = "心跳", description = "保持会话活跃状态")
    @PostMapping("/session/{sessionId}/heartbeat")
    public Result<Void> heartbeat(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        // TODO: 实现心跳逻辑
        return Result.success();
    }

    @Operation(summary = "获取考试进度", description = "获取学生的答题进度")
    @GetMapping("/session/{sessionId}/progress")
    public Result<Map<String, Object>> getProgress(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {
        // TODO: 实现进度统计逻辑
        // 返回：总题数、已答题数、未答题数、已标记题数等
        return Result.success();
    }
}

