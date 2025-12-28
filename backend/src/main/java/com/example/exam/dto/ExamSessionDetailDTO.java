package com.example.exam.dto;

import com.example.exam.entity.exam.ExamAnswer;
import com.example.exam.entity.exam.ExamSession;
import com.example.exam.entity.exam.ExamViolation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
/**
 * 考试会话详情DTO - 包含完整的考试信息
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-26
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamSessionDetailDTO {

    /**
     * 会话信息
     */
    private ExamSession session;

    /**
     * 考试基本信息
     */
    private ExamInfoDTO examInfo;

    /**
     * 题目列表（含选项）
     */
    private List<QuestionDetailDTO> questions;

    /**
     * 已保存的答案（key: questionId）
     */
    private List<ExamAnswer> answers;

    /**
     * 违规记录
     */
    private List<ExamViolation> violations;

    /**
     * 考试信息内部类
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExamInfoDTO {
        private Long examId;
        private String examName;
        private String description;
        private String paperName;
        private Integer duration;
        private String startTime;
        private String endTime;
        private Integer totalScore;
        private Integer cutScreenLimit;
        private Integer cutScreenTimer;
        private Integer forbidCopy;
        private Integer singleDevice;
        private Integer shuffleQuestions;
        private Integer shuffleOptions;
    }

    /**
     * 题目详情内部类
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuestionDetailDTO {
        private Long questionId;
        private String questionType;
        private String questionContent;
        private Integer defaultScore;
        private Integer blankCount;
        private List<OptionDTO> options;
        private Integer sortOrder;
    }

    /**
     * 选项内部类
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OptionDTO {
        private Long optionId;
        private String optionKey;
        private String optionContent;
    }
}

