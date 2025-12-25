package com.example.exam.dto.subject;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 科目DTO
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Schema(description = "科目DTO")
public class SubjectDTO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "科目ID")
    private Long subjectId;

    @Schema(description = "科目名称")
    private String subjectName;

    @Schema(description = "科目编码")
    private String subjectCode;

    @Schema(description = "归属学院ID")
    private Long orgId;

    @Schema(description = "归属学院名称")
    private String orgName;

    @Schema(description = "科目描述")
    private String description;

    @Schema(description = "科目封面")
    private String coverImage;

    @Schema(description = "学分")
    private BigDecimal credit;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "创建人ID")
    private Long createUserId;

    @Schema(description = "创建人姓名")
    private String createUserName;

    @Schema(description = "学生人数")
    private Integer studentCount;

    @Schema(description = "题库数量")
    private Integer questionBankCount;

    @Schema(description = "试卷数量")
    private Integer paperCount;

    @Schema(description = "考试数量")
    private Integer examCount;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

