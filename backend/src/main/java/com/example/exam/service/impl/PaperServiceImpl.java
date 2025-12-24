package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
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
import java.util.stream.Collectors;

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

    private final PaperQuestionMapper paperQuestionMapper;
    private final QuestionMapper questionMapper;

    @Override
    public IPage<Paper> pagePapers(Page<Paper> page, String keyword, Integer paperType, Long createUserId) {
        LambdaQueryWrapper<Paper> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(keyword != null && !keyword.isEmpty(), Paper::getPaperName, keyword)
               .eq(paperType != null, Paper::getPaperType, paperType)
               .eq(createUserId != null, Paper::getCreateUserId, createUserId)
               .orderByDesc(Paper::getCreateTime);
        return this.page(page, wrapper);
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
            paper.setPaperType(2); // 2-随机组卷
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
            newPaper.setAuditStatus(0); // 新试卷默认为草稿状态
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
}

