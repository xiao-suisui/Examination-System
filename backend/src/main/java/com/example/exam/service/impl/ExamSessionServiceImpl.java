package com.example.exam.service.impl;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.entity.exam.Exam;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.entity.exam.ExamViolation;
import com.example.exam.mapper.exam.ExamAnswerMapper;
import com.example.exam.mapper.exam.ExamMapper;
import com.example.exam.mapper.exam.ExamSessionMapper;
import com.example.exam.mapper.exam.ExamViolationMapper;
import com.example.exam.service.AutoGradingService;
import com.example.exam.service.ExamSessionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 考试会话Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-10
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExamSessionServiceImpl extends ServiceImpl<ExamSessionMapper, ExamSession> implements ExamSessionService {

    private final ExamMapper examMapper;
    private final ExamViolationMapper examViolationMapper;
    private final ExamAnswerMapper examAnswerMapper;
    private final AutoGradingService autoGradingService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ExamSession startExam(Long examId, Long userId) {
        try {
            // 1. 检查考试是否存在
            Exam exam = examMapper.selectById(examId);
            if (exam == null) {
                log.error("考试不存在: examId={}", examId);
                return null;
            }

            // 2. 检查考试状态
            if (exam.getExamStatus() != ExamStatus.IN_PROGRESS && exam.getExamStatus() != ExamStatus.PUBLISHED) {
                log.error("考试状态不允许开始: examId={}, status={}", examId, exam.getExamStatus());
                return null;
            }

            // 3. 检查考试时间
            LocalDateTime now = LocalDateTime.now();
            if (now.isBefore(exam.getStartTime()) || now.isAfter(exam.getEndTime())) {
                log.error("不在考试时间范围内: examId={}, now={}", examId, now);
                return null;
            }

            // 4. 检查是否已有会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId)
                   .eq(ExamSession::getUserId, userId)
                   .orderByDesc(ExamSession::getAttemptNumber);
            ExamSession existingSession = baseMapper.selectOne(wrapper);

            // 如果已有未提交的会话，返回该会话
            if (existingSession != null && existingSession.getSessionStatus() == ExamSessionStatus.IN_PROGRESS) {
                log.info("返回已存在的会话: sessionId={}", existingSession.getSessionId());
                return existingSession;
            }

            // 5. 创建新会话
            int attemptNumber = existingSession != null ? existingSession.getAttemptNumber() + 1 : 1;

            ExamSession session = ExamSession.builder()
                    .sessionId(UUID.randomUUID().toString())
                    .examId(examId)
                    .userId(userId)
                    .attemptNumber(attemptNumber)
                    .startTime(now)
                    .sessionStatus(ExamSessionStatus.IN_PROGRESS)
                    .tabSwitchCount(0)
                    .build();

            if (baseMapper.insert(session) > 0) {
                log.info("创建考试会话成功: sessionId={}, examId={}, userId={}",
                        session.getSessionId(), examId, userId);
                return session;
            }

            return null;
        } catch (Exception e) {
            log.error("开始考试失败", e);
            throw new RuntimeException("开始考试失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveAnswer(String sessionId, ExamAnswer answer) {
        try {
            // TODO: 实现保存单个答案逻辑
            // 这里需要保存到exam_answer表
            log.info("保存答案: sessionId={}, questionId={}", sessionId, answer.getQuestionId());
            return true;
        } catch (Exception e) {
            log.error("保存答案失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveAnswers(String sessionId, List<ExamAnswer> answers) {
        try {
            // TODO: 实现批量保存答案逻辑
            log.info("批量保存答案: sessionId={}, count={}", sessionId, answers.size());
            for (ExamAnswer answer : answers) {
                saveAnswer(sessionId, answer);
            }
            return true;
        } catch (Exception e) {
            log.error("批量保存答案失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean submitExam(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                log.error("会话不存在: sessionId={}", sessionId);
                return false;
            }

            // 检查会话状态
            if (session.getSessionStatus() != ExamSessionStatus.IN_PROGRESS) {
                log.warn("会话状态不正确，无法提交: sessionId={}, status={}", sessionId, session.getSessionStatus());
                return false;
            }

            // 更新会话状态
            LocalDateTime now = LocalDateTime.now();
            session.setSubmitTime(now);
            session.setSessionStatus(ExamSessionStatus.SUBMITTED);

            // 计算实际用时（分钟）
            if (session.getStartTime() != null) {
                Duration duration = Duration.between(session.getStartTime(), now);
                session.setDuration((int) duration.toMinutes());
            }

            // 保存提交状态
            int result = baseMapper.updateById(session);

            if (result > 0) {
                log.info("提交考试成功: sessionId={}, status={}", sessionId, session.getSessionStatus());
                return true;
            }

            return false;
        } catch (Exception e) {
            log.error("提交考试失败", e);
            return false;
        }
    }

    /**
     * 执行自动阅卷（独立事务，不影响提交）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void doAutoGrading(String sessionId) {
        try {
            log.info("开始自动阅卷: sessionId={}", sessionId);
            BigDecimal objectiveScore = autoGradingService.gradeSession(sessionId);

            // 重新获取会话
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                return;
            }

            session.setObjectiveScore(objectiveScore);

            // 检查是否有主观题需要人工批改
            boolean hasSubjectiveQuestions = checkHasSubjectiveQuestions(sessionId);

            if (hasSubjectiveQuestions) {
                // 有主观题，保持SUBMITTED状态
                log.info("考试包含主观题，等待人工批改: sessionId={}, objectiveScore={}", sessionId, objectiveScore);
            } else {
                // 没有主观题，直接计算总分
                session.setTotalScore(objectiveScore);
                session.setSessionStatus(ExamSessionStatus.GRADED);
                log.info("自动阅卷完成: sessionId={}, totalScore={}", sessionId, objectiveScore);
            }

            baseMapper.updateById(session);
        } catch (Exception e) {
            log.error("自动阅卷失败: sessionId={}", sessionId, e);
            // 不抛出异常，让阅卷失败不影响其他操作
        }
    }

    /**
     * 检查会话中是否包含未批改的题目（主观题）
     */
    private boolean checkHasSubjectiveQuestions(String sessionId) {
        try {
            // 查询该会话中 score 为 null 的答案数量
            // 自动批改后，客观题的 score 会有值，主观题的 score 仍为 null
            LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamAnswer::getSessionId, sessionId)
                   .isNull(ExamAnswer::getScore);

            long count = examAnswerMapper.selectCount(wrapper);
            boolean hasSubjective = count > 0;

            log.info("检查主观题: sessionId={}, 未批改数量={}", sessionId, count);
            return hasSubjective;
        } catch (Exception e) {
            log.error("检查主观题失败: sessionId={}", sessionId, e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean pauseExam(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                return false;
            }

            // TODO: 实现暂停逻辑（如果需要）
            log.info("暂停考试: sessionId={}", sessionId);
            return true;
        } catch (Exception e) {
            log.error("暂停考试失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean resumeExam(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                return false;
            }

            // TODO: 实现恢复逻辑（如果需要）
            log.info("恢复考试: sessionId={}", sessionId);
            return true;
        } catch (Exception e) {
            log.error("恢复考试失败", e);
            return false;
        }
    }

    @Override
    public Object getExamResult(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                return null;
            }

            // TODO: 实现获取考试结果详情
            log.info("获取考试结果: sessionId={}", sessionId);
            return session;
        } catch (Exception e) {
            log.error("获取考试结果失败", e);
            return null;
        }
    }

    @Override
    public List<ExamSession> getMyExamSessions(Long userId) {
        try {
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getUserId, userId)
                   .orderByDesc(ExamSession::getStartTime);
            return baseMapper.selectList(wrapper);
        } catch (Exception e) {
            log.error("获取我的考试会话失败", e);
            return new ArrayList<>();
        }
    }

    @Override
    public Long getRemainingTime(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                return 0L;
            }

            Exam exam = examMapper.selectById(session.getExamId());
            if (exam == null) {
                return 0L;
            }

            // 计算剩余时间（秒）
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime endTime = exam.getEndTime();

            if (now.isAfter(endTime)) {
                return 0L;
            }

            Duration duration = Duration.between(now, endTime);
            return duration.getSeconds();
        } catch (Exception e) {
            log.error("获取剩余时间失败", e);
            return 0L;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean markQuestion(String sessionId, Long questionId, String markType) {
        try {
            // TODO: 实现标记题目逻辑
            log.info("标记题目: sessionId={}, questionId={}, markType={}",
                    sessionId, questionId, markType);
            return true;
        } catch (Exception e) {
            log.error("标记题目失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int recordTabSwitch(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                log.error("会话不存在: sessionId={}", sessionId);
                return 0;
            }

            // 增加切屏次数
            int currentCount = session.getTabSwitchCount() != null ? session.getTabSwitchCount() : 0;
            int newCount = currentCount + 1;
            session.setTabSwitchCount(newCount);

            // 记录切屏时间
            List<String> records = new ArrayList<>();
            if (session.getTabSwitchRecords() != null && !session.getTabSwitchRecords().isEmpty()) {
                records = JSON.parseArray(session.getTabSwitchRecords(), String.class);
            }
            records.add(LocalDateTime.now().toString());
            session.setTabSwitchRecords(JSON.toJSONString(records));

            baseMapper.updateById(session);

            log.warn("记录切屏: sessionId={}, count={}", sessionId, newCount);

            // 检查是否超过限制
            Exam exam = examMapper.selectById(session.getExamId());
            if (exam != null && exam.getCutScreenLimit() != null && newCount > exam.getCutScreenLimit()) {
                log.warn("切屏次数超过限制，强制提交: sessionId={}, count={}, limit={}",
                        sessionId, newCount, exam.getCutScreenLimit());
                // 自动提交
                submitExam(sessionId);
            }

            return newCount;
        } catch (Exception e) {
            log.error("记录切屏失败", e);
            return 0;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateHeartbeat(String sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session != null) {
                // 更新最后活跃时间
                session.setUpdateTime(LocalDateTime.now());
                baseMapper.updateById(session);
                log.debug("更新心跳: sessionId={}", sessionId);
            }
        } catch (Exception e) {
            log.error("更新心跳失败", e);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int recordViolation(String sessionId, String violationType, String violationDetail, Integer severity) {
        try {
            // 1. 检查会话是否存在
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                log.error("会话不存在: sessionId={}", sessionId);
                return 0;
            }

            // 2. 创建违规记录
            ExamViolation violation = ExamViolation.builder()
                    .sessionId(sessionId)
                    .examId(session.getExamId())
                    .userId(session.getUserId())
                    .violationType(violationType)
                    .violationTime(LocalDateTime.now())
                    .violationDetail(violationDetail)
                    .severity(severity != null ? severity : 1)
                    .build();

            examViolationMapper.insert(violation);

            // 3. 统计总违规次数
            Integer totalCount = examViolationMapper.countBySessionId(sessionId);

            log.warn("记录违规行为: sessionId={}, type={}, severity={}, totalCount={}",
                    sessionId, violationType, severity, totalCount);

            // 4. 检查是否需要强制终止考试
            Exam exam = examMapper.selectById(session.getExamId());
            if (exam != null && exam.getCutScreenLimit() != null) {
                // 如果切屏类型的违规，也更新切屏次数
                if ("TAB_SWITCH".equals(violationType)) {
                    recordTabSwitch(sessionId);
                }

                // 如果严重程度为5（致命）或总违规次数超过限制的2倍，强制终止
                if (severity != null && severity >= 5) {
                    log.warn("检测到严重违规，强制提交: sessionId={}, type={}, severity={}",
                            sessionId, violationType, severity);
                    submitExam(sessionId);
                } else if (totalCount > exam.getCutScreenLimit() * 2) {
                    log.warn("违规次数过多，强制提交: sessionId={}, count={}, limit={}",
                            sessionId, totalCount, exam.getCutScreenLimit());
                    submitExam(sessionId);
                }
            }

            return totalCount;
        } catch (Exception e) {
            log.error("记录违规行为失败", e);
            return 0;
        }
    }
}

