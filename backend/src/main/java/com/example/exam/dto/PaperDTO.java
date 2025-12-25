package com.example.exam.dto;

import com.example.exam.common.enums.AuditStatus;
import com.example.exam.common.enums.PaperType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 试卷DTO - 用于查询列表/详情展示
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-14
 */
@Data
@Schema(description = "试卷数据传输对象")
public class PaperDTO {

    @Schema(description = "试卷ID")
    private Long paperId;

    @Schema(description = "试卷名称")
    private String paperName;

    @Schema(description = "试卷描述")
    private String description;

    @Schema(description = "组卷方式：1-手动组卷，2-自动组卷，3-随机组卷")
    private PaperType paperType;

    @Schema(description = "试卷总分")
    private BigDecimal totalScore;

    @Schema(description = "及格分")
    private BigDecimal passScore;

    @Schema(description = "组织ID")
    private Long orgId;

    @Schema(description = "创建人ID")
    private Long createUserId;

    @Schema(description = "创建人姓名")
    private String createUserName;

    @Schema(description = "审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝")
    private AuditStatus auditStatus;

    @Schema(description = "审核备注")
    private String auditRemark;

    @Schema(description = "审核人ID")
    private Long auditorId;

    @Schema(description = "审核人姓名")
    private String auditorName;

    @Schema(description = "审核时间")
    private LocalDateTime auditTime;

    @Schema(description = "发布状态：0-未发布，1-已发布，2-已过期")
    private Integer publishStatus;

    @Schema(description = "发布时间")
    private LocalDateTime publishTime;

    @Schema(description = "允许查看错题解析：0-否，1-是")
    private Integer allowViewAnalysis;

    @Schema(description = "允许补考：0-否，1-是")
    private Integer allowReexam;

    @Schema(description = "补考次数限制")
    private Integer reexamLimit;

    @Schema(description = "有效天数")
    private Integer validDays;

    @Schema(description = "版本号")
    private Integer version;

    @Schema(description = "父试卷ID")
    private Long parentPaperId;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    // ==================== 扩展字段 ====================

    @Schema(description = "题目数量（统计）")
    private Integer questionCount;

    @Schema(description = "题库名称列表（逗号分隔）")
    private String bankNames;

    @Schema(description = "题库ID列表（逗号分隔）")
    private String bankIds;

    @Schema(description = "试卷题目列表（含选项和答案）")
    private java.util.List<QuestionDTO> questions;
}

