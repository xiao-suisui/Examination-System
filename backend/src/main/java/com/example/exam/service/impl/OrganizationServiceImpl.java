package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.mapper.system.SysOrganizationMapper;
import com.example.exam.service.OrganizationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * 组织Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-09
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrganizationServiceImpl extends ServiceImpl<SysOrganizationMapper, SysOrganization>
        implements OrganizationService {

    @Override
    public List<SysOrganization> getOrganizationTree() {
        // 查询所有组织
        List<SysOrganization> allOrganizations = this.list(
            new LambdaQueryWrapper<SysOrganization>()
                .orderByAsc(SysOrganization::getSort)
        );

        // 构建树形结构（从根节点parentId=0开始）
        return buildTree(allOrganizations, 0L);
    }

    @Override
    public List<SysOrganization> buildTree(List<SysOrganization> organizations, Long parentId) {
        List<SysOrganization> tree = new ArrayList<>();

        for (SysOrganization org : organizations) {
            if (parentId.equals(org.getParentId())) {
                // 递归查找子节点
                List<SysOrganization> children = buildTree(organizations, org.getOrgId());
                org.setChildren(children);
                tree.add(org);
            }
        }

        return tree;
    }

    @Override
    public boolean isDescendant(Long targetId, Long orgId) {
        if (targetId == null || orgId == null) {
            return false;
        }

        if (targetId.equals(orgId)) {
            return true;
        }

        // 查询targetId的所有子组织
        List<SysOrganization> children = this.list(
            new LambdaQueryWrapper<SysOrganization>()
                .eq(SysOrganization::getParentId, targetId)
        );

        // 递归检查每个子组织
        for (SysOrganization child : children) {
            if (isDescendant(child.getOrgId(), orgId)) {
                return true;
            }
        }

        return false;
    }
}

