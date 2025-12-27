package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.entity.exam.ExamViolation;
import com.example.exam.mapper.exam.ExamAnswerMapper;
import com.example.exam.mapper.exam.ExamSessionMapper;
import com.example.exam.mapper.exam.ExamViolationMapper;
import com.example.exam.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 统计分析Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StatisticsServiceImpl implements StatisticsService {

    private final ExamSessionMapper examSessionMapper;
    private final ExamViolationMapper examViolationMapper;
    private final ExamAnswerMapper examAnswerMapper;

    @Override
    public Object getExamOverview(Long examId) {
        try {
            // 查询该考试的所有会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId);
            List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

            if (sessions.isEmpty()) {
                return createEmptyOverview();
            }

            // 统计数据
            long totalStudents = sessions.size();
            long submittedCount = sessions.stream()
                    .filter(s -> s.getSubmitTime() != null)
                    .count();

            List<BigDecimal> scores = sessions.stream()
                    .filter(s -> s.getTotalScore() != null)
                    .map(ExamSession::getTotalScore)
                    .collect(Collectors.toList());

            BigDecimal averageScore = scores.isEmpty() ? BigDecimal.ZERO :
                    scores.stream()
                            .reduce(BigDecimal.ZERO, BigDecimal::add)
                            .divide(BigDecimal.valueOf(scores.size()), 2, RoundingMode.HALF_UP);

            BigDecimal maxScore = scores.isEmpty() ? BigDecimal.ZERO :
                    scores.stream().max(BigDecimal::compareTo).orElse(BigDecimal.ZERO);

            BigDecimal minScore = scores.isEmpty() ? BigDecimal.ZERO :
                    scores.stream().min(BigDecimal::compareTo).orElse(BigDecimal.ZERO);

            // 及格率（假设60分及格）
            long passCount = scores.stream()
                    .filter(score -> score.compareTo(BigDecimal.valueOf(60)) >= 0)
                    .count();
            double passRate = scores.isEmpty() ? 0 : (passCount * 100.0 / scores.size());

            Map<String, Object> overview = new HashMap<>();
            overview.put("totalStudents", totalStudents);
            overview.put("submittedCount", submittedCount);
            overview.put("absentCount", totalStudents - submittedCount);
            overview.put("averageScore", averageScore);
            overview.put("maxScore", maxScore);
            overview.put("minScore", minScore);
            overview.put("passCount", passCount);
            overview.put("passRate", passRate);

            log.info("考试统计概览: examId={}, totalStudents={}, averageScore={}",
                    examId, totalStudents, averageScore);

            return overview;
        } catch (Exception e) {
            log.error("获取考试统计概览失败", e);
            return createEmptyOverview();
        }
    }

    @Override
    public Object getScoreDistribution(Long examId) {
        try {
            // 查询该考试的所有会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId)
                   .isNotNull(ExamSession::getTotalScore);
            List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

            if (sessions.isEmpty()) {
                return createEmptyDistribution();
            }

            // 按分数段统计（0-59, 60-69, 70-79, 80-89, 90-100）
            Map<String, Long> distribution = new LinkedHashMap<>();
            distribution.put("0-59", 0L);
            distribution.put("60-69", 0L);
            distribution.put("70-79", 0L);
            distribution.put("80-89", 0L);
            distribution.put("90-100", 0L);

            for (ExamSession session : sessions) {
                BigDecimal score = session.getTotalScore();
                int scoreInt = score.intValue();

                if (scoreInt < 60) {
                    distribution.merge("0-59", 1L, Long::sum);
                } else if (scoreInt < 70) {
                    distribution.merge("60-69", 1L, Long::sum);
                } else if (scoreInt < 80) {
                    distribution.merge("70-79", 1L, Long::sum);
                } else if (scoreInt < 90) {
                    distribution.merge("80-89", 1L, Long::sum);
                } else {
                    distribution.merge("90-100", 1L, Long::sum);
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("distribution", distribution);
            result.put("total", sessions.size());

            log.info("成绩分布统计: examId={}, total={}", examId, sessions.size());
            return result;
        } catch (Exception e) {
            log.error("获取成绩分布失败", e);
            return createEmptyDistribution();
        }
    }

    @Override
    public Object getQuestionStatistics(Long questionId, Long examId) {
        try {
            // TODO: 实现题目统计（需要关联答题记录）
            Map<String, Object> statistics = new HashMap<>();
            statistics.put("questionId", questionId);
            statistics.put("examId", examId);
            statistics.put("totalAttempts", 0);
            statistics.put("correctCount", 0);
            statistics.put("correctRate", 0.0);
            statistics.put("averageScore", BigDecimal.ZERO);

            log.info("题目统计: questionId={}, examId={}", questionId, examId);
            return statistics;
        } catch (Exception e) {
            log.error("获取题目统计失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getKnowledgeMastery(Long userId, Long bankId) {
        try {
            // TODO: 实现知识点掌握度分析
            log.info("知识点掌握度: userId={}, bankId={}", userId, bankId);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("获取知识点掌握度失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getStudentReport(Long userId, Long examId, LocalDateTime startTime, LocalDateTime endTime) {
        try {
            // 查询学生的考试记录
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getUserId, userId)
                   .eq(examId != null, ExamSession::getExamId, examId)
                   .ge(startTime != null, ExamSession::getStartTime, startTime)
                   .le(endTime != null, ExamSession::getStartTime, endTime)
                   .orderByDesc(ExamSession::getStartTime);

            List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

            Map<String, Object> report = new HashMap<>();
            report.put("userId", userId);
            report.put("totalExams", sessions.size());
            report.put("sessions", sessions);

            if (!sessions.isEmpty()) {
                List<BigDecimal> scores = sessions.stream()
                        .filter(s -> s.getTotalScore() != null)
                        .map(ExamSession::getTotalScore)
                        .collect(Collectors.toList());

                if (!scores.isEmpty()) {
                    BigDecimal averageScore = scores.stream()
                            .reduce(BigDecimal.ZERO, BigDecimal::add)
                            .divide(BigDecimal.valueOf(scores.size()), 2, RoundingMode.HALF_UP);

                    report.put("averageScore", averageScore);
                    report.put("maxScore", scores.stream().max(BigDecimal::compareTo).orElse(BigDecimal.ZERO));
                    report.put("minScore", scores.stream().min(BigDecimal::compareTo).orElse(BigDecimal.ZERO));
                }
            }

            log.info("学生成绩报告: userId={}, totalExams={}", userId, sessions.size());
            return report;
        } catch (Exception e) {
            log.error("获取学生成绩报告失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getClassComparison(Long examId, Long[] organizationIds) {
        try {
            // TODO: 实现班级成绩对比
            log.info("班级成绩对比: examId={}, organizationIds={}", examId, organizationIds);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("获取班级成绩对比失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getTrendAnalysis(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        try {
            // TODO: 实现趋势分析
            log.info("趋势分析: userId={}, startTime={}, endTime={}", userId, startTime, endTime);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("获取趋势分析失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getBankQualityAnalysis(Long bankId) {
        try {
            // TODO: 实现题库质量分析
            log.info("题库质量分析: bankId={}", bankId);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("获取题库质量分析失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getSystemUsage(LocalDateTime startTime, LocalDateTime endTime) {
        try {
            // TODO: 实现系统使用统计
            log.info("系统使用统计: startTime={}, endTime={}", startTime, endTime);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("获取系统使用统计失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object exportReport(String type, Long examId, LocalDateTime startTime, LocalDateTime endTime) {
        try {
            // TODO: 实现导出报表
            log.info("导出报表: type={}, examId={}", type, examId);
            return new HashMap<>();
        } catch (Exception e) {
            log.error("导出报表失败", e);
            return new HashMap<>();
        }
    }

    @Override
    public Object getDashboardData(Long userId, String role) {
        try {
            Map<String, Object> dashboard = new HashMap<>();

            if ("STUDENT".equals(role)) {
                // 学生仪表盘
                dashboard.put("type", "student");
                dashboard.putAll(getStudentDashboard(userId));
            } else if ("TEACHER".equals(role) || "ADMIN".equals(role)) {
                // 教师/管理员仪表盘
                dashboard.put("type", "teacher");
                dashboard.putAll(getTeacherDashboard(userId));
            }

            log.info("仪表盘数据: userId={}, role={}", userId, role);
            return dashboard;
        } catch (Exception e) {
            log.error("获取仪表盘数据失败", e);
            return new HashMap<>();
        }
    }

    /**
     * 获取学生仪表盘数据
     */
    private Map<String, Object> getStudentDashboard(Long userId) {
        Map<String, Object> data = new HashMap<>();

        // 查询学生的考试记录
        LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExamSession::getUserId, userId)
               .orderByDesc(ExamSession::getStartTime);
        List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

        // 统计数据
        long totalExams = sessions.size();
        long completedExams = sessions.stream()
                .filter(s -> s.getSessionStatus() == ExamSessionStatus.GRADED)
                .count();
        long pendingExams = sessions.stream()
                .filter(s -> s.getSessionStatus() == ExamSessionStatus.SUBMITTED)
                .count();

        // 计算平均分
        List<BigDecimal> scores = sessions.stream()
                .filter(s -> s.getTotalScore() != null)
                .map(ExamSession::getTotalScore)
                .collect(Collectors.toList());

        BigDecimal averageScore = scores.isEmpty() ? BigDecimal.ZERO :
                scores.stream()
                        .reduce(BigDecimal.ZERO, BigDecimal::add)
                        .divide(BigDecimal.valueOf(scores.size()), 2, RoundingMode.HALF_UP);

        // 最近考试
        List<ExamSession> recentExams = sessions.stream()
                .limit(5)
                .collect(Collectors.toList());

        data.put("totalExams", totalExams);
        data.put("completedExams", completedExams);
        data.put("pendingExams", pendingExams);
        data.put("averageScore", averageScore);
        data.put("recentExams", recentExams);

        return data;
    }

    /**
     * 获取教师/管理员仪表盘数据
     */
    private Map<String, Object> getTeacherDashboard(Long userId) {
        Map<String, Object> data = new HashMap<>();

        // 查询待批改数量
        LambdaQueryWrapper<ExamAnswer> answerWrapper = new LambdaQueryWrapper<>();
        answerWrapper.isNull(ExamAnswer::getScore);
        long pendingGrading = examAnswerMapper.selectCount(answerWrapper);

        // 查询今日提交的考试数量
        LocalDateTime todayStart = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        LambdaQueryWrapper<ExamSession> sessionWrapper = new LambdaQueryWrapper<>();
        sessionWrapper.ge(ExamSession::getSubmitTime, todayStart);
        long todaySubmissions = examSessionMapper.selectCount(sessionWrapper);

        // 查询进行中的考试数量
        LambdaQueryWrapper<ExamSession> inProgressWrapper = new LambdaQueryWrapper<>();
        inProgressWrapper.eq(ExamSession::getSessionStatus, ExamSessionStatus.IN_PROGRESS);
        long inProgressExams = examSessionMapper.selectCount(inProgressWrapper);

        data.put("pendingGrading", pendingGrading);
        data.put("todaySubmissions", todaySubmissions);
        data.put("inProgressExams", inProgressExams);

        return data;
    }

    /**
     * 获取违规统计
     */
    public Object getViolationStatistics(Long examId) {
        try {
            LambdaQueryWrapper<ExamViolation> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamViolation::getExamId, examId);
            List<ExamViolation> violations = examViolationMapper.selectList(wrapper);

            if (violations.isEmpty()) {
                return createEmptyViolationStats();
            }

            // 按类型统计
            Map<String, Long> typeStats = violations.stream()
                    .collect(Collectors.groupingBy(
                            ExamViolation::getViolationType,
                            Collectors.counting()
                    ));

            // 按严重程度统计
            Map<Integer, Long> severityStats = violations.stream()
                    .collect(Collectors.groupingBy(
                            ExamViolation::getSeverity,
                            Collectors.counting()
                    ));

            Map<String, Object> statistics = new HashMap<>();
            statistics.put("totalViolations", violations.size());
            statistics.put("typeStatistics", typeStats);
            statistics.put("severityStatistics", severityStats);
            statistics.put("violationList", violations);

            log.info("违规统计: examId={}, totalViolations={}", examId, violations.size());
            return statistics;
        } catch (Exception e) {
            log.error("获取违规统计失败", e);
            return createEmptyViolationStats();
        }
    }

    private Map<String, Object> createEmptyOverview() {
        Map<String, Object> overview = new HashMap<>();
        overview.put("totalStudents", 0);
        overview.put("submittedCount", 0);
        overview.put("absentCount", 0);
        overview.put("averageScore", BigDecimal.ZERO);
        overview.put("maxScore", BigDecimal.ZERO);
        overview.put("minScore", BigDecimal.ZERO);
        overview.put("passCount", 0);
        overview.put("passRate", 0.0);
        return overview;
    }

    private Map<String, Object> createEmptyDistribution() {
        Map<String, Long> distribution = new LinkedHashMap<>();
        distribution.put("0-59", 0L);
        distribution.put("60-69", 0L);
        distribution.put("70-79", 0L);
        distribution.put("80-89", 0L);
        distribution.put("90-100", 0L);

        Map<String, Object> result = new HashMap<>();
        result.put("distribution", distribution);
        result.put("total", 0);
        return result;
    }

    private Map<String, Object> createEmptyViolationStats() {
        Map<String, Object> statistics = new HashMap<>();
        statistics.put("totalViolations", 0);
        statistics.put("typeStatistics", new HashMap<>());
        statistics.put("severityStatistics", new HashMap<>());
        statistics.put("violationList", new ArrayList<>());
        return statistics;
    }
}

