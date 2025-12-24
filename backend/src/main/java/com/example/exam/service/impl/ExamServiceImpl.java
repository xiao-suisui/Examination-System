package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.entity.exam.Exam;
import com.example.exam.mapper.exam.ExamMapper;
import com.example.exam.service.ExamService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 考试Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Service
@RequiredArgsConstructor
public class ExamServiceImpl extends ServiceImpl<ExamMapper, Exam> implements ExamService {

    @Override
    public IPage<Exam> pageExams(Page<Exam> page, ExamStatus status, String keyword,
                                 LocalDateTime startTimeBegin, LocalDateTime startTimeEnd) {
        LambdaQueryWrapper<Exam> wrapper = new LambdaQueryWrapper<>();
        // status参数在这里是枚举，但数据库字段是Integer，暂时注释掉
        // wrapper.eq(status != null, Exam::getExamStatus, status)
        wrapper.like(keyword != null && !keyword.isEmpty(), Exam::getExamName, keyword)
               .ge(startTimeBegin != null, Exam::getStartTime, startTimeBegin)
               .le(startTimeEnd != null, Exam::getStartTime, startTimeEnd)
               .orderByDesc(Exam::getCreateTime);
        return this.page(page, wrapper);
    }

    @Override
    public boolean publishExam(Long examId) {
        // TODO: 实现发布考试逻辑
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 数据库中：0-未开始，1-进行中，2-已结束，3-已终止
        // 这里假设发布后状态为0（未开始）
        exam.setExamStatus(0);
        return this.updateById(exam);
    }

    @Override
    public boolean startExam(Long examId) {
        // TODO: 实现开始考试逻辑
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 设置为进行中
        exam.setExamStatus(1);
        return this.updateById(exam);
    }

    @Override
    public boolean endExam(Long examId) {
        // TODO: 实现结束考试逻辑
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 设置为已结束
        exam.setExamStatus(2);
        return this.updateById(exam);
    }

    @Override
    public Object getExamMonitorData(Long examId) {
        // TODO: 实现考试监控数据获取逻辑
        Map<String, Object> monitorData = new HashMap<>();
        monitorData.put("examId", examId);
        monitorData.put("totalParticipants", 0);
        monitorData.put("currentOnline", 0);
        monitorData.put("submitted", 0);
        return monitorData;
    }

    @Override
    public Object getExamStatistics(Long examId) {
        // TODO: 实现考试统计逻辑
        Map<String, Object> statistics = new HashMap<>();
        statistics.put("examId", examId);
        statistics.put("averageScore", 0.0);
        statistics.put("highestScore", 0.0);
        statistics.put("lowestScore", 0.0);
        return statistics;
    }
}

