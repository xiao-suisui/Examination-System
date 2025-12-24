package com.example.exam.mapper.system;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.system.SysRolePermission;
import org.apache.ibatis.annotations.Mapper;

/**
 * 角色权限关联表Mapper接口
 *
 * 模块：系统管理模块（exam-system）
 * 职责：角色权限关联数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface SysRolePermissionMapper extends BaseMapper<SysRolePermission> {

}

