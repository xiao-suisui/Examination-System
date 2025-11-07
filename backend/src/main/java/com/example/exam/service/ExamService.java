package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.entity.exam.Exam;

import java.time.LocalDateTime;

/**
 * 考试Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface ExamService extends IService<Exam> {

    /**
     * 分页查询考试
     */
    IPage<Exam> pageExams(Page<Exam> page, ExamStatus status, String keyword,
                          LocalDateTime startTimeBegin, LocalDateTime startTimeEnd);

    /**
     * 发布考试
     */
    boolean publishExam(Long examId);

    /**
     * 开始考试
     */
    boolean startExam(Long examId);

    /**
     * 结束考试
     */
    boolean endExam(Long examId);

    /**
     * 获取考试监控数据
     */
    Object getExamMonitorData(Long examId);

    /**
     * 获取考试统计数据
     */
    Object getExamStatistics(Long examId);
}

