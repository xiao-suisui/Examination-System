package com.example.exam.controller;

import com.example.exam.annotation.OperationLog;
import com.example.exam.annotation.RequirePermission;
import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.UserStatus;
import com.example.exam.common.result.Result;
import com.example.exam.entity.system.SysUser;
import com.example.exam.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户Controller
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Tag(name = "用户管理", description = "用户的注册、登录、个人信息管理")
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@lombok.extern.slf4j.Slf4j
public class UserController {

    private final UserService userService;

    @Operation(summary = "分页查询用户", description = "查询用户列表，支持关键词搜索")
    @RequirePermission(value = "user:view", desc = "查看用户")
    @OperationLog(module = "用户管理", type = "查询", description = "分页查询用户", recordParams = false)
    @GetMapping("/page")
    public Result<com.baomidou.mybatisplus.core.metadata.IPage<com.example.exam.dto.UserDTO>> page(
            @Parameter(description = "当前页码", example = "1") @RequestParam(defaultValue = "1") Long current,
            @Parameter(description = "每页数量", example = "10") @RequestParam(defaultValue = "10") Long size,
            @Parameter(description = "用户名") @RequestParam(required = false) String username,
            @Parameter(description = "真实姓名") @RequestParam(required = false) String realName,
            @Parameter(description = "状态：0-禁用，1-启用") @RequestParam(required = false) com.example.exam.common.enums.UserStatus status) {

        com.baomidou.mybatisplus.extension.plugins.pagination.Page<com.example.exam.dto.UserDTO> page =
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(current, size);

        com.baomidou.mybatisplus.core.metadata.IPage<com.example.exam.dto.UserDTO> result =
            userService.pageUserDTO(page, username, realName, status);

        return Result.success(result);
    }

    @Operation(summary = "创建用户", description = "管理员创建新用户")
    @RequirePermission(value = "user:create", desc = "创建用户")
    @OperationLog(module = "用户管理", type = "创建", description = "创建用户")
    @PostMapping
    public Result<Void> create(@Parameter(description = "用户信息", required = true) @RequestBody SysUser user) {
        // 设置默认org_id
        if (user.getOrgId() == null) {
            user.setOrgId(1L);
        }
        boolean success = userService.register(user);
        return success ? Result.success() : Result.error("创建失败");
    }

    @Operation(summary = "用户注册", description = "新用户注册，需要填写用户名、密码、真实姓名等信息")
    @OperationLog(module = "用户管理", type = "注册", description = "用户注册")
    @PostMapping("/register")
    public Result<Void> register(
            @Parameter(description = "注册信息", required = true) @Valid @RequestBody com.example.exam.dto.RegisterDTO registerDTO) {

        // 构建用户对象
        SysUser user = new SysUser();
        user.setUsername(registerDTO.getUsername());
        user.setRealName(registerDTO.getRealName());
        user.setPassword(registerDTO.getPassword());
        user.setEmail(registerDTO.getEmail());
        user.setPhone(registerDTO.getPhone());

        // 设置默认值
        user.setStatus(UserStatus.of(1));          // 默认启用
        user.setAuditStatus(AuditStatus.of(0));     // 默认草稿
        user.setRoleId(3L);         // 默认学生角色
        user.setOrgId(1L);          // 默认组织

        boolean success = userService.register(user);
        return success ? Result.success() : Result.error("注册失败");
    }

    @Operation(summary = "根据用户名查询用户", description = "根据用户名查询用户详细信息")
    @RequirePermission(value = "user:view", desc = "查看用户")
    @GetMapping("/username/{username}")
    public Result<SysUser> getUserByUsername(
            @Parameter(description = "用户名", required = true) @PathVariable String username) {
        SysUser user = userService.getUserByUsername(username);
        return user != null ? Result.success(user) : Result.error("用户不存在");
    }

    @Operation(summary = "根据ID查询用户", description = "根据用户ID查询用户详细信息")
    @RequirePermission(value = "user:view", desc = "查看用户")
    @GetMapping("/{id:[0-9]+}")
    public Result<SysUser> getUserById(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id) {
        SysUser user = userService.getById(id);
        return user != null ? Result.success(user) : Result.error("用户不存在");
    }

