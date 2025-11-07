package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;

import java.util.List;

/**
 * 考试会话Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface ExamSessionService extends IService<ExamSession> {

    /**
     * 开始考试
     */
    ExamSession startExam(Long examId, Long userId);

    /**
     * 保存答案
     */
    boolean saveAnswer(Long sessionId, ExamAnswer answer);

    /**
     * 批量保存答案
     */
    boolean saveAnswers(Long sessionId, List<ExamAnswer> answers);

    /**
     * 提交考试
     */
    boolean submitExam(Long sessionId);

    /**
     * 暂停考试
     */
    boolean pauseExam(Long sessionId);

    /**
     * 恢复考试
     */
    boolean resumeExam(Long sessionId);

    /**
     * 获取考试结果
     */
    Object getExamResult(Long sessionId);

    /**
     * 获取我的考试会话
     */
    List<ExamSession> getMyExamSessions(Long userId);

    /**
     * 获取剩余时间（秒）
     */
    Long getRemainingTime(Long sessionId);

    /**
     * 标记题目
     */
    boolean markQuestion(Long sessionId, Long questionId, String markType);
}

