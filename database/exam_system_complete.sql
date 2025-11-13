-- ============================================================
-- 考试系统完整数据库脚本（全新设计）
-- 版本: 2.0
-- 更新日期: 2025-11-06
-- 数据库: MySQL 8.0.35+
-- 字符集: utf8mb4
-- 备注: 基于需求文档V1.0完整版设计
-- ============================================================
--
-- 【版本更新说明】
--
-- V2.0 (2025-11-06):
-- - 完善8种题型支持（单选、多选、不定项、判断、匹配、排序、填空、主观）
-- - 添加防作弊相关字段（切屏检测、单设备登录、主观题防抄袭）
-- - 增强成绩管理（客观题自动判分、主观题批改）
-- - 完善权限管理（RBAC三层模型）
-- - 添加考试监控和审计日志
--
-- 【外键约束说明】
--
-- 本脚本默认 **不使用物理外键约束**，原因如下：
--
-- 1. 性能考虑：
--    - 外键检查会增加 INSERT/UPDATE/DELETE 操作的开销
--    - 高并发场景下，外键会增加锁竞争，降低系统吞吐量
--    - 考试系统在考试高峰期（如 500+ 人同时答题）需要高性能
--
-- 2. 扩展性考虑：
--    - 未来如需水平分库分表，外键会成为障碍
--    - 跨库查询时外键约束无法生效
--    - Redis 缓存策略与外键约束可能冲突
--
-- 3. 灵活性考虑：
--    - 某些业务场景需要先插入关联数据后补充主数据
--    - 数据迁移和批量导入时外键会增加复杂度
--    - 测试环境数据准备更灵活
--
-- 【替代方案】
--
-- 1. 逻辑外键：所有表设计中已通过命名和注释明确关联关系
-- 2. 应用层控制：在 Service 层实现数据完整性检查（推荐）
-- 3. 数据库索引：所有外键字段都已建立索引，保证查询性能
-- 4. 定期校验：提供数据一致性校验脚本（见脚本末尾）
--
-- 【如何启用外键】
--
-- 如果您的项目场景适合使用外键（小规模、低并发），可以：
-- 1. 在脚本末尾找到 "可选：外键约束" 部分
-- 2. 取消注释相关 ALTER TABLE 语句
-- 3. 执行完整脚本
--
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建数据库
DROP DATABASE IF EXISTS `exam_system`;
CREATE DATABASE `exam_system` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `exam_system`;

-- ============================================================
-- 第一部分：用户与权限管理
-- ============================================================

