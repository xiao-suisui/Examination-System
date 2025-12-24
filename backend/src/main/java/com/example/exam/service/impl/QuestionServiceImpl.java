package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.annotation.DataScope;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DataScopeType;
import com.example.exam.common.enums.DifficultyType;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.dto.QuestionDTO;
import com.example.exam.entity.question.Question;
import com.example.exam.entity.question.QuestionBank;
import com.example.exam.entity.question.QuestionOption;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.mapper.question.QuestionBankMapper;
import com.example.exam.mapper.question.QuestionOptionMapper;
import com.example.exam.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
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
    private final QuestionBankMapper questionBankMapper;

    @Override
    @DataScope(value = DataScopeType.SUBJECT, subjectIdField = "bank_id")
    public IPage<Question> pageQuestions(Page<Question> page, Long bankId, QuestionType questionType,
                                          DifficultyType difficulty, AuditStatus auditStatus,
                                          Long knowledgeId, String keyword, Long subjectId) {
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(bankId != null, Question::getBankId, bankId)
               .eq(questionType != null, Question::getQuestionType, questionType)
               .eq(difficulty != null, Question::getDifficulty, difficulty)
               .eq(auditStatus != null, Question::getAuditStatus, auditStatus)
               .like(keyword != null && !keyword.isEmpty(), Question::getQuestionContent, keyword)
               .orderByDesc(Question::getCreateTime);

        // ⭐ 科目ID筛选（需要通过题库关联）
        if (subjectId != null) {
            wrapper.inSql(Question::getBankId,
                "SELECT bank_id FROM question_bank WHERE subject_id = " + subjectId + " AND deleted = 0");
        }

        // 知识点筛选需要特殊处理（FIND_IN_SET）
        if (knowledgeId != null) {
            wrapper.apply("FIND_IN_SET({0}, knowledge_ids) > 0", knowledgeId);
        }

        return this.page(page, wrapper);
    }

    @Override
    public IPage<com.example.exam.dto.QuestionDTO> pageQuestionsDTO(Page<Question> page, Long bankId,
                                                                     QuestionType questionType,
                                                                     DifficultyType difficulty,
                                                                     AuditStatus auditStatus,
                                                                     Long knowledgeId, String keyword, Long subjectId) {
        IPage<Question> questionPage = pageQuestions(page, bankId, questionType, difficulty,
                                                     auditStatus, knowledgeId, keyword, subjectId);

        // 转换为DTO
        IPage<QuestionDTO> dtoPage = new Page<>();
        BeanUtils.copyProperties(questionPage, dtoPage, "records");

        List<QuestionDTO> dtoList = questionPage.getRecords().stream()
            .map(this::convertToQuestionDTO)
            .collect(java.util.stream.Collectors.toList());

        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    /**
     * 将Question实体转换为QuestionDTO
     */
    private QuestionDTO convertToQuestionDTO(Question question) {
        com.example.exam.dto.QuestionDTO dto = new com.example.exam.dto.QuestionDTO();
        org.springframework.beans.BeanUtils.copyProperties(question, dto);

        // 设置枚举名称（用于前端显示）
        if (question.getQuestionType() != null) {
            dto.setQuestionTypeName(question.getQuestionType().getName());

            dto.setQuestionType(question.getQuestionType().getCode());
        }

        if (question.getDifficulty() != null) {
            dto.setDifficultyName(question.getDifficulty().getName());
        }
        if (question.getAuditStatus() != null) {
            dto.setAuditStatusName(question.getAuditStatus().getName());
        }

        // 查询题库名称
        if (question.getBankId() != null) {

            QuestionBank bank = questionBankMapper.selectById(question.getBankId());
            if (bank != null) {
                dto.setBankName(bank.getBankName());
            }
        }

        // 查询选项列表（对于选择题和判断题）
        if (question.getQuestionType() != null) {
            QuestionType type = question.getQuestionType();
            if (type == QuestionType.SINGLE_CHOICE ||
                type == QuestionType.MULTIPLE_CHOICE ||
                type == QuestionType.INDEFINITE_CHOICE ||
                type == QuestionType.TRUE_FALSE) {

                LambdaQueryWrapper<QuestionOption> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(QuestionOption::getQuestionId, question.getQuestionId())
                       .eq(QuestionOption::getDeleted, 0)  // 只查询未删除的选项
                       .orderByAsc(QuestionOption::getOptionSeq);
                List<QuestionOption> options = questionOptionMapper.selectList(wrapper);
                dto.setOptions(options);

                // 提取正确答案选项序号
                if (options != null && !options.isEmpty()) {
                    String correctAnswer = options.stream()
                        .filter(opt -> opt.getIsCorrect() != null && opt.getIsCorrect() == 1)
                        .map(QuestionOption::getOptionSeq)
                        .collect(java.util.stream.Collectors.joining(","));

                    // 设置正确答案
                    if (!correctAnswer.isEmpty()) {
                        dto.setCorrectAnswer(correctAnswer);
                    }
                }
            } else if (type == QuestionType.FILL_BLANK) {
                // 填空题，使用 answerList 字段
                dto.setCorrectAnswer(question.getAnswerList());
            } else if (type == QuestionType.SUBJECTIVE) {
                // 主观题，使用 referenceAnswer 字段
                dto.setCorrectAnswer(question.getReferenceAnswer());
            }
        }

        return dto;
    }

    @Override
    public List<Question> randomSelectQuestions(Long bankId, QuestionType questionType,
                                                 DifficultyType difficulty, List<Long> knowledgeIds,
                                                 Integer limit, List<Long> excludeIds) {
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Question::getStatus, 1) // 只查询启用的题目
               .eq(Question::getAuditStatus, AuditStatus.APPROVED) // 只查询已审核通过的
               .eq(bankId != null, Question::getBankId, bankId)
               .eq(questionType != null, Question::getQuestionType, questionType)
               .eq(difficulty != null, Question::getDifficulty, difficulty)
               .notIn(excludeIds != null && !excludeIds.isEmpty(), Question::getQuestionId, excludeIds)
               .last("ORDER BY RAND() LIMIT " + (limit != null ? limit : 10));

        // 知识点筛选
        if (knowledgeIds != null && !knowledgeIds.isEmpty()) {
            wrapper.and(w -> {
                for (int i = 0; i < knowledgeIds.size(); i++) {
                    if (i == 0) {
                        w.apply("FIND_IN_SET({0}, knowledge_ids) > 0", knowledgeIds.get(i));
                    } else {
                        w.or().apply("FIND_IN_SET({0}, knowledge_ids) > 0", knowledgeIds.get(i));
                    }
                }
            });
        }

        return this.list(wrapper);
    }

    @Override
    public com.example.exam.dto.QuestionDTO getQuestionDTOById(Long questionId) {
        Question question = this.getById(questionId);
        if (question == null) {
            return null;
        }
        return convertToQuestionDTO(question);
    }

    @Override
    public List<Question> getQuestionsWithOptions(List<Long> questionIds) {
        // 直接批量查询题目
        if (questionIds == null || questionIds.isEmpty()) {
            return new ArrayList<>();
        }
        return this.listByIds(questionIds);
    }

    @Override
    public Integer countByCondition(Long bankId, QuestionType questionType,
                                     DifficultyType difficulty, List<Long> knowledgeIds) {
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Question::getStatus, 1) // 只统计启用的题目
               .eq(Question::getAuditStatus, AuditStatus.APPROVED) // 只统计已审核通过的
               .eq(bankId != null, Question::getBankId, bankId)
               .eq(questionType != null, Question::getQuestionType, questionType)
               .eq(difficulty != null, Question::getDifficulty, difficulty);

        // 知识点筛选
        if (knowledgeIds != null && !knowledgeIds.isEmpty()) {
            wrapper.and(w -> {
                for (int i = 0; i < knowledgeIds.size(); i++) {
                    if (i == 0) {
                        w.apply("FIND_IN_SET({0}, knowledge_ids) > 0", knowledgeIds.get(i));
                    } else {
                        w.or().apply("FIND_IN_SET({0}, knowledge_ids) > 0", knowledgeIds.get(i));
                    }
                }
            });
        }

        return Math.toIntExact(this.count(wrapper));
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
    public boolean saveQuestionWithOptions(Question question, List<QuestionOption> options) {
        // 1. 保存题目主表
        boolean saved = save(question);
        if (!saved) {
            return false;
        }

        // 2. 保存选项（如果有）
        if (options != null && !options.isEmpty()) {
            for (QuestionOption option : options) {
                option.setQuestionId(question.getQuestionId());
                questionOptionMapper.insert(option);
            }
        }

        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateQuestionWithOptions(Question question, List<QuestionOption> options) {
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
        if (options != null && !options.isEmpty()) {
            for (QuestionOption option : options) {
                option.setQuestionId(question.getQuestionId());
                option.setOptionId(null); // 清空ID，让数据库自动生成
                questionOptionMapper.insert(option);
            }
        }

        return true;
    }
}

