package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.question.Question;
import com.example.exam.entity.question.QuestionOption;
import com.example.exam.mapper.exam.ExamAnswerMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.mapper.question.QuestionOptionMapper;
import com.example.exam.service.ExamAnswerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 答题记录ServiceImpl
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExamAnswerServiceImpl extends ServiceImpl<ExamAnswerMapper, ExamAnswer> implements ExamAnswerService {

    private final QuestionMapper questionMapper;
    private final QuestionOptionMapper questionOptionMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveAnswer(ExamAnswer answer) {
        try {
            // 查询是否已存在答案
            LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamAnswer::getSessionId, answer.getSessionId())
                   .eq(ExamAnswer::getQuestionId, answer.getQuestionId());
            ExamAnswer existing = getOne(wrapper);

            if (existing != null) {
                // 更新现有答案
                answer.setAnswerId(existing.getAnswerId());
                return updateById(answer);
            } else {
                // 插入新答案
                return save(answer);
            }
        } catch (Exception e) {
            log.error("保存答案失败", e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveAnswers(List<ExamAnswer> answers) {
        try {
            for (ExamAnswer answer : answers) {
                if (!saveAnswer(answer)) {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            log.error("批量保存答案失败", e);
            return false;
        }
    }

    @Override
    public List<ExamAnswer> getSessionAnswers(String sessionId) {
        LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExamAnswer::getSessionId, sessionId);
        wrapper.orderByAsc(ExamAnswer::getQuestionId);
        return list(wrapper);
    }

    @Override
    public ExamAnswer getAnswer(String sessionId, Long questionId) {
        LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExamAnswer::getSessionId, sessionId);
        wrapper.eq(ExamAnswer::getQuestionId, questionId);
        return getOne(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateAnswer(ExamAnswer answer) {
        return updateById(answer);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteAnswer(String sessionId, Long questionId) {
        LambdaQueryWrapper<ExamAnswer> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExamAnswer::getSessionId, sessionId);
        wrapper.eq(ExamAnswer::getQuestionId, questionId);
        return remove(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean autoGradeObjectiveQuestions(String sessionId) {
        try {
            // 获取该会话的所有答案
            List<ExamAnswer> answers = getSessionAnswers(sessionId);
            if (answers.isEmpty()) {
                return true;
            }

            // 批量查询题目信息
            List<Long> questionIds = answers.stream()
                    .map(ExamAnswer::getQuestionId)
                    .collect(Collectors.toList());
            List<Question> questions = questionMapper.selectBatchIds(questionIds);
            Map<Long, Question> questionMap = questions.stream()
                    .collect(Collectors.toMap(Question::getQuestionId, q -> q));

            // 批改每个答案
            for (ExamAnswer answer : answers) {
                Question question = questionMap.get(answer.getQuestionId());
                if (question == null) {
                    continue;
                }

                // 只批改客观题（单选、多选、判断）
                int questionType = question.getQuestionType().getCode();
                if (questionType == 1 || questionType == 2 || questionType == 3) {
                    boolean isCorrect = gradeObjectiveQuestion(answer, question);
                    answer.setIsCorrect(isCorrect ? 1 : 0);
                    answer.setScore(isCorrect ? question.getDefaultScore() : BigDecimal.ZERO);
                    updateById(answer);
                }
            }

            log.info("自动批改完成: sessionId={}, count={}", sessionId, answers.size());
            return true;
        } catch (Exception e) {
            log.error("自动批改失败", e);
            return false;
        }
    }

    /**
     * 批改客观题
     */
    private boolean gradeObjectiveQuestion(ExamAnswer answer, Question question) {
        try {
            // 获取正确答案（选项ID）
            LambdaQueryWrapper<QuestionOption> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(QuestionOption::getQuestionId, question.getQuestionId());
            wrapper.eq(QuestionOption::getIsCorrect, 1);
            List<QuestionOption> correctOptions = questionOptionMapper.selectList(wrapper);

            if (correctOptions.isEmpty()) {
                log.warn("题目没有正确答案: questionId={}", question.getQuestionId());
                return false;
            }

            // 获取正确答案ID集合
            Set<Long> correctOptionIds = correctOptions.stream()
                    .map(QuestionOption::getOptionId)
                    .collect(Collectors.toSet());

            // 获取学生答案ID集合
            Set<Long> studentOptionIds = new HashSet<>();
            if (answer.getOptionIds() != null && !answer.getOptionIds().isEmpty()) {
                String[] ids = answer.getOptionIds().split(",");
                for (String id : ids) {
                    try {
                        studentOptionIds.add(Long.parseLong(id.trim()));
                    } catch (NumberFormatException e) {
                        log.warn("无效的选项ID: {}", id);
                    }
                }
            }

            // 判断是否正确（必须完全一致）
            return correctOptionIds.equals(studentOptionIds);
        } catch (Exception e) {
            log.error("批改题目失败: questionId={}", question.getQuestionId(), e);
            return false;
        }
    }
}

