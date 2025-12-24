package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.question.QuestionBank;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 题库表Mapper接口
 * 模块：题库管理模块（exam-question）
 * 职责：题库数据访问
 *
 * <p>说明：使用 MyBatis-Plus 提供的 BaseMapper 方法，无需自定义 SQL</p>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-08
 */
@Mapper
public interface QuestionBankMapper extends BaseMapper<QuestionBank> {
    // 使用 MyBatis-Plus 的 BaseMapper 提供的通用方法
    // 复杂查询在 Service 层使用 LambdaQueryWrapper 实现

    /**
     * 获取题库统计信息
     *
     * @param bankId 题库ID
     * @return 统计信息
     */
    @Select("SELECT " +
            "bank_id AS bankId, " +
            "bank_name AS bankName, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND deleted = 0) AS totalQuestions, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type = 1 AND deleted = 0) AS singleChoiceCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type = 2 AND deleted = 0) AS multipleChoiceCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type = 4 AND deleted = 0) AS trueFalseCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type = 6 AND deleted = 0) AS fillBlankCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type = 7 AND deleted = 0) AS shortAnswerCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND question_type NOT IN (1,2,4,6,7) AND deleted = 0) AS otherCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND difficulty = 1 AND deleted = 0) AS easyCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND difficulty = 2 AND deleted = 0) AS mediumCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND difficulty = 3 AND deleted = 0) AS hardCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND audit_status = 2 AND deleted = 0) AS approvedCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND audit_status = 1 AND deleted = 0) AS pendingCount, " +
            "(SELECT COUNT(*) FROM question WHERE bank_id = #{bankId} AND audit_status = 3 AND deleted = 0) AS rejectedCount " +
            "FROM question_bank WHERE bank_id = #{bankId} AND deleted = 0")
    com.example.exam.dto.QuestionBankStatisticsDTO getStatistics(@org.apache.ibatis.annotations.Param("bankId") Long bankId);
}

