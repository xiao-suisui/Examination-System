package com.example.exam.mapper.system;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.system.SysPermission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 权限表 Mapper 接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Mapper
public interface SysPermissionMapper extends BaseMapper<SysPermission> {

    /**
     * 根据角色ID获取权限列表
     */
    @Select("SELECT p.* FROM sys_permission p " +
            "INNER JOIN sys_role_permission rp ON p.perm_id = rp.perm_id " +
            "WHERE rp.role_id = #{roleId} AND p.deleted = 0")
    List<SysPermission> selectByRoleId(@Param("roleId") Long roleId);

    /**
     * 根据用户ID获取权限列表
     */
    @Select("SELECT DISTINCT p.* FROM sys_permission p " +
            "INNER JOIN sys_role_permission rp ON p.perm_id = rp.perm_id " +
            "INNER JOIN sys_user u ON u.role_id = rp.role_id " +
            "WHERE u.user_id = #{userId} AND p.deleted = 0 AND u.deleted = 0")
    List<SysPermission> selectByUserId(@Param("userId") Long userId);

    /**
     * 获取所有权限（树形结构用）
     */
    @Select("SELECT * FROM sys_permission WHERE deleted = 0 ORDER BY sort ASC, perm_id ASC")
    List<SysPermission> selectAllPermissions();
}

