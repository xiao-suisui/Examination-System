package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.enums.BankType;
import com.example.exam.common.result.Result;
import com.example.exam.dto.QuestionBankStatisticsDTO;
import com.example.exam.entity.question.QuestionBank;
import com.example.exam.service.QuestionBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 题库管理Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "题库管理", description = "题库的创建、管理、导入导出等功能")
@RestController
@RequestMapping("/api/question-bank")
@RequiredArgsConstructor
@Slf4j
public class QuestionBankController {

    private final QuestionBankService questionBankService;
    private final com.example.exam.service.UserService userService;

    @Operation(summary = "分页查询题库", description = "查询题库列表，支持关键词搜索、题库类型、科目筛选")
    @OperationLog(module = "题库管理", type = "查询", description = "分页查询题库", recordParams = false)
    @RequirePermission(value = "question_bank:view", desc = "查看题库")
    @GetMapping("/page")
    public Result<IPage<QuestionBank>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "题库名称关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "题库类型（1-公共题库,2-私有题库）", example = "1") @RequestParam(required = false) Integer bankType,
            @Parameter(description = "科目ID") @RequestParam(required = false) Long subjectId) {

        // 手动转换枚举
        BankType bankTypeEnum = bankType != null ? BankType.of(bankType) : null;

        Page<QuestionBank> page = new Page<>(current, size);
        IPage<QuestionBank> result = questionBankService.pageQuestionBanks(page, keyword, bankTypeEnum, subjectId);
        return Result.success(result);
    }

    @Operation(summary = "查询所有题库", description = "查询所有可用题库（用于下拉选择）")
    @RequirePermission(value = "question_bank:view", desc = "查看题库")
    @GetMapping("/list")
    public Result<List<QuestionBank>> list() {
        List<QuestionBank> list = questionBankService.list();
        return Result.success(list);
    }

    @Operation(summary = "查询题库详情", description = "根据ID查询题库详细信息")
    @RequirePermission(value = "question_bank:view", desc = "查看题库")
    @GetMapping("/{id}")
    public Result<QuestionBank> getById(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        QuestionBank questionBank = questionBankService.getById(id);
        return questionBank != null ? Result.success(questionBank) : Result.error("题库不存在");
    }

    @Operation(summary = "创建题库", description = "创建新的题库")
    @OperationLog(module = "题库管理", type = "创建", description = "创建题库")
    @RequirePermission(value = "question_bank:create", desc = "创建题库")
    @PostMapping
    public Result<Long> create(
            @Parameter(description = "题库信息", required = true) @RequestBody QuestionBank questionBank) {

        // 自动设置创建人ID（从当前登录用户获取）
        Long currentUserId = getCurrentUserId();
        questionBank.setCreateUserId(currentUserId);

        // 自动设置组织ID（如果未提供）
        if (questionBank.getOrgId() == null) {
            Long currentOrgId = getCurrentUserOrgId();
            questionBank.setOrgId(currentOrgId);
        }

        // 自动设置科目ID（从当前用户的主科目获取，如果未提供）
        if (questionBank.getSubjectId() == null) {
            Long currentSubjectId = getCurrentUserSubjectId();
            if (currentSubjectId != null) {
                questionBank.setSubjectId(currentSubjectId);
            }
        }

        // 设置默认状态
        if (questionBank.getStatus() == null) {
            questionBank.setStatus(1); // 默认启用
        }

        boolean success = questionBankService.save(questionBank);
        return success ? Result.success("创建成功", questionBank.getBankId()) : Result.error("创建失败");
    }

    @Operation(summary = "更新题库", description = "更新题库信息")
    @OperationLog(module = "题库管理", type = "更新", description = "更新题库")
    @RequirePermission(value = "question_bank:update", desc = "更新题库")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id,
            @Parameter(description = "题库信息", required = true) @RequestBody QuestionBank questionBank) {
        questionBank.setBankId(id);
        boolean success = questionBankService.updateById(questionBank);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除题库", description = "删除题库（题库下无题目时可删除）")
    @OperationLog(module = "题库管理", type = "删除", description = "删除题库")
    @RequirePermission(value = "question_bank:delete", desc = "删除题库")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        boolean success = questionBankService.removeById(id);
        return success ? Result.success() : Result.error("删除失败，题库下可能还有题目");
    }

    @Operation(summary = "题库统计", description = "查询题库中的题目统计信息（包含题型分布、难度分布、审核状态）")
    @OperationLog(module = "题库管理", type = "查询", description = "查询题库统计信息", recordParams = false)
    @RequirePermission(value = "question_bank:view", desc = "查看题库")
    @GetMapping("/{id:[0-9]+}/statistics")
    public Result<QuestionBankStatisticsDTO> statistics(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        com.example.exam.dto.QuestionBankStatisticsDTO statistics = questionBankService.getQuestionBankStatistics(id);
        if (statistics == null) {
            return Result.error("题库不存在");
        }
        return Result.success(statistics);
    }

    @Operation(summary = "导入题目到题库", description = "批量导入题目到指定题库")
    @RequirePermission(value = "question_bank:import", desc = "导入题目")
    @PostMapping("/{id}/import")
    public Result<Object> importQuestions(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id,
            @Parameter(description = "导入文件内容", required = true) @RequestBody String fileContent) {
        Object result = questionBankService.importQuestions(id, fileContent);
        return Result.success("导入成功", result);
    }

    @Operation(summary = "导出题库题目", description = "导出题库中的所有题目")
    @RequirePermission(value = "question_bank:export", desc = "导出题目")
    @GetMapping("/{id}/export")
    public Result<Object> exportQuestions(
            @Parameter(description = "题库ID", required = true) @PathVariable Long id) {
        Object exportData = questionBankService.exportQuestions(id);
        return Result.success(exportData);
    }

    @Operation(summary = "批量添加题目到题库", description = "将多个题目添加到指定题库")
    @OperationLog(module = "题库管理", type = "更新", description = "批量添加题目")
    @RequirePermission(value = "question_bank:update", desc = "更新题库")
    @PostMapping("/{bankId}/questions")
    public Result<Void> addQuestions(
            @Parameter(description = "题库ID", required = true) @PathVariable Long bankId,
            @Parameter(description = "题目ID列表", required = true) @RequestBody java.util.Map<String, java.util.List<Long>> params) {

        java.util.List<Long> questionIds = params.get("questionIds");
        if (questionIds == null || questionIds.isEmpty()) {
            return Result.error("题目ID列表不能为空");
        }

        boolean success = questionBankService.addQuestions(bankId, questionIds);
        return success ? Result.success("添加成功", null) : Result.error("添加失败");
    }

    @Operation(summary = "从题库移除题目", description = "将题目从指定题库中移除（题目本身不删除）")
    @OperationLog(module = "题库管理", type = "更新", description = "移除题目")
    @RequirePermission(value = "question_bank:update", desc = "更新题库")
    @DeleteMapping("/{bankId}/questions/{questionId}")
    public Result<Void> removeQuestion(
            @Parameter(description = "题库ID", required = true) @PathVariable Long bankId,
            @Parameter(description = "题目ID", required = true) @PathVariable Long questionId) {
        boolean success = questionBankService.removeQuestion(bankId, questionId);
        return success ? Result.success("移除成功" ,null) : Result.error("移除失败");
    }

    /**
     * 获取当前登录用户ID
     */
    private Long getCurrentUserId() {
        try {
            org.springframework.security.core.Authentication authentication =
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();

            if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {

                Object principal = authentication.getPrincipal();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    String username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                    com.example.exam.entity.system.SysUser user = getUserByUsername(username);
                    if (user != null) {
                        return user.getUserId();
                    }
                }
            }
        } catch (Exception e) {
            log.warn("获取当前用户ID失败", e);
        }
        return 1L; // 默认系统管理员
    }

    /**
     * 获取当前登录用户的组织ID
     */
    private Long getCurrentUserOrgId() {
        try {
            org.springframework.security.core.Authentication authentication =
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();

            if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {

                Object principal = authentication.getPrincipal();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    String username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                    com.example.exam.entity.system.SysUser user = getUserByUsername(username);
                    if (user != null && user.getOrgId() != null) {
                        return user.getOrgId();
                    }
                }
            }
        } catch (Exception e) {
            log.warn("获取当前用户组织ID失败", e);
        }
        return 1L; // 默认组织
    }

    /**
     * 获取当前登录用户的主科目ID（从用户关联的第一个科目获取）
     */
    private Long getCurrentUserSubjectId() {
        try {
            org.springframework.security.core.Authentication authentication =
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();

            if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {

                Object principal = authentication.getPrincipal();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    String username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                    com.example.exam.entity.system.SysUser user = getUserByUsername(username);
                    if (user != null) {
                        // TODO: 从用户-科目关联表中查询用户的主科目
                        // 这里暂时返回null，需要根据实际业务实现
                        return null;
                    }
                }
            }
        } catch (Exception e) {
            log.warn("获取当前用户科目ID失败", e);
        }
        return null;
    }

    /**
     * 根据用户名查询用户信息
     */
    private com.example.exam.entity.system.SysUser getUserByUsername(String username) {
        try {
            return userService.getUserByUsername(username);
        } catch (Exception e) {
            log.error("查询用户失败: username={}", username, e);
            return null;
        }
    }
}

