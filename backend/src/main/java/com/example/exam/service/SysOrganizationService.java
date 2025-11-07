package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.system.SysOrganization;

import java.util.List;

/**
 * 组织Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
public interface SysOrganizationService extends IService<SysOrganization> {

    /**
     * 获取组织树
     * @return 组织树结构
     */
    List<SysOrganization> getOrganizationTree();

    /**
     * 获取指定组织的所有子组织（包括子子组织）
     * @param orgId 组织ID
     * @return 子组织列表
     */
    List<SysOrganization> getChildOrganizations(Long orgId);

    /**
     * 根据父ID查询直属子组织
     * @param parentId 父组织ID
     * @return 子组织列表
     */
    List<SysOrganization> getChildrenByParentId(Long parentId);

    /**
     * 检查组织编码是否已存在
     * @param orgCode 组织编码
     * @param excludeOrgId 排除的组织ID（用于更新时检查）
     * @return 是否存在
     */
    boolean isOrgCodeExists(String orgCode, Long excludeOrgId);

    /**
     * 检查组织下是否有子组织
     * @param orgId 组织ID
     * @return 是否有子组织
     */
    boolean hasChildren(Long orgId);

    /**
     * 检查组织下是否有用户
     * @param orgId 组织ID
     * @return 是否有用户
     */
    boolean hasUsers(Long orgId);

    /**
     * 批量删除组织（级联删除）
     * @param orgIds 组织ID列表
     * @return 是否成功
     */
    boolean batchDelete(List<Long> orgIds);
}

