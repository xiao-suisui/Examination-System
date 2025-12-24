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
 * 职责：考试数据访问层
 * 所有复杂查询使用LambdaQueryWrapper在Service层实现
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface ExamMapper extends BaseMapper<Exam> {
    // 所有数据操作使用LambdaQueryWrapper，无需自定义方法
}

