package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.UserStatus;
import com.example.exam.dto.UserDTO;
import com.example.exam.entity.system.SysUser;

/**
 * 用户Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface UserService extends IService<SysUser> {

    /**
     * 用户注册
     *
     * @param user 用户信息
     * @return 是否注册成功
     */
    boolean register(SysUser user);

    /**
     * 分页查询用户DTO（包含角色名称）
     *
     * @param page     分页对象
     * @param username 用户名（可选）
     * @param realName 真实姓名（可选）
     * @param status   状态（可选）
     * @return 用户DTO分页数据
     */
    IPage<UserDTO> pageUserDTO(Page<?> page, String username, String realName, Integer status);

    /**
     * 根据用户名查询用户
     *
     * @param username 用户名
     * @return 用户信息
     */
    SysUser getUserByUsername(String username);

    /**
     * 根据用户名和密码验证用户（用于登录）
     *
     * @param username 用户名
     * @param password 密码
     * @return 用户信息，验证失败返回null
     */
    SysUser validateUser(String username, String password);

    /**
     * 更新用户状态
     *
     * @param userId 用户ID
     * @param status 状态（DISABLED-禁用，ENABLED-启用）
     * @return 是否更新成功
     */
    boolean updateUserStatus(Long userId, UserStatus status);

    /**
     * 更新最后登录时间和IP
     *
     * @param userId 用户ID
     * @param ip     登录IP
     */
    void updateLastLogin(Long userId, String ip);

    /**
     * 重置密码
     *
     * @param userId 用户ID
     * @param newPassword 新密码
     * @return 是否重置成功
     */
    boolean resetPassword(Long userId, String newPassword);

    /**
     * 修改密码
     *
     * @param userId 用户ID
     * @param oldPassword 旧密码
     * @param newPassword 新密码
     * @return 是否修改成功
     */
    boolean changePassword(Long userId, String oldPassword, String newPassword);

    /**
     * 修改密码（updatePassword别名方法）
     *
     * @param userId 用户ID
     * @param oldPassword 旧密码
     * @param newPassword 新密码
     * @return 是否修改成功
     */
    default boolean updatePassword(Long userId, String oldPassword, String newPassword) {
        return changePassword(userId, oldPassword, newPassword);
    }
}

