package com.example.exam.service.impl;

import com.example.exam.common.enums.QuestionType;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.question.Question;
import com.example.exam.entity.question.QuestionOption;
import com.example.exam.mapper.exam.ExamAnswerMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.mapper.question.QuestionOptionMapper;
import com.example.exam.service.AutoGradingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 自动判分Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AutoGradingServiceImpl implements AutoGradingService {

    private final QuestionOptionMapper questionOptionMapper;
    private final ExamAnswerMapper examAnswerMapper;
    private final QuestionMapper questionMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BigDecimal gradeQuestion(Question question, ExamAnswer answer) {
        QuestionType questionType = question.getQuestionType();

        // 题目类型为空或主观题不自动判分，直接返回，不更新分数
        if (questionType == null || questionType == QuestionType.SUBJECTIVE) {
            log.info("主观题跳过自动批改: questionId={}", question.getQuestionId());
            return BigDecimal.ZERO;
        }

        BigDecimal score = BigDecimal.ZERO;

        switch (questionType) {
            case SINGLE_CHOICE:
            case TRUE_FALSE:
                score = gradeSingleChoice(question, answer);
                break;
            case MULTIPLE_CHOICE:
                score = gradeMultipleChoice(question, answer);
                break;
            case INDEFINITE_CHOICE:
                score = gradeIndefiniteChoice(question, answer);
                break;
            case MATCHING:
                score = gradeMatching(question, answer);
                break;
            case SORT:
                score = gradeSort(question, answer);
                break;
            case FILL_BLANK:
                score = gradeFillBlank(question, answer);
                break;
            default:
                // 未知题型不处理
                log.warn("未知题型，跳过批改: questionId={}, type={}", question.getQuestionId(), questionType);
                return BigDecimal.ZERO;
        }

        // 只有客观题才更新答题记录的分数
        answer.setScore(score);
        answer.setIsCorrect(score.compareTo(BigDecimal.ZERO) > 0 ? 1 : 0);
        examAnswerMapper.updateById(answer);

        log.info("客观题自动批改完成: questionId={}, score={}", question.getQuestionId(), score);

        return score;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BigDecimal gradeSession(String sessionId) {
        // 查询所有答题记录
        List<ExamAnswer> answers = examAnswerMapper.selectBySessionId(sessionId);

        BigDecimal totalScore = BigDecimal.ZERO;

        for (ExamAnswer answer : answers) {
            // 从数据库获取完整的题目信息
            Question question = questionMapper.selectById(answer.getQuestionId());
            if (question == null) {
                log.warn("题目不存在，跳过批改: questionId={}", answer.getQuestionId());
                continue;
            }

            BigDecimal score = gradeQuestion(question, answer);
            totalScore = totalScore.add(score);
        }

        return totalScore;
    }

    /**
     * 单选题/判断题判分
     */
    private BigDecimal gradeSingleChoice(Question question, ExamAnswer answer) {
        List<QuestionOption> correctOptions = questionOptionMapper.selectCorrectOptionsByQuestionId(question.getQuestionId());

        if (correctOptions.isEmpty()) {
            return BigDecimal.ZERO;
        }

        String correctOptionId = correctOptions.get(0).getOptionId().toString();
        String userAnswer = answer.getOptionIds();

        return correctOptionId.equals(userAnswer) ? question.getDefaultScore() : BigDecimal.ZERO;
    }

    /**
     * 多选题判分（完全正确才得分）
     */
    private BigDecimal gradeMultipleChoice(Question question, ExamAnswer answer) {
        List<QuestionOption> correctOptions = questionOptionMapper.selectCorrectOptionsByQuestionId(question.getQuestionId());

        Set<String> correctSet = correctOptions.stream()
                .map(o -> o.getOptionId().toString())
                .collect(Collectors.toSet());

        Set<String> userSet = Arrays.stream(answer.getOptionIds().split(","))
                .collect(Collectors.toSet());

        return correctSet.equals(userSet) ? question.getDefaultScore() : BigDecimal.ZERO;
    }

    /**
     * 不定项选择题判分（部分得分）
     */
    private BigDecimal gradeIndefiniteChoice(Question question, ExamAnswer answer) {
        List<QuestionOption> correctOptions = questionOptionMapper.selectCorrectOptionsByQuestionId(question.getQuestionId());

        Set<String> correctSet = correctOptions.stream()
                .map(o -> o.getOptionId().toString())
                .collect(Collectors.toSet());

        Set<String> userSet = Arrays.stream(answer.getOptionIds().split(","))
                .collect(Collectors.toSet());

        // 如果选择了错误选项，得0分
        for (String userId : userSet) {
            if (!correctSet.contains(userId)) {
                return BigDecimal.ZERO;
            }
        }

        // 计算部分得分
        BigDecimal score = BigDecimal.ZERO;
        for (String userId : userSet) {
            QuestionOption option = correctOptions.stream()
                    .filter(o -> o.getOptionId().toString().equals(userId))
                    .findFirst()
                    .orElse(null);

            if (option != null && option.getScoreRatio() != null) {
                BigDecimal ratio = new BigDecimal(option.getScoreRatio()).divide(new BigDecimal(100), 2, RoundingMode.HALF_UP);
                score = score.add(question.getDefaultScore().multiply(ratio));
            }
        }

        return score;
    }

    /**
     * 匹配题判分
     */
    private BigDecimal gradeMatching(Question question, ExamAnswer answer) {
        // TODO: 实现匹配题判分逻辑
        return BigDecimal.ZERO;
    }

    /**
     * 排序题判分（逆序数法）
     */
    private BigDecimal gradeSort(Question question, ExamAnswer answer) {
        // TODO: 实现排序题判分逻辑（逆序数法）
        return BigDecimal.ZERO;
    }

    /**
     * 填空题判分（模糊匹配）
     */
    private BigDecimal gradeFillBlank(Question question, ExamAnswer answer) {
        String answerList = question.getAnswerList();
        String userAnswer = answer.getUserAnswer();

        if (answerList == null || userAnswer == null) {
            return BigDecimal.ZERO;
        }

        // 解析答案列表（格式：空1答案1,空1答案2|空2答案1）
        String[] blanks = answerList.split("\\|");
        String[] userAnswers = userAnswer.split("\\|");

        if (blanks.length != userAnswers.length) {
            return BigDecimal.ZERO;
        }

        int correctCount = 0;
        for (int i = 0; i < blanks.length; i++) {
            String[] correctAnswers = blanks[i].split(",");
            String userAns = userAnswers[i].trim();

            for (String correctAns : correctAnswers) {
                if (correctAns.trim().equalsIgnoreCase(userAns)) {
                    correctCount++;
                    break;
                }
            }
        }

        // 按比例得分
        BigDecimal ratio = new BigDecimal(correctCount).divide(new BigDecimal(blanks.length), 2, RoundingMode.HALF_UP);
        return question.getDefaultScore().multiply(ratio);
    }
}

