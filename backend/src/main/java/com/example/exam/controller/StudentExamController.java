package com.example.exam.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.exam.common.result.Result;
import com.example.exam.dto.ExamSessionDetailDTO;
import com.example.exam.dto.ViolationRequest;
import com.example.exam.entity.exam.*;
import com.example.exam.entity.paper.Paper;
import com.example.exam.entity.paper.PaperQuestion;
import com.example.exam.entity.question.Question;
import com.example.exam.entity.question.QuestionOption;
import com.example.exam.mapper.exam.ExamMapper;
import com.example.exam.mapper.exam.ExamViolationMapper;
import com.example.exam.mapper.paper.PaperMapper;
import com.example.exam.mapper.paper.PaperQuestionMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.mapper.question.QuestionOptionMapper;
import com.example.exam.service.ExamAnswerService;
import com.example.exam.service.ExamSessionService;
import com.example.exam.service.ExamUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学生答卷Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
@Slf4j
@Tag(name = "学生答卷", description = "学生参加考试、答题、提交等功能")
@RestController
@RequestMapping("/api/student/exam")
@RequiredArgsConstructor
public class StudentExamController {

    private final ExamSessionService examSessionService;
    private final ExamAnswerService examAnswerService;
    private final ExamUserService examUserService;
    private final ExamViolationMapper examViolationMapper;
    private final ExamMapper examMapper;
    private final PaperMapper paperMapper;
    private final PaperQuestionMapper paperQuestionMapper;
    private final QuestionMapper questionMapper;
    private final QuestionOptionMapper questionOptionMapper;

