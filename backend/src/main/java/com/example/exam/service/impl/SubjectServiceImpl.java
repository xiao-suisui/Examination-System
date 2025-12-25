package com.example.exam.service.impl;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.common.exception.BusinessException;
import com.example.exam.dto.subject.*;
import com.example.exam.entity.subject.Subject;
import com.example.exam.entity.subject.SubjectManager;
import com.example.exam.entity.subject.SubjectUser;
import com.example.exam.entity.system.SysUser;
import com.example.exam.entity.system.SysOrganization;
import com.example.exam.mapper.subject.SubjectMapper;
import com.example.exam.mapper.subject.SubjectManagerMapper;
import com.example.exam.mapper.subject.SubjectUserMapper;
import com.example.exam.mapper.system.SysUserMapper;
import com.example.exam.mapper.system.SysOrganizationMapper;
import com.example.exam.service.SubjectService;
import com.example.exam.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 科目Service实现类
 *
 * @author system
 * @since 2025-12-20
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SubjectServiceImpl extends ServiceImpl<SubjectMapper, Subject> implements SubjectService {

    private final SubjectManagerMapper subjectManagerMapper;
    private final SubjectUserMapper subjectUserMapper;
    private final SysUserMapper sysUserMapper;
    private final SysOrganizationMapper sysOrganizationMapper;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String REDIS_KEY_USER_SUBJECTS = "subject:user:";
    private static final String REDIS_KEY_USER_PERMISSIONS = "subject:user:%s:permissions:%s";
    private static final long CACHE_EXPIRE_HOURS = 24;

    private static final String[] ALL_PERMISSIONS = {
            "MANAGE_STUDENT", "MANAGE_EXAM", "MANAGE_PAPER",
            "MANAGE_QUESTION_BANK", "GRADE_EXAM", "VIEW_ANALYSIS"
    };

    @Override
    public IPage<SubjectDTO> pageSubjects(SubjectQueryDTO query) {
        Long userId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();

        LambdaQueryWrapper<Subject> wrapper = new LambdaQueryWrapper<>();

        // 数据权限过滤
        if (!"ADMIN".equals(roleCode)) {
            if ("ACADEMIC_ADMIN".equals(roleCode)) {
                // 学院管理员：只能看本学院的科目
                Long orgId = SecurityUtils.getOrgId();
                wrapper.eq(Subject::getOrgId, orgId);
            } else if ("TEACHER".equals(roleCode)) {
                // 教师：只能看管理的科目
                List<Long> managedSubjectIds = getUserManagedSubjectIds(userId);
                if (managedSubjectIds.isEmpty()) {
                    return new Page<>();
                }
                wrapper.in(Subject::getSubjectId, managedSubjectIds);
            }
        }

        // 查询条件
        wrapper.and(StringUtils.hasText(query.getKeyword()), w -> w
                .like(Subject::getSubjectName, query.getKeyword())
                .or()
                .like(Subject::getSubjectCode, query.getKeyword())
        );
        wrapper.eq(query.getOrgId() != null, Subject::getOrgId, query.getOrgId());
        wrapper.eq(query.getStatus() != null, Subject::getStatus, query.getStatus());
        wrapper.eq(query.getCreateUserId() != null, Subject::getCreateUserId, query.getCreateUserId());
        wrapper.orderByDesc(Subject::getCreateTime);

        IPage<Subject> page = this.page(new Page<>(query.getCurrent(), query.getSize()), wrapper);
        return page.convert(this::convertToDTO);
    }

    @Override
    public SubjectDTO getSubjectDetail(Long subjectId) {
        Subject subject = this.getById(subjectId);
        if (subject == null) {
            throw new BusinessException("科目不存在");
        }
        return convertToDTO(subject);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createSubject(SubjectCreateDTO dto) {
        Long userId = SecurityUtils.getUserId();

        // 检查科目编码是否重复
        LambdaQueryWrapper<Subject> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Subject::getSubjectCode, dto.getSubjectCode());
        wrapper.eq(Subject::getOrgId, dto.getOrgId());
        if (this.count(wrapper) > 0) {
            throw new BusinessException("科目编码已存在");
        }

        // 创建科目
        Subject subject = new Subject();
        subject.setSubjectName(dto.getSubjectName());
        subject.setSubjectCode(dto.getSubjectCode());
        subject.setOrgId(dto.getOrgId());
        subject.setDescription(dto.getDescription());
        subject.setCoverImage(dto.getCoverImage());
        subject.setCredit(dto.getCredit());
        subject.setSort(dto.getSort());
        subject.setStatus(1);
        // 注意：createUserId 已由 MyBatis-Plus 自动填充，无需手动设置
        this.save(subject);

        // 自动添加创建者为管理员
        SubjectManager manager = new SubjectManager();
        manager.setSubjectId(subject.getSubjectId());
        manager.setUserId(userId);
        manager.setIsCreator(1);
        manager.setManagerType(1);
        manager.setPermissions(JSON.toJSONString(ALL_PERMISSIONS));
        subjectManagerMapper.insert(manager);

        // 清除缓存
        clearUserCache(userId);

        log.info("创建科目成功：subjectId={}, subjectName={}, userId={}",
                subject.getSubjectId(), subject.getSubjectName(), userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSubject(SubjectUpdateDTO dto) {
        Subject subject = this.getById(dto.getSubjectId());
        if (subject == null) {
            throw new BusinessException("科目不存在");
        }

        // 检查权限
        Long userId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();
        if (!"ADMIN".equals(roleCode) && !isCreator(userId, dto.getSubjectId())) {
            throw new BusinessException("无权限修改该科目");
        }

        // 更新科目
        subject.setSubjectName(dto.getSubjectName());
        subject.setSubjectCode(dto.getSubjectCode());
        subject.setOrgId(dto.getOrgId());
        subject.setDescription(dto.getDescription());
        subject.setCoverImage(dto.getCoverImage());
        subject.setCredit(dto.getCredit());
        subject.setSort(dto.getSort());
        if (dto.getStatus() != null) {
            subject.setStatus(dto.getStatus());
        }
        this.updateById(subject);

        log.info("更新科目成功：subjectId={}, userId={}", dto.getSubjectId(), userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteSubject(Long subjectId) {
        Subject subject = this.getById(subjectId);
        if (subject == null) {
            throw new BusinessException("科目不存在");
        }

        // 检查权限
        Long userId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();
        if (!"ADMIN".equals(roleCode) && !isCreator(userId, subjectId)) {
            throw new BusinessException("无权限删除该科目");
        }

        // 检查是否有学生
        LambdaQueryWrapper<SubjectUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectUser::getSubjectId, subjectId);
        wrapper.eq(SubjectUser::getUserType, 4); // 4表示学生
        long studentCount = subjectUserMapper.selectCount(wrapper);
        if (studentCount > 0) {
            throw new BusinessException("该科目下还有学生，无法删除");
        }

        // 软删除科目
        this.removeById(subjectId);

        log.info("删除科目成功：subjectId={}, userId={}", subjectId, userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addManager(Long subjectId, Long userId, Integer managerType, String[] permissions) {
        // 检查科目是否存在
        Subject subject = this.getById(subjectId);
        if (subject == null) {
            throw new BusinessException("科目不存在");
        }

        // 检查权限（只有创建者或系统管理员可以添加管理员）
        Long currentUserId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();
        if (!"ADMIN".equals(roleCode) && !isCreator(currentUserId, subjectId)) {
            throw new BusinessException("无权限添加管理员");
        }

        // 检查是否已存在
        LambdaQueryWrapper<SubjectManager> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectManager::getSubjectId, subjectId);
        wrapper.eq(SubjectManager::getUserId, userId);
        if (subjectManagerMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("该用户已是科目管理员");
        }

        // 添加管理员
        SubjectManager manager = new SubjectManager();
        manager.setSubjectId(subjectId);
        manager.setUserId(userId);
        manager.setIsCreator(0);
        manager.setManagerType(managerType);
        manager.setPermissions(JSON.toJSONString(permissions));
        subjectManagerMapper.insert(manager);

        // 清除被添加用户的缓存
        clearUserCache(userId);

        log.info("添加科目管理员成功：subjectId={}, userId={}, managerType={}",
                subjectId, userId, managerType);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void removeManager(Long subjectId, Long userId) {
        // 检查权限
        Long currentUserId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();
        if (!"ADMIN".equals(roleCode) && !isCreator(currentUserId, subjectId)) {
            throw new BusinessException("无权限移除管理员");
        }

        // 不能移除创建者
        LambdaQueryWrapper<SubjectManager> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectManager::getSubjectId, subjectId);
        wrapper.eq(SubjectManager::getUserId, userId);
        wrapper.eq(SubjectManager::getIsCreator, 1);
        if (subjectManagerMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("不能移除科目创建者");
        }

        // 移除管理员
        wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectManager::getSubjectId, subjectId);
        wrapper.eq(SubjectManager::getUserId, userId);
        subjectManagerMapper.delete(wrapper);

        // 清除被移除用户的缓存
        clearUserCache(userId);

        log.info("移除科目管理员成功：subjectId={}, userId={}", subjectId, userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateManagerPermissions(Long subjectId, Long userId, String[] permissions) {
        // 检查权限
        Long currentUserId = SecurityUtils.getUserId();
        String roleCode = SecurityUtils.getRoleCode();
        if (!"ADMIN".equals(roleCode) && !isCreator(currentUserId, subjectId)) {
            throw new BusinessException("无权限修改管理员权限");
        }

        // 更新权限
        LambdaQueryWrapper<SubjectManager> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectManager::getSubjectId, subjectId);
        wrapper.eq(SubjectManager::getUserId, userId);
        SubjectManager manager = subjectManagerMapper.selectOne(wrapper);
        if (manager == null) {
            throw new BusinessException("管理员不存在");
        }

        manager.setPermissions(JSON.toJSONString(permissions));
        subjectManagerMapper.updateById(manager);

        // 清除缓存
        clearUserCache(userId);

        log.info("更新科目管理员权限成功：subjectId={}, userId={}", subjectId, userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enrollStudents(Long subjectId, List<Long> studentIds, Integer enrollType) {
        // 检查科目状态
        Subject subject = this.getById(subjectId);
        if (subject == null) {
            throw new BusinessException("科目不存在");
        }
        if (subject.getStatus() == 0) {
            throw new BusinessException("科目已禁用，无法选课");
        }

        // 批量插入（不检查org_id，支持跨学院选课）
        List<SubjectUser> list = studentIds.stream()
                .filter(studentId -> {
                    // 过滤已选课的学生
                    LambdaQueryWrapper<SubjectUser> wrapper = new LambdaQueryWrapper<>();
                    wrapper.eq(SubjectUser::getUserId, studentId);
                    wrapper.eq(SubjectUser::getSubjectId, subjectId);
                    wrapper.eq(SubjectUser::getUserType, 4); // 4表示学生
                    return subjectUserMapper.selectCount(wrapper) == 0;
                })
                .map(studentId -> {
                    SubjectUser su = new SubjectUser();
                    su.setUserId(studentId);
                    su.setSubjectId(subjectId);
                    su.setUserType(4); // 4表示学生
                    su.setPermissions(null); // 学生默认无特殊权限
                    return su;
                }).toList();

        if (!list.isEmpty()) {
            list.forEach(subjectUserMapper::insert);
            log.info("添加学生到科目成功：subjectId={}, count={}", subjectId, list.size());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdrawStudent(Long subjectId, Long studentId) {
        LambdaQueryWrapper<SubjectUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectUser::getSubjectId, subjectId);
        wrapper.eq(SubjectUser::getUserId, studentId);
        wrapper.eq(SubjectUser::getUserType, 4); // 4表示学生
        subjectUserMapper.delete(wrapper);

        log.info("移除学生成功：subjectId={}, studentId={}", subjectId, studentId);
    }

    @Override
    public boolean hasSubjectPermission(Long userId, Long subjectId, String permission) {
        // 检查Redis缓存
        String cacheKey = String.format(REDIS_KEY_USER_PERMISSIONS, userId, subjectId);
        String cachedPermissions = (String) redisTemplate.opsForValue().get(cacheKey);

        if (cachedPermissions != null) {
            return cachedPermissions.contains(permission);
        }

        // 查询数据库
        String permissionsJson = baseMapper.selectUserPermissions(userId, subjectId);
        if (permissionsJson == null) {
            return false;
        }

        // 缓存到Redis
        redisTemplate.opsForValue().set(cacheKey, permissionsJson, CACHE_EXPIRE_HOURS, TimeUnit.HOURS);

        return permissionsJson.contains(permission);
    }

    @Override
    public List<Long> getUserManagedSubjectIds(Long userId) {
        // 检查Redis缓存
        String cacheKey = REDIS_KEY_USER_SUBJECTS + userId;
        @SuppressWarnings("unchecked")
        List<Long> cachedIds = (List<Long>) redisTemplate.opsForValue().get(cacheKey);

        if (cachedIds != null) {
            return cachedIds;
        }

        // 查询数据库
        List<Long> subjectIds = baseMapper.selectManagedSubjectIds(userId);

        // 缓存到Redis
        redisTemplate.opsForValue().set(cacheKey, subjectIds, CACHE_EXPIRE_HOURS, TimeUnit.HOURS);

        return subjectIds;
    }

    @Override
    public List<Long> getUserEnrolledSubjectIds(Long userId) {
        return subjectUserMapper.selectSubjectIdsByUserId(userId);
    }

    @Override
    public boolean isCreator(Long userId, Long subjectId) {
        return baseMapper.isCreator(userId, subjectId) > 0;
    }

    @Override
    public List<SubjectManagerDTO> getSubjectManagers(Long subjectId) {
        // 查询科目管理员
        LambdaQueryWrapper<SubjectManager> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectManager::getSubjectId, subjectId);
        wrapper.orderByDesc(SubjectManager::getIsCreator);
        wrapper.orderByAsc(SubjectManager::getCreateTime);

        List<SubjectManager> managers = subjectManagerMapper.selectList(wrapper);

        // 转换为DTO并查询用户信息
        return managers.stream().map(manager -> {
            SubjectManagerDTO dto = new SubjectManagerDTO();
            dto.setId(manager.getId());
            dto.setSubjectId(manager.getSubjectId());
            dto.setUserId(manager.getUserId());
            dto.setIsCreator(manager.getIsCreator());
            dto.setManagerType(manager.getManagerType());
            dto.setPermissions(manager.getPermissions());
            dto.setValidStartDate(manager.getValidStartDate());
            dto.setValidEndDate(manager.getValidEndDate());
            dto.setCreateTime(manager.getCreateTime());
            dto.setUpdateTime(manager.getUpdateTime());

            // 查询用户信息
            SysUser user = sysUserMapper.selectById(manager.getUserId());
            if (user != null) {
                dto.setUsername(user.getUsername());
                dto.setRealName(user.getRealName());
            }

            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public IPage<SubjectStudentDTO> getSubjectStudents(Long subjectId, Long current, Long size) {
        // 查询学生列表
        LambdaQueryWrapper<SubjectUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectUser::getSubjectId, subjectId);
        wrapper.eq(SubjectUser::getUserType, 4); // 4表示学生
        wrapper.orderByDesc(SubjectUser::getJoinTime);

        IPage<SubjectUser> page = subjectUserMapper.selectPage(
            new Page<>(current, size), wrapper
        );

        // 转换为DTO
        return page.convert(su -> {
            SubjectStudentDTO dto = new SubjectStudentDTO();
            dto.setId(su.getId());
            dto.setStudentId(su.getUserId());
            dto.setSubjectId(su.getSubjectId());
            dto.setEnrollType(1); // 默认必修
            dto.setEnrollTime(su.getJoinTime());
            dto.setStatus(1); // 默认正常
            dto.setCreateTime(su.getCreateTime());

            // 查询学生信息
            SysUser user = sysUserMapper.selectById(su.getUserId());
            if (user != null) {
                dto.setUsername(user.getUsername());
                dto.setRealName(user.getRealName());
                dto.setOrgId(user.getOrgId());

                // 查询组织信息
                if (user.getOrgId() != null) {
                    SysOrganization org = sysOrganizationMapper.selectById(user.getOrgId());
                    if (org != null) {
                        dto.setOrgName(org.getOrgName());
                    }
                }
            }

            return dto;
        });
    }

    @Override
    public List<SubjectManagerDTO> getAvailableTeachers(Long orgId) {
        // 查询指定组织的教师（角色为TEACHER）
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getOrgId, orgId);
        wrapper.eq(SysUser::getRoleId, 2); // 2表示教师角色
        wrapper.eq(SysUser::getStatus, 1); // 状态启用
        wrapper.orderByAsc(SysUser::getRealName);

        List<SysUser> teachers = sysUserMapper.selectList(wrapper);

        return teachers.stream().map(teacher -> {
            SubjectManagerDTO dto = new SubjectManagerDTO();
            dto.setUserId(teacher.getUserId());
            dto.setUsername(teacher.getUsername());
            dto.setRealName(teacher.getRealName());
            dto.setOrgId(teacher.getOrgId());

            // 查询组织信息
            if (teacher.getOrgId() != null) {
                SysOrganization org = sysOrganizationMapper.selectById(teacher.getOrgId());
                if (org != null) {
                    dto.setOrgName(org.getOrgName());
                }
            }

            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public List<SubjectStudentDTO> getAvailableStudents(String keyword, Long orgId) {
        // 查询学生（角色为STUDENT）
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getRoleId, 3); // 3表示学生角色
        wrapper.eq(SysUser::getStatus, 1); // 状态启用

        // 按组织ID筛选
        if (orgId != null) {
            wrapper.eq(SysUser::getOrgId, orgId);
        }

        // 添加关键词搜索
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(SysUser::getRealName, keyword)
                .or()
                .like(SysUser::getUsername, keyword)
            );
        }

        wrapper.orderByAsc(SysUser::getRealName);
        wrapper.last("LIMIT 100"); // 限制返回数量

        List<SysUser> students = sysUserMapper.selectList(wrapper);

        return students.stream().map(student -> {
            SubjectStudentDTO dto = new SubjectStudentDTO();
            dto.setStudentId(student.getUserId());
            dto.setUserId(student.getUserId());  // 设置userId（与studentId相同）
            dto.setUsername(student.getUsername());
            dto.setRealName(student.getRealName());
            dto.setOrgId(student.getOrgId());

            // 查询组织信息
            if (student.getOrgId() != null) {
                SysOrganization org = sysOrganizationMapper.selectById(student.getOrgId());
                if (org != null) {
                    dto.setOrgName(org.getOrgName());
                }
            }

            return dto;
        }).collect(Collectors.toList());
    }

    /**
     * 转换为DTO
     */
    private SubjectDTO convertToDTO(Subject subject) {
        SubjectDTO dto = new SubjectDTO();
        dto.setSubjectId(subject.getSubjectId());
        dto.setSubjectName(subject.getSubjectName());
        dto.setSubjectCode(subject.getSubjectCode());
        dto.setOrgId(subject.getOrgId());
        dto.setDescription(subject.getDescription());
        dto.setCoverImage(subject.getCoverImage());
        dto.setCredit(subject.getCredit());
        dto.setStatus(subject.getStatus());
        dto.setSort(subject.getSort());
        dto.setCreateUserId(subject.getCreateUserId());
        dto.setCreateTime(subject.getCreateTime());
        dto.setUpdateTime(subject.getUpdateTime());

        // 查询组织名称
        if (subject.getOrgId() != null) {
            SysOrganization org = sysOrganizationMapper.selectById(subject.getOrgId());
            if (org != null) {
                dto.setOrgName(org.getOrgName());
            }
        }

        // 查询创建人姓名
        if (subject.getCreateUserId() != null) {
            SysUser user = sysUserMapper.selectById(subject.getCreateUserId());
            if (user != null) {
                dto.setCreateUserName(user.getRealName());
            }
        }

        // 查询学生人数
        LambdaQueryWrapper<SubjectUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SubjectUser::getSubjectId, subject.getSubjectId());
        wrapper.eq(SubjectUser::getUserType, 4); // 4表示学生
        long studentCount = subjectUserMapper.selectCount(wrapper);
        dto.setStudentCount((int) studentCount);

        return dto;
    }

    /**
     * 清除用户缓存
     */
    private void clearUserCache(Long userId) {
        redisTemplate.delete(REDIS_KEY_USER_SUBJECTS + userId);
        // 清除权限缓存需要遍历所有科目，暂时不实现
    }
}

