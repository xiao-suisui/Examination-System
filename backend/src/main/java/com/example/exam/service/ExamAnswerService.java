package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.exam.ExamAnswer;

import java.util.List;

/**
 * 答题记录Service
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
public interface ExamAnswerService extends IService<ExamAnswer> {

    /**
     * 保存单个答案
     *
     * @param answer 答案
     * @return 是否成功
     */
    boolean saveAnswer(ExamAnswer answer);

    /**
     * 批量保存答案
     *
     * @param answers 答案列表
     * @return 是否成功
     */
    boolean saveAnswers(List<ExamAnswer> answers);

    /**
     * 获取会话的所有答案
     *
     * @param sessionId 会话ID
     * @return 答案列表
     */
    List<ExamAnswer> getSessionAnswers(String sessionId);

    /**
     * 获取考生某道题的答案
     *
     * @param sessionId 会话ID
     * @param questionId 题目ID
     * @return 答案
     */
    ExamAnswer getAnswer(String sessionId, Long questionId);

    /**
     * 更新答案
     *
     * @param answer 答案
     * @return 是否成功
     */
    boolean updateAnswer(ExamAnswer answer);

    /**
     * 删除答案
     *
     * @param sessionId 会话ID
     * @param questionId 题目ID
     * @return 是否成功
     */
    boolean deleteAnswer(String sessionId, Long questionId);

    /**
     * 自动批改客观题
     *
     * @param sessionId 会话ID
     * @return 是否成功
     */
    boolean autoGradeObjectiveQuestions(String sessionId);
}

