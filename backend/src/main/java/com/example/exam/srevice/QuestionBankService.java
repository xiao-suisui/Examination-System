package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.BankType;
import com.example.exam.entity.question.QuestionBank;

/**
 * 题库Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface QuestionBankService extends IService<QuestionBank> {

    /**
     * 分页查询题库
     *
     * @param page 分页参数
     * @param keyword 关键词
     * @param bank 题库类型
     * @param subjectId 科目ID
     * @return 分页结果
     */
    IPage<QuestionBank> pageQuestionBanks(Page<QuestionBank> page, String keyword, BankType bank, Long subjectId);

    /**
     * 获取题库统计信息
     *
     * @param bankId 题库ID
     * @return 统计信息
     */
    com.example.exam.dto.QuestionBankStatisticsDTO getQuestionBankStatistics(Long bankId);

    /**
     * 导入题目到题库
     */
    Object importQuestions(Long bankId, String fileContent);

    /**
     * 导出题库题目
     */
    Object exportQuestions(Long bankId);

    /**
     * 批量添加题目到题库
     *
     * @param bankId 题库ID
     * @param questionIds 题目ID列表
     * @return 是否添加成功
     */
    boolean addQuestions(Long bankId, java.util.List<Long> questionIds);

    /**
     * 从题库中移除题目
     *
     * @param bankId 题库ID
     * @param questionId 题目ID
     * @return 是否移除成功
     */
    boolean removeQuestion(Long bankId, Long questionId);
}

