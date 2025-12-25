package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.result.Result;
import com.example.exam.dto.subject.*;
import com.example.exam.service.SubjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 科目管理Controller
 *
 * @author system
 * @since 2025-12-20
 */
@Tag(name = "科目管理", description = "科目的CRUD、管理员授权、学生选课")
@RestController
@RequestMapping("/api/subject")
@RequiredArgsConstructor
public class SubjectController {

    private final SubjectService subjectService;

    @Operation(summary = "分页查询科目")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "分页查询科目")
    @GetMapping("/page")
    public Result<IPage<SubjectDTO>> page(@Valid SubjectQueryDTO query) {
        return Result.success(subjectService.pageSubjects(query));
    }

    @Operation(summary = "查询科目详情")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "查询科目详情", recordParams = false)
    @GetMapping("/{id}")
    public Result<SubjectDTO> detail(@Parameter(description = "科目ID") @PathVariable Long id) {
        return Result.success(subjectService.getSubjectDetail(id));
    }

    @Operation(summary = "创建科目")
    @RequirePermission(value = "subject:create", desc = "创建科目")
    @OperationLog(module = "科目管理", type = "创建", description = "创建科目")
    @PostMapping
    public Result<Void> create(@Valid @RequestBody SubjectCreateDTO dto) {
        subjectService.createSubject(dto);
        return Result.success();
    }

    @Operation(summary = "更新科目")
    @RequirePermission(value = "subject:update", desc = "更新科目")
    @OperationLog(module = "科目管理", type = "更新", description = "更新科目")
    @PutMapping
    public Result<Void> update(@Valid @RequestBody SubjectUpdateDTO dto) {
        subjectService.updateSubject(dto);
        return Result.success();
    }

    @Operation(summary = "删除科目")
    @RequirePermission(value = "subject:delete", desc = "删除科目")
    @OperationLog(module = "科目管理", type = "删除", description = "删除科目")
    @DeleteMapping("/{id}")
    public Result<Void> delete(@Parameter(description = "科目ID") @PathVariable Long id) {
        subjectService.deleteSubject(id);
        return Result.success();
    }

    @Operation(summary = "添加科目管理员")
    @RequirePermission(value = "subject:manage", desc = "管理科目成员")
    @OperationLog(module = "科目管理", type = "授权", description = "添加科目管理员")
    @PostMapping("/{subjectId}/managers")
    public Result<Void> addManager(
            @Parameter(description = "科目ID") @PathVariable Long subjectId,
            @RequestBody SubjectManagerAddDTO dto
    ) {
        subjectService.addManager(subjectId, dto.getUserId(), dto.getManagerType(), dto.getPermissions());
        return Result.success();
    }

    @Operation(summary = "移除科目管理员")
    @RequirePermission(value = "subject:manage", desc = "管理科目成员")
    @OperationLog(module = "科目管理", type = "授权", description = "移除科目管理员")
    @DeleteMapping("/{subjectId}/managers/{userId}")
    public Result<Void> removeManager(
            @Parameter(description = "科目ID") @PathVariable Long subjectId,
            @Parameter(description = "用户ID") @PathVariable Long userId
    ) {
        subjectService.removeManager(subjectId, userId);
        return Result.success();
    }

    @Operation(summary = "批量添加学生到科目")
    @RequirePermission(value = "subject:manage", desc = "管理科目成员")
    @OperationLog(module = "科目管理", type = "学生管理", description = "添加学生到科目")
    @PostMapping("/{subjectId}/students")
    public Result<Void> enrollStudents(
            @Parameter(description = "科目ID") @PathVariable Long subjectId,
            @RequestBody SubjectEnrollStudentsDTO dto
    ) {
        subjectService.enrollStudents(subjectId, dto.getStudentIds(), dto.getEnrollType());
        return Result.success();
    }

    @Operation(summary = "移除学生")
    @RequirePermission(value = "subject:manage", desc = "管理科目成员")
    @OperationLog(module = "科目管理", type = "学生管理", description = "从科目移除学生")
    @DeleteMapping("/{subjectId}/students/{studentId}")
    public Result<Void> withdrawStudent(
            @Parameter(description = "科目ID") @PathVariable Long subjectId,
            @Parameter(description = "学生ID") @PathVariable Long studentId
    ) {
        subjectService.withdrawStudent(subjectId, studentId);
        return Result.success();
    }

    @Operation(summary = "获取我的科目列表")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "获取我的科目列表", recordParams = false)
    @GetMapping("/my-subjects")
    public Result<List<Long>> mySubjects() {
        Long userId = com.example.exam.util.SecurityUtils.getUserId();
        String roleCode = com.example.exam.util.SecurityUtils.getRoleCode();

        if ("STUDENT".equals(roleCode)) {
            return Result.success(subjectService.getUserEnrolledSubjectIds(userId));
        } else {
            return Result.success(subjectService.getUserManagedSubjectIds(userId));
        }
    }

    @Operation(summary = "获取科目管理员列表")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "查询科目管理员", recordParams = false)
    @GetMapping("/{subjectId}/managers")
    public Result<List<SubjectManagerDTO>> getManagers(
            @Parameter(description = "科目ID") @PathVariable Long subjectId
    ) {
        return Result.success(subjectService.getSubjectManagers(subjectId));
    }

    @Operation(summary = "分页获取科目学生列表")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "查询科目学生", recordParams = false)
    @GetMapping("/{subjectId}/students")
    public Result<IPage<SubjectStudentDTO>> getStudents(
            @Parameter(description = "科目ID") @PathVariable Long subjectId,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "10") Long size
    ) {
        return Result.success(subjectService.getSubjectStudents(subjectId, current, size));
    }

    @Operation(summary = "获取可选教师列表")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "查询可选教师", recordParams = false)
    @GetMapping("/available-teachers")
    public Result<List<SubjectManagerDTO>> getAvailableTeachers(
            @Parameter(description = "组织ID") @RequestParam Long orgId
    ) {
        return Result.success(subjectService.getAvailableTeachers(orgId));
    }

    @Operation(summary = "获取可选学生列表")
    @RequirePermission(value = "subject:view", desc = "查看科目")
    @OperationLog(module = "科目管理", type = "查询", description = "查询可选学生", recordParams = false)
    @GetMapping("/available-students")
    public Result<List<SubjectStudentDTO>> getAvailableStudents(
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword
    ) {
        return Result.success(subjectService.getAvailableStudents(keyword));
    }
}

