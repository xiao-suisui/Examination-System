package com.example.exam.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.common.enums.PaperType;
import com.example.exam.dto.PaperDTO;
import com.example.exam.entity.paper.Paper;
import com.example.exam.entity.paper.PaperRule;

/**
 * 试卷Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
public interface PaperService extends IService<Paper> {

    /**
     * 查询试卷列表（不分页）
     * @param keyword 试卷名称关键词
     * @param bankId 题库ID
     * @param auditStatus 审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝
     * @return 试卷DTO列表
     */
    java.util.List<PaperDTO> listPapers(String keyword, Long bankId, com.example.exam.common.enums.AuditStatus auditStatus);

    /**
     * 分页查询试卷（返回DTO）
     * @param page 分页对象
     * @param keyword 试卷名称关键词
     * @param bankId 题库ID
     * @param paperType 组卷方式：1-手动组卷，2-自动组卷，3-随机组卷
     * @param auditStatus 审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝
     */
    IPage<PaperDTO> pagePapers(Page<Paper> page, String keyword, Long bankId, PaperType paperType, com.example.exam.common.enums.AuditStatus auditStatus);

    /**
     * 查询试卷详情（含题目）
     */
    Paper getPaperWithQuestions(Long paperId);

    /**
     * 查询试卷DTO详情（含题目和选项）
     */
    com.example.exam.dto.PaperDTO getPaperDTOWithQuestions(Long paperId);

    /**
     * 自动组卷
     */
    Long autoGeneratePaper(Paper paper, PaperRule[] rules);

    /**
     * 添加题目到试卷
     */
    boolean addQuestionsToPaper(Long paperId, Long[] questionIds);

    /**
     * 从试卷移除题目
     */
    boolean removeQuestionsFromPaper(Long paperId, Long[] questionIds);

    /**
     * 预览试卷
     */
    Paper previewPaper(Long paperId);

    /**
     * 复制试卷
     */
    Long copyPaper(Long paperId, String newTitle);

    /**
     * 获取试卷统计信息
     *
     * @param paperId 试卷ID
     * @return 统计信息
     */
    com.example.exam.dto.PaperStatisticsDTO getPaperStatistics(Long paperId);
}

