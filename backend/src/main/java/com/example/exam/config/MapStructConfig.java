package com.example.exam.config;

import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

/**
 * MapStruct 全局配置
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-19
 */
@MapperConfig(
    // Spring Bean 模式，支持依赖注入
    componentModel = "spring",
    // 未映射属性报错，强制显式处理每个属性
    unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface MapStructConfig {
    // 统一配置，所有 Converter 继承此接口
}

