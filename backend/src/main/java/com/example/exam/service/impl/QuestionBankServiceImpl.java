package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.BankType;
import com.example.exam.entity.question.QuestionBank;
import com.example.exam.mapper.question.QuestionBankMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.service.QuestionBankService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 题库Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionBankServiceImpl extends ServiceImpl<QuestionBankMapper, QuestionBank> implements QuestionBankService {

    private final QuestionMapper questionMapper;

    @Override
    public IPage<QuestionBank> pageQuestionBanks(Page<QuestionBank> page, String keyword, BankType bank, Long subjectId) {
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

        //  科目ID筛选（新增）
        if (subjectId != null) {
            wrapper.eq(QuestionBank::getSubjectId, subjectId);
        }

        wrapper.orderByDesc(QuestionBank::getSort);

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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addQuestions(Long bankId, java.util.List<Long> questionIds) {
        // 验证题库是否存在
        QuestionBank bank = this.getById(bankId);
        if (bank == null) {
            throw new RuntimeException("题库不存在");
        }

        if (questionIds == null || questionIds.isEmpty()) {
            throw new RuntimeException("题目ID列表不能为空");
        }

        int successCount = 0;
        int skippedCount = 0;
        for (Long questionId : questionIds) {
            // 查询题目
            com.example.exam.entity.question.Question question = questionMapper.selectById(questionId);
            if (question == null) {
                log.warn("题目不存在: questionId={}", questionId);
                continue;
            }

            // 如果题目已经属于当前题库，跳过
            if (question.getBankId() != null && question.getBankId().equals(bankId)) {
                log.info("题目已在当前题库中: questionId={}, bankId={}", questionId, bankId);
                skippedCount++;
                continue;
            }

            // 如果题目属于其他题库，先从原题库移除（可选：根据业务需求决定）
            if (question.getBankId() != null) {
                log.warn("题目已属于题库 {}, 将从原题库移除并添加到题库 {}", question.getBankId(), bankId);
            }

            // 将题目添加到当前题库
            question.setBankId(bankId);
            int updateCount = questionMapper.updateById(question);
            if (updateCount > 0) {
                successCount++;
            }
        }

        // 更新题库的题目数量
        if (successCount > 0) {
            updateQuestionCount(bankId);
        }

        log.info("批量添加题目完成: 成功{}个, 跳过{}个", successCount, skippedCount);
        return successCount > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeQuestion(Long bankId, Long questionId) {
        log.info("开始移除题目: bankId={}, questionId={}", bankId, questionId);

        // 验证题库是否存在
        QuestionBank bank = this.getById(bankId);
        if (bank == null) {
            log.error("题库不存在: bankId={}", bankId);
            throw new RuntimeException("题库不存在");
        }

        // 查询题目
        com.example.exam.entity.question.Question question = questionMapper.selectById(questionId);
        if (question == null) {
            log.error("题目不存在: questionId={}", questionId);
            throw new RuntimeException("题目不存在");
        }

        log.info("题目信息: questionId={}, bankId={}, questionContent={}",
                 questionId, question.getBankId(),
                 question.getQuestionContent() != null ? question.getQuestionContent().substring(0, Math.min(20, question.getQuestionContent().length())) : "null");

        // 验证题目是否属于该题库
        if (question.getBankId() == null) {
            log.warn("题目不属于任何题库: questionId={}", questionId);
            throw new RuntimeException("题目不属于任何题库");
        }

        if (!question.getBankId().equals(bankId)) {
            log.error("题目不属于当前题库: questionId={}, 题目所属题库={}, 当前题库={}",
                     questionId, question.getBankId(), bankId);
            throw new RuntimeException("题目不属于该题库");
        }

        // 将题目的bankId设置为1
        log.info("将题目的bankId设置为1: questionId={}", questionId);

        question.setBankId(1L);
        int updateCount = questionMapper.updateById(question);
        log.info("更新题目结果: updateCount={}", updateCount);

        if (updateCount > 0) {
            // 更新题库的题目数量
            updateQuestionCount(bankId);
            log.info("移除题目成功: bankId={}, questionId={}", bankId, questionId);
        } else {
            log.error("更新题目失败: bankId={}, questionId={}", bankId, questionId);
        }

        return updateCount > 0;
    }

    /**
     * 更新题库的题目数量
     *
     * @param bankId 题库ID
     */
    private void updateQuestionCount(Long bankId) {
        QuestionBank bank = this.getById(bankId);
        if (bank != null) {
            Long questionCount = questionMapper.selectCount(
                new LambdaQueryWrapper<com.example.exam.entity.question.Question>()
                    .eq(com.example.exam.entity.question.Question::getBankId, bankId)
                    .eq(com.example.exam.entity.question.Question::getDeleted, 0)
            );
            bank.setQuestionCount(questionCount.intValue());
            this.updateById(bank);
        }
    }
}

