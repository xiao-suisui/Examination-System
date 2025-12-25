package com.example.exam.converter;

import com.example.exam.config.MapStructConfig;
import com.example.exam.dto.QuestionDTO;
import com.example.exam.dto.QuestionSaveDTO;
import com.example.exam.entity.question.Question;
import org.mapstruct.*;

import java.util.List;

/**
 * 题目实体和DTO转换器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@Mapper(config = MapStructConfig.class, uses = EnumConverter.class)
public interface QuestionConverter {

    /**
     * Question 转 QuestionDTO
     * 同名属性自动映射，使用EnumConverter自动转换枚举
     */
    @Mapping(target = "bankName", ignore = true)          // 题库名称需要关联查询
    @Mapping(target = "questionTypeName", ignore = true)  // 题型名称需要手动转换
    @Mapping(target = "difficultyName", ignore = true)    // 难度名称需要手动转换
    @Mapping(target = "knowledgeNames", ignore = true)    // 知识点名称需要关联查询
    @Mapping(target = "auditStatusName", ignore = true)   // 审核状态名称需要手动转换
    @Mapping(target = "auditorName", ignore = true)       // 审核人姓名需要关联查询
    @Mapping(target = "createUserName", ignore = true)    // 创建人姓名需要关联查询
    @Mapping(target = "options", ignore = true)           // 选项列表需要单独查询
    @Mapping(target = "correctOptionIds", ignore = true)  // 正确答案ID需要从选项表计算
    @Mapping(target = "correctAnswer", ignore = true)     // 正确答案内容需要从选项表计算
    QuestionDTO toDTO(Question question);

    /**
     * QuestionDTO 转 Question
     * 仅映射基础字段，忽略关联字段和自动填充字段
     */
    @Mapping(target = "deleted", ignore = true)           // 逻辑删除字段由系统管理
    @Mapping(target = "createTime", ignore = true)        // 由 MyBatis-Plus 自动填充
    @Mapping(target = "updateTime", ignore = true)        // 由 MyBatis-Plus 自动填充
    @Mapping(target = "subjectId", ignore = true)         // 科目ID通常由Controller设置
    Question toEntity(QuestionDTO dto);

    /**
     * QuestionSaveDTO 转 Question（用于创建和更新）
     * 处理前端发送的保存DTO，自动转换枚举类型
     */
    @Mapping(target = "answerAnalysis", source = "analysis")  // 前端使用 analysis，实体类使用 answerAnalysis
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    @Mapping(target = "createUserId", ignore = true)          // 由Controller手动设置
    @Mapping(target = "orgId", ignore = true)                 // 由Controller手动设置
    @Mapping(target = "subjectId", ignore = true)             // 由Controller手动设置
    @Mapping(target = "auditStatus", ignore = true)           // 由Controller手动设置
    @Mapping(target = "status", ignore = true)                // 由Controller手动设置
    @Mapping(target = "auditRemark", ignore = true)
    @Mapping(target = "auditorId", ignore = true)
    @Mapping(target = "auditTime", ignore = true)
    @Mapping(target = "useCount", ignore = true)
    @Mapping(target = "correctRate", ignore = true)
    Question fromSaveDTO(QuestionSaveDTO dto);

    /**
     * 批量转换
     */
    List<QuestionDTO> toDTOList(List<Question> questions);

    List<Question> toEntityList(List<QuestionDTO> dtos);

    /**
     * 更新实体（忽略null值）
     * 用于部分更新场景
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "questionId", ignore = true)        // 主键不允许更新
    @Mapping(target = "bankId", ignore = true)            // 题库ID通常不允许更改
    @Mapping(target = "subjectId", ignore = true)         // 科目ID通常不允许更改
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "createUserId", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    void updateQuestionFromDTO(QuestionDTO dto, @MappingTarget Question question);
}

