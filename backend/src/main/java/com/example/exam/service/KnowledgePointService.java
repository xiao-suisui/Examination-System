package com.example.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.exam.entity.question.KnowledgePoint;

import java.util.List;

/**
 * 知识点Service接口
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
public interface KnowledgePointService extends IService<KnowledgePoint> {

    /**
     * 获取知识点树
     * @param orgId 组织ID（为null则查询所有）
     * @return 知识点树
     */
    List<KnowledgePoint> getKnowledgeTree(Long orgId);

    /**
     * 根据父ID获取子知识点
     * @param parentId 父知识点ID
     * @return 子知识点列表
     */
    List<KnowledgePoint> getChildrenByParentId(Long parentId);

    /**
     * 获取所有子知识点（递归）
     * @param knowledgeId 知识点ID
     * @return 子知识点列表
     */
    List<KnowledgePoint> getAllChildren(Long knowledgeId);

    /**
     * 检查是否有子知识点
     * @param knowledgeId 知识点ID
     * @return 是否有子知识点
     */
    boolean hasChildren(Long knowledgeId);

    /**
     * 检查知识点是否被题目使用
     * @param knowledgeId 知识点ID
     * @return 是否被使用
     */
    boolean isUsedByQuestions(Long knowledgeId);

    /**
     * 批量删除知识点
     * @param knowledgeIds 知识点ID列表
     * @return 是否成功
     */
    boolean batchDelete(List<Long> knowledgeIds);

    /**
     * 获取知识点路径（从根到当前节点）
     * @param knowledgeId 知识点ID
     * @return 路径列表
     */
    List<KnowledgePoint> getKnowledgePath(Long knowledgeId);
}

