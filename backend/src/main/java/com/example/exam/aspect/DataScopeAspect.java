package com.example.exam.aspect;

import com.example.exam.annotation.DataScope;
import com.example.exam.common.enums.DataScopeType;
import com.example.exam.entity.subject.SubjectUser;
import com.example.exam.mapper.subject.SubjectUserMapper;
import com.example.exam.util.SecurityUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 数据权限切面
 * <p>根据用户角色和科目权限自动过滤数据</p>
 *
 * <p>过滤规则：</p>
 * <ul>
 *   <li>超级管理员：查看所有数据</li>
 *   <li>教师：只能查看管理的科目数据</li>
 *   <li>学生：只能查看加入的科目数据</li>
 *   <li>普通用户：只能查看自己创建的数据</li>
 * </ul>
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-20
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class DataScopeAspect {

    private final SubjectUserMapper subjectUserMapper;

    /**
     * 线程本地变量，用于存储数据权限SQL片段
     */
    private static final ThreadLocal<String> DATA_SCOPE_SQL = new ThreadLocal<>();

    @Around("@annotation(com.example.exam.annotation.DataScope)")
    public Object doAround(ProceedingJoinPoint point) throws Throwable {
        try {
            // 获取方法签名
            MethodSignature signature = (MethodSignature) point.getSignature();
            Method method = signature.getMethod();

            // 获取注解
            DataScope dataScope = method.getAnnotation(DataScope.class);
            if (dataScope == null) {
                return point.proceed();
            }

            // 获取当前用户ID
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                log.warn("用户未登录，跳过数据权限过滤");
                return point.proceed();
            }

            // 超级管理员跳过数据权限过滤
            if (SecurityUtils.isSuperAdmin()) {
                log.debug("超级管理员访问，跳过数据权限过滤");
                return point.proceed();
            }

            // 根据数据权限类型添加过滤条件
            String sqlFilter = buildDataScopeFilter(userId, dataScope);
            if (sqlFilter != null && !sqlFilter.isEmpty()) {
                DATA_SCOPE_SQL.set(sqlFilter);
                log.debug("数据权限SQL: {}", sqlFilter);
            }

            // 执行方法
            return point.proceed();

        } finally {
            // 清除线程本地变量
            DATA_SCOPE_SQL.remove();
        }
    }

    /**
     * 构建数据权限过滤SQL
     */
    private String buildDataScopeFilter(Long userId, DataScope dataScope) {
        DataScopeType scopeType = dataScope.value();
        String tableAlias = dataScope.tableAlias();
        String prefix = tableAlias.isEmpty() ? "" : tableAlias + ".";

        switch (scopeType) {
            case ALL:
                // 全部数据权限，不过滤
                return null;

            case SUBJECT:
                // 科目数据权限
                return buildSubjectFilter(userId, prefix, dataScope.subjectIdField());

            case ORG:
                // 组织数据权限
                return buildOrgFilter(userId, prefix, dataScope.orgIdField());

            case SELF:
                // 仅本人数据权限
                return buildSelfFilter(userId, prefix, dataScope.createUserIdField());

            default:
                return null;
        }
    }

    /**
     * 构建科目过滤条件
     * <p>用户只能查看有权限的科目数据</p>
     */
    private String buildSubjectFilter(Long userId, String prefix, String subjectIdField) {
        // 查询用户有权限的科目ID列表
        List<SubjectUser> subjectUsers = subjectUserMapper.selectList(
            new LambdaQueryWrapper<SubjectUser>()
                .eq(SubjectUser::getUserId, userId)
                .select(SubjectUser::getSubjectId)
        );

        if (subjectUsers == null || subjectUsers.isEmpty()) {
            // 用户没有任何科目权限，返回永假条件
            return prefix + subjectIdField + " = -1";
        }

        // 构建 IN 条件
        String subjectIds = subjectUsers.stream()
            .map(su -> String.valueOf(su.getSubjectId()))
            .collect(Collectors.joining(","));

        return prefix + subjectIdField + " IN (" + subjectIds + ")";
    }

    /**
     * 构建组织过滤条件
     * <p>用户只能查看本组织及子组织数据</p>
     */
    private String buildOrgFilter(Long userId, String prefix, String orgIdField) {
        // 获取用户所在组织ID
        Long orgId = SecurityUtils.getCurrentUserOrgId();
        if (orgId == null) {
            return prefix + orgIdField + " = -1";
        }

        // TODO: 如果需要包含子组织，需要查询组织树
        // 目前只过滤当前组织
        return prefix + orgIdField + " = " + orgId;
    }

    /**
     * 构建仅本人数据过滤条件
     */
    private String buildSelfFilter(Long userId, String prefix, String createUserIdField) {
        return prefix + createUserIdField + " = " + userId;
    }

    /**
     * 获取当前线程的数据权限SQL
     * <p>供MyBatis拦截器使用</p>
     */
    public static String getDataScopeSQL() {
        return DATA_SCOPE_SQL.get();
    }
}

