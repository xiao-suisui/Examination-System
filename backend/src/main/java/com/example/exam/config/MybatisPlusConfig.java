package com.example.exam.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis Plus配置类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Configuration
@MapperScan("com.example.exam.mapper")
public class MybatisPlusConfig {

    /**
     * MyBatis Plus拦截器配置
     * 添加分页插件
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        
        // 分页插件
        PaginationInnerInterceptor paginationInnerInterceptor = new PaginationInnerInterceptor(DbType.MYSQL);
        paginationInnerInterceptor.setMaxLimit(1000L); // 单页最大数量限制
        paginationInnerInterceptor.setOverflow(false); // 溢出总页数后是否进行处理
        
        interceptor.addInnerInterceptor(paginationInnerInterceptor);
        
        return interceptor;
    }
}

