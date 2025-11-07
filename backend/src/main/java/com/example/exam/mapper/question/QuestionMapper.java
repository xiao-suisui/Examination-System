package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyLevel;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.entity.question.Question;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 题目表Mapper接口（核心）
 *
 * 模块：题库管理模块（exam-question）
 * 职责：题目数据访问，支持复杂查询
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface QuestionMapper extends BaseMapper<Question> {

    /**
     * 分页查询题目列表（支持多条件筛选）
     *
     * @param page 分页对象
     * @param bankId 题库ID
     * @param questionType 题型
     * @param difficulty 难度
     * @param auditStatus 审核状态
     * @param knowledgeId 知识点ID
     * @param keyword 关键词（题目内容模糊搜索）
     * @return 题目分页列表
     */
    IPage<Question> selectQuestionPage(Page<Question> page,
                                        @Param("bankId") Long bankId,
                                        @Param("questionType") QuestionType questionType,
                                        @Param("difficulty") DifficultyLevel difficulty,
                                        @Param("auditStatus") AuditStatus auditStatus,
                                        @Param("knowledgeId") Long knowledgeId,
                                        @Param("keyword") String keyword);

    /**
     * 随机抽取题目（用于随机组卷）
     *
     * @param bankId 题库ID
     * @param questionType 题型
     * @param difficulty 难度
     * @param knowledgeIds 知识点ID列表（可选）
     * @param limit 抽取数量
     * @param excludeIds 排除的题目ID列表（避免重复）
     * @return 题目列表
     */
    List<Question> selectRandomQuestions(@Param("bankId") Long bankId,
                                          @Param("questionType") QuestionType questionType,
                                          @Param("difficulty") DifficultyLevel difficulty,
                                          @Param("knowledgeIds") List<Long> knowledgeIds,
                                          @Param("limit") Integer limit,
                                          @Param("excludeIds") List<Long> excludeIds);

    /**
     * 批量查询题目（含选项）
     *
     * @param questionIds 题目ID列表
     * @return 题目列表（含选项信息）
     */
    List<Question> selectQuestionsWithOptions(@Param("questionIds") List<Long> questionIds);

    /**
     * 统计题库中符合条件的题目数量
     *
     * @param bankId 题库ID
     * @param questionType 题型
     * @param difficulty 难度
     * @param knowledgeIds 知识点ID列表（可选）
     * @return 题目数量
     */
    Integer countQuestionsByCondition(@Param("bankId") Long bankId,
                                       @Param("questionType") QuestionType questionType,
                                       @Param("difficulty") DifficultyLevel difficulty,
                                       @Param("knowledgeIds") List<Long> knowledgeIds);
}

