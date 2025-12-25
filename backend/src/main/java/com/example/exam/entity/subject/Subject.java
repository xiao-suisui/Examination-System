
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.example.exam.entity.exam.Exam;}
    private Integer deleted;
    @TableField("deleted")
    @TableLogic
     */
     * 是否删除：0-否，1-是（逻辑删除）
    /**

    private LocalDateTime updateTime;
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
     */
     * 更新时间（自动填充）
    /**

    private LocalDateTime createTime;
    @TableField(value = "create_time", fill = FieldFill.INSERT)
     */
     * 创建时间（自动填充）
    /**

    private Long createUserId;
    @TableField(value = "create_user_id", fill = FieldFill.INSERT)
     */
     * 创建人ID（自动填充）
    /**

    private Long orgId;
    @TableField(value = "org_id", fill = FieldFill.INSERT)
     */
     * 组织ID（数据隔离）
    /**

    private Integer status;
    @TableField("status")
     */
     * 科目状态：0-禁用，1-启用
    /**

    private Integer classHours;
    @TableField("class_hours")
     */
     * 课时数
    /**

    private Integer credits;
    @TableField("credits")
     */
     * 学分
    /**

    private String academicYear;
    @TableField("academic_year")
     */
     * 学年
    /**

    private String semester;
    @TableField("semester")
     */
     * 学期
    /**

    private String coverImage;
    @TableField("cover_image")
     */
     * 封面图片
    /**

    private String description;
    @TableField("description")
     */
     * 科目描述
    /**

    private String subjectCode;
    @TableField("subject_code")
     */
     * 科目代码
    /**

    private String subjectName;
    @TableField("subject_name")
     */
     * 科目名称
    /**

    private Long subjectId;
    @TableId(value = "subject_id", type = IdType.AUTO)
     */
     * 科目ID（主键，自增）
    /**

    private static final long serialVersionUID = 1L;
    @Serial

public class Subject implements Serializable {
@TableName("subject")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
 */
 * @since 2025-12-26
 * @version 2.0
 * @author
    Exam System
 *
 * 科目表实体类
/**

import java.time.LocalDateTime;
import java.io.Serializable;
import java.io.Serial;

import lombok.experimental.Accessors;
import lombok.*;
import com.baomidou.mybatisplus.annotation.*;


