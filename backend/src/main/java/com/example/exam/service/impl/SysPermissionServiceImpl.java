package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.dto.SysPermissionDTO;
import com.example.exam.entity.system.SysPermission;
import com.example.exam.entity.system.SysRolePermission;
import com.example.exam.mapper.system.SysPermissionMapper;
import com.example.exam.mapper.system.SysRolePermissionMapper;
import com.example.exam.service.PermissionCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 权限服务实现类
 * 集成Redis缓存提升性能
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-24
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysPermissionServiceImpl extends ServiceImpl<SysPermissionMapper, SysPermission>
        implements com.example.exam.service.SysPermissionService {

    private final SysRolePermissionMapper rolePermissionMapper;
    private final PermissionCacheService permissionCacheService;

    @Override
    public List<SysPermission> getUserPermissions(Long userId) {
        return baseMapper.selectByUserId(userId);
    }

    @Override
    public Set<String> getUserPermissionCodes(Long userId) {
        // 先尝试从缓存获取
        Set<String> cachedPermissions = permissionCacheService.getCachedUserPermissions(userId);
        if (cachedPermissions != null) {
            log.debug("从缓存获取用户权限 - userId: {}", userId);
            return cachedPermissions;
        }

        // 缓存未命中，从数据库查询
        log.debug("缓存未命中，从数据库查询用户权限 - userId: {}", userId);
        List<SysPermission> permissions = getUserPermissions(userId);
        Set<String> permissionCodes = permissions.stream()
                .map(SysPermission::getPermCode)
                .collect(Collectors.toSet());

        // 缓存查询结果
        permissionCacheService.cacheUserPermissions(userId, permissionCodes);

        return permissionCodes;
    }

    @Override
    public List<SysPermission> getRolePermissions(Long roleId) {
        return baseMapper.selectByRoleId(roleId);
    }

    @Override
    public List<SysPermissionDTO> getPermissionTree() {
        // 获取所有权限
        List<SysPermission> allPermissions = baseMapper.selectAllPermissions();

        // 转换为DTO
        List<SysPermissionDTO> dtoList = allPermissions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        // 构建树形结构
        return buildTree(dtoList, 0L);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean assignPermissionsToRole(Long roleId, List<Long> permIds) {
        // 删除原有权限关联
        LambdaQueryWrapper<SysRolePermission> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(SysRolePermission::getRoleId, roleId);
        rolePermissionMapper.delete(deleteWrapper);

        // 批量插入新的权限关联
        if (permIds != null && !permIds.isEmpty()) {
            List<SysRolePermission> rolePermissions = permIds.stream()
                    .map(permId -> SysRolePermission.builder()
                            .roleId(roleId)
                            .permId(permId)
                            .build())
                    .collect(Collectors.toList());

            // 批量插入
            for (SysRolePermission rp : rolePermissions) {
                rolePermissionMapper.insert(rp);
            }
        }

        log.info("为角色[{}]分配权限成功，权限数量：{}", roleId, permIds == null ? 0 : permIds.size());

        // 清除该角色下所有用户的权限缓存
        permissionCacheService.evictPermissionsByRole(roleId);

        return true;
    }

    @Override
    public boolean hasPermission(Long userId, String permCode) {
        // 使用带缓存的getUserPermissionCodes方法
        Set<String> permCodes = getUserPermissionCodes(userId);
        return permCodes.contains(permCode);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createPermission(SysPermission permission) {
        // 检查权限编码是否已存在
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getPermCode, permission.getPermCode());
        long count = baseMapper.selectCount(wrapper);
        if (count > 0) {
            throw new RuntimeException("权限编码已存在：" + permission.getPermCode());
        }

        return save(permission);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePermission(SysPermission permission) {
        // 检查权限是否存在
        SysPermission existing = baseMapper.selectById(permission.getPermId());
        if (existing == null) {
            throw new RuntimeException("权限不存在");
        }

        // 检查权限编码是否重复（排除自身）
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getPermCode, permission.getPermCode())
                .ne(SysPermission::getPermId, permission.getPermId());
        long count = baseMapper.selectCount(wrapper);
        if (count > 0) {
            throw new RuntimeException("权限编码已存在：" + permission.getPermCode());
        }

        return updateById(permission);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deletePermission(Long permId) {
        // 检查是否有子权限
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysPermission::getParentId, permId);
        long count = baseMapper.selectCount(wrapper);
        if (count > 0) {
            throw new RuntimeException("存在子权限，无法删除");
        }

        // 删除角色权限关联
        LambdaQueryWrapper<SysRolePermission> rpWrapper = new LambdaQueryWrapper<>();
        rpWrapper.eq(SysRolePermission::getPermId, permId);
        rolePermissionMapper.delete(rpWrapper);

        // 删除权限
        return removeById(permId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void initDefaultPermissions() {
        // 检查是否已初始化
        long count = baseMapper.selectCount(null);
        if (count > 0) {
            log.info("权限已初始化，跳过");
            return;
        }

        log.info("开始初始化默认权限...");

        List<SysPermission> permissions = new ArrayList<>();

        // ========== 系统管理 ==========
        SysPermission sysManage = createPermission(null, "系统管理", "system", "MENU", "/system", 1);
        permissions.add(sysManage);

        // 用户管理
        SysPermission userManage = createPermission(null, "用户管理", "system:user", "MENU", "/system/user", 1);
        permissions.add(userManage);
        permissions.add(createPermission(null, "查看用户", "system:user:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建用户", "system:user:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑用户", "system:user:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除用户", "system:user:delete", "BUTTON", null, 4));
        permissions.add(createPermission(null, "审核用户", "system:user:audit", "BUTTON", null, 5));

        // 角色管理
        SysPermission roleManage = createPermission(null, "角色管理", "system:role", "MENU", "/system/role", 2);
        permissions.add(roleManage);
        permissions.add(createPermission(null, "查看角色", "system:role:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建角色", "system:role:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑角色", "system:role:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除角色", "system:role:delete", "BUTTON", null, 4));
        permissions.add(createPermission(null, "分配权限", "system:role:assign", "BUTTON", null, 5));

        // 组织管理
        SysPermission orgManage = createPermission(null, "组织管理", "system:org", "MENU", "/system/organization", 3);
        permissions.add(orgManage);
        permissions.add(createPermission(null, "查看组织", "system:org:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建组织", "system:org:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑组织", "system:org:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除组织", "system:org:delete", "BUTTON", null, 4));

        // ========== 题库管理 ==========
        SysPermission bankManage = createPermission(null, "题库管理", "bank", "MENU", "/question-bank", 2);
        permissions.add(bankManage);
        permissions.add(createPermission(null, "查看题库", "bank:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建题库", "bank:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑题库", "bank:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除题库", "bank:delete", "BUTTON", null, 4));

        // ========== 题目管理 ==========
        SysPermission questionManage = createPermission(null, "题目管理", "question", "MENU", "/question", 3);
        permissions.add(questionManage);
        permissions.add(createPermission(null, "查看题目", "question:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建题目", "question:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑题目", "question:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除题目", "question:delete", "BUTTON", null, 4));
        permissions.add(createPermission(null, "导入题目", "question:import", "BUTTON", null, 5));
        permissions.add(createPermission(null, "导出题目", "question:export", "BUTTON", null, 6));

        // ========== 试卷管理 ==========
        SysPermission paperManage = createPermission(null, "试卷管理", "paper", "MENU", "/paper", 4);
        permissions.add(paperManage);
        permissions.add(createPermission(null, "查看试卷", "paper:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建试卷", "paper:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑试卷", "paper:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除试卷", "paper:delete", "BUTTON", null, 4));
        permissions.add(createPermission(null, "审核试卷", "paper:audit", "BUTTON", null, 5));
        permissions.add(createPermission(null, "发布试卷", "paper:publish", "BUTTON", null, 6));

        // ========== 考试管理 ==========
        SysPermission examManage = createPermission(null, "考试管理", "exam", "MENU", "/exam", 5);
        permissions.add(examManage);
        permissions.add(createPermission(null, "查看考试", "exam:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "创建考试", "exam:create", "BUTTON", null, 2));
        permissions.add(createPermission(null, "编辑考试", "exam:update", "BUTTON", null, 3));
        permissions.add(createPermission(null, "删除考试", "exam:delete", "BUTTON", null, 4));
        permissions.add(createPermission(null, "发布考试", "exam:publish", "BUTTON", null, 5));
        permissions.add(createPermission(null, "开始考试", "exam:start", "BUTTON", null, 6));
        permissions.add(createPermission(null, "结束考试", "exam:end", "BUTTON", null, 7));
        permissions.add(createPermission(null, "监控考试", "exam:monitor", "BUTTON", null, 8));

        // ========== 阅卷管理 ==========
        SysPermission gradingManage = createPermission(null, "阅卷管理", "grading", "MENU", "/grading", 6);
        permissions.add(gradingManage);
        permissions.add(createPermission(null, "查看答卷", "grading:view", "BUTTON", null, 1));
        permissions.add(createPermission(null, "批阅试卷", "grading:grade", "BUTTON", null, 2));
        permissions.add(createPermission(null, "发布成绩", "grading:publish", "BUTTON", null, 3));

        // ========== 统计分析 ==========
        SysPermission statsManage = createPermission(null, "统计分析", "statistics", "MENU", "/statistics", 7);
        permissions.add(statsManage);
        permissions.add(createPermission(null, "考试统计", "statistics:exam", "BUTTON", null, 1));
        permissions.add(createPermission(null, "成绩统计", "statistics:score", "BUTTON", null, 2));
        permissions.add(createPermission(null, "题目统计", "statistics:question", "BUTTON", null, 3));

        // 批量保存
        saveBatch(permissions);

        log.info("默认权限初始化完成，共{}条", permissions.size());
    }

    /**
     * 创建权限对象
     */
    private SysPermission createPermission(Long parentId, String name, String code, String type, String url, int sort) {
        return SysPermission.builder()
                .parentId(parentId == null ? 0L : parentId)
                .permName(name)
                .permCode(code)
                .permType(type)
                .permUrl(url)
                .sort(sort)
                .build();
    }

    /**
     * 转换为DTO
     */
    private SysPermissionDTO convertToDTO(SysPermission permission) {
        return SysPermissionDTO.builder()
                .permId(permission.getPermId())
                .permName(permission.getPermName())
                .permCode(permission.getPermCode())
                .permType(permission.getPermType())
                .permUrl(permission.getPermUrl())
                .parentId(permission.getParentId())
                .sort(permission.getSort())
                .createTime(permission.getCreateTime())
                .updateTime(permission.getUpdateTime())
                .build();
    }

    /**
     * 构建树形结构
     */
    private List<SysPermissionDTO> buildTree(List<SysPermissionDTO> allNodes, Long parentId) {
        List<SysPermissionDTO> children = allNodes.stream()
                .filter(node -> parentId.equals(node.getParentId()))
                .collect(Collectors.toList());

        children.forEach(child -> {
            List<SysPermissionDTO> subChildren = buildTree(allNodes, child.getPermId());
            child.setChildren(subChildren.isEmpty() ? null : subChildren);
        });

        return children;
    }
}