-- 1. 组织表
DROP TABLE IF EXISTS `sys_organization`;
CREATE TABLE `sys_organization` (
  `org_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '组织ID',
  `org_name` VARCHAR(100) NOT NULL COMMENT '组织名称',
  `org_code` VARCHAR(50) DEFAULT NULL COMMENT '组织编码',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父组织ID（0为顶级）',
  `org_level` TINYINT NOT NULL COMMENT '组织层级：1-学校/企业，2-学院/部门，3-班级/小组',
  `org_type` VARCHAR(20) DEFAULT 'SCHOOL' COMMENT '组织类型：SCHOOL-学校，ENTERPRISE-企业，TRAINING-培训机构',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`org_id`),
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_org_level` (`org_level`),
  INDEX `idx_status` (`status`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='组织表';

-- 2. 角色表
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `role_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
  `role_desc` VARCHAR(200) DEFAULT NULL COMMENT '角色描述',
  `is_default` TINYINT DEFAULT 0 COMMENT '是否预设角色：0-自定义，1-预设（不可删除）',
  `create_user_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_role_code` (`role_code`, `deleted`),
  INDEX `idx_status` (`status`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 3. 权限表
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission` (
  `perm_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `perm_name` VARCHAR(100) NOT NULL COMMENT '权限名称',
  `perm_code` VARCHAR(50) NOT NULL COMMENT '权限编码',
  `perm_type` VARCHAR(20) NOT NULL COMMENT '权限类型：MENU-菜单，BUTTON-按钮，API-接口',
  `perm_url` VARCHAR(200) DEFAULT NULL COMMENT '权限URL或路由',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父权限ID',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`perm_id`),
  UNIQUE KEY `uk_perm_code` (`perm_code`, `deleted`),
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- 4. 角色权限关联表
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `perm_id` BIGINT NOT NULL COMMENT '权限ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_perm` (`role_id`, `perm_id`),
  INDEX `idx_role_id` (`role_id`),
  INDEX `idx_perm_id` (`perm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 5. 用户表
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名（登录账号）',
  `password` VARCHAR(100) NOT NULL COMMENT '密码（Bcrypt加密）',
  `real_name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号（AES-256加密）',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱（AES-256加密）',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  `gender` TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
  `org_id` BIGINT NOT NULL COMMENT '组织ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `audit_status` TINYINT DEFAULT 1 COMMENT '审核状态：0-待审核，1-已通过，2-已拒绝',
  `audit_remark` VARCHAR(200) DEFAULT NULL COMMENT '审核备注',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_username` (`username`, `deleted`),
  UNIQUE KEY `uk_phone` (`phone`, `deleted`),
  UNIQUE KEY `uk_email` (`email`, `deleted`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_role_id` (`role_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_audit_status` (`audit_status`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 6. 菜单表
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `menu_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` VARCHAR(50) NOT NULL COMMENT '菜单名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父菜单ID',
  `menu_type` TINYINT NOT NULL COMMENT '菜单类型：1-目录，2-菜单，3-按钮',
  `path` VARCHAR(200) DEFAULT NULL COMMENT '路由路径',
  `component` VARCHAR(200) DEFAULT NULL COMMENT '组件路径',
  `icon` VARCHAR(100) DEFAULT NULL COMMENT '图标',
  `perm_code` VARCHAR(50) DEFAULT NULL COMMENT '权限标识',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `visible` TINYINT DEFAULT 1 COMMENT '是否可见：0-否，1-是',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`menu_id`),
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单表';

-- ============================================================
-- 第二部分：题库管理
-- ============================================================

-- 7. 知识点分类表（3级结构）
DROP TABLE IF EXISTS `knowledge_point`;
CREATE TABLE `knowledge_point` (
  `knowledge_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
  `knowledge_name` VARCHAR(100) NOT NULL COMMENT '知识点名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父知识点ID（0为顶级）',
  `level` TINYINT NOT NULL COMMENT '层级：1-一级，2-二级，3-三级',
  `org_id` BIGINT NOT NULL COMMENT '组织ID（数据隔离）',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '知识点描述',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`knowledge_id`),
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_level` (`level`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点分类表';

-- 8. 题库表
DROP TABLE IF EXISTS `question_bank`;
CREATE TABLE `question_bank` (
  `bank_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '题库ID',
  `bank_name` VARCHAR(100) NOT NULL COMMENT '题库名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '题库描述',
  `bank_type` VARCHAR(20) DEFAULT 'PUBLIC' COMMENT '题库类型：PUBLIC-公共题库，PRIVATE-私有题库',
  `cover_image` VARCHAR(255) DEFAULT NULL COMMENT '封面图片',
  `question_count` INT DEFAULT 0 COMMENT '题目数量（统计字段）',
  `create_user_id` BIGINT DEFAULT NULL COMMENT '创建者ID（私有题库必填）',
  `org_id` BIGINT NOT NULL COMMENT '组织ID（数据隔离）',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`bank_id`),
  INDEX `idx_bank_type` (`bank_type`),
  INDEX `idx_create_user_id` (`create_user_id`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题库表';

-- 9. 题目表（支持8种题型）
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question` (
  `question_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `bank_id` BIGINT NOT NULL COMMENT '题库ID',
  `org_id` BIGINT NOT NULL COMMENT '组织ID（数据隔离）',
  `question_content` TEXT NOT NULL COMMENT '题目内容（富文本，支持图片/公式）',
  `question_type` VARCHAR(50) NOT NULL COMMENT '题型：SINGLE_CHOICE-单选，MULTIPLE_CHOICE-多选，INDEFINITE_CHOICE-不定项，TRUE_FALSE-判断，MATCHING-匹配，SORT-排序，FILL_BLANK-填空，SUBJECTIVE-主观',
  `default_score` DECIMAL(5,2) DEFAULT 2.00 COMMENT '默认分值',
  `difficulty` VARCHAR(20) DEFAULT 'MEDIUM' COMMENT '难度：EASY-简单，MEDIUM-中等，HARD-困难',
  `knowledge_ids` VARCHAR(200) DEFAULT NULL COMMENT '知识点ID列表（逗号分隔，最多3个）',
  `answer_list` TEXT DEFAULT NULL COMMENT '填空题答案（格式：空1答案1,空1答案2|空2答案1）',
  `reference_answer` TEXT DEFAULT NULL COMMENT '主观题参考答案',
  `score_rule` VARCHAR(500) DEFAULT NULL COMMENT '主观题评分标准',
  `answer_analysis` TEXT DEFAULT NULL COMMENT '答案解析',
  `question_image` VARCHAR(255) DEFAULT NULL COMMENT '题目图片URL',
  `use_count` INT DEFAULT 0 COMMENT '被组卷使用次数',
  `correct_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '历史正确率（百分比）',
  `audit_status` TINYINT DEFAULT 0 COMMENT '审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝',
  `audit_remark` VARCHAR(200) DEFAULT NULL COMMENT '审核备注',
  `auditor_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `audit_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `create_user_id` BIGINT NOT NULL COMMENT '创建人ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`question_id`),
  INDEX `idx_bank_id` (`bank_id`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_question_type` (`question_type`),
  INDEX `idx_difficulty` (`difficulty`),
  INDEX `idx_audit_status` (`audit_status`),
  INDEX `idx_create_user_id` (`create_user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_deleted` (`deleted`),
  INDEX `idx_composite` (`bank_id`, `question_type`, `difficulty`, `audit_status`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表';

-- 10. 选项表（支持8种题型的专属属性）
DROP TABLE IF EXISTS `question_option`;
CREATE TABLE `question_option` (
  `option_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '选项ID',
  `question_id` BIGINT NOT NULL COMMENT '题目ID',
  `option_seq` VARCHAR(10) NOT NULL COMMENT '选项序号（A/B/C/D或1/2/3）',
  `option_content` TEXT NOT NULL COMMENT '选项内容',
  `is_correct` TINYINT DEFAULT 0 COMMENT '是否正确答案：0-否，1-是（单选/多选/判断题用）',
  `score_ratio` TINYINT DEFAULT NULL COMMENT '分值占比（0-100，不定项选择题专用）',
  `option_type` VARCHAR(20) DEFAULT 'NORMAL' COMMENT '选项类型：NORMAL-普通，STEM-题干（匹配题），MATCH-匹配项（匹配题）',
  `assoc_flag` VARCHAR(10) DEFAULT NULL COMMENT '关联标识（匹配题专用，如M1、M2）',
  `correct_order` INT DEFAULT NULL COMMENT '正确排序值（排序题专用，如1、2、3）',
  `option_analysis` VARCHAR(500) DEFAULT NULL COMMENT '选项解析',
  `option_image` VARCHAR(255) DEFAULT NULL COMMENT '选项图片URL',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`option_id`),
  INDEX `idx_question_id` (`question_id`),
  INDEX `idx_question_correct` (`question_id`, `is_correct`),
  INDEX `idx_assoc_flag` (`question_id`, `assoc_flag`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='选项表';

-- 11. 题目标签表
DROP TABLE IF EXISTS `question_tag`;
CREATE TABLE `question_tag` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `question_id` BIGINT NOT NULL COMMENT '题目ID',
  `tag_name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_tag` (`question_id`, `tag_name`),
  INDEX `idx_tag_name` (`tag_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目标签表';

-- ============================================================
-- 第三部分：试卷管理
-- ============================================================

-- 12. 试卷表
DROP TABLE IF EXISTS `paper`;
CREATE TABLE `paper` (
  `paper_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
  `paper_name` VARCHAR(200) NOT NULL COMMENT '试卷名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '试卷描述',
  `paper_type` TINYINT NOT NULL COMMENT '组卷方式：1-固定组卷，2-随机组卷',
  `total_score` DECIMAL(5,2) NOT NULL DEFAULT 100.00 COMMENT '试卷总分',
  `pass_score` DECIMAL(5,2) NOT NULL DEFAULT 60.00 COMMENT '及格分',
  `org_id` BIGINT NOT NULL COMMENT '组织ID（数据隔离）',
  `create_user_id` BIGINT NOT NULL COMMENT '创建人ID',
  `audit_status` TINYINT DEFAULT 0 COMMENT '审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝',
  `audit_remark` VARCHAR(200) DEFAULT NULL COMMENT '审核备注',
  `auditor_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `audit_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `publish_status` TINYINT DEFAULT 0 COMMENT '发布状态：0-未发布，1-已发布，2-已过期',
  `publish_time` DATETIME DEFAULT NULL COMMENT '发布时间',
  `allow_view_analysis` TINYINT DEFAULT 0 COMMENT '允许查看错题解析：0-否，1-是',
  `allow_reexam` TINYINT DEFAULT 0 COMMENT '允许补考：0-否，1-是',
  `reexam_limit` INT DEFAULT 0 COMMENT '补考次数限制（0表示不限）',
  `valid_days` INT DEFAULT 30 COMMENT '发布后有效天数',
  `version` INT DEFAULT 1 COMMENT '试卷版本号',
  `parent_paper_id` BIGINT DEFAULT NULL COMMENT '父试卷ID（版本管理用）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`paper_id`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_create_user_id` (`create_user_id`),
  INDEX `idx_audit_status` (`audit_status`),
  INDEX `idx_publish_status` (`publish_status`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷表';

-- 13. 试卷题目关联表（固定组卷使用）
DROP TABLE IF EXISTS `paper_question`;
CREATE TABLE `paper_question` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `paper_id` BIGINT NOT NULL COMMENT '试卷ID',
  `question_id` BIGINT NOT NULL COMMENT '题目ID',
  `question_score` DECIMAL(5,2) NOT NULL COMMENT '该题在试卷中的分值',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '题目顺序',
  `rule_id` BIGINT DEFAULT NULL COMMENT '关联组卷规则ID（随机组卷用）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_paper_question` (`paper_id`, `question_id`),
  INDEX `idx_paper_id` (`paper_id`),
  INDEX `idx_question_id` (`question_id`),
  INDEX `idx_sort_order` (`paper_id`, `sort_order`),
  INDEX `idx_rule_id` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷题目关联表';

-- 14. 组卷规则表（随机组卷使用）
DROP TABLE IF EXISTS `paper_rule`;
CREATE TABLE `paper_rule` (
  `rule_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `paper_id` BIGINT NOT NULL COMMENT '试卷ID',
  `bank_id` BIGINT DEFAULT NULL COMMENT '题库ID（从哪个题库抽题）',
  `question_type` TINYINT NOT NULL COMMENT '题型：1-单选，2-多选，4-判断，6-填空，7-简答',
  `total_num` INT NOT NULL COMMENT '该题型总题量',
  `easy_num` INT DEFAULT 0 COMMENT '简单题数量',
  `medium_num` INT DEFAULT 0 COMMENT '中等题数量',
  `hard_num` INT DEFAULT 0 COMMENT '困难题数量',
  `single_score` DECIMAL(5,2) NOT NULL COMMENT '每题分值',
  `knowledge_ids` VARCHAR(200) DEFAULT NULL COMMENT '指定知识点ID列表（逗号分隔，为空则不限）',
  `sort_order` INT DEFAULT 0 COMMENT '题型顺序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`rule_id`),
  INDEX `idx_paper_id` (`paper_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='组卷规则表（随机组卷用）';

-- ============================================================
-- 第四部分：考试管理
-- ============================================================

-- 15. 考试表
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam` (
  `exam_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '考试ID',
  `exam_name` VARCHAR(200) NOT NULL COMMENT '考试名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '考试描述',
  `cover_image` VARCHAR(255) DEFAULT NULL COMMENT '考试封面图片',
  `paper_id` BIGINT NOT NULL COMMENT '试卷ID',
  `start_time` DATETIME NOT NULL COMMENT '考试开始时间',
  `end_time` DATETIME NOT NULL COMMENT '考试结束时间',
  `duration` INT NOT NULL COMMENT '考试时长（分钟）',
  `exam_range_type` TINYINT DEFAULT 1 COMMENT '考试范围类型：1-指定考生，2-指定班级，3-指定组织',
  `exam_range_ids` TEXT DEFAULT NULL COMMENT '考试范围ID列表（JSON数组）',
  `exam_status` TINYINT DEFAULT 0 COMMENT '考试状态：0-未开始，1-进行中，2-已结束，3-已终止',
  `cut_screen_limit` TINYINT DEFAULT 3 COMMENT '允许切屏次数（0-5）',
  `cut_screen_timer` TINYINT DEFAULT 1 COMMENT '切屏时长是否计入考试时间：0-不计入，1-计入',
  `forbid_copy` TINYINT DEFAULT 1 COMMENT '禁止复制粘贴：0-允许，1-禁止',
  `single_device` TINYINT DEFAULT 1 COMMENT '单设备登录：0-允许多设备，1-仅允许单设备',
  `shuffle_questions` TINYINT DEFAULT 0 COMMENT '是否乱序题目：0-否，1-是',
  `shuffle_options` TINYINT DEFAULT 0 COMMENT '是否乱序选项：0-否，1-是',
  `anti_plagiarism` TINYINT DEFAULT 0 COMMENT '主观题防抄袭：0-关闭，1-开启',
  `plagiarism_threshold` TINYINT DEFAULT 80 COMMENT '相似度阈值（0-100）',
  `remind_time` TINYINT DEFAULT 15 COMMENT '考前提醒时间（分钟，0-60）',
  `show_score_immediately` TINYINT DEFAULT 1 COMMENT '交卷后是否立即显示成绩：0-否，1-是',
  `org_id` BIGINT NOT NULL COMMENT '组织ID',
  `create_user_id` BIGINT NOT NULL COMMENT '创建人ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`exam_id`),
  INDEX `idx_paper_id` (`paper_id`),
  INDEX `idx_org_id` (`org_id`),
  INDEX `idx_exam_status` (`exam_status`),
  INDEX `idx_time_range` (`start_time`, `end_time`),
  INDEX `idx_create_user_id` (`create_user_id`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试表';

-- 16. 考试考生关联表
DROP TABLE IF EXISTS `exam_user`;
CREATE TABLE `exam_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `exam_id` BIGINT NOT NULL COMMENT '考试ID',
  `user_id` BIGINT NOT NULL COMMENT '考生ID',
  `exam_status` TINYINT DEFAULT 0 COMMENT '考试状态：0-未参考，1-参考中，2-已提交，3-缺考',
  `reexam_count` INT DEFAULT 0 COMMENT '已补考次数',
  `final_score` DECIMAL(5,2) DEFAULT NULL COMMENT '最终成绩',
  `pass_status` TINYINT DEFAULT NULL COMMENT '及格状态：0-不及格，1-及格',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_exam_user` (`exam_id`, `user_id`),
  INDEX `idx_exam_id` (`exam_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_exam_status` (`exam_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试考���关联表';

-- 17. 考试会话表
DROP TABLE IF EXISTS `exam_session`;
CREATE TABLE `exam_session` (
  `session_id` VARCHAR(64) NOT NULL COMMENT '会话ID（UUID）',
  `exam_id` BIGINT NOT NULL COMMENT '考试ID',
  `user_id` BIGINT NOT NULL COMMENT '考生ID',
  `attempt_number` INT DEFAULT 1 COMMENT '第几次考试（补考用）',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `submit_time` DATETIME DEFAULT NULL COMMENT '提交时间',
  `duration` INT DEFAULT NULL COMMENT '实际用时（分钟）',
  `session_status` VARCHAR(20) DEFAULT 'IN_PROGRESS' COMMENT '状态：IN_PROGRESS-进行中，SUBMITTED-已提交，GRADED-已批改，TERMINATED-已终止',
  `total_score` DECIMAL(5,2) DEFAULT NULL COMMENT '总得分',
  `objective_score` DECIMAL(5,2) DEFAULT NULL COMMENT '客观题得分',
  `subjective_score` DECIMAL(5,2) DEFAULT NULL COMMENT '主观题得分',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
  `device_info` VARCHAR(200) DEFAULT NULL COMMENT '设备信息',
  `tab_switch_count` INT DEFAULT 0 COMMENT '切屏次数',
  `tab_switch_records` TEXT DEFAULT NULL COMMENT '切屏记录（JSON数组）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`session_id`),
  INDEX `idx_exam_user` (`exam_id`, `user_id`),
  INDEX `idx_session_status` (`session_status`),
  INDEX `idx_submit_time` (`submit_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试会话表';

-- ============================================================
-- 第五部分：答题与批改
-- ============================================================

-- 18. 答题记录表
DROP TABLE IF EXISTS `exam_answer`;
CREATE TABLE `exam_answer` (
  `answer_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '答案ID',
  `session_id` VARCHAR(64) NOT NULL COMMENT '会话ID',
  `exam_id` BIGINT NOT NULL COMMENT '考试ID',
  `question_id` BIGINT NOT NULL COMMENT '题目ID',
  `user_id` BIGINT NOT NULL COMMENT '考生ID',
  `option_ids` VARCHAR(200) DEFAULT NULL COMMENT '选择的选项ID（用逗号分隔，客观题用）',
  `user_answer` TEXT DEFAULT NULL COMMENT '考生答案（主观题、填空题用）',
  `answer_order` VARCHAR(200) DEFAULT NULL COMMENT '排序题答案（选项ID按顺序，用逗号分隔）',
  `score` DECIMAL(5,2) DEFAULT NULL COMMENT '该题得分',
  `is_correct` TINYINT DEFAULT NULL COMMENT '是否正确：0-错误，1-正确，NULL-未批改',
  `is_marked` TINYINT DEFAULT 0 COMMENT '是否标记（答题时考生标记的不确定题目）',
  `graded_by` BIGINT DEFAULT NULL COMMENT '批改人ID',
  `grade_time` DATETIME DEFAULT NULL COMMENT '批改时间',
  `teacher_comment` VARCHAR(500) DEFAULT NULL COMMENT '教师评语（限200字）',
  `answer_time` DATETIME DEFAULT NULL COMMENT '答题时间',
  `time_spent` INT DEFAULT NULL COMMENT '答题耗时（秒）',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`answer_id`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_exam_question` (`exam_id`, `question_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_correct` (`is_correct`),
  INDEX `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='答题记录表';

-- ============================================================
-- 第六部分：系统日志
-- ============================================================

-- 19. 操作日志表
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT NOT NULL COMMENT '操作人ID',
  `operate_type` VARCHAR(50) NOT NULL COMMENT '操作类型：CREATE-新增，UPDATE-修改，DELETE-删除，PUBLISH-发布，TERMINATE-终止',
  `operate_module` VARCHAR(50) NOT NULL COMMENT '操作模块：PAPER-试卷，EXAM-考试，QUESTION-题目',
  `operate_content` VARCHAR(1000) NOT NULL COMMENT '操作内容描述',
  `target_id` BIGINT DEFAULT NULL COMMENT '操作对象ID',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT '操作IP',
  `device_info` VARCHAR(200) DEFAULT NULL COMMENT '设备信息',
  `operate_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_operate_type` (`operate_type`),
  INDEX `idx_operate_module` (`operate_module`),
  INDEX `idx_operate_time` (`operate_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- ============================================================
-- 第七部分：初始化数据
-- ============================================================

-- 1. 初始化默认组织
INSERT INTO `sys_organization` (`org_id`, `org_name`, `org_code`, `parent_id`, `org_level`, `org_type`, `sort`) VALUES
(1, '系统默认组织', 'DEFAULT_ORG', 0, 1, 'SCHOOL', 1);

-- 2. 初始化角色
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_code`, `role_desc`, `is_default`, `sort`) VALUES
(1, '系统管理员', 'ADMIN', '系统管理员，拥有所有权限', 1, 1),
(2, '教师', 'TEACHER', '教师角色，可以出题、组卷、批改、查看成绩', 1, 2),
(3, '考生', 'STUDENT', '考生角色，可以参加考试、查看成绩', 1, 3);

-- 3. 初始化权限（示例）
INSERT INTO `sys_permission` (`perm_id`, `perm_name`, `perm_code`, `perm_type`, `resource_code`, `parent_id`, `sort`) VALUES
-- 题目管理权限
(1, '题目管理', 'QUESTION_MANAGE', 1, 'question', 0, 1),
(2, '创建题目', 'QUESTION_CREATE', 2, 'question', 1, 1),
(3, '编辑题目', 'QUESTION_UPDATE', 2, 'question', 1, 2),
(4, '删除题目', 'QUESTION_DELETE', 2, 'question', 1, 3),
(5, '审核题目', 'QUESTION_AUDIT', 2, 'question', 1, 4),
-- 试卷管理权限
(10, '试卷管理', 'PAPER_MANAGE', 1, 'paper', 0, 2),
(11, '创建试卷', 'PAPER_CREATE', 2, 'paper', 10, 1),
(12, '编辑试卷', 'PAPER_UPDATE', 2, 'paper', 10, 2),
(13, '删除试卷', 'PAPER_DELETE', 2, 'paper', 10, 3),
(14, '审核试卷', 'PAPER_AUDIT', 2, 'paper', 10, 4),
(15, '发布试卷', 'PAPER_PUBLISH', 2, 'paper', 10, 5),
-- 考试管理权限
(20, '考试管理', 'EXAM_MANAGE', 1, 'exam', 0, 3),
(21, '创建考试', 'EXAM_CREATE', 2, 'exam', 20, 1),
(22, '发布考试', 'EXAM_PUBLISH', 2, 'exam', 20, 2),
(23, '终止考试', 'EXAM_TERMINATE', 2, 'exam', 20, 3),
(24, '监控考试', 'EXAM_MONITOR', 2, 'exam', 20, 4),
(25, '批改试卷', 'EXAM_GRADE', 2, 'exam', 20, 5),
-- 考生权限
(30, '参加考试', 'EXAM_TAKE', 2, 'exam', 0, 4),
(31, '查看成绩', 'SCORE_VIEW', 2, 'score', 0, 5);

-- 4. 分配角色权限
-- 管理员：所有权限
INSERT INTO `sys_role_permission` (`role_id`, `perm_id`)
SELECT 1, perm_id FROM `sys_permission`;

-- 教师：题目、试卷、考试管理权限
INSERT INTO `sys_role_permission` (`role_id`, `perm_id`) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5),
(2, 10), (2, 11), (2, 12), (2, 13), (2, 15),
(2, 20), (2, 21), (2, 22), (2, 23), (2, 24), (2, 25),
(2, 31);

-- 考生：参加考试和查看成绩
INSERT INTO `sys_role_permission` (`role_id`, `perm_id`) VALUES
(3, 30), (3, 31);

-- 5. 创建默认管理员账号（密码：Admin@123，需要Bcrypt加密）
-- 注意：实际部署时请修改密码
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `real_name`, `org_id`, `role_id`, `status`, `audit_status`) VALUES
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 1, 1, 1, 1);
-- 密码说明：上面的密码是 Admin@123 的Bcrypt加密结果（示例）

-- 6. 初始化菜单（示例）
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `menu_type`, `path`, `component`, `icon`, `perm_code`, `sort`, `visible`, `status`) VALUES
-- 一级菜单
(1, '题库管理', 0, 1, '/question', NULL, 'el-icon-reading', NULL, 1, 1, 1),
(2, '试卷管理', 0, 1, '/paper', NULL, 'el-icon-document', NULL, 2, 1, 1),
(3, '考试管理', 0, 1, '/exam', NULL, 'el-icon-edit', NULL, 3, 1, 1),
(4, '成绩管理', 0, 1, '/score', NULL, 'el-icon-data-analysis', NULL, 4, 1, 1),
(5, '系统管理', 0, 1, '/system', NULL, 'el-icon-setting', NULL, 5, 1, 1),
-- 二级菜单
(10, '题库列表', 1, 2, '/question/bank', 'question/bank/index', NULL, 'QUESTION_MANAGE', 1, 1, 1),
(11, '题目列表', 1, 2, '/question/list', 'question/list/index', NULL, 'QUESTION_MANAGE', 2, 1, 1),
(12, '知识点管理', 1, 2, '/question/knowledge', 'question/knowledge/index', NULL, 'QUESTION_MANAGE', 3, 1, 1),
(20, '试卷列表', 2, 2, '/paper/list', 'paper/list/index', NULL, 'PAPER_MANAGE', 1, 1, 1),
(21, '创建试卷', 2, 2, '/paper/create', 'paper/create/index', NULL, 'PAPER_CREATE', 2, 1, 1),
(30, '考试列表', 3, 2, '/exam/list', 'exam/list/index', NULL, 'EXAM_MANAGE', 1, 1, 1),
(31, '考试监控', 3, 2, '/exam/monitor', 'exam/monitor/index', NULL, 'EXAM_MONITOR', 2, 1, 1),
(32, '试卷批改', 3, 2, '/exam/grade', 'exam/grade/index', NULL, 'EXAM_GRADE', 3, 1, 1),
(40, '成绩统计', 4, 2, '/score/statistics', 'score/statistics/index', NULL, 'EXAM_MANAGE', 1, 1, 1),
(41, '我的成绩', 4, 2, '/score/my', 'score/my/index', NULL, 'SCORE_VIEW', 2, 1, 1),
(50, '用户管理', 5, 2, '/system/user', 'system/user/index', NULL, 'USER_MANAGE', 1, 1, 1),
(51, '角色管理', 5, 2, '/system/role', 'system/role/index', NULL, 'ROLE_MANAGE', 2, 1, 1),
(52, '组织管理', 5, 2, '/system/org', 'system/org/index', NULL, 'ORG_MANAGE', 3, 1, 1);

-- 7. 初始化示例知识点
INSERT INTO `knowledge_point` (`knowledge_id`, `knowledge_name`, `parent_id`, `level`, `org_id`, `sort`) VALUES
(1, '计算机基础', 0, 1, 1, 1),
(2, '硬件知识', 1, 2, 1, 1),
(3, 'CPU', 2, 3, 1, 1),
(4, '内存', 2, 3, 1, 2),
(5, '软件知识', 1, 2, 1, 2),
(6, '操作系统', 5, 3, 1, 1),
(7, '应用软件', 5, 3, 1, 2);

-- 8. 初始化示例题库
INSERT INTO `question_bank` (`bank_id`, `bank_name`, `description`, `bank_type`, `org_id`, `sort`) VALUES
(1, '计算机基础题库', '包含计算机基础知识相关题目', 'PUBLIC', 1, 1),
(2, '数学题库', '包含数学相关题目', 'PUBLIC', 1, 2);

-- ============================================================
-- 索引优化建议（针对高频查询）
-- ============================================================

-- 组卷查询优化索引
CREATE INDEX `idx_question_for_paper` ON `question`
  (`bank_id`, `question_type`, `difficulty`, `audit_status`, `deleted`);

-- 考试会话查询优化索引
CREATE INDEX `idx_session_exam_status` ON `exam_session`
  (`exam_id`, `session_status`, `submit_time`);

-- 答题记录查询优化索引
CREATE INDEX `idx_answer_session_question` ON `exam_answer`
  (`session_id`, `question_id`, `deleted`);

-- 成绩统计查询优化索引
CREATE INDEX `idx_session_score` ON `exam_session`
  (`exam_id`, `session_status`, `total_score`);

-- ============================================================
-- 可选：外键约束（默认禁用）
-- ============================================================
--
-- 如果您的项目规模较小（日活<1000），可以启用外键约束
-- 取消以下注释即可添加外键约束
--
-- 注意：启用外键会影响性能，请根据实际情况评估
-- ============================================================

/*
-- 用户表外键
ALTER TABLE `sys_user`
  ADD CONSTRAINT `fk_user_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`),
  ADD CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`);

-- 角色权限关联表外键
ALTER TABLE `sys_role_permission`
  ADD CONSTRAINT `fk_role_perm_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_role_perm_perm` FOREIGN KEY (`perm_id`) REFERENCES `sys_permission` (`perm_id`) ON DELETE CASCADE;

-- 知识点外键（自关联）
ALTER TABLE `knowledge_point`
  ADD CONSTRAINT `fk_knowledge_parent` FOREIGN KEY (`parent_id`) REFERENCES `knowledge_point` (`knowledge_id`),
  ADD CONSTRAINT `fk_knowledge_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`);

-- 题库表外键
ALTER TABLE `question_bank`
  ADD CONSTRAINT `fk_bank_user` FOREIGN KEY (`create_user_id`) REFERENCES `sys_user` (`user_id`),
  ADD CONSTRAINT `fk_bank_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`);

-- 题目表外键
ALTER TABLE `question`
  ADD CONSTRAINT `fk_question_bank` FOREIGN KEY (`bank_id`) REFERENCES `question_bank` (`bank_id`),
  ADD CONSTRAINT `fk_question_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`),
  ADD CONSTRAINT `fk_question_user` FOREIGN KEY (`create_user_id`) REFERENCES `sys_user` (`user_id`),
  ADD CONSTRAINT `fk_question_auditor` FOREIGN KEY (`auditor_id`) REFERENCES `sys_user` (`user_id`);

-- 选项表外键
ALTER TABLE `question_option`
  ADD CONSTRAINT `fk_option_question` FOREIGN KEY (`question_id`) REFERENCES `question` (`question_id`) ON DELETE CASCADE;

-- 题目标签表外键
ALTER TABLE `question_tag`
  ADD CONSTRAINT `fk_tag_question` FOREIGN KEY (`question_id`) REFERENCES `question` (`question_id`) ON DELETE CASCADE;

-- 试卷表外键
ALTER TABLE `paper`
  ADD CONSTRAINT `fk_paper_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`),
  ADD CONSTRAINT `fk_paper_user` FOREIGN KEY (`create_user_id`) REFERENCES `sys_user` (`user_id`),
  ADD CONSTRAINT `fk_paper_auditor` FOREIGN KEY (`auditor_id`) REFERENCES `sys_user` (`user_id`),
  ADD CONSTRAINT `fk_paper_parent` FOREIGN KEY (`parent_paper_id`) REFERENCES `paper` (`paper_id`);

-- 试卷题目关联表外键
ALTER TABLE `paper_question`
  ADD CONSTRAINT `fk_paper_q_paper` FOREIGN KEY (`paper_id`) REFERENCES `paper` (`paper_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_paper_q_question` FOREIGN KEY (`question_id`) REFERENCES `question` (`question_id`),
  ADD CONSTRAINT `fk_paper_q_rule` FOREIGN KEY (`rule_id`) REFERENCES `paper_rule` (`rule_id`);

-- 组卷规则表外键
ALTER TABLE `paper_rule`
  ADD CONSTRAINT `fk_rule_paper` FOREIGN KEY (`paper_id`) REFERENCES `paper` (`paper_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rule_bank` FOREIGN KEY (`bank_id`) REFERENCES `question_bank` (`bank_id`);

-- 考试表外键
ALTER TABLE `exam`
  ADD CONSTRAINT `fk_exam_paper` FOREIGN KEY (`paper_id`) REFERENCES `paper` (`paper_id`),
  ADD CONSTRAINT `fk_exam_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`),
  ADD CONSTRAINT `fk_exam_user` FOREIGN KEY (`create_user_id`) REFERENCES `sys_user` (`user_id`);

-- 考试考生关联表外键
ALTER TABLE `exam_user`
  ADD CONSTRAINT `fk_exam_user_exam` FOREIGN KEY (`exam_id`) REFERENCES `exam` (`exam_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_exam_user_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`);

-- 考试会话表外键
ALTER TABLE `exam_session`
  ADD CONSTRAINT `fk_session_exam` FOREIGN KEY (`exam_id`) REFERENCES `exam` (`exam_id`),
  ADD CONSTRAINT `fk_session_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`);

-- 答题记录表外键
ALTER TABLE `exam_answer`
  ADD CONSTRAINT `fk_answer_session` FOREIGN KEY (`session_id`) REFERENCES `exam_session` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_answer_exam` FOREIGN KEY (`exam_id`) REFERENCES `exam` (`exam_id`),
  ADD CONSTRAINT `fk_answer_question` FOREIGN KEY (`question_id`) REFERENCES `question` (`question_id`),
  ADD CONSTRAINT `fk_answer_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`),
  ADD CONSTRAINT `fk_answer_grader` FOREIGN KEY (`graded_by`) REFERENCES `sys_user` (`user_id`);

-- 操作日志表外键
ALTER TABLE `sys_operation_log`
  ADD CONSTRAINT `fk_log_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`);
*/

-- ============================================================
-- 数据完整性校验脚本（推荐定期执行）
-- ============================================================
--
-- 由于不使用物理外键，建议定期运行以下脚本检查数据一致性
-- 可以通过定时任务（如每天凌晨）自动执行
-- ============================================================

-- 1. 检查孤儿数据：用户表中引用了不存在的组织或角色
-- SELECT user_id, username, org_id FROM sys_user WHERE org_id NOT IN (SELECT org_id FROM sys_organization);
-- SELECT user_id, username, role_id FROM sys_user WHERE role_id NOT IN (SELECT role_id FROM sys_role);

-- 2. 检查孤儿数据：题目表中引用了不存在的题库
-- SELECT question_id, question_content FROM question WHERE bank_id NOT IN (SELECT bank_id FROM question_bank);

-- 3. 检查孤儿数据：选项表中引用了不存在的题目
-- SELECT option_id, question_id FROM question_option WHERE question_id NOT IN (SELECT question_id FROM question);

-- 4. 检查孤儿数据：试卷题目关联表中引用了不存在的试卷或题目
-- SELECT id, paper_id, question_id FROM paper_question WHERE paper_id NOT IN (SELECT paper_id FROM paper);
-- SELECT id, paper_id, question_id FROM paper_question WHERE question_id NOT IN (SELECT question_id FROM question);

-- 5. 检查孤儿数据：考试表中引用了不存在的试卷
-- SELECT exam_id, exam_name, paper_id FROM exam WHERE paper_id NOT IN (SELECT paper_id FROM paper);

-- 6. 检查孤儿数据：答题记录中引用了不存在的会话或题目
-- SELECT answer_id, session_id FROM exam_answer WHERE session_id NOT IN (SELECT session_id FROM exam_session);
-- SELECT answer_id, question_id FROM exam_answer WHERE question_id NOT IN (SELECT question_id FROM question);

-- 7. 统计各表数据量（用于监控）
-- SELECT
--   'sys_user' AS table_name, COUNT(*) AS total_count FROM sys_user
-- UNION ALL SELECT 'question', COUNT(*) FROM question
-- UNION ALL SELECT 'question_option', COUNT(*) FROM question_option
-- UNION ALL SELECT 'paper', COUNT(*) FROM paper
-- UNION ALL SELECT 'exam', COUNT(*) FROM exam
-- UNION ALL SELECT 'exam_session', COUNT(*) FROM exam_session
-- UNION ALL SELECT 'exam_answer', COUNT(*) FROM exam_answer;

-- ============================================================
-- 数据完整性保证：Service层实现建议
-- ============================================================
--
-- 在应用层（Java Service）中实现数据完整性检查：
--
-- 示例1：删除题库前检查是否有题目
-- public boolean deleteQuestionBank(Long bankId) {
--     long questionCount = questionMapper.countByBankId(bankId);
--     if (questionCount > 0) {
--         throw new BusinessException("该题库下还有题目，无法删除");
--     }
--     return questionBankMapper.deleteById(bankId) > 0;
-- }
--
-- 示例2：删除题目前检查是否已被组卷
-- public boolean deleteQuestion(Long questionId) {
--     long paperCount = paperQuestionMapper.countByQuestionId(questionId);
--     if (paperCount > 0) {
--         throw new BusinessException("该题目已被组卷，无法删除，只能禁用");
--     }
--     return questionMapper.deleteById(questionId) > 0;
-- }
--
-- 示例3：创建考试时检查试卷是否存在且已审核
-- public boolean createExam(ExamDTO dto) {
--     Paper paper = paperMapper.selectById(dto.getPaperId());
--     if (paper == null) {
--         throw new BusinessException("试卷不存在");
--     }
--     if (paper.getAuditStatus() != 2) {
--         throw new BusinessException("试卷未通过审核，无法创建考试");
--     }
--     // 继续创建考试...
-- }
--
-- 示例4：事务控制，确保级联操作的原子性
-- @Transactional(rollbackFor = Exception.class)
-- public boolean deletePaper(Long paperId) {
--     // 删除试卷关联的题目
--     paperQuestionMapper.deleteByPaperId(paperId);
--     // 删除试卷关联的规则
--     paperRuleMapper.deleteByPaperId(paperId);
--     // 删除试卷
--     return paperMapper.deleteById(paperId) > 0;
-- }
--
-- ============================================================

-- ============================================================
-- 结束
-- ============================================================

SET FOREIGN_KEY_CHECKS = 1;

-- 完成提示
SELECT '========================================' AS '';
SELECT 'Database exam_system created successfully!' AS 'STATUS';
SELECT '========================================' AS '';
SELECT 'Default admin account: admin / Admin@123' AS 'NOTICE';
SELECT 'Please change the default password after first login!' AS 'WARNING';
SELECT '========================================' AS '';
SELECT 'Foreign key constraints: DISABLED (for performance)' AS 'INFO';
SELECT 'Data integrity: Application layer control (recommended)' AS 'INFO';
SELECT 'See script comments for how to enable foreign keys' AS 'INFO';
SELECT '========================================' AS '';

