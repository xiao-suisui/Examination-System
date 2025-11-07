package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.question.QuestionTag;
import org.apache.ibatis.annotations.Mapper;

/**
 * 题目标签表Mapper接口
 *
 * 模块：题库管理模块（exam-question）
 * 职责：题目标签数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface QuestionTagMapper extends BaseMapper<QuestionTag> {

}

