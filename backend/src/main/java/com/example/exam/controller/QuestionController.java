package com.example.exam.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.DifficultyType;
import com.example.exam.common.enums.QuestionType;
import com.example.exam.common.result.Result;
import com.example.exam.dto.QuestionDTO;
import com.example.exam.entity.question.Question;
import com.example.exam.service.QuestionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 题目Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "题目管理", description = "题目的增删改查、审核等操作")
@RestController
@RequestMapping("/api/question")
@RequiredArgsConstructor
@lombok.extern.slf4j.Slf4j
public class QuestionController {

    private final QuestionService questionService;
    private final com.example.exam.service.UserService userService;
    private final com.example.exam.converter.QuestionConverter questionConverter;

    @Operation(summary = "分页查询题目", description = "支持多条件筛选的题目分页查询（题库、题型、难度、审核状态、知识点、科目）")
    @OperationLog(module = "题目管理", type = "查询", description = "分页查询题目", recordParams = false)
    @RequirePermission(value = "question:view", desc = "查看题目")
    @GetMapping("/page")
    public Result<IPage<Question>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "题库ID") @RequestParam(required = false) Long bankId,
            @Parameter(description = "题型：1-单选,2-多选,3-不定项,4-判断,5-匹配,6-排序,7-填空,8-主观", example = "1")
            @RequestParam(required = false) Integer questionType,
            @Parameter(description = "难度：1-简单,2-中等,3-困难", example = "2")
            @RequestParam(required = false) Integer difficulty,
            @Parameter(description = "审核状态：0-草稿,1-待审核,2-已通过,3-已拒绝", example = "2")
            @RequestParam(required = false) Integer auditStatus,
            @Parameter(description = "知识点ID") @RequestParam(required = false) Long knowledgeId,
            @Parameter(description = "关键词（题目内容）") @RequestParam(required = false) String keyword,
            @Parameter(description = "科目ID") @RequestParam(required = false) Long subjectId) {

        // 手动转换枚举类型
        QuestionType questionTypeEnum = questionType != null ? QuestionType.of(questionType) : null;
        DifficultyType difficultyEnum = difficulty != null ? DifficultyType.of(difficulty) : null;
        AuditStatus auditStatusEnum = auditStatus != null ? AuditStatus.of(auditStatus) : null;

        Page<Question> page = new Page<>(current, size);
        IPage<Question> result = questionService.pageQuestions(
                page, bankId, questionTypeEnum, difficultyEnum, auditStatusEnum, knowledgeId, keyword, subjectId);

        return Result.success(result);
    }

    @Operation(summary = "查询题目详情", description = "根据ID查询题目详情，包含所有选项信息")
    @RequirePermission(value = "question:view", desc = "查看题目")
    @GetMapping("/{id}")
    public Result<com.example.exam.dto.QuestionDTO> getById(
            @Parameter(description = "题目ID", required = true, example = "1") @PathVariable Long id) {
        Question question = questionService.getById(id);
        if (question == null) {
            return Result.error("题目不存在");
        }

        // 使用DTO转换，包含options
        QuestionDTO dto = questionService.getQuestionDTOById(id);
        return Result.success(dto);
    }

    @Operation(summary = "创建题目", description = "创建新题目，支持8种题型，包含选项信息")
    @OperationLog(module = "题目管理", type = "创建", description = "创建题目")
    @RequirePermission(value = "question:create", desc = "创建题目")
    @PostMapping
    public Result<Void> create(
            @Parameter(description = "题目信息（包含选项列表）", required = true) @RequestBody com.example.exam.dto.QuestionSaveDTO dto) {

        log.info("创建题目请求: bankId={}, questionType={}, questionContent={}",
                 dto.getBankId(), dto.getQuestionType(),
                 dto.getQuestionContent() != null ? dto.getQuestionContent().substring(0, Math.min(20, dto.getQuestionContent().length())) : "null");

        // 使用 MapStruct 转换DTO为实体（自动处理枚举类型转换和字段映射）
        Question question = questionConverter.fromSaveDTO(dto);

        // 设置创建人ID和组织ID（从当前登录用户获取）
        Long currentUserId = getCurrentUserId();
        Long currentOrgId = getCurrentUserOrgId();

        question.setCreateUserId(currentUserId);
        if (question.getOrgId() == null) {
            question.setOrgId(currentOrgId);
        }

        // 自动设置科目ID（如果未提供）
        if (question.getSubjectId() == null) {
            Long currentSubjectId = getCurrentUserSubjectId();
            if (currentSubjectId != null) {
                question.setSubjectId(currentSubjectId);
            }
        }

        // 设置默认状态
        if (question.getAuditStatus() == null) {
            question.setAuditStatus(AuditStatus.DRAFT);
        }
        if (question.getStatus() == null) {
            question.setStatus(1); // 默认启用
        }

        boolean success = questionService.saveQuestionWithOptions(question, dto.getOptions());

        if (success) {
            log.info("创建题目成功: questionId={}", question.getQuestionId());
            return Result.success("创建成功", null);
        } else {
            log.error("创建题目失败: bankId={}, questionType={}", dto.getBankId(), dto.getQuestionType());
            return Result.error("创建失败");
        }
    }

    @Operation(summary = "更新题目", description = "根据ID更新题目信息，包含选项信息")
    @OperationLog(module = "题目管理", type = "更新", description = "更新题目")
    @RequirePermission(value = "question:update", desc = "更新题目")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id,
            @Parameter(description = "题目信息（包含选项列表）", required = true) @RequestBody com.example.exam.dto.QuestionSaveDTO dto) {

        log.info("更新题目请求: questionId={}, bankId={}, questionType={}", id, dto.getBankId(), dto.getQuestionType());

        // 使用 MapStruct 转换DTO为实体（自动处理枚举类型转换）
        Question question = questionConverter.fromSaveDTO(dto);
        question.setQuestionId(id);

        boolean success = questionService.updateQuestionWithOptions(question, dto.getOptions());

        if (success) {
            log.info("更新题目成功: questionId={}", id);
            return Result.success("更新成功", null);
        } else {
            log.error("更新题目失败: questionId={}", id);
            return Result.error("更新失败");
        }
    }

    @Operation(summary = "删除题目", description = "逻辑删除题目（软删除）")
    @OperationLog(module = "题目管理", type = "删除", description = "删除题目")
    @RequirePermission(value = "question:delete", desc = "删除题目")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id) {
        boolean success = questionService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "审核题目", description = "对题目进行审核（通过/拒绝）")
    @OperationLog(module = "题目管理", type = "审核", description = "审核题目")
    @RequirePermission(value = "question:audit", desc = "审核题目")
    @PostMapping("/{id}/audit")
    public Result<Void> audit(
            @Parameter(description = "题目ID", required = true) @PathVariable Long id,
            @Parameter(description = "审核状态：0-草稿,1-待审核,2-已通过,3-已拒绝", required = true, example = "2")
            @RequestParam Integer auditStatus,
            @Parameter(description = "审核备注") @RequestParam(required = false) String remark,
            @Parameter(description = "审核人ID", required = true) @RequestParam Long auditorId) {

        // 手动转换枚举
        AuditStatus auditStatusEnum = AuditStatus.of(auditStatus);
        boolean success = questionService.auditQuestion(id, auditStatusEnum, remark, auditorId);
        return success ? Result.success() : Result.error("审核失败");
    }

    /**
     * 获取当前登录用户ID
     * 从Spring Security上下文或JWT Token中获取
     */
    private Long getCurrentUserId() {
        try {
            // 尝试从Spring Security上下文获取
            org.springframework.security.core.Authentication authentication =
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();

            if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {

                Object principal = authentication.getPrincipal();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    String username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                    // 通过username查询用户ID
                    com.example.exam.entity.system.SysUser user = getUserByUsername(username);
                    if (user != null) {
                        return user.getUserId();
                    }
                }
            }
        } catch (Exception e) {
            log.warn("获取当前用户ID失败", e);
        }

        // 如果获取失败，返回默认值（系统管理员ID）
        return 1L;
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

        // 如果获取失败，返回默认组织ID
        return 1L;
    }

    /**
     * 获取当前登录用户的主科目ID
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

