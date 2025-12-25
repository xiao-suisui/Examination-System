package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.exam.ExamUser;

import java.util.List;

/**
 * 考试考生关联Service
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
public interface ExamUserService extends IService<ExamUser> {

    /**
     * 添加考生到考试
     *
     * @param examId 考试ID
     * @param userIds 考生ID列表
     * @return 是否成功
     */
    boolean addStudentsToExam(Long examId, List<Long> userIds);

    /**
     * 批量添加考生（根据班级或组织）
     *
     * @param examId 考试ID
     * @param rangeType 范围类型（1-指定考生，2-指定班级，3-指定组织）
     * @param rangeIds 范围ID列表
     * @return 是否成功
     */
    boolean addStudentsByRange(Long examId, Integer rangeType, List<Long> rangeIds);

    /**
     * 移除考生
     *
     * @param examId 考试ID
     * @param userId 考生ID
     * @return 是否成功
     */
    boolean removeStudent(Long examId, Long userId);

    /**
     * 查询考试的所有考生
     *
     * @param examId 考试ID
     * @return 考生列表
     */
    List<ExamUser> getExamStudents(Long examId);

    /**
     * 检查考生是否有考试权限
     *
     * @param examId 考试ID
     * @param userId 考生ID
     * @return 是否有权限
     */
    boolean hasExamPermission(Long examId, Long userId);

    /**
     * 更新考生考试状态
     *
     * @param examId 考试ID
     * @param userId 考生ID
     * @param status 状态
     * @return 是否成功
     */
    boolean updateExamStatus(Long examId, Long userId, Integer status);
}

