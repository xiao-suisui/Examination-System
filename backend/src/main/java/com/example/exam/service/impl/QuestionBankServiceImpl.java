package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.BankType;
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
    public IPage<QuestionBank> pageQuestionBanks(Page<QuestionBank> page, String keyword, BankType bank) {
        LambdaQueryWrapper<QuestionBank> wrapper = new LambdaQueryWrapper<>();

        // 关键词模糊查询（题库名称或描述）
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.and(w -> w.like(QuestionBank::getBankName, keyword)
                             .or()
                             .like(QuestionBank::getDescription, keyword));
        }

        // 题库类型筛选
        if (bank != null) {
            wrapper.eq(QuestionBank::getBankType, bank);
        }

        // 按创建时间倒序排列
        wrapper.orderByDesc(QuestionBank::getCreateTime);

        return baseMapper.selectPage(page, wrapper);
    }

    @Override
    public com.example.exam.dto.QuestionBankStatisticsDTO getQuestionBankStatistics(Long bankId) {
        // 调用Mapper查询统计信息
        return baseMapper.getStatistics(bankId);
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

