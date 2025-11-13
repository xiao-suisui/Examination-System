package com.example.exam.mapper.system;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.exam.dto.UserDTO;
import com.example.exam.entity.system.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 用户表Mapper接口
 *
 * 模块：系统管理模块（exam-system）
 * 职责：用户数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {

    /**
     * 根据用户名查询用户（用于登录）
     *
     * @param username 用户名
     * @return 用户信息
     */
    @Select("SELECT * FROM sys_user WHERE username = #{username} AND deleted = 0")
    SysUser selectByUsername(@Param("username") String username);

    /**
     * 根据手机号查询用户
     *
     * @param phone 手机号
     * @return 用户信息
     */
    @Select("SELECT * FROM sys_user WHERE phone = #{phone} AND deleted = 0")
    SysUser selectByPhone(@Param("phone") String phone);

    /**
     * 根据邮箱查询用户
     *
     * @param email 邮箱
     * @return 用户信息
     */
    @Select("SELECT * FROM sys_user WHERE email = #{email} AND deleted = 0")
    SysUser selectByEmail(@Param("email") String email);

    /**
     * 分页查询用户DTO（包含角色名称和组织名称）
     *
     * @param page     分页对象
     * @param username 用户名（可选）
     * @param realName 真实姓名（可选）
     * @param status   状态（可选）
     * @return 用户DTO分页数据
     */
    IPage<UserDTO> selectUserDTOPage(Page<?> page,
                                     @Param("username") String username,
                                     @Param("realName") String realName,
                                     @Param("status") Integer status);
}