    @Operation(summary = "开始考试", description = "学生开始考试，创建考试会话")
    @PostMapping("/{examId}/start")
    public Result<ExamSession> startExam(
            @Parameter(description = "考试ID", required = true) @PathVariable Long examId,
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId) {



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

    @Operation(summary = "获取考试会话信息", description = "获取当前考试会话的详细信息，包括题目列表")
    @GetMapping("/session/{sessionId}")
    public Result<ExamSessionDetailDTO> getSession(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {

        // 1. 获取会话信息
        ExamSession session = examSessionService.getById(sessionId);
        if (session == null) {
            return Result.error("会话不存在");
        }

        // 2. 获取考试信息
        Exam exam = examMapper.selectById(session.getExamId());
        if (exam == null) {
            return Result.error("考试不存在");
        }

        // 3. 获取试卷信息
        Paper paper = paperMapper.selectById(exam.getPaperId());
        String paperName = paper != null ? paper.getPaperName() : "未知试卷";

        // 4. 获取试卷题目列表
        LambdaQueryWrapper<PaperQuestion> pqWrapper = new LambdaQueryWrapper<>();
        pqWrapper.eq(PaperQuestion::getPaperId, exam.getPaperId())
                 .orderByAsc(PaperQuestion::getSortOrder);
        List<PaperQuestion> paperQuestions = paperQuestionMapper.selectList(pqWrapper);

        // 5. 获取题目详情和选项
        List<ExamSessionDetailDTO.QuestionDetailDTO> questionDTOs = new ArrayList<>();
        for (PaperQuestion pq : paperQuestions) {
            Question question = questionMapper.selectById(pq.getQuestionId());
            if (question == null) continue;

            // 获取选项
            LambdaQueryWrapper<QuestionOption> optWrapper = new LambdaQueryWrapper<>();
            optWrapper.eq(QuestionOption::getQuestionId, question.getQuestionId())
                      .orderByAsc(QuestionOption::getOptionSeq);
            List<QuestionOption> options = questionOptionMapper.selectList(optWrapper);

            List<ExamSessionDetailDTO.OptionDTO> optionDTOs = new ArrayList<>();
            for (QuestionOption opt : options) {
                ExamSessionDetailDTO.OptionDTO optionDTO = ExamSessionDetailDTO.OptionDTO.builder()
                        .optionId(opt.getOptionId())
                        .optionKey(opt.getOptionSeq())
                        .optionContent(opt.getOptionContent())
                        .build();
                optionDTOs.add(optionDTO);
            }

            // 计算填空题空格数（根据answerList中的|分隔符计算）
            Integer blankCount = null;
            if (question.getAnswerList() != null && !question.getAnswerList().isEmpty()) {
                blankCount = question.getAnswerList().split("\\|").length;
            }

            ExamSessionDetailDTO.QuestionDetailDTO questionDTO = ExamSessionDetailDTO.QuestionDetailDTO.builder()
                    .questionId(question.getQuestionId())
                    .questionType(question.getQuestionType() != null ? question.getQuestionType().name() : "SINGLE_CHOICE")
                    .questionContent(question.getQuestionContent())
                    .defaultScore(pq.getQuestionScore() != null ? pq.getQuestionScore().intValue() :
                                  (question.getDefaultScore() != null ? question.getDefaultScore().intValue() : 0))
                    .blankCount(blankCount)
                    .options(optionDTOs)
                    .sortOrder(pq.getSortOrder())
                    .build();

            questionDTOs.add(questionDTO);
        }

        // 6. 获取已保存的答案
        List<ExamAnswer> answers = examAnswerService.getSessionAnswers(sessionId);

        // 7. 获取违规记录
        LambdaQueryWrapper<ExamViolation> vWrapper = new LambdaQueryWrapper<>();
        vWrapper.eq(ExamViolation::getSessionId, sessionId);
        List<ExamViolation> violations = examViolationMapper.selectList(vWrapper);

        // 8. 构建返回DTO
        ExamSessionDetailDTO.ExamInfoDTO examInfoDTO = ExamSessionDetailDTO.ExamInfoDTO.builder()
                .examId(exam.getExamId())
                .examName(exam.getExamName())
                .description(exam.getDescription())
                .paperName(paperName)
                .duration(exam.getDuration())
                .startTime(exam.getStartTime() != null ? exam.getStartTime().toString() : null)
                .endTime(exam.getEndTime() != null ? exam.getEndTime().toString() : null)
                .totalScore(paper != null && paper.getTotalScore() != null ? paper.getTotalScore().intValue() : 100)
                .cutScreenLimit(exam.getCutScreenLimit())
                .cutScreenTimer(exam.getCutScreenTimer())
                .forbidCopy(exam.getForbidCopy())
                .singleDevice(exam.getSingleDevice())
                .shuffleQuestions(exam.getShuffleQuestions())
                .shuffleOptions(exam.getShuffleOptions())
                .build();

        ExamSessionDetailDTO result = ExamSessionDetailDTO.builder()
                .session(session)
                .examInfo(examInfoDTO)
                .questions(questionDTOs)
                .answers(answers)
                .violations(violations)
                .build();

        return Result.success(result);
    }

    @Operation(summary = "保存单个答案", description = "保存学生对某道题的答案")
    @PostMapping("/session/{sessionId}/answer")
    public Result<Void> saveAnswer(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "答案", required = true) @RequestBody ExamAnswer answer) {

        // 获取会话信息
        ExamSession session = examSessionService.getById(sessionId);
        if (session == null) {
            return Result.error("会话不存在");
        }

        // 设置必要字段
        answer.setSessionId(sessionId);
        answer.setExamId(session.getExamId());
        answer.setUserId(session.getUserId());

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

        // 获取会话信息
        ExamSession session = examSessionService.getById(sessionId);
        if (session == null) {
            return Result.error("会话不存在");
        }

        // 设置必要字段
        answers.forEach(answer -> {
            answer.setSessionId(sessionId);
            answer.setExamId(session.getExamId());
            answer.setUserId(session.getUserId());
        });

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
    public Result<Map<String, Object>> submitExam(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId) {

        try {
            // 检查会话是否存在
            ExamSession session = examSessionService.getById(sessionId);
            if (session == null) {
                return Result.error("会话不存在");
            }

            // 提交考试（独立事务）
            boolean success = examSessionService.submitExam(sessionId);
            if (!success) {
                return Result.error("提交失败，请检查考试状态");
            }

            // 自动批改（独立事务，失败不影响提交）
            try {
                examSessionService.doAutoGrading(sessionId);
            } catch (Exception e) {
                log.warn("自动批改异常，但提交已成功: sessionId={}", sessionId, e);
            }

            // 获取更新后的会话信息
            ExamSession updatedSession = examSessionService.getById(sessionId);

            Map<String, Object> result = new HashMap<>();
            result.put("sessionId", sessionId);
            result.put("status", updatedSession.getSessionStatus());
            result.put("totalScore", updatedSession.getTotalScore());
            result.put("objectiveScore", updatedSession.getObjectiveScore());
            result.put("submitTime", updatedSession.getSubmitTime());

            return Result.success("提交成功", result);
        } catch (Exception e) {
            log.error("提交考试异常: sessionId={}", sessionId, e);
            return Result.error("提交失败: " + e.getMessage());
        }
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

    @Operation(summary = "记录违规行为", description = "记录学生在考试过程中的异常行为")
    @PostMapping("/session/{sessionId}/violation")
    public Result<Map<String, Object>> recordViolation(
            @Parameter(description = "会话ID", required = true) @PathVariable String sessionId,
            @Parameter(description = "违规信息", required = true) @RequestBody ViolationRequest request) {

        try {
            // 获取会话信息
            ExamSession session = examSessionService.getById(sessionId);
            if (session == null) {
                return Result.error("会话不存在");
            }

            // 创建违规记录
            ExamViolation violation = ExamViolation.builder()
                    .sessionId(sessionId)
                    .examId(session.getExamId())
                    .userId(session.getUserId())
                    .violationType(request.getViolationType())
                    .violationDetail(request.getViolationDetail())
                    .severity(request.getSeverity() != null ? request.getSeverity() : 1)
                    .violationTime(parseViolationTime(request.getViolationTime()))
                    .build();

            // 保存违规记录
            int result = examViolationMapper.insert(violation);

            if (result > 0) {
                // 统计总违规次数
                Integer totalViolations = examViolationMapper.countBySessionId(sessionId);

                // 返回结果
                Map<String, Object> data = new HashMap<>();
                data.put("violationId", violation.getId());
                data.put("totalViolations", totalViolations);
                data.put("currentType", request.getViolationType());

                log.info("记录违规: sessionId={}, type={}, total={}", sessionId, request.getViolationType(), totalViolations);

                return Result.success("记录成功", data);
            } else {
                return Result.error("记录失败");
            }
        } catch (Exception e) {
            log.error("记录违规失败: sessionId={}", sessionId, e);
            return Result.error("记录失败: " + e.getMessage());
        }
    }

    /**
     * 解析违规时间
     */
    private LocalDateTime parseViolationTime(String timeStr) {
        if (timeStr == null || timeStr.isEmpty()) {
            return LocalDateTime.now();
        }
        try {
            return LocalDateTime.parse(timeStr, DateTimeFormatter.ISO_DATE_TIME);
        } catch (Exception e) {
            log.warn("解析违规时间失败: {}", timeStr, e);
            return LocalDateTime.now();
        }
    }
}

