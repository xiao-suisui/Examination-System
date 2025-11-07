package com.example.exam.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysUser;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 用户Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements UserService {

    private final PasswordEncoder passwordEncoder;

    @Override
    public SysUser getUserByUsername(String username) {
        return baseMapper.selectByUsername(username);
    }

    public SysUser getUserByPhone(String phone) {
        return baseMapper.selectByPhone(phone);
    }

    public SysUser getUserByEmail(String email) {
        return baseMapper.selectByEmail(email);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean register(SysUser user) {
        // 加密密码
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        // 设置审核状态为待审核
        user.setAuditStatus(0);
        return save(user);
    }

    @Override
    public SysUser validateUser(String username, String password) {
        SysUser user = getUserByUsername(username);
        if (user != null && passwordEncoder.matches(password, user.getPassword())) {
            return user;
        }
        return null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateUserStatus(Long userId, Integer status) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setStatus(status);
        return updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean resetPassword(Long userId, String newPassword) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setPassword(passwordEncoder.encode(newPassword));
        return updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean changePassword(Long userId, String oldPassword, String newPassword) {
        SysUser user = getById(userId);
        if (user == null) {
            return false;
        }
        // 验证旧密码
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            return false;
        }
        // 更新新密码
        user.setPassword(passwordEncoder.encode(newPassword));
        return updateById(user);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateLastLogin(Long userId, String ip) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setLastLoginTime(LocalDateTime.now());
        user.setLastLoginIp(ip);
        updateById(user);
    }
}

