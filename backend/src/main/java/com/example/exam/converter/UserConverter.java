package com.example.exam.converter;

import com.example.exam.config.MapStructConfig;
import com.example.exam.dto.UserDTO;
import com.example.exam.entity.system.SysUser;
import org.mapstruct.*;

import java.util.List;

/**
 * 用户实体和DTO转换器
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@Mapper(config = MapStructConfig.class, uses = EnumConverter.class)
public interface UserConverter {

    /**
     * SysUser 转 UserDTO
     * 同名属性自动映射，使用EnumConverter自动转换枚举
     */
    @Mapping(target = "orgName", ignore = true)          // 组织名称需要关联查询
    @Mapping(target = "roleName", ignore = true)         // 角色名称需要关联查询
    UserDTO toDTO(SysUser user);

    /**
     * UserDTO 转 SysUser
     * 忽略密码、自动填充字段和逻辑删除字段
     */
    @Mapping(target = "password", ignore = true)         // 密码单独处理
    @Mapping(target = "deleted", ignore = true)          // 逻辑删除字段由系统管理
    @Mapping(target = "createTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    @Mapping(target = "updateTime", ignore = true)       // 由 MyBatis-Plus 自动填充
    SysUser toEntity(UserDTO dto);

    /**
     * 批量转换
     */
    List<UserDTO> toDTOList(List<SysUser> users);

    List<SysUser> toEntityList(List<UserDTO> dtos);

    /**
     * 更新实体（忽略null值）
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "userId", ignore = true)           // 主键不允许更新
    @Mapping(target = "password", ignore = true)         // 密码单独处理
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createTime", ignore = true)
    @Mapping(target = "updateTime", ignore = true)
    void updateUserFromDTO(UserDTO dto, @MappingTarget SysUser user);
}

