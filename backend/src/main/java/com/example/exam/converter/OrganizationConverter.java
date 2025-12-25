package com.example.exam.converter;

import com.example.exam.config.MapStructConfig;
import com.example.exam.dto.SysOrganizationDTO;
import com.example.exam.entity.system.SysOrganization;
import org.mapstruct.*;

import java.util.List;

/**
 * 组织实体和DTO转换器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@Mapper(config = MapStructConfig.class, uses = EnumConverter.class)
public interface OrganizationConverter {

    /**
     * SysOrganization 转 SysOrganizationDTO
     * 同名属性自动映射，枚举类型直接映射
     */
    @Mapping(target = "children", ignore = true)         // 子组织需要递归查询
    @Mapping(target = "hasChildren", ignore = true)      // 是否有子组织需要查询判断
    SysOrganizationDTO toDTO(SysOrganization org);

    /**
     * SysOrganizationDTO 转 SysOrganization
     * 忽略自动填充字段和逻辑删除字段
     */
    @Mapping(target = "deleted", ignore = true)          // 逻辑删除字段由系统管理
    @Mapping(target = "createTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    @Mapping(target = "updateTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    SysOrganization toEntity(SysOrganizationDTO dto);

    /**
     * 批量转换
     */
    List<SysOrganizationDTO> toDTOList(List<SysOrganization> orgs);

    List<SysOrganization> toEntityList(List<SysOrganizationDTO> dtos);

    /**
     * 更新实体（忽略null值）
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "orgId", ignore = true)            // 主键不允许更新
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    void updateOrgFromDTO(SysOrganizationDTO dto, @MappingTarget SysOrganization org);
}

