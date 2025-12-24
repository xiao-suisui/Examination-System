package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 审核状态枚举
 *
 * 模块：公共模块（exam-common）
 * 职责：定义题目、试卷等资源的审核状态
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Getter
@AllArgsConstructor
public enum AuditStatus {

    /**
     * 草稿：创建后未提交审核
     */
    DRAFT(0, "草稿"),

    /**
     * 待审核：已提交，等待审核
     */
    PENDING(1, "待审核"),

    /**
     * 已通过：审核通过，可以使用
     */
    APPROVED(2, "已通过"),

    /**
     * 已拒绝：审核不通过，需要修改
     */
    REJECTED(3, "已拒绝");

    /**
     * 状态编码（数据库存储值）
     */
    @EnumValue
    @JsonValue
    private final int code;

    /**
     * 状态名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取审核状态枚举
     *
     * @param code 状态编码
     * @return 审核状态枚举，未找到则返回null
     */
    public static AuditStatus fromCode(int code) {
        for (AuditStatus status : values()) {
            if (status.getCode() == code) {
                return status;
            }
        }
        return null;
    }

    /**
     * 判断是否可以提交审核
     *
     * @return true-可以提交审核，false-不可以提交审核
     */
    public boolean canSubmitForAudit() {
        return this == DRAFT || this == REJECTED;
    }

    /**
     * 判断是否可以修改
     *
     * @return true-可以修改，false-不可以修改
     */
    public boolean canModify() {
        return this == DRAFT || this == REJECTED;
    }

    /**
     * 判断是否可以删除
     *
     * @return true-可以删除，false-不可以删除
     */
    public boolean canDelete() {
        return this == DRAFT || this == REJECTED;
    }
}

