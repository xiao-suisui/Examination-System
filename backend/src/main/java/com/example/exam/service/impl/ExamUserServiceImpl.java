package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.exam.ExamUser;
import com.example.exam.mapper.exam.ExamUserMapper;
import com.example.exam.service.ExamUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 考试考生关联ServiceImpl
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExamUserServiceImpl extends ServiceImpl<ExamUserMapper, ExamUser> implements ExamUserService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addStudentsToExam(Long examId, List<Long> userIds) {
        if (examId == null || userIds == null || userIds.isEmpty()) {
            return false;
        }

        // 查询已存在的考生
        LambdaQueryWrapper<ExamUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExamUser::getExamId, examId);
        queryWrapper.in(ExamUser::getUserId, userIds);
        List<ExamUser> existingList = list(queryWrapper);
        List<Long> existingUserIds = existingList.stream()
                .map(ExamUser::getUserId)
                .toList();

        // 过滤出需要添加的新考生
        List<ExamUser> newExamUsers = new ArrayList<>();
        for (Long userId : userIds) {
            if (!existingUserIds.contains(userId)) {
                ExamUser examUser = ExamUser.builder()
                        .examId(examId)
                        .userId(userId)
                        .examStatus(0) // 未参考
                        .reexamCount(0)
                        .passStatus(0)
                        .build();
                newExamUsers.add(examUser);
            }
        }

        if (newExamUsers.isEmpty()) {
            log.info("所有考生已存在，无需添加");
            return true;
        }

        return saveBatch(newExamUsers);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addStudentsByRange(Long examId, Integer rangeType, List<Long> rangeIds) {
        // TODO: 根据范围类型（班级、组织）获取学生列表
        // 这里需要根据实际的班级/组织表结构来实现
        log.warn("按范围添加考生功能待实现");
        return false;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeStudent(Long examId, Long userId) {
        LambdaQueryWrapper<ExamUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExamUser::getExamId, examId);
        queryWrapper.eq(ExamUser::getUserId, userId);
        return remove(queryWrapper);
    }

    @Override
    public List<ExamUser> getExamStudents(Long examId) {
        LambdaQueryWrapper<ExamUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExamUser::getExamId, examId);
        queryWrapper.orderByDesc(ExamUser::getCreateTime);
        return list(queryWrapper);
    }

    @Override
    public boolean hasExamPermission(Long examId, Long userId) {
        LambdaQueryWrapper<ExamUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExamUser::getExamId, examId);
        queryWrapper.eq(ExamUser::getUserId, userId);
        return count(queryWrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateExamStatus(Long examId, Long userId, Integer status) {
        LambdaQueryWrapper<ExamUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExamUser::getExamId, examId);
        queryWrapper.eq(ExamUser::getUserId, userId);

        ExamUser examUser = getOne(queryWrapper);
        if (examUser == null) {
            return false;
        }

        examUser.setExamStatus(status);
        return updateById(examUser);
    }
}

