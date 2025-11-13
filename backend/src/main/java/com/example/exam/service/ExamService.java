package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.dto.ExamDTO;
import com.example.exam.dto.ExamMonitorDTO;
import com.example.exam.dto.ExamStatisticsDTO;
import com.example.exam.entity.exam.Exam;

import java.time.LocalDateTime;
import java.util.List;

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
     * 分页查询考试DTO（包含试卷名称、组织名称等）
     */
    IPage<ExamDTO> pageExamDTO(Page<?> page, ExamStatus status, String keyword,
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
     * 取消考试
     */
    boolean cancelExam(Long examId);

    /**
     * 获取考试监控数据
     */
    ExamMonitorDTO getExamMonitorData(Long examId);

    /**
     * 获取考试统计数据
     */
    ExamStatisticsDTO getExamStatistics(Long examId);

    /**
     * 查询考生的考试列表
     *
     * @param userId 考生ID
     * @param orgId  组织ID
     * @return 考试列表
     */
    List<Exam> getExamsByUser(Long userId, Long orgId);

    /**
     * 复制考试
     *
     * @param examId   考试ID
     * @param newTitle 新考试标题
     * @return 新考试ID
     */
    Long copyExam(Long examId, String newTitle);
}

