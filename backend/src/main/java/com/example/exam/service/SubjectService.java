package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.dto.subject.*;
import com.example.exam.entity.subject.Subject;

import java.util.List;

/**
 * 科目Service接口
 *
 * @author system
 * @since 2025-12-20
 */
public interface SubjectService extends IService<Subject> {

    /**
     * 分页查询科目
     *
     * @param query 查询条件
     * @return 分页结果
     */
    IPage<SubjectDTO> pageSubjects(SubjectQueryDTO query);

    /**
     * 查询科目详情
     *
     * @param subjectId 科目ID
     * @return 科目详情
     */
    SubjectDTO getSubjectDetail(Long subjectId);

    /**
     * 创建科目
     *
     * @param dto 科目创建DTO
     */
    void createSubject(SubjectCreateDTO dto);

    /**
     * 更新科目
     *
     * @param dto 科目更新DTO
     */
    void updateSubject(SubjectUpdateDTO dto);

    /**
     * 删除科目
     *
     * @param subjectId 科目ID
     */
    void deleteSubject(Long subjectId);

    /**
     * 添加科目管理员
     *
     * @param subjectId   科目ID
     * @param userId      用户ID
     * @param managerType 管理员类型
     * @param permissions 权限列表
     */
    void addManager(Long subjectId, Long userId, Integer managerType, String[] permissions);

    /**
     * 移除科目管理员
     *
     * @param subjectId 科目ID
     * @param userId    用户ID
     */
    void removeManager(Long subjectId, Long userId);

    /**
     * 更新管理员权限
     *
     * @param subjectId   科目ID
     * @param userId      用户ID
     * @param permissions 权限列表
     */
    void updateManagerPermissions(Long subjectId, Long userId, String[] permissions);

    /**
     * 批量添加学生到科目
     *
     * @param subjectId  科目ID
     * @param studentIds 学生ID列表
     * @param enrollType 选课类型
     */
    void enrollStudents(Long subjectId, List<Long> studentIds, Integer enrollType);

    /**
     * 移除学生
     *
     * @param subjectId 科目ID
     * @param studentId 学生ID
     */
    void withdrawStudent(Long subjectId, Long studentId);

    /**
     * 检查用户是否有科目权限
     *
     * @param userId     用户ID
     * @param subjectId  科目ID
     * @param permission 权限代码
     * @return 是否有权限
     */
    boolean hasSubjectPermission(Long userId, Long subjectId, String permission);

    /**
     * 获取用户管理的科目ID列表
     *
     * @param userId 用户ID
     * @return 科目ID列表
     */
    List<Long> getUserManagedSubjectIds(Long userId);

    /**
     * 获取用户加入的科目ID列表（学生）
     *
     * @param userId 用户ID
     * @return 科目ID列表
     */
    List<Long> getUserEnrolledSubjectIds(Long userId);

    /**
     * 检查是否为科目创建者
     *
     * @param userId    用户ID
     * @param subjectId 科目ID
     * @return 是否为创建者
     */
    boolean isCreator(Long userId, Long subjectId);

    /**
     * 获取科目管理员列表
     *
     * @param subjectId 科目ID
     * @return 管理员列表
     */
    List<SubjectManagerDTO> getSubjectManagers(Long subjectId);

    /**
     * 分页获取科目学生列表
     *
     * @param subjectId 科目ID
     * @param current   当前页
     * @param size      每页大小
     * @return 学生分页数据
     */
    IPage<SubjectStudentDTO> getSubjectStudents(Long subjectId, Long current, Long size);

    /**
     * 获取可选教师列表（本组织的教师）
     *
     * @param orgId 组织ID
     * @return 教师列表
     */
    List<SubjectManagerDTO> getAvailableTeachers(Long orgId);

    /**
     * 获取可选学生列表
     *
     * @param keyword 关键词
     * @param orgId 组织ID
     * @return 学生列表
     */
    List<SubjectStudentDTO> getAvailableStudents(String keyword, Long orgId);
}

