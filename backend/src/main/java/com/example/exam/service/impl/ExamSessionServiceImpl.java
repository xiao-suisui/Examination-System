package com.example.exam.service.impl;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.entity.exam.Exam;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.mapper.exam.ExamMapper;
import com.example.exam.mapper.exam.ExamSessionMapper;
import com.example.exam.service.ExamSessionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    public boolean saveAnswer(Long sessionId, ExamAnswer answer) {
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
    public boolean saveAnswers(Long sessionId, List<ExamAnswer> answers) {
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
    public boolean submitExam(Long sessionId) {
        try {
            ExamSession session = baseMapper.selectById(sessionId);
            if (session == null) {
                log.error("会话不存在: sessionId={}", sessionId);
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

            int result = baseMapper.updateById(session);

            if (result > 0) {
                log.info("提交考试成功: sessionId={}", sessionId);
                // TODO: 触发自动阅卷
                return true;
            }

            return false;
        } catch (Exception e) {
            log.error("提交考试失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean pauseExam(Long sessionId) {
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
    public boolean resumeExam(Long sessionId) {
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
    public Object getExamResult(Long sessionId) {
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
    public Long getRemainingTime(Long sessionId) {
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
    public boolean markQuestion(Long sessionId, Long questionId, String markType) {
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
                submitExam(Long.valueOf(sessionId));
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
}

