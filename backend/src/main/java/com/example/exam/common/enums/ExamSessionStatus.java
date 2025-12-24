package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 考试会话状态枚举
 *
 * 模块：公共模块（exam-common）
 * 职责：定义考试会话的各个状态
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Getter
@AllArgsConstructor
public enum ExamSessionStatus {

    /**
     * 进行中：考试正在进行
     */
    IN_PROGRESS("IN_PROGRESS", "进行中"),

    /**
     * 已提交：考生已提交试卷
     */
    SUBMITTED("SUBMITTED", "已提交"),

    /**
     * 已批改：试卷已批改完成
     */
    GRADED("GRADED", "已批改"),

    /**
     * 已终止：考试被强制终止
     */
    TERMINATED("TERMINATED", "已终止"),

    /**
     * 超时提交：考试时间到自动提交
     */
    TIMEOUT_SUBMITTED("TIMEOUT_SUBMITTED", "超时提交"),

    /**
     * 异常终止：因违规等原因异常终止
     */
    ABNORMAL_TERMINATED("ABNORMAL_TERMINATED", "异常终止");

    /**
     * 状态编码（数据库存储值）
     */
    @EnumValue
    @JsonValue
    private final String code;

    /**
     * 状态名称（中文显示）
     */
    private final String name;

    /**
     * 根据编码获取状态枚举
     *
     * @param code 状态编码
     * @return 状态枚举，未找到则返回null
     */
    public static ExamSessionStatus fromCode(String code) {
        for (ExamSessionStatus status : values()) {
            if (status.getCode().equals(code)) {
                return status;
            }
        }
        return null;
    }

    /**
     * 判断考试是否已结束
     *
     * @return true-已结束，false-未结束
     */
    public boolean isFinished() {
        return this != IN_PROGRESS;
    }

    /**
     * 判断是否可以继续答题
     *
     * @return true-可以继续答题，false-不可以继续答题
     */
    public boolean canContinue() {
        return this == IN_PROGRESS;
    }

    /**
     * 判断是否需要批改
     *
     * @return true-需要批改，false-不需要批改
     */
    public boolean needsGrading() {
        return this == SUBMITTED || this == TIMEOUT_SUBMITTED;
    }
}

