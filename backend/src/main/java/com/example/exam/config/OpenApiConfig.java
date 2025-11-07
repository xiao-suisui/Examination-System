package com.example.exam.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI（Swagger）配置类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Configuration
public class OpenApiConfig {

    /**
     * 配置OpenAPI基本信息
     */
    @Bean
    public OpenAPI examSystemOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("考试系统 API 文档")
                        .description("在线考试系统 RESTful API 接口文档")
                        .version("v2.0.0")
                        .contact(new Contact()
                                .name("Exam System Team")
                                .email("support@exam-system.com")
                                .url("https://github.com/your-repo/exam-system"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")));
    }

    /**
     * 系统管理模块API
     */
    @Bean
    public GroupedOpenApi systemApi() {
        return GroupedOpenApi.builder()
                .group("1. 系统管理")
                .pathsToMatch("/api/system/**", "/api/user/**", "/api/role/**", "/api/permission/**")
                .build();
    }

    /**
     * 题库管理模块API
     */
    @Bean
    public GroupedOpenApi questionApi() {
        return GroupedOpenApi.builder()
                .group("2. 题库管理")
                .pathsToMatch("/api/question/**", "/api/question-bank/**", "/api/knowledge/**")
                .build();
    }

    /**
     * 试卷管理模块API
     */
    @Bean
    public GroupedOpenApi paperApi() {
        return GroupedOpenApi.builder()
                .group("3. 试卷管理")
                .pathsToMatch("/api/paper/**", "/api/paper-rule/**")
                .build();
    }

    /**
     * 考试管理模块API
     */
    @Bean
    public GroupedOpenApi examApi() {
        return GroupedOpenApi.builder()
                .group("4. 考试管理")
                .pathsToMatch("/api/exam/**", "/api/exam-session/**")
                .build();
    }

    /**
     * 成绩管理模块API
     */
    @Bean
    public GroupedOpenApi gradeApi() {
        return GroupedOpenApi.builder()
                .group("5. 成绩管理")
                .pathsToMatch("/api/grade/**", "/api/score/**", "/api/answer/**")
                .build();
    }

    /**
     * 认证授权模块API
     */
    @Bean
    public GroupedOpenApi authApi() {
        return GroupedOpenApi.builder()
                .group("6. 认证授权")
                .pathsToMatch("/api/auth/**", "/api/login/**", "/api/logout/**")
                .build();
    }
}

