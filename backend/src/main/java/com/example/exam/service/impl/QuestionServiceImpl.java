package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyType;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.entity.question.Question;
import com.example.exam.entity.question.QuestionOption;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.mapper.question.QuestionOptionMapper;
import com.example.exam.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 题目Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Service
@RequiredArgsConstructor
public class QuestionServiceImpl extends ServiceImpl<QuestionMapper, Question> implements QuestionService {

    private final QuestionOptionMapper questionOptionMapper;

    @Override
    public IPage<Question> pageQuestions(Page<Question> page, Long bankId, QuestionType questionType,
                                          DifficultyType difficulty, AuditStatus auditStatus,
                                          Long knowledgeId, String keyword) {
        return baseMapper.selectQuestionPage(page, bankId, questionType, difficulty,
                auditStatus, knowledgeId, keyword);
    }

    @Override
    public List<Question> randomSelectQuestions(Long bankId, QuestionType questionType,
                                                 DifficultyType difficulty, List<Long> knowledgeIds,
                                                 Integer limit, List<Long> excludeIds) {
        return baseMapper.selectRandomQuestions(bankId, questionType, difficulty,
                knowledgeIds, limit, excludeIds);
    }

    @Override
    public List<Question> getQuestionsWithOptions(List<Long> questionIds) {
        return baseMapper.selectQuestionsWithOptions(questionIds);
    }

    @Override
    public Integer countByCondition(Long bankId, QuestionType questionType,
                                     DifficultyType difficulty, List<Long> knowledgeIds) {
        return baseMapper.countQuestionsByCondition(bankId, questionType, difficulty, knowledgeIds);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean auditQuestion(Long questionId, AuditStatus auditStatus, String remark, Long auditorId) {
        Question question = new Question();
        question.setQuestionId(questionId);
        question.setAuditStatus(auditStatus);
        question.setAuditRemark(remark);
        question.setAuditorId(auditorId);
        question.setAuditTime(LocalDateTime.now());
        return updateById(question);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveQuestionWithOptions(Question question) {
        // 1. 保存题目主表
        boolean saved = save(question);
        if (!saved) {
            return false;
        }

        // 2. 保存选项（如果有）
        if (question.getOptions() != null && !question.getOptions().isEmpty()) {
            for (QuestionOption option : question.getOptions()) {
                option.setQuestionId(question.getQuestionId());
                questionOptionMapper.insert(option);
            }
        }

        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateQuestionWithOptions(Question question) {
        // 1. 更新题目主表
        boolean updated = updateById(question);
        if (!updated) {
            return false;
        }

        // 2. 删除旧选项
        LambdaQueryWrapper<QuestionOption> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionOption::getQuestionId, question.getQuestionId());
        questionOptionMapper.delete(wrapper);

        // 3. 保存新选项（如果有）
        if (question.getOptions() != null && !question.getOptions().isEmpty()) {
            for (QuestionOption option : question.getOptions()) {
                option.setQuestionId(question.getQuestionId());
                option.setOptionId(null); // 清空ID，让数据库自动生成
                questionOptionMapper.insert(option);
            }
        }

        return true;
    }
}

