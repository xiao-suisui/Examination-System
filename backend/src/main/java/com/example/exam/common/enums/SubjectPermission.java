package com.example.exam.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 科目权限枚举
 *
 * @author system
 * @since 2025-12-20
 */
@Getter
public enum SubjectPermission {

    MANAGE_STUDENT("MANAGE_STUDENT", "管理学生"),
    MANAGE_EXAM("MANAGE_EXAM", "管理考试"),
    MANAGE_PAPER("MANAGE_PAPER", "管理试卷"),
    MANAGE_QUESTION_BANK("MANAGE_QUESTION_BANK", "管理题库"),
    GRADE_EXAM("GRADE_EXAM", "批改考试"),
    VIEW_ANALYSIS("VIEW_ANALYSIS", "查看数据分析");

    @EnumValue
    @JsonValue
    private final String code;
    private final String desc;

    SubjectPermission(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static SubjectPermission fromCode(String code) {
        for (SubjectPermission permission : values()) {
            if (permission.code.equals(code)) {
                return permission;
            }
        }
        return null;
    }
}

