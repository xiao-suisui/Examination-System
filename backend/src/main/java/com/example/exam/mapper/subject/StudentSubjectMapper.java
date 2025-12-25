package com.example.exam.mapper.subject;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.subject.StudentSubject;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 学生-科目关联Mapper接口
 *
 * @author system
 * @since 2025-12-20
 */
@Mapper
public interface StudentSubjectMapper extends BaseMapper<StudentSubject> {

    /**
     * 查询学生加入的科目ID列表
     *
     * @param studentId 学生ID
     * @return 科目ID列表
     */
    @Select("SELECT DISTINCT subject_id FROM student_subject " +
            "WHERE student_id = #{studentId} AND status = 1")
    List<Long> selectEnrolledSubjectIds(@Param("studentId") Long studentId);
}

