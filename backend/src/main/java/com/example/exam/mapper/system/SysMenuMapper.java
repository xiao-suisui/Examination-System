package com.example.exam.mapper.system;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.system.SysMenu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 菜单表Mapper接口
 *
 * 模块：系统管理模块（exam-system）
 * 职责：菜单数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface SysMenuMapper extends BaseMapper<SysMenu> {

    /**
     * 根据用户ID查询菜单列表
     *
     * @param userId 用户ID
     * @return 菜单列表
     */
    @Select("SELECT DISTINCT m.* FROM sys_menu m " +
            "INNER JOIN sys_permission p ON m.perm_code = p.perm_code " +
            "INNER JOIN sys_role_permission rp ON p.perm_id = rp.perm_id " +
            "INNER JOIN sys_user u ON u.role_id = rp.role_id " +
            "WHERE u.user_id = #{userId} AND m.status = 1 AND m.visible = 1 " +
            "ORDER BY m.sort ASC")
    List<SysMenu> selectMenusByUserId(@Param("userId") Long userId);
}

