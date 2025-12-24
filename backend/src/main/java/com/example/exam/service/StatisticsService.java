package com.example.exam.service;

import java.time.LocalDateTime;

/**
 * 统计分析Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface StatisticsService {

    /**
     * 获取考试统计
     */
    Object getExamOverview(Long examId);

    /**
     * 获取成绩分布
     */
    Object getScoreDistribution(Long examId);

    /**
     * 获取题目统计
     */
    Object getQuestionStatistics(Long questionId, Long examId);

    /**
     * 获取知识点掌握度
     */
    Object getKnowledgeMastery(Long userId, Long bankId);

    /**
     * 获取学生成绩报告
     */
    Object getStudentReport(Long userId, Long examId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 班级成绩对比
     */
    Object getClassComparison(Long examId, Long[] organizationIds);

    /**
     * 趋势分析
     */
    Object getTrendAnalysis(Long userId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 题库质量分析
     */
    Object getBankQualityAnalysis(Long bankId);

    /**
     * 系统使用统计
     */
    Object getSystemUsage(LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 导出报表
     */
    Object exportReport(String type, Long examId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 获取仪表盘数据
     */
    Object getDashboardData(Long userId, String role);
}

