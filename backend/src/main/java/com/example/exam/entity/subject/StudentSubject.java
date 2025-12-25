package com.example.exam.entity.subject;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 学生-科目关联实体类
 *
 * @author system
 * @since 2025-12-20
 */
@Data
@Accessors(chain = true)
@TableName("student_subject")
public class StudentSubject implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 关联ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 学生ID
     */
    private Long studentId;

    /**
     * 科目ID
     */
    private Long subjectId;

    /**
     * 选课类型：1-必修，2-选修
     */
    private Integer enrollType;

    /**
     * 选课时间
     */
    private LocalDateTime enrollTime;

    /**
     * 状态：0-已退课，1-正常
     */
    private Integer status;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

