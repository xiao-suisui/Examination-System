package com.example.exam.mapper.exam;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.exam.ExamAnswer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 答题记录表Mapper接口（核心）
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：答题记录数据访问，支持成绩统计
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface ExamAnswerMapper extends BaseMapper<ExamAnswer> {

    /**
     * 根据会话ID查询所有答题记录
     *
     * @param sessionId 会话ID
     * @return 答题记录列表
     */
    @Select("SELECT * FROM exam_answer WHERE session_id = #{sessionId} AND deleted = 0")
    List<ExamAnswer> selectBySessionId(@Param("sessionId") String sessionId);

    /**
     * 统计考生的总分
     *
     * @param sessionId 会话ID
     * @return 总分
     */
    @Select("SELECT COALESCE(SUM(score), 0) FROM exam_answer WHERE session_id = #{sessionId} AND deleted = 0")
    BigDecimal calculateTotalScore(@Param("sessionId") String sessionId);

    /**
     * 查询需要批改的主观题列表
     *
     * @param examId 考试ID
     * @return 答题记录列表
     */
    List<ExamAnswer> selectSubjectiveAnswersForGrading(@Param("examId") Long examId);

    /**
     * 统计题目答题情况（正确率、平均分）
     *
     * @param examId 考试ID
     * @param questionId 题目ID
     * @return 统计信息
     */
    @org.apache.ibatis.annotations.MapKey("questionId")
    Map<String, Object> selectQuestionStats(@Param("examId") Long examId, @Param("questionId") Long questionId);

    /**
     * 查询错题列表（用于错题解析）
     *
     * @param userId 考生ID
     * @param examId 考试ID（可选）
     * @return 错题列表
     */
    List<ExamAnswer> selectWrongAnswers(@Param("userId") Long userId, @Param("examId") Long examId);

    /**
     * 统计考试成绩分布
     *
     * @param examId 考试ID
     * @return 分数段统计（0-59, 60-69, 70-79, 80-89, 90-100）
     */
    @org.apache.ibatis.annotations.MapKey("scoreRange")
    List<Map<String, Object>> selectScoreDistribution(@Param("examId") Long examId);
}

