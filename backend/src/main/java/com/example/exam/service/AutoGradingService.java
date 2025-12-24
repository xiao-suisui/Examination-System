package com.example.exam.service;

import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.question.Question;

import java.math.BigDecimal;

/**
 * 自动判分Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface AutoGradingService {

    /**
     * 自动判分（单题）
     *
     * @param question 题目信息
     * @param answer 考生答案
     * @return 得分
     */
    BigDecimal gradeQuestion(Question question, ExamAnswer answer);

    /**
     * 批量自动判分（整个考试会话的所有客观题）
     *
     * @param sessionId 会话ID
     * @return 客观题总分
     */
    BigDecimal gradeSession(String sessionId);
}

