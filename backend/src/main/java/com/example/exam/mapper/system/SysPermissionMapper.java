package com.example.exam.mapper.system;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.system.SysPermission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 权限表Mapper接口
 *
 * 模块：系统管理模块（exam-system）
 * 职责：权限数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface SysPermissionMapper extends BaseMapper<SysPermission> {

    /**
     * 根据角色ID查询权限列表
     *
     * @param roleId 角色ID
     * @return 权限列表
     */
    @Select("SELECT p.* FROM sys_permission p " +
            "INNER JOIN sys_role_permission rp ON p.perm_id = rp.perm_id " +
            "WHERE rp.role_id = #{roleId}")
    List<SysPermission> selectPermissionsByRoleId(@Param("roleId") Long roleId);

    /**
     * 根据用户ID查询权限列表
     *
     * @param userId 用户ID
     * @return 权限列表
     */
    @Select("SELECT DISTINCT p.* FROM sys_permission p " +
            "INNER JOIN sys_role_permission rp ON p.perm_id = rp.perm_id " +
            "INNER JOIN sys_user u ON u.role_id = rp.role_id " +
            "WHERE u.user_id = #{userId} AND u.deleted = 0 AND u.status = 1")
    List<SysPermission> selectPermissionsByUserId(@Param("userId") Long userId);
}

