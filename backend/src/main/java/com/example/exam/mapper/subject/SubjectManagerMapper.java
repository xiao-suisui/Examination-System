package com.example.exam.mapper.subject;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.subject.SubjectManager;
import org.apache.ibatis.annotations.Mapper;

/**
 * 科目管理员Mapper接口
 *
 * @author system
 * @since 2025-12-20
 */
@Mapper
public interface SubjectManagerMapper extends BaseMapper<SubjectManager> {
}

