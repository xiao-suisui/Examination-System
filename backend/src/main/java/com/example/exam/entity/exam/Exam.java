package com.example.exam.entity.exam;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 考试表实体类
 *
 * 模块：考试管理模块（exam-exam）
 * 职责：管理考试（发布、配置、防作弊）
 * 表名：exam
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("exam")
public class Exam implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 考试ID（主键，自增）
     */
    @TableId(value = "exam_id", type = IdType.AUTO)
    private Long examId;

    /**
     * 考试名称
     */
    @TableField("exam_name")
    private String examName;

    /**
     * 考试描述
     */
    @TableField("description")
    private String description;

    /**
     * 考试封面图片
     */
    @TableField("cover_image")
    private String coverImage;

    /**
     * 试卷ID
     */
    @TableField("paper_id")
    private Long paperId;

    /**
     * 考试开始时间
     */
    @TableField("start_time")
    private LocalDateTime startTime;

    /**
     * 考试结束时间
     */
    @TableField("end_time")
    private LocalDateTime endTime;

    /**
     * 考试时长（分钟）
     */
    @TableField("duration")
    private Integer duration;

    /**
     * 考试范围类型：1-指定考生，2-指定班级，3-指定组织
     */
    @TableField("exam_range_type")
    private Integer examRangeType;

    /**
     * 考试范围ID列表（JSON数组）
     */
    @TableField("exam_range_ids")
    private String examRangeIds;

    /**
     * 考试状态：0-未开始，1-进行中，2-已结束，3-已终止
     */
    @TableField("exam_status")
    private Integer examStatus;

    /**
     * 允许切屏次数（0-5）
     */
    @TableField("cut_screen_limit")
    private Integer cutScreenLimit;

    /**
     * 切屏时长是否计入考试时间：0-不计入，1-计入
     */
    @TableField("cut_screen_timer")
    private Integer cutScreenTimer;

    /**
     * 禁止复制粘贴：0-允许，1-禁止
     */
    @TableField("forbid_copy")
    private Integer forbidCopy;

    /**
     * 单设备登录：0-允许多设备，1-仅允许单设备
     */
    @TableField("single_device")
    private Integer singleDevice;

    /**
     * 是否乱序题目：0-否，1-是
     */
    @TableField("shuffle_questions")
    private Integer shuffleQuestions;

    /**
     * 是否乱序选项：0-否，1-是
     */
    @TableField("shuffle_options")
    private Integer shuffleOptions;

    /**
     * 主观题防抄袭：0-关闭，1-开启
     */
    @TableField("anti_plagiarism")
    private Integer antiPlagiarism;

    /**
     * 相似度阈值（0-100）
     */
    @TableField("plagiarism_threshold")
    private Integer plagiarismThreshold;

    /**
     * 考前提醒时间（分钟，0-60）
     */
    @TableField("remind_time")
    private Integer remindTime;

    /**
     * 交卷后是否立即显示成绩：0-否，1-是
     */
    @TableField("show_score_immediately")
    private Integer showScoreImmediately;

    /**
     * 组织ID
     */
    @TableField("org_id")
    private Long orgId;

    /**
     * 创建人ID
     */
    @TableField("create_user_id")
    private Long createUserId;

    /**
     * 创建时间（自动填充）
     */
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间（自动填充）
     */
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 是否删除：0-否，1-是（逻辑删除）
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}

