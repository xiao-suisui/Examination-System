package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.common.enums.ExamStatus;
import com.example.exam.dto.ExamDTO;
import com.example.exam.dto.ExamMonitorDTO;
import com.example.exam.dto.ExamStatisticsDTO;
import com.example.exam.entity.exam.Exam;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.entity.paper.Paper;
import com.example.exam.converter.ExamConverter;
import com.example.exam.mapper.exam.ExamMapper;
import com.example.exam.mapper.exam.ExamSessionMapper;
import com.example.exam.mapper.paper.PaperMapper;
import com.example.exam.service.ExamService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 考试Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExamServiceImpl extends ServiceImpl<ExamMapper, Exam> implements ExamService {

    private final ExamMapper examMapper;
    private final ExamSessionMapper examSessionMapper;
    private final PaperMapper paperMapper;
    private final ExamConverter examConverter;
    private final com.example.exam.mapper.exam.ExamUserMapper examUserMapper;
    private final com.example.exam.mapper.system.SysUserMapper userMapper;

    @Override
    public IPage<Exam> pageExams(Page<Exam> page, Long subjectId, ExamStatus status, String keyword,
                                 LocalDateTime startTimeBegin, LocalDateTime startTimeEnd) {
        LambdaQueryWrapper<Exam> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(subjectId != null, Exam::getSubjectId, subjectId)
               .eq(status != null, Exam::getExamStatus, status)
               .like(keyword != null && !keyword.isEmpty(), Exam::getExamName, keyword)
               .ge(startTimeBegin != null, Exam::getStartTime, startTimeBegin)
               .le(startTimeEnd != null, Exam::getStartTime, startTimeEnd)
               .orderByDesc(Exam::getCreateTime);
        return this.page(page, wrapper);
    }

    @Override
    public IPage<ExamDTO> pageExamDTO(Page<?> page, Long subjectId, ExamStatus status, String keyword,
                                      LocalDateTime startTimeBegin, LocalDateTime startTimeEnd) {
        // 先查询基础数据
        Page<Exam> examPage = new Page<>(page.getCurrent(), page.getSize());
        IPage<Exam> examResult = pageExams(examPage, subjectId, status, keyword, startTimeBegin, startTimeEnd);

        // 转换为DTO
        List<ExamDTO> dtoList = examResult.getRecords().stream().map(exam -> {
            // 使用Converter进行基础转换
            ExamDTO dto = examConverter.toDTO(exam);

            // 查询试卷名称
            if (exam.getPaperId() != null) {
                Paper paper = paperMapper.selectById(exam.getPaperId());
                if (paper != null) {
                    dto.setPaperName(paper.getPaperName());
                }
            }

            // 设置状态名称
            if (exam.getExamStatus() != null) {
                dto.setExamStatusName(exam.getExamStatus().getName());
            }

            // 查询参与人数和已提交人数
            LambdaQueryWrapper<ExamSession> sessionWrapper = new LambdaQueryWrapper<>();
            sessionWrapper.eq(ExamSession::getExamId, exam.getExamId());
            Long totalCount = examSessionMapper.selectCount(sessionWrapper);
            dto.setTotalParticipants(totalCount != null ? totalCount.intValue() : 0);

            sessionWrapper.clear();
            sessionWrapper.eq(ExamSession::getExamId, exam.getExamId())
                         .eq(ExamSession::getSessionStatus, ExamSessionStatus.SUBMITTED);
            Long submittedCount = examSessionMapper.selectCount(sessionWrapper);
            dto.setSubmittedCount(submittedCount != null ? submittedCount.intValue() : 0);

            return dto;
        }).collect(Collectors.toList());

        // 构建返回结果
        Page<ExamDTO> dtoPage = new Page<>(examResult.getCurrent(), examResult.getSize(), examResult.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean publishExam(Long examId) {
        Exam exam = this.getById(examId);
        if (exam == null) {
            log.error("考试不存在: {}", examId);
            return false;
        }
        // 验证试卷是否存在
        if (exam.getPaperId() == null) {
            log.error("考试未关联试卷: {}", examId);
            return false;
        }
        Paper paper = paperMapper.selectById(exam.getPaperId());
        if (paper == null) {
            log.error("关联的试卷不存在: {}", exam.getPaperId());
            return false;
        }

        // 发布考试
        exam.setExamStatus(ExamStatus.PUBLISHED);
        return this.updateById(exam);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean startExam(Long examId) {
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 设置为进行中
        exam.setExamStatus(ExamStatus.IN_PROGRESS);
        return this.updateById(exam);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean endExam(Long examId) {
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 设置为已结束
        exam.setExamStatus(ExamStatus.ENDED);
        return this.updateById(exam);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelExam(Long examId) {
        Exam exam = this.getById(examId);
        if (exam == null) {
            return false;
        }
        // 设置为已取消
        exam.setExamStatus(ExamStatus.CANCELLED);
        return this.updateById(exam);
    }

    @Override
    public ExamMonitorDTO getExamMonitorData(Long examId) {
        try {
            // 查询所有会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId);
            List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

            int totalParticipants = sessions.size();
            int currentOnline = 0;
            int submitted = 0;
            int answering = 0;
            int cutScreenAbnormal = 0;

            for (ExamSession session : sessions) {
                if (session.getSessionStatus() == ExamSessionStatus.SUBMITTED) {
                    submitted++;
                } else if (session.getSessionStatus() == ExamSessionStatus.IN_PROGRESS) {
                    answering++;
                    currentOnline++;
                }
                if (session.getTabSwitchCount() != null && session.getTabSwitchCount() > 3) {
                    cutScreenAbnormal++;
                }
            }

            return ExamMonitorDTO.builder()
                    .examId(examId)
                    .totalParticipants(totalParticipants)
                    .currentOnline(currentOnline)
                    .submitted(submitted)
                    .answering(answering)
                    .cutScreenAbnormal(cutScreenAbnormal)
                    .deviceAbnormal(0)
                    .suspectedCheating(0)
                    .build();
        } catch (Exception e) {
            log.error("获取考试监控数据失败", e);
            return ExamMonitorDTO.builder()
                    .examId(examId)
                    .totalParticipants(0)
                    .currentOnline(0)
                    .submitted(0)
                    .answering(0)
                    .cutScreenAbnormal(0)
                    .deviceAbnormal(0)
                    .suspectedCheating(0)
                    .build();
        }
    }

    @Override
    public ExamStatisticsDTO getExamStatistics(Long examId) {
        try {
            Exam exam = this.getById(examId);
            if (exam == null) {
                return null;
            }

            // 查询所有已提交的会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId)
                   .eq(ExamSession::getSessionStatus, ExamSessionStatus.SUBMITTED);
            List<ExamSession> sessions = examSessionMapper.selectList(wrapper);

            int totalParticipants = sessions.size();
            int gradedCount = 0;
            int passCount = 0;
            int excellentCount = 0;
            int goodCount = 0;
            int mediumCount = 0;
            int fairCount = 0;

            BigDecimal totalScore = BigDecimal.ZERO;
            BigDecimal highestScore = BigDecimal.ZERO;
            BigDecimal lowestScore = new BigDecimal("100");

            // 获取试卷及格分数
            Paper paper = exam.getPaperId() != null ? paperMapper.selectById(exam.getPaperId()) : null;
            BigDecimal passScore = paper != null && paper.getPassScore() != null ?
                paper.getPassScore() : new BigDecimal("60");

            for (ExamSession session : sessions) {
                if (session.getTotalScore() != null) {
                    gradedCount++;
                    BigDecimal score = session.getTotalScore();
                    totalScore = totalScore.add(score);

                    // 更新最高分和最低分
                    if (score.compareTo(highestScore) > 0) {
                        highestScore = score;
                    }
                    if (score.compareTo(lowestScore) < 0) {
                        lowestScore = score;
                    }

                    // 统计分数段
                    if (score.compareTo(passScore) >= 0) {
                        passCount++;
                    }
                    if (score.compareTo(new BigDecimal("90")) >= 0) {
                        excellentCount++;
                    } else if (score.compareTo(new BigDecimal("80")) >= 0) {
                        goodCount++;
                    } else if (score.compareTo(new BigDecimal("70")) >= 0) {
                        mediumCount++;
                    } else if (score.compareTo(new BigDecimal("60")) >= 0) {
                        fairCount++;
                    }
                }
            }

            // 计算平均分
            BigDecimal averageScore = gradedCount > 0 ?
                totalScore.divide(new BigDecimal(gradedCount), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO;

            // 计算及格率
            BigDecimal passRate = totalParticipants > 0 ?
                new BigDecimal(passCount).divide(new BigDecimal(totalParticipants), 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100")) : BigDecimal.ZERO;

            return ExamStatisticsDTO.builder()
                    .examId(examId)
                    .examName(exam.getExamName())
                    .totalParticipants(totalParticipants)
                    .submittedCount(totalParticipants)
                    .notSubmittedCount(0)
                    .gradedCount(gradedCount)
                    .pendingGradeCount(totalParticipants - gradedCount)
                    .averageScore(averageScore)
                    .highestScore(highestScore)
                    .lowestScore(lowestScore.compareTo(new BigDecimal("100")) < 0 ? lowestScore : BigDecimal.ZERO)
                    .passCount(passCount)
                    .failCount(gradedCount - passCount)
                    .passRate(passRate)
                    .excellentCount(excellentCount)
                    .goodCount(goodCount)
                    .mediumCount(mediumCount)
                    .fairCount(fairCount)
                    .build();

        } catch (Exception e) {
            log.error("获取考试统计信息失败", e);
            return null;
        }
    }

    @Override
    public List<Exam> getExamsByUser(Long userId, Long orgId) {
        LambdaQueryWrapper<Exam> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Exam::getExamStatus, ExamStatus.PUBLISHED, ExamStatus.IN_PROGRESS)
               .and(w -> w.apply("exam_range_type = 1 AND FIND_IN_SET({0}, exam_range_ids) > 0", userId)
                          .or()
                          .apply("exam_range_type IN (2, 3) AND FIND_IN_SET({0}, exam_range_ids) > 0", orgId))
               .orderByDesc(Exam::getStartTime);
        return this.list(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long copyExam(Long examId, String newTitle) {
        try {
            Exam originalExam = this.getById(examId);
            if (originalExam == null) {
                log.error("原考试不存在: {}", examId);
                return null;
            }

            Exam newExam = Exam.builder()
                    .examName(newTitle)
                    .description(originalExam.getDescription())
                    .coverImage(originalExam.getCoverImage())
                    .paperId(originalExam.getPaperId())
                    .duration(originalExam.getDuration())
                    .examRangeType(originalExam.getExamRangeType())
                    .examRangeIds(originalExam.getExamRangeIds())
                    .examStatus(ExamStatus.DRAFT)
                    .cutScreenLimit(originalExam.getCutScreenLimit())
                    .cutScreenTimer(originalExam.getCutScreenTimer())
                    .forbidCopy(originalExam.getForbidCopy())
                    .singleDevice(originalExam.getSingleDevice())
                    .shuffleQuestions(originalExam.getShuffleQuestions())
                    .shuffleOptions(originalExam.getShuffleOptions())
                    .antiPlagiarism(originalExam.getAntiPlagiarism())
                    .plagiarismThreshold(originalExam.getPlagiarismThreshold())
                    .remindTime(originalExam.getRemindTime())
                    .showScoreImmediately(originalExam.getShowScoreImmediately())
                    .orgId(originalExam.getOrgId())
                    .createUserId(originalExam.getCreateUserId())
                    .build();

            if (this.save(newExam)) {
                log.info("复制考试成功，原考试ID: {}, 新考试ID: {}", examId, newExam.getExamId());
                return newExam.getExamId();
            } else {
                log.error("保存新考试失败");
                return null;
            }
        } catch (Exception e) {
            log.error("复制考试失败", e);
            throw new RuntimeException("复制考试失败: " + e.getMessage());
        }
    }

    @Override
    public List<ExamDTO> getMyExams(Long userId, ExamStatus status) {
        LambdaQueryWrapper<Exam> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(status != null, Exam::getExamStatus, status)
               .orderByDesc(Exam::getCreateTime);

        List<Exam> exams = this.list(wrapper);

        // 转换为 DTO 并添加学生相关信息
        return exams.stream()
                .map(exam -> {
                    ExamDTO dto = examConverter.toDTO(exam);

                    // 查询学生是否已参加
                    LambdaQueryWrapper<ExamSession> sessionWrapper = new LambdaQueryWrapper<>();
                    sessionWrapper.eq(ExamSession::getExamId, exam.getExamId())
                                  .eq(ExamSession::getUserId, userId);
                    ExamSession session = examSessionMapper.selectOne(sessionWrapper);

                    if (session != null) {
                        dto.setHasJoined(true);
                        dto.setSessionId(session.getSessionId());
                        dto.setSessionStatus(session.getSessionStatus());
                    } else {
                        dto.setHasJoined(false);
                    }

                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String enterExam(Long examId, Long userId) {
        try {
            // 1. 验证考试是否存在
            Exam exam = this.getById(examId);
            if (exam == null) {
                log.error("考试不存在，examId: {}", examId);
                return null;
            }

            // 2. 验证考试状态
            if (exam.getExamStatus() != ExamStatus.IN_PROGRESS) {
                log.error("考试未开始或已结束，examId: {}, status: {}", examId, exam.getExamStatus());
                return null;
            }

            // 3. 检查是否已有会话
            LambdaQueryWrapper<ExamSession> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(ExamSession::getExamId, examId)
                   .eq(ExamSession::getUserId, userId);
            ExamSession existingSession = examSessionMapper.selectOne(wrapper);

            if (existingSession != null) {
                // 已有会话，返回现有会话ID
                log.info("学生已有考试会话，sessionId: {}", existingSession.getSessionId());
                return existingSession.getSessionId();
            }

            // 4. 创建新会话
            ExamSession newSession = new ExamSession();
            newSession.setSessionId(generateSessionId());
            newSession.setExamId(examId);
            newSession.setUserId(userId);
            newSession.setSessionStatus(ExamSessionStatus.IN_PROGRESS);
            newSession.setStartTime(LocalDateTime.now());
            newSession.setTotalScore(BigDecimal.ZERO);

            if (examSessionMapper.insert(newSession) > 0) {
                log.info("创建考试会话成功，sessionId: {}, examId: {}, userId: {}",
                        newSession.getSessionId(), examId, userId);
                return newSession.getSessionId();
            } else {
                log.error("创建考试会话失败");
                return null;
            }
        } catch (Exception e) {
            log.error("进入考试失败", e);
            throw new RuntimeException("进入考试失败: " + e.getMessage());
        }
    }

    /**
     * 生成会话ID
     */
    private String generateSessionId() {
        return "S" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }

    @Override
    public List<com.example.exam.dto.ExamUserDTO> getExamStudents(Long examId) {
        try {
            // 查询考试的所有考生信息
            LambdaQueryWrapper<com.example.exam.entity.exam.ExamUser> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(com.example.exam.entity.exam.ExamUser::getExamId, examId);
            List<com.example.exam.entity.exam.ExamUser> examUsers = examUserMapper.selectList(wrapper);

            // 转换为 DTO
            return examUsers.stream().map(examUser -> {
                com.example.exam.dto.ExamUserDTO dto = new com.example.exam.dto.ExamUserDTO();
                dto.setExamUserId(examUser.getId());
                dto.setExamId(examUser.getExamId());
                dto.setUserId(examUser.getUserId());
                dto.setExamStatus(examUser.getExamStatus());
                dto.setFinalScore(examUser.getFinalScore());
                dto.setPassStatus(examUser.getPassStatus());
                dto.setReexamCount(examUser.getReexamCount());
                dto.setCreateTime(examUser.getCreateTime());

                // 获取用户信息
                com.example.exam.entity.system.SysUser user = userMapper.selectById(examUser.getUserId());
                if (user != null) {
                    dto.setUserName(user.getUsername());
                    dto.setRealName(user.getRealName());
                }

                return dto;
            }).collect(Collectors.toList());
        } catch (Exception e) {
            log.error("获取考试考生列表失败", e);
            return java.util.Collections.emptyList();
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addStudentsToExam(Long examId, List<Long> userIds) {
        try {
            // 验证考试是否存在
            Exam exam = this.getById(examId);
            if (exam == null) {
                log.error("考试不存在，examId: {}", examId);
                return false;
            }

            // 批量添加考生
            for (Long userId : userIds) {
                // 检查是否已存在
                LambdaQueryWrapper<com.example.exam.entity.exam.ExamUser> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(com.example.exam.entity.exam.ExamUser::getExamId, examId)
                       .eq(com.example.exam.entity.exam.ExamUser::getUserId, userId);
                Long count = examUserMapper.selectCount(wrapper);

                if (count == 0) {
                    // 不存在则添加
                    com.example.exam.entity.exam.ExamUser examUser = new com.example.exam.entity.exam.ExamUser();
                    examUser.setExamId(examId);
                    examUser.setUserId(userId);
                    examUser.setExamStatus(0); // 未参考
                    examUser.setReexamCount(0);
                    examUser.setPassStatus(0); // 不及格
                    examUserMapper.insert(examUser);
                    log.info("添加考生成功，examId: {}, userId: {}", examId, userId);
                } else {
                    log.info("考生已存在，跳过添加，examId: {}, userId: {}", examId, userId);
                }
            }

            return true;
        } catch (Exception e) {
            log.error("添加考生失败", e);
            throw new RuntimeException("添加考生失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeStudentFromExam(Long examId, Long userId) {
        try {
            // 删除考生关联
            LambdaQueryWrapper<com.example.exam.entity.exam.ExamUser> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(com.example.exam.entity.exam.ExamUser::getExamId, examId)
                   .eq(com.example.exam.entity.exam.ExamUser::getUserId, userId);
            int result = examUserMapper.delete(wrapper);

            if (result > 0) {
                log.info("移除考生成功，examId: {}, userId: {}", examId, userId);
                return true;
            } else {
                log.warn("考生不存在或已移除，examId: {}, userId: {}", examId, userId);
                return false;
            }
        } catch (Exception e) {
            log.error("移除考生失败", e);
            throw new RuntimeException("移除考生失败: " + e.getMessage());
        }
    }

    @Override
    public boolean checkExamPermission(Long examId, Long userId) {
        try {
            // 检查考生是否在考试列表中
            LambdaQueryWrapper<com.example.exam.entity.exam.ExamUser> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(com.example.exam.entity.exam.ExamUser::getExamId, examId)
                   .eq(com.example.exam.entity.exam.ExamUser::getUserId, userId);
            Long count = examUserMapper.selectCount(wrapper);

            return count > 0;
        } catch (Exception e) {
            log.error("检查考试权限失败", e);
            return false;
        }
    }
}
