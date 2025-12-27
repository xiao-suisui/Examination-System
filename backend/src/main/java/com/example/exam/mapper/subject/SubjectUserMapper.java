package com.example.exam.mapper.subject;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.subject.SubjectUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 科目用户关联表Mapper接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Mapper
public interface SubjectUserMapper extends BaseMapper<SubjectUser> {

    /**
     * 查询科目下指定类型的用户ID列表
     *
     * @param subjectId 科目ID
     * @param userType  用户类型（4-学生）
     * @return 用户ID列表
     */
    @Select("SELECT user_id FROM subject_user WHERE subject_id = #{subjectId} AND user_type = #{userType} AND deleted = 0")
    List<Long> selectUserIdsBySubjectAndType(@Param("subjectId") Long subjectId, @Param("userType") Integer userType);

    /**
     * 查询科目的所有学生数量
     *
     * @param subjectId 科目ID
     * @return 学生数量
     */
    @Select("SELECT COUNT(*) FROM subject_user WHERE subject_id = #{subjectId} AND user_type = 4 AND deleted = 0")
    Integer countStudentsBySubject(@Param("subjectId") Long subjectId);

    /**
     * 查询用户选修的所有科目ID列表
     *
     * @param userId 用户ID
     * @return 科目ID列表
     */
    @Select("SELECT subject_id FROM subject_user WHERE user_id = #{userId} AND deleted = 0")
    List<Long> selectSubjectIdsByUserId(@Param("userId") Long userId);
}

