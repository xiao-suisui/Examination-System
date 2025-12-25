package com.example.exam.mapper.subject;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.subject.Subject;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 科目Mapper接口
 *
 * @author system
 * @since 2025-12-20
 */
@Mapper
public interface SubjectMapper extends BaseMapper<Subject> {

    /**
     * 查询用户管理的科目ID列表
     *
     * @param userId 用户ID
     * @return 科目ID列表
     */
    @Select("SELECT DISTINCT sm.subject_id FROM subject_manager sm " +
            "WHERE sm.user_id = #{userId}")
    List<Long> selectManagedSubjectIds(@Param("userId") Long userId);

    /**
     * 查询用户在某科目的权限列表
     *
     * @param userId    用户ID
     * @param subjectId 科目ID
     * @return 权限JSON字符串
     */
    @Select("SELECT permissions FROM subject_manager " +
            "WHERE user_id = #{userId} AND subject_id = #{subjectId}")
    String selectUserPermissions(@Param("userId") Long userId, @Param("subjectId") Long subjectId);

    /**
     * 检查用户是否为科目创建者
     *
     * @param userId    用户ID
     * @param subjectId 科目ID
     * @return 是否为创建者
     */
    @Select("SELECT COUNT(*) FROM subject_manager " +
            "WHERE user_id = #{userId} AND subject_id = #{subjectId} AND is_creator = 1")
    int isCreator(@Param("userId") Long userId, @Param("subjectId") Long subjectId);
}

