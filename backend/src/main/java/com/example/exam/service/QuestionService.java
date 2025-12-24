package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyType;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.dto.QuestionDTO;
import com.example.exam.entity.question.Question;

import java.util.List;

/**
 * 题目Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface QuestionService extends IService<Question> {

    /**
     * 分页查询题目（返回Entity）
     *
     * @param page 分页参数
     * @param bankId 题库ID
     * @param questionType 题目类型
     * @param difficulty 难度
     * @param auditStatus 审核状态
     * @param knowledgeId 知识点ID
     * @param keyword 关键词
     * @param subjectId 科目ID
     * @return 分页结果
     */
    IPage<Question> pageQuestions(Page<Question> page, Long bankId, QuestionType questionType,
                                  DifficultyType difficulty, AuditStatus auditStatus,
                                  Long knowledgeId, String keyword, Long subjectId);

    /**
     * 分页查询题目（返回DTO，包含扩展信息）
     */
    IPage<QuestionDTO> pageQuestionsDTO(Page<Question> page, Long bankId, QuestionType questionType,
                                        DifficultyType difficulty, AuditStatus auditStatus,
                                        Long knowledgeId, String keyword, Long subjectId);

    /**
     * 根据ID查询题目详情（返回DTO，包含选项）
     */
    QuestionDTO getQuestionDTOById(Long questionId);

    /**
     * 随机抽取题目
     */
    List<Question> randomSelectQuestions(Long bankId, QuestionType questionType,
                                          DifficultyType difficulty, List<Long> knowledgeIds,
                                          Integer limit, List<Long> excludeIds);

    /**
     * 批量查询题目（含选项）
     */
    List<Question> getQuestionsWithOptions(List<Long> questionIds);

    /**
     * 统计符合条件的题目数量
     */
    Integer countByCondition(Long bankId, QuestionType questionType,
                             DifficultyType difficulty, List<Long> knowledgeIds);

    /**
     * 审核题目
     */
    boolean auditQuestion(Long questionId, AuditStatus auditStatus, String remark, Long auditorId);

    /**
     * 保存题目（含选项）
     *
     * @param question 题目信息
     * @param options 选项列表
     * @return 是否保存成功
     */
    boolean saveQuestionWithOptions(Question question, java.util.List<com.example.exam.entity.question.QuestionOption> options);

    /**
     * 更新题目（含选项）
     *
     * @param question 题目信息
     * @param options 选项列表
     * @return 是否更新成功
     */
    boolean updateQuestionWithOptions(Question question, java.util.List<com.example.exam.entity.question.QuestionOption> options);
}

