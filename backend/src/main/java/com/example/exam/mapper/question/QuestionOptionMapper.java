package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.question.QuestionOption;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 选项表Mapper接口（核心）
 *
 * 模块：题库管理模块（exam-question）
 * 职责：选项数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface QuestionOptionMapper extends BaseMapper<QuestionOption> {

    /**
     * 根据题目ID查询所有选项
     *
     * @param questionId 题目ID
     * @return 选项列表
     */
    @Select("SELECT * FROM question_option WHERE question_id = #{questionId} AND deleted = 0 ORDER BY sort ASC")
    List<QuestionOption> selectByQuestionId(@Param("questionId") Long questionId);

    /**
     * 根据题目ID查询正确选项
     *
     * @param questionId 题目ID
     * @return 正确选项列表
     */
    @Select("SELECT * FROM question_option WHERE question_id = #{questionId} AND is_correct = 1 AND deleted = 0 ORDER BY sort ASC")
    List<QuestionOption> selectCorrectOptionsByQuestionId(@Param("questionId") Long questionId);

    /**
     * 批量查询多个题目的选项
     *
     * @param questionIds 题目ID列表
     * @return 选项列表
     */
    @Select("<script>" +
            "SELECT * FROM question_option WHERE question_id IN " +
            "<foreach collection='questionIds' item='id' open='(' separator=',' close=')'>" +
            "#{id}" +
            "</foreach>" +
            " AND deleted = 0 ORDER BY question_id, sort ASC" +
            "</script>")
    List<QuestionOption> selectByQuestionIds(@Param("questionIds") List<Long> questionIds);
}

