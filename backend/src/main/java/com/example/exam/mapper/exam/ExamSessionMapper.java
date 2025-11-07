package com.example.exam.mapper.exam;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.exam.ExamSession;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 考试会话表Mapper接口
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：考试会话数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface ExamSessionMapper extends BaseMapper<ExamSession> {

    /**
     * 根据考试ID和用户ID查询最新会话
     *
     * @param examId 考试ID
     * @param userId 考生ID
     * @return 考试会话
     */
    @Select("SELECT * FROM exam_session WHERE exam_id = #{examId} AND user_id = #{userId} " +
            "ORDER BY attempt_number DESC LIMIT 1")
    ExamSession selectLatestSession(@Param("examId") Long examId, @Param("userId") Long userId);

    /**
     * 查询进行中的会话列表（用于监控）
     *
     * @param examId 考试ID
     * @return 会话列表
     */
    @Select("SELECT * FROM exam_session WHERE exam_id = #{examId} AND session_status = 'IN_PROGRESS'")
    List<ExamSession> selectInProgressSessions(@Param("examId") Long examId);
}

