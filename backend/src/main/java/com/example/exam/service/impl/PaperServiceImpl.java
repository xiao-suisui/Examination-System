package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.PaperType;
import com.example.exam.entity.paper.Paper;
import com.example.exam.entity.paper.PaperQuestion;
import com.example.exam.entity.paper.PaperRule;
import com.example.exam.entity.question.Question;
import com.example.exam.mapper.paper.PaperMapper;
import com.example.exam.mapper.paper.PaperQuestionMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.service.PaperService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

/**
 * 试卷Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PaperServiceImpl extends ServiceImpl<PaperMapper, Paper> implements PaperService {

    private final PaperMapper paperMapper;
    private final PaperQuestionMapper paperQuestionMapper;
    private final QuestionMapper questionMapper;
    private final com.example.exam.mapper.paper.PaperRuleMapper paperRuleMapper;
    private final com.example.exam.mapper.exam.ExamMapper examMapper;

    @Override
    public IPage<Paper> pagePapers(Page<Paper> page, String keyword, Long bankId, PaperType paperType, AuditStatus auditStatus) {
        LambdaQueryWrapper<Paper> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(keyword != null && !keyword.isEmpty(), Paper::getPaperName, keyword)
               .eq(paperType != null, Paper::getPaperType, paperType)
               .eq(auditStatus != null, Paper::getAuditStatus, auditStatus)
               .orderByDesc(Paper::getCreateTime);

        IPage<Paper> result = this.page(page, wrapper);

        // 填充每个试卷的扩展信息
        result.getRecords().forEach(paper -> enrichPaperInfo(paper, bankId));

        return result;
    }

    /**
     * 填充试卷的扩展信息（题目数量、题库名称、状态）
     *
     * @param paper 试卷对象
     * @param filterBankId 过滤的题库ID（如果不为null，只返回该题库的试卷）
     */
    private void enrichPaperInfo(Paper paper, Long filterBankId) {
        try {
            Long paperBankId = null;
            int questionCount = 0;

            // 1. 优先从PaperRule表查询（自动组卷/随机组卷）
            LambdaQueryWrapper<PaperRule> ruleWrapper = new LambdaQueryWrapper<>();
            ruleWrapper.eq(PaperRule::getPaperId, paper.getPaperId());
            List<PaperRule> rules = paperRuleMapper.selectList(ruleWrapper);

            if (rules != null && !rules.isEmpty()) {
                // 获取第一个规则的题库ID
                paperBankId = rules.get(0).getBankId();
                // 累加所有规则的题目数量
                questionCount = rules.stream()
                    .mapToInt(rule -> rule.getTotalNum() != null ? rule.getTotalNum() : 0)
                    .sum();
            }

            // 2. 如果没有规则，从PaperQuestion表查询（手动组卷）
            if (questionCount == 0) {
                LambdaQueryWrapper<PaperQuestion> pqWrapper = new LambdaQueryWrapper<>();
                pqWrapper.eq(PaperQuestion::getPaperId, paper.getPaperId());
                Long count = paperQuestionMapper.selectCount(pqWrapper);
                questionCount = count != null ? count.intValue() : 0;

                // 查询题库ID（从第一道题目获取）
                if (questionCount > 0) {
                    pqWrapper.last("LIMIT 1");
                    PaperQuestion pq = paperQuestionMapper.selectOne(pqWrapper);
                    if (pq != null) {
                        Question question = questionMapper.selectById(pq.getQuestionId());
                        if (question != null) {
                            paperBankId = question.getBankId();
                        }
                    }
                }
            }

            // 如果指定了过滤题库ID，且当前试卷不属于该题库，跳过
            if (filterBankId != null && paperBankId != null && !filterBankId.equals(paperBankId)) {
                return;
            }

            // 3. 设置题目数量
            paper.setQuestionCount(questionCount);

            // 4. 查询并设置题库名称
            if (paperBankId != null) {
                String bankName = paperMapper.selectBankNameById(paperBankId);
                paper.setBankName(bankName != null ? bankName : "");
                paper.setBankId(paperBankId);
            } else {
                paper.setBankName("");
                paper.setBankId(null);
            }

        } catch (Exception e) {
            log.warn("填充试卷信息失败，paperId: {}", paper.getPaperId(), e);
            // 设置默认值，避免前端显示异常
            paper.setQuestionCount(0);
            paper.setBankName("");
        }
    }

    @Override
    public Paper getPaperWithQuestions(Long paperId) {
        Paper paper = this.getById(paperId);
        if (paper != null) {
            // 查询试卷的所有题目
            LambdaQueryWrapper<PaperQuestion> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaperQuestion::getPaperId, paperId)
                   .orderByAsc(PaperQuestion::getSortOrder);
            List<PaperQuestion> paperQuestions = paperQuestionMapper.selectList(wrapper);

            if (!paperQuestions.isEmpty()) {
                // TODO: 如果需要返回题目详情，可以在Paper实体中添加@TableField(exist = false)的questions字段
                // 然后批量查询题目并设置到paper对象中
                log.info("试卷{}包含{}道题目", paperId, paperQuestions.size());
            }
        }
        return paper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long autoGeneratePaper(Paper paper, PaperRule[] rules) {
        try {
            // 1. 保存试卷基本信息
            paper.setPaperType(PaperType.AUTO); // 自动组卷
            if (!this.save(paper)) {
                log.error("保存试卷失败");
                return null;
            }

            Long paperId = paper.getPaperId();
            int questionOrder = 1;
            BigDecimal totalScore = BigDecimal.ZERO;

            // 2. 根据规则随机抽取题目
            for (PaperRule rule : rules) {
                LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(rule.getBankId() != null, Question::getBankId, rule.getBankId())
                       .eq(rule.getQuestionType() != null, Question::getQuestionType, rule.getQuestionType())
                       .eq(Question::getStatus, 1) // 只选启用的题目
                       .last("ORDER BY RAND() LIMIT " + rule.getTotalNum());

                List<Question> questions = questionMapper.selectList(wrapper);

                if (questions.size() < rule.getTotalNum()) {
                    log.warn("题目数量不足，需要{}道，实际只有{}道", rule.getTotalNum(), questions.size());
                }

                // 3. 添加题目到试卷
                for (Question question : questions) {
                    PaperQuestion paperQuestion = new PaperQuestion();
                    paperQuestion.setPaperId(paperId);
                    paperQuestion.setQuestionId(question.getQuestionId());
                    paperQuestion.setQuestionScore(rule.getSingleScore());
                    paperQuestion.setSortOrder(questionOrder++);
                    paperQuestionMapper.insert(paperQuestion);

                    totalScore = totalScore.add(rule.getSingleScore());
                }
            }

            // 4. 更新试卷的总分（paper表没有questionCount字段）
            paper.setTotalScore(totalScore);
            this.updateById(paper);

            log.info("自动组卷成功，试卷ID: {}, 题目数: {}, 总分: {}", paperId, questionOrder - 1, totalScore);
            return paperId;

        } catch (Exception e) {
            log.error("自动组卷失败", e);
            throw new RuntimeException("自动组卷失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addQuestionsToPaper(Long paperId, Long[] questionIds) {
        try {
            Paper paper = this.getById(paperId);
            if (paper == null) {
                log.error("试卷不存在: {}", paperId);
                return false;
            }

            // 获取当前试卷的最大题目顺序号
            LambdaQueryWrapper<PaperQuestion> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaperQuestion::getPaperId, paperId)
                   .orderByDesc(PaperQuestion::getSortOrder)
                   .last("LIMIT 1");
            PaperQuestion lastQuestion = paperQuestionMapper.selectOne(wrapper);
            int nextOrder = lastQuestion != null ? lastQuestion.getSortOrder() + 1 : 1;

            // 添加题目到试卷
            BigDecimal totalScore = paper.getTotalScore() != null ? paper.getTotalScore() : BigDecimal.ZERO;
            for (Long questionId : questionIds) {
                Question question = questionMapper.selectById(questionId);
                if (question != null) {
                    PaperQuestion paperQuestion = new PaperQuestion();
                    paperQuestion.setPaperId(paperId);
                    paperQuestion.setQuestionId(questionId);
                    paperQuestion.setQuestionScore(question.getDefaultScore());
                    paperQuestion.setSortOrder(nextOrder++);
                    paperQuestionMapper.insert(paperQuestion);

                    totalScore = totalScore.add(question.getDefaultScore());
                }
            }

            // 更新试卷总分
            paper.setTotalScore(totalScore);
            this.updateById(paper);

            log.info("添加题目到试卷成功，试卷ID: {}, 新增题目数: {}", paperId, questionIds.length);
            return true;

        } catch (Exception e) {
            log.error("添加题目到试卷失败", e);
            throw new RuntimeException("添加题目失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeQuestionsFromPaper(Long paperId, Long[] questionIds) {
        try {
            Paper paper = this.getById(paperId);
            if (paper == null) {
                log.error("试卷不存在: {}", paperId);
                return false;
            }

            List<Long> questionIdList = Arrays.asList(questionIds);

            // 获取要删除的题目分数
            LambdaQueryWrapper<PaperQuestion> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaperQuestion::getPaperId, paperId)
                   .in(PaperQuestion::getQuestionId, questionIdList);
            List<PaperQuestion> paperQuestions = paperQuestionMapper.selectList(wrapper);

            BigDecimal removedScore = paperQuestions.stream()
                    .map(PaperQuestion::getQuestionScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // 删除题目
            paperQuestionMapper.delete(wrapper);

            // 更新试卷总分
            paper.setTotalScore(paper.getTotalScore().subtract(removedScore));
            this.updateById(paper);

            log.info("从试卷移除题目成功，试卷ID: {}, 移除题目数: {}", paperId, questionIds.length);
            return true;

        } catch (Exception e) {
            log.error("从试卷移除题目失败", e);
            throw new RuntimeException("移除题目失败: " + e.getMessage());
        }
    }

    @Override
    public Paper previewPaper(Long paperId) {
        Paper paper = this.getPaperWithQuestions(paperId);
        if (paper != null) {
            // 预览模式下不显示答案（这里可以在获取题目时过滤答案字段）
            log.info("预览试卷: {}", paperId);
        }
        return paper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long copyPaper(Long paperId, String newTitle) {
        try {
            // 1. 复制试卷基本信息
            Paper originalPaper = this.getById(paperId);
            if (originalPaper == null) {
                log.error("原试卷不存在: {}", paperId);
                return null;
            }

            Paper newPaper = new Paper();
            newPaper.setPaperName(newTitle);
            newPaper.setDescription(originalPaper.getDescription());
            newPaper.setPaperType(originalPaper.getPaperType());
            newPaper.setPassScore(originalPaper.getPassScore());
            newPaper.setTotalScore(originalPaper.getTotalScore());
            newPaper.setCreateUserId(originalPaper.getCreateUserId());
            newPaper.setOrgId(originalPaper.getOrgId());
            newPaper.setAuditStatus(AuditStatus.DRAFT); // 新试卷默认为草稿状态
            newPaper.setPublishStatus(0); // 默认未发布

            if (!this.save(newPaper)) {
                log.error("保存新试卷失败");
                return null;
            }

            Long newPaperId = newPaper.getPaperId();

            // 2. 复制试卷题目关联
            LambdaQueryWrapper<PaperQuestion> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaperQuestion::getPaperId, paperId)
                   .orderByAsc(PaperQuestion::getSortOrder);
            List<PaperQuestion> originalQuestions = paperQuestionMapper.selectList(wrapper);

            for (PaperQuestion originalPQ : originalQuestions) {
                PaperQuestion newPQ = new PaperQuestion();
                newPQ.setPaperId(newPaperId);
                newPQ.setQuestionId(originalPQ.getQuestionId());
                newPQ.setQuestionScore(originalPQ.getQuestionScore());
                newPQ.setSortOrder(originalPQ.getSortOrder());
                paperQuestionMapper.insert(newPQ);
            }

            log.info("复制试卷成功，原试卷ID: {}, 新试卷ID: {}, 题目数: {}",
                    paperId, newPaperId, originalQuestions.size());
            return newPaperId;

        } catch (Exception e) {
            log.error("复制试卷失败", e);
            throw new RuntimeException("复制试卷失败: " + e.getMessage());
        }
    }

    @Override
    public com.example.exam.dto.PaperStatisticsDTO getPaperStatistics(Long paperId) {
        try {
            // 获取试卷基本信息
            Paper paper = this.getById(paperId);
            if (paper == null) {
                return null;
            }

            // 获取试卷中的所有题目
            LambdaQueryWrapper<PaperQuestion> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaperQuestion::getPaperId, paperId);
            List<PaperQuestion> paperQuestions = paperQuestionMapper.selectList(wrapper);

            if (paperQuestions.isEmpty()) {
                // 如果没有题目，返回基本统计
                return com.example.exam.dto.PaperStatisticsDTO.builder()
                        .paperId(paperId)
                        .paperName(paper.getPaperName())
                        .totalQuestions(0)
                        .singleChoiceCount(0)
                        .multipleChoiceCount(0)
                        .trueFalseCount(0)
                        .fillBlankCount(0)
                        .shortAnswerCount(0)
                        .otherCount(0)
                        .easyCount(0)
                        .mediumCount(0)
                        .hardCount(0)
                        .totalScore(paper.getTotalScore())
                        .passScore(paper.getPassScore())
                        .duration(null)  // paper表没有duration字段，时长在exam表中
                        .usageCount(0)
                        .build();
            }

            // 获取题目ID列表
            List<Long> questionIds = paperQuestions.stream()
                    .map(PaperQuestion::getQuestionId)
                    .collect(java.util.stream.Collectors.toList());

            // 查询题目详情
            LambdaQueryWrapper<com.example.exam.entity.question.Question> questionWrapper =
                new LambdaQueryWrapper<>();
            questionWrapper.in(com.example.exam.entity.question.Question::getQuestionId, questionIds);
            List<com.example.exam.entity.question.Question> questions =
                questionMapper.selectList(questionWrapper);

            // 统计各类型题目数量
            int singleChoiceCount = 0, multipleChoiceCount = 0, trueFalseCount = 0;
            int fillBlankCount = 0, shortAnswerCount = 0, otherCount = 0;
            int easyCount = 0, mediumCount = 0, hardCount = 0;

            for (com.example.exam.entity.question.Question q : questions) {
                // 统计题型
                if (q.getQuestionType() != null) {
                    switch (q.getQuestionType().getCode()) {
                        case 1: singleChoiceCount++; break;
                        case 2: multipleChoiceCount++; break;
                        case 4: trueFalseCount++; break;
                        case 6: fillBlankCount++; break;
                        case 7: shortAnswerCount++; break;
                        default: otherCount++; break;
                    }
                }

                // 统计难度
                if (q.getDifficulty() != null) {
                    switch (q.getDifficulty().getType()) {
                        case 1: easyCount++; break;
                        case 2: mediumCount++; break;
                        case 3: hardCount++; break;
                    }
                }
            }

            // 统计使用次数（被多少场考试使用）
            LambdaQueryWrapper<com.example.exam.entity.exam.Exam> examWrapper =
                new LambdaQueryWrapper<>();
            examWrapper.eq(com.example.exam.entity.exam.Exam::getPaperId, paperId);
            long usageCount = examMapper.selectCount(examWrapper);

            return com.example.exam.dto.PaperStatisticsDTO.builder()
                    .paperId(paperId)
                    .paperName(paper.getPaperName())
                    .totalQuestions(questions.size())
                    .singleChoiceCount(singleChoiceCount)
                    .multipleChoiceCount(multipleChoiceCount)
                    .trueFalseCount(trueFalseCount)
                    .fillBlankCount(fillBlankCount)
                    .shortAnswerCount(shortAnswerCount)
                    .otherCount(otherCount)
                    .easyCount(easyCount)
                    .mediumCount(mediumCount)
                    .hardCount(hardCount)
                    .totalScore(paper.getTotalScore())
                    .passScore(paper.getPassScore())
                    .duration(null)  // paper表没有duration字段，时长在exam表中设置
                    .usageCount((int) usageCount)
                    .build();

        } catch (Exception e) {
            log.error("获取试卷统计信息失败", e);
            return null;
        }
    }
}

