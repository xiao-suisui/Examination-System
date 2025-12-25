package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 科目学生DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目学生DTO")
public class SubjectStudentDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "关联ID")
    private Long id;

    @Schema(description = "学生ID")
    private Long studentId;

    @Schema(description = "学号")
    private String username;

    @Schema(description = "真实姓名")
    private String realName;

    @Schema(description = "组织ID")
    private Long orgId;

    @Schema(description = "组织名称（班级）")
    private String orgName;

    @Schema(description = "科目ID")
    private Long subjectId;

    @Schema(description = "选课类型：1-必修，2-选修")
    private Integer enrollType;

    @Schema(description = "选课时间")
    private LocalDateTime enrollTime;

    @Schema(description = "状态：0-已退课，1-正常")
    private Integer status;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}

