package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.question.QuestionBank;
import com.example.exam.mapper.question.QuestionBankMapper;
import com.example.exam.service.QuestionBankService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 题库Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Service
@RequiredArgsConstructor
public class QuestionBankServiceImpl extends ServiceImpl<QuestionBankMapper, QuestionBank> implements QuestionBankService {

    @Override
    public IPage<QuestionBank> pageQuestionBanks(Page<QuestionBank> page, String keyword, Boolean isPublic) {
        LambdaQueryWrapper<QuestionBank> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(QuestionBank::getBankName, keyword)
                             .or()
                             .like(QuestionBank::getDescription, keyword));
        }

        // 公开/私有筛选
        if (isPublic != null) {
            wrapper.eq(QuestionBank::getBankType, isPublic ? "PUBLIC" : "PRIVATE");
        }

        wrapper.orderByDesc(QuestionBank::getCreateTime);
        return this.page(page, wrapper);
    }

    @Override
    public Object getQuestionBankStatistics(Long bankId) {
        // TODO: 实现题库统计信息查询
        // 包括：题目总数、各类型题目数量、难度分布等
        QuestionBank questionBank = this.getById(bankId);
        if (questionBank == null) {
            return null;
        }

        // 这里应该调用QuestionMapper统计各类数据
        // 暂时返回基本信息
        return questionBank;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Object importQuestions(Long bankId, String fileContent) {
        // TODO: 实现题目导入功能
        // 支持Excel、JSON等格式导入
        return "导入功能待实现";
    }

    @Override
    public Object exportQuestions(Long bankId) {
        // TODO: 实现题目导出功能
        // 导出为Excel或JSON格式
        return "导出功能待实现";
    }
}

