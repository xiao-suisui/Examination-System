package com.example.exam.mapper.exam;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.exam.ExamUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 考试考生关联表Mapper接口
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：考试考生关联数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface ExamUserMapper extends BaseMapper<ExamUser> {

    /**
     * 查询考生的考试状态
     *
     * @param examId 考试ID
     * @param userId 考生ID
     * @return 考试考生关联信息
     */
    @Select("SELECT * FROM exam_user WHERE exam_id = #{examId} AND user_id = #{userId}")
    ExamUser selectByExamIdAndUserId(@Param("examId") Long examId, @Param("userId") Long userId);

    /**
     * 统计考试参考人数
     *
     * @param examId 考试ID
     * @param examStatus 考试状态（可选）
     * @return 人数统计
     */
    @Select("<script>" +
            "SELECT COUNT(*) FROM exam_user WHERE exam_id = #{examId} " +
            "<if test='examStatus != null'>AND exam_status = #{examStatus}</if>" +
            "</script>")
    Integer countByExamStatus(@Param("examId") Long examId, @Param("examStatus") Integer examStatus);
}