    @Operation(summary = "更新用户信息", description = "更新用户的个人信息")
    @RequirePermission(value = "user:update", desc = "更新用户")
    @OperationLog(module = "用户管理", type = "更新", description = "更新用户信息")
    @PutMapping("/{id:[0-9]+}")
    public Result<Void> updateUser(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id,
            @Parameter(description = "用户信息", required = true) @RequestBody SysUser user) {
        user.setUserId(id);

        // 如果密码为空或null，则不更新密码字段
        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            user.setPassword(null); // 设置为null，MyBatis Plus会忽略null值字段
        }

        boolean success = userService.updateById(user);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除用户", description = "逻辑删除用户（软删除）")
    @RequirePermission(value = "user:delete", desc = "删除用户")
    @OperationLog(module = "用户管理", type = "删除", description = "删除用户")
    @DeleteMapping("/{id:[0-9]+}")
    public Result<Void> deleteUser(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id) {
        boolean success = userService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }

    @Operation(summary = "更新个人资料", description = "更新当前登录用户的个人资料")
    @OperationLog(module = "个人中心", type = "更新", description = "更新个人资料")
    @PutMapping("/profile")
    public Result<Void> updateProfile(@Parameter(description = "个人资料", required = true) @RequestBody com.example.exam.dto.ProfileDTO profileDTO) {
        // 获取当前登录用户ID
        Long currentUserId = com.example.exam.util.SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return Result.error("未登录");
        }

        // 更新个人资料
        SysUser user = new SysUser();
        user.setUserId(currentUserId);
        user.setRealName(profileDTO.getRealName());
        user.setPhone(profileDTO.getPhone());
        user.setEmail(profileDTO.getEmail());
        // 将Integer转换为Gender枚举
        if (profileDTO.getGender() != null) {
            user.setGender(com.example.exam.common.enums.Gender.of(profileDTO.getGender()));
        }

        boolean success = userService.updateById(user);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "修改密码", description = "修改当前登录用户的密码")
    @OperationLog(module = "个人中心", type = "更新", description = "修改密码")
    @PostMapping("/update-password")
    public Result<Void> updatePassword(@Parameter(description = "密码信息", required = true) @RequestBody com.example.exam.dto.UpdatePasswordDTO updatePasswordDTO) {
        // 获取当前登录用户ID
        Long currentUserId = com.example.exam.util.SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return Result.error("未登录");
        }

        // 修改密码
        boolean success = userService.updatePassword(currentUserId, updatePasswordDTO.getOldPassword(), updatePasswordDTO.getNewPassword());
        return success ? Result.success() : Result.error("密码修改失败，请检查原密码是否正确");
    }

    @Operation(summary = "上传头像", description = "上传当前用户的头像")
    @OperationLog(module = "个人中心", type = "更新", description = "上传头像")
    @PostMapping("/avatar")
    public Result<java.util.Map<String, String>> uploadAvatar(@Parameter(description = "头像文件", required = true) @RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        // 获取当前登录用户ID
        Long currentUserId = com.example.exam.util.SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return Result.error("未登录");
        }

        try {
            // 验证文件
            if (file == null || file.isEmpty()) {
                return Result.error("请选择要上传的文件");
            }

            // 验证文件类型
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return Result.error("只能上传图片文件");
            }

            // 验证文件大小（限制2MB）
            if (file.getSize() > 2 * 1024 * 1024) {
                return Result.error("图片大小不能超过2MB");
            }

            // 获取文件扩展名
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // 这里应该调用文件上传服务，暂时返回一个模拟的URL
            // TODO: 实现文件上传服务（MinIO、OSS等）
            String avatarUrl = "/uploads/avatars/" + currentUserId + "_" + System.currentTimeMillis() + extension;

            log.info("上传头像：userId={}, filename={}, size={}", currentUserId, originalFilename, file.getSize());

            // 更新用户头像
            SysUser user = new SysUser();
            user.setUserId(currentUserId);
            user.setAvatar(avatarUrl);
            userService.updateById(user);

            java.util.Map<String, String> result = new java.util.HashMap<>();
            result.put("url", avatarUrl);
            return Result.success(result);
        } catch (Exception e) {
            log.error("上传头像失败", e);
            return Result.error("上传头像失败");
        }
    }
}

