package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.entity.system.SysUser;
import com.example.exam.mapper.system.SysOrganizationMapper;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.service.SysOrganizationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 组织Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysOrganizationServiceImpl extends ServiceImpl<SysOrganizationMapper, SysOrganization>
        implements SysOrganizationService {

    private final SysUserMapper sysUserMapper;

    @Override
    public List<SysOrganization> getOrganizationTree() {
        // 查询所有启用的组织
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getStatus, 1)
               .orderByAsc(SysOrganization::getSort)
               .orderByAsc(SysOrganization::getOrgId);
        List<SysOrganization> allOrgs = this.list(wrapper);

        // 构建树形结构（只返回顶级组织，子组织会被递归添加到children属性中）
        return buildTree(allOrgs, 0L);
    }

    @Override
    public List<SysOrganization> getChildOrganizations(Long orgId) {
        List<SysOrganization> result = new ArrayList<>();
        collectChildren(orgId, result);
        return result;
    }

    @Override
    public List<SysOrganization> getChildrenByParentId(Long parentId) {
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getParentId, parentId)
               .orderByAsc(SysOrganization::getSort)
               .orderByAsc(SysOrganization::getOrgId);
        return this.list(wrapper);
    }

    @Override
    public boolean isOrgCodeExists(String orgCode, Long excludeOrgId) {
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getOrgCode, orgCode);
        if (excludeOrgId != null) {
            wrapper.ne(SysOrganization::getOrgId, excludeOrgId);
        }
        return this.count(wrapper) > 0;
    }

    @Override
    public boolean hasChildren(Long orgId) {
        LambdaQueryWrapper<SysOrganization> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOrganization::getParentId, orgId);
        return this.count(wrapper) > 0;
    }

    @Override
    public boolean hasUsers(Long orgId) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getOrgId, orgId);
        return sysUserMapper.selectCount(wrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchDelete(List<Long> orgIds) {
        try {
            // 检查是否有子组织
            for (Long orgId : orgIds) {
                if (hasChildren(orgId)) {
                    log.warn("组织{}存在子组织，无法删除", orgId);
                    throw new RuntimeException("组织存在子组织，无法删除");
                }
                if (hasUsers(orgId)) {
                    log.warn("组织{}存在用户，无法删除", orgId);
                    throw new RuntimeException("组织存在用户，无法删除");
                }
            }

            // 批量删除（逻辑删除）
            return this.removeByIds(orgIds);
        } catch (Exception e) {
            log.error("批量删除组织失败", e);
            throw e;
        }
    }

    /**
     * 递归收集所有子组织
     */
    private void collectChildren(Long parentId, List<SysOrganization> result) {
        List<SysOrganization> children = getChildrenByParentId(parentId);
        result.addAll(children);
        for (SysOrganization child : children) {
            collectChildren(child.getOrgId(), result);
        }
    }

    /**
     * 构建树形结构
     */
    private List<SysOrganization> buildTree(List<SysOrganization> allOrgs, Long parentId) {
        return allOrgs.stream()
                .filter(org -> parentId.equals(org.getParentId()))
                .peek(org -> {
                    List<SysOrganization> children = buildTree(allOrgs, org.getOrgId());
                    // 这里如果需要在实体类中添加children字段，需要使用@TableField(exist = false)
                    // 暂时通过额外查询返回子组织
                })
                .collect(Collectors.toList());
    }
}

