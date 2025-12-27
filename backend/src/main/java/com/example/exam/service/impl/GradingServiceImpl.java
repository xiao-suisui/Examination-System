package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.mapper.exam.ExamAnswerMapper;
import com.example.exam.mapper.exam.ExamSessionMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.service.GradingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 阅卷Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GradingServiceImpl implements GradingService {

    private final ExamAnswerMapper examAnswerMapper;
    private final ExamSessionMapper examSessionMapper;
    private final QuestionMapper questionMapper;

    @Override
    public IPage<ExamAnswer> getPendingAnswers(Page<ExamAnswer> page, Long examId, Long questionId, Long teacherId) {
        try {
            // 查询待批改的答案（score 为 null 表示未批改）
            // 注意：客观题已经被自动批改，score 有值；主观题 score 为 null
            LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(examId != null, ExamAnswer::getExamId, examId)
                   .eq(questionId != null, ExamAnswer::getQuestionId, questionId)
                   .isNull(ExamAnswer::getScore) // 未批改的答案
                   .isNotNull(ExamAnswer::getUserAnswer) // 有答案内容
                   .ne(ExamAnswer::getUserAnswer, "") // 答案不为空
                   .orderByAsc(ExamAnswer::getCreateTime);

            return examAnswerMapper.selectPage(page, wrapper);
        } catch (Exception e) {
            log.error("获取待阅卷答案失败", e);
            return page;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean gradeAnswer(Long answerId, Double score, String comment, Long teacherId) {
        try {
            ExamAnswer answer = examAnswerMapper.selectById(answerId);
            if (answer == null) {
                log.error("答案不存在: answerId={}", answerId);
                return false;
            }

            // 更新答案得分和批注
            answer.setScore(BigDecimal.valueOf(score));
            answer.setTeacherComment(comment);
            answer.setGradedBy(teacherId);
            answer.setGradeTime(LocalDateTime.now());

            int result = examAnswerMapper.updateById(answer);

            if (result > 0) {
                log.info("阅卷成功: answerId={}, score={}, teacherId={}", answerId, score, teacherId);

                // 检查该会话的所有主观题是否都已批改完成
                checkAndUpdateSessionStatus(answer.getSessionId());

                return true;
            }

            return false;
        } catch (Exception e) {
            log.error("阅卷失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Object batchGrade(List<Object> gradeData) {
        try {
            int successCount = 0;
            for (Object data : gradeData) {
                // TODO: 解析批量阅卷数据并处理
                successCount++;
            }

            Map<String, Object> result = new HashMap<>();
            result.put("total", gradeData.size());
            result.put("success", successCount);
            result.put("failed", gradeData.size() - successCount);

            log.info("批量阅卷完成: total={}, success={}", gradeData.size(), successCount);
            return result;
        } catch (Exception e) {
            log.error("批量阅卷失败", e);
            return null;
        }
    }

    @Override
    public List<Object> getMyGradingTasks(Long teacherId) {
        try {
            // TODO: 查询分配给该教师的阅卷任务
            log.info("获取阅卷任务: teacherId={}", teacherId);
            return List.of();
        } catch (Exception e) {
            log.error("获取阅卷任务失败", e);
            return List.of();
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean assignGradingTask(Long examId, Long questionId, Long[] teacherIds) {
        try {
            // TODO: 实现阅卷任务分配逻辑
            log.info("分配阅卷任务: examId={}, questionId={}, teacherIds={}", examId, questionId, teacherIds);
            return true;
        } catch (Exception e) {
            log.error("分配阅卷任务失败", e);
            return false;
        }
    }

    @Override
    public Object getGradingProgress(Long examId) {
        try {
            // 统计阅卷进度
            LambdaQueryWrapper<ExamAnswer> totalWrapper = new LambdaQueryWrapper<>();
            totalWrapper.eq(ExamAnswer::getExamId, examId);
            long total = examAnswerMapper.selectCount(totalWrapper);

            LambdaQueryWrapper<ExamAnswer> gradedWrapper = new LambdaQueryWrapper<>();
            gradedWrapper.eq(ExamAnswer::getExamId, examId)
                        .isNotNull(ExamAnswer::getScore);
            long graded = examAnswerMapper.selectCount(gradedWrapper);

            Map<String, Object> progress = new HashMap<>();
            progress.put("total", total);
            progress.put("graded", graded);
            progress.put("pending", total - graded);
            progress.put("progress", total > 0 ? (graded * 100.0 / total) : 0);

            log.info("阅卷进度: examId={}, total={}, graded={}", examId, total, graded);
            return progress;
        } catch (Exception e) {
            log.error("获取阅卷进度失败", e);
            return null;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean requestReview(Long sessionId, Long questionId, String reason) {
        try {
            // TODO: 实现成绩复核申请
            log.info("申请成绩复核: sessionId={}, questionId={}, reason={}", sessionId, questionId, reason);
            return true;
        } catch (Exception e) {
            log.error("申请成绩复核失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleReview(Long reviewId, Boolean approved, Double newScore, String opinion, Long handlerId) {
        try {
            // TODO: 实现处理复核申请
            log.info("处理复核申请: reviewId={}, approved={}, newScore={}, handlerId={}",
                    reviewId, approved, newScore, handlerId);
            return true;
        } catch (Exception e) {
            log.error("处理复核申请失败", e);
            return false;
        }
    }

    @Override
    public IPage<Object> getReviewRequests(Page<Object> page, Long examId, String status) {
        try {
            // TODO: 实现获取复核申请列表
            log.info("获取复核申请列表: examId={}, status={}", examId, status);
            return page;
        } catch (Exception e) {
            log.error("获取复核申请列表失败", e);
            return page;
        }
    }

    /**
     * 检查会话的所有答案是否都已批改完成，如果完成则更新会话状态
     */
    private void checkAndUpdateSessionStatus(String sessionId) {
        try {
            // 查询该会话中未批改的答案数量（score 为 null）
            LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamAnswer::getSessionId, sessionId)
                   .isNull(ExamAnswer::getScore);
            long ungradedCount = examAnswerMapper.selectCount(wrapper);

            if (ungradedCount == 0) {
                // 所有答案都已批改完成，计算总分
                BigDecimal totalScore = examAnswerMapper.calculateTotalScore(sessionId);

                // 更新会话状态
                ExamSession session = examSessionMapper.selectById(sessionId);
                if (session != null) {
                    session.setTotalScore(totalScore);
                    session.setSessionStatus(ExamSessionStatus.GRADED);
                    examSessionMapper.updateById(session);

                    log.info("会话批改完成: sessionId={}, totalScore={}", sessionId, totalScore);
                }
            } else {
                log.info("会话还有未批改的答案: sessionId={}, ungradedCount={}", sessionId, ungradedCount);
            }
        } catch (Exception e) {
            log.error("检查会话状态失败: sessionId={}", sessionId, e);
        }
    }

    /**
     * 判断题目是否为主观题
     */
    private boolean isSubjectiveQuestion(Long questionId) {
        try {
            var question = questionMapper.selectById(questionId);
            return question != null && question.getQuestionType() == QuestionType.SUBJECTIVE;
        } catch (Exception e) {
            log.error("查询题目类型失败: questionId={}", questionId, e);
            return false;
        }
    }
}

