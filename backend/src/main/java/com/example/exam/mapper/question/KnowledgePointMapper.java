package com.example.exam.mapper.question;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.question.KnowledgePoint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 知识点表Mapper接口
 *
 * 模块：题库管理模块（exam-question）
 * 职责：知识点数据访问，支持树形结构查询
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface KnowledgePointMapper extends BaseMapper<KnowledgePoint> {

    /**
     * 查询指定父节点下的所有子知识点
     *
     * @param parentId 父节点ID
     * @return 子知识点列表
     */
    @Select("SELECT * FROM knowledge_point WHERE parent_id = #{parentId} AND deleted = 0 ORDER BY sort")
    List<KnowledgePoint> selectByParentId(@Param("parentId") Long parentId);

    /**
     * 查询根节点知识点（顶级分类）
     *
     * @return 根节点列表
     */
    @Select("SELECT * FROM knowledge_point WHERE parent_id IS NULL AND deleted = 0 ORDER BY sort")
    List<KnowledgePoint> selectRootNodes();
}

