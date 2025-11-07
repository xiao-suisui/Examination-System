package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyLevel;
import com.example.exam.common.enums.QuestionType;
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
     * 分页查询题目
     */
    IPage<Question> pageQuestions(Page<Question> page, Long bankId, QuestionType questionType,
                                   DifficultyLevel difficulty, AuditStatus auditStatus,
                                   Long knowledgeId, String keyword);

    /**
     * 随机抽取题目
     */
    List<Question> randomSelectQuestions(Long bankId, QuestionType questionType,
                                          DifficultyLevel difficulty, List<Long> knowledgeIds,
                                          Integer limit, List<Long> excludeIds);

    /**
     * 批量查询题目（含选项）
     */
    List<Question> getQuestionsWithOptions(List<Long> questionIds);

    /**
     * 统计符合条件的题目数量
     */
    Integer countByCondition(Long bankId, QuestionType questionType,
                             DifficultyLevel difficulty, List<Long> knowledgeIds);

    /**
     * 审核题目
     */
    boolean auditQuestion(Long questionId, AuditStatus auditStatus, String remark, Long auditorId);
}

