package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.entity.exam.ExamAnswer;

import java.util.List;

/**
 * 阅卷Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface GradingService {

    /**
     * 获取待阅卷答案
     */
    IPage<ExamAnswer> getPendingAnswers(Page<ExamAnswer> page, Long examId, Long questionId, Long teacherId);

    /**
     * 阅卷
     */
    boolean gradeAnswer(Long answerId, Double score, String comment, Long teacherId);

    /**
     * 批量阅卷
     */
    Object batchGrade(List<Object> gradeData);

    /**
     * 获取我的阅卷任务
     */
    List<Object> getMyGradingTasks(Long teacherId);

    /**
     * 分配阅卷任务
     */
    boolean assignGradingTask(Long examId, Long questionId, Long[] teacherIds);

    /**
     * 获取阅卷进度
     */
    Object getGradingProgress(Long examId);

    /**
     * 申请成绩复核
     */
    boolean requestReview(Long sessionId, Long questionId, String reason);

    /**
     * 处理复核申请
     */
    boolean handleReview(Long reviewId, Boolean approved, Double newScore, String opinion, Long handlerId);

    /**
     * 获取复核申请列表
     */
    IPage<Object> getReviewRequests(Page<Object> page, Long examId, String status);
}

