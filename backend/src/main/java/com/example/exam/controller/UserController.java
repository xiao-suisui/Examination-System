package com.example.exam.controller;

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

    @Operation(summary = "用户注册", description = "新用户注册，需要填写用户名、密码、真实姓名等信息")
    @com.example.exam.annotation.OperationLog(module = "用户管理", type = "注册", description = "用户注册")
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
        user.setStatus(1);          // 默认启用
        user.setAuditStatus(0);     // 默认待审核
        user.setRoleId(3L);         // 默认学生角色
        user.setOrgId(1L);          // 默认组织

        boolean success = userService.register(user);
        return success ? Result.success() : Result.error("注册失败");
    }

    @Operation(summary = "根据用户名查询用户", description = "根据用户名查询用户详细信息")
    @GetMapping("/username/{username}")
    public Result<SysUser> getUserByUsername(
            @Parameter(description = "用户名", required = true) @PathVariable String username) {
        SysUser user = userService.getUserByUsername(username);
        return user != null ? Result.success(user) : Result.error("用户不存在");
    }

    @Operation(summary = "根据ID查询用户", description = "根据用户ID查询用户详细信息")
    @GetMapping("/{id}")
    public Result<SysUser> getUserById(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id) {
        SysUser user = userService.getById(id);
        return user != null ? Result.success(user) : Result.error("用户不存在");
    }

    @Operation(summary = "更新用户信息", description = "更新用户的个人信息")
    @com.example.exam.annotation.OperationLog(module = "用户管理", type = "更新", description = "更新用户信息")
    @PutMapping("/{id}")
    public Result<Void> updateUser(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id,
            @Parameter(description = "用户信息", required = true) @RequestBody SysUser user) {
        user.setUserId(id);
        boolean success = userService.updateById(user);
        return success ? Result.success() : Result.error("更新失败");
    }

    @Operation(summary = "删除用户", description = "逻辑删除用户（软删除）")
    @com.example.exam.annotation.OperationLog(module = "用户管理", type = "删除", description = "删除用户")
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(
            @Parameter(description = "用户ID", required = true) @PathVariable Long id) {
        boolean success = userService.removeById(id);
        return success ? Result.success() : Result.error("删除失败");
    }
}

