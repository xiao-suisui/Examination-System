package com.example.exam.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.example.exam.util.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * MyBatis Plus 元数据自动填充配置
 *
 * <p>职责：自动填充createTime、updateTime、createUserId、updateUserId、orgId等字段</p>
 *
 * <p>支持的自动填充字段：</p>
 * <ul>
 *   <li>createTime - 创建时间（INSERT）</li>
 *   <li>updateTime - 更新时间（INSERT、UPDATE）</li>
 *   <li>operateTime - 操作时间，用于日志表（INSERT）</li>
 *   <li>createUserId - 创建人ID（INSERT）</li>
 *   <li>updateUserId - 更新人ID（INSERT、UPDATE）</li>
 *   <li>userId - 用户ID，用于关联表（INSERT）</li>
 *   <li>orgId - 组织ID，用于数据隔离（INSERT）</li>
 * </ul>
 *
 * <p>使用方式：在实体类字段上添加注解</p>
 * <pre>
 * &#64;TableField(fill = FieldFill.INSERT)
 * private LocalDateTime createTime;
 *
 * &#64;TableField(fill = FieldFill.INSERT_UPDATE)
 * private LocalDateTime updateTime;
 *
 * &#64;TableField(fill = FieldFill.INSERT)
 * private Long createUserId;
 *
 * &#64;TableField(fill = FieldFill.INSERT_UPDATE)
 * private Long updateUserId;
 *
 * &#64;TableField(fill = FieldFill.INSERT)
 * private Long orgId;
 * </pre>
 *
 * @author Exam System
 * @version 2.1
 * @since 2025-11-06
 */
@Slf4j
@Component
public class MetaObjectHandlerConfig implements MetaObjectHandler {

    /**
     * 插入时自动填充
     */
    @Override
    public void insertFill(MetaObject metaObject) {
        log.debug("开始插入填充...");

        // 1. 自动填充创建时间
        this.strictInsertFill(metaObject, "createTime", LocalDateTime.class, LocalDateTime.now());

        // 2. 自动填充更新时间
        this.strictInsertFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());

        // 3. 自动填充操作时间（用于日志表）
        this.strictInsertFill(metaObject, "operateTime", LocalDateTime.class, LocalDateTime.now());

        // 4. 自动填充创建人ID
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId != null) {
                this.strictInsertFill(metaObject, "createUserId", Long.class, userId);
                this.strictInsertFill(metaObject, "userId", Long.class, userId); // 用于关联表
                log.debug("自动填充创建人ID: {}", userId);
            }
        } catch (Exception e) {
            log.warn("获取当前用户ID失败，跳过createUserId自动填充: {}", e.getMessage());
        }

        // 5. 自动填充更新人ID（插入时，更新人=创建人）
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId != null) {
                this.strictInsertFill(metaObject, "updateUserId", Long.class, userId);
            }
        } catch (Exception e) {
            log.warn("获取当前用户ID失败，跳过updateUserId自动填充: {}", e.getMessage());
        }

        // 6. 自动填充组织ID（数据隔离）
        try {
            Long orgId = SecurityUtils.getCurrentUserOrgId();
            if (orgId != null) {
                this.strictInsertFill(metaObject, "orgId", Long.class, orgId);
                log.debug("自动填充组织ID: {}", orgId);
            }
        } catch (Exception e) {
            log.warn("获取当前用户组织ID失败，跳过orgId自动填充: {}", e.getMessage());
        }
    }

    /**
     * 更新时自动填充
     */
    @Override
    public void updateFill(MetaObject metaObject) {
        log.debug("开始更新填充...");

        // 1. 自动填充更新时间
        this.strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());

        // 2. 自动填充更新人ID
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId != null) {
                this.strictUpdateFill(metaObject, "updateUserId", Long.class, userId);
                log.debug("自动填充更新人ID: {}", userId);
            }
        } catch (Exception e) {
            log.warn("获取当前用户ID失败，跳过updateUserId自动填充: {}", e.getMessage());
        }
    }
}

