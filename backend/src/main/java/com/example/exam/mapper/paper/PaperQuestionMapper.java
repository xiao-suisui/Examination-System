package com.example.exam.mapper.paper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.paper.PaperQuestion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 试卷题目关联表Mapper接口
 *
 * 模块：试卷管理模块（exam-paper）
 * 职责：试卷题目关联数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface PaperQuestionMapper extends BaseMapper<PaperQuestion> {

    /**
     * 根据试卷ID查询所有题目关联
     *
     * @param paperId 试卷ID
     * @return 题目关联列表
     */
    @Select("SELECT * FROM paper_question WHERE paper_id = #{paperId} ORDER BY sort_order ASC")
    List<PaperQuestion> selectByPaperId(@Param("paperId") Long paperId);

    /**
     * 根据试卷ID查询题目ID列表
     *
     * @param paperId 试卷ID
     * @return 题目ID列表
     */
    @Select("SELECT question_id FROM paper_question WHERE paper_id = #{paperId} ORDER BY sort_order ASC")
    List<Long> selectQuestionIdsByPaperId(@Param("paperId") Long paperId);
}

