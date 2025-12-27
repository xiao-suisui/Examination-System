package com.example.exam.converter;

import com.example.exam.dto.ExamDTO;
import com.example.exam.entity.exam.Exam;
import org.mapstruct.*;

import java.util.List;

/**
 * 考试实体和DTO转换器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.ERROR,
    uses = EnumConverter.class
)
public interface ExamConverter {

    /**
     * Exam 转 ExamDTO
     * 同名属性自动映射，枚举类型直接映射
     */
    @Mapping(target = "paperName", ignore = true)         // 需要关联查询
    @Mapping(target = "subjectName", ignore = true)       // 科目名称需要关联查询
    @Mapping(target = "examStatusName", ignore = true)    // 状态名称由前端根据examStatus枚举获取
    @Mapping(target = "createUserName", ignore = true)    // 创建人姓名需要关联查询
    @Mapping(target = "totalParticipants", ignore = true) // 统计字段
    @Mapping(target = "submittedCount", ignore = true)
    @Mapping(target = "absentCount", ignore = true)
    @Mapping(target = "averageScore", ignore = true)
    @Mapping(target = "maxScore", ignore = true)
    @Mapping(target = "minScore", ignore = true)
    @Mapping(target = "passCount", ignore = true)
    @Mapping(target = "passRate", ignore = true)
    @Mapping(target = "hasJoined", ignore = true)         // 用户是否已参加，需要关联查询
    @Mapping(target = "sessionId", ignore = true)         // 会话ID，需要关联查询
    @Mapping(target = "sessionStatus", ignore = true)     // 会话状态，需要关联查询
    @Mapping(target = "studentScore", ignore = true)      // 学生分数，需要关联查询
    ExamDTO toDTO(Exam exam);

    /**
     * ExamDTO 转 Exam
     * 仅映射基础字段，枚举类型直接映射
     */
    @Mapping(target = "deleted", ignore = true)           // 逻辑删除字段由系统管理
    @Mapping(target = "createTime", ignore = true)        // 由 MyBatis-Plus 自动填充
    @Mapping(target = "updateTime", ignore = true)        // 由 MyBatis-Plus 自动填充
    @Mapping(target = "subjectId", ignore = true)         // 科目ID由Controller设置
    Exam toEntity(ExamDTO dto);

    /**
     * 批量转换 Exam List 到 ExamDTO List
     */
    List<ExamDTO> toDTOList(List<Exam> examList);

    /**
     * 批量转换 ExamDTO List 到 Exam List
     */
    List<Exam> toEntityList(List<ExamDTO> dtoList);

    /**
     * 更新实体（忽略null值）
     * 用于部分更新场景，使用EnumConverter自动转换examStatus
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "examId", ignore = true)            // 主键不允许更新
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "createUserId", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    @Mapping(target = "subjectId", ignore = true)         // 科目ID不允许更新
    void updateExamFromDTO(ExamDTO dto, @MappingTarget Exam exam);
}

