package com.example.exam.mapper.exam;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.exam.Exam;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 考试表Mapper接口
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：考试数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface ExamMapper extends BaseMapper<Exam> {

    /**
     * 查询考试监控统计信息
     *
     * @param examId 考试ID
     * @return 统计信息（在线人数、已提交人数等）
     */
    Map<String, Object> selectExamMonitorStats(@Param("examId") Long examId);

    /**
     * 查询考生的考试列表（根据考试范围）
     *
     * @param userId 考生ID
     * @param orgId 组织ID
     * @return 考试列表
     */
    List<Exam> selectExamsByUser(@Param("userId") Long userId, @Param("orgId") Long orgId);
}

