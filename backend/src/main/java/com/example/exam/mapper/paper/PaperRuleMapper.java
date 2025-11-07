package com.example.exam.mapper.paper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.paper.PaperRule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 组卷规则表Mapper接口
 *
 * 模块：试卷管理模块（exam-paper）
 * 职责：组卷规则数据访问（随机组卷）
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface PaperRuleMapper extends BaseMapper<PaperRule> {

    /**
     * 根据试卷ID查询所有组卷规则
     *
     * @param paperId 试卷ID
     * @return 组卷规则列表
     */
    @Select("SELECT * FROM paper_rule WHERE paper_id = #{paperId} ORDER BY sort_order ASC")
    List<PaperRule> selectByPaperId(@Param("paperId") Long paperId);
}

