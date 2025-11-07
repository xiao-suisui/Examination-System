package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
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
     */
    IPage<QuestionBank> pageQuestionBanks(Page<QuestionBank> page, String keyword, Boolean
            isPublic);

    /**
     * 获取题库统计信息
     */
    Object getQuestionBankStatistics(Long bankId);

    /**
     * 导入题目到题库
     */
    Object importQuestions(Long bankId, String fileContent);

    /**
     * 导出题库题目
     */
    Object exportQuestions(Long bankId);
}

