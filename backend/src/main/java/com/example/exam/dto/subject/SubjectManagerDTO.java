package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 科目管理员DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目管理员DTO")
public class SubjectManagerDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "关联ID")
    private Long id;

    @Schema(description = "科目ID")
    private Long subjectId;

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "真实姓名")
    private String realName;

    @Schema(description = "是否为创建者：0-否，1-是")
    private Integer isCreator;

    @Schema(description = "管理员类型：1-主讲教师，2-协作教师，3-助教")
    private Integer managerType;

    @Schema(description = "权限列表（JSON数组）")
    private String permissions;

    @Schema(description = "授权开始日期")
    private LocalDate validStartDate;

    @Schema(description = "授权结束日期")
    private LocalDate validEndDate;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

