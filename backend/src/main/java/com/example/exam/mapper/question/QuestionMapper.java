package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyType;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.entity.question.Question;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 题目表Mapper接口
 *
 * 模块：题库管理模块（exam-question）
 * 职责：题目数据访问层
 * 所有复杂查询使用LambdaQueryWrapper在Service层实现
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface QuestionMapper extends BaseMapper<Question> {
    // 所有数据操作使用LambdaQueryWrapper，无需自定义方法
}

