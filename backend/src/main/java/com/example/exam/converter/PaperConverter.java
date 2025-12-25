package com.example.exam.converter;

import com.example.exam.config.MapStructConfig;
import com.example.exam.dto.PaperDTO;
import com.example.exam.entity.paper.Paper;
import org.mapstruct.*;

import java.util.List;

/**
 * 试卷实体和DTO转换器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@Mapper(config = MapStructConfig.class, uses = EnumConverter.class)
public interface PaperConverter {

    /**
     * Paper 转 PaperDTO
     * 同名属性自动映射，使用EnumConverter自动转换枚举
     */
    @Mapping(target = "createUserName", ignore = true)   // 创建人姓名需要关联查询
    @Mapping(target = "auditorName", ignore = true)      // 审核人姓名需要关联查询
    @Mapping(target = "questionCount", ignore = true)    // 题目数量统计字段
    @Mapping(target = "bankNames", ignore = true)        // 题库名称列表需要关联查询
    @Mapping(target = "bankIds", ignore = true)          // 题库ID列表需要关联查询
    @Mapping(target = "questions", ignore = true)        // 试卷题目列表需要关联查询
    PaperDTO toDTO(Paper paper);

    /**
     * PaperDTO 转 Paper
     * 仅映射基础字段，忽略关联字段和自动填充字段
     */
    @Mapping(target = "deleted", ignore = true)          // 逻辑删除字段由系统管理
    @Mapping(target = "createTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    @Mapping(target = "updateTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    Paper toEntity(PaperDTO dto);

    /**
     * 批量转换
     */
    List<PaperDTO> toDTOList(List<Paper> papers);

    List<Paper> toEntityList(List<PaperDTO> dtos);

    /**
     * 更新实体（忽略null值）
     * 用于部分更新场景
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "paperId", ignore = true)          // 主键不允许更新
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "createUserId", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    void updatePaperFromDTO(PaperDTO dto, @MappingTarget Paper paper);
}

