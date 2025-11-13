package com.example.exam.mapper.paper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.exam.entity.paper.Paper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 试卷表Mapper接口
 * 模块：试卷管理模块（exam-paper）
 * 职责：试卷数据访问
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Mapper
public interface PaperMapper extends BaseMapper<Paper> {

    /**
     * 根据创建者ID查询试卷列表
     *
     * @param creatorId 创建者ID
     * @return 试卷列表
     */
    @Select("SELECT * FROM paper WHERE create_user_id = #{creatorId} AND deleted = 0 ORDER BY create_time DESC")
    List<Paper> selectByCreatorId(@Param("creatorId") Long creatorId);

    /**
     * 查询试卷使用次数（被多少考试使用）
     *
     * @param paperId 试卷ID
     * @return 使用次数
     */
    @Select("SELECT COUNT(*) FROM exam WHERE paper_id = #{paperId} AND deleted = 0")
    int countUsageByPaperId(@Param("paperId") Long paperId);

    /**
     * 根据题库ID查询题库名称
     *
     * @param bankId 题库ID
     * @return 题库名称
     */
    @Select("SELECT bank_name FROM question_bank WHERE bank_id = #{bankId} AND deleted = 0")
    String selectBankNameById(@Param("bankId") Long bankId);
}

