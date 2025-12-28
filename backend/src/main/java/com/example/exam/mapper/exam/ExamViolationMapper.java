package com.example.exam.mapper.exam;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.exam.ExamViolation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 考试违规记录表Mapper接口
 * 模块：考试管理模块（exam-exam）
 * 职责：考试违规数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Mapper
public interface ExamViolationMapper extends BaseMapper<ExamViolation> {

    /**
     * 根据会话ID查询违规记录
     *
     * @param sessionId 会话ID
     * @return 违规记录列表
     */
    @Select("SELECT * FROM exam_violation WHERE session_id = #{sessionId} ORDER BY violation_time DESC")
    List<ExamViolation> selectBySessionId(@Param("sessionId") String sessionId);

    /**
     * 根据考试ID查询违规记录
     *
     * @param examId 考试ID
     * @return 违规记录列表
     */
    @Select("SELECT * FROM exam_violation WHERE exam_id = #{examId} ORDER BY violation_time DESC")
    List<ExamViolation> selectByExamId(@Param("examId") Long examId);

    /**
     * 根据用户ID查询违规记录
     *
     * @param userId 用户ID
     * @return 违规记录列表
     */
    @Select("SELECT * FROM exam_violation WHERE user_id = #{userId} ORDER BY violation_time DESC")
    List<ExamViolation> selectByUserId(@Param("userId") Long userId);

    /**
     * 统计会话的违规次数
     *
     * @param sessionId 会话ID
     * @return 违规次数
     */
    @Select("SELECT COUNT(*) FROM exam_violation WHERE session_id = #{sessionId}")
    Integer countBySessionId(@Param("sessionId") String sessionId);
}

