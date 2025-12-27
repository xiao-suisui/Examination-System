package com.example.exam.dto;

import com.example.exam.common.enums.ExamSessionStatus;
import com.example.exam.common.enums.ExamStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 考试DTO - 用于查询列表/详情展示
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-14
 */
@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "考试数据传输对象")
public class ExamDTO {

    @Schema(description = "考试ID")
    private Long examId;

    @Schema(description = "考试名称")
    private String examName;

    @Schema(description = "考试描述")
    private String description;

    @Schema(description = "封面图片")
    private String coverImage;

    @Schema(description = "试卷ID")
    private Long paperId;

    @Schema(description = "试卷名称")
    private String paperName;

    @Schema(description = "所属科目ID")
    private Long subjectId;

    @Schema(description = "所属科目名称")
    private String subjectName;

    @Schema(description = "开始时间")
    private LocalDateTime startTime;

    @Schema(description = "结束时间")
    private LocalDateTime endTime;

    @Schema(description = "考试时长（分钟）")
    private Integer duration;

    @Schema(description = "考试范围类型：1-指定考生，2-指定班级，3-指定组织")
    private Integer examRangeType;

    @Schema(description = "考试范围ID列表")
    private String examRangeIds;

    @Schema(description = "考试状态")
    private ExamStatus examStatus;

    @Schema(description = "考试状态名称")
    private String examStatusName;

    @Schema(description = "切屏限制次数")
    private Integer cutScreenLimit;

    @Schema(description = "切屏时长是否计入：0-否，1-是")
    private Integer cutScreenTimer;

    @Schema(description = "禁止复制：0-否，1-是")
    private Integer forbidCopy;

    @Schema(description = "单设备登录：0-否，1-是")
    private Integer singleDevice;

    @Schema(description = "乱序题目：0-否，1-是")
    private Integer shuffleQuestions;

    @Schema(description = "乱序选项：0-否，1-是")
    private Integer shuffleOptions;

    @Schema(description = "主观题防抄袭：0-否，1-是")
    private Integer antiPlagiarism;

    @Schema(description = "相似度阈值")
    private Integer plagiarismThreshold;

    @Schema(description = "考前提醒时间（分钟）")
    private Integer remindTime;

    @Schema(description = "立即显示成绩：0-否，1-是")
    private Integer showScoreImmediately;


    @Schema(description = "组织ID")
    private Long orgId;

    @Schema(description = "创建人ID")
    private Long createUserId;

    @Schema(description = "创建人姓名")
    private String createUserName;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    // ==================== 统计字段 ====================

    @Schema(description = "参考人数")
    private Integer totalParticipants;

    @Schema(description = "已提交人数")
    private Integer submittedCount;

    @Schema(description = "缺考人数")
    private Integer absentCount;

    @Schema(description = "平均分")
    private Double averageScore;

    @Schema(description = "最高分")
    private Double maxScore;

    @Schema(description = "最低分")
    private Double minScore;

    @Schema(description = "及格人数")
    private Integer passCount;

    @Schema(description = "及格率")
    private Double passRate;

    // ==================== 学生端字段 ====================

    @Schema(description = "是否已参加考试")
    private Boolean hasJoined;

    @Schema(description = "考试会话ID")
    private String sessionId;

    @Schema(description = "会话状态")
    private ExamSessionStatus sessionStatus;

    @Schema(description = "学生得分")
    private BigDecimal studentScore;
}
