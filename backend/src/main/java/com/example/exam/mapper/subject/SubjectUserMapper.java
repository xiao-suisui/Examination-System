package com.example.exam.mapper.subject;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.subject.SubjectUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 科目-用户关联Mapper
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-20
 */
@Mapper
public interface SubjectUserMapper extends BaseMapper<SubjectUser> {

    /**
     * 查询用户加入的所有科目ID
     *
     * @param userId 用户ID
     * @return 科目ID列表
     */
    @Select("SELECT subject_id FROM subject_user WHERE user_id = #{userId} AND deleted = 0")
    List<Long> selectSubjectIdsByUserId(Long userId);

    /**
     * 查询科目下的所有用户ID
     *
     * @param subjectId 科目ID
     * @return 用户ID列表
     */
    @Select("SELECT user_id FROM subject_user WHERE subject_id = #{subjectId} AND deleted = 0")
    List<Long> selectUserIdsBySubjectId(Long subjectId);

    /**
     * 查询用户在科目中的角色
     *
     * @param subjectId 科目ID
     * @param userId 用户ID
     * @return 用户类型
     */
    @Select("SELECT user_type FROM subject_user WHERE subject_id = #{subjectId} AND user_id = #{userId} AND deleted = 0 LIMIT 1")
    Integer selectUserTypeBySubjectAndUser(Long subjectId, Long userId);

    /**
     * 检查用户是否在科目中
     *
     * @param subjectId 科目ID
     * @param userId 用户ID
     * @return 是否存在
     */
    @Select("SELECT COUNT(1) FROM subject_user WHERE subject_id = #{subjectId} AND user_id = #{userId} AND deleted = 0")
    int existsBySubjectAndUser(Long subjectId, Long userId);
}

