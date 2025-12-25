package com.example.exam.converter;

import com.example.exam.common.enums.*;
import org.mapstruct.Mapper;

/**
 * 枚举转换器 - 提供枚举与整数之间的转换
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-20
 */
@Mapper(componentModel = "spring")
public interface EnumConverter {

    // ==================== ExamStatus 转换 ====================

    default Integer examStatusToInteger(ExamStatus status) {
        return status != null ? status.getCode() : null;
    }

    default ExamStatus integerToExamStatus(Integer code) {
        return ExamStatus.of(code);
    }

    // ==================== QuestionType 转换 ====================

    default Integer questionTypeToInteger(QuestionType type) {
        return type != null ? type.getCode() : null;
    }

    default QuestionType integerToQuestionType(Integer code) {
        return QuestionType.of(code);
    }

    // ==================== DifficultyType 转换 ====================

    default Integer difficultyTypeToInteger(DifficultyType type) {
        return type != null ? type.getCode() : null;
    }

    default DifficultyType integerToDifficultyType(Integer code) {
        return DifficultyType.of(code);
    }

    // ==================== PaperType 转换 ====================

    default Integer paperTypeToInteger(PaperType type) {
        return type != null ? type.getCode() : null;
    }

    default PaperType integerToPaperType(Integer code) {
        return PaperType.of(code);
    }

    // ==================== AuditStatus 转换 ====================

    default Integer auditStatusToInteger(AuditStatus status) {
        return status != null ? status.getCode() : null;
    }

    default AuditStatus integerToAuditStatus(Integer code) {
        return AuditStatus.of(code);
    }

    // ==================== UserStatus 转换 ====================

    default Integer userStatusToInteger(UserStatus status) {
        return status != null ? status.getCode() : null;
    }

    default UserStatus integerToUserStatus(Integer code) {
        return UserStatus.of(code);
    }

    // ==================== Gender 转换 ====================

    default Integer genderToInteger(Gender gender) {
        return gender != null ? gender.getCode() : null;
    }

    default Gender integerToGender(Integer code) {
        return Gender.of(code);
    }

    // ==================== BankType 转换 ====================

    default Integer bankTypeToInteger(BankType type) {
        return type != null ? type.getCode() : null;
    }

    default BankType integerToBankType(Integer code) {
        return BankType.of(code);
    }

    // ==================== OrgLevel 转换 ====================

    default Integer orgLevelToInteger(OrgLevel level) {
        return level != null ? level.getCode() : null;
    }

    default OrgLevel integerToOrgLevel(Integer code) {
        return OrgLevel.of(code);
    }

    // ==================== OrgType 转换 ====================

    default Integer orgTypeToInteger(OrgType type) {
        return type != null ? type.getCode() : null;
    }

    default OrgType integerToOrgType(Integer code) {
        return OrgType.of(code);
    }
}

