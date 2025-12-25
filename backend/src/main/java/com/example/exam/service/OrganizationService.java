package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.system.SysOrganization;

import java.util.List;

/**
 * 组织Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
public interface OrganizationService extends IService<SysOrganization> {

    /**
     * 获取组织树形结构
     *
     * @return 组织树
     */
    List<SysOrganization> getOrganizationTree();

    /**
     * 构建树形结构
     *
     * @param organizations 组织列表
     * @param parentId 父组织ID
     * @return 树形结构
     */
    List<SysOrganization> buildTree(List<SysOrganization> organizations, Long parentId);

    /**
     * 判断targetId是否是orgId的子孙节点
     *
     * @param targetId 目标组织ID
     * @param orgId 组织ID
     * @return true-是子孙节点，false-不是
     */
    boolean isDescendant(Long targetId, Long orgId);
}

