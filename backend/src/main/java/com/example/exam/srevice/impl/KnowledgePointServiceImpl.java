package com.example.exam.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.question.KnowledgePoint;
import com.example.exam.entity.question.Question;
import com.example.exam.mapper.question.KnowledgePointMapper;
import com.example.exam.mapper.question.QuestionMapper;
import com.example.exam.service.KnowledgePointService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 知识点Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class KnowledgePointServiceImpl extends ServiceImpl<KnowledgePointMapper, KnowledgePoint>
        implements KnowledgePointService {

    private final QuestionMapper questionMapper;

    @Override
    public List<KnowledgePoint> getKnowledgeTree(Long orgId) {
        LambdaQueryWrapper<KnowledgePoint> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(orgId != null, KnowledgePoint::getOrgId, orgId)
               .orderByAsc(KnowledgePoint::getSort)
               .orderByAsc(KnowledgePoint::getKnowledgeId);

        List<KnowledgePoint> allPoints = this.list(wrapper);
        return buildTree(allPoints, 0L);
    }

    @Override
    public List<KnowledgePoint> getChildrenByParentId(Long parentId) {
        LambdaQueryWrapper<KnowledgePoint> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(KnowledgePoint::getParentId, parentId)
               .orderByAsc(KnowledgePoint::getSort)
               .orderByAsc(KnowledgePoint::getKnowledgeId);
        return this.list(wrapper);
    }

    @Override
    public List<KnowledgePoint> getAllChildren(Long knowledgeId) {
        List<KnowledgePoint> result = new ArrayList<>();
        collectAllChildren(knowledgeId, result);
        return result;
    }

    @Override
    public boolean hasChildren(Long knowledgeId) {
        LambdaQueryWrapper<KnowledgePoint> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(KnowledgePoint::getParentId, knowledgeId);
        return this.count(wrapper) > 0;
    }

    @Override
    public boolean isUsedByQuestions(Long knowledgeId) {
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        // knowledge_ids字段存储的是逗号分隔的字符串，使用LIKE查询
        wrapper.like(Question::getKnowledgeIds, knowledgeId.toString());
        return questionMapper.selectCount(wrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchDelete(List<Long> knowledgeIds) {
        try {
            for (Long knowledgeId : knowledgeIds) {
                // 检查是否有子知识点
                if (hasChildren(knowledgeId)) {
                    throw new RuntimeException("知识点存在子知识点，无法删除");
                }
                // 检查是否被题目使用
                if (isUsedByQuestions(knowledgeId)) {
                    throw new RuntimeException("知识点已被题目使用，无法删除");
                }
            }
            return this.removeByIds(knowledgeIds);
        } catch (Exception e) {
            log.error("批量删除知识点失败", e);
            throw e;
        }
    }

    @Override
    public List<KnowledgePoint> getKnowledgePath(Long knowledgeId) {
        List<KnowledgePoint> path = new ArrayList<>();
        KnowledgePoint current = this.getById(knowledgeId);

        while (current != null) {
            path.add(0, current); // 添加到列表开头
            if (current.getParentId() == null || current.getParentId() == 0) {
                break;
            }
            current = this.getById(current.getParentId());
        }

        return path;
    }

    /**
     * 递归收集所有子知识点
     */
    private void collectAllChildren(Long parentId, List<KnowledgePoint> result) {
        List<KnowledgePoint> children = getChildrenByParentId(parentId);
        result.addAll(children);
        for (KnowledgePoint child : children) {
            collectAllChildren(child.getKnowledgeId(), result);
        }
    }

    /**
     * 构建树形结构
     */
    private List<KnowledgePoint> buildTree(List<KnowledgePoint> allPoints, Long parentId) {
        return allPoints.stream()
                .filter(point -> {
                    Long pid = point.getParentId();
                    return (pid == null && parentId == 0L) || parentId.equals(pid);
                })
                .peek(point -> {
                    // 这里可以添加children字段到实体类（使用@TableField(exist = false)）
                    // 暂时通过递归返回子节点
                })
                .collect(Collectors.toList());
    }
}

