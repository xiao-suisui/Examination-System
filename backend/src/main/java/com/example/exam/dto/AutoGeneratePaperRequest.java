package com.example.exam.dto;

import com.example.exam.entity.paper.Paper;
import com.example.exam.entity.paper.PaperRule;
import lombok.Data;

import java.util.List;

/**
 * 自动组卷请求DTO
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-12-23
 */
@Data
public class AutoGeneratePaperRequest {

    /**
     * 试卷基本信息
     */
    private Paper paper;

    /**
     * 组卷规则列表
     */
    private List<PaperRule> rules;
}

