/*
 Navicat Premium Dump SQL

 Source Server         : root'@'localhost
 Source Server Type    : MySQL
 Source Server Version : 80404 (8.4.4)
 Source Host           : localhost:3306
 Source Schema         : exam_system

 Target Server Type    : MySQL
 Target Server Version : 80404 (8.4.4)
 File Encoding         : 65001

 Date: 26/12/2025 01:09:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for exam
-- ----------------------------
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam`  (
  `exam_id` bigint NOT NULL AUTO_INCREMENT COMMENT '考试ID',
  `subject_id` bigint NULL DEFAULT NULL COMMENT '所属科目ID',
  `exam_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '考试名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '考试描述',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '考试封面图片',
  `paper_id` bigint NOT NULL COMMENT '试卷ID',
  `start_time` datetime NOT NULL COMMENT '考试开始时间',
  `end_time` datetime NOT NULL COMMENT '考试结束时间',
  `duration` int NOT NULL COMMENT '考试时长（分钟）',
  `exam_range_type` tinyint NULL DEFAULT 1 COMMENT '考试范围类型：1-指定考生，2-指定班级，3-指定组织',
  `exam_range_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '考试范围ID列表（JSON数组）',
  `exam_status` tinyint NULL DEFAULT 0 COMMENT '考试状态：0-草稿，1-待发布，2-已发布，3-进行中，4-已结束，5-已取消',
  `cut_screen_limit` tinyint NULL DEFAULT 3 COMMENT '允许切屏次数（0-5）',
  `cut_screen_timer` tinyint NULL DEFAULT 1 COMMENT '切屏时长是否计入考试时间：0-不计入，1-计入',
  `forbid_copy` tinyint NULL DEFAULT 1 COMMENT '禁止复制粘贴：0-允许，1-禁止',
  `single_device` tinyint NULL DEFAULT 1 COMMENT '单设备登录：0-允许多设备，1-仅允许单设备',
  `shuffle_questions` tinyint NULL DEFAULT 0 COMMENT '是否乱序题目：0-否，1-是',
  `shuffle_options` tinyint NULL DEFAULT 0 COMMENT '是否乱序选项：0-否，1-是',
  `anti_plagiarism` tinyint NULL DEFAULT 0 COMMENT '主观题防抄袭：0-关闭，1-开启',
  `plagiarism_threshold` tinyint NULL DEFAULT 80 COMMENT '相似度阈值（0-100）',
  `remind_time` tinyint NULL DEFAULT 15 COMMENT '考前提醒时间（分钟，0-60）',
  `show_score_immediately` tinyint NULL DEFAULT 1 COMMENT '交卷后是否立即显示成绩：0-否，1-是',
  `org_id` bigint NOT NULL DEFAULT 1 COMMENT '组织ID（数据隔离）',
  `create_user_id` bigint NOT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`exam_id`) USING BTREE,
  INDEX `idx_paper_id`(`paper_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_exam_status`(`exam_status` ASC) USING BTREE,
  INDEX `idx_time_range`(`start_time` ASC, `end_time` ASC) USING BTREE,
  INDEX `idx_create_user_id`(`create_user_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考试表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam
-- ----------------------------
INSERT INTO `exam` VALUES (1, 1, '53w5', 'w5', NULL, 1, '2025-12-23 00:00:00', '2025-12-23 02:12:43', 133, 1, NULL, 4, 3, 1, 1, 1, 0, 0, 0, 80, 15, 1, 1, 1, '2025-12-23 00:20:02', '2025-12-24 01:55:45', 1);
INSERT INTO `exam` VALUES (2, 1, 'test', 'tqwet', NULL, 1, '2025-12-25 00:00:00', '2025-12-25 04:06:00', 246, 1, NULL, 1, 3, 1, 1, 1, 0, 0, 0, 80, 15, 1, 1, 1, '2025-12-25 00:35:38', '2025-12-25 00:39:35', 0);
INSERT INTO `exam` VALUES (3, 1, 'test', '', '', 1, '2025-12-25 00:00:00', '2025-12-25 02:55:05', 175, 1, '', 1, 3, 1, 1, 1, 1, 1, 1, 80, 15, 1, 1, 1, '2025-12-25 00:56:01', '2025-12-25 00:56:01', 0);

-- ----------------------------
-- Table structure for exam_answer
-- ----------------------------
DROP TABLE IF EXISTS `exam_answer`;
CREATE TABLE `exam_answer`  (
  `answer_id` bigint NOT NULL AUTO_INCREMENT COMMENT '答案ID',
  `session_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `bank_id` bigint NULL DEFAULT NULL COMMENT '题库ID(统计分析用)',
  `user_id` bigint NOT NULL COMMENT '考生ID',
  `option_ids` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '选择的选项ID（用逗号分隔，客观题用）',
  `user_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '考生答案（主观题、填空题用）',
  `answer_order` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '排序题答案（选项ID按顺序，用逗号分隔）',
  `score` decimal(5, 2) NULL DEFAULT NULL COMMENT '该题得分',
  `is_correct` tinyint NULL DEFAULT NULL COMMENT '是否正确：0-错误，1-正确，NULL-未批改',
  `is_marked` tinyint NULL DEFAULT 0 COMMENT '是否标记（答题时考生标记的不确定题目）',
  `graded_by` bigint NULL DEFAULT NULL COMMENT '批改人ID',
  `grade_time` datetime NULL DEFAULT NULL COMMENT '批改时间',
  `teacher_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '教师评语（限200字）',
  `answer_time` datetime NULL DEFAULT NULL COMMENT '答题时间',
  `time_spent` int NULL DEFAULT NULL COMMENT '答题耗时（秒）',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`answer_id`) USING BTREE,
  INDEX `idx_session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_exam_question`(`exam_id` ASC, `question_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_correct`(`is_correct` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_answer_session_question`(`session_id` ASC, `question_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_bank_id`(`bank_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '答题记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_answer
-- ----------------------------

-- ----------------------------
-- Table structure for exam_session
-- ----------------------------
DROP TABLE IF EXISTS `exam_session`;
CREATE TABLE `exam_session`  (
  `session_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话ID（UUID）',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `user_id` bigint NOT NULL COMMENT '考生ID',
  `attempt_number` int NULL DEFAULT 1 COMMENT '第几次考试（补考用）',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `duration` int NULL DEFAULT NULL COMMENT '实际用时（分钟）',
  `session_status` tinyint NULL DEFAULT 1 COMMENT '场次状态：1-进行中，2-已提交，3-已批改，4-已终止，5-超时提交，6-异常终止',
  `total_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '总得分',
  `objective_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '客观题得分',
  `subjective_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '主观题得分',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `device_info` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备信息',
  `tab_switch_count` int NULL DEFAULT 0 COMMENT '切屏次数',
  `tab_switch_records` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '切屏记录（JSON数组）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`session_id`) USING BTREE,
  INDEX `idx_exam_user`(`exam_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_session_status`(`session_status` ASC) USING BTREE,
  INDEX `idx_submit_time`(`submit_time` ASC) USING BTREE,
  INDEX `idx_session_exam_status`(`exam_id` ASC, `session_status` ASC, `submit_time` ASC) USING BTREE,
  INDEX `idx_session_score`(`exam_id` ASC, `session_status` ASC, `total_score` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考试会话表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_session
-- ----------------------------

-- ----------------------------
-- Table structure for exam_user
-- ----------------------------
DROP TABLE IF EXISTS `exam_user`;
CREATE TABLE `exam_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `user_id` bigint NOT NULL COMMENT '考生ID',
  `exam_status` tinyint NULL DEFAULT 0 COMMENT '考试状态：0-未参考，1-参考中，2-已提交，3-缺考',
  `reexam_count` int NULL DEFAULT 0 COMMENT '已补考次数',
  `final_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '最终成绩',
  `pass_status` tinyint NULL DEFAULT NULL COMMENT '及格状态：0-不及格，1-及格',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_exam_user`(`exam_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_exam_id`(`exam_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_exam_status`(`exam_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考试考���关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_user
-- ----------------------------

-- ----------------------------
-- Table structure for knowledge_point
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_point`;
CREATE TABLE `knowledge_point`  (
  `knowledge_id` bigint NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
  `subject_id` bigint NULL DEFAULT NULL COMMENT '所属科目ID',
  `knowledge_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识点名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父知识点ID（0为顶级）',
  `level` tinyint NOT NULL COMMENT '层级：1-一级，2-二级，3-三级',
  `org_id` bigint NOT NULL COMMENT '组织ID（数据隔离）',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '知识点描述',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`knowledge_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_level`(`level` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 178 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '知识点分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_point
-- ----------------------------
INSERT INTO `knowledge_point` VALUES (1, 6, '计算机基础', 0, 1, 1, NULL, 1, '2025-11-06 11:08:34', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (161, 6, 'Java基础', NULL, 1, 1, 'Java编程语言基础', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (162, 6, '面向对象', 1, 2, 1, '封装、继承、多态', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (163, 6, '集合框架', 1, 2, 1, 'List、Set、Map等集合', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (164, 6, '异常处理', 1, 2, 1, '异常机制与处理', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (165, 6, '多线程', 1, 2, 1, '线程、并发、同步', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (166, 6, '数据库', NULL, 1, 1, '数据库相关知识', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (167, 6, 'SQL语句', 6, 2, 1, 'SELECT、INSERT、UPDATE、DELETE', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (168, 6, '索引优化', 6, 2, 1, '索引类型与优化策略', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (169, 6, '事务管理', 6, 2, 1, 'ACID特性与事务隔离级别', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (170, 6, 'Spring框架', NULL, 1, 1, 'Spring生态体系', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (171, 6, 'IOC容器', 10, 2, 1, '依赖注入与控制反转', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (172, 6, 'AOP编程', 10, 2, 1, '面向切面编程', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (173, 6, 'Spring MVC', 10, 2, 1, 'Web MVC框架', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (174, 6, '算法', NULL, 1, 1, '算法与数据结构', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (175, 6, '排序算法', 14, 2, 1, '冒泡、快排、归并等', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (176, 6, '查找算法', 14, 2, 1, '二分查找、哈希查找', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `knowledge_point` VALUES (177, 6, '动态规划', 14, 2, 1, 'DP算法思想', 0, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);

-- ----------------------------
-- Table structure for paper
-- ----------------------------
DROP TABLE IF EXISTS `paper`;
CREATE TABLE `paper`  (
  `paper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
  `subject_id` bigint NULL DEFAULT NULL COMMENT '所属科目ID',
  `paper_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '试卷名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '试卷描述',
  `paper_type` tinyint NOT NULL COMMENT '组卷方式：1-手动组卷，2-自动组卷，3-随机组卷',
  `total_score` decimal(5, 2) NOT NULL DEFAULT 100.00 COMMENT '试卷总分',
  `pass_score` decimal(5, 2) NOT NULL DEFAULT 60.00 COMMENT '及格分',
  `org_id` bigint NOT NULL DEFAULT 1 COMMENT '组织ID（数据隔离）',
  `create_user_id` bigint NOT NULL COMMENT '创建人ID',
  `audit_status` tinyint NULL DEFAULT 0 COMMENT '审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝',
  `audit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `auditor_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `publish_status` tinyint NULL DEFAULT 0 COMMENT '发布状态：0-未发布，1-已发布，2-已过期',
  `publish_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `allow_view_analysis` tinyint NULL DEFAULT 0 COMMENT '允许查看错题解析：0-否，1-是',
  `allow_reexam` tinyint NULL DEFAULT 0 COMMENT '允许补考：0-否，1-是',
  `reexam_limit` int NULL DEFAULT 0 COMMENT '补考次数限制（0表示不限）',
  `valid_days` int NULL DEFAULT 30 COMMENT '发布后有效天数',
  `version` int NULL DEFAULT 1 COMMENT '试卷版本号',
  `parent_paper_id` bigint NULL DEFAULT NULL COMMENT '父试卷ID（版本管理用）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `bank_id` bigint NULL DEFAULT NULL COMMENT '题库id',
  PRIMARY KEY (`paper_id`) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_create_user_id`(`create_user_id` ASC) USING BTREE,
  INDEX `idx_audit_status`(`audit_status` ASC) USING BTREE,
  INDEX `idx_publish_status`(`publish_status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '试卷表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paper
-- ----------------------------
INSERT INTO `paper` VALUES (1, 6, 'Java基础综合测试卷', 'Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题', 1, 0.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 23:48:08', 0, 1);
INSERT INTO `paper` VALUES (2, 6, '数据库原理期中考试', 'MySQL数据库原理期中考试试卷', 1, 72.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 23:48:08', 0, 53);
INSERT INTO `paper` VALUES (3, 6, 'Spring框架快速测试', 'Spring框架知识点快速测试', 2, 100.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 23:48:09', 0, 52);
INSERT INTO `paper` VALUES (4, 6, '综合能力测试卷', 'Java、数据库、Spring综合能力测试', 1, 30.00, 70.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 23:48:11', 0, 55);
INSERT INTO `paper` VALUES (5, 6, 'Java基础综合测试卷', 'test', 1, 10.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-24 01:17:59', 1, NULL);
INSERT INTO `paper` VALUES (9, 6, 'testExam', 'test', 1, 10.00, 60.00, 1, 1, 0, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 04:10:38', 1, NULL);
INSERT INTO `paper` VALUES (10, NULL, 'Java基础综合测试卷', '', 3, 0.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-24 01:18:05', 1, NULL);
INSERT INTO `paper` VALUES (11, NULL, 'test', '', 1, 111.00, 60.00, 1, 1, 2, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 30, 1, NULL, '2025-11-07 11:15:32', '2025-12-22 23:48:08', 0, 1);

-- ----------------------------
-- Table structure for paper_question
-- ----------------------------
DROP TABLE IF EXISTS `paper_question`;
CREATE TABLE `paper_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `paper_id` bigint NOT NULL COMMENT '试卷ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `bank_id` bigint NULL DEFAULT NULL COMMENT '题库ID(记录题目来源)',
  `question_score` decimal(5, 2) NOT NULL COMMENT '该题在试卷中的分值',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '题目顺序',
  `rule_id` bigint NULL DEFAULT NULL COMMENT '关联组卷规则ID（随机组卷用）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_paper_question`(`paper_id` ASC, `question_id` ASC) USING BTREE,
  INDEX `idx_paper_id`(`paper_id` ASC) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE,
  INDEX `idx_sort_order`(`paper_id` ASC, `sort_order` ASC) USING BTREE,
  INDEX `idx_rule_id`(`rule_id` ASC) USING BTREE,
  INDEX `idx_bank_id`(`bank_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 103 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '试卷题目关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paper_question
-- ----------------------------
INSERT INTO `paper_question` VALUES (63, 1, 268, 1, 5.00, 1, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (64, 1, 234, 1, 3.00, 2, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (65, 1, 235, 53, 2.00, 3, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (66, 1, 236, 53, 2.00, 4, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (67, 1, 237, 53, 4.00, 5, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (68, 1, 238, 53, 3.00, 6, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (69, 1, 239, 53, 4.00, 7, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (70, 1, 240, 53, 4.00, 8, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (71, 1, 241, 53, 5.00, 9, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (72, 1, 242, 53, 2.00, 10, NULL, '2025-12-22 17:10:50');
INSERT INTO `paper_question` VALUES (73, 2, 239, 53, 4.00, 1, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (74, 2, 268, 1, 5.00, 2, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (75, 2, 234, 1, 3.00, 3, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (76, 2, 235, 53, 2.00, 4, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (77, 2, 236, 53, 2.00, 5, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (78, 2, 237, 53, 4.00, 6, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (79, 2, 238, 53, 3.00, 7, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (80, 2, 240, 53, 4.00, 8, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (81, 2, 241, 53, 5.00, 9, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (82, 2, 242, 53, 2.00, 10, NULL, '2025-12-22 17:42:21');
INSERT INTO `paper_question` VALUES (83, 11, 268, 58, 5.00, 1, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (84, 11, 234, 58, 3.00, 2, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (85, 11, 235, 58, 2.00, 3, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (86, 11, 236, 58, 2.00, 4, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (87, 11, 237, 58, 4.00, 5, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (88, 11, 238, 58, 3.00, 6, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (89, 11, 239, 58, 4.00, 7, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (90, 11, 240, 58, 4.00, 8, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (91, 11, 241, 58, 5.00, 9, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (92, 11, 242, 58, 2.00, 10, NULL, '2025-12-24 01:59:18');
INSERT INTO `paper_question` VALUES (93, 11, 243, 58, 2.00, 11, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (94, 11, 244, 58, 4.00, 12, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (95, 11, 245, 58, 4.00, 13, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (96, 11, 246, 58, 10.00, 14, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (97, 11, 247, 58, 10.00, 15, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (98, 11, 248, 58, 2.00, 16, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (99, 11, 249, 58, 2.00, 17, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (100, 11, 250, 58, 3.00, 18, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (101, 11, 251, 58, 3.00, 19, NULL, '2025-12-24 01:59:30');
INSERT INTO `paper_question` VALUES (102, 11, 252, 58, 3.00, 20, NULL, '2025-12-24 01:59:30');

-- ----------------------------
-- Table structure for paper_rule
-- ----------------------------
DROP TABLE IF EXISTS `paper_rule`;
CREATE TABLE `paper_rule`  (
  `rule_id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `paper_id` bigint NOT NULL COMMENT '试卷ID',
  `bank_id` bigint NULL DEFAULT NULL COMMENT '题库ID（从哪个题库抽题）',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '题库名称(冗余字段)',
  `question_type` tinyint NOT NULL COMMENT '题型',
  `total_num` int NOT NULL COMMENT '该题型总题量',
  `easy_num` int NULL DEFAULT 0 COMMENT '简单题数量',
  `medium_num` int NULL DEFAULT 0 COMMENT '中等题数量',
  `hard_num` int NULL DEFAULT 0 COMMENT '困难题数量',
  `single_score` decimal(5, 2) NOT NULL COMMENT '每题分值',
  `knowledge_ids` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '指定知识点ID列表（逗号分隔，为空则不限）',
  `sort_order` int NULL DEFAULT 0 COMMENT '题型顺序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`rule_id`) USING BTREE,
  INDEX `idx_paper_id`(`paper_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组卷规则表（随机组卷用）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paper_rule
-- ----------------------------

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `question_id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `subject_id` bigint NULL DEFAULT NULL COMMENT '所属科目ID',
  `bank_id` bigint NOT NULL COMMENT '题库ID',
  `org_id` bigint NOT NULL DEFAULT 1 COMMENT '组织ID（数据隔离）',
  `question_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题目内容（富文本，支持图片/公式）',
  `question_type` tinyint NOT NULL COMMENT '题型：1-单选,2-多选,3-不定项,4-判断,5-匹配,6-排序,7-填空,8-主观',
  `default_score` decimal(5, 2) NULL DEFAULT 2.00 COMMENT '默认分值',
  `difficulty` tinyint NOT NULL DEFAULT 2 COMMENT '难度：1-简单,2-中等,3-困难',
  `knowledge_ids` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '知识点ID列表（逗号分隔，最多3个）',
  `answer_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '填空题答案（格式：空1答案1,空1答案2|空2答案1）',
  `reference_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '主观题参考答案',
  `score_rule` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主观题评分标准',
  `answer_analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '答案解析',
  `question_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '题目图片URL',
  `use_count` int NULL DEFAULT 0 COMMENT '被组卷使用次数',
  `correct_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '历史正确率（百分比）',
  `audit_status` tinyint NULL DEFAULT 0 COMMENT '审核状态：0-草稿，1-待审核，2-已通过，3-已拒绝',
  `audit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `auditor_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `create_user_id` bigint NOT NULL COMMENT '创建人ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`question_id`) USING BTREE,
  INDEX `idx_bank_id`(`bank_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_question_type`(`question_type` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty` ASC) USING BTREE,
  INDEX `idx_audit_status`(`audit_status` ASC) USING BTREE,
  INDEX `idx_create_user_id`(`create_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_composite`(`bank_id` ASC, `question_type` ASC, `difficulty` ASC, `audit_status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_question_for_paper`(`bank_id` ASC, `question_type` ASC, `difficulty` ASC, `audit_status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_bank_type_diff_audit`(`bank_id` ASC, `question_type` ASC, `difficulty` ASC, `audit_status` ASC, `status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 270 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '题目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question
-- ----------------------------
INSERT INTO `question` VALUES (1, 6, 1, 1, '下列哪个关键字用于定义Java类？', 1, 2.00, 1, '1,2', NULL, NULL, NULL, '正确答案是class。class是Java中定义类的关键字。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:06:12', '2025-12-20 15:30:37', 1);
INSERT INTO `question` VALUES (234, 6, 58, 1, '下列哪个关键字用于定义Java类？', 1, 3.00, 2, '', NULL, NULL, NULL, '正确答案是class。class是Java中定义类的关键字。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-22 01:25:45', 0);
INSERT INTO `question` VALUES (235, 6, 58, 1, 'Java中的String类是否可以被继承？', 4, 2.00, 2, '', NULL, NULL, NULL, '正确答案是不能。String类被final修饰，无法被继承。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-22 04:00:24', 0);
INSERT INTO `question` VALUES (236, 6, 58, 1, '下列哪个不是Java的访问修饰符？', 1, 2.00, 1, '1,2', NULL, NULL, NULL, '正确答案是friendly。Java中的访问修饰符有public、protected、private和默认(包访问权限)。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (237, 6, 58, 1, 'Java中equals()和==的区别是什么？', 1, 4.00, 2, '', NULL, NULL, NULL, '==比较的是对象的引用地址，equals()比较的是对象的内容。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (238, 6, 58, 1, '以下哪个集合类是线程安全的？', 1, 3.00, 3, '', NULL, NULL, NULL, '正确答案是Vector。Vector是线程安全的，而ArrayList不是。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (239, 6, 58, 1, 'Java中面向对象的三大特性包括哪些？', 2, 4.00, 2, '', NULL, NULL, NULL, '面向对象的三大特性是：封装、继承、多态。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-23 21:22:19', 0);
INSERT INTO `question` VALUES (240, 6, 58, 1, '下列哪些是Java中的基本数据类型？', 2, 4.00, 2, '', NULL, NULL, NULL, 'Java的8种基本数据类型：byte、short、int、long、float、double、char、boolean。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:15', 0);
INSERT INTO `question` VALUES (241, 6, 58, 1, 'Java异常处理中，下列哪些是正确的？', 2, 5.00, 2, '1,4', NULL, NULL, NULL, 'try块必须配合catch或finally使用；finally块一定会执行（除非JVM退出）。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (242, 6, 58, 1, 'Java是纯面向对象的编程语言。', 4, 2.00, 1, '1,2', NULL, NULL, NULL, '错误。Java不是纯面向对象语言，因为它包含8种基本数据类型，它们不是对象。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (243, 6, 58, 1, 'Java中的方法可以重载(overload)也可以重写(override)。', 4, 2.00, 2, '1,2', NULL, NULL, NULL, '正确。重载发生在同一个类中，重写发生在父类和子类之间。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (244, 6, 58, 1, 'Java中，_____关键字用于继承父类，_____关键字用于实现接口。', 7, 4.00, 1, '1,2', 'extends|implements', NULL, NULL, '第一空：extends，第二空：implements', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (245, 6, 58, 1, 'HashMap的默认初始容量是_____，默认负载因子是_____。', 7, 4.00, 2, '1,3', '16|0.75', NULL, NULL, 'HashMap默认容量为16，负载因子为0.75', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (246, 6, 58, 1, '请简述Java中ArrayList和LinkedList的区别，并说明在什么场景下使用哪种数据结构更合适。', 8, 10.00, 2, '1,3', NULL, 'ArrayList基于动态数组实现，查询快(O(1))，插入删除慢(O(n))；LinkedList基于双向链表实现，插入删除快(O(1))，查询慢(O(n))。使用场景：频繁查询用ArrayList，频繁插入删除用LinkedList。', '答出数据结构差异4分，答出时间复杂度3分，答出使用场景3分', '关键点：底层数据结构、时间复杂度、使用场景', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (247, 6, 58, 1, '请解释Java中的垃圾回收机制(GC)，并说明常见的垃圾回收算法。', 8, 10.00, 3, '1,5', NULL, 'Java的垃圾回收机制自动管理内存，回收不再使用的对象。常见算法：1.标记-清除算法 2.复制算法 3.标记-整理算法 4.分代收集算法。', '答出GC基本概念3分，答出2-3种算法4分，详细说明算法原理3分', '关键点：自动内存管理、可达性分析、GC算法', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (248, 6, 58, 1, '在MySQL中，哪个存储引擎支持事务？', 1, 2.00, 1, '6,9', NULL, NULL, NULL, '正确答案是InnoDB。InnoDB支持事务、外键等特性。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (249, 6, 58, 1, 'SQL语句中，DISTINCT关键字的作用是什么？', 1, 2.00, 1, '6,7', NULL, NULL, NULL, 'DISTINCT用于去除重复的记录。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (250, 6, 58, 1, '数据库的ACID特性中，I代表什么？', 1, 3.00, 2, '', NULL, NULL, NULL, 'I代表Isolation（隔离性），表示并发事务之间相互隔离。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (251, 6, 58, 1, '以下哪种索引类型查询效率最高？', 1, 3.00, 2, '6,8', NULL, NULL, NULL, '主键索引效率最高，因为数据按主键物理排序。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (252, 6, 58, 1, 'MySQL中，LEFT JOIN和RIGHT JOIN的区别是什么？', 1, 3.00, 2, '6,7', NULL, NULL, NULL, 'LEFT JOIN返回左表所有记录和右表匹配记录，RIGHT JOIN相反。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (253, 6, 52, 1, '以下哪些是MySQL支持的数据类型？', 2, 4.00, 2, '', NULL, NULL, NULL, 'MySQL支持INT、VARCHAR、TEXT、DATE、DATETIME等多种数据类型。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:48', 0);
INSERT INTO `question` VALUES (254, 6, 52, 1, '数据库索引的优点包括哪些？', 2, 4.00, 2, '', NULL, NULL, NULL, '索引可以加快查询速度、实现唯一性约束、加速表与表之间的连接。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:43', 0);
INSERT INTO `question` VALUES (255, 6, 1, 1, '数据库的主键可以为NULL值。', 4, 2.00, 1, '6', NULL, NULL, NULL, '错误。主键不能为NULL，必须唯一且非空。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:23', 0);
INSERT INTO `question` VALUES (256, 6, 52, 1, '索引可以提高数据的查询速度，但会降低写入速度。', 4, 2.00, 2, '', NULL, NULL, NULL, '正确。索引需要额外的存储空间和维护成本，影响插入、更新、删除的性能。', NULL, 0, 0.00, 1, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:34', 0);
INSERT INTO `question` VALUES (257, 6, 52, 1, '请解释数据库的三大范式，并举例说明。', 8, 10.00, 2, '', NULL, '第一范式(1NF)：每个字段都是不可分割的原子值。第二范式(2NF)：消除部分依赖，非主键字段完全依赖主键。第三范式(3NF)：消除传递依赖，非主键字段不依赖其他非主键字段。', '每个范式定义正确3分，举例说明1分', '关键点：原子性、完全依赖、消除传递依赖', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:29', 0);
INSERT INTO `question` VALUES (258, 6, 1, 1, 'Spring框架的核心是什么？', 1, 2.00, 1, '10,11', NULL, NULL, NULL, '正确答案是IOC和AOP。IOC(控制反转)和AOP(面向切面编程)是Spring的两大核心。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:20', 0);
INSERT INTO `question` VALUES (259, 6, 52, 1, 'Spring Boot的主要作用是什么？', 1, 2.00, 2, '', NULL, NULL, NULL, 'Spring Boot简化了Spring应用的配置和部署，提供了自动配置功能。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:11:21', 0);
INSERT INTO `question` VALUES (260, 6, 1, 1, '@Autowired注解的作用是什么？', 1, 3.00, 2, '10,11', NULL, NULL, NULL, '@Autowired实现依赖注入，自动装配Bean。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:12', 0);
INSERT INTO `question` VALUES (261, 6, 1, 1, 'Spring中Bean的默认作用域是什么？', 1, 3.00, 2, '10,11', NULL, NULL, NULL, '默认作用域是singleton（单例模式）。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:13', 0);
INSERT INTO `question` VALUES (262, 6, 1, 1, 'Spring Boot的优点包括哪些？', 2, 4.00, 1, '10', NULL, NULL, NULL, 'Spring Boot提供自动配置、内嵌服务器、简化依赖管理、生产就绪特性等。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:14', 0);
INSERT INTO `question` VALUES (263, 6, 1, 1, 'Spring AOP的应用场景包括哪些？', 2, 5.00, 2, '10,12', NULL, NULL, NULL, 'AOP常用于日志记录、事务管理、权限控制、性能监控等场景。', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-24 01:40:19', 0);
INSERT INTO `question` VALUES (264, 6, 53, 1, '请解释Spring IOC的工作原理，并说明依赖注入的三种方式。', 8, 10.00, 2, '', NULL, 'IOC将对象创建和依赖关系的管理交给容器，降低耦合度。三种依赖注入方式：1.构造器注入 2.Setter注入 3.字段注入。推荐使用构造器注入。', '答出IOC原理4分，答出三种注入方式6分', '关键点：控制反转、依赖注入、容器管理', NULL, 0, 0.00, 2, NULL, NULL, NULL, 1, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question` VALUES (268, NULL, 58, 1, 'testtest', 1, 5.00, 2, '', NULL, NULL, NULL, 'test', NULL, 0, NULL, 0, NULL, NULL, NULL, 1, 1, '2025-12-22 03:47:55', '2025-12-23 21:18:41', 0);
INSERT INTO `question` VALUES (269, NULL, 1, 1, '还是热回收', 1, 5.00, 2, '', NULL, NULL, NULL, '我个人', NULL, 0, NULL, 0, NULL, NULL, NULL, 1, 1, '2025-12-25 19:00:32', '2025-12-25 19:00:32', 0);

-- ----------------------------
-- Table structure for question_bank
-- ----------------------------
DROP TABLE IF EXISTS `question_bank`;
CREATE TABLE `question_bank`  (
  `bank_id` bigint NOT NULL AUTO_INCREMENT COMMENT '题库ID',
  `subject_id` bigint NULL DEFAULT NULL COMMENT '所属科目ID',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题库名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '题库描述',
  `bank_type` tinyint NULL DEFAULT NULL COMMENT '题库类型：1-公共题库，2-私有题库',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图片',
  `question_count` int NULL DEFAULT 0 COMMENT '题目数量（统计字段）',
  `create_user_id` bigint NULL DEFAULT NULL COMMENT '创建者ID（私有题库必填）',
  `org_id` bigint NOT NULL DEFAULT 1 COMMENT '组织ID（数据隔离）',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`bank_id`) USING BTREE,
  INDEX `idx_bank_type`(`bank_type` ASC) USING BTREE,
  INDEX `idx_create_user_id`(`create_user_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 59 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '题库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_bank
-- ----------------------------
INSERT INTO `question_bank` VALUES (1, 6, '默认题库', 'Java编程语言基础知识题库，包含语法、面向对象、集合等内容', 1, NULL, 4, 1, 1, 5, 1, '2025-11-07 09:08:07', '2025-12-25 19:24:11', 0);
INSERT INTO `question_bank` VALUES (51, 6, 'Java基础题库', 'Java编程语言基础知识题库，包含语法、面向对象、集合等内容', 1, NULL, 0, 1, 1, 0, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 1);
INSERT INTO `question_bank` VALUES (52, 6, '数据库原理题库', 'MySQL、SQL语句、索引、事务等数据库相关知识', 1, NULL, 0, 1, 1, 0, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question_bank` VALUES (53, 6, 'Spring框架题库', 'Spring Boot、Spring MVC、Spring Cloud等框架知识', 1, NULL, 10, 1, 1, 4, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question_bank` VALUES (54, 6, '算法与数据结构题库', '常见算法、数据结构、时间复杂度等计算机基础', 1, NULL, 0, 1, 1, 0, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question_bank` VALUES (55, 6, '计算机网络题库', 'TCP/IP、HTTP协议、网络安全等网络基础知识', 1, NULL, 0, 1, 1, 0, 1, '2025-11-07 11:15:32', '2025-12-20 15:30:37', 0);
INSERT INTO `question_bank` VALUES (56, 6, 'test', 'test', 1, NULL, 0, 1, 1, 1, 1, '2025-12-21 16:21:30', '2025-12-21 16:32:22', 1);
INSERT INTO `question_bank` VALUES (57, NULL, 'tees他', '斯特', 1, NULL, 0, 1, 1, 0, 1, '2025-12-22 02:55:58', '2025-12-22 02:56:00', 1);
INSERT INTO `question_bank` VALUES (58, NULL, 'test', 'test', 1, NULL, 20, 1, 1, 0, 1, '2025-12-24 01:36:13', '2025-12-24 01:36:13', 0);

-- ----------------------------
-- Table structure for question_option
-- ----------------------------
DROP TABLE IF EXISTS `question_option`;
CREATE TABLE `question_option`  (
  `option_id` bigint NOT NULL AUTO_INCREMENT COMMENT '选项ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `option_seq` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '选项序号（A/B/C/D或1/2/3）',
  `option_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '选项内容',
  `is_correct` tinyint NULL DEFAULT 0 COMMENT '是否正确答案：0-否，1-是（单选/多选/判断题用）',
  `score_ratio` tinyint NULL DEFAULT NULL COMMENT '分值占比（0-100，不定项选择题专用）',
  `option_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NORMAL' COMMENT '选项类型：NORMAL-普通，STEM-题干（匹配题），MATCH-匹配项（匹配题）',
  `assoc_flag` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联标识（匹配题专用，如M1、M2）',
  `correct_order` int NULL DEFAULT NULL COMMENT '正确排序值（排序题专用，如1、2、3）',
  `option_analysis` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '选项解析',
  `option_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '选项图片URL',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`option_id`) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE,
  INDEX `idx_question_correct`(`question_id` ASC, `is_correct` ASC) USING BTREE,
  INDEX `idx_assoc_flag`(`question_id` ASC, `assoc_flag` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 352 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '选项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_option
-- ----------------------------
INSERT INTO `question_option` VALUES (1, 1, 'A', 'class', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:14:22', '2025-11-07 11:14:22', 0);
INSERT INTO `question_option` VALUES (213, 1, 'A', 'class', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (214, 1, 'B', 'Class', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (215, 1, 'C', 'struct', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (216, 1, 'D', 'interface', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (217, 2, 'A', '可以', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (218, 2, 'B', '不能', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (219, 2, 'C', '看情况', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (220, 2, 'D', '需要配置', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (221, 3, 'A', 'public', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (222, 3, 'B', 'protected', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (223, 3, 'C', 'private', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (224, 3, 'D', 'friendly', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (225, 4, 'A', '没有区别', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (226, 4, 'B', '==比较引用，equals比较内容', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (227, 4, 'C', '==比较内容，equals比较引用', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (228, 4, 'D', '都比较引用', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (229, 5, 'A', 'ArrayList', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (230, 5, 'B', 'Vector', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (231, 5, 'C', 'LinkedList', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (232, 5, 'D', 'HashMap', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (233, 6, 'A', '封装', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (234, 6, 'B', '继承', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (235, 6, 'C', '多态', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (236, 6, 'D', '抽象', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (237, 7, 'A', 'int', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (238, 7, 'B', 'long', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (239, 7, 'C', 'String', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (240, 7, 'D', 'boolean', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (241, 7, 'E', 'char', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 5, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (242, 8, 'A', 'try块必须配合catch或finally', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (243, 8, 'B', 'finally块一定会执行', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (244, 8, 'C', 'catch块可以有多个', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (245, 8, 'D', 'try块可以单独使用', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (246, 9, 'A', '正确', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (247, 9, 'B', '错误', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (248, 10, 'A', '正确', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (249, 10, 'B', '错误', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (250, 15, 'A', 'MyISAM', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (251, 15, 'B', 'InnoDB', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (252, 15, 'C', 'Memory', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (253, 15, 'D', 'CSV', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (254, 16, 'A', '排序', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (255, 16, 'B', '去重', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (256, 16, 'C', '分组', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (257, 16, 'D', '过滤', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (258, 17, 'A', 'Atomicity原子性', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (259, 17, 'B', 'Consistency一致性', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (260, 17, 'C', 'Isolation隔离性', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (261, 17, 'D', 'Durability持久性', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (262, 18, 'A', '主键索引', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (263, 18, 'B', '唯一索引', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (264, 18, 'C', '普通索引', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (265, 18, 'D', '全文索引', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (266, 19, 'A', '没有区别', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (267, 19, 'B', 'LEFT JOIN返回左表所有记录', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (268, 19, 'C', 'RIGHT JOIN返回左表所有记录', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (269, 19, 'D', '两者都返回所有记录', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (270, 20, 'A', 'INT', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (271, 20, 'B', 'VARCHAR', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (272, 20, 'C', 'TEXT', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (273, 20, 'D', 'DATE', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (274, 21, 'A', '加快查询速度', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (275, 21, 'B', '实现唯一性约束', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (276, 21, 'C', '加速表连接', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (277, 21, 'D', '减少存储空间', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (278, 22, 'A', '正确', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (279, 22, 'B', '错误', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (280, 23, 'A', '正确', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (281, 23, 'B', '错误', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (282, 25, 'A', 'IOC和AOP', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (283, 25, 'B', 'MVC和ORM', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (284, 25, 'C', 'REST和SOAP', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (285, 25, 'D', 'JPA和Hibernate', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (286, 26, 'A', '简化配置和部署', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (287, 26, 'B', '提高运行速度', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (288, 26, 'C', '增强安全性', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (289, 26, 'D', '优化数据库', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (290, 27, 'A', '创建Bean', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (291, 27, 'B', '依赖注入', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (292, 27, 'C', '配置属性', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (293, 27, 'D', '声明事务', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (294, 28, 'A', 'singleton', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (295, 28, 'B', 'prototype', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (296, 28, 'C', 'request', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (297, 28, 'D', 'session', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (298, 29, 'A', '自动配置', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (299, 29, 'B', '内嵌服务器', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (300, 29, 'C', '简化依赖', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (301, 29, 'D', '生产就绪', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (302, 30, 'A', '日志记录', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (303, 30, 'B', '事务管理', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 2, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (304, 30, 'C', '权限控制', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 3, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (305, 30, 'D', '性能监控', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 4, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);
INSERT INTO `question_option` VALUES (335, 234, 'A', '违法', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 01:25:45', '2025-12-22 01:25:45', 0);
INSERT INTO `question_option` VALUES (336, 235, 'A', 'v', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 02:53:08', '2025-12-22 04:00:24', 1);
INSERT INTO `question_option` VALUES (337, 235, 'B', 'x', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 02:53:08', '2025-12-22 04:00:24', 1);
INSERT INTO `question_option` VALUES (338, 268, 'A', 'test', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 03:47:55', '2025-12-23 21:18:41', 1);
INSERT INTO `question_option` VALUES (339, 268, 'B', 'rwar', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 03:47:55', '2025-12-23 21:18:41', 1);
INSERT INTO `question_option` VALUES (340, 235, 'A', 'x', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 02:53:08', '2025-12-22 02:53:08', 0);
INSERT INTO `question_option` VALUES (341, 268, 'A', 'test', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 03:47:55', '2025-12-22 03:47:55', 0);
INSERT INTO `question_option` VALUES (342, 268, 'B', 'rwar', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-22 03:47:55', '2025-12-22 03:47:55', 0);
INSERT INTO `question_option` VALUES (343, 268, 'C', '34rwae', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:18:41', '2025-12-23 21:18:41', 0);
INSERT INTO `question_option` VALUES (344, 268, 'D', 'asdf', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:18:41', '2025-12-23 21:18:41', 0);
INSERT INTO `question_option` VALUES (345, 268, 'E', 'asdf', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:18:41', '2025-12-23 21:18:41', 0);
INSERT INTO `question_option` VALUES (346, 268, 'F', 'asdf', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:18:41', '2025-12-23 21:18:41', 0);
INSERT INTO `question_option` VALUES (347, 239, 'A', '', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:22:19', '2025-12-23 21:22:19', 0);
INSERT INTO `question_option` VALUES (348, 239, 'B', '', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-23 21:22:19', '2025-12-23 21:22:19', 0);
INSERT INTO `question_option` VALUES (349, 269, 'A', '为如果', 1, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-25 19:00:32', '2025-12-25 19:00:32', 0);
INSERT INTO `question_option` VALUES (350, 269, 'B', '为如果', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-25 19:00:32', '2025-12-25 19:00:32', 0);
INSERT INTO `question_option` VALUES (351, 269, 'C', ' 为如果', 0, NULL, 'NORMAL', NULL, NULL, NULL, NULL, 0, '2025-12-25 19:00:32', '2025-12-25 19:00:32', 0);

-- ----------------------------
-- Table structure for question_tag
-- ----------------------------
DROP TABLE IF EXISTS `question_tag`;
CREATE TABLE `question_tag`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签名称',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_question_tag`(`question_id` ASC, `tag_name` ASC) USING BTREE,
  INDEX `idx_tag_name`(`tag_name` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '题目标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_tag
-- ----------------------------

-- ----------------------------
-- Table structure for student_subject
-- ----------------------------
DROP TABLE IF EXISTS `student_subject`;
CREATE TABLE `student_subject`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `student_id` bigint NOT NULL COMMENT '学生ID（关联sys_user）',
  `subject_id` bigint NOT NULL COMMENT '科目ID',
  `enroll_type` tinyint NULL DEFAULT 1 COMMENT '选课类型：1-必修，2-选修',
  `enroll_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '选课时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-已退课，1-正常',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_subject`(`student_id` ASC, `subject_id` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_student_subject_student` FOREIGN KEY (`student_id`) REFERENCES `sys_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_student_subject_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生-科目关联表（支持跨学院选课）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_subject
-- ----------------------------
INSERT INTO `student_subject` VALUES (1, 5, 1, 1, '2025-12-20 15:30:37', 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37');

-- ----------------------------
-- Table structure for subject
-- ----------------------------
DROP TABLE IF EXISTS `subject`;
CREATE TABLE `subject`  (
  `subject_id` bigint NOT NULL AUTO_INCREMENT COMMENT '科目ID',
  `subject_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '科目名称',
  `subject_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '科目编码',
  `org_id` bigint NOT NULL COMMENT '归属学院ID（org_level=2）',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '科目描述',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '科目封面',
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '学分',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `create_user_id` bigint NOT NULL COMMENT '创建人ID（科目创建者）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`subject_id`) USING BTREE,
  UNIQUE INDEX `uk_subject_code`(`subject_code` ASC, `org_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_create_user_id`(`create_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '科目表（归属学院）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject
-- ----------------------------
INSERT INTO `subject` VALUES (1, 'Java程序设计', 'CS101', 1, 'Java编程语言基础课程，包含语法、面向对象、集合框架等内容', NULL, 4.0, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);
INSERT INTO `subject` VALUES (2, '数据结构与算法', 'CS102', 1, '数据结构与算法分析课程，包含线性表、树、图、排序等', NULL, 4.0, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);
INSERT INTO `subject` VALUES (3, '数据库原理', 'CS201', 1, '数据库系统原理与应用，包含SQL、事务、索引等', NULL, 3.0, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);
INSERT INTO `subject` VALUES (4, '计算机网络', 'CS202', 1, '计算机网络原理，包含TCP/IP、HTTP、网络安全等', NULL, 3.0, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);
INSERT INTO `subject` VALUES (5, '操作系统', 'CS301', 1, '操作系统原理与实践，包含进程、内存、文件系统等', NULL, 4.0, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);
INSERT INTO `subject` VALUES (6, '未分类科目', 'DEFAULT', 1, '历史数据默认科目，后续可手动调整', NULL, NULL, 1, 0, 1, '2025-12-20 15:30:37', '2025-12-20 15:30:37', 0);

-- ----------------------------
-- Table structure for subject_manager
-- ----------------------------
DROP TABLE IF EXISTS `subject_manager`;
CREATE TABLE `subject_manager`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `subject_id` bigint NOT NULL COMMENT '科目ID',
  `user_id` bigint NOT NULL COMMENT '管理员ID（教师/助教）',
  `is_creator` tinyint NULL DEFAULT 0 COMMENT '是否为创建者：0-否，1-是',
  `manager_type` tinyint NULL DEFAULT 1 COMMENT '管理员类型：1-主讲教师，2-协作教师，3-助教',
  `permissions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限列表（JSON数组）',
  `valid_start_date` date NULL DEFAULT NULL COMMENT '授权开始日期',
  `valid_end_date` date NULL DEFAULT NULL COMMENT '授权结束日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_subject_user`(`subject_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_creator`(`is_creator` ASC) USING BTREE,
  CONSTRAINT `fk_subject_manager_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_subject_manager_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '科目管理员表（支持多管理员协作）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject_manager
-- ----------------------------
INSERT INTO `subject_manager` VALUES (1, 1, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-20 15:30:37');
INSERT INTO `subject_manager` VALUES (2, 2, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-20 15:30:37');
INSERT INTO `subject_manager` VALUES (3, 3, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-20 15:30:37');
INSERT INTO `subject_manager` VALUES (4, 4, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-20 15:30:37');
INSERT INTO `subject_manager` VALUES (5, 5, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-20 15:30:37');
INSERT INTO `subject_manager` VALUES (6, 6, 1, 1, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"MANAGE_QUESTION_BANK\",\"GRADE_EXAM\",\"VIEW_ANALYSIS\"]', NULL, NULL, '2025-12-20 15:30:37', '2025-12-24 02:30:45');
INSERT INTO `subject_manager` VALUES (9, 1, 3, 0, 1, '[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"VIEW_ANALYSIS\",\"GRADE_EXAM\",\"MANAGE_QUESTION_BANK\"]', NULL, NULL, '2025-12-25 17:30:33', '2025-12-25 17:30:33');

-- ----------------------------
-- Table structure for subject_user
-- ----------------------------
DROP TABLE IF EXISTS `subject_user`;
CREATE TABLE `subject_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `subject_id` bigint NOT NULL COMMENT '科目ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL DEFAULT 4 COMMENT '用户类型：1-创建者，2-管理员，3-教师，4-学生',
  `permissions` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限标识（JSON格式）',
  `join_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_subject_user_deleted`(`subject_id` ASC, `user_id` ASC, `deleted` ASC) USING BTREE COMMENT '科目用户唯一索引（包含删除标识）',
  INDEX `idx_subject_id`(`subject_id` ASC) USING BTREE COMMENT '科目ID索引',
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE COMMENT '用户ID索引',
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE COMMENT '用户类型索引',
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE COMMENT '删除标识索引',
  CONSTRAINT `fk_subject_user_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_subject_user_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '科目用户关联表（学生选课、教师授课）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of subject_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `menu_type` tinyint NOT NULL COMMENT '菜单类型：1-目录，2-菜单，3-按钮',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '路由路径',
  `component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组件路径',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标',
  `perm_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限标识',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `visible` tinyint NULL DEFAULT 1 COMMENT '是否可见：0-否，1-是',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`menu_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '题库管理', 0, 1, '/question', NULL, 'el-icon-reading', NULL, 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (2, '试卷管理', 0, 1, '/paper', NULL, 'el-icon-document', NULL, 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (3, '考试管理', 0, 1, '/exam', NULL, 'el-icon-edit', NULL, 3, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (4, '成绩管理', 0, 1, '/score', NULL, 'el-icon-data-analysis', NULL, 4, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (5, '系统管理', 0, 1, '/system', NULL, 'el-icon-setting', NULL, 5, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (10, '题库列表', 1, 2, '/question/bank', 'question/bank/index', NULL, 'QUESTION_MANAGE', 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (11, '题目列表', 1, 2, '/question/list', 'question/list/index', NULL, 'QUESTION_MANAGE', 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (12, '知识点管理', 1, 2, '/question/knowledge', 'question/knowledge/index', NULL, 'QUESTION_MANAGE', 3, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (20, '试卷列表', 2, 2, '/paper/list', 'paper/list/index', NULL, 'PAPER_MANAGE', 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (21, '创建试卷', 2, 2, '/paper/create', 'paper/create/index', NULL, 'PAPER_CREATE', 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (30, '考试列表', 3, 2, '/exam/list', 'exam/list/index', NULL, 'EXAM_MANAGE', 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (31, '考试监控', 3, 2, '/exam/monitor', 'exam/monitor/index', NULL, 'EXAM_MONITOR', 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (32, '试卷批改', 3, 2, '/exam/grade', 'exam/grade/index', NULL, 'EXAM_GRADE', 3, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (40, '成绩统计', 4, 2, '/score/statistics', 'score/statistics/index', NULL, 'EXAM_MANAGE', 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (41, '我的成绩', 4, 2, '/score/my', 'score/my/index', NULL, 'SCORE_VIEW', 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (50, '用户管理', 5, 2, '/system/user', 'system/user/index', NULL, 'USER_MANAGE', 1, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (51, '角色管理', 5, 2, '/system/role', 'system/role/index', NULL, 'ROLE_MANAGE', 2, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');
INSERT INTO `sys_menu` VALUES (52, '组织管理', 5, 2, '/system/org', 'system/org/index', NULL, 'ORG_MANAGE', 3, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34');

-- ----------------------------
-- Table structure for sys_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint NOT NULL COMMENT '操作人ID',
  `operate_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型：CREATE-新增，UPDATE-修改，DELETE-删除，PUBLISH-发布，TERMINATE-终止',
  `operate_module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作模块：PAPER-试卷，EXAM-考试，QUESTION-题目',
  `operate_content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作内容描述',
  `target_id` bigint NULL DEFAULT NULL COMMENT '操作对象ID',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作IP',
  `device_info` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备信息',
  `operate_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_operate_type`(`operate_type` ASC) USING BTREE,
  INDEX `idx_operate_module`(`operate_module` ASC) USING BTREE,
  INDEX `idx_operate_time`(`operate_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3587 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_operation_log
-- ----------------------------
INSERT INTO `sys_operation_log` VALUES (1, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 94ms', '2025-11-06 23:53:33');
INSERT INTO `sys_operation_log` VALUES (2, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-06 23:55:14');
INSERT INTO `sys_operation_log` VALUES (3, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-06 23:56:40');
INSERT INTO `sys_operation_log` VALUES (4, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-06 23:56:51');
INSERT INTO `sys_operation_log` VALUES (5, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-06 23:57:59');
INSERT INTO `sys_operation_log` VALUES (6, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-06 23:58:03');
INSERT INTO `sys_operation_log` VALUES (7, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-06 23:58:05');
INSERT INTO `sys_operation_log` VALUES (8, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-06 23:58:26');
INSERT INTO `sys_operation_log` VALUES (9, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-06 23:58:29');
INSERT INTO `sys_operation_log` VALUES (10, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-07 00:01:45');
INSERT INTO `sys_operation_log` VALUES (11, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 00:01:47');
INSERT INTO `sys_operation_log` VALUES (12, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-07 00:01:50');
INSERT INTO `sys_operation_log` VALUES (13, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 00:02:37');
INSERT INTO `sys_operation_log` VALUES (14, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 00:06:02');
INSERT INTO `sys_operation_log` VALUES (15, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 00:06:04');
INSERT INTO `sys_operation_log` VALUES (16, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-07 00:06:38');
INSERT INTO `sys_operation_log` VALUES (17, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-07 00:06:56');
INSERT INTO `sys_operation_log` VALUES (18, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 00:07:08');
INSERT INTO `sys_operation_log` VALUES (19, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-07 00:13:16');
INSERT INTO `sys_operation_log` VALUES (20, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 00:22:43');
INSERT INTO `sys_operation_log` VALUES (21, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-07 15:52:35');
INSERT INTO `sys_operation_log` VALUES (22, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-07 15:53:40');
INSERT INTO `sys_operation_log` VALUES (23, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-11-07 15:53:49');
INSERT INTO `sys_operation_log` VALUES (24, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 15:53:50');
INSERT INTO `sys_operation_log` VALUES (25, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-07 15:54:01');
INSERT INTO `sys_operation_log` VALUES (26, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-07 15:54:08');
INSERT INTO `sys_operation_log` VALUES (27, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 15:56:56');
INSERT INTO `sys_operation_log` VALUES (28, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 15:59:28');
INSERT INTO `sys_operation_log` VALUES (29, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 15:59:35');
INSERT INTO `sys_operation_log` VALUES (30, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-07 16:01:09');
INSERT INTO `sys_operation_log` VALUES (31, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-07 16:01:11');
INSERT INTO `sys_operation_log` VALUES (32, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:01:14');
INSERT INTO `sys_operation_log` VALUES (33, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-07 16:01:17');
INSERT INTO `sys_operation_log` VALUES (34, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:01:41');
INSERT INTO `sys_operation_log` VALUES (35, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:01:57');
INSERT INTO `sys_operation_log` VALUES (36, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:05:05');
INSERT INTO `sys_operation_log` VALUES (37, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:05:06');
INSERT INTO `sys_operation_log` VALUES (38, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 16:05:33');
INSERT INTO `sys_operation_log` VALUES (39, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:06:20');
INSERT INTO `sys_operation_log` VALUES (40, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:21:44');
INSERT INTO `sys_operation_log` VALUES (41, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:21:51');
INSERT INTO `sys_operation_log` VALUES (42, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:21:54');
INSERT INTO `sys_operation_log` VALUES (43, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:22:12');
INSERT INTO `sys_operation_log` VALUES (44, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 16:23:49');
INSERT INTO `sys_operation_log` VALUES (45, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:23:53');
INSERT INTO `sys_operation_log` VALUES (46, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:23:55');
INSERT INTO `sys_operation_log` VALUES (47, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-07 16:23:58');
INSERT INTO `sys_operation_log` VALUES (48, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-07 16:23:59');
INSERT INTO `sys_operation_log` VALUES (49, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:23:59');
INSERT INTO `sys_operation_log` VALUES (50, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-07 16:24:26');
INSERT INTO `sys_operation_log` VALUES (51, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-07 16:25:41');
INSERT INTO `sys_operation_log` VALUES (52, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:30:25');
INSERT INTO `sys_operation_log` VALUES (53, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:30:26');
INSERT INTO `sys_operation_log` VALUES (54, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:30:28');
INSERT INTO `sys_operation_log` VALUES (55, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:30:28');
INSERT INTO `sys_operation_log` VALUES (56, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:30:57');
INSERT INTO `sys_operation_log` VALUES (57, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:31:01');
INSERT INTO `sys_operation_log` VALUES (58, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 16:31:59');
INSERT INTO `sys_operation_log` VALUES (59, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:32:07');
INSERT INTO `sys_operation_log` VALUES (60, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:32:17');
INSERT INTO `sys_operation_log` VALUES (61, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:32:41');
INSERT INTO `sys_operation_log` VALUES (62, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 16:32:51');
INSERT INTO `sys_operation_log` VALUES (63, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:32:56');
INSERT INTO `sys_operation_log` VALUES (64, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:32:57');
INSERT INTO `sys_operation_log` VALUES (65, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:33:07');
INSERT INTO `sys_operation_log` VALUES (66, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-07 16:33:09');
INSERT INTO `sys_operation_log` VALUES (67, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-07 16:33:10');
INSERT INTO `sys_operation_log` VALUES (68, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:34:16');
INSERT INTO `sys_operation_log` VALUES (69, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 16:34:16');
INSERT INTO `sys_operation_log` VALUES (70, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 16:34:21');
INSERT INTO `sys_operation_log` VALUES (71, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-07 22:58:53');
INSERT INTO `sys_operation_log` VALUES (72, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-11-07 22:58:55');
INSERT INTO `sys_operation_log` VALUES (73, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-07 22:59:12');
INSERT INTO `sys_operation_log` VALUES (74, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 22:59:15');
INSERT INTO `sys_operation_log` VALUES (75, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-07 22:59:16');
INSERT INTO `sys_operation_log` VALUES (76, 1, '查询', '试卷管理', '分页查询试卷 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'generate_type\' in \'field list\'\r\n### The error may exist in com/example/exam/mapper/paper/PaperMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT  paper_id,paper_name,description,paper_type,generate_type,total_score,pass_score,org_id,create_user_id,audit_status,audit_remark,auditor_id,audit_time,publish_status,publish_time,allow_view_analysis,allow_reexam,reexam_limit,valid_days,version,parent_paper_id,create_time,update_time,deleted  FROM paper  WHERE deleted=0       ORDER BY create_time DESC\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'generate_type\' in \'field list\'\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 23:04:45');
INSERT INTO `sys_operation_log` VALUES (77, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-11-07 23:26:09');
INSERT INTO `sys_operation_log` VALUES (78, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-07 23:26:14');
INSERT INTO `sys_operation_log` VALUES (79, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 23:26:19');
INSERT INTO `sys_operation_log` VALUES (80, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-07 23:26:22');
INSERT INTO `sys_operation_log` VALUES (81, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-07 23:26:32');
INSERT INTO `sys_operation_log` VALUES (82, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-07 23:26:33');
INSERT INTO `sys_operation_log` VALUES (83, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 23:27:30');
INSERT INTO `sys_operation_log` VALUES (84, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-07 23:28:10');
INSERT INTO `sys_operation_log` VALUES (85, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-07 23:28:12');
INSERT INTO `sys_operation_log` VALUES (86, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-07 23:28:38');
INSERT INTO `sys_operation_log` VALUES (87, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-11-08 22:55:49');
INSERT INTO `sys_operation_log` VALUES (88, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-08 22:55:51');
INSERT INTO `sys_operation_log` VALUES (89, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-08 22:56:00');
INSERT INTO `sys_operation_log` VALUES (90, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-08 22:56:02');
INSERT INTO `sys_operation_log` VALUES (91, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-08 22:56:08');
INSERT INTO `sys_operation_log` VALUES (92, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-08 22:56:09');
INSERT INTO `sys_operation_log` VALUES (93, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-08 22:56:14');
INSERT INTO `sys_operation_log` VALUES (94, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 57ms', '2025-11-08 23:03:40');
INSERT INTO `sys_operation_log` VALUES (95, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:03:55');
INSERT INTO `sys_operation_log` VALUES (96, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-08 23:04:00');
INSERT INTO `sys_operation_log` VALUES (97, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:04:17');
INSERT INTO `sys_operation_log` VALUES (98, 1, '删除', '题库管理', '删除题库', NULL, '0:0:0:0:0:0:0:1', '[51] | 耗时: 91ms', '2025-11-08 23:04:32');
INSERT INTO `sys_operation_log` VALUES (99, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:04:32');
INSERT INTO `sys_operation_log` VALUES (100, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-11-08 23:04:34');
INSERT INTO `sys_operation_log` VALUES (101, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-08 23:04:42');
INSERT INTO `sys_operation_log` VALUES (102, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:04:45');
INSERT INTO `sys_operation_log` VALUES (103, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:04:57');
INSERT INTO `sys_operation_log` VALUES (104, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:05:02');
INSERT INTO `sys_operation_log` VALUES (105, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-08 23:05:32');
INSERT INTO `sys_operation_log` VALUES (106, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-08 23:05:49');
INSERT INTO `sys_operation_log` VALUES (107, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:05:51');
INSERT INTO `sys_operation_log` VALUES (108, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:05:54');
INSERT INTO `sys_operation_log` VALUES (109, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-08 23:05:57');
INSERT INTO `sys_operation_log` VALUES (110, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:05:59');
INSERT INTO `sys_operation_log` VALUES (111, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-08 23:06:12');
INSERT INTO `sys_operation_log` VALUES (112, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-08 23:09:09');
INSERT INTO `sys_operation_log` VALUES (113, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-08 23:09:16');
INSERT INTO `sys_operation_log` VALUES (114, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-11-08 23:24:32');
INSERT INTO `sys_operation_log` VALUES (115, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-08 23:24:35');
INSERT INTO `sys_operation_log` VALUES (116, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-08 23:24:39');
INSERT INTO `sys_operation_log` VALUES (117, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-08 23:45:52');
INSERT INTO `sys_operation_log` VALUES (118, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-08 23:45:58');
INSERT INTO `sys_operation_log` VALUES (119, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-08 23:46:07');
INSERT INTO `sys_operation_log` VALUES (120, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 64ms', '2025-11-08 23:56:08');
INSERT INTO `sys_operation_log` VALUES (121, 1, '查询', '题库管理', '分页查询题库 | 错误: Error attempting to get column \'bank_type\' from result set.  Cause: java.sql.SQLDataException: Cannot determine value type from string \'PUBLIC\'\n; Cannot determine value type from string \'PUBLIC\'', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-08 23:56:16');
INSERT INTO `sys_operation_log` VALUES (122, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-08 23:56:36');
INSERT INTO `sys_operation_log` VALUES (123, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-08 23:59:23');
INSERT INTO `sys_operation_log` VALUES (124, 1, '查询', '题库管理', '分页查询题库 | 错误: Error attempting to get column \'bank_type\' from result set.  Cause: java.sql.SQLDataException: Cannot determine value type from string \'PUBLIC\'\n; Cannot determine value type from string \'PUBLIC\'', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-08 23:59:27');
INSERT INTO `sys_operation_log` VALUES (125, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-08 23:59:34');
INSERT INTO `sys_operation_log` VALUES (126, 1, '查询', '题库管理', '分页查询题库 | 错误: Error attempting to get column \'bank_type\' from result set.  Cause: java.sql.SQLDataException: Cannot determine value type from string \'PUBLIC\'\n; Cannot determine value type from string \'PUBLIC\'', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-08 23:59:39');
INSERT INTO `sys_operation_log` VALUES (127, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-08 23:59:40');
INSERT INTO `sys_operation_log` VALUES (128, 1, '查询', '题库管理', '分页查询题库 | 错误: Error attempting to get column \'bank_type\' from result set.  Cause: java.sql.SQLDataException: Cannot determine value type from string \'PUBLIC\'\n; Cannot determine value type from string \'PUBLIC\'', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:00:52');
INSERT INTO `sys_operation_log` VALUES (129, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 00:01:18');
INSERT INTO `sys_operation_log` VALUES (130, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:04:55');
INSERT INTO `sys_operation_log` VALUES (131, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 00:04:58');
INSERT INTO `sys_operation_log` VALUES (132, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:05:08');
INSERT INTO `sys_operation_log` VALUES (133, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:05:11');
INSERT INTO `sys_operation_log` VALUES (134, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:05:13');
INSERT INTO `sys_operation_log` VALUES (135, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:05:33');
INSERT INTO `sys_operation_log` VALUES (136, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:05:46');
INSERT INTO `sys_operation_log` VALUES (137, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:05:48');
INSERT INTO `sys_operation_log` VALUES (138, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:07:10');
INSERT INTO `sys_operation_log` VALUES (139, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:07:15');
INSERT INTO `sys_operation_log` VALUES (140, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:07:19');
INSERT INTO `sys_operation_log` VALUES (141, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:07:26');
INSERT INTO `sys_operation_log` VALUES (142, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:10:14');
INSERT INTO `sys_operation_log` VALUES (143, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:10:18');
INSERT INTO `sys_operation_log` VALUES (144, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:10:21');
INSERT INTO `sys_operation_log` VALUES (145, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:10:27');
INSERT INTO `sys_operation_log` VALUES (146, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:11:30');
INSERT INTO `sys_operation_log` VALUES (147, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 00:13:49');
INSERT INTO `sys_operation_log` VALUES (148, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:14:00');
INSERT INTO `sys_operation_log` VALUES (149, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:14:02');
INSERT INTO `sys_operation_log` VALUES (150, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:14:06');
INSERT INTO `sys_operation_log` VALUES (151, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:14:25');
INSERT INTO `sys_operation_log` VALUES (152, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 00:15:26');
INSERT INTO `sys_operation_log` VALUES (153, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:15:30');
INSERT INTO `sys_operation_log` VALUES (154, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:15:34');
INSERT INTO `sys_operation_log` VALUES (155, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 00:15:37');
INSERT INTO `sys_operation_log` VALUES (156, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:15:44');
INSERT INTO `sys_operation_log` VALUES (157, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 00:15:48');
INSERT INTO `sys_operation_log` VALUES (158, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:15:56');
INSERT INTO `sys_operation_log` VALUES (159, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:16:26');
INSERT INTO `sys_operation_log` VALUES (160, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:16:28');
INSERT INTO `sys_operation_log` VALUES (161, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 00:16:35');
INSERT INTO `sys_operation_log` VALUES (162, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:16:44');
INSERT INTO `sys_operation_log` VALUES (163, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:16:45');
INSERT INTO `sys_operation_log` VALUES (164, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:16:51');
INSERT INTO `sys_operation_log` VALUES (165, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:17:10');
INSERT INTO `sys_operation_log` VALUES (166, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:17:12');
INSERT INTO `sys_operation_log` VALUES (167, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:17:19');
INSERT INTO `sys_operation_log` VALUES (168, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:17:22');
INSERT INTO `sys_operation_log` VALUES (169, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:18:14');
INSERT INTO `sys_operation_log` VALUES (170, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:18:50');
INSERT INTO `sys_operation_log` VALUES (171, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:18:57');
INSERT INTO `sys_operation_log` VALUES (172, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 00:19:00');
INSERT INTO `sys_operation_log` VALUES (173, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:19:42');
INSERT INTO `sys_operation_log` VALUES (174, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:19:44');
INSERT INTO `sys_operation_log` VALUES (175, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 00:20:08');
INSERT INTO `sys_operation_log` VALUES (176, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 00:21:04');
INSERT INTO `sys_operation_log` VALUES (177, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 00:21:06');
INSERT INTO `sys_operation_log` VALUES (178, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 00:21:26');
INSERT INTO `sys_operation_log` VALUES (179, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 00:26:01');
INSERT INTO `sys_operation_log` VALUES (180, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-09 01:00:54');
INSERT INTO `sys_operation_log` VALUES (181, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 01:01:08');
INSERT INTO `sys_operation_log` VALUES (182, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 01:01:14');
INSERT INTO `sys_operation_log` VALUES (183, 1, '删除', '题目管理', '删除题目', NULL, '0:0:0:0:0:0:0:1', '[1] | 耗时: 18ms', '2025-11-09 01:01:34');
INSERT INTO `sys_operation_log` VALUES (184, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 01:01:34');
INSERT INTO `sys_operation_log` VALUES (185, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 01:02:03');
INSERT INTO `sys_operation_log` VALUES (186, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:02:30');
INSERT INTO `sys_operation_log` VALUES (187, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:02:33');
INSERT INTO `sys_operation_log` VALUES (188, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:02:40');
INSERT INTO `sys_operation_log` VALUES (189, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:02:52');
INSERT INTO `sys_operation_log` VALUES (190, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:02:54');
INSERT INTO `sys_operation_log` VALUES (191, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 01:03:16');
INSERT INTO `sys_operation_log` VALUES (192, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-11-09 01:09:47');
INSERT INTO `sys_operation_log` VALUES (193, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-09 01:09:49');
INSERT INTO `sys_operation_log` VALUES (194, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-09 01:09:49');
INSERT INTO `sys_operation_log` VALUES (195, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 01:09:51');
INSERT INTO `sys_operation_log` VALUES (196, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 01:09:57');
INSERT INTO `sys_operation_log` VALUES (197, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:10:00');
INSERT INTO `sys_operation_log` VALUES (198, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:10:05');
INSERT INTO `sys_operation_log` VALUES (199, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:10:42');
INSERT INTO `sys_operation_log` VALUES (200, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:10:43');
INSERT INTO `sys_operation_log` VALUES (201, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 01:10:53');
INSERT INTO `sys_operation_log` VALUES (202, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:10:54');
INSERT INTO `sys_operation_log` VALUES (203, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 01:11:54');
INSERT INTO `sys_operation_log` VALUES (204, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:12:06');
INSERT INTO `sys_operation_log` VALUES (205, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 01:12:16');
INSERT INTO `sys_operation_log` VALUES (206, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:12:17');
INSERT INTO `sys_operation_log` VALUES (207, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:12:33');
INSERT INTO `sys_operation_log` VALUES (208, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:13:14');
INSERT INTO `sys_operation_log` VALUES (209, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:13:34');
INSERT INTO `sys_operation_log` VALUES (210, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:13:47');
INSERT INTO `sys_operation_log` VALUES (211, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:04');
INSERT INTO `sys_operation_log` VALUES (212, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:17');
INSERT INTO `sys_operation_log` VALUES (213, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:21');
INSERT INTO `sys_operation_log` VALUES (214, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:23');
INSERT INTO `sys_operation_log` VALUES (215, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:26');
INSERT INTO `sys_operation_log` VALUES (216, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:14:29');
INSERT INTO `sys_operation_log` VALUES (217, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:32');
INSERT INTO `sys_operation_log` VALUES (218, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:14:37');
INSERT INTO `sys_operation_log` VALUES (219, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:15:19');
INSERT INTO `sys_operation_log` VALUES (220, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:27:55');
INSERT INTO `sys_operation_log` VALUES (221, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:27:57');
INSERT INTO `sys_operation_log` VALUES (222, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:27:58');
INSERT INTO `sys_operation_log` VALUES (223, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 01:28:13');
INSERT INTO `sys_operation_log` VALUES (224, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:28:14');
INSERT INTO `sys_operation_log` VALUES (225, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 01:28:21');
INSERT INTO `sys_operation_log` VALUES (226, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:28:27');
INSERT INTO `sys_operation_log` VALUES (227, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 01:28:42');
INSERT INTO `sys_operation_log` VALUES (228, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 01:28:44');
INSERT INTO `sys_operation_log` VALUES (229, 1, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id,  question_content, question_type, default_score, difficulty, knowledge_ids,              create_time, update_time )  VALUES (  ?,  ?, ?, ?, ?, ?,              ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\n; Field \'org_id\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test\",\"optionSeq\":\"A\"}],\"questionContent\":\"test1\",\"questionType\":1}] | 耗时: 25ms', '2025-11-09 01:29:16');
INSERT INTO `sys_operation_log` VALUES (230, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 01:37:51');
INSERT INTO `sys_operation_log` VALUES (231, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-11-09 01:51:23');
INSERT INTO `sys_operation_log` VALUES (232, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-09 01:51:24');
INSERT INTO `sys_operation_log` VALUES (233, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 01:51:29');
INSERT INTO `sys_operation_log` VALUES (234, 1, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id,  question_content, question_type, default_score, difficulty, knowledge_ids,              create_time, update_time )  VALUES (  ?,  ?, ?, ?, ?, ?,              ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\n; Field \'org_id\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":2,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionSeq\":\"A\"},{\"isCorrect\":1,\"optionContent\":\"test2\",\"optionSeq\":\"B\"}],\"questionContent\":\"下列哪个关键字用于定义Java类？\",\"questionType\":2}] | 耗时: 4ms', '2025-11-09 01:56:26');
INSERT INTO `sys_operation_log` VALUES (235, 1, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id,  question_content, question_type, default_score, difficulty, knowledge_ids,              create_time, update_time )  VALUES (  ?,  ?, ?, ?, ?, ?,              ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'org_id\' doesn\'t have a default value\n; Field \'org_id\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":2,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionSeq\":\"A\"},{\"isCorrect\":1,\"optionContent\":\"test2\",\"optionSeq\":\"B\"}],\"questionContent\":\"下列哪个关键字用于定义Java类？\",\"questionType\":2}] | 耗时: 239ms', '2025-11-09 01:57:32');
INSERT INTO `sys_operation_log` VALUES (236, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-09 02:02:54');
INSERT INTO `sys_operation_log` VALUES (237, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 02:04:58');
INSERT INTO `sys_operation_log` VALUES (238, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:05:16');
INSERT INTO `sys_operation_log` VALUES (239, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-09 02:05:19');
INSERT INTO `sys_operation_log` VALUES (240, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 02:16:30');
INSERT INTO `sys_operation_log` VALUES (241, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:16:30');
INSERT INTO `sys_operation_log` VALUES (242, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:16:31');
INSERT INTO `sys_operation_log` VALUES (243, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:16:32');
INSERT INTO `sys_operation_log` VALUES (244, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:16:33');
INSERT INTO `sys_operation_log` VALUES (245, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:16:34');
INSERT INTO `sys_operation_log` VALUES (246, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-11-09 02:16:34');
INSERT INTO `sys_operation_log` VALUES (247, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-09 02:16:39');
INSERT INTO `sys_operation_log` VALUES (248, 1, '查询', '组织管理', '获取组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-09 02:16:43');
INSERT INTO `sys_operation_log` VALUES (249, 1, '查询', '组织管理', '获取组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 02:16:54');
INSERT INTO `sys_operation_log` VALUES (250, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 35ms', '2025-11-09 02:26:49');
INSERT INTO `sys_operation_log` VALUES (251, 1, '更新', '用户管理', '更新用户信息 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'252905763@qq.com-0\' for key \'sys_user.uk_email\'\r\n### The error may exist in com/example/exam/mapper/system/SysUserMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.system.SysUserMapper.updateById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE sys_user  SET username=?, password=?, real_name=?, phone=?, email=?,    role_id=?, status=?,      update_time=?  WHERE user_id=? AND deleted=0\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'252905763@qq.com-0\' for key \'sys_user.uk_email\'\n; Duplicate entry \'252905763@qq.com-0\' for key \'sys_user.uk_email\'', NULL, '0:0:0:0:0:0:0:1', '[1,{\"email\":\"252905763@qq.com\",\"password\":\"\",\"phone\":\"18431043673\",\"realName\":\"系统管理员\",\"roleId\":1,\"status\":1,\"userId\":1,\"username\":\"admin\"}] | 耗时: 203ms', '2025-11-09 02:27:39');
INSERT INTO `sys_operation_log` VALUES (252, 1, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[1,{\"email\":\"252905733@qq.com\",\"password\":\"\",\"phone\":\"18431043674\",\"realName\":\"系统管理员\",\"roleId\":1,\"status\":1,\"userId\":1,\"username\":\"admin\"}] | 耗时: 17ms', '2025-11-09 02:28:11');
INSERT INTO `sys_operation_log` VALUES (253, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:28:11');
INSERT INTO `sys_operation_log` VALUES (254, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:28:19');
INSERT INTO `sys_operation_log` VALUES (255, 1, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[1,{\"email\":\"252905733@qq.com\",\"password\":\"\",\"phone\":\"18431043674\",\"realName\":\"系统管理员\",\"roleId\":1,\"status\":1,\"userId\":1,\"username\":\"admin\"}] | 耗时: 12ms', '2025-11-09 02:28:31');
INSERT INTO `sys_operation_log` VALUES (256, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:28:31');
INSERT INTO `sys_operation_log` VALUES (257, 1, '查询', '组织管理', '查询组织树 | 错误: Error attempting to get column \'org_type\' from result set.  Cause: java.sql.SQLDataException: Cannot determine value type from string \'SCHOOL\'\n; Cannot determine value type from string \'SCHOOL\'', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:28:34');
INSERT INTO `sys_operation_log` VALUES (258, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 52ms', '2025-11-09 02:31:08');
INSERT INTO `sys_operation_log` VALUES (259, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-09 02:31:11');
INSERT INTO `sys_operation_log` VALUES (260, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 02:31:25');
INSERT INTO `sys_operation_log` VALUES (261, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 02:33:42');
INSERT INTO `sys_operation_log` VALUES (262, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 02:34:00');
INSERT INTO `sys_operation_log` VALUES (263, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:34:05');
INSERT INTO `sys_operation_log` VALUES (264, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:34:13');
INSERT INTO `sys_operation_log` VALUES (265, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:37:51');
INSERT INTO `sys_operation_log` VALUES (266, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-09 02:37:53');
INSERT INTO `sys_operation_log` VALUES (267, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:37:54');
INSERT INTO `sys_operation_log` VALUES (268, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:37:59');
INSERT INTO `sys_operation_log` VALUES (269, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:38:04');
INSERT INTO `sys_operation_log` VALUES (270, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:38:07');
INSERT INTO `sys_operation_log` VALUES (271, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[235,{\"bankId\":1,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":0,\"optionContent\":\"对\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"错\",\"optionSeq\":\"B\"}],\"questionContent\":\"Java中的String类是否可以被继承？\",\"questionId\":235,\"questionType\":4}] | 耗时: 117ms', '2025-11-09 02:38:24');
INSERT INTO `sys_operation_log` VALUES (272, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:38:24');
INSERT INTO `sys_operation_log` VALUES (273, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:39:27');
INSERT INTO `sys_operation_log` VALUES (274, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 02:39:29');
INSERT INTO `sys_operation_log` VALUES (275, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 02:39:30');
INSERT INTO `sys_operation_log` VALUES (276, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:39:31');
INSERT INTO `sys_operation_log` VALUES (277, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:39:32');
INSERT INTO `sys_operation_log` VALUES (278, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:39:33');
INSERT INTO `sys_operation_log` VALUES (279, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 02:39:37');
INSERT INTO `sys_operation_log` VALUES (280, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:39:40');
INSERT INTO `sys_operation_log` VALUES (281, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:39:42');
INSERT INTO `sys_operation_log` VALUES (282, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:39:49');
INSERT INTO `sys_operation_log` VALUES (283, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-11-09 02:40:55');
INSERT INTO `sys_operation_log` VALUES (284, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:44:12');
INSERT INTO `sys_operation_log` VALUES (285, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:44:13');
INSERT INTO `sys_operation_log` VALUES (286, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 02:46:27');
INSERT INTO `sys_operation_log` VALUES (287, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-09 02:46:27');
INSERT INTO `sys_operation_log` VALUES (288, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:46:34');
INSERT INTO `sys_operation_log` VALUES (289, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:46:36');
INSERT INTO `sys_operation_log` VALUES (290, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-09 02:46:40');
INSERT INTO `sys_operation_log` VALUES (291, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 154ms', '2025-11-09 02:47:30');
INSERT INTO `sys_operation_log` VALUES (292, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:48:09');
INSERT INTO `sys_operation_log` VALUES (293, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 02:48:09');
INSERT INTO `sys_operation_log` VALUES (294, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 02:48:10');
INSERT INTO `sys_operation_log` VALUES (295, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 02:48:12');
INSERT INTO `sys_operation_log` VALUES (296, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-09 02:48:12');
INSERT INTO `sys_operation_log` VALUES (297, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:48:38');
INSERT INTO `sys_operation_log` VALUES (298, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 02:48:39');
INSERT INTO `sys_operation_log` VALUES (299, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 02:48:39');
INSERT INTO `sys_operation_log` VALUES (300, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 02:48:43');
INSERT INTO `sys_operation_log` VALUES (301, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-09 13:36:58');
INSERT INTO `sys_operation_log` VALUES (302, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 13:37:01');
INSERT INTO `sys_operation_log` VALUES (303, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-09 13:37:01');
INSERT INTO `sys_operation_log` VALUES (304, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 13:37:04');
INSERT INTO `sys_operation_log` VALUES (305, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 13:37:07');
INSERT INTO `sys_operation_log` VALUES (306, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-09 13:37:07');
INSERT INTO `sys_operation_log` VALUES (307, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 13:37:08');
INSERT INTO `sys_operation_log` VALUES (308, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 13:37:09');
INSERT INTO `sys_operation_log` VALUES (309, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 13:37:09');
INSERT INTO `sys_operation_log` VALUES (310, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 13:37:14');
INSERT INTO `sys_operation_log` VALUES (311, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-09 13:37:14');
INSERT INTO `sys_operation_log` VALUES (312, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 13:37:17');
INSERT INTO `sys_operation_log` VALUES (313, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":0,\"sort\":0,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 121ms', '2025-11-09 13:37:21');
INSERT INTO `sys_operation_log` VALUES (314, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 13:37:21');
INSERT INTO `sys_operation_log` VALUES (315, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 13:37:23');
INSERT INTO `sys_operation_log` VALUES (316, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 13:37:23');
INSERT INTO `sys_operation_log` VALUES (317, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 13:37:24');
INSERT INTO `sys_operation_log` VALUES (318, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-11-09 13:37:27');
INSERT INTO `sys_operation_log` VALUES (319, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 13:37:30');
INSERT INTO `sys_operation_log` VALUES (320, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 13:37:31');
INSERT INTO `sys_operation_log` VALUES (321, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 13:37:31');
INSERT INTO `sys_operation_log` VALUES (322, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 35ms', '2025-11-09 13:37:35');
INSERT INTO `sys_operation_log` VALUES (323, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 54ms', '2025-11-09 13:42:34');
INSERT INTO `sys_operation_log` VALUES (324, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-09 13:52:51');
INSERT INTO `sys_operation_log` VALUES (325, 1, '查询', '题库管理', '查询题库统计信息', NULL, '127.0.0.1', ' | 耗时: 8ms', '2025-11-09 13:52:51');
INSERT INTO `sys_operation_log` VALUES (326, 1, '查询', '试卷管理', '分页查询试卷', NULL, '127.0.0.1', ' | 耗时: 48ms', '2025-11-09 13:52:51');
INSERT INTO `sys_operation_log` VALUES (327, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-09 13:54:26');
INSERT INTO `sys_operation_log` VALUES (328, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-11-09 13:54:27');
INSERT INTO `sys_operation_log` VALUES (329, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-11-09 13:54:39');
INSERT INTO `sys_operation_log` VALUES (330, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 13:54:48');
INSERT INTO `sys_operation_log` VALUES (331, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-11-09 13:54:57');
INSERT INTO `sys_operation_log` VALUES (332, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:08:25');
INSERT INTO `sys_operation_log` VALUES (333, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 14:08:38');
INSERT INTO `sys_operation_log` VALUES (334, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:08:46');
INSERT INTO `sys_operation_log` VALUES (335, 3, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:08:48');
INSERT INTO `sys_operation_log` VALUES (336, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 14:09:12');
INSERT INTO `sys_operation_log` VALUES (337, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:09:13');
INSERT INTO `sys_operation_log` VALUES (338, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:09:14');
INSERT INTO `sys_operation_log` VALUES (339, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:09:26');
INSERT INTO `sys_operation_log` VALUES (340, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:09:29');
INSERT INTO `sys_operation_log` VALUES (341, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 14:09:33');
INSERT INTO `sys_operation_log` VALUES (342, 3, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'create_user_id\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id,  question_content, question_type, default_score, difficulty, knowledge_ids,              create_time, update_time )  VALUES (  ?,  ?, ?, ?, ?, ?,              ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'create_user_id\' doesn\'t have a default value\n; Field \'create_user_id\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":10,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"Test1\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"test2\",\"optionSeq\":\"B\"},{\"isCorrect\":0,\"optionContent\":\"TEST3\",\"optionSeq\":\"C\"},{\"isCorrect\":0,\"optionContent\":\"test4\",\"optionSeq\":\"D\"}],\"questionContent\":\"Testtest\",\"questionType\":1}] | 耗时: 19ms', '2025-11-09 14:10:34');
INSERT INTO `sys_operation_log` VALUES (343, 3, '创建', '题目管理', '创建题目', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":10,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"Test1\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"test2\",\"optionSeq\":\"B\"},{\"isCorrect\":0,\"optionContent\":\"TEST3\",\"optionSeq\":\"C\"},{\"isCorrect\":0,\"optionContent\":\"test4\",\"optionSeq\":\"D\"}],\"questionContent\":\"Testtest\",\"questionType\":1}] | 耗时: 267ms', '2025-11-09 14:15:39');
INSERT INTO `sys_operation_log` VALUES (344, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-09 14:15:39');
INSERT INTO `sys_operation_log` VALUES (345, 3, '创建', '题目管理', '创建题目', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionSeq\":\"A\"}],\"questionContent\":\"TEST他\",\"questionType\":1}] | 耗时: 21ms', '2025-11-09 14:17:03');
INSERT INTO `sys_operation_log` VALUES (346, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 14:17:03');
INSERT INTO `sys_operation_log` VALUES (347, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-09 14:17:07');
INSERT INTO `sys_operation_log` VALUES (348, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-09 14:17:12');
INSERT INTO `sys_operation_log` VALUES (349, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-09 14:17:16');
INSERT INTO `sys_operation_log` VALUES (350, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-09 14:17:20');
INSERT INTO `sys_operation_log` VALUES (351, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:17:20');
INSERT INTO `sys_operation_log` VALUES (352, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:17:21');
INSERT INTO `sys_operation_log` VALUES (353, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:17:23');
INSERT INTO `sys_operation_log` VALUES (354, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-09 14:17:26');
INSERT INTO `sys_operation_log` VALUES (355, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:17:31');
INSERT INTO `sys_operation_log` VALUES (356, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:17:34');
INSERT INTO `sys_operation_log` VALUES (357, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:17:39');
INSERT INTO `sys_operation_log` VALUES (358, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:17:41');
INSERT INTO `sys_operation_log` VALUES (359, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 14:17:41');
INSERT INTO `sys_operation_log` VALUES (360, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:17:43');
INSERT INTO `sys_operation_log` VALUES (361, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:17:45');
INSERT INTO `sys_operation_log` VALUES (362, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:17:45');
INSERT INTO `sys_operation_log` VALUES (363, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:18:12');
INSERT INTO `sys_operation_log` VALUES (364, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:18:18');
INSERT INTO `sys_operation_log` VALUES (365, 3, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionId\":313,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"sort\":0},{\"isCorrect\":0,\"optionContent\":\"塔斯特\",\"optionSeq\":\"B\"}],\"questionContent\":\"TEST他\",\"questionId\":266,\"questionType\":4}] | 耗时: 28ms', '2025-11-09 14:18:30');
INSERT INTO `sys_operation_log` VALUES (366, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-09 14:18:30');
INSERT INTO `sys_operation_log` VALUES (367, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:18:34');
INSERT INTO `sys_operation_log` VALUES (368, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:18:41');
INSERT INTO `sys_operation_log` VALUES (369, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-11-09 14:18:46');
INSERT INTO `sys_operation_log` VALUES (370, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-11-09 14:19:00');
INSERT INTO `sys_operation_log` VALUES (371, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:19:14');
INSERT INTO `sys_operation_log` VALUES (372, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-09 14:19:48');
INSERT INTO `sys_operation_log` VALUES (373, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-11-09 14:19:55');
INSERT INTO `sys_operation_log` VALUES (374, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-09 14:19:57');
INSERT INTO `sys_operation_log` VALUES (375, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-09 14:19:57');
INSERT INTO `sys_operation_log` VALUES (376, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-09 14:23:11');
INSERT INTO `sys_operation_log` VALUES (377, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:23:12');
INSERT INTO `sys_operation_log` VALUES (378, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:23:23');
INSERT INTO `sys_operation_log` VALUES (379, 3, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionId\":314,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"sort\":0},{\"isCorrect\":0,\"optionContent\":\"塔斯特\",\"optionId\":315,\"optionSeq\":\"B\",\"optionType\":\"NORMAL\",\"sort\":0}],\"questionContent\":\"TEST他\",\"questionId\":266,\"questionType\":4}] | 耗时: 13ms', '2025-11-09 14:23:27');
INSERT INTO `sys_operation_log` VALUES (380, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:23:27');
INSERT INTO `sys_operation_log` VALUES (381, 3, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test1\",\"optionId\":316,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"sort\":0},{\"isCorrect\":0,\"optionContent\":\"塔斯特\",\"optionId\":317,\"optionSeq\":\"B\",\"optionType\":\"NORMAL\",\"sort\":0}],\"questionContent\":\"TEST他\",\"questionId\":266,\"questionType\":4}] | 耗时: 18ms', '2025-11-09 14:23:32');
INSERT INTO `sys_operation_log` VALUES (382, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-09 14:23:32');
INSERT INTO `sys_operation_log` VALUES (383, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-11-10 08:46:54');
INSERT INTO `sys_operation_log` VALUES (384, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-10 08:47:02');
INSERT INTO `sys_operation_log` VALUES (385, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-10 08:47:05');
INSERT INTO `sys_operation_log` VALUES (386, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 08:47:08');
INSERT INTO `sys_operation_log` VALUES (387, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 08:47:13');
INSERT INTO `sys_operation_log` VALUES (388, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 08:47:14');
INSERT INTO `sys_operation_log` VALUES (389, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 08:47:44');
INSERT INTO `sys_operation_log` VALUES (390, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-10 08:47:49');
INSERT INTO `sys_operation_log` VALUES (391, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 08:47:50');
INSERT INTO `sys_operation_log` VALUES (392, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 08:47:57');
INSERT INTO `sys_operation_log` VALUES (393, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-10 08:47:58');
INSERT INTO `sys_operation_log` VALUES (394, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-10 08:53:45');
INSERT INTO `sys_operation_log` VALUES (395, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 08:53:48');
INSERT INTO `sys_operation_log` VALUES (396, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-10 08:54:32');
INSERT INTO `sys_operation_log` VALUES (397, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-10 08:54:34');
INSERT INTO `sys_operation_log` VALUES (398, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-10 08:54:34');
INSERT INTO `sys_operation_log` VALUES (399, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:01:43');
INSERT INTO `sys_operation_log` VALUES (400, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:01:43');
INSERT INTO `sys_operation_log` VALUES (401, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 74ms', '2025-11-10 09:01:56');
INSERT INTO `sys_operation_log` VALUES (402, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-11-10 09:02:05');
INSERT INTO `sys_operation_log` VALUES (403, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 09:02:09');
INSERT INTO `sys_operation_log` VALUES (404, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-10 09:02:09');
INSERT INTO `sys_operation_log` VALUES (405, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 09:02:10');
INSERT INTO `sys_operation_log` VALUES (406, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 09:02:11');
INSERT INTO `sys_operation_log` VALUES (407, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 09:02:12');
INSERT INTO `sys_operation_log` VALUES (408, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 09:02:15');
INSERT INTO `sys_operation_log` VALUES (409, 3, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-10 09:02:16');
INSERT INTO `sys_operation_log` VALUES (410, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 09:02:18');
INSERT INTO `sys_operation_log` VALUES (411, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-10 09:02:19');
INSERT INTO `sys_operation_log` VALUES (412, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 09:02:19');
INSERT INTO `sys_operation_log` VALUES (413, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:02:22');
INSERT INTO `sys_operation_log` VALUES (414, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:02:24');
INSERT INTO `sys_operation_log` VALUES (415, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-10 09:02:29');
INSERT INTO `sys_operation_log` VALUES (416, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 148ms', '2025-11-10 09:05:19');
INSERT INTO `sys_operation_log` VALUES (417, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-10 09:06:32');
INSERT INTO `sys_operation_log` VALUES (418, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-11-10 09:06:35');
INSERT INTO `sys_operation_log` VALUES (419, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-11-10 09:07:11');
INSERT INTO `sys_operation_log` VALUES (420, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-10 09:07:47');
INSERT INTO `sys_operation_log` VALUES (421, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-10 09:07:49');
INSERT INTO `sys_operation_log` VALUES (422, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-10 09:07:53');
INSERT INTO `sys_operation_log` VALUES (423, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-10 09:07:56');
INSERT INTO `sys_operation_log` VALUES (424, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-10 09:08:01');
INSERT INTO `sys_operation_log` VALUES (425, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-10 09:08:05');
INSERT INTO `sys_operation_log` VALUES (426, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:25:49');
INSERT INTO `sys_operation_log` VALUES (427, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-10 09:25:52');
INSERT INTO `sys_operation_log` VALUES (428, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 09:26:10');
INSERT INTO `sys_operation_log` VALUES (429, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 09:26:11');
INSERT INTO `sys_operation_log` VALUES (430, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 09:26:11');
INSERT INTO `sys_operation_log` VALUES (431, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 09:26:13');
INSERT INTO `sys_operation_log` VALUES (432, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 09:26:15');
INSERT INTO `sys_operation_log` VALUES (433, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 09:26:15');
INSERT INTO `sys_operation_log` VALUES (434, 3, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 09:29:04');
INSERT INTO `sys_operation_log` VALUES (435, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 09:29:04');
INSERT INTO `sys_operation_log` VALUES (436, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-10 09:29:05');
INSERT INTO `sys_operation_log` VALUES (437, 3, '删除', '试卷管理', '删除试卷', NULL, '0:0:0:0:0:0:0:1', '[8] | 耗时: 151ms', '2025-11-10 09:30:24');
INSERT INTO `sys_operation_log` VALUES (438, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-10 09:30:24');
INSERT INTO `sys_operation_log` VALUES (439, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 85ms', '2025-11-10 09:39:11');
INSERT INTO `sys_operation_log` VALUES (440, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-11-10 09:42:43');
INSERT INTO `sys_operation_log` VALUES (441, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-11-10 10:14:10');
INSERT INTO `sys_operation_log` VALUES (442, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-11-10 10:15:52');
INSERT INTO `sys_operation_log` VALUES (443, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-10 10:15:57');
INSERT INTO `sys_operation_log` VALUES (444, 3, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-10 10:16:06');
INSERT INTO `sys_operation_log` VALUES (445, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 10:17:06');
INSERT INTO `sys_operation_log` VALUES (446, 3, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[3,{\"email\":\"252905763@qq.com\",\"password\":\"\",\"phone\":\"18531043673\",\"realName\":\"杨克言\",\"roleId\":1,\"status\":1,\"userId\":3,\"username\":\"Test\"}] | 耗时: 21ms', '2025-11-10 10:17:28');
INSERT INTO `sys_operation_log` VALUES (447, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-10 10:17:28');
INSERT INTO `sys_operation_log` VALUES (448, 3, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 10:17:36');
INSERT INTO `sys_operation_log` VALUES (449, 0, '注册', '用户管理', '用户注册 | 错误: 手机号已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"285728347@qq.com\",\"password\":\"123456\",\"phone\":\"18531043673\",\"realName\":\"王琳焱\",\"username\":\"Stuent\"}] | 耗时: 128ms', '2025-11-10 10:34:41');
INSERT INTO `sys_operation_log` VALUES (450, 0, '注册', '用户管理', '用户注册 | 错误: 手机号已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"285728347@qq.com\",\"password\":\"123456\",\"phone\":\"18531043673\",\"realName\":\"王琳焱\",\"username\":\"Stuent\"}] | 耗时: 7ms', '2025-11-10 10:35:02');
INSERT INTO `sys_operation_log` VALUES (451, 0, '注册', '用户管理', '用户注册 | 错误: 手机号已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"285728347@qq.com\",\"password\":\"123456\",\"phone\":\"18531043673\",\"realName\":\"王琳焱\",\"username\":\"Stuent\"}] | 耗时: 4ms', '2025-11-10 10:35:39');
INSERT INTO `sys_operation_log` VALUES (452, 0, '注册', '用户管理', '用户注册 | 错误: 手机号已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"285728347@qq.com\",\"password\":\"123456\",\"phone\":\"18531043673\",\"realName\":\"王琳焱\",\"username\":\"Stuent\"}] | 耗时: 4ms', '2025-11-10 10:36:07');
INSERT INTO `sys_operation_log` VALUES (453, 0, '注册', '用户管理', '用户注册 | 错误: 手机号已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"252905763@qq.com\",\"password\":\"123456\",\"phone\":\"18531043673\",\"realName\":\"王琳焱\",\"username\":\"Student\"}] | 耗时: 17ms', '2025-11-10 10:38:30');
INSERT INTO `sys_operation_log` VALUES (454, 0, '注册', '用户管理', '用户注册 | 错误: 邮箱已被注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"252905763@qq.com\",\"password\":\"123456\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"username\":\"Student\"}] | 耗时: 9ms', '2025-11-10 10:38:38');
INSERT INTO `sys_operation_log` VALUES (455, 0, '注册', '用户管理', '用户注册', NULL, '0:0:0:0:0:0:0:1', '[{\"email\":\"252905764@qq.com\",\"password\":\"123456\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"username\":\"Student\"}] | 耗时: 96ms', '2025-11-10 10:38:43');
INSERT INTO `sys_operation_log` VALUES (456, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 20ms', '2025-11-10 10:38:56');
INSERT INTO `sys_operation_log` VALUES (457, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 121ms', '2025-11-10 10:51:00');
INSERT INTO `sys_operation_log` VALUES (458, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-11-10 10:51:11');
INSERT INTO `sys_operation_log` VALUES (459, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 10:51:58');
INSERT INTO `sys_operation_log` VALUES (460, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-10 10:51:58');
INSERT INTO `sys_operation_log` VALUES (461, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 10:51:59');
INSERT INTO `sys_operation_log` VALUES (462, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-10 10:52:00');
INSERT INTO `sys_operation_log` VALUES (463, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-10 10:52:01');
INSERT INTO `sys_operation_log` VALUES (464, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 10:52:40');
INSERT INTO `sys_operation_log` VALUES (465, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-10 10:52:42');
INSERT INTO `sys_operation_log` VALUES (466, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 72ms', '2025-11-10 10:54:55');
INSERT INTO `sys_operation_log` VALUES (467, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-10 10:55:22');
INSERT INTO `sys_operation_log` VALUES (468, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 10:55:28');
INSERT INTO `sys_operation_log` VALUES (469, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-10 10:58:56');
INSERT INTO `sys_operation_log` VALUES (470, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-10 10:59:07');
INSERT INTO `sys_operation_log` VALUES (471, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 10:59:14');
INSERT INTO `sys_operation_log` VALUES (472, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 10:59:20');
INSERT INTO `sys_operation_log` VALUES (473, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 180ms', '2025-11-10 11:00:57');
INSERT INTO `sys_operation_log` VALUES (474, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:01:04');
INSERT INTO `sys_operation_log` VALUES (475, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:01:30');
INSERT INTO `sys_operation_log` VALUES (476, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 11:02:26');
INSERT INTO `sys_operation_log` VALUES (477, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:04:06');
INSERT INTO `sys_operation_log` VALUES (478, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-10 11:04:16');
INSERT INTO `sys_operation_log` VALUES (479, 5, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 11:04:16');
INSERT INTO `sys_operation_log` VALUES (480, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:04:18');
INSERT INTO `sys_operation_log` VALUES (481, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:04:19');
INSERT INTO `sys_operation_log` VALUES (482, 5, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-10 11:04:19');
INSERT INTO `sys_operation_log` VALUES (483, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-10 11:12:29');
INSERT INTO `sys_operation_log` VALUES (484, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 186ms', '2025-11-10 11:12:32');
INSERT INTO `sys_operation_log` VALUES (485, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 11:12:39');
INSERT INTO `sys_operation_log` VALUES (486, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 11:12:55');
INSERT INTO `sys_operation_log` VALUES (487, 5, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"questionCount\":14,\"reexamLimit\":0,\"totalScore\":77,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 24ms', '2025-11-10 11:13:25');
INSERT INTO `sys_operation_log` VALUES (488, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-10 11:13:25');
INSERT INTO `sys_operation_log` VALUES (489, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-10 11:13:36');
INSERT INTO `sys_operation_log` VALUES (490, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-10 11:13:39');
INSERT INTO `sys_operation_log` VALUES (491, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-10 11:13:40');
INSERT INTO `sys_operation_log` VALUES (492, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-10 11:13:43');
INSERT INTO `sys_operation_log` VALUES (493, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-10 11:15:14');
INSERT INTO `sys_operation_log` VALUES (494, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-10 11:15:24');
INSERT INTO `sys_operation_log` VALUES (495, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-10 11:18:16');
INSERT INTO `sys_operation_log` VALUES (496, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-10 11:18:38');
INSERT INTO `sys_operation_log` VALUES (497, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-10 11:19:25');
INSERT INTO `sys_operation_log` VALUES (498, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-11 08:44:13');
INSERT INTO `sys_operation_log` VALUES (499, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-11-11 08:44:17');
INSERT INTO `sys_operation_log` VALUES (500, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:44:19');
INSERT INTO `sys_operation_log` VALUES (501, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-11 08:44:24');
INSERT INTO `sys_operation_log` VALUES (502, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-11 08:44:29');
INSERT INTO `sys_operation_log` VALUES (503, 5, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-11 08:44:29');
INSERT INTO `sys_operation_log` VALUES (504, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-11 08:44:31');
INSERT INTO `sys_operation_log` VALUES (505, 5, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":0,\"sort\":1,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 155ms', '2025-11-11 08:45:14');
INSERT INTO `sys_operation_log` VALUES (506, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-11 08:45:14');
INSERT INTO `sys_operation_log` VALUES (507, 5, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":0,\"sort\":2,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 15ms', '2025-11-11 08:45:20');
INSERT INTO `sys_operation_log` VALUES (508, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-11 08:45:20');
INSERT INTO `sys_operation_log` VALUES (509, 5, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"Java基础题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":15,\"sort\":1,\"status\":1,\"updateTime\":\"2025-11-09 00:02:32\"}] | 耗时: 13ms', '2025-11-11 08:45:23');
INSERT INTO `sys_operation_log` VALUES (510, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:45:23');
INSERT INTO `sys_operation_log` VALUES (511, 5, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[52,{\"bankId\":52,\"bankName\":\"数据库原理题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"MySQL、SQL语句、索引、事务等数据库相关知识\",\"orgId\":1,\"questionCount\":0,\"sort\":1,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 10ms', '2025-11-11 08:45:31');
INSERT INTO `sys_operation_log` VALUES (512, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-11 08:45:31');
INSERT INTO `sys_operation_log` VALUES (513, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-11 08:45:39');
INSERT INTO `sys_operation_log` VALUES (514, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:45:40');
INSERT INTO `sys_operation_log` VALUES (515, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-11 08:45:47');
INSERT INTO `sys_operation_log` VALUES (516, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-11 08:46:54');
INSERT INTO `sys_operation_log` VALUES (517, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:47:01');
INSERT INTO `sys_operation_log` VALUES (518, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:47:07');
INSERT INTO `sys_operation_log` VALUES (519, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:47:12');
INSERT INTO `sys_operation_log` VALUES (520, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-11-11 08:47:14');
INSERT INTO `sys_operation_log` VALUES (521, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-11 08:47:19');
INSERT INTO `sys_operation_log` VALUES (522, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-11 08:47:23');
INSERT INTO `sys_operation_log` VALUES (523, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-11 08:47:24');
INSERT INTO `sys_operation_log` VALUES (524, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-11 08:47:26');
INSERT INTO `sys_operation_log` VALUES (525, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-11 08:47:29');
INSERT INTO `sys_operation_log` VALUES (526, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-11 08:47:31');
INSERT INTO `sys_operation_log` VALUES (527, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-11 08:49:43');
INSERT INTO `sys_operation_log` VALUES (528, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-11 08:49:52');
INSERT INTO `sys_operation_log` VALUES (529, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-11 08:56:33');
INSERT INTO `sys_operation_log` VALUES (530, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 101ms', '2025-11-11 08:57:16');
INSERT INTO `sys_operation_log` VALUES (531, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-11 08:57:22');
INSERT INTO `sys_operation_log` VALUES (532, 5, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"bankId\":1,\"bankName\":\"\",\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"questionCount\":14,\"reexamLimit\":0,\"totalScore\":67,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 131ms', '2025-11-11 08:57:32');
INSERT INTO `sys_operation_log` VALUES (533, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-11 08:57:32');
INSERT INTO `sys_operation_log` VALUES (534, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-11 08:57:39');
INSERT INTO `sys_operation_log` VALUES (535, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-11-11 09:52:37');
INSERT INTO `sys_operation_log` VALUES (536, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-11-11 11:13:02');
INSERT INTO `sys_operation_log` VALUES (537, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 19185ms', '2025-11-12 09:28:22');
INSERT INTO `sys_operation_log` VALUES (538, 0, '登录', '认证模块', '用户登录', NULL, '127.0.0.1', '参数序列化失败 | 耗时: 75ms', '2025-11-12 09:28:28');
INSERT INTO `sys_operation_log` VALUES (539, 5, '查询', '试卷管理', '分页查询试卷', NULL, '127.0.0.1', ' | 耗时: 52ms', '2025-11-12 09:28:37');
INSERT INTO `sys_operation_log` VALUES (540, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 272ms', '2025-11-12 09:40:56');
INSERT INTO `sys_operation_log` VALUES (541, 5, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 09:41:12');
INSERT INTO `sys_operation_log` VALUES (542, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 85ms', '2025-11-12 09:41:13');
INSERT INTO `sys_operation_log` VALUES (543, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-12 09:41:22');
INSERT INTO `sys_operation_log` VALUES (544, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-12 09:41:22');
INSERT INTO `sys_operation_log` VALUES (545, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-12 09:41:23');
INSERT INTO `sys_operation_log` VALUES (546, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-12 09:41:23');
INSERT INTO `sys_operation_log` VALUES (547, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 47ms', '2025-11-12 09:41:24');
INSERT INTO `sys_operation_log` VALUES (548, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 09:41:32');
INSERT INTO `sys_operation_log` VALUES (549, 5, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[3,{\"email\":\"252905763@qq.com\",\"password\":\"\",\"phone\":\"18531043673\",\"realName\":\"杨克言\",\"roleId\":2,\"status\":1,\"userId\":3,\"username\":\"Test\"}] | 耗时: 19ms', '2025-11-12 09:41:46');
INSERT INTO `sys_operation_log` VALUES (550, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 09:41:46');
INSERT INTO `sys_operation_log` VALUES (551, 5, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[5,{\"email\":\"252905764@qq.com\",\"password\":\"\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"roleId\":3,\"status\":1,\"userId\":5,\"username\":\"Student\"}] | 耗时: 28ms', '2025-11-12 09:46:52');
INSERT INTO `sys_operation_log` VALUES (552, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 09:46:52');
INSERT INTO `sys_operation_log` VALUES (553, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-12 09:46:54');
INSERT INTO `sys_operation_log` VALUES (554, 5, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[5,{\"email\":\"252905764@qq.com\",\"password\":\"\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"roleId\":3,\"status\":1,\"userId\":5,\"username\":\"Student\"}] | 耗时: 9ms', '2025-11-12 09:46:58');
INSERT INTO `sys_operation_log` VALUES (555, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 09:46:58');
INSERT INTO `sys_operation_log` VALUES (556, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 09:47:02');
INSERT INTO `sys_operation_log` VALUES (557, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-12 09:49:13');
INSERT INTO `sys_operation_log` VALUES (558, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 09:49:16');
INSERT INTO `sys_operation_log` VALUES (559, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 09:49:18');
INSERT INTO `sys_operation_log` VALUES (560, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-12 09:49:20');
INSERT INTO `sys_operation_log` VALUES (561, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 09:49:23');
INSERT INTO `sys_operation_log` VALUES (562, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-12 09:49:28');
INSERT INTO `sys_operation_log` VALUES (563, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-12 09:49:31');
INSERT INTO `sys_operation_log` VALUES (564, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-12 09:49:32');
INSERT INTO `sys_operation_log` VALUES (565, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-12 09:49:35');
INSERT INTO `sys_operation_log` VALUES (566, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-12 09:49:37');
INSERT INTO `sys_operation_log` VALUES (567, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-12 09:49:39');
INSERT INTO `sys_operation_log` VALUES (568, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 09:49:55');
INSERT INTO `sys_operation_log` VALUES (569, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-12 09:50:17');
INSERT INTO `sys_operation_log` VALUES (570, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-12 10:12:21');
INSERT INTO `sys_operation_log` VALUES (571, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-12 10:12:38');
INSERT INTO `sys_operation_log` VALUES (572, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-12 10:13:31');
INSERT INTO `sys_operation_log` VALUES (573, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 93ms', '2025-11-12 11:18:31');
INSERT INTO `sys_operation_log` VALUES (574, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-12 11:18:36');
INSERT INTO `sys_operation_log` VALUES (575, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-12 11:18:37');
INSERT INTO `sys_operation_log` VALUES (576, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-12 11:19:23');
INSERT INTO `sys_operation_log` VALUES (577, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 92ms', '2025-11-12 11:24:48');
INSERT INTO `sys_operation_log` VALUES (578, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-12 11:24:49');
INSERT INTO `sys_operation_log` VALUES (579, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-11-12 11:24:51');
INSERT INTO `sys_operation_log` VALUES (580, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-11-12 11:24:51');
INSERT INTO `sys_operation_log` VALUES (581, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-12 11:24:57');
INSERT INTO `sys_operation_log` VALUES (582, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-12 11:24:58');
INSERT INTO `sys_operation_log` VALUES (583, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-12 11:24:59');
INSERT INTO `sys_operation_log` VALUES (584, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-12 11:25:04');
INSERT INTO `sys_operation_log` VALUES (585, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-12 11:25:05');
INSERT INTO `sys_operation_log` VALUES (586, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-12 11:25:05');
INSERT INTO `sys_operation_log` VALUES (587, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-12 11:25:07');
INSERT INTO `sys_operation_log` VALUES (588, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-12 11:25:09');
INSERT INTO `sys_operation_log` VALUES (589, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-12 11:25:14');
INSERT INTO `sys_operation_log` VALUES (590, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-12 11:25:15');
INSERT INTO `sys_operation_log` VALUES (591, 5, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"bankId\":1,\"bankName\":\"\",\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"questionCount\":14,\"reexamLimit\":0,\"totalScore\":67,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 123ms', '2025-11-12 11:28:01');
INSERT INTO `sys_operation_log` VALUES (592, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-12 11:28:01');
INSERT INTO `sys_operation_log` VALUES (593, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-12 11:28:03');
INSERT INTO `sys_operation_log` VALUES (594, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-12 11:28:04');
INSERT INTO `sys_operation_log` VALUES (595, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-12 11:28:09');
INSERT INTO `sys_operation_log` VALUES (596, 5, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"bankId\":1,\"bankName\":\"\",\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"questionCount\":14,\"reexamLimit\":0,\"totalScore\":67,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 2ms', '2025-11-12 11:28:15');
INSERT INTO `sys_operation_log` VALUES (597, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-12 11:28:15');
INSERT INTO `sys_operation_log` VALUES (598, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-12 11:31:04');
INSERT INTO `sys_operation_log` VALUES (599, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-12 11:39:34');
INSERT INTO `sys_operation_log` VALUES (600, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-12 11:39:45');
INSERT INTO `sys_operation_log` VALUES (601, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-12 11:39:46');
INSERT INTO `sys_operation_log` VALUES (602, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-12 11:39:50');
INSERT INTO `sys_operation_log` VALUES (603, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-12 11:39:51');
INSERT INTO `sys_operation_log` VALUES (604, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 55ms', '2025-11-13 17:58:50');
INSERT INTO `sys_operation_log` VALUES (605, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-13 17:58:51');
INSERT INTO `sys_operation_log` VALUES (606, 5, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-11-13 17:58:53');
INSERT INTO `sys_operation_log` VALUES (607, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 181ms', '2025-11-14 08:46:26');
INSERT INTO `sys_operation_log` VALUES (608, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 5ms', '2025-11-14 08:46:28');
INSERT INTO `sys_operation_log` VALUES (609, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 263ms', '2025-11-14 08:46:41');
INSERT INTO `sys_operation_log` VALUES (610, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 292ms', '2025-11-14 08:51:13');
INSERT INTO `sys_operation_log` VALUES (611, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-14 08:51:17');
INSERT INTO `sys_operation_log` VALUES (612, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-14 08:51:18');
INSERT INTO `sys_operation_log` VALUES (613, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-14 08:51:19');
INSERT INTO `sys_operation_log` VALUES (614, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-14 08:51:20');
INSERT INTO `sys_operation_log` VALUES (615, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-14 08:51:23');
INSERT INTO `sys_operation_log` VALUES (616, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-14 08:51:25');
INSERT INTO `sys_operation_log` VALUES (617, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-14 08:51:26');
INSERT INTO `sys_operation_log` VALUES (618, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-11-14 08:51:27');
INSERT INTO `sys_operation_log` VALUES (619, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 134ms', '2025-11-20 10:04:14');
INSERT INTO `sys_operation_log` VALUES (620, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 74ms', '2025-11-20 10:04:16');
INSERT INTO `sys_operation_log` VALUES (621, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-11-20 10:04:18');
INSERT INTO `sys_operation_log` VALUES (622, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.system.SysUserMapper.selectUserDTOPage', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-20 10:04:20');
INSERT INTO `sys_operation_log` VALUES (623, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-20 10:04:22');
INSERT INTO `sys_operation_log` VALUES (624, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.system.SysUserMapper.selectUserDTOPage', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-20 10:04:23');
INSERT INTO `sys_operation_log` VALUES (625, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:04:24');
INSERT INTO `sys_operation_log` VALUES (626, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.system.SysUserMapper.selectUserDTOPage', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-20 10:04:26');
INSERT INTO `sys_operation_log` VALUES (627, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.system.SysUserMapper.selectUserDTOPage', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-20 10:04:37');
INSERT INTO `sys_operation_log` VALUES (628, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.system.SysUserMapper.selectUserDTOPage', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-11-20 10:05:13');
INSERT INTO `sys_operation_log` VALUES (629, 1, '查询', '用户管理', '分页查询用户 | 错误: Invalid bound statement (not found): com.example.exam.mapper.converter.UserConverter.toDTO', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 124ms', '2025-11-20 10:11:40');
INSERT INTO `sys_operation_log` VALUES (630, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 150ms', '2025-11-20 10:21:34');
INSERT INTO `sys_operation_log` VALUES (631, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-20 10:21:37');
INSERT INTO `sys_operation_log` VALUES (632, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 10:21:38');
INSERT INTO `sys_operation_log` VALUES (633, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-20 10:21:39');
INSERT INTO `sys_operation_log` VALUES (634, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"TEST2\",\"questionId\":266,\"questionType\":4}] | 耗时: 141ms', '2025-11-20 10:21:49');
INSERT INTO `sys_operation_log` VALUES (635, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-20 10:21:49');
INSERT INTO `sys_operation_log` VALUES (636, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 10:21:55');
INSERT INTO `sys_operation_log` VALUES (637, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"日哇让\",\"optionSeq\":\"A\"}],\"questionContent\":\"TEST2\",\"questionId\":266,\"questionType\":4}] | 耗时: 18ms', '2025-11-20 10:22:05');
INSERT INTO `sys_operation_log` VALUES (638, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 10:22:05');
INSERT INTO `sys_operation_log` VALUES (639, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:11');
INSERT INTO `sys_operation_log` VALUES (640, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 10:22:13');
INSERT INTO `sys_operation_log` VALUES (641, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:22:33');
INSERT INTO `sys_operation_log` VALUES (642, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 10:22:34');
INSERT INTO `sys_operation_log` VALUES (643, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 10:22:34');
INSERT INTO `sys_operation_log` VALUES (644, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:22:36');
INSERT INTO `sys_operation_log` VALUES (645, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:37');
INSERT INTO `sys_operation_log` VALUES (646, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:37');
INSERT INTO `sys_operation_log` VALUES (647, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:22:38');
INSERT INTO `sys_operation_log` VALUES (648, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:22:39');
INSERT INTO `sys_operation_log` VALUES (649, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:22:39');
INSERT INTO `sys_operation_log` VALUES (650, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:39');
INSERT INTO `sys_operation_log` VALUES (651, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:22:40');
INSERT INTO `sys_operation_log` VALUES (652, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:22:40');
INSERT INTO `sys_operation_log` VALUES (653, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:43');
INSERT INTO `sys_operation_log` VALUES (654, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:22:51');
INSERT INTO `sys_operation_log` VALUES (655, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:22:55');
INSERT INTO `sys_operation_log` VALUES (656, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:23:02');
INSERT INTO `sys_operation_log` VALUES (657, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:23:03');
INSERT INTO `sys_operation_log` VALUES (658, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:23:03');
INSERT INTO `sys_operation_log` VALUES (659, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:23:06');
INSERT INTO `sys_operation_log` VALUES (660, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":0,\"sort\":2,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 13ms', '2025-11-20 10:23:10');
INSERT INTO `sys_operation_log` VALUES (661, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:23:10');
INSERT INTO `sys_operation_log` VALUES (662, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:23:26');
INSERT INTO `sys_operation_log` VALUES (663, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:23:26');
INSERT INTO `sys_operation_log` VALUES (664, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:23:27');
INSERT INTO `sys_operation_log` VALUES (665, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[237,{\"bankId\":1,\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"3\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"2345\",\"optionSeq\":\"B\"},{\"isCorrect\":0,\"optionContent\":\"2535\",\"optionSeq\":\"C\"}],\"questionContent\":\"Java中equals()和==的区别是什么？\",\"questionId\":237,\"questionType\":1}] | 耗时: 29ms', '2025-11-20 10:24:39');
INSERT INTO `sys_operation_log` VALUES (666, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 10:24:39');
INSERT INTO `sys_operation_log` VALUES (667, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:24:44');
INSERT INTO `sys_operation_log` VALUES (668, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-20 10:25:21');
INSERT INTO `sys_operation_log` VALUES (669, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 10:27:44');
INSERT INTO `sys_operation_log` VALUES (670, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:29:26');
INSERT INTO `sys_operation_log` VALUES (671, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:30:05');
INSERT INTO `sys_operation_log` VALUES (672, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 10:30:07');
INSERT INTO `sys_operation_log` VALUES (673, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:30:09');
INSERT INTO `sys_operation_log` VALUES (674, 1, '查询', '试卷管理', '分页查询试卷 | 错误: Cannot invoke \"com.example.exam.entity.paper.PaperQuestion.getBankId()\" because \"pq\" is null', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 10:30:14');
INSERT INTO `sys_operation_log` VALUES (675, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 451ms', '2025-11-20 10:31:37');
INSERT INTO `sys_operation_log` VALUES (676, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 125ms', '2025-11-20 10:31:39');
INSERT INTO `sys_operation_log` VALUES (677, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-11-20 10:32:03');
INSERT INTO `sys_operation_log` VALUES (678, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-11-20 10:32:05');
INSERT INTO `sys_operation_log` VALUES (679, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-20 10:32:07');
INSERT INTO `sys_operation_log` VALUES (680, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-11-20 10:32:20');
INSERT INTO `sys_operation_log` VALUES (681, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[5,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"test\",\"orgId\":1,\"paperId\":5,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 33ms', '2025-11-20 10:32:25');
INSERT INTO `sys_operation_log` VALUES (682, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-20 10:32:25');
INSERT INTO `sys_operation_log` VALUES (683, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-20 10:33:08');
INSERT INTO `sys_operation_log` VALUES (684, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 10:33:31');
INSERT INTO `sys_operation_log` VALUES (685, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:33:33');
INSERT INTO `sys_operation_log` VALUES (686, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-20 10:33:33');
INSERT INTO `sys_operation_log` VALUES (687, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-11-20 10:34:39');
INSERT INTO `sys_operation_log` VALUES (688, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-20 10:35:08');
INSERT INTO `sys_operation_log` VALUES (689, 1, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[5,{\"email\":\"252905764@qq.com\",\"password\":\"\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"roleId\":3,\"status\":0,\"userId\":5,\"username\":\"Student\"}] | 耗时: 20ms', '2025-11-20 10:35:22');
INSERT INTO `sys_operation_log` VALUES (690, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 10:35:22');
INSERT INTO `sys_operation_log` VALUES (691, 1, '更新', '用户管理', '更新用户信息', NULL, '0:0:0:0:0:0:0:1', '[5,{\"email\":\"252905764@qq.com\",\"password\":\"\",\"phone\":\"18531043676\",\"realName\":\"王琳焱\",\"roleId\":3,\"status\":1,\"userId\":5,\"username\":\"Student\"}] | 耗时: 15ms', '2025-11-20 10:35:27');
INSERT INTO `sys_operation_log` VALUES (692, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 10:35:27');
INSERT INTO `sys_operation_log` VALUES (693, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-20 10:35:38');
INSERT INTO `sys_operation_log` VALUES (694, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-20 10:35:39');
INSERT INTO `sys_operation_log` VALUES (695, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:35:40');
INSERT INTO `sys_operation_log` VALUES (696, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-20 10:35:42');
INSERT INTO `sys_operation_log` VALUES (697, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:35:49');
INSERT INTO `sys_operation_log` VALUES (698, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:35:58');
INSERT INTO `sys_operation_log` VALUES (699, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:35:58');
INSERT INTO `sys_operation_log` VALUES (700, 1, '查询', '组织管理', '分页查询组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:36:02');
INSERT INTO `sys_operation_log` VALUES (701, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:36:19');
INSERT INTO `sys_operation_log` VALUES (702, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 10:36:19');
INSERT INTO `sys_operation_log` VALUES (703, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:24');
INSERT INTO `sys_operation_log` VALUES (704, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:36:25');
INSERT INTO `sys_operation_log` VALUES (705, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 10:36:25');
INSERT INTO `sys_operation_log` VALUES (706, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:31');
INSERT INTO `sys_operation_log` VALUES (707, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:35');
INSERT INTO `sys_operation_log` VALUES (708, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:36');
INSERT INTO `sys_operation_log` VALUES (709, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:36');
INSERT INTO `sys_operation_log` VALUES (710, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:40');
INSERT INTO `sys_operation_log` VALUES (711, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:41');
INSERT INTO `sys_operation_log` VALUES (712, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:36:41');
INSERT INTO `sys_operation_log` VALUES (713, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:42');
INSERT INTO `sys_operation_log` VALUES (714, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:43');
INSERT INTO `sys_operation_log` VALUES (715, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 10:36:43');
INSERT INTO `sys_operation_log` VALUES (716, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:44');
INSERT INTO `sys_operation_log` VALUES (717, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:36:46');
INSERT INTO `sys_operation_log` VALUES (718, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:36:46');
INSERT INTO `sys_operation_log` VALUES (719, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:36:48');
INSERT INTO `sys_operation_log` VALUES (720, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:37:06');
INSERT INTO `sys_operation_log` VALUES (721, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:37:13');
INSERT INTO `sys_operation_log` VALUES (722, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:37:13');
INSERT INTO `sys_operation_log` VALUES (723, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:37:19');
INSERT INTO `sys_operation_log` VALUES (724, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:37:21');
INSERT INTO `sys_operation_log` VALUES (725, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:37:21');
INSERT INTO `sys_operation_log` VALUES (726, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 10:37:39');
INSERT INTO `sys_operation_log` VALUES (727, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:44:44');
INSERT INTO `sys_operation_log` VALUES (728, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 10:44:45');
INSERT INTO `sys_operation_log` VALUES (729, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:45:59');
INSERT INTO `sys_operation_log` VALUES (730, 1, '创建', '组织管理', '创建组织', NULL, '0:0:0:0:0:0:0:1', '[{\"orgCode\":\"testcode\",\"orgLevel\":1,\"orgName\":\"testorg\",\"orgType\":1,\"parentId\":0,\"sort\":0,\"status\":1}] | 耗时: 25ms', '2025-11-20 10:46:27');
INSERT INTO `sys_operation_log` VALUES (731, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:46:27');
INSERT INTO `sys_operation_log` VALUES (732, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:46:41');
INSERT INTO `sys_operation_log` VALUES (733, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:47:00');
INSERT INTO `sys_operation_log` VALUES (734, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:47:10');
INSERT INTO `sys_operation_log` VALUES (735, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:47:11');
INSERT INTO `sys_operation_log` VALUES (736, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:47:13');
INSERT INTO `sys_operation_log` VALUES (737, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:51:41');
INSERT INTO `sys_operation_log` VALUES (738, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:45');
INSERT INTO `sys_operation_log` VALUES (739, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:46');
INSERT INTO `sys_operation_log` VALUES (740, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[250,{\"bankId\":2,\"defaultScore\":3,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"35\",\"optionSeq\":\"A\"}],\"questionContent\":\"数据库的ACID特性中，I代表什么？\",\"questionId\":250,\"questionType\":1}] | 耗时: 30ms', '2025-11-20 10:51:52');
INSERT INTO `sys_operation_log` VALUES (741, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:52');
INSERT INTO `sys_operation_log` VALUES (742, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:51:54');
INSERT INTO `sys_operation_log` VALUES (743, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:55');
INSERT INTO `sys_operation_log` VALUES (744, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:51:56');
INSERT INTO `sys_operation_log` VALUES (745, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:51:56');
INSERT INTO `sys_operation_log` VALUES (746, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:57');
INSERT INTO `sys_operation_log` VALUES (747, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:51:58');
INSERT INTO `sys_operation_log` VALUES (748, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:51:58');
INSERT INTO `sys_operation_log` VALUES (749, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:00');
INSERT INTO `sys_operation_log` VALUES (750, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-20 10:52:01');
INSERT INTO `sys_operation_log` VALUES (751, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:01');
INSERT INTO `sys_operation_log` VALUES (752, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:03');
INSERT INTO `sys_operation_log` VALUES (753, 1, '创建', '题目管理', '创建题目', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"其他问题\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"天气问题\",\"optionSeq\":\"B\"}],\"questionContent\":\"tests他\",\"questionType\":1}] | 耗时: 22ms', '2025-11-20 10:52:21');
INSERT INTO `sys_operation_log` VALUES (754, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:21');
INSERT INTO `sys_operation_log` VALUES (755, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:22');
INSERT INTO `sys_operation_log` VALUES (756, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:23');
INSERT INTO `sys_operation_log` VALUES (757, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:23');
INSERT INTO `sys_operation_log` VALUES (758, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:27');
INSERT INTO `sys_operation_log` VALUES (759, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:41');
INSERT INTO `sys_operation_log` VALUES (760, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:52:42');
INSERT INTO `sys_operation_log` VALUES (761, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:42');
INSERT INTO `sys_operation_log` VALUES (762, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:47');
INSERT INTO `sys_operation_log` VALUES (763, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:48');
INSERT INTO `sys_operation_log` VALUES (764, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 10:52:48');
INSERT INTO `sys_operation_log` VALUES (765, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 10:52:50');
INSERT INTO `sys_operation_log` VALUES (766, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 10:52:51');
INSERT INTO `sys_operation_log` VALUES (767, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:51');
INSERT INTO `sys_operation_log` VALUES (768, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:52:55');
INSERT INTO `sys_operation_log` VALUES (769, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-11-20 10:53:31');
INSERT INTO `sys_operation_log` VALUES (770, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 10:53:35');
INSERT INTO `sys_operation_log` VALUES (771, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-20 10:53:37');
INSERT INTO `sys_operation_log` VALUES (772, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 80ms', '2025-11-20 11:03:37');
INSERT INTO `sys_operation_log` VALUES (773, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 346ms', '2025-11-20 11:03:39');
INSERT INTO `sys_operation_log` VALUES (774, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-20 11:03:41');
INSERT INTO `sys_operation_log` VALUES (775, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-20 11:03:42');
INSERT INTO `sys_operation_log` VALUES (776, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-20 11:03:49');
INSERT INTO `sys_operation_log` VALUES (777, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-20 11:03:53');
INSERT INTO `sys_operation_log` VALUES (778, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 130ms', '2025-11-20 11:04:04');
INSERT INTO `sys_operation_log` VALUES (779, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-20 11:04:04');
INSERT INTO `sys_operation_log` VALUES (780, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-11-20 11:04:07');
INSERT INTO `sys_operation_log` VALUES (781, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-20 11:04:09');
INSERT INTO `sys_operation_log` VALUES (782, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 11:04:11');
INSERT INTO `sys_operation_log` VALUES (783, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-20 11:04:13');
INSERT INTO `sys_operation_log` VALUES (784, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-20 11:04:15');
INSERT INTO `sys_operation_log` VALUES (785, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 11:04:16');
INSERT INTO `sys_operation_log` VALUES (786, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:21');
INSERT INTO `sys_operation_log` VALUES (787, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:22');
INSERT INTO `sys_operation_log` VALUES (788, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:22');
INSERT INTO `sys_operation_log` VALUES (789, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:04:24');
INSERT INTO `sys_operation_log` VALUES (790, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:04:25');
INSERT INTO `sys_operation_log` VALUES (791, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:04:25');
INSERT INTO `sys_operation_log` VALUES (792, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:04:27');
INSERT INTO `sys_operation_log` VALUES (793, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-11-20 10:22:05\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"日哇让\",\"optionId\":320,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":266,\"sort\":0,\"updateTime\":\"2025-11-20 10:22:05\"},{\"isCorrect\":0,\"optionContent\":\"我去二分\",\"optionSeq\":\"B\"}],\"questionContent\":\"TEST2\",\"questionId\":266,\"questionType\":4}] | 耗时: 35ms', '2025-11-20 11:04:34');
INSERT INTO `sys_operation_log` VALUES (794, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:34');
INSERT INTO `sys_operation_log` VALUES (795, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:36');
INSERT INTO `sys_operation_log` VALUES (796, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[266,{\"bankId\":52,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-11-20 11:04:34\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"我去二分\",\"optionId\":328,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":266,\"sort\":0,\"updateTime\":\"2025-11-20 11:04:34\"}],\"questionContent\":\"TEST2\",\"questionId\":266,\"questionType\":4}] | 耗时: 19ms', '2025-11-20 11:04:42');
INSERT INTO `sys_operation_log` VALUES (797, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:04:42');
INSERT INTO `sys_operation_log` VALUES (798, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:44');
INSERT INTO `sys_operation_log` VALUES (799, 1, '删除', '题目管理', '删除题目', NULL, '0:0:0:0:0:0:0:1', '[267] | 耗时: 11ms', '2025-11-20 11:04:52');
INSERT INTO `sys_operation_log` VALUES (800, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:52');
INSERT INTO `sys_operation_log` VALUES (801, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:04:55');
INSERT INTO `sys_operation_log` VALUES (802, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:04:56');
INSERT INTO `sys_operation_log` VALUES (803, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:04:56');
INSERT INTO `sys_operation_log` VALUES (804, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:04:58');
INSERT INTO `sys_operation_log` VALUES (805, 1, '删除', '题目管理', '删除题目', NULL, '0:0:0:0:0:0:0:1', '[266] | 耗时: 9ms', '2025-11-20 11:05:00');
INSERT INTO `sys_operation_log` VALUES (806, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:05:00');
INSERT INTO `sys_operation_log` VALUES (807, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:05:00');
INSERT INTO `sys_operation_log` VALUES (808, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:05:01');
INSERT INTO `sys_operation_log` VALUES (809, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:05:01');
INSERT INTO `sys_operation_log` VALUES (810, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:05:03');
INSERT INTO `sys_operation_log` VALUES (811, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:05:10');
INSERT INTO `sys_operation_log` VALUES (812, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[265,{\"bankId\":1,\"defaultScore\":10,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-11-09 14:15:39\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"Test1\",\"optionId\":309,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":265,\"sort\":0,\"updateTime\":\"2025-11-09 14:15:39\"},{\"createTime\":\"2025-11-09 14:15:39\",\"deleted\":0,\"isCorrect\":0,\"optionContent\":\"test2\",\"optionId\":310,\"optionSeq\":\"B\",\"optionType\":\"NORMAL\",\"questionId\":265,\"sort\":0,\"updateTime\":\"2025-11-09 14:15:39\"},{\"createTime\":\"2...', '2025-11-20 11:05:14');
INSERT INTO `sys_operation_log` VALUES (813, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:05:14');
INSERT INTO `sys_operation_log` VALUES (814, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 11:06:16');
INSERT INTO `sys_operation_log` VALUES (815, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:06:19');
INSERT INTO `sys_operation_log` VALUES (816, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:06:19');
INSERT INTO `sys_operation_log` VALUES (817, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:06:20');
INSERT INTO `sys_operation_log` VALUES (818, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:06:21');
INSERT INTO `sys_operation_log` VALUES (819, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:06:21');
INSERT INTO `sys_operation_log` VALUES (820, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:06:22');
INSERT INTO `sys_operation_log` VALUES (821, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:06:23');
INSERT INTO `sys_operation_log` VALUES (822, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:06:23');
INSERT INTO `sys_operation_log` VALUES (823, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:06:28');
INSERT INTO `sys_operation_log` VALUES (824, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:09:12');
INSERT INTO `sys_operation_log` VALUES (825, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:09:18');
INSERT INTO `sys_operation_log` VALUES (826, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:09:29');
INSERT INTO `sys_operation_log` VALUES (827, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:12:21');
INSERT INTO `sys_operation_log` VALUES (828, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 11:12:33');
INSERT INTO `sys_operation_log` VALUES (829, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:13:53');
INSERT INTO `sys_operation_log` VALUES (830, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:13:53');
INSERT INTO `sys_operation_log` VALUES (831, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-20 11:14:02');
INSERT INTO `sys_operation_log` VALUES (832, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-20 11:15:58');
INSERT INTO `sys_operation_log` VALUES (833, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:16:06');
INSERT INTO `sys_operation_log` VALUES (834, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:16:10');
INSERT INTO `sys_operation_log` VALUES (835, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:16:12');
INSERT INTO `sys_operation_log` VALUES (836, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:16:15');
INSERT INTO `sys_operation_log` VALUES (837, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:16:16');
INSERT INTO `sys_operation_log` VALUES (838, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:16');
INSERT INTO `sys_operation_log` VALUES (839, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:17');
INSERT INTO `sys_operation_log` VALUES (840, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:18');
INSERT INTO `sys_operation_log` VALUES (841, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:18');
INSERT INTO `sys_operation_log` VALUES (842, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:18');
INSERT INTO `sys_operation_log` VALUES (843, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:16:19');
INSERT INTO `sys_operation_log` VALUES (844, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:16:19');
INSERT INTO `sys_operation_log` VALUES (845, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:19');
INSERT INTO `sys_operation_log` VALUES (846, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:16:20');
INSERT INTO `sys_operation_log` VALUES (847, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:16:20');
INSERT INTO `sys_operation_log` VALUES (848, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:21');
INSERT INTO `sys_operation_log` VALUES (849, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:16:21');
INSERT INTO `sys_operation_log` VALUES (850, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:16:21');
INSERT INTO `sys_operation_log` VALUES (851, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:17:15');
INSERT INTO `sys_operation_log` VALUES (852, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:17:15');
INSERT INTO `sys_operation_log` VALUES (853, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:17:15');
INSERT INTO `sys_operation_log` VALUES (854, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:17:15');
INSERT INTO `sys_operation_log` VALUES (855, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 295ms', '2025-11-20 11:19:58');
INSERT INTO `sys_operation_log` VALUES (856, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 120ms', '2025-11-20 11:20:07');
INSERT INTO `sys_operation_log` VALUES (857, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-11-20 11:20:10');
INSERT INTO `sys_operation_log` VALUES (858, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 11:20:16');
INSERT INTO `sys_operation_log` VALUES (859, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-20 11:20:18');
INSERT INTO `sys_operation_log` VALUES (860, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-20 11:20:18');
INSERT INTO `sys_operation_log` VALUES (861, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-20 11:20:18');
INSERT INTO `sys_operation_log` VALUES (862, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:19');
INSERT INTO `sys_operation_log` VALUES (863, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:19');
INSERT INTO `sys_operation_log` VALUES (864, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:19');
INSERT INTO `sys_operation_log` VALUES (865, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:20:20');
INSERT INTO `sys_operation_log` VALUES (866, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:20:20');
INSERT INTO `sys_operation_log` VALUES (867, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:20');
INSERT INTO `sys_operation_log` VALUES (868, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:20:21');
INSERT INTO `sys_operation_log` VALUES (869, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:21');
INSERT INTO `sys_operation_log` VALUES (870, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:20:21');
INSERT INTO `sys_operation_log` VALUES (871, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:20:23');
INSERT INTO `sys_operation_log` VALUES (872, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-20 11:20:23');
INSERT INTO `sys_operation_log` VALUES (873, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:20:27');
INSERT INTO `sys_operation_log` VALUES (874, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-20 11:20:27');
INSERT INTO `sys_operation_log` VALUES (875, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,265] | 耗时: 16ms', '2025-11-20 11:20:32');
INSERT INTO `sys_operation_log` VALUES (876, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:20:32');
INSERT INTO `sys_operation_log` VALUES (877, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:20:32');
INSERT INTO `sys_operation_log` VALUES (878, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:20:39');
INSERT INTO `sys_operation_log` VALUES (879, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:20:39');
INSERT INTO `sys_operation_log` VALUES (880, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:20:41');
INSERT INTO `sys_operation_log` VALUES (881, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:20:41');
INSERT INTO `sys_operation_log` VALUES (882, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,265] | 耗时: 9ms', '2025-11-20 11:20:43');
INSERT INTO `sys_operation_log` VALUES (883, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:20:44');
INSERT INTO `sys_operation_log` VALUES (884, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:20:44');
INSERT INTO `sys_operation_log` VALUES (885, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-20 11:22:52');
INSERT INTO `sys_operation_log` VALUES (886, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:23:01');
INSERT INTO `sys_operation_log` VALUES (887, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:23:01');
INSERT INTO `sys_operation_log` VALUES (888, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:23:05');
INSERT INTO `sys_operation_log` VALUES (889, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:23:07');
INSERT INTO `sys_operation_log` VALUES (890, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:23:07');
INSERT INTO `sys_operation_log` VALUES (891, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:23:07');
INSERT INTO `sys_operation_log` VALUES (892, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:23:09');
INSERT INTO `sys_operation_log` VALUES (893, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:23:09');
INSERT INTO `sys_operation_log` VALUES (894, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:23:10');
INSERT INTO `sys_operation_log` VALUES (895, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:23:11');
INSERT INTO `sys_operation_log` VALUES (896, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:23:14');
INSERT INTO `sys_operation_log` VALUES (897, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:23:57');
INSERT INTO `sys_operation_log` VALUES (898, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:24:00');
INSERT INTO `sys_operation_log` VALUES (899, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:02');
INSERT INTO `sys_operation_log` VALUES (900, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-20 11:24:05');
INSERT INTO `sys_operation_log` VALUES (901, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:08');
INSERT INTO `sys_operation_log` VALUES (902, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:09');
INSERT INTO `sys_operation_log` VALUES (903, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:12');
INSERT INTO `sys_operation_log` VALUES (904, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:20');
INSERT INTO `sys_operation_log` VALUES (905, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[237,{\"bankId\":1,\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"Java中equals()和==的区别是什么？\",\"questionId\":237,\"questionType\":1}] | 耗时: 21ms', '2025-11-20 11:24:23');
INSERT INTO `sys_operation_log` VALUES (906, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:24:23');
INSERT INTO `sys_operation_log` VALUES (907, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:24:29');
INSERT INTO `sys_operation_log` VALUES (908, 1, '删除', '题目管理', '删除题目', NULL, '0:0:0:0:0:0:0:1', '[265] | 耗时: 12ms', '2025-11-20 11:24:30');
INSERT INTO `sys_operation_log` VALUES (909, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:30');
INSERT INTO `sys_operation_log` VALUES (910, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:24:33');
INSERT INTO `sys_operation_log` VALUES (911, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:36');
INSERT INTO `sys_operation_log` VALUES (912, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:24:36');
INSERT INTO `sys_operation_log` VALUES (913, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-20 11:28:01');
INSERT INTO `sys_operation_log` VALUES (914, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-20 11:28:03');
INSERT INTO `sys_operation_log` VALUES (915, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-20 11:28:04');
INSERT INTO `sys_operation_log` VALUES (916, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:28:04');
INSERT INTO `sys_operation_log` VALUES (917, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:28:07');
INSERT INTO `sys_operation_log` VALUES (918, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-20 11:28:11');
INSERT INTO `sys_operation_log` VALUES (919, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-20 11:28:11');
INSERT INTO `sys_operation_log` VALUES (920, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 17704ms', '2025-11-21 08:46:29');
INSERT INTO `sys_operation_log` VALUES (921, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 84ms', '2025-11-21 08:46:38');
INSERT INTO `sys_operation_log` VALUES (922, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 83ms', '2025-11-21 08:46:45');
INSERT INTO `sys_operation_log` VALUES (923, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-21 08:46:47');
INSERT INTO `sys_operation_log` VALUES (924, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 08:46:48');
INSERT INTO `sys_operation_log` VALUES (925, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-21 08:47:06');
INSERT INTO `sys_operation_log` VALUES (926, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-11-21 08:47:14');
INSERT INTO `sys_operation_log` VALUES (927, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-21 08:47:19');
INSERT INTO `sys_operation_log` VALUES (928, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-21 08:47:22');
INSERT INTO `sys_operation_log` VALUES (929, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-21 08:47:26');
INSERT INTO `sys_operation_log` VALUES (930, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 08:47:45');
INSERT INTO `sys_operation_log` VALUES (931, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-21 08:47:49');
INSERT INTO `sys_operation_log` VALUES (932, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-11-21 08:47:50');
INSERT INTO `sys_operation_log` VALUES (933, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-21 08:48:13');
INSERT INTO `sys_operation_log` VALUES (934, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:48:19');
INSERT INTO `sys_operation_log` VALUES (935, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:48:25');
INSERT INTO `sys_operation_log` VALUES (936, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 08:48:40');
INSERT INTO `sys_operation_log` VALUES (937, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:48:47');
INSERT INTO `sys_operation_log` VALUES (938, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:48:55');
INSERT INTO `sys_operation_log` VALUES (939, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:49:16');
INSERT INTO `sys_operation_log` VALUES (940, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 08:49:25');
INSERT INTO `sys_operation_log` VALUES (941, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:50:05');
INSERT INTO `sys_operation_log` VALUES (942, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-11-21 08:50:06');
INSERT INTO `sys_operation_log` VALUES (943, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-21 08:50:12');
INSERT INTO `sys_operation_log` VALUES (944, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 08:50:15');
INSERT INTO `sys_operation_log` VALUES (945, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 08:50:17');
INSERT INTO `sys_operation_log` VALUES (946, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 08:50:22');
INSERT INTO `sys_operation_log` VALUES (947, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-21 08:50:22');
INSERT INTO `sys_operation_log` VALUES (948, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:50:24');
INSERT INTO `sys_operation_log` VALUES (949, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 08:53:00');
INSERT INTO `sys_operation_log` VALUES (950, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 08:53:03');
INSERT INTO `sys_operation_log` VALUES (951, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:53:17');
INSERT INTO `sys_operation_log` VALUES (952, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:53:22');
INSERT INTO `sys_operation_log` VALUES (953, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 08:53:22');
INSERT INTO `sys_operation_log` VALUES (954, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:54:35');
INSERT INTO `sys_operation_log` VALUES (955, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 08:54:53');
INSERT INTO `sys_operation_log` VALUES (956, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 08:54:53');
INSERT INTO `sys_operation_log` VALUES (957, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:54:54');
INSERT INTO `sys_operation_log` VALUES (958, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:55:02');
INSERT INTO `sys_operation_log` VALUES (959, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 08:55:03');
INSERT INTO `sys_operation_log` VALUES (960, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-11-21 09:02:52');
INSERT INTO `sys_operation_log` VALUES (961, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-21 09:02:56');
INSERT INTO `sys_operation_log` VALUES (962, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:03:00');
INSERT INTO `sys_operation_log` VALUES (963, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-21 09:03:01');
INSERT INTO `sys_operation_log` VALUES (964, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:03:02');
INSERT INTO `sys_operation_log` VALUES (965, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-21 09:03:02');
INSERT INTO `sys_operation_log` VALUES (966, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 09:03:13');
INSERT INTO `sys_operation_log` VALUES (967, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:03:16');
INSERT INTO `sys_operation_log` VALUES (968, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-21 09:03:19');
INSERT INTO `sys_operation_log` VALUES (969, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 09:03:31');
INSERT INTO `sys_operation_log` VALUES (970, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:03:39');
INSERT INTO `sys_operation_log` VALUES (971, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[4,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java、数据库、Spring综合能力测试\",\"orgId\":1,\"paperId\":4,\"paperName\":\"综合能力测试卷\",\"paperType\":1,\"passScore\":70,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 22ms', '2025-11-21 09:03:44');
INSERT INTO `sys_operation_log` VALUES (972, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 09:03:44');
INSERT INTO `sys_operation_log` VALUES (973, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 09:03:48');
INSERT INTO `sys_operation_log` VALUES (974, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-21 09:03:50');
INSERT INTO `sys_operation_log` VALUES (975, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-21 09:03:54');
INSERT INTO `sys_operation_log` VALUES (976, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 09:03:56');
INSERT INTO `sys_operation_log` VALUES (977, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:04:05');
INSERT INTO `sys_operation_log` VALUES (978, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-21 09:04:10');
INSERT INTO `sys_operation_log` VALUES (979, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:04:13');
INSERT INTO `sys_operation_log` VALUES (980, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 18ms', '2025-11-21 09:04:30');
INSERT INTO `sys_operation_log` VALUES (981, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-21 09:04:30');
INSERT INTO `sys_operation_log` VALUES (982, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 09:09:42');
INSERT INTO `sys_operation_log` VALUES (983, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-21 09:09:44');
INSERT INTO `sys_operation_log` VALUES (984, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:18:40');
INSERT INTO `sys_operation_log` VALUES (985, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:19:06');
INSERT INTO `sys_operation_log` VALUES (986, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:19:07');
INSERT INTO `sys_operation_log` VALUES (987, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:19:07');
INSERT INTO `sys_operation_log` VALUES (988, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:19:14');
INSERT INTO `sys_operation_log` VALUES (989, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:19:34');
INSERT INTO `sys_operation_log` VALUES (990, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:19:34');
INSERT INTO `sys_operation_log` VALUES (991, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:19:53');
INSERT INTO `sys_operation_log` VALUES (992, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:19:55');
INSERT INTO `sys_operation_log` VALUES (993, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:19:55');
INSERT INTO `sys_operation_log` VALUES (994, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:20:17');
INSERT INTO `sys_operation_log` VALUES (995, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:20:39');
INSERT INTO `sys_operation_log` VALUES (996, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:20:43');
INSERT INTO `sys_operation_log` VALUES (997, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:20:43');
INSERT INTO `sys_operation_log` VALUES (998, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:20:46');
INSERT INTO `sys_operation_log` VALUES (999, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:20:57');
INSERT INTO `sys_operation_log` VALUES (1000, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:20:59');
INSERT INTO `sys_operation_log` VALUES (1001, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:20:59');
INSERT INTO `sys_operation_log` VALUES (1002, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:21:00');
INSERT INTO `sys_operation_log` VALUES (1003, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:22:07');
INSERT INTO `sys_operation_log` VALUES (1004, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 09:22:08');
INSERT INTO `sys_operation_log` VALUES (1005, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 09:22:15');
INSERT INTO `sys_operation_log` VALUES (1006, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:25:27');
INSERT INTO `sys_operation_log` VALUES (1007, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:25:28');
INSERT INTO `sys_operation_log` VALUES (1008, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:25:28');
INSERT INTO `sys_operation_log` VALUES (1009, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:26:05');
INSERT INTO `sys_operation_log` VALUES (1010, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:26:07');
INSERT INTO `sys_operation_log` VALUES (1011, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,234] | 耗时: 25ms', '2025-11-21 09:26:11');
INSERT INTO `sys_operation_log` VALUES (1012, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:26:12');
INSERT INTO `sys_operation_log` VALUES (1013, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:26:12');
INSERT INTO `sys_operation_log` VALUES (1014, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:26:15');
INSERT INTO `sys_operation_log` VALUES (1015, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:26:18');
INSERT INTO `sys_operation_log` VALUES (1016, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:26:18');
INSERT INTO `sys_operation_log` VALUES (1017, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:26:19');
INSERT INTO `sys_operation_log` VALUES (1018, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:29:57');
INSERT INTO `sys_operation_log` VALUES (1019, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:30:00');
INSERT INTO `sys_operation_log` VALUES (1020, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:30:02');
INSERT INTO `sys_operation_log` VALUES (1021, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[264,{\"bankId\":53,\"defaultScore\":10,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"请解释Spring IOC的工作原理，并说明依赖注入的三种方式。\",\"questionId\":264,\"questionType\":8}] | 耗时: 16ms', '2025-11-21 09:30:07');
INSERT INTO `sys_operation_log` VALUES (1022, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:30:07');
INSERT INTO `sys_operation_log` VALUES (1023, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:30:16');
INSERT INTO `sys_operation_log` VALUES (1024, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:30:18');
INSERT INTO `sys_operation_log` VALUES (1025, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:30:20');
INSERT INTO `sys_operation_log` VALUES (1026, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:31:34');
INSERT INTO `sys_operation_log` VALUES (1027, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:33:44');
INSERT INTO `sys_operation_log` VALUES (1028, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:33:50');
INSERT INTO `sys_operation_log` VALUES (1029, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:34:02');
INSERT INTO `sys_operation_log` VALUES (1030, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:34:02');
INSERT INTO `sys_operation_log` VALUES (1031, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:34:07');
INSERT INTO `sys_operation_log` VALUES (1032, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:34:13');
INSERT INTO `sys_operation_log` VALUES (1033, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:34:16');
INSERT INTO `sys_operation_log` VALUES (1034, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:47:07');
INSERT INTO `sys_operation_log` VALUES (1035, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:47:24');
INSERT INTO `sys_operation_log` VALUES (1036, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[234,{\"bankId\":1,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-11-09 01:01:08\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"Class\",\"optionId\":306,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":234,\"sort\":0,\"updateTime\":\"2025-11-09 01:01:08\"}],\"questionContent\":\"下列哪个关键字用于定义Java类？\",\"questionId\":234,\"questionType\":1}] | 耗时: 17ms', '2025-11-21 09:51:35');
INSERT INTO `sys_operation_log` VALUES (1037, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:51:35');
INSERT INTO `sys_operation_log` VALUES (1038, 1, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[238,{\"bankId\":1,\"defaultScore\":3,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"以下哪个集合类是线程安全的？\",\"questionId\":238,\"questionType\":1}] | 耗时: 16ms', '2025-11-21 09:51:42');
INSERT INTO `sys_operation_log` VALUES (1039, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:51:42');
INSERT INTO `sys_operation_log` VALUES (1040, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-21 09:51:56');
INSERT INTO `sys_operation_log` VALUES (1041, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:52:00');
INSERT INTO `sys_operation_log` VALUES (1042, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 09:52:00');
INSERT INTO `sys_operation_log` VALUES (1043, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:52:02');
INSERT INTO `sys_operation_log` VALUES (1044, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-21 09:52:03');
INSERT INTO `sys_operation_log` VALUES (1045, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:52:03');
INSERT INTO `sys_operation_log` VALUES (1046, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:52:10');
INSERT INTO `sys_operation_log` VALUES (1047, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:52:10');
INSERT INTO `sys_operation_log` VALUES (1048, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[53,264] | 耗时: 16ms', '2025-11-21 09:52:14');
INSERT INTO `sys_operation_log` VALUES (1049, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 09:52:15');
INSERT INTO `sys_operation_log` VALUES (1050, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-21 09:52:15');
INSERT INTO `sys_operation_log` VALUES (1051, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 09:52:21');
INSERT INTO `sys_operation_log` VALUES (1052, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:52:21');
INSERT INTO `sys_operation_log` VALUES (1053, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-21 09:54:17');
INSERT INTO `sys_operation_log` VALUES (1054, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:54:19');
INSERT INTO `sys_operation_log` VALUES (1055, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 09:54:19');
INSERT INTO `sys_operation_log` VALUES (1056, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 10:00:06');
INSERT INTO `sys_operation_log` VALUES (1057, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-11-21 10:00:06');
INSERT INTO `sys_operation_log` VALUES (1058, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[53,264] | 耗时: 6ms', '2025-11-21 10:00:09');
INSERT INTO `sys_operation_log` VALUES (1059, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-21 10:00:09');
INSERT INTO `sys_operation_log` VALUES (1060, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-11-21 10:00:09');
INSERT INTO `sys_operation_log` VALUES (1061, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 10:08:11');
INSERT INTO `sys_operation_log` VALUES (1062, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 10:08:11');
INSERT INTO `sys_operation_log` VALUES (1063, 1, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[53,264] | 耗时: 10ms', '2025-11-21 10:08:14');
INSERT INTO `sys_operation_log` VALUES (1064, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 10:08:14');
INSERT INTO `sys_operation_log` VALUES (1065, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-21 10:08:14');
INSERT INTO `sys_operation_log` VALUES (1066, 1, '查询', '题库管理', '分页查询题库', NULL, '127.0.0.1', ' | 耗时: 221ms', '2025-11-21 10:28:32');
INSERT INTO `sys_operation_log` VALUES (1067, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-21 10:28:40');
INSERT INTO `sys_operation_log` VALUES (1068, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-21 10:28:41');
INSERT INTO `sys_operation_log` VALUES (1069, 1, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-21 10:28:46');
INSERT INTO `sys_operation_log` VALUES (1070, 1, '查询', '题目管理', '分页查询题目', NULL, '127.0.0.1', ' | 耗时: 18ms', '2025-11-21 10:28:46');
INSERT INTO `sys_operation_log` VALUES (1071, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-21 10:28:50');
INSERT INTO `sys_operation_log` VALUES (1072, 1, '查询', '题目管理', '分页查询题目', NULL, '127.0.0.1', ' | 耗时: 8ms', '2025-11-21 10:28:53');
INSERT INTO `sys_operation_log` VALUES (1073, 1, '查询', '题库管理', '分页查询题库', NULL, '127.0.0.1', ' | 耗时: 6ms', '2025-11-21 10:29:04');
INSERT INTO `sys_operation_log` VALUES (1074, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 10:29:05');
INSERT INTO `sys_operation_log` VALUES (1075, 1, '查询', '题库管理', '查询题库统计信息', NULL, '127.0.0.1', ' | 耗时: 4ms', '2025-11-21 10:29:05');
INSERT INTO `sys_operation_log` VALUES (1076, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-21 10:29:06');
INSERT INTO `sys_operation_log` VALUES (1077, 1, '查询', '题库管理', '查询题库统计信息', NULL, '127.0.0.1', ' | 耗时: 5ms', '2025-11-21 10:29:07');
INSERT INTO `sys_operation_log` VALUES (1078, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-21 10:29:07');
INSERT INTO `sys_operation_log` VALUES (1079, 1, '查询', '题目管理', '分页查询题目', NULL, '127.0.0.1', ' | 耗时: 7ms', '2025-11-21 10:29:11');
INSERT INTO `sys_operation_log` VALUES (1080, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 73ms', '2025-11-21 10:30:22');
INSERT INTO `sys_operation_log` VALUES (1081, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-11-21 10:30:26');
INSERT INTO `sys_operation_log` VALUES (1082, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-21 10:30:33');
INSERT INTO `sys_operation_log` VALUES (1083, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 10:34:30');
INSERT INTO `sys_operation_log` VALUES (1084, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-21 10:35:03');
INSERT INTO `sys_operation_log` VALUES (1085, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 10:35:04');
INSERT INTO `sys_operation_log` VALUES (1086, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-21 10:39:25');
INSERT INTO `sys_operation_log` VALUES (1087, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 202ms', '2025-11-21 10:39:26');
INSERT INTO `sys_operation_log` VALUES (1088, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-21 10:39:26');
INSERT INTO `sys_operation_log` VALUES (1089, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-21 10:39:27');
INSERT INTO `sys_operation_log` VALUES (1090, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 2156ms', '2025-11-24 08:57:21');
INSERT INTO `sys_operation_log` VALUES (1091, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 284ms', '2025-11-24 08:57:29');
INSERT INTO `sys_operation_log` VALUES (1092, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[52,{\"bankId\":52,\"bankName\":\"数据库原理题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"MySQL、SQL语句、索引、事务等数据库相关知识\",\"orgId\":1,\"questionCount\":0,\"sort\":0,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 83ms', '2025-11-24 08:57:35');
INSERT INTO `sys_operation_log` VALUES (1093, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-24 08:57:35');
INSERT INTO `sys_operation_log` VALUES (1094, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[54,{\"bankId\":54,\"bankName\":\"算法与数据结构题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"常见算法、数据结构、时间复杂度等计算机基础\",\"orgId\":1,\"questionCount\":0,\"sort\":1,\"status\":1,\"updateTime\":\"2025-11-09 00:02:35\"}] | 耗时: 124ms', '2025-11-24 08:57:44');
INSERT INTO `sys_operation_log` VALUES (1095, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-11-24 08:57:44');
INSERT INTO `sys_operation_log` VALUES (1096, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 54ms', '2025-11-24 08:57:50');
INSERT INTO `sys_operation_log` VALUES (1097, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-24 08:57:50');
INSERT INTO `sys_operation_log` VALUES (1098, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[54,{\"bankId\":54,\"bankName\":\"算法与数据结构题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"常见算法、数据结构、时间复杂度等计算机基础\",\"orgId\":1,\"questionCount\":0,\"sort\":0,\"status\":1,\"updateTime\":\"2025-11-09 00:02:35\"}] | 耗时: 27ms', '2025-11-24 08:57:55');
INSERT INTO `sys_operation_log` VALUES (1099, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 08:57:56');
INSERT INTO `sys_operation_log` VALUES (1100, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-11-24 08:57:57');
INSERT INTO `sys_operation_log` VALUES (1101, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 08:57:57');
INSERT INTO `sys_operation_log` VALUES (1102, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"Java基础题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":14,\"sort\":0,\"status\":1,\"updateTime\":\"2025-11-09 00:02:32\"}] | 耗时: 17ms', '2025-11-24 08:58:12');
INSERT INTO `sys_operation_log` VALUES (1103, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-24 08:58:12');
INSERT INTO `sys_operation_log` VALUES (1104, 1, '查询', '题库管理', '分页查询题库', NULL, '127.0.0.1', ' | 耗时: 87ms', '2025-11-24 09:00:29');
INSERT INTO `sys_operation_log` VALUES (1105, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 230ms', '2025-11-24 09:00:45');
INSERT INTO `sys_operation_log` VALUES (1106, 1, '查询', '试卷管理', '分页查询试卷', NULL, '127.0.0.1', ' | 耗时: 120ms', '2025-11-24 09:00:49');
INSERT INTO `sys_operation_log` VALUES (1107, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 80ms', '2025-11-24 09:00:58');
INSERT INTO `sys_operation_log` VALUES (1108, 1, '查询', '题目管理', '分页查询题目', NULL, '127.0.0.1', ' | 耗时: 50ms', '2025-11-24 09:01:08');
INSERT INTO `sys_operation_log` VALUES (1109, 1, '更新', '试卷管理', '更新试卷', NULL, '127.0.0.1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 497ms', '2025-11-24 09:01:26');
INSERT INTO `sys_operation_log` VALUES (1110, 1, '查询', '试卷管理', '分页查询试卷', NULL, '127.0.0.1', ' | 耗时: 65ms', '2025-11-24 09:01:27');
INSERT INTO `sys_operation_log` VALUES (1111, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 65ms', '2025-11-24 09:20:21');
INSERT INTO `sys_operation_log` VALUES (1112, 1, '删除', '试卷管理', '删除试卷', NULL, '0:0:0:0:0:0:0:1', '[7] | 耗时: 17ms', '2025-11-24 09:20:26');
INSERT INTO `sys_operation_log` VALUES (1113, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-11-24 09:20:26');
INSERT INTO `sys_operation_log` VALUES (1114, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 09:20:45');
INSERT INTO `sys_operation_log` VALUES (1115, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-11-24 09:20:49');
INSERT INTO `sys_operation_log` VALUES (1116, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-24 09:20:57');
INSERT INTO `sys_operation_log` VALUES (1117, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-11-24 09:21:04');
INSERT INTO `sys_operation_log` VALUES (1118, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[5,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"test\",\"orgId\":1,\"paperId\":5,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":10,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 20ms', '2025-11-24 09:21:19');
INSERT INTO `sys_operation_log` VALUES (1119, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-11-24 09:21:19');
INSERT INTO `sys_operation_log` VALUES (1120, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-11-24 09:21:28');
INSERT INTO `sys_operation_log` VALUES (1121, 1, '创建', '试卷管理', '创建试卷', NULL, '0:0:0:0:0:0:0:1', '[{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"test\",\"orgId\":1,\"paperName\":\"testExam\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":10,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 21ms', '2025-11-24 09:27:07');
INSERT INTO `sys_operation_log` VALUES (1122, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 46ms', '2025-11-24 09:27:08');
INSERT INTO `sys_operation_log` VALUES (1123, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-24 09:31:40');
INSERT INTO `sys_operation_log` VALUES (1124, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 363ms', '2025-11-24 09:31:43');
INSERT INTO `sys_operation_log` VALUES (1125, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 391ms', '2025-11-24 09:51:55');
INSERT INTO `sys_operation_log` VALUES (1126, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 82ms', '2025-11-24 09:52:02');
INSERT INTO `sys_operation_log` VALUES (1127, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 71ms', '2025-11-24 09:53:07');
INSERT INTO `sys_operation_log` VALUES (1128, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 09:53:07');
INSERT INTO `sys_operation_log` VALUES (1129, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-24 10:08:38');
INSERT INTO `sys_operation_log` VALUES (1130, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 10:08:40');
INSERT INTO `sys_operation_log` VALUES (1131, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 46ms', '2025-11-24 10:08:41');
INSERT INTO `sys_operation_log` VALUES (1132, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 64ms', '2025-11-24 10:08:41');
INSERT INTO `sys_operation_log` VALUES (1133, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 57ms', '2025-11-24 10:08:57');
INSERT INTO `sys_operation_log` VALUES (1134, 1, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[6,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":6,\"paperName\":\"Java基础综合测试卷\",\"paperType\":2,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-11-07 11:15:32\",\"validDays\":30,\"version\":1}] | 耗时: 626ms', '2025-11-24 10:09:02');
INSERT INTO `sys_operation_log` VALUES (1135, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-11-24 10:09:02');
INSERT INTO `sys_operation_log` VALUES (1136, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 10:14:02');
INSERT INTO `sys_operation_log` VALUES (1137, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 45ms', '2025-11-24 10:14:12');
INSERT INTO `sys_operation_log` VALUES (1138, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 5ms', '2025-11-24 10:14:17');
INSERT INTO `sys_operation_log` VALUES (1139, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 296ms', '2025-11-24 10:14:32');
INSERT INTO `sys_operation_log` VALUES (1140, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-11-24 10:14:52');
INSERT INTO `sys_operation_log` VALUES (1141, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-11-24 10:14:54');
INSERT INTO `sys_operation_log` VALUES (1142, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-24 10:14:57');
INSERT INTO `sys_operation_log` VALUES (1143, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-24 10:14:59');
INSERT INTO `sys_operation_log` VALUES (1144, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 471ms', '2025-11-24 10:23:06');
INSERT INTO `sys_operation_log` VALUES (1145, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 146ms', '2025-11-24 10:23:06');
INSERT INTO `sys_operation_log` VALUES (1146, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 78ms', '2025-11-24 10:23:13');
INSERT INTO `sys_operation_log` VALUES (1147, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 70ms', '2025-11-24 10:23:27');
INSERT INTO `sys_operation_log` VALUES (1148, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-11-24 10:31:40');
INSERT INTO `sys_operation_log` VALUES (1149, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-11-24 10:31:58');
INSERT INTO `sys_operation_log` VALUES (1150, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-11-24 10:32:09');
INSERT INTO `sys_operation_log` VALUES (1151, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-24 10:32:10');
INSERT INTO `sys_operation_log` VALUES (1152, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 10:32:11');
INSERT INTO `sys_operation_log` VALUES (1153, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-24 10:32:13');
INSERT INTO `sys_operation_log` VALUES (1154, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-24 10:32:20');
INSERT INTO `sys_operation_log` VALUES (1155, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-24 10:32:21');
INSERT INTO `sys_operation_log` VALUES (1156, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-11-24 10:33:20');
INSERT INTO `sys_operation_log` VALUES (1157, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1374ms', '2025-11-24 10:33:30');
INSERT INTO `sys_operation_log` VALUES (1158, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-11-24 10:33:30');
INSERT INTO `sys_operation_log` VALUES (1159, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-11-24 10:33:30');
INSERT INTO `sys_operation_log` VALUES (1160, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 10:33:47');
INSERT INTO `sys_operation_log` VALUES (1161, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 10:33:49');
INSERT INTO `sys_operation_log` VALUES (1162, 3, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 61ms', '2025-11-24 11:13:08');
INSERT INTO `sys_operation_log` VALUES (1163, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 11:13:10');
INSERT INTO `sys_operation_log` VALUES (1164, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-11-24 11:13:11');
INSERT INTO `sys_operation_log` VALUES (1165, 3, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-24 11:16:42');
INSERT INTO `sys_operation_log` VALUES (1166, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 771ms', '2025-11-24 11:16:45');
INSERT INTO `sys_operation_log` VALUES (1167, 3, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-24 11:25:01');
INSERT INTO `sys_operation_log` VALUES (1168, 3, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-11-24 11:25:01');
INSERT INTO `sys_operation_log` VALUES (1169, 3, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 11:25:01');
INSERT INTO `sys_operation_log` VALUES (1170, 3, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-24 11:25:18');
INSERT INTO `sys_operation_log` VALUES (1171, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 224ms', '2025-11-24 11:25:21');
INSERT INTO `sys_operation_log` VALUES (1172, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-11-24 11:25:21');
INSERT INTO `sys_operation_log` VALUES (1173, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-11-24 11:25:21');
INSERT INTO `sys_operation_log` VALUES (1174, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-24 11:25:21');
INSERT INTO `sys_operation_log` VALUES (1175, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-24 11:25:28');
INSERT INTO `sys_operation_log` VALUES (1176, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-24 11:25:28');
INSERT INTO `sys_operation_log` VALUES (1177, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-24 11:25:28');
INSERT INTO `sys_operation_log` VALUES (1178, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-24 11:25:39');
INSERT INTO `sys_operation_log` VALUES (1179, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-24 11:25:39');
INSERT INTO `sys_operation_log` VALUES (1180, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-11-24 11:25:39');
INSERT INTO `sys_operation_log` VALUES (1181, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-11-24 11:25:42');
INSERT INTO `sys_operation_log` VALUES (1182, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 2550ms', '2025-11-25 09:12:25');
INSERT INTO `sys_operation_log` VALUES (1183, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 73ms', '2025-11-25 09:12:26');
INSERT INTO `sys_operation_log` VALUES (1184, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 79ms', '2025-11-25 09:12:26');
INSERT INTO `sys_operation_log` VALUES (1185, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 95ms', '2025-11-25 09:12:26');
INSERT INTO `sys_operation_log` VALUES (1186, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-11-25 09:12:49');
INSERT INTO `sys_operation_log` VALUES (1187, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-25 09:12:49');
INSERT INTO `sys_operation_log` VALUES (1188, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-25 09:12:49');
INSERT INTO `sys_operation_log` VALUES (1189, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-25 09:13:03');
INSERT INTO `sys_operation_log` VALUES (1190, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-11-25 09:13:03');
INSERT INTO `sys_operation_log` VALUES (1191, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-25 09:13:03');
INSERT INTO `sys_operation_log` VALUES (1192, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-25 09:13:06');
INSERT INTO `sys_operation_log` VALUES (1193, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-11-25 09:13:07');
INSERT INTO `sys_operation_log` VALUES (1194, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-25 09:13:07');
INSERT INTO `sys_operation_log` VALUES (1195, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-11-25 09:13:30');
INSERT INTO `sys_operation_log` VALUES (1196, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-25 09:13:30');
INSERT INTO `sys_operation_log` VALUES (1197, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-11-25 09:13:30');
INSERT INTO `sys_operation_log` VALUES (1198, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-11-25 09:14:32');
INSERT INTO `sys_operation_log` VALUES (1199, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-11-25 09:14:32');
INSERT INTO `sys_operation_log` VALUES (1200, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-11-25 09:14:32');
INSERT INTO `sys_operation_log` VALUES (1201, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-11-25 09:17:34');
INSERT INTO `sys_operation_log` VALUES (1202, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-11-25 09:17:34');
INSERT INTO `sys_operation_log` VALUES (1203, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-11-25 09:17:34');
INSERT INTO `sys_operation_log` VALUES (1204, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-11-25 09:17:37');
INSERT INTO `sys_operation_log` VALUES (1205, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 248ms', '2025-11-25 09:17:39');
INSERT INTO `sys_operation_log` VALUES (1206, 5, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-11-25 09:17:40');
INSERT INTO `sys_operation_log` VALUES (1207, 5, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-11-25 09:17:40');
INSERT INTO `sys_operation_log` VALUES (1208, 5, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-11-25 09:17:40');
INSERT INTO `sys_operation_log` VALUES (1209, 5, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-11-25 09:18:18');
INSERT INTO `sys_operation_log` VALUES (1210, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 201ms', '2025-11-25 09:18:21');
INSERT INTO `sys_operation_log` VALUES (1211, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-11-25 09:18:21');
INSERT INTO `sys_operation_log` VALUES (1212, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-11-25 09:18:21');
INSERT INTO `sys_operation_log` VALUES (1213, 1, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-11-25 09:18:21');
INSERT INTO `sys_operation_log` VALUES (1214, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1187ms', '2025-12-01 00:50:30');
INSERT INTO `sys_operation_log` VALUES (1215, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1186ms', '2025-12-01 00:50:30');
INSERT INTO `sys_operation_log` VALUES (1216, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1935ms', '2025-12-01 00:50:31');
INSERT INTO `sys_operation_log` VALUES (1217, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-01 00:50:38');
INSERT INTO `sys_operation_log` VALUES (1218, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 51ms', '2025-12-01 00:50:38');
INSERT INTO `sys_operation_log` VALUES (1219, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 52ms', '2025-12-01 00:50:38');
INSERT INTO `sys_operation_log` VALUES (1220, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-01 00:50:41');
INSERT INTO `sys_operation_log` VALUES (1221, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 707ms', '2025-12-01 00:56:25');
INSERT INTO `sys_operation_log` VALUES (1222, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-01 00:56:25');
INSERT INTO `sys_operation_log` VALUES (1223, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-01 00:56:25');
INSERT INTO `sys_operation_log` VALUES (1224, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-01 00:56:25');
INSERT INTO `sys_operation_log` VALUES (1225, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 210ms', '2025-12-01 01:23:48');
INSERT INTO `sys_operation_log` VALUES (1226, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-01 01:23:49');
INSERT INTO `sys_operation_log` VALUES (1227, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-01 01:23:49');
INSERT INTO `sys_operation_log` VALUES (1228, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-01 01:23:49');
INSERT INTO `sys_operation_log` VALUES (1229, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-01 01:23:56');
INSERT INTO `sys_operation_log` VALUES (1230, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-01 01:23:56');
INSERT INTO `sys_operation_log` VALUES (1231, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-12-01 01:23:56');
INSERT INTO `sys_operation_log` VALUES (1232, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-01 01:24:00');
INSERT INTO `sys_operation_log` VALUES (1233, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-01 01:24:00');
INSERT INTO `sys_operation_log` VALUES (1234, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-01 01:24:00');
INSERT INTO `sys_operation_log` VALUES (1235, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-01 01:24:09');
INSERT INTO `sys_operation_log` VALUES (1236, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-01 01:24:09');
INSERT INTO `sys_operation_log` VALUES (1237, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-01 01:24:09');
INSERT INTO `sys_operation_log` VALUES (1238, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-01 01:24:15');
INSERT INTO `sys_operation_log` VALUES (1239, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-01 01:24:15');
INSERT INTO `sys_operation_log` VALUES (1240, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-01 01:24:15');
INSERT INTO `sys_operation_log` VALUES (1241, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-01 01:24:19');
INSERT INTO `sys_operation_log` VALUES (1242, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-01 01:24:19');
INSERT INTO `sys_operation_log` VALUES (1243, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-01 01:24:19');
INSERT INTO `sys_operation_log` VALUES (1244, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1245, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1246, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1247, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1248, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 53ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1249, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 111ms', '2025-12-01 01:28:09');
INSERT INTO `sys_operation_log` VALUES (1250, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-01 01:28:14');
INSERT INTO `sys_operation_log` VALUES (1251, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-01 01:28:14');
INSERT INTO `sys_operation_log` VALUES (1252, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-01 01:28:14');
INSERT INTO `sys_operation_log` VALUES (1253, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-01 01:28:20');
INSERT INTO `sys_operation_log` VALUES (1254, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-01 01:28:20');
INSERT INTO `sys_operation_log` VALUES (1255, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-01 01:28:20');
INSERT INTO `sys_operation_log` VALUES (1256, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-01 01:28:36');
INSERT INTO `sys_operation_log` VALUES (1257, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-01 01:28:36');
INSERT INTO `sys_operation_log` VALUES (1258, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-01 01:28:36');
INSERT INTO `sys_operation_log` VALUES (1259, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-01 01:28:52');
INSERT INTO `sys_operation_log` VALUES (1260, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 109ms', '2025-12-01 01:28:52');
INSERT INTO `sys_operation_log` VALUES (1261, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 296ms', '2025-12-01 01:28:52');
INSERT INTO `sys_operation_log` VALUES (1262, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 86ms', '2025-12-01 01:29:25');
INSERT INTO `sys_operation_log` VALUES (1263, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 103ms', '2025-12-01 01:29:25');
INSERT INTO `sys_operation_log` VALUES (1264, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 206ms', '2025-12-01 01:29:25');
INSERT INTO `sys_operation_log` VALUES (1265, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-01 01:29:45');
INSERT INTO `sys_operation_log` VALUES (1266, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-01 01:29:45');
INSERT INTO `sys_operation_log` VALUES (1267, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-01 01:29:45');
INSERT INTO `sys_operation_log` VALUES (1268, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-01 01:29:49');
INSERT INTO `sys_operation_log` VALUES (1269, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-01 01:29:49');
INSERT INTO `sys_operation_log` VALUES (1270, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-01 01:29:49');
INSERT INTO `sys_operation_log` VALUES (1271, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-01 01:38:04');
INSERT INTO `sys_operation_log` VALUES (1272, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-01 01:38:04');
INSERT INTO `sys_operation_log` VALUES (1273, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-01 01:38:04');
INSERT INTO `sys_operation_log` VALUES (1274, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-01 01:49:17');
INSERT INTO `sys_operation_log` VALUES (1275, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-01 01:49:17');
INSERT INTO `sys_operation_log` VALUES (1276, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-01 01:49:17');
INSERT INTO `sys_operation_log` VALUES (1277, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-01 01:49:21');
INSERT INTO `sys_operation_log` VALUES (1278, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-01 01:49:21');
INSERT INTO `sys_operation_log` VALUES (1279, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-01 01:49:21');
INSERT INTO `sys_operation_log` VALUES (1280, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 3276ms', '2025-12-01 09:24:42');
INSERT INTO `sys_operation_log` VALUES (1281, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 209ms', '2025-12-01 09:24:42');
INSERT INTO `sys_operation_log` VALUES (1282, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 218ms', '2025-12-01 09:24:42');
INSERT INTO `sys_operation_log` VALUES (1283, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 233ms', '2025-12-01 09:24:42');
INSERT INTO `sys_operation_log` VALUES (1284, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-01 09:24:52');
INSERT INTO `sys_operation_log` VALUES (1285, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-01 09:24:52');
INSERT INTO `sys_operation_log` VALUES (1286, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-01 09:24:52');
INSERT INTO `sys_operation_log` VALUES (1287, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 384ms', '2025-12-02 15:27:50');
INSERT INTO `sys_operation_log` VALUES (1288, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 414ms', '2025-12-02 15:27:50');
INSERT INTO `sys_operation_log` VALUES (1289, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 418ms', '2025-12-02 15:27:50');
INSERT INTO `sys_operation_log` VALUES (1290, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-02 15:27:51');
INSERT INTO `sys_operation_log` VALUES (1291, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-02 15:27:55');
INSERT INTO `sys_operation_log` VALUES (1292, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-02 15:28:03');
INSERT INTO `sys_operation_log` VALUES (1293, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 69ms', '2025-12-02 15:28:07');
INSERT INTO `sys_operation_log` VALUES (1294, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-02 15:28:12');
INSERT INTO `sys_operation_log` VALUES (1295, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-02 15:28:22');
INSERT INTO `sys_operation_log` VALUES (1296, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-02 15:28:23');
INSERT INTO `sys_operation_log` VALUES (1297, 1, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-02 15:28:25');
INSERT INTO `sys_operation_log` VALUES (1298, 1, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:28:26');
INSERT INTO `sys_operation_log` VALUES (1299, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:28:29');
INSERT INTO `sys_operation_log` VALUES (1300, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"Java基础题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":14,\"sort\":1,\"status\":1,\"updateTime\":\"2025-11-09 00:02:32\"}] | 耗时: 472ms', '2025-12-02 15:29:17');
INSERT INTO `sys_operation_log` VALUES (1301, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 15:29:17');
INSERT INTO `sys_operation_log` VALUES (1302, 1, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":1,\"sort\":3,\"status\":1,\"updateTime\":\"2025-11-09 00:02:34\"}] | 耗时: 18ms', '2025-12-02 15:29:23');
INSERT INTO `sys_operation_log` VALUES (1303, 1, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 15:29:23');
INSERT INTO `sys_operation_log` VALUES (1304, 1, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-02 15:29:35');
INSERT INTO `sys_operation_log` VALUES (1305, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-02 15:30:43');
INSERT INTO `sys_operation_log` VALUES (1306, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 390ms', '2025-12-02 15:30:49');
INSERT INTO `sys_operation_log` VALUES (1307, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-02 15:30:49');
INSERT INTO `sys_operation_log` VALUES (1308, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 15:30:49');
INSERT INTO `sys_operation_log` VALUES (1309, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-02 15:30:49');
INSERT INTO `sys_operation_log` VALUES (1310, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-02 15:30:52');
INSERT INTO `sys_operation_log` VALUES (1311, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-02 15:31:01');
INSERT INTO `sys_operation_log` VALUES (1312, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:31:15');
INSERT INTO `sys_operation_log` VALUES (1313, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:31:22');
INSERT INTO `sys_operation_log` VALUES (1314, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-02 15:31:22');
INSERT INTO `sys_operation_log` VALUES (1315, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-02 15:31:22');
INSERT INTO `sys_operation_log` VALUES (1316, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-02 15:31:30');
INSERT INTO `sys_operation_log` VALUES (1317, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 15:31:32');
INSERT INTO `sys_operation_log` VALUES (1318, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-02 15:31:32');
INSERT INTO `sys_operation_log` VALUES (1319, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-02 15:31:32');
INSERT INTO `sys_operation_log` VALUES (1320, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:31:33');
INSERT INTO `sys_operation_log` VALUES (1321, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-02 15:31:34');
INSERT INTO `sys_operation_log` VALUES (1322, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 15:31:34');
INSERT INTO `sys_operation_log` VALUES (1323, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-02 15:31:34');
INSERT INTO `sys_operation_log` VALUES (1324, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-02 15:31:37');
INSERT INTO `sys_operation_log` VALUES (1325, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-02 15:31:40');
INSERT INTO `sys_operation_log` VALUES (1326, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 15:31:41');
INSERT INTO `sys_operation_log` VALUES (1327, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-02 15:31:41');
INSERT INTO `sys_operation_log` VALUES (1328, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-02 15:31:41');
INSERT INTO `sys_operation_log` VALUES (1329, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-02 15:31:44');
INSERT INTO `sys_operation_log` VALUES (1330, 3, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-02 15:35:30');
INSERT INTO `sys_operation_log` VALUES (1331, 3, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-02 15:35:31');
INSERT INTO `sys_operation_log` VALUES (1332, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-02 16:21:23');
INSERT INTO `sys_operation_log` VALUES (1333, 3, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-02 16:22:47');
INSERT INTO `sys_operation_log` VALUES (1334, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-02 16:22:56');
INSERT INTO `sys_operation_log` VALUES (1335, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 257ms', '2025-12-02 16:22:58');
INSERT INTO `sys_operation_log` VALUES (1336, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-02 16:22:59');
INSERT INTO `sys_operation_log` VALUES (1337, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-02 16:23:00');
INSERT INTO `sys_operation_log` VALUES (1338, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-02 16:29:47');
INSERT INTO `sys_operation_log` VALUES (1339, 3, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 153ms', '2025-12-02 17:30:13');
INSERT INTO `sys_operation_log` VALUES (1340, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 468ms', '2025-12-03 14:54:09');
INSERT INTO `sys_operation_log` VALUES (1341, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 96ms', '2025-12-03 14:54:09');
INSERT INTO `sys_operation_log` VALUES (1342, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 109ms', '2025-12-03 14:54:09');
INSERT INTO `sys_operation_log` VALUES (1343, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 114ms', '2025-12-03 14:54:09');
INSERT INTO `sys_operation_log` VALUES (1344, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-03 14:54:13');
INSERT INTO `sys_operation_log` VALUES (1345, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-03 14:54:16');
INSERT INTO `sys_operation_log` VALUES (1346, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-03 14:57:16');
INSERT INTO `sys_operation_log` VALUES (1347, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-03 14:57:16');
INSERT INTO `sys_operation_log` VALUES (1348, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-03 14:57:16');
INSERT INTO `sys_operation_log` VALUES (1349, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-03 17:27:18');
INSERT INTO `sys_operation_log` VALUES (1350, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 63ms', '2025-12-03 17:27:18');
INSERT INTO `sys_operation_log` VALUES (1351, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 178ms', '2025-12-03 17:27:18');
INSERT INTO `sys_operation_log` VALUES (1352, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-18 18:59:45');
INSERT INTO `sys_operation_log` VALUES (1353, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-18 18:59:45');
INSERT INTO `sys_operation_log` VALUES (1354, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 886ms', '2025-12-18 19:00:05');
INSERT INTO `sys_operation_log` VALUES (1355, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 237ms', '2025-12-18 19:00:05');
INSERT INTO `sys_operation_log` VALUES (1356, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 264ms', '2025-12-18 19:00:05');
INSERT INTO `sys_operation_log` VALUES (1357, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 289ms', '2025-12-18 19:00:05');
INSERT INTO `sys_operation_log` VALUES (1358, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-18 19:00:07');
INSERT INTO `sys_operation_log` VALUES (1359, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-18 19:00:08');
INSERT INTO `sys_operation_log` VALUES (1360, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-18 19:33:49');
INSERT INTO `sys_operation_log` VALUES (1361, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-18 19:34:36');
INSERT INTO `sys_operation_log` VALUES (1362, 5, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-18 21:35:40');
INSERT INTO `sys_operation_log` VALUES (1363, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 222ms', '2025-12-18 21:35:41');
INSERT INTO `sys_operation_log` VALUES (1364, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 46ms', '2025-12-18 21:35:41');
INSERT INTO `sys_operation_log` VALUES (1365, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-12-18 21:35:41');
INSERT INTO `sys_operation_log` VALUES (1366, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 65ms', '2025-12-18 21:35:41');
INSERT INTO `sys_operation_log` VALUES (1367, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 374ms', '2025-12-20 16:51:26');
INSERT INTO `sys_operation_log` VALUES (1368, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 377ms', '2025-12-20 16:51:26');
INSERT INTO `sys_operation_log` VALUES (1369, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 412ms', '2025-12-20 16:51:26');
INSERT INTO `sys_operation_log` VALUES (1370, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-12-20 16:53:04');
INSERT INTO `sys_operation_log` VALUES (1371, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 69ms', '2025-12-20 16:53:04');
INSERT INTO `sys_operation_log` VALUES (1372, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-20 16:53:14');
INSERT INTO `sys_operation_log` VALUES (1373, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-20 16:53:16');
INSERT INTO `sys_operation_log` VALUES (1374, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 54ms', '2025-12-20 16:53:17');
INSERT INTO `sys_operation_log` VALUES (1375, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 16:53:20');
INSERT INTO `sys_operation_log` VALUES (1376, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 16:53:31');
INSERT INTO `sys_operation_log` VALUES (1377, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-20 17:05:45');
INSERT INTO `sys_operation_log` VALUES (1378, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-20 17:05:45');
INSERT INTO `sys_operation_log` VALUES (1379, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-20 17:05:45');
INSERT INTO `sys_operation_log` VALUES (1380, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-20 17:05:45');
INSERT INTO `sys_operation_log` VALUES (1381, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 56ms', '2025-12-20 17:05:45');
INSERT INTO `sys_operation_log` VALUES (1382, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 17:05:47');
INSERT INTO `sys_operation_log` VALUES (1383, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 17:05:50');
INSERT INTO `sys_operation_log` VALUES (1384, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 17:05:52');
INSERT INTO `sys_operation_log` VALUES (1385, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-20 17:05:53');
INSERT INTO `sys_operation_log` VALUES (1386, 5, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-20 17:05:53');
INSERT INTO `sys_operation_log` VALUES (1387, 5, '创建', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-20 17:05:54');
INSERT INTO `sys_operation_log` VALUES (1388, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 17:05:54');
INSERT INTO `sys_operation_log` VALUES (1389, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-20 17:05:56');
INSERT INTO `sys_operation_log` VALUES (1390, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 17:06:08');
INSERT INTO `sys_operation_log` VALUES (1391, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-20 17:06:10');
INSERT INTO `sys_operation_log` VALUES (1392, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 654ms', '2025-12-20 17:06:11');
INSERT INTO `sys_operation_log` VALUES (1393, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 17:06:12');
INSERT INTO `sys_operation_log` VALUES (1394, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-20 17:06:12');
INSERT INTO `sys_operation_log` VALUES (1395, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-20 17:06:12');
INSERT INTO `sys_operation_log` VALUES (1396, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-20 17:06:13');
INSERT INTO `sys_operation_log` VALUES (1397, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 17:06:13');
INSERT INTO `sys_operation_log` VALUES (1398, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 17:06:14');
INSERT INTO `sys_operation_log` VALUES (1399, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-20 17:06:14');
INSERT INTO `sys_operation_log` VALUES (1400, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 35ms', '2025-12-20 17:06:14');
INSERT INTO `sys_operation_log` VALUES (1401, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 17:06:15');
INSERT INTO `sys_operation_log` VALUES (1402, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 17:06:15');
INSERT INTO `sys_operation_log` VALUES (1403, 5, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 17:06:15');
INSERT INTO `sys_operation_log` VALUES (1404, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-20 17:06:15');
INSERT INTO `sys_operation_log` VALUES (1405, 5, '创建', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 17:06:15');
INSERT INTO `sys_operation_log` VALUES (1406, 5, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[234,{\"bankId\":1,\"defaultScore\":3,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"下列哪个关键字用于定义Java类？\",\"questionId\":234,\"questionType\":1}] | 耗时: 495ms', '2025-12-20 17:06:26');
INSERT INTO `sys_operation_log` VALUES (1407, 5, '创建', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-20 17:06:26');
INSERT INTO `sys_operation_log` VALUES (1408, 5, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 40ms', '2025-12-20 19:47:00');
INSERT INTO `sys_operation_log` VALUES (1409, 5, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 546ms', '2025-12-20 19:47:00');
INSERT INTO `sys_operation_log` VALUES (1410, 5, '查询', '题目管理', '分页查询题目 | 错误: 您没有权限执行此操作：查看题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-20 19:47:00');
INSERT INTO `sys_operation_log` VALUES (1411, 5, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-20 19:47:07');
INSERT INTO `sys_operation_log` VALUES (1412, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 2697ms', '2025-12-20 19:47:13');
INSERT INTO `sys_operation_log` VALUES (1413, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-20 19:47:17');
INSERT INTO `sys_operation_log` VALUES (1414, 0, '登录', '认证模块', '用户登录', NULL, '127.0.0.1', '参数序列化失败 | 耗时: 876ms', '2025-12-20 19:48:28');
INSERT INTO `sys_operation_log` VALUES (1415, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-20 19:48:28');
INSERT INTO `sys_operation_log` VALUES (1416, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 219ms', '2025-12-20 19:49:16');
INSERT INTO `sys_operation_log` VALUES (1417, 1, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-20 19:49:17');
INSERT INTO `sys_operation_log` VALUES (1418, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 2653ms', '2025-12-20 20:02:24');
INSERT INTO `sys_operation_log` VALUES (1419, 1, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-20 20:02:24');
INSERT INTO `sys_operation_log` VALUES (1420, 1, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-20 20:02:24');
INSERT INTO `sys_operation_log` VALUES (1421, 1, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2100ms', '2025-12-20 20:02:27');
INSERT INTO `sys_operation_log` VALUES (1422, 1, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-20 20:06:20');
INSERT INTO `sys_operation_log` VALUES (1423, 1, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-20 20:06:20');
INSERT INTO `sys_operation_log` VALUES (1424, 1, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-20 20:06:20');
INSERT INTO `sys_operation_log` VALUES (1425, 1, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-20 20:06:51');
INSERT INTO `sys_operation_log` VALUES (1426, 1, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-20 20:06:51');
INSERT INTO `sys_operation_log` VALUES (1427, 1, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-20 20:06:56');
INSERT INTO `sys_operation_log` VALUES (1428, 1, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-20 20:06:56');
INSERT INTO `sys_operation_log` VALUES (1429, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 115ms', '2025-12-20 20:06:56');
INSERT INTO `sys_operation_log` VALUES (1430, 1, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-20 20:07:00');
INSERT INTO `sys_operation_log` VALUES (1431, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-20 20:38:10');
INSERT INTO `sys_operation_log` VALUES (1432, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 819ms', '2025-12-20 20:38:12');
INSERT INTO `sys_operation_log` VALUES (1433, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 287ms', '2025-12-20 20:38:12');
INSERT INTO `sys_operation_log` VALUES (1434, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 303ms', '2025-12-20 20:38:12');
INSERT INTO `sys_operation_log` VALUES (1435, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 310ms', '2025-12-20 20:38:12');
INSERT INTO `sys_operation_log` VALUES (1436, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-20 20:38:15');
INSERT INTO `sys_operation_log` VALUES (1437, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-20 20:38:15');
INSERT INTO `sys_operation_log` VALUES (1438, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 48ms', '2025-12-20 20:38:15');
INSERT INTO `sys_operation_log` VALUES (1439, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-20 20:38:16');
INSERT INTO `sys_operation_log` VALUES (1440, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-20 20:38:16');
INSERT INTO `sys_operation_log` VALUES (1441, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-20 20:38:16');
INSERT INTO `sys_operation_log` VALUES (1442, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-20 20:38:16');
INSERT INTO `sys_operation_log` VALUES (1443, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1444, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1445, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1446, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 89ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1447, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1448, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1449, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1450, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 58ms', '2025-12-20 20:38:23');
INSERT INTO `sys_operation_log` VALUES (1451, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 20:38:25');
INSERT INTO `sys_operation_log` VALUES (1452, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 20:38:25');
INSERT INTO `sys_operation_log` VALUES (1453, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-20 20:38:25');
INSERT INTO `sys_operation_log` VALUES (1454, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-20 20:38:27');
INSERT INTO `sys_operation_log` VALUES (1455, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 20:38:27');
INSERT INTO `sys_operation_log` VALUES (1456, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-20 20:38:27');
INSERT INTO `sys_operation_log` VALUES (1457, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-20 20:38:27');
INSERT INTO `sys_operation_log` VALUES (1458, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-20 20:38:28');
INSERT INTO `sys_operation_log` VALUES (1459, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-20 20:38:28');
INSERT INTO `sys_operation_log` VALUES (1460, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-20 20:38:28');
INSERT INTO `sys_operation_log` VALUES (1461, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 80ms', '2025-12-20 20:38:28');
INSERT INTO `sys_operation_log` VALUES (1462, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-20 20:38:31');
INSERT INTO `sys_operation_log` VALUES (1463, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-20 20:38:31');
INSERT INTO `sys_operation_log` VALUES (1464, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-20 20:38:35');
INSERT INTO `sys_operation_log` VALUES (1465, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-20 20:38:35');
INSERT INTO `sys_operation_log` VALUES (1466, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-20 20:38:36');
INSERT INTO `sys_operation_log` VALUES (1467, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-20 20:38:37');
INSERT INTO `sys_operation_log` VALUES (1468, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-20 20:38:38');
INSERT INTO `sys_operation_log` VALUES (1469, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-20 20:38:41');
INSERT INTO `sys_operation_log` VALUES (1470, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-20 20:38:41');
INSERT INTO `sys_operation_log` VALUES (1471, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-20 20:38:41');
INSERT INTO `sys_operation_log` VALUES (1472, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-20 20:38:43');
INSERT INTO `sys_operation_log` VALUES (1473, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-20 20:38:43');
INSERT INTO `sys_operation_log` VALUES (1474, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-20 20:38:43');
INSERT INTO `sys_operation_log` VALUES (1475, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-20 20:38:44');
INSERT INTO `sys_operation_log` VALUES (1476, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"区韦尔特\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"请问饿t\",\"optionSeq\":\"B\"}],\"questionContent\":\"特尔恩恩斯特\",\"questionType\":1}] | 耗时: 333ms', '2025-12-20 20:55:04');
INSERT INTO `sys_operation_log` VALUES (1477, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"区韦尔特\",\"optionSeq\":\"A\"},{\"isCorrect\":1,\"optionContent\":\"请问饿t\",\"optionSeq\":\"B\"},{\"isCorrect\":0,\"optionContent\":\"违法\",\"optionSeq\":\"C\"}],\"questionContent\":\"特尔恩恩斯特\",\"questionType\":2}] | 耗时: 15ms', '2025-12-20 20:55:25');
INSERT INTO `sys_operation_log` VALUES (1478, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-20 22:30:30');
INSERT INTO `sys_operation_log` VALUES (1479, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-20 22:30:30');
INSERT INTO `sys_operation_log` VALUES (1480, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-12-20 22:30:30');
INSERT INTO `sys_operation_log` VALUES (1481, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-20 22:30:30');
INSERT INTO `sys_operation_log` VALUES (1482, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-20 22:35:39');
INSERT INTO `sys_operation_log` VALUES (1483, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-20 22:35:39');
INSERT INTO `sys_operation_log` VALUES (1484, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-20 22:35:39');
INSERT INTO `sys_operation_log` VALUES (1485, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-20 22:35:39');
INSERT INTO `sys_operation_log` VALUES (1486, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-20 22:35:57');
INSERT INTO `sys_operation_log` VALUES (1487, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-20 22:35:57');
INSERT INTO `sys_operation_log` VALUES (1488, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-20 22:35:58');
INSERT INTO `sys_operation_log` VALUES (1489, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 22:35:59');
INSERT INTO `sys_operation_log` VALUES (1490, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-20 22:35:59');
INSERT INTO `sys_operation_log` VALUES (1491, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 22:36:00');
INSERT INTO `sys_operation_log` VALUES (1492, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-20 22:36:05');
INSERT INTO `sys_operation_log` VALUES (1493, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 22:36:09');
INSERT INTO `sys_operation_log` VALUES (1494, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-20 22:36:09');
INSERT INTO `sys_operation_log` VALUES (1495, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 22:36:11');
INSERT INTO `sys_operation_log` VALUES (1496, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 22:36:11');
INSERT INTO `sys_operation_log` VALUES (1497, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-20 22:36:12');
INSERT INTO `sys_operation_log` VALUES (1498, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 22:36:21');
INSERT INTO `sys_operation_log` VALUES (1499, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 22:36:23');
INSERT INTO `sys_operation_log` VALUES (1500, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-20 22:36:25');
INSERT INTO `sys_operation_log` VALUES (1501, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-20 22:36:25');
INSERT INTO `sys_operation_log` VALUES (1502, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-20 22:36:25');
INSERT INTO `sys_operation_log` VALUES (1503, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-20 22:36:36');
INSERT INTO `sys_operation_log` VALUES (1504, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-20 22:36:36');
INSERT INTO `sys_operation_log` VALUES (1505, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-20 22:36:37');
INSERT INTO `sys_operation_log` VALUES (1506, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-20 22:37:20');
INSERT INTO `sys_operation_log` VALUES (1507, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-20 22:37:20');
INSERT INTO `sys_operation_log` VALUES (1508, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-20 22:37:20');
INSERT INTO `sys_operation_log` VALUES (1509, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-20 22:37:21');
INSERT INTO `sys_operation_log` VALUES (1510, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-20 22:37:22');
INSERT INTO `sys_operation_log` VALUES (1511, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-20 22:48:36');
INSERT INTO `sys_operation_log` VALUES (1512, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6242ms', '2025-12-21 16:20:30');
INSERT INTO `sys_operation_log` VALUES (1513, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6247ms', '2025-12-21 16:20:30');
INSERT INTO `sys_operation_log` VALUES (1514, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6440ms', '2025-12-21 16:20:30');
INSERT INTO `sys_operation_log` VALUES (1515, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:20:43');
INSERT INTO `sys_operation_log` VALUES (1516, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-21 16:20:43');
INSERT INTO `sys_operation_log` VALUES (1517, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 492ms', '2025-12-21 16:20:43');
INSERT INTO `sys_operation_log` VALUES (1518, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:20:45');
INSERT INTO `sys_operation_log` VALUES (1519, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-21 16:20:45');
INSERT INTO `sys_operation_log` VALUES (1520, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-21 16:20:45');
INSERT INTO `sys_operation_log` VALUES (1521, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-21 16:20:45');
INSERT INTO `sys_operation_log` VALUES (1522, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-21 16:20:49');
INSERT INTO `sys_operation_log` VALUES (1523, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-21 16:20:49');
INSERT INTO `sys_operation_log` VALUES (1524, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 23ms', '2025-12-21 16:20:49');
INSERT INTO `sys_operation_log` VALUES (1525, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 123ms', '2025-12-21 16:20:49');
INSERT INTO `sys_operation_log` VALUES (1526, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 50ms', '2025-12-21 16:20:59');
INSERT INTO `sys_operation_log` VALUES (1527, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-21 16:21:17');
INSERT INTO `sys_operation_log` VALUES (1528, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-21 16:21:17');
INSERT INTO `sys_operation_log` VALUES (1529, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 22ms', '2025-12-21 16:21:17');
INSERT INTO `sys_operation_log` VALUES (1530, 0, '创建', '题库管理', '创建题库', NULL, '0:0:0:0:0:0:0:1', '[{\"bankName\":\"特殊土\",\"bankType\":1,\"description\":\"特色系统\",\"sort\":1}] | 耗时: 27ms', '2025-12-21 16:21:30');
INSERT INTO `sys_operation_log` VALUES (1531, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-21 16:21:30');
INSERT INTO `sys_operation_log` VALUES (1532, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-21 16:21:35');
INSERT INTO `sys_operation_log` VALUES (1533, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-21 16:21:38');
INSERT INTO `sys_operation_log` VALUES (1534, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[56,{\"bankId\":56,\"bankName\":\"特殊土\",\"bankType\":1,\"createTime\":\"2025-12-21 16:21:30\",\"deleted\":0,\"description\":\"特色系统\",\"orgId\":1,\"questionCount\":0,\"sort\":1,\"status\":1,\"updateTime\":\"2025-12-21 16:21:30\"}] | 耗时: 11ms', '2025-12-21 16:21:44');
INSERT INTO `sys_operation_log` VALUES (1535, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:21:44');
INSERT INTO `sys_operation_log` VALUES (1536, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:24:42');
INSERT INTO `sys_operation_log` VALUES (1537, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 377ms', '2025-12-21 16:24:46');
INSERT INTO `sys_operation_log` VALUES (1538, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:24:46');
INSERT INTO `sys_operation_log` VALUES (1539, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:24:46');
INSERT INTO `sys_operation_log` VALUES (1540, 0, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 334ms', '2025-12-21 16:24:46');
INSERT INTO `sys_operation_log` VALUES (1541, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:24:49');
INSERT INTO `sys_operation_log` VALUES (1542, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:24:49');
INSERT INTO `sys_operation_log` VALUES (1543, 0, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-21 16:24:49');
INSERT INTO `sys_operation_log` VALUES (1544, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:24:49');
INSERT INTO `sys_operation_log` VALUES (1545, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:24:49');
INSERT INTO `sys_operation_log` VALUES (1546, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:24:53');
INSERT INTO `sys_operation_log` VALUES (1547, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:24:53');
INSERT INTO `sys_operation_log` VALUES (1548, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 67ms', '2025-12-21 16:24:53');
INSERT INTO `sys_operation_log` VALUES (1549, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:24:55');
INSERT INTO `sys_operation_log` VALUES (1550, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-21 16:24:57');
INSERT INTO `sys_operation_log` VALUES (1551, 0, '查询', '组织管理', '查询组织树 | 错误: 您没有权限执行此操作：查看组织', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-21 16:24:58');
INSERT INTO `sys_operation_log` VALUES (1552, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-21 16:25:00');
INSERT INTO `sys_operation_log` VALUES (1553, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:25:00');
INSERT INTO `sys_operation_log` VALUES (1554, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:28:55');
INSERT INTO `sys_operation_log` VALUES (1555, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:28:55');
INSERT INTO `sys_operation_log` VALUES (1556, 0, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-21 16:28:55');
INSERT INTO `sys_operation_log` VALUES (1557, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:31:37');
INSERT INTO `sys_operation_log` VALUES (1558, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 224ms', '2025-12-21 16:31:40');
INSERT INTO `sys_operation_log` VALUES (1559, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-21 16:31:40');
INSERT INTO `sys_operation_log` VALUES (1560, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-21 16:31:40');
INSERT INTO `sys_operation_log` VALUES (1561, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-21 16:31:40');
INSERT INTO `sys_operation_log` VALUES (1562, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-21 16:31:42');
INSERT INTO `sys_operation_log` VALUES (1563, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:31:42');
INSERT INTO `sys_operation_log` VALUES (1564, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-21 16:31:42');
INSERT INTO `sys_operation_log` VALUES (1565, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[56,{\"bankId\":56,\"bankName\":\"test\",\"bankType\":1,\"createTime\":\"2025-12-21 16:21:30\",\"createUserId\":1,\"deleted\":0,\"description\":\"test\",\"orgId\":1,\"questionCount\":0,\"sort\":1,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-21 16:21:30\"}] | 耗时: 16ms', '2025-12-21 16:32:16');
INSERT INTO `sys_operation_log` VALUES (1566, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:32:16');
INSERT INTO `sys_operation_log` VALUES (1567, 0, '删除', '题库管理', '删除题库', NULL, '0:0:0:0:0:0:0:1', '[56] | 耗时: 17ms', '2025-12-21 16:32:22');
INSERT INTO `sys_operation_log` VALUES (1568, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:32:22');
INSERT INTO `sys_operation_log` VALUES (1569, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-21 16:32:32');
INSERT INTO `sys_operation_log` VALUES (1570, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:32:32');
INSERT INTO `sys_operation_log` VALUES (1571, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-21 16:32:32');
INSERT INTO `sys_operation_log` VALUES (1572, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-21 16:32:32');
INSERT INTO `sys_operation_log` VALUES (1573, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:33:03');
INSERT INTO `sys_operation_log` VALUES (1574, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:33:05');
INSERT INTO `sys_operation_log` VALUES (1575, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-21 16:33:13');
INSERT INTO `sys_operation_log` VALUES (1576, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:33:18');
INSERT INTO `sys_operation_log` VALUES (1577, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-21 16:35:37');
INSERT INTO `sys_operation_log` VALUES (1578, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:35:43');
INSERT INTO `sys_operation_log` VALUES (1579, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:35:50');
INSERT INTO `sys_operation_log` VALUES (1580, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:35:50');
INSERT INTO `sys_operation_log` VALUES (1581, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:35:50');
INSERT INTO `sys_operation_log` VALUES (1582, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:36:03');
INSERT INTO `sys_operation_log` VALUES (1583, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 16:36:03');
INSERT INTO `sys_operation_log` VALUES (1584, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:36:09');
INSERT INTO `sys_operation_log` VALUES (1585, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 63ms', '2025-12-21 16:42:00');
INSERT INTO `sys_operation_log` VALUES (1586, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 711ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1587, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 846ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1588, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2044ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1589, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2042ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1590, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2095ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1591, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 155ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1592, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1593, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 58ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1594, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1595, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 47ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1596, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 102ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1597, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1598, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 168ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1599, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-21 16:42:02');
INSERT INTO `sys_operation_log` VALUES (1600, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-21 16:42:03');
INSERT INTO `sys_operation_log` VALUES (1601, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 59ms', '2025-12-21 16:42:03');
INSERT INTO `sys_operation_log` VALUES (1602, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 2146ms', '2025-12-21 16:42:04');
INSERT INTO `sys_operation_log` VALUES (1603, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 25ms', '2025-12-21 16:42:04');
INSERT INTO `sys_operation_log` VALUES (1604, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 42ms', '2025-12-21 16:42:04');
INSERT INTO `sys_operation_log` VALUES (1605, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 47ms', '2025-12-21 16:42:05');
INSERT INTO `sys_operation_log` VALUES (1606, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 23ms', '2025-12-21 16:42:05');
INSERT INTO `sys_operation_log` VALUES (1607, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:42:08');
INSERT INTO `sys_operation_log` VALUES (1608, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-21 16:42:08');
INSERT INTO `sys_operation_log` VALUES (1609, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-21 16:42:08');
INSERT INTO `sys_operation_log` VALUES (1610, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:45:16');
INSERT INTO `sys_operation_log` VALUES (1611, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 16:45:16');
INSERT INTO `sys_operation_log` VALUES (1612, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-21 16:45:16');
INSERT INTO `sys_operation_log` VALUES (1613, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-21 16:45:16');
INSERT INTO `sys_operation_log` VALUES (1614, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-21 16:45:17');
INSERT INTO `sys_operation_log` VALUES (1615, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:45:17');
INSERT INTO `sys_operation_log` VALUES (1616, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-21 16:45:17');
INSERT INTO `sys_operation_log` VALUES (1617, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-21 16:45:21');
INSERT INTO `sys_operation_log` VALUES (1618, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-21 16:45:21');
INSERT INTO `sys_operation_log` VALUES (1619, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-21 16:45:21');
INSERT INTO `sys_operation_log` VALUES (1620, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 53ms', '2025-12-21 16:45:21');
INSERT INTO `sys_operation_log` VALUES (1621, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:45:22');
INSERT INTO `sys_operation_log` VALUES (1622, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:45:22');
INSERT INTO `sys_operation_log` VALUES (1623, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-21 16:45:22');
INSERT INTO `sys_operation_log` VALUES (1624, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:45:23');
INSERT INTO `sys_operation_log` VALUES (1625, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-21 16:45:23');
INSERT INTO `sys_operation_log` VALUES (1626, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-21 16:45:23');
INSERT INTO `sys_operation_log` VALUES (1627, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 24ms', '2025-12-21 16:45:23');
INSERT INTO `sys_operation_log` VALUES (1628, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-21 16:45:33');
INSERT INTO `sys_operation_log` VALUES (1629, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:45:33');
INSERT INTO `sys_operation_log` VALUES (1630, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-21 16:45:33');
INSERT INTO `sys_operation_log` VALUES (1631, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 16:45:37');
INSERT INTO `sys_operation_log` VALUES (1632, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:45:37');
INSERT INTO `sys_operation_log` VALUES (1633, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-21 16:45:37');
INSERT INTO `sys_operation_log` VALUES (1634, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-21 16:45:37');
INSERT INTO `sys_operation_log` VALUES (1635, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 16:45:46');
INSERT INTO `sys_operation_log` VALUES (1636, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-21 16:45:46');
INSERT INTO `sys_operation_log` VALUES (1637, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 18ms', '2025-12-21 16:45:46');
INSERT INTO `sys_operation_log` VALUES (1638, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 46ms', '2025-12-21 16:45:46');
INSERT INTO `sys_operation_log` VALUES (1639, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-12-21 16:54:26');
INSERT INTO `sys_operation_log` VALUES (1640, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 231ms', '2025-12-21 16:54:26');
INSERT INTO `sys_operation_log` VALUES (1641, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3761ms', '2025-12-21 16:54:26');
INSERT INTO `sys_operation_log` VALUES (1642, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 16:54:49');
INSERT INTO `sys_operation_log` VALUES (1643, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-21 16:54:49');
INSERT INTO `sys_operation_log` VALUES (1644, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-21 16:54:49');
INSERT INTO `sys_operation_log` VALUES (1645, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:54:51');
INSERT INTO `sys_operation_log` VALUES (1646, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 263ms', '2025-12-21 16:54:52');
INSERT INTO `sys_operation_log` VALUES (1647, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:54:53');
INSERT INTO `sys_operation_log` VALUES (1648, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:54:53');
INSERT INTO `sys_operation_log` VALUES (1649, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:54:53');
INSERT INTO `sys_operation_log` VALUES (1650, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:54:55');
INSERT INTO `sys_operation_log` VALUES (1651, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:54:55');
INSERT INTO `sys_operation_log` VALUES (1652, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-21 16:54:55');
INSERT INTO `sys_operation_log` VALUES (1653, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:56:01');
INSERT INTO `sys_operation_log` VALUES (1654, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 16:56:01');
INSERT INTO `sys_operation_log` VALUES (1655, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 16:56:01');
INSERT INTO `sys_operation_log` VALUES (1656, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 347ms', '2025-12-21 16:56:06');
INSERT INTO `sys_operation_log` VALUES (1657, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 326ms', '2025-12-21 16:56:06');
INSERT INTO `sys_operation_log` VALUES (1658, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 322ms', '2025-12-21 16:56:06');
INSERT INTO `sys_operation_log` VALUES (1659, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-21 16:56:07');
INSERT INTO `sys_operation_log` VALUES (1660, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:56:07');
INSERT INTO `sys_operation_log` VALUES (1661, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 16:56:07');
INSERT INTO `sys_operation_log` VALUES (1662, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 16:56:11');
INSERT INTO `sys_operation_log` VALUES (1663, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:56:11');
INSERT INTO `sys_operation_log` VALUES (1664, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 16:56:11');
INSERT INTO `sys_operation_log` VALUES (1665, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-21 16:56:30');
INSERT INTO `sys_operation_log` VALUES (1666, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 201ms', '2025-12-21 16:56:31');
INSERT INTO `sys_operation_log` VALUES (1667, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-21 16:56:32');
INSERT INTO `sys_operation_log` VALUES (1668, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 16:56:32');
INSERT INTO `sys_operation_log` VALUES (1669, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-21 16:56:32');
INSERT INTO `sys_operation_log` VALUES (1670, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-21 17:06:05');
INSERT INTO `sys_operation_log` VALUES (1671, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-21 17:06:05');
INSERT INTO `sys_operation_log` VALUES (1672, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-21 17:06:05');
INSERT INTO `sys_operation_log` VALUES (1673, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-21 17:06:08');
INSERT INTO `sys_operation_log` VALUES (1674, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-21 17:06:08');
INSERT INTO `sys_operation_log` VALUES (1675, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-21 17:06:08');
INSERT INTO `sys_operation_log` VALUES (1676, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 17:07:04');
INSERT INTO `sys_operation_log` VALUES (1677, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 17:07:04');
INSERT INTO `sys_operation_log` VALUES (1678, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:04');
INSERT INTO `sys_operation_log` VALUES (1679, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-21 17:07:06');
INSERT INTO `sys_operation_log` VALUES (1680, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 17:07:06');
INSERT INTO `sys_operation_log` VALUES (1681, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:06');
INSERT INTO `sys_operation_log` VALUES (1682, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-21 17:07:11');
INSERT INTO `sys_operation_log` VALUES (1683, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 17:07:11');
INSERT INTO `sys_operation_log` VALUES (1684, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:11');
INSERT INTO `sys_operation_log` VALUES (1685, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-21 17:07:13');
INSERT INTO `sys_operation_log` VALUES (1686, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 204ms', '2025-12-21 17:07:14');
INSERT INTO `sys_operation_log` VALUES (1687, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-21 17:07:14');
INSERT INTO `sys_operation_log` VALUES (1688, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 17:07:14');
INSERT INTO `sys_operation_log` VALUES (1689, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-21 17:07:14');
INSERT INTO `sys_operation_log` VALUES (1690, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-21 17:07:23');
INSERT INTO `sys_operation_log` VALUES (1691, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 17:07:23');
INSERT INTO `sys_operation_log` VALUES (1692, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:23');
INSERT INTO `sys_operation_log` VALUES (1693, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:25');
INSERT INTO `sys_operation_log` VALUES (1694, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:07:25');
INSERT INTO `sys_operation_log` VALUES (1695, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-21 17:07:25');
INSERT INTO `sys_operation_log` VALUES (1696, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-21 17:07:30');
INSERT INTO `sys_operation_log` VALUES (1697, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 17:07:30');
INSERT INTO `sys_operation_log` VALUES (1698, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-21 17:07:30');
INSERT INTO `sys_operation_log` VALUES (1699, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-21 17:08:27');
INSERT INTO `sys_operation_log` VALUES (1700, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-21 17:08:27');
INSERT INTO `sys_operation_log` VALUES (1701, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-21 17:08:28');
INSERT INTO `sys_operation_log` VALUES (1702, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 374ms', '2025-12-21 17:08:31');
INSERT INTO `sys_operation_log` VALUES (1703, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-21 17:08:31');
INSERT INTO `sys_operation_log` VALUES (1704, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 217ms', '2025-12-21 17:08:31');
INSERT INTO `sys_operation_log` VALUES (1705, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 210ms', '2025-12-22 00:47:15');
INSERT INTO `sys_operation_log` VALUES (1706, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 220ms', '2025-12-22 00:47:15');
INSERT INTO `sys_operation_log` VALUES (1707, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 216ms', '2025-12-22 00:47:15');
INSERT INTO `sys_operation_log` VALUES (1708, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:47:31');
INSERT INTO `sys_operation_log` VALUES (1709, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-22 00:47:31');
INSERT INTO `sys_operation_log` VALUES (1710, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 267ms', '2025-12-22 00:47:32');
INSERT INTO `sys_operation_log` VALUES (1711, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:47:33');
INSERT INTO `sys_operation_log` VALUES (1712, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 00:47:33');
INSERT INTO `sys_operation_log` VALUES (1713, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-22 00:47:33');
INSERT INTO `sys_operation_log` VALUES (1714, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 00:47:33');
INSERT INTO `sys_operation_log` VALUES (1715, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-22 00:47:35');
INSERT INTO `sys_operation_log` VALUES (1716, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-22 00:47:35');
INSERT INTO `sys_operation_log` VALUES (1717, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 00:47:35');
INSERT INTO `sys_operation_log` VALUES (1718, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:47:38');
INSERT INTO `sys_operation_log` VALUES (1719, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 00:47:39');
INSERT INTO `sys_operation_log` VALUES (1720, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 00:47:39');
INSERT INTO `sys_operation_log` VALUES (1721, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:47:44');
INSERT INTO `sys_operation_log` VALUES (1722, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:47:55');
INSERT INTO `sys_operation_log` VALUES (1723, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 00:47:55');
INSERT INTO `sys_operation_log` VALUES (1724, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 00:47:55');
INSERT INTO `sys_operation_log` VALUES (1725, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 00:47:55');
INSERT INTO `sys_operation_log` VALUES (1726, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:47:57');
INSERT INTO `sys_operation_log` VALUES (1727, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 00:47:57');
INSERT INTO `sys_operation_log` VALUES (1728, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 00:47:57');
INSERT INTO `sys_operation_log` VALUES (1729, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-12-22 00:47:57');
INSERT INTO `sys_operation_log` VALUES (1730, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:48:04');
INSERT INTO `sys_operation_log` VALUES (1731, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 00:48:04');
INSERT INTO `sys_operation_log` VALUES (1732, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:48:11');
INSERT INTO `sys_operation_log` VALUES (1733, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 00:48:11');
INSERT INTO `sys_operation_log` VALUES (1734, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 00:48:11');
INSERT INTO `sys_operation_log` VALUES (1735, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 00:48:14');
INSERT INTO `sys_operation_log` VALUES (1736, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 00:48:14');
INSERT INTO `sys_operation_log` VALUES (1737, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:48:17');
INSERT INTO `sys_operation_log` VALUES (1738, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:48:17');
INSERT INTO `sys_operation_log` VALUES (1739, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 00:48:17');
INSERT INTO `sys_operation_log` VALUES (1740, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:48:18');
INSERT INTO `sys_operation_log` VALUES (1741, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:48:18');
INSERT INTO `sys_operation_log` VALUES (1742, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:48:20');
INSERT INTO `sys_operation_log` VALUES (1743, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 00:48:20');
INSERT INTO `sys_operation_log` VALUES (1744, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1745, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1746, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1747, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1748, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1749, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1750, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 00:48:28');
INSERT INTO `sys_operation_log` VALUES (1751, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:48:30');
INSERT INTO `sys_operation_log` VALUES (1752, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:48:30');
INSERT INTO `sys_operation_log` VALUES (1753, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:48:33');
INSERT INTO `sys_operation_log` VALUES (1754, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:48:33');
INSERT INTO `sys_operation_log` VALUES (1755, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:48:36');
INSERT INTO `sys_operation_log` VALUES (1756, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:48:36');
INSERT INTO `sys_operation_log` VALUES (1757, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 00:48:36');
INSERT INTO `sys_operation_log` VALUES (1758, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-22 00:48:36');
INSERT INTO `sys_operation_log` VALUES (1759, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:48:42');
INSERT INTO `sys_operation_log` VALUES (1760, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:48:42');
INSERT INTO `sys_operation_log` VALUES (1761, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 00:48:42');
INSERT INTO `sys_operation_log` VALUES (1762, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 00:48:42');
INSERT INTO `sys_operation_log` VALUES (1763, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:49:22');
INSERT INTO `sys_operation_log` VALUES (1764, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 163ms', '2025-12-22 00:49:25');
INSERT INTO `sys_operation_log` VALUES (1765, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:49:25');
INSERT INTO `sys_operation_log` VALUES (1766, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:49:25');
INSERT INTO `sys_operation_log` VALUES (1767, 0, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 187ms', '2025-12-22 00:49:25');
INSERT INTO `sys_operation_log` VALUES (1768, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:29');
INSERT INTO `sys_operation_log` VALUES (1769, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:29');
INSERT INTO `sys_operation_log` VALUES (1770, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:29');
INSERT INTO `sys_operation_log` VALUES (1771, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:29');
INSERT INTO `sys_operation_log` VALUES (1772, 0, '查询', '题目管理', '分页查询题目 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT     subject_id     FROM  subject_user     WHERE deleted=0     AND (user_id = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:49:29');
INSERT INTO `sys_operation_log` VALUES (1773, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:49:30');
INSERT INTO `sys_operation_log` VALUES (1774, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:49:30');
INSERT INTO `sys_operation_log` VALUES (1775, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-22 00:49:30');
INSERT INTO `sys_operation_log` VALUES (1776, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:32');
INSERT INTO `sys_operation_log` VALUES (1777, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:49:43');
INSERT INTO `sys_operation_log` VALUES (1778, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 125ms', '2025-12-22 00:49:46');
INSERT INTO `sys_operation_log` VALUES (1779, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:49:46');
INSERT INTO `sys_operation_log` VALUES (1780, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:49:46');
INSERT INTO `sys_operation_log` VALUES (1781, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:49:46');
INSERT INTO `sys_operation_log` VALUES (1782, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:49:51');
INSERT INTO `sys_operation_log` VALUES (1783, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 00:49:51');
INSERT INTO `sys_operation_log` VALUES (1784, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 00:49:51');
INSERT INTO `sys_operation_log` VALUES (1785, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:50:36');
INSERT INTO `sys_operation_log` VALUES (1786, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:50:36');
INSERT INTO `sys_operation_log` VALUES (1787, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 00:50:36');
INSERT INTO `sys_operation_log` VALUES (1788, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 00:50:36');
INSERT INTO `sys_operation_log` VALUES (1789, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-22 00:50:40');
INSERT INTO `sys_operation_log` VALUES (1790, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:50:40');
INSERT INTO `sys_operation_log` VALUES (1791, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 00:50:40');
INSERT INTO `sys_operation_log` VALUES (1792, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-22 00:50:40');
INSERT INTO `sys_operation_log` VALUES (1793, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:50:47');
INSERT INTO `sys_operation_log` VALUES (1794, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:50:47');
INSERT INTO `sys_operation_log` VALUES (1795, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 00:50:47');
INSERT INTO `sys_operation_log` VALUES (1796, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:50:49');
INSERT INTO `sys_operation_log` VALUES (1797, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:50:49');
INSERT INTO `sys_operation_log` VALUES (1798, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 00:51:01');
INSERT INTO `sys_operation_log` VALUES (1799, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:51:01');
INSERT INTO `sys_operation_log` VALUES (1800, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:51:01');
INSERT INTO `sys_operation_log` VALUES (1801, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 00:51:01');
INSERT INTO `sys_operation_log` VALUES (1802, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 00:51:35');
INSERT INTO `sys_operation_log` VALUES (1803, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:51:35');
INSERT INTO `sys_operation_log` VALUES (1804, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 00:51:35');
INSERT INTO `sys_operation_log` VALUES (1805, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 00:51:37');
INSERT INTO `sys_operation_log` VALUES (1806, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:51:37');
INSERT INTO `sys_operation_log` VALUES (1807, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:51:38');
INSERT INTO `sys_operation_log` VALUES (1808, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 00:51:38');
INSERT INTO `sys_operation_log` VALUES (1809, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:51:38');
INSERT INTO `sys_operation_log` VALUES (1810, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 00:51:38');
INSERT INTO `sys_operation_log` VALUES (1811, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:51:55');
INSERT INTO `sys_operation_log` VALUES (1812, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:51:55');
INSERT INTO `sys_operation_log` VALUES (1813, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 00:51:55');
INSERT INTO `sys_operation_log` VALUES (1814, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 00:51:55');
INSERT INTO `sys_operation_log` VALUES (1815, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 00:58:39');
INSERT INTO `sys_operation_log` VALUES (1816, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 00:58:39');
INSERT INTO `sys_operation_log` VALUES (1817, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 00:58:39');
INSERT INTO `sys_operation_log` VALUES (1818, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 00:58:39');
INSERT INTO `sys_operation_log` VALUES (1819, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 125ms', '2025-12-22 01:06:12');
INSERT INTO `sys_operation_log` VALUES (1820, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 01:06:20');
INSERT INTO `sys_operation_log` VALUES (1821, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-22 01:06:25');
INSERT INTO `sys_operation_log` VALUES (1822, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 01:06:32');
INSERT INTO `sys_operation_log` VALUES (1823, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-22 01:06:35');
INSERT INTO `sys_operation_log` VALUES (1824, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 01:06:54');
INSERT INTO `sys_operation_log` VALUES (1825, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 01:06:54');
INSERT INTO `sys_operation_log` VALUES (1826, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:06:55');
INSERT INTO `sys_operation_log` VALUES (1827, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 01:06:55');
INSERT INTO `sys_operation_log` VALUES (1828, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 457ms', '2025-12-22 01:22:07');
INSERT INTO `sys_operation_log` VALUES (1829, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 149ms', '2025-12-22 01:22:07');
INSERT INTO `sys_operation_log` VALUES (1830, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 154ms', '2025-12-22 01:22:07');
INSERT INTO `sys_operation_log` VALUES (1831, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 156ms', '2025-12-22 01:22:07');
INSERT INTO `sys_operation_log` VALUES (1832, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 01:22:09');
INSERT INTO `sys_operation_log` VALUES (1833, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 01:22:09');
INSERT INTO `sys_operation_log` VALUES (1834, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 22ms', '2025-12-22 01:22:09');
INSERT INTO `sys_operation_log` VALUES (1835, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 01:22:11');
INSERT INTO `sys_operation_log` VALUES (1836, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 01:22:11');
INSERT INTO `sys_operation_log` VALUES (1837, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:24:26');
INSERT INTO `sys_operation_log` VALUES (1838, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-22 01:24:26');
INSERT INTO `sys_operation_log` VALUES (1839, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-22 01:24:26');
INSERT INTO `sys_operation_log` VALUES (1840, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-22 01:24:26');
INSERT INTO `sys_operation_log` VALUES (1841, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 01:24:27');
INSERT INTO `sys_operation_log` VALUES (1842, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 01:24:27');
INSERT INTO `sys_operation_log` VALUES (1843, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 01:24:27');
INSERT INTO `sys_operation_log` VALUES (1844, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 01:24:28');
INSERT INTO `sys_operation_log` VALUES (1845, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-12-22 01:24:28');
INSERT INTO `sys_operation_log` VALUES (1846, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 01:24:30');
INSERT INTO `sys_operation_log` VALUES (1847, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 01:24:30');
INSERT INTO `sys_operation_log` VALUES (1848, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-22 01:24:30');
INSERT INTO `sys_operation_log` VALUES (1849, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:24:32');
INSERT INTO `sys_operation_log` VALUES (1850, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 01:24:32');
INSERT INTO `sys_operation_log` VALUES (1851, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:24:33');
INSERT INTO `sys_operation_log` VALUES (1852, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 01:24:33');
INSERT INTO `sys_operation_log` VALUES (1853, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 01:24:34');
INSERT INTO `sys_operation_log` VALUES (1854, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:24:34');
INSERT INTO `sys_operation_log` VALUES (1855, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:24:34');
INSERT INTO `sys_operation_log` VALUES (1856, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 01:24:34');
INSERT INTO `sys_operation_log` VALUES (1857, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:24:34');
INSERT INTO `sys_operation_log` VALUES (1858, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[234,{\"bankId\":1,\"defaultScore\":3,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"违法\",\"optionSeq\":\"A\"}],\"questionContent\":\"下列哪个关键字用于定义Java类？\",\"questionId\":234,\"questionType\":1}] | 耗时: 58ms', '2025-12-22 01:25:45');
INSERT INTO `sys_operation_log` VALUES (1859, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-22 01:25:45');
INSERT INTO `sys_operation_log` VALUES (1860, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:26:58');
INSERT INTO `sys_operation_log` VALUES (1861, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 01:26:58');
INSERT INTO `sys_operation_log` VALUES (1862, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:26:58');
INSERT INTO `sys_operation_log` VALUES (1863, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:26:59');
INSERT INTO `sys_operation_log` VALUES (1864, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 01:26:59');
INSERT INTO `sys_operation_log` VALUES (1865, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:27:14');
INSERT INTO `sys_operation_log` VALUES (1866, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:27:14');
INSERT INTO `sys_operation_log` VALUES (1867, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 01:27:14');
INSERT INTO `sys_operation_log` VALUES (1868, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 01:27:14');
INSERT INTO `sys_operation_log` VALUES (1869, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:27:21');
INSERT INTO `sys_operation_log` VALUES (1870, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:27:21');
INSERT INTO `sys_operation_log` VALUES (1871, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 01:27:21');
INSERT INTO `sys_operation_log` VALUES (1872, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:27:22');
INSERT INTO `sys_operation_log` VALUES (1873, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:27:22');
INSERT INTO `sys_operation_log` VALUES (1874, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 01:29:42');
INSERT INTO `sys_operation_log` VALUES (1875, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 01:29:42');
INSERT INTO `sys_operation_log` VALUES (1876, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 01:29:42');
INSERT INTO `sys_operation_log` VALUES (1877, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 01:29:42');
INSERT INTO `sys_operation_log` VALUES (1878, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:31:50');
INSERT INTO `sys_operation_log` VALUES (1879, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:31:50');
INSERT INTO `sys_operation_log` VALUES (1880, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 01:31:50');
INSERT INTO `sys_operation_log` VALUES (1881, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 01:31:52');
INSERT INTO `sys_operation_log` VALUES (1882, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:31:52');
INSERT INTO `sys_operation_log` VALUES (1883, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:31:53');
INSERT INTO `sys_operation_log` VALUES (1884, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:31:53');
INSERT INTO `sys_operation_log` VALUES (1885, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:31:53');
INSERT INTO `sys_operation_log` VALUES (1886, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 01:31:53');
INSERT INTO `sys_operation_log` VALUES (1887, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:32:04');
INSERT INTO `sys_operation_log` VALUES (1888, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 01:32:04');
INSERT INTO `sys_operation_log` VALUES (1889, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:32:04');
INSERT INTO `sys_operation_log` VALUES (1890, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:32:06');
INSERT INTO `sys_operation_log` VALUES (1891, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:32:06');
INSERT INTO `sys_operation_log` VALUES (1892, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 01:32:07');
INSERT INTO `sys_operation_log` VALUES (1893, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:32:07');
INSERT INTO `sys_operation_log` VALUES (1894, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 01:32:07');
INSERT INTO `sys_operation_log` VALUES (1895, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:32:07');
INSERT INTO `sys_operation_log` VALUES (1896, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:32:13');
INSERT INTO `sys_operation_log` VALUES (1897, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:32:13');
INSERT INTO `sys_operation_log` VALUES (1898, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:32:13');
INSERT INTO `sys_operation_log` VALUES (1899, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3ms', '2025-12-22 01:32:13');
INSERT INTO `sys_operation_log` VALUES (1900, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:32:21');
INSERT INTO `sys_operation_log` VALUES (1901, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:32:21');
INSERT INTO `sys_operation_log` VALUES (1902, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:32:21');
INSERT INTO `sys_operation_log` VALUES (1903, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 01:32:22');
INSERT INTO `sys_operation_log` VALUES (1904, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 01:32:22');
INSERT INTO `sys_operation_log` VALUES (1905, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 01:32:24');
INSERT INTO `sys_operation_log` VALUES (1906, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:32:24');
INSERT INTO `sys_operation_log` VALUES (1907, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 01:32:24');
INSERT INTO `sys_operation_log` VALUES (1908, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 01:32:53');
INSERT INTO `sys_operation_log` VALUES (1909, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 01:32:53');
INSERT INTO `sys_operation_log` VALUES (1910, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 01:43:02');
INSERT INTO `sys_operation_log` VALUES (1911, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 163ms', '2025-12-22 01:43:02');
INSERT INTO `sys_operation_log` VALUES (1912, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 224ms', '2025-12-22 01:43:02');
INSERT INTO `sys_operation_log` VALUES (1913, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 136ms', '2025-12-22 01:53:32');
INSERT INTO `sys_operation_log` VALUES (1914, 1, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 01:53:37');
INSERT INTO `sys_operation_log` VALUES (1915, 1, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-22 01:53:45');
INSERT INTO `sys_operation_log` VALUES (1916, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-22 01:53:50');
INSERT INTO `sys_operation_log` VALUES (1917, 1, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 01:53:55');
INSERT INTO `sys_operation_log` VALUES (1918, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1190ms', '2025-12-22 01:56:31');
INSERT INTO `sys_operation_log` VALUES (1919, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1142ms', '2025-12-22 01:56:31');
INSERT INTO `sys_operation_log` VALUES (1920, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1152ms', '2025-12-22 01:56:31');
INSERT INTO `sys_operation_log` VALUES (1921, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 01:56:36');
INSERT INTO `sys_operation_log` VALUES (1922, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-22 01:56:36');
INSERT INTO `sys_operation_log` VALUES (1923, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 195ms', '2025-12-22 01:56:36');
INSERT INTO `sys_operation_log` VALUES (1924, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:04:43');
INSERT INTO `sys_operation_log` VALUES (1925, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 02:04:43');
INSERT INTO `sys_operation_log` VALUES (1926, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:04:43');
INSERT INTO `sys_operation_log` VALUES (1927, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:04:45');
INSERT INTO `sys_operation_log` VALUES (1928, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:04:45');
INSERT INTO `sys_operation_log` VALUES (1929, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-22 02:04:45');
INSERT INTO `sys_operation_log` VALUES (1930, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:09:54');
INSERT INTO `sys_operation_log` VALUES (1931, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-12-22 02:09:54');
INSERT INTO `sys_operation_log` VALUES (1932, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 64ms', '2025-12-22 02:09:54');
INSERT INTO `sys_operation_log` VALUES (1933, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 25ms', '2025-12-22 02:09:54');
INSERT INTO `sys_operation_log` VALUES (1934, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:09:59');
INSERT INTO `sys_operation_log` VALUES (1935, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-22 02:09:59');
INSERT INTO `sys_operation_log` VALUES (1936, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 02:09:59');
INSERT INTO `sys_operation_log` VALUES (1937, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 421ms', '2025-12-22 02:09:59');
INSERT INTO `sys_operation_log` VALUES (1938, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:10:13');
INSERT INTO `sys_operation_log` VALUES (1939, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:10:13');
INSERT INTO `sys_operation_log` VALUES (1940, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:10:13');
INSERT INTO `sys_operation_log` VALUES (1941, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 02:10:13');
INSERT INTO `sys_operation_log` VALUES (1942, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:10:22');
INSERT INTO `sys_operation_log` VALUES (1943, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:10:22');
INSERT INTO `sys_operation_log` VALUES (1944, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-22 02:10:22');
INSERT INTO `sys_operation_log` VALUES (1945, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:10:22');
INSERT INTO `sys_operation_log` VALUES (1946, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 02:10:42');
INSERT INTO `sys_operation_log` VALUES (1947, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:10:50');
INSERT INTO `sys_operation_log` VALUES (1948, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:10:50');
INSERT INTO `sys_operation_log` VALUES (1949, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:10:50');
INSERT INTO `sys_operation_log` VALUES (1950, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:10:50');
INSERT INTO `sys_operation_log` VALUES (1951, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:10:58');
INSERT INTO `sys_operation_log` VALUES (1952, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:10:58');
INSERT INTO `sys_operation_log` VALUES (1953, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:10:58');
INSERT INTO `sys_operation_log` VALUES (1954, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 02:10:58');
INSERT INTO `sys_operation_log` VALUES (1955, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-22 02:11:40');
INSERT INTO `sys_operation_log` VALUES (1956, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:11:40');
INSERT INTO `sys_operation_log` VALUES (1957, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:11:40');
INSERT INTO `sys_operation_log` VALUES (1958, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 02:11:40');
INSERT INTO `sys_operation_log` VALUES (1959, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:11:46');
INSERT INTO `sys_operation_log` VALUES (1960, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:11:46');
INSERT INTO `sys_operation_log` VALUES (1961, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:11:46');
INSERT INTO `sys_operation_log` VALUES (1962, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 02:11:46');
INSERT INTO `sys_operation_log` VALUES (1963, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:11:50');
INSERT INTO `sys_operation_log` VALUES (1964, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:11:51');
INSERT INTO `sys_operation_log` VALUES (1965, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 02:11:51');
INSERT INTO `sys_operation_log` VALUES (1966, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:16:36');
INSERT INTO `sys_operation_log` VALUES (1967, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:16:36');
INSERT INTO `sys_operation_log` VALUES (1968, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:16:36');
INSERT INTO `sys_operation_log` VALUES (1969, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:16:36');
INSERT INTO `sys_operation_log` VALUES (1970, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:16:39');
INSERT INTO `sys_operation_log` VALUES (1971, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 127ms', '2025-12-22 02:16:39');
INSERT INTO `sys_operation_log` VALUES (1972, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 134ms', '2025-12-22 02:16:39');
INSERT INTO `sys_operation_log` VALUES (1973, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 25ms', '2025-12-22 02:16:39');
INSERT INTO `sys_operation_log` VALUES (1974, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-22 02:16:45');
INSERT INTO `sys_operation_log` VALUES (1975, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:16:45');
INSERT INTO `sys_operation_log` VALUES (1976, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-22 02:16:45');
INSERT INTO `sys_operation_log` VALUES (1977, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 132ms', '2025-12-22 02:16:46');
INSERT INTO `sys_operation_log` VALUES (1978, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 130ms', '2025-12-22 02:16:46');
INSERT INTO `sys_operation_log` VALUES (1979, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 161ms', '2025-12-22 02:16:49');
INSERT INTO `sys_operation_log` VALUES (1980, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:16:59');
INSERT INTO `sys_operation_log` VALUES (1981, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[53,{\"questionIds\":[235,234]}] | 耗时: 22ms', '2025-12-22 02:17:07');
INSERT INTO `sys_operation_log` VALUES (1982, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:17:13');
INSERT INTO `sys_operation_log` VALUES (1983, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:17:21');
INSERT INTO `sys_operation_log` VALUES (1984, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:17:21');
INSERT INTO `sys_operation_log` VALUES (1985, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:17:22');
INSERT INTO `sys_operation_log` VALUES (1986, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:17:32');
INSERT INTO `sys_operation_log` VALUES (1987, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[53,{\"questionIds\":[234]}] | 耗时: 4ms', '2025-12-22 02:17:35');
INSERT INTO `sys_operation_log` VALUES (1988, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:17:45');
INSERT INTO `sys_operation_log` VALUES (1989, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:17:48');
INSERT INTO `sys_operation_log` VALUES (1990, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[53,{\"questionIds\":[235,234]}] | 耗时: 5ms', '2025-12-22 02:17:55');
INSERT INTO `sys_operation_log` VALUES (1991, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[53,264] | 耗时: 18ms', '2025-12-22 02:18:10');
INSERT INTO `sys_operation_log` VALUES (1992, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:18:11');
INSERT INTO `sys_operation_log` VALUES (1993, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:18:11');
INSERT INTO `sys_operation_log` VALUES (1994, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:18:16');
INSERT INTO `sys_operation_log` VALUES (1995, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:18:16');
INSERT INTO `sys_operation_log` VALUES (1996, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 02:18:16');
INSERT INTO `sys_operation_log` VALUES (1997, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:18:17');
INSERT INTO `sys_operation_log` VALUES (1998, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:18:17');
INSERT INTO `sys_operation_log` VALUES (1999, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:21:28');
INSERT INTO `sys_operation_log` VALUES (2000, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:21:33');
INSERT INTO `sys_operation_log` VALUES (2001, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[53,{\"questionIds\":[234]}] | 耗时: 4ms', '2025-12-22 02:21:42');
INSERT INTO `sys_operation_log` VALUES (2002, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 94ms', '2025-12-22 02:22:48');
INSERT INTO `sys_operation_log` VALUES (2003, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:22:58');
INSERT INTO `sys_operation_log` VALUES (2004, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 02:22:58');
INSERT INTO `sys_operation_log` VALUES (2005, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 65ms', '2025-12-22 02:22:58');
INSERT INTO `sys_operation_log` VALUES (2006, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-12-22 02:23:01');
INSERT INTO `sys_operation_log` VALUES (2007, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 75ms', '2025-12-22 02:23:01');
INSERT INTO `sys_operation_log` VALUES (2008, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,234] | 耗时: 249ms', '2025-12-22 02:23:05');
INSERT INTO `sys_operation_log` VALUES (2009, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:23:05');
INSERT INTO `sys_operation_log` VALUES (2010, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:23:05');
INSERT INTO `sys_operation_log` VALUES (2011, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 604ms', '2025-12-22 02:27:33');
INSERT INTO `sys_operation_log` VALUES (2012, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[1,{\"questionIds\":[234,235,236,237,238,239,240,241,242,243]}] | 耗时: 387ms', '2025-12-22 02:27:39');
INSERT INTO `sys_operation_log` VALUES (2013, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-22 02:27:41');
INSERT INTO `sys_operation_log` VALUES (2014, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 149ms', '2025-12-22 02:27:43');
INSERT INTO `sys_operation_log` VALUES (2015, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 02:27:45');
INSERT INTO `sys_operation_log` VALUES (2016, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 02:27:45');
INSERT INTO `sys_operation_log` VALUES (2017, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 36ms', '2025-12-22 02:27:46');
INSERT INTO `sys_operation_log` VALUES (2018, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"默认题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":14,\"sort\":0,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-22 02:25:09\"}] | 耗时: 48ms', '2025-12-22 02:27:51');
INSERT INTO `sys_operation_log` VALUES (2019, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 312ms', '2025-12-22 02:27:51');
INSERT INTO `sys_operation_log` VALUES (2020, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2021, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 151ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2022, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 152ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2023, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2024, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2025, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2026, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-22 02:27:52');
INSERT INTO `sys_operation_log` VALUES (2027, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":1,\"sort\":4,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-20 15:30:37\"}] | 耗时: 12ms', '2025-12-22 02:27:56');
INSERT INTO `sys_operation_log` VALUES (2028, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:27:56');
INSERT INTO `sys_operation_log` VALUES (2029, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"默认题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":14,\"sort\":5,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-22 02:25:09\"}] | 耗时: 13ms', '2025-12-22 02:28:02');
INSERT INTO `sys_operation_log` VALUES (2030, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 104ms', '2025-12-22 02:28:02');
INSERT INTO `sys_operation_log` VALUES (2031, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 288ms', '2025-12-22 02:28:08');
INSERT INTO `sys_operation_log` VALUES (2032, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 282ms', '2025-12-22 02:28:08');
INSERT INTO `sys_operation_log` VALUES (2033, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:28:10');
INSERT INTO `sys_operation_log` VALUES (2034, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 249ms', '2025-12-22 02:28:11');
INSERT INTO `sys_operation_log` VALUES (2035, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 276ms', '2025-12-22 02:28:11');
INSERT INTO `sys_operation_log` VALUES (2036, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-22 02:28:11');
INSERT INTO `sys_operation_log` VALUES (2037, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:28:13');
INSERT INTO `sys_operation_log` VALUES (2038, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 313ms', '2025-12-22 02:28:13');
INSERT INTO `sys_operation_log` VALUES (2039, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 34ms', '2025-12-22 02:28:13');
INSERT INTO `sys_operation_log` VALUES (2040, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 136ms', '2025-12-22 02:28:16');
INSERT INTO `sys_operation_log` VALUES (2041, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 142ms', '2025-12-22 02:28:16');
INSERT INTO `sys_operation_log` VALUES (2042, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 282ms', '2025-12-22 02:28:17');
INSERT INTO `sys_operation_log` VALUES (2043, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:28:21');
INSERT INTO `sys_operation_log` VALUES (2044, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[53,{\"questionIds\":[234,235,236,237,238,239,240,241,242,243]}] | 耗时: 1120ms', '2025-12-22 02:28:25');
INSERT INTO `sys_operation_log` VALUES (2045, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 402ms', '2025-12-22 02:28:25');
INSERT INTO `sys_operation_log` VALUES (2046, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:28:25');
INSERT INTO `sys_operation_log` VALUES (2047, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:28:27');
INSERT INTO `sys_operation_log` VALUES (2048, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 175ms', '2025-12-22 02:28:27');
INSERT INTO `sys_operation_log` VALUES (2049, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 02:28:27');
INSERT INTO `sys_operation_log` VALUES (2050, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 245ms', '2025-12-22 02:28:29');
INSERT INTO `sys_operation_log` VALUES (2051, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 256ms', '2025-12-22 02:28:29');
INSERT INTO `sys_operation_log` VALUES (2052, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:28:33');
INSERT INTO `sys_operation_log` VALUES (2053, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 323ms', '2025-12-22 02:28:34');
INSERT INTO `sys_operation_log` VALUES (2054, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 325ms', '2025-12-22 02:28:34');
INSERT INTO `sys_operation_log` VALUES (2055, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 02:28:34');
INSERT INTO `sys_operation_log` VALUES (2056, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:28:36');
INSERT INTO `sys_operation_log` VALUES (2057, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:28:38');
INSERT INTO `sys_operation_log` VALUES (2058, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:30:32');
INSERT INTO `sys_operation_log` VALUES (2059, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-22 02:30:32');
INSERT INTO `sys_operation_log` VALUES (2060, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 02:30:32');
INSERT INTO `sys_operation_log` VALUES (2061, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:30:33');
INSERT INTO `sys_operation_log` VALUES (2062, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:30:33');
INSERT INTO `sys_operation_log` VALUES (2063, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:30:34');
INSERT INTO `sys_operation_log` VALUES (2064, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:30:34');
INSERT INTO `sys_operation_log` VALUES (2065, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 02:30:34');
INSERT INTO `sys_operation_log` VALUES (2066, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:30:36');
INSERT INTO `sys_operation_log` VALUES (2067, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-22 02:30:36');
INSERT INTO `sys_operation_log` VALUES (2068, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,247] | 耗时: 33ms', '2025-12-22 02:30:39');
INSERT INTO `sys_operation_log` VALUES (2069, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 02:30:39');
INSERT INTO `sys_operation_log` VALUES (2070, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:30:39');
INSERT INTO `sys_operation_log` VALUES (2071, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:30:43');
INSERT INTO `sys_operation_log` VALUES (2072, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 02:30:43');
INSERT INTO `sys_operation_log` VALUES (2073, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,244] | 耗时: 21ms', '2025-12-22 02:30:48');
INSERT INTO `sys_operation_log` VALUES (2074, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 02:30:49');
INSERT INTO `sys_operation_log` VALUES (2075, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:30:49');
INSERT INTO `sys_operation_log` VALUES (2076, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:30:54');
INSERT INTO `sys_operation_log` VALUES (2077, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-22 02:30:54');
INSERT INTO `sys_operation_log` VALUES (2078, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-22 02:30:54');
INSERT INTO `sys_operation_log` VALUES (2079, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 02:30:54');
INSERT INTO `sys_operation_log` VALUES (2080, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:31:17');
INSERT INTO `sys_operation_log` VALUES (2081, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:31:17');
INSERT INTO `sys_operation_log` VALUES (2082, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 02:31:17');
INSERT INTO `sys_operation_log` VALUES (2083, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:31:19');
INSERT INTO `sys_operation_log` VALUES (2084, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:31:19');
INSERT INTO `sys_operation_log` VALUES (2085, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,244] | 耗时: 16ms', '2025-12-22 02:31:23');
INSERT INTO `sys_operation_log` VALUES (2086, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:31:24');
INSERT INTO `sys_operation_log` VALUES (2087, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:31:24');
INSERT INTO `sys_operation_log` VALUES (2088, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,244] | 耗时: 22ms', '2025-12-22 02:31:44');
INSERT INTO `sys_operation_log` VALUES (2089, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:31:45');
INSERT INTO `sys_operation_log` VALUES (2090, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:31:45');
INSERT INTO `sys_operation_log` VALUES (2091, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[1,244] | 耗时: 19ms', '2025-12-22 02:31:49');
INSERT INTO `sys_operation_log` VALUES (2092, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:31:49');
INSERT INTO `sys_operation_log` VALUES (2093, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:31:50');
INSERT INTO `sys_operation_log` VALUES (2094, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-22 02:36:38');
INSERT INTO `sys_operation_log` VALUES (2095, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:36:39');
INSERT INTO `sys_operation_log` VALUES (2096, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 791ms', '2025-12-22 02:36:39');
INSERT INTO `sys_operation_log` VALUES (2097, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1012ms', '2025-12-22 02:36:39');
INSERT INTO `sys_operation_log` VALUES (2098, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 689ms', '2025-12-22 02:36:39');
INSERT INTO `sys_operation_log` VALUES (2099, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1095ms', '2025-12-22 02:36:40');
INSERT INTO `sys_operation_log` VALUES (2100, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:36:40');
INSERT INTO `sys_operation_log` VALUES (2101, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 63ms', '2025-12-22 02:36:40');
INSERT INTO `sys_operation_log` VALUES (2102, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 51ms', '2025-12-22 02:36:40');
INSERT INTO `sys_operation_log` VALUES (2103, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 20ms', '2025-12-22 02:36:40');
INSERT INTO `sys_operation_log` VALUES (2104, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 259ms', '2025-12-22 02:36:44');
INSERT INTO `sys_operation_log` VALUES (2105, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-22 02:36:44');
INSERT INTO `sys_operation_log` VALUES (2106, 0, '更新', '题库管理', '移除题目', NULL, '0:0:0:0:0:0:0:1', '[53,234] | 耗时: 183ms', '2025-12-22 02:36:46');
INSERT INTO `sys_operation_log` VALUES (2107, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 116ms', '2025-12-22 02:36:47');
INSERT INTO `sys_operation_log` VALUES (2108, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:36:47');
INSERT INTO `sys_operation_log` VALUES (2109, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 02:36:48');
INSERT INTO `sys_operation_log` VALUES (2110, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:36:48');
INSERT INTO `sys_operation_log` VALUES (2111, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 02:36:48');
INSERT INTO `sys_operation_log` VALUES (2112, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 260ms', '2025-12-22 02:36:49');
INSERT INTO `sys_operation_log` VALUES (2113, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 263ms', '2025-12-22 02:36:49');
INSERT INTO `sys_operation_log` VALUES (2114, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:36:51');
INSERT INTO `sys_operation_log` VALUES (2115, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 283ms', '2025-12-22 02:36:52');
INSERT INTO `sys_operation_log` VALUES (2116, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 286ms', '2025-12-22 02:36:52');
INSERT INTO `sys_operation_log` VALUES (2117, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-22 02:36:52');
INSERT INTO `sys_operation_log` VALUES (2118, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:36:54');
INSERT INTO `sys_operation_log` VALUES (2119, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 211ms', '2025-12-22 02:36:54');
INSERT INTO `sys_operation_log` VALUES (2120, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 220ms', '2025-12-22 02:36:54');
INSERT INTO `sys_operation_log` VALUES (2121, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 02:36:54');
INSERT INTO `sys_operation_log` VALUES (2122, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:36:58');
INSERT INTO `sys_operation_log` VALUES (2123, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:36:58');
INSERT INTO `sys_operation_log` VALUES (2124, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 20ms', '2025-12-22 02:36:58');
INSERT INTO `sys_operation_log` VALUES (2125, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 174ms', '2025-12-22 02:37:02');
INSERT INTO `sys_operation_log` VALUES (2126, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 188ms', '2025-12-22 02:37:02');
INSERT INTO `sys_operation_log` VALUES (2127, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:37:05');
INSERT INTO `sys_operation_log` VALUES (2128, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 419ms', '2025-12-22 02:37:05');
INSERT INTO `sys_operation_log` VALUES (2129, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 437ms', '2025-12-22 02:37:05');
INSERT INTO `sys_operation_log` VALUES (2130, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 18ms', '2025-12-22 02:37:05');
INSERT INTO `sys_operation_log` VALUES (2131, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"sat\",\"optionSeq\":\"A\"}],\"questionContent\":\"testtste\",\"questionType\":1}] | 耗时: 175ms', '2025-12-22 02:37:18');
INSERT INTO `sys_operation_log` VALUES (2132, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"sat\",\"optionSeq\":\"A\"}],\"questionContent\":\"testtste\",\"questionType\":1}] | 耗时: 386ms', '2025-12-22 02:37:43');
INSERT INTO `sys_operation_log` VALUES (2133, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":1,\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"sat\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"sdfg\",\"optionSeq\":\"B\"}],\"questionContent\":\"testtste\",\"questionType\":1}] | 耗时: 101ms', '2025-12-22 02:37:54');
INSERT INTO `sys_operation_log` VALUES (2134, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:43:15');
INSERT INTO `sys_operation_log` VALUES (2135, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 151ms', '2025-12-22 02:43:15');
INSERT INTO `sys_operation_log` VALUES (2136, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 02:43:15');
INSERT INTO `sys_operation_log` VALUES (2137, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:43:16');
INSERT INTO `sys_operation_log` VALUES (2138, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 391ms', '2025-12-22 02:43:16');
INSERT INTO `sys_operation_log` VALUES (2139, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 389ms', '2025-12-22 02:43:16');
INSERT INTO `sys_operation_log` VALUES (2140, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 02:43:16');
INSERT INTO `sys_operation_log` VALUES (2141, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:43:17');
INSERT INTO `sys_operation_log` VALUES (2142, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:43:17');
INSERT INTO `sys_operation_log` VALUES (2143, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 02:43:17');
INSERT INTO `sys_operation_log` VALUES (2144, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:43:19');
INSERT INTO `sys_operation_log` VALUES (2145, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 312ms', '2025-12-22 02:43:19');
INSERT INTO `sys_operation_log` VALUES (2146, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 316ms', '2025-12-22 02:43:19');
INSERT INTO `sys_operation_log` VALUES (2147, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 02:43:19');
INSERT INTO `sys_operation_log` VALUES (2148, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:43:20');
INSERT INTO `sys_operation_log` VALUES (2149, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 02:43:20');
INSERT INTO `sys_operation_log` VALUES (2150, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-22 02:43:20');
INSERT INTO `sys_operation_log` VALUES (2151, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:43:21');
INSERT INTO `sys_operation_log` VALUES (2152, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 389ms', '2025-12-22 02:43:21');
INSERT INTO `sys_operation_log` VALUES (2153, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 392ms', '2025-12-22 02:43:21');
INSERT INTO `sys_operation_log` VALUES (2154, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 02:43:21');
INSERT INTO `sys_operation_log` VALUES (2155, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:43:22');
INSERT INTO `sys_operation_log` VALUES (2156, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 168ms', '2025-12-22 02:43:22');
INSERT INTO `sys_operation_log` VALUES (2157, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-22 02:43:22');
INSERT INTO `sys_operation_log` VALUES (2158, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 219ms', '2025-12-22 02:43:22');
INSERT INTO `sys_operation_log` VALUES (2159, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:43:23');
INSERT INTO `sys_operation_log` VALUES (2160, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 02:43:23');
INSERT INTO `sys_operation_log` VALUES (2161, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 02:43:23');
INSERT INTO `sys_operation_log` VALUES (2162, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:43:24');
INSERT INTO `sys_operation_log` VALUES (2163, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 267ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2164, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 270ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2165, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2166, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2167, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2168, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 02:43:25');
INSERT INTO `sys_operation_log` VALUES (2169, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:43:26');
INSERT INTO `sys_operation_log` VALUES (2170, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 02:43:26');
INSERT INTO `sys_operation_log` VALUES (2171, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:43:26');
INSERT INTO `sys_operation_log` VALUES (2172, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:43:26');
INSERT INTO `sys_operation_log` VALUES (2173, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:44:15');
INSERT INTO `sys_operation_log` VALUES (2174, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:44:15');
INSERT INTO `sys_operation_log` VALUES (2175, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:44:15');
INSERT INTO `sys_operation_log` VALUES (2176, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 02:44:15');
INSERT INTO `sys_operation_log` VALUES (2177, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:44:17');
INSERT INTO `sys_operation_log` VALUES (2178, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 02:44:17');
INSERT INTO `sys_operation_log` VALUES (2179, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:44:17');
INSERT INTO `sys_operation_log` VALUES (2180, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:44:17');
INSERT INTO `sys_operation_log` VALUES (2181, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:44:19');
INSERT INTO `sys_operation_log` VALUES (2182, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:44:19');
INSERT INTO `sys_operation_log` VALUES (2183, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 02:44:19');
INSERT INTO `sys_operation_log` VALUES (2184, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 02:44:19');
INSERT INTO `sys_operation_log` VALUES (2185, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:52:05');
INSERT INTO `sys_operation_log` VALUES (2186, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:52:05');
INSERT INTO `sys_operation_log` VALUES (2187, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:52:05');
INSERT INTO `sys_operation_log` VALUES (2188, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 02:52:05');
INSERT INTO `sys_operation_log` VALUES (2189, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 02:52:08');
INSERT INTO `sys_operation_log` VALUES (2190, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 306ms', '2025-12-22 02:52:08');
INSERT INTO `sys_operation_log` VALUES (2191, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 296ms', '2025-12-22 02:52:08');
INSERT INTO `sys_operation_log` VALUES (2192, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 379ms', '2025-12-22 02:52:09');
INSERT INTO `sys_operation_log` VALUES (2193, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:52:43');
INSERT INTO `sys_operation_log` VALUES (2194, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:52:46');
INSERT INTO `sys_operation_log` VALUES (2195, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 158ms', '2025-12-22 02:52:46');
INSERT INTO `sys_operation_log` VALUES (2196, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 155ms', '2025-12-22 02:52:46');
INSERT INTO `sys_operation_log` VALUES (2197, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-22 02:52:46');
INSERT INTO `sys_operation_log` VALUES (2198, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[235,{\"bankId\":53,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":0,\"optionContent\":\"v\",\"optionSeq\":\"A\"},{\"isCorrect\":1,\"optionContent\":\"x\",\"optionSeq\":\"B\"}],\"questionContent\":\"Java中的String类是否可以被继承？\",\"questionId\":235,\"questionType\":4}] | 耗时: 34ms', '2025-12-22 02:53:08');
INSERT INTO `sys_operation_log` VALUES (2199, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 02:53:09');
INSERT INTO `sys_operation_log` VALUES (2200, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 02:53:11');
INSERT INTO `sys_operation_log` VALUES (2201, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 136ms', '2025-12-22 02:53:12');
INSERT INTO `sys_operation_log` VALUES (2202, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 132ms', '2025-12-22 02:53:12');
INSERT INTO `sys_operation_log` VALUES (2203, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-22 02:53:12');
INSERT INTO `sys_operation_log` VALUES (2204, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 245ms', '2025-12-22 02:53:44');
INSERT INTO `sys_operation_log` VALUES (2205, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 349ms', '2025-12-22 02:53:47');
INSERT INTO `sys_operation_log` VALUES (2206, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 285ms', '2025-12-22 02:53:49');
INSERT INTO `sys_operation_log` VALUES (2207, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"bankId\":53,\"defaultScore\":2,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 195ms', '2025-12-22 02:54:35');
INSERT INTO `sys_operation_log` VALUES (2208, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"tr\",\"bankId\":53,\"correctAnswer\":\"\",\"defaultScore\":2,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 742ms', '2025-12-22 02:55:37');
INSERT INTO `sys_operation_log` VALUES (2209, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"tr\",\"bankId\":53,\"correctAnswer\":\"\",\"defaultScore\":2,\"difficulty\":3,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"t\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"s\",\"optionSeq\":\"B\"}],\"questionContent\":\"testts\",\"questionType\":1}] | 耗时: 21ms', '2025-12-22 02:55:38');
INSERT INTO `sys_operation_log` VALUES (2210, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 02:55:52');
INSERT INTO `sys_operation_log` VALUES (2211, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 179ms', '2025-12-22 02:55:52');
INSERT INTO `sys_operation_log` VALUES (2212, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 90ms', '2025-12-22 02:55:52');
INSERT INTO `sys_operation_log` VALUES (2213, 0, '创建', '题库管理', '创建题库', NULL, '0:0:0:0:0:0:0:1', '[{\"bankName\":\"tees他\",\"bankType\":1,\"description\":\"斯特\",\"sort\":0}] | 耗时: 210ms', '2025-12-22 02:55:58');
INSERT INTO `sys_operation_log` VALUES (2214, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:55:58');
INSERT INTO `sys_operation_log` VALUES (2215, 0, '删除', '题库管理', '删除题库', NULL, '0:0:0:0:0:0:0:1', '[57] | 耗时: 18ms', '2025-12-22 02:56:00');
INSERT INTO `sys_operation_log` VALUES (2216, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-22 02:56:00');
INSERT INTO `sys_operation_log` VALUES (2217, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:56:02');
INSERT INTO `sys_operation_log` VALUES (2218, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 111ms', '2025-12-22 02:56:03');
INSERT INTO `sys_operation_log` VALUES (2219, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-22 02:56:03');
INSERT INTO `sys_operation_log` VALUES (2220, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 556ms', '2025-12-22 02:56:03');
INSERT INTO `sys_operation_log` VALUES (2221, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-22 02:56:09');
INSERT INTO `sys_operation_log` VALUES (2222, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 02:56:13');
INSERT INTO `sys_operation_log` VALUES (2223, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 02:56:15');
INSERT INTO `sys_operation_log` VALUES (2224, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 02:56:17');
INSERT INTO `sys_operation_log` VALUES (2225, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 02:56:22');
INSERT INTO `sys_operation_log` VALUES (2226, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 02:56:26');
INSERT INTO `sys_operation_log` VALUES (2227, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"\",\"bankId\":53,\"correctAnswer\":\"\",\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"安文丰\",\"optionSeq\":\"A\"}],\"questionContent\":\"违法阿飞啊额\",\"questionType\":1}] | 耗时: 126ms', '2025-12-22 02:56:49');
INSERT INTO `sys_operation_log` VALUES (2228, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 02:59:57');
INSERT INTO `sys_operation_log` VALUES (2229, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 68ms', '2025-12-22 02:59:57');
INSERT INTO `sys_operation_log` VALUES (2230, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 68ms', '2025-12-22 02:59:57');
INSERT INTO `sys_operation_log` VALUES (2231, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 02:59:57');
INSERT INTO `sys_operation_log` VALUES (2232, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 03:13:41');
INSERT INTO `sys_operation_log` VALUES (2233, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 03:13:41');
INSERT INTO `sys_operation_log` VALUES (2234, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 03:13:41');
INSERT INTO `sys_operation_log` VALUES (2235, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 03:13:41');
INSERT INTO `sys_operation_log` VALUES (2236, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 03:13:47');
INSERT INTO `sys_operation_log` VALUES (2237, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 96ms', '2025-12-22 03:13:47');
INSERT INTO `sys_operation_log` VALUES (2238, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 97ms', '2025-12-22 03:13:47');
INSERT INTO `sys_operation_log` VALUES (2239, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 53ms', '2025-12-22 03:13:47');
INSERT INTO `sys_operation_log` VALUES (2240, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 03:13:49');
INSERT INTO `sys_operation_log` VALUES (2241, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 234ms', '2025-12-22 03:13:50');
INSERT INTO `sys_operation_log` VALUES (2242, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 239ms', '2025-12-22 03:13:50');
INSERT INTO `sys_operation_log` VALUES (2243, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 28ms', '2025-12-22 03:13:50');
INSERT INTO `sys_operation_log` VALUES (2244, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"\",\"bankId\":1,\"correctAnswer\":\"\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":0,\"optionContent\":\"其他\",\"optionSeq\":\"A\"}],\"questionContent\":\"特殊土其他\",\"questionType\":1}] | 耗时: 16ms', '2025-12-22 03:14:05');
INSERT INTO `sys_operation_log` VALUES (2245, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"test\",\"bankId\":1,\"correctAnswer\":\"\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"rwar\",\"optionSeq\":\"B\"}],\"questionContent\":\"testtest\",\"questionType\":1}] | 耗时: 11ms', '2025-12-22 03:14:38');
INSERT INTO `sys_operation_log` VALUES (2246, 0, '创建', '题目管理', '创建题目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/question/QuestionMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.question.QuestionMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO question  ( bank_id, org_id, question_content,  default_score,  knowledge_ids,        audit_status,    create_user_id, status, create_time, update_time )  VALUES (  ?, ?, ?,  ?,  ?,        ?,    ?, ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'question_type\' doesn\'t have a default value\n; Field \'question_type\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"test\",\"bankId\":1,\"correctAnswer\":\"\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"rwar\",\"optionSeq\":\"B\"}],\"questionContent\":\"testtest\",\"questionType\":1}] | 耗时: 11ms', '2025-12-22 03:23:07');
INSERT INTO `sys_operation_log` VALUES (2247, 0, '创建', '题目管理', '创建题目', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"test\",\"bankId\":1,\"correctAnswer\":\"\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"test\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"rwar\",\"optionSeq\":\"B\"}],\"questionContent\":\"testtest\",\"questionType\":1}] | 耗时: 883ms', '2025-12-22 03:47:55');
INSERT INTO `sys_operation_log` VALUES (2248, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 335ms', '2025-12-22 03:47:56');
INSERT INTO `sys_operation_log` VALUES (2249, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-22 03:53:32');
INSERT INTO `sys_operation_log` VALUES (2250, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 97ms', '2025-12-22 03:53:32');
INSERT INTO `sys_operation_log` VALUES (2251, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 115ms', '2025-12-22 03:53:32');
INSERT INTO `sys_operation_log` VALUES (2252, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-22 03:53:32');
INSERT INTO `sys_operation_log` VALUES (2253, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 03:55:53');
INSERT INTO `sys_operation_log` VALUES (2254, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 03:55:53');
INSERT INTO `sys_operation_log` VALUES (2255, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 03:55:53');
INSERT INTO `sys_operation_log` VALUES (2256, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 03:55:53');
INSERT INTO `sys_operation_log` VALUES (2257, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-22 04:00:19');
INSERT INTO `sys_operation_log` VALUES (2258, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 139ms', '2025-12-22 04:00:19');
INSERT INTO `sys_operation_log` VALUES (2259, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 188ms', '2025-12-22 04:00:19');
INSERT INTO `sys_operation_log` VALUES (2260, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 340ms', '2025-12-22 04:00:19');
INSERT INTO `sys_operation_log` VALUES (2261, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[235,{\"analysis\":\"正确答案是不能。String类被final修饰，无法被继承。\",\"bankId\":53,\"correctAnswer\":\"B\",\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-12-22 02:53:08\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"x\",\"optionId\":337,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":235,\"sort\":0,\"updateTime\":\"2025-12-22 02:53:08\"}],\"questionContent\":\"Java中的String类是否可以被继承？\",\"questionId\":235,\"questionType\":4}] | 耗时: 62ms', '2025-12-22 04:00:24');
INSERT INTO `sys_operation_log` VALUES (2262, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-22 04:00:25');
INSERT INTO `sys_operation_log` VALUES (2263, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 04:00:35');
INSERT INTO `sys_operation_log` VALUES (2264, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 173ms', '2025-12-22 04:00:35');
INSERT INTO `sys_operation_log` VALUES (2265, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 169ms', '2025-12-22 04:00:35');
INSERT INTO `sys_operation_log` VALUES (2266, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-22 04:00:35');
INSERT INTO `sys_operation_log` VALUES (2267, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 04:00:37');
INSERT INTO `sys_operation_log` VALUES (2268, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 135ms', '2025-12-22 04:00:37');
INSERT INTO `sys_operation_log` VALUES (2269, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 144ms', '2025-12-22 04:00:37');
INSERT INTO `sys_operation_log` VALUES (2270, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 04:00:37');
INSERT INTO `sys_operation_log` VALUES (2271, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:00:40');
INSERT INTO `sys_operation_log` VALUES (2272, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 126ms', '2025-12-22 04:00:40');
INSERT INTO `sys_operation_log` VALUES (2273, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 135ms', '2025-12-22 04:00:40');
INSERT INTO `sys_operation_log` VALUES (2274, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-22 04:00:40');
INSERT INTO `sys_operation_log` VALUES (2275, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:00:44');
INSERT INTO `sys_operation_log` VALUES (2276, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 83ms', '2025-12-22 04:00:44');
INSERT INTO `sys_operation_log` VALUES (2277, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-22 04:00:44');
INSERT INTO `sys_operation_log` VALUES (2278, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 623ms', '2025-12-22 04:00:45');
INSERT INTO `sys_operation_log` VALUES (2279, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:00:56');
INSERT INTO `sys_operation_log` VALUES (2280, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 389ms', '2025-12-22 04:00:56');
INSERT INTO `sys_operation_log` VALUES (2281, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 50ms', '2025-12-22 04:00:56');
INSERT INTO `sys_operation_log` VALUES (2282, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 858ms', '2025-12-22 04:00:57');
INSERT INTO `sys_operation_log` VALUES (2283, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 15ms', '2025-12-22 04:01:05');
INSERT INTO `sys_operation_log` VALUES (2284, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 04:01:12');
INSERT INTO `sys_operation_log` VALUES (2285, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 238ms', '2025-12-22 04:01:12');
INSERT INTO `sys_operation_log` VALUES (2286, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 04:01:12');
INSERT INTO `sys_operation_log` VALUES (2287, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 274ms', '2025-12-22 04:01:12');
INSERT INTO `sys_operation_log` VALUES (2288, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:01:13');
INSERT INTO `sys_operation_log` VALUES (2289, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 66ms', '2025-12-22 04:01:13');
INSERT INTO `sys_operation_log` VALUES (2290, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 04:01:15');
INSERT INTO `sys_operation_log` VALUES (2291, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 04:01:15');
INSERT INTO `sys_operation_log` VALUES (2292, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 04:01:15');
INSERT INTO `sys_operation_log` VALUES (2293, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 473ms', '2025-12-22 04:01:15');
INSERT INTO `sys_operation_log` VALUES (2294, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 04:01:42');
INSERT INTO `sys_operation_log` VALUES (2295, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 185ms', '2025-12-22 04:01:43');
INSERT INTO `sys_operation_log` VALUES (2296, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 04:01:43');
INSERT INTO `sys_operation_log` VALUES (2297, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 213ms', '2025-12-22 04:01:43');
INSERT INTO `sys_operation_log` VALUES (2298, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 392ms', '2025-12-22 04:01:54');
INSERT INTO `sys_operation_log` VALUES (2299, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 13ms', '2025-12-22 04:02:00');
INSERT INTO `sys_operation_log` VALUES (2300, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:02:10');
INSERT INTO `sys_operation_log` VALUES (2301, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 131ms', '2025-12-22 04:02:11');
INSERT INTO `sys_operation_log` VALUES (2302, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 04:02:11');
INSERT INTO `sys_operation_log` VALUES (2303, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 154ms', '2025-12-22 04:02:11');
INSERT INTO `sys_operation_log` VALUES (2304, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 198ms', '2025-12-22 04:02:22');
INSERT INTO `sys_operation_log` VALUES (2305, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 3ms', '2025-12-22 04:02:28');
INSERT INTO `sys_operation_log` VALUES (2306, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 221ms', '2025-12-22 04:04:39');
INSERT INTO `sys_operation_log` VALUES (2307, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 147ms', '2025-12-22 04:04:39');
INSERT INTO `sys_operation_log` VALUES (2308, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1291ms', '2025-12-22 04:04:45');
INSERT INTO `sys_operation_log` VALUES (2309, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1315ms', '2025-12-22 04:04:45');
INSERT INTO `sys_operation_log` VALUES (2310, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1332ms', '2025-12-22 04:04:45');
INSERT INTO `sys_operation_log` VALUES (2311, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 252ms', '2025-12-22 04:08:52');
INSERT INTO `sys_operation_log` VALUES (2312, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 289ms', '2025-12-22 04:08:52');
INSERT INTO `sys_operation_log` VALUES (2313, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 04:08:52');
INSERT INTO `sys_operation_log` VALUES (2314, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:08:55');
INSERT INTO `sys_operation_log` VALUES (2315, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 291ms', '2025-12-22 04:08:55');
INSERT INTO `sys_operation_log` VALUES (2316, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 315ms', '2025-12-22 04:08:55');
INSERT INTO `sys_operation_log` VALUES (2317, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 04:08:55');
INSERT INTO `sys_operation_log` VALUES (2318, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:09:07');
INSERT INTO `sys_operation_log` VALUES (2319, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 154ms', '2025-12-22 04:09:07');
INSERT INTO `sys_operation_log` VALUES (2320, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 04:09:07');
INSERT INTO `sys_operation_log` VALUES (2321, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 172ms', '2025-12-22 04:09:07');
INSERT INTO `sys_operation_log` VALUES (2322, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:09:22');
INSERT INTO `sys_operation_log` VALUES (2323, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 358ms', '2025-12-22 04:09:22');
INSERT INTO `sys_operation_log` VALUES (2324, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 403ms', '2025-12-22 04:09:22');
INSERT INTO `sys_operation_log` VALUES (2325, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 802ms', '2025-12-22 04:09:22');
INSERT INTO `sys_operation_log` VALUES (2326, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 343ms', '2025-12-22 04:09:27');
INSERT INTO `sys_operation_log` VALUES (2327, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 4ms', '2025-12-22 04:09:31');
INSERT INTO `sys_operation_log` VALUES (2328, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 04:10:31');
INSERT INTO `sys_operation_log` VALUES (2329, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 171ms', '2025-12-22 04:10:31');
INSERT INTO `sys_operation_log` VALUES (2330, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-22 04:10:31');
INSERT INTO `sys_operation_log` VALUES (2331, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 599ms', '2025-12-22 04:10:31');
INSERT INTO `sys_operation_log` VALUES (2332, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 04:10:35');
INSERT INTO `sys_operation_log` VALUES (2333, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 125ms', '2025-12-22 04:10:35');
INSERT INTO `sys_operation_log` VALUES (2334, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 385ms', '2025-12-22 04:10:35');
INSERT INTO `sys_operation_log` VALUES (2335, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 919ms', '2025-12-22 04:10:36');
INSERT INTO `sys_operation_log` VALUES (2336, 0, '删除', '试卷管理', '删除试卷', NULL, '0:0:0:0:0:0:0:1', '[9] | 耗时: 16ms', '2025-12-22 04:10:38');
INSERT INTO `sys_operation_log` VALUES (2337, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 378ms', '2025-12-22 04:10:38');
INSERT INTO `sys_operation_log` VALUES (2338, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 04:10:53');
INSERT INTO `sys_operation_log` VALUES (2339, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 215ms', '2025-12-22 04:10:53');
INSERT INTO `sys_operation_log` VALUES (2340, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 04:10:53');
INSERT INTO `sys_operation_log` VALUES (2341, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 242ms', '2025-12-22 04:10:53');
INSERT INTO `sys_operation_log` VALUES (2342, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 144ms', '2025-12-22 04:10:59');
INSERT INTO `sys_operation_log` VALUES (2343, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 4ms', '2025-12-22 04:11:07');
INSERT INTO `sys_operation_log` VALUES (2344, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:19:33');
INSERT INTO `sys_operation_log` VALUES (2345, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 301ms', '2025-12-22 04:19:33');
INSERT INTO `sys_operation_log` VALUES (2346, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 1198ms', '2025-12-22 04:19:34');
INSERT INTO `sys_operation_log` VALUES (2347, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1907ms', '2025-12-22 04:19:35');
INSERT INTO `sys_operation_log` VALUES (2348, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 293ms', '2025-12-22 04:20:04');
INSERT INTO `sys_operation_log` VALUES (2349, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 3ms', '2025-12-22 04:20:08');
INSERT INTO `sys_operation_log` VALUES (2350, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:20:18');
INSERT INTO `sys_operation_log` VALUES (2351, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 282ms', '2025-12-22 04:20:18');
INSERT INTO `sys_operation_log` VALUES (2352, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 04:20:18');
INSERT INTO `sys_operation_log` VALUES (2353, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 299ms', '2025-12-22 04:20:18');
INSERT INTO `sys_operation_log` VALUES (2354, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 04:20:28');
INSERT INTO `sys_operation_log` VALUES (2355, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 242ms', '2025-12-22 04:20:28');
INSERT INTO `sys_operation_log` VALUES (2356, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 04:20:28');
INSERT INTO `sys_operation_log` VALUES (2357, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 265ms', '2025-12-22 04:20:28');
INSERT INTO `sys_operation_log` VALUES (2358, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 04:20:33');
INSERT INTO `sys_operation_log` VALUES (2359, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 202ms', '2025-12-22 04:20:33');
INSERT INTO `sys_operation_log` VALUES (2360, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-22 04:20:33');
INSERT INTO `sys_operation_log` VALUES (2361, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 224ms', '2025-12-22 04:20:33');
INSERT INTO `sys_operation_log` VALUES (2362, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:20:36');
INSERT INTO `sys_operation_log` VALUES (2363, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 102ms', '2025-12-22 04:20:36');
INSERT INTO `sys_operation_log` VALUES (2364, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 04:20:36');
INSERT INTO `sys_operation_log` VALUES (2365, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 527ms', '2025-12-22 04:20:37');
INSERT INTO `sys_operation_log` VALUES (2366, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:20:53');
INSERT INTO `sys_operation_log` VALUES (2367, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 43ms', '2025-12-22 04:20:53');
INSERT INTO `sys_operation_log` VALUES (2368, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 198ms', '2025-12-22 04:20:56');
INSERT INTO `sys_operation_log` VALUES (2369, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 194ms', '2025-12-22 04:20:56');
INSERT INTO `sys_operation_log` VALUES (2370, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-22 04:20:56');
INSERT INTO `sys_operation_log` VALUES (2371, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 8ms', '2025-12-22 04:21:02');
INSERT INTO `sys_operation_log` VALUES (2372, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 306ms', '2025-12-22 04:21:12');
INSERT INTO `sys_operation_log` VALUES (2373, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 301ms', '2025-12-22 04:21:12');
INSERT INTO `sys_operation_log` VALUES (2374, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-22 04:21:12');
INSERT INTO `sys_operation_log` VALUES (2375, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 123ms', '2025-12-22 04:21:17');
INSERT INTO `sys_operation_log` VALUES (2376, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 04:21:18');
INSERT INTO `sys_operation_log` VALUES (2377, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 5ms', '2025-12-22 04:21:19');
INSERT INTO `sys_operation_log` VALUES (2378, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:21:24');
INSERT INTO `sys_operation_log` VALUES (2379, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 182ms', '2025-12-22 04:21:24');
INSERT INTO `sys_operation_log` VALUES (2380, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 5ms', '2025-12-22 04:21:26');
INSERT INTO `sys_operation_log` VALUES (2381, 0, '查询', '科目管理', '查询科目学生 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT COUNT(*) AS total FROM subject_user WHERE deleted = 0 AND (subject_id = ? AND user_type = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 156ms', '2025-12-22 04:21:32');
INSERT INTO `sys_operation_log` VALUES (2382, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:21:35');
INSERT INTO `sys_operation_log` VALUES (2383, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 04:21:35');
INSERT INTO `sys_operation_log` VALUES (2384, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:21:41');
INSERT INTO `sys_operation_log` VALUES (2385, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 04:21:50');
INSERT INTO `sys_operation_log` VALUES (2386, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 322ms', '2025-12-22 04:21:50');
INSERT INTO `sys_operation_log` VALUES (2387, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 04:21:50');
INSERT INTO `sys_operation_log` VALUES (2388, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 351ms', '2025-12-22 04:21:50');
INSERT INTO `sys_operation_log` VALUES (2389, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:22:56');
INSERT INTO `sys_operation_log` VALUES (2390, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 04:22:56');
INSERT INTO `sys_operation_log` VALUES (2391, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 04:23:02');
INSERT INTO `sys_operation_log` VALUES (2392, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 352ms', '2025-12-22 04:23:02');
INSERT INTO `sys_operation_log` VALUES (2393, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 377ms', '2025-12-22 04:23:02');
INSERT INTO `sys_operation_log` VALUES (2394, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 409ms', '2025-12-22 04:23:02');
INSERT INTO `sys_operation_log` VALUES (2395, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 105ms', '2025-12-22 04:24:08');
INSERT INTO `sys_operation_log` VALUES (2396, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 10ms', '2025-12-22 04:24:15');
INSERT INTO `sys_operation_log` VALUES (2397, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 16:42:56');
INSERT INTO `sys_operation_log` VALUES (2398, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 346ms', '2025-12-22 16:43:11');
INSERT INTO `sys_operation_log` VALUES (2399, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 16:43:12');
INSERT INTO `sys_operation_log` VALUES (2400, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-22 16:43:12');
INSERT INTO `sys_operation_log` VALUES (2401, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-22 16:43:12');
INSERT INTO `sys_operation_log` VALUES (2402, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 16:43:14');
INSERT INTO `sys_operation_log` VALUES (2403, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 16:43:14');
INSERT INTO `sys_operation_log` VALUES (2404, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 19ms', '2025-12-22 16:43:14');
INSERT INTO `sys_operation_log` VALUES (2405, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 16:43:17');
INSERT INTO `sys_operation_log` VALUES (2406, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 16:43:17');
INSERT INTO `sys_operation_log` VALUES (2407, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 16:43:17');
INSERT INTO `sys_operation_log` VALUES (2408, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 16:43:17');
INSERT INTO `sys_operation_log` VALUES (2409, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 16:43:23');
INSERT INTO `sys_operation_log` VALUES (2410, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 16:43:23');
INSERT INTO `sys_operation_log` VALUES (2411, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-22 16:43:23');
INSERT INTO `sys_operation_log` VALUES (2412, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-12-22 16:43:23');
INSERT INTO `sys_operation_log` VALUES (2413, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 16:46:09');
INSERT INTO `sys_operation_log` VALUES (2414, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 16:46:09');
INSERT INTO `sys_operation_log` VALUES (2415, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 16:46:12');
INSERT INTO `sys_operation_log` VALUES (2416, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 16:46:12');
INSERT INTO `sys_operation_log` VALUES (2417, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-22 16:46:12');
INSERT INTO `sys_operation_log` VALUES (2418, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 16:46:14');
INSERT INTO `sys_operation_log` VALUES (2419, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 16:46:14');
INSERT INTO `sys_operation_log` VALUES (2420, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 16:46:14');
INSERT INTO `sys_operation_log` VALUES (2421, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-22 16:46:14');
INSERT INTO `sys_operation_log` VALUES (2422, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 16:46:17');
INSERT INTO `sys_operation_log` VALUES (2423, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 16:46:17');
INSERT INTO `sys_operation_log` VALUES (2424, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 16:46:17');
INSERT INTO `sys_operation_log` VALUES (2425, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 16:46:17');
INSERT INTO `sys_operation_log` VALUES (2426, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 16:46:23');
INSERT INTO `sys_operation_log` VALUES (2427, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 16:46:23');
INSERT INTO `sys_operation_log` VALUES (2428, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3ms', '2025-12-22 16:46:23');
INSERT INTO `sys_operation_log` VALUES (2429, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-22 16:46:23');
INSERT INTO `sys_operation_log` VALUES (2430, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-22 16:47:10');
INSERT INTO `sys_operation_log` VALUES (2431, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 12ms', '2025-12-22 16:47:14');
INSERT INTO `sys_operation_log` VALUES (2432, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 7ms', '2025-12-22 16:49:04');
INSERT INTO `sys_operation_log` VALUES (2433, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 16:50:23');
INSERT INTO `sys_operation_log` VALUES (2434, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 16:50:23');
INSERT INTO `sys_operation_log` VALUES (2435, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 16:50:23');
INSERT INTO `sys_operation_log` VALUES (2436, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 50ms', '2025-12-22 16:50:23');
INSERT INTO `sys_operation_log` VALUES (2437, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 17:10:22');
INSERT INTO `sys_operation_log` VALUES (2438, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 17:10:22');
INSERT INTO `sys_operation_log` VALUES (2439, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-22 17:10:22');
INSERT INTO `sys_operation_log` VALUES (2440, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 17:10:22');
INSERT INTO `sys_operation_log` VALUES (2441, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 17:10:32');
INSERT INTO `sys_operation_log` VALUES (2442, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 975ms', '2025-12-22 17:10:33');
INSERT INTO `sys_operation_log` VALUES (2443, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1608ms', '2025-12-22 17:10:34');
INSERT INTO `sys_operation_log` VALUES (2444, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 55ms', '2025-12-22 17:10:34');
INSERT INTO `sys_operation_log` VALUES (2445, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 17:10:35');
INSERT INTO `sys_operation_log` VALUES (2446, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2448ms', '2025-12-22 17:10:37');
INSERT INTO `sys_operation_log` VALUES (2447, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3132ms', '2025-12-22 17:10:38');
INSERT INTO `sys_operation_log` VALUES (2448, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3774ms', '2025-12-22 17:10:39');
INSERT INTO `sys_operation_log` VALUES (2449, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 122ms', '2025-12-22 17:10:45');
INSERT INTO `sys_operation_log` VALUES (2450, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 17:10:53');
INSERT INTO `sys_operation_log` VALUES (2451, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 80ms', '2025-12-22 17:10:53');
INSERT INTO `sys_operation_log` VALUES (2452, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 165ms', '2025-12-22 17:10:53');
INSERT INTO `sys_operation_log` VALUES (2453, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 200ms', '2025-12-22 17:10:53');
INSERT INTO `sys_operation_log` VALUES (2454, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 17:11:08');
INSERT INTO `sys_operation_log` VALUES (2455, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 17:12:01');
INSERT INTO `sys_operation_log` VALUES (2456, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 17:12:01');
INSERT INTO `sys_operation_log` VALUES (2457, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-22 17:12:01');
INSERT INTO `sys_operation_log` VALUES (2458, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 17:12:01');
INSERT INTO `sys_operation_log` VALUES (2459, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 17ms', '2025-12-22 17:12:13');
INSERT INTO `sys_operation_log` VALUES (2460, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 17:12:26');
INSERT INTO `sys_operation_log` VALUES (2461, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 17:12:26');
INSERT INTO `sys_operation_log` VALUES (2462, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 17:12:26');
INSERT INTO `sys_operation_log` VALUES (2463, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-22 17:12:26');
INSERT INTO `sys_operation_log` VALUES (2464, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 17:12:37');
INSERT INTO `sys_operation_log` VALUES (2465, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 17:15:58');
INSERT INTO `sys_operation_log` VALUES (2466, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 17:15:58');
INSERT INTO `sys_operation_log` VALUES (2467, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 17:15:58');
INSERT INTO `sys_operation_log` VALUES (2468, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 17:16:43');
INSERT INTO `sys_operation_log` VALUES (2469, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 17:16:43');
INSERT INTO `sys_operation_log` VALUES (2470, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-22 17:16:44');
INSERT INTO `sys_operation_log` VALUES (2471, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-22 17:16:44');
INSERT INTO `sys_operation_log` VALUES (2472, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 17:31:14');
INSERT INTO `sys_operation_log` VALUES (2473, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-22 17:31:14');
INSERT INTO `sys_operation_log` VALUES (2474, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 61ms', '2025-12-22 17:31:14');
INSERT INTO `sys_operation_log` VALUES (2475, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-22 17:31:14');
INSERT INTO `sys_operation_log` VALUES (2476, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 17:33:18');
INSERT INTO `sys_operation_log` VALUES (2477, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 17:33:18');
INSERT INTO `sys_operation_log` VALUES (2478, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-22 17:33:18');
INSERT INTO `sys_operation_log` VALUES (2479, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-22 17:33:18');
INSERT INTO `sys_operation_log` VALUES (2480, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 17:34:22');
INSERT INTO `sys_operation_log` VALUES (2481, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 26ms', '2025-12-22 17:34:23');
INSERT INTO `sys_operation_log` VALUES (2482, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 17:34:25');
INSERT INTO `sys_operation_log` VALUES (2483, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 17:34:25');
INSERT INTO `sys_operation_log` VALUES (2484, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 17:34:25');
INSERT INTO `sys_operation_log` VALUES (2485, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 17:34:27');
INSERT INTO `sys_operation_log` VALUES (2486, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 187ms', '2025-12-22 17:34:27');
INSERT INTO `sys_operation_log` VALUES (2487, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 17:34:33');
INSERT INTO `sys_operation_log` VALUES (2488, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 17:34:33');
INSERT INTO `sys_operation_log` VALUES (2489, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 17:34:33');
INSERT INTO `sys_operation_log` VALUES (2490, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 8ms', '2025-12-22 17:35:00');
INSERT INTO `sys_operation_log` VALUES (2491, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 24ms', '2025-12-22 17:41:09');
INSERT INTO `sys_operation_log` VALUES (2492, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 17:41:10');
INSERT INTO `sys_operation_log` VALUES (2493, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 355ms', '2025-12-22 17:41:10');
INSERT INTO `sys_operation_log` VALUES (2494, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 342ms', '2025-12-22 17:41:10');
INSERT INTO `sys_operation_log` VALUES (2495, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 882ms', '2025-12-22 17:41:11');
INSERT INTO `sys_operation_log` VALUES (2496, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 17:41:45');
INSERT INTO `sys_operation_log` VALUES (2497, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-22 17:41:45');
INSERT INTO `sys_operation_log` VALUES (2498, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 22ms', '2025-12-22 17:41:45');
INSERT INTO `sys_operation_log` VALUES (2499, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-22 17:41:45');
INSERT INTO `sys_operation_log` VALUES (2500, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 7ms', '2025-12-22 17:41:50');
INSERT INTO `sys_operation_log` VALUES (2501, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 683ms', '2025-12-22 17:42:03');
INSERT INTO `sys_operation_log` VALUES (2502, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 188ms', '2025-12-22 17:42:06');
INSERT INTO `sys_operation_log` VALUES (2503, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[2,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":0,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"MySQL数据库原理期中考试试卷\",\"orgId\":1,\"paperId\":2,\"paperName\":\"数据库原理期中考试\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":38,\"updateTime\":\"2025-12-20 15:30:37\",\"validDays\":30,\"version\":1}] | 耗时: 14ms', '2025-12-22 17:42:10');
INSERT INTO `sys_operation_log` VALUES (2504, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 17:42:16');
INSERT INTO `sys_operation_log` VALUES (2505, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 17:42:23');
INSERT INTO `sys_operation_log` VALUES (2506, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-22 17:42:23');
INSERT INTO `sys_operation_log` VALUES (2507, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-22 17:42:23');
INSERT INTO `sys_operation_log` VALUES (2508, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 17:42:23');
INSERT INTO `sys_operation_log` VALUES (2509, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 18:18:25');
INSERT INTO `sys_operation_log` VALUES (2510, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 18:18:25');
INSERT INTO `sys_operation_log` VALUES (2511, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 18:18:28');
INSERT INTO `sys_operation_log` VALUES (2512, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-22 18:18:28');
INSERT INTO `sys_operation_log` VALUES (2513, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-22 18:18:28');
INSERT INTO `sys_operation_log` VALUES (2514, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-22 18:18:55');
INSERT INTO `sys_operation_log` VALUES (2515, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-22 18:18:55');
INSERT INTO `sys_operation_log` VALUES (2516, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 47ms', '2025-12-22 18:18:55');
INSERT INTO `sys_operation_log` VALUES (2517, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 18:19:03');
INSERT INTO `sys_operation_log` VALUES (2518, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3ms', '2025-12-22 18:19:03');
INSERT INTO `sys_operation_log` VALUES (2519, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-22 18:19:10');
INSERT INTO `sys_operation_log` VALUES (2520, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 18:19:10');
INSERT INTO `sys_operation_log` VALUES (2521, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-22 18:19:10');
INSERT INTO `sys_operation_log` VALUES (2522, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 18:19:19');
INSERT INTO `sys_operation_log` VALUES (2523, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 18:19:19');
INSERT INTO `sys_operation_log` VALUES (2524, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 6ms', '2025-12-22 18:19:40');
INSERT INTO `sys_operation_log` VALUES (2525, 0, '查询', '科目管理', '查询科目学生 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT COUNT(*) AS total FROM subject_user WHERE deleted = 0 AND (subject_id = ? AND user_type = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 65ms', '2025-12-22 18:19:43');
INSERT INTO `sys_operation_log` VALUES (2526, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-22 18:19:46');
INSERT INTO `sys_operation_log` VALUES (2527, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 18:19:47');
INSERT INTO `sys_operation_log` VALUES (2528, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 18:19:57');
INSERT INTO `sys_operation_log` VALUES (2529, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 213ms', '2025-12-22 18:19:59');
INSERT INTO `sys_operation_log` VALUES (2530, 0, '查询', '题目管理', '分页查询题目 | 错误: 您没有权限执行此操作：查看题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 18:19:59');
INSERT INTO `sys_operation_log` VALUES (2531, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 18:19:59');
INSERT INTO `sys_operation_log` VALUES (2532, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-22 18:19:59');
INSERT INTO `sys_operation_log` VALUES (2533, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 18:20:06');
INSERT INTO `sys_operation_log` VALUES (2534, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 204ms', '2025-12-22 18:20:09');
INSERT INTO `sys_operation_log` VALUES (2535, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 18:20:09');
INSERT INTO `sys_operation_log` VALUES (2536, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-22 18:20:09');
INSERT INTO `sys_operation_log` VALUES (2537, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 18:20:09');
INSERT INTO `sys_operation_log` VALUES (2538, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 18:20:18');
INSERT INTO `sys_operation_log` VALUES (2539, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 18:20:18');
INSERT INTO `sys_operation_log` VALUES (2540, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 18:20:18');
INSERT INTO `sys_operation_log` VALUES (2541, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 18:27:42');
INSERT INTO `sys_operation_log` VALUES (2542, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-22 18:27:42');
INSERT INTO `sys_operation_log` VALUES (2543, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-22 18:27:45');
INSERT INTO `sys_operation_log` VALUES (2544, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-22 18:27:45');
INSERT INTO `sys_operation_log` VALUES (2545, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-22 18:27:45');
INSERT INTO `sys_operation_log` VALUES (2546, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 18:59:19');
INSERT INTO `sys_operation_log` VALUES (2547, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 383ms', '2025-12-22 18:59:19');
INSERT INTO `sys_operation_log` VALUES (2548, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3138ms', '2025-12-22 18:59:22');
INSERT INTO `sys_operation_log` VALUES (2549, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4002ms', '2025-12-22 18:59:23');
INSERT INTO `sys_operation_log` VALUES (2550, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:09:11');
INSERT INTO `sys_operation_log` VALUES (2551, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 19:09:11');
INSERT INTO `sys_operation_log` VALUES (2552, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-22 19:09:11');
INSERT INTO `sys_operation_log` VALUES (2553, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 19:09:11');
INSERT INTO `sys_operation_log` VALUES (2554, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 19:10:34');
INSERT INTO `sys_operation_log` VALUES (2555, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-22 19:10:34');
INSERT INTO `sys_operation_log` VALUES (2556, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1262ms', '2025-12-22 19:10:36');
INSERT INTO `sys_operation_log` VALUES (2557, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 1092ms', '2025-12-22 19:10:36');
INSERT INTO `sys_operation_log` VALUES (2558, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:10:38');
INSERT INTO `sys_operation_log` VALUES (2559, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-22 19:10:38');
INSERT INTO `sys_operation_log` VALUES (2560, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 587ms', '2025-12-22 19:10:45');
INSERT INTO `sys_operation_log` VALUES (2561, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 910ms', '2025-12-22 19:10:45');
INSERT INTO `sys_operation_log` VALUES (2562, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 909ms', '2025-12-22 19:10:45');
INSERT INTO `sys_operation_log` VALUES (2563, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-22 19:11:29');
INSERT INTO `sys_operation_log` VALUES (2564, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 36ms', '2025-12-22 19:11:29');
INSERT INTO `sys_operation_log` VALUES (2565, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-22 19:12:06');
INSERT INTO `sys_operation_log` VALUES (2566, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 35ms', '2025-12-22 19:12:06');
INSERT INTO `sys_operation_log` VALUES (2567, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 40ms', '2025-12-22 19:12:06');
INSERT INTO `sys_operation_log` VALUES (2568, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:12:11');
INSERT INTO `sys_operation_log` VALUES (2569, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 19:12:11');
INSERT INTO `sys_operation_log` VALUES (2570, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:12:12');
INSERT INTO `sys_operation_log` VALUES (2571, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-22 19:12:12');
INSERT INTO `sys_operation_log` VALUES (2572, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:17:50');
INSERT INTO `sys_operation_log` VALUES (2573, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 20ms', '2025-12-22 19:17:50');
INSERT INTO `sys_operation_log` VALUES (2574, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 19:19:20');
INSERT INTO `sys_operation_log` VALUES (2575, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 36ms', '2025-12-22 19:19:20');
INSERT INTO `sys_operation_log` VALUES (2576, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-22 19:19:52');
INSERT INTO `sys_operation_log` VALUES (2577, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 19:19:52');
INSERT INTO `sys_operation_log` VALUES (2578, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-22 19:21:35');
INSERT INTO `sys_operation_log` VALUES (2579, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 585ms', '2025-12-22 19:21:35');
INSERT INTO `sys_operation_log` VALUES (2580, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 19:21:44');
INSERT INTO `sys_operation_log` VALUES (2581, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 27ms', '2025-12-22 19:21:44');
INSERT INTO `sys_operation_log` VALUES (2582, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-22 19:59:55');
INSERT INTO `sys_operation_log` VALUES (2583, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 167ms', '2025-12-22 19:59:55');
INSERT INTO `sys_operation_log` VALUES (2584, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 695ms', '2025-12-22 19:59:56');
INSERT INTO `sys_operation_log` VALUES (2585, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 58ms', '2025-12-22 23:44:37');
INSERT INTO `sys_operation_log` VALUES (2586, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 673ms', '2025-12-22 23:44:37');
INSERT INTO `sys_operation_log` VALUES (2587, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 23:44:49');
INSERT INTO `sys_operation_log` VALUES (2588, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 27ms', '2025-12-22 23:44:49');
INSERT INTO `sys_operation_log` VALUES (2589, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 23:45:01');
INSERT INTO `sys_operation_log` VALUES (2590, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-22 23:45:01');
INSERT INTO `sys_operation_log` VALUES (2591, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 35ms', '2025-12-22 23:45:01');
INSERT INTO `sys_operation_log` VALUES (2592, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 23:45:02');
INSERT INTO `sys_operation_log` VALUES (2593, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 39ms', '2025-12-22 23:45:03');
INSERT INTO `sys_operation_log` VALUES (2594, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 23:45:14');
INSERT INTO `sys_operation_log` VALUES (2595, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-22 23:45:14');
INSERT INTO `sys_operation_log` VALUES (2596, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 44ms', '2025-12-22 23:45:14');
INSERT INTO `sys_operation_log` VALUES (2597, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 169ms', '2025-12-22 23:45:14');
INSERT INTO `sys_operation_log` VALUES (2598, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 23:45:16');
INSERT INTO `sys_operation_log` VALUES (2599, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 18ms', '2025-12-22 23:45:16');
INSERT INTO `sys_operation_log` VALUES (2600, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 23:46:06');
INSERT INTO `sys_operation_log` VALUES (2601, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 23:46:06');
INSERT INTO `sys_operation_log` VALUES (2602, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-22 23:46:06');
INSERT INTO `sys_operation_log` VALUES (2603, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-22 23:46:27');
INSERT INTO `sys_operation_log` VALUES (2604, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-22 23:46:27');
INSERT INTO `sys_operation_log` VALUES (2605, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-22 23:46:27');
INSERT INTO `sys_operation_log` VALUES (2606, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 81ms', '2025-12-22 23:46:28');
INSERT INTO `sys_operation_log` VALUES (2607, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 23:46:32');
INSERT INTO `sys_operation_log` VALUES (2608, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-22 23:46:32');
INSERT INTO `sys_operation_log` VALUES (2609, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 23:46:41');
INSERT INTO `sys_operation_log` VALUES (2610, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-22 23:46:41');
INSERT INTO `sys_operation_log` VALUES (2611, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-22 23:47:16');
INSERT INTO `sys_operation_log` VALUES (2612, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-22 23:47:16');
INSERT INTO `sys_operation_log` VALUES (2613, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 23:47:17');
INSERT INTO `sys_operation_log` VALUES (2614, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-22 23:48:19');
INSERT INTO `sys_operation_log` VALUES (2615, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-22 23:48:19');
INSERT INTO `sys_operation_log` VALUES (2616, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-22 23:48:20');
INSERT INTO `sys_operation_log` VALUES (2617, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-22 23:48:20');
INSERT INTO `sys_operation_log` VALUES (2618, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 64ms', '2025-12-22 23:48:20');
INSERT INTO `sys_operation_log` VALUES (2619, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-22 23:52:13');
INSERT INTO `sys_operation_log` VALUES (2620, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-22 23:52:13');
INSERT INTO `sys_operation_log` VALUES (2621, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-22 23:52:13');
INSERT INTO `sys_operation_log` VALUES (2622, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-22 23:54:59');
INSERT INTO `sys_operation_log` VALUES (2623, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 68ms', '2025-12-22 23:54:59');
INSERT INTO `sys_operation_log` VALUES (2624, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 39ms', '2025-12-22 23:54:59');
INSERT INTO `sys_operation_log` VALUES (2625, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-23 00:06:11');
INSERT INTO `sys_operation_log` VALUES (2626, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 936ms', '2025-12-23 00:06:12');
INSERT INTO `sys_operation_log` VALUES (2627, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-23 00:06:13');
INSERT INTO `sys_operation_log` VALUES (2628, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 26ms', '2025-12-23 00:06:13');
INSERT INTO `sys_operation_log` VALUES (2629, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 144ms', '2025-12-23 00:06:13');
INSERT INTO `sys_operation_log` VALUES (2630, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 00:06:54');
INSERT INTO `sys_operation_log` VALUES (2631, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 548ms', '2025-12-23 00:06:55');
INSERT INTO `sys_operation_log` VALUES (2632, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-23 00:09:00');
INSERT INTO `sys_operation_log` VALUES (2633, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 53ms', '2025-12-23 00:09:01');
INSERT INTO `sys_operation_log` VALUES (2634, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1639ms', '2025-12-23 00:09:01');
INSERT INTO `sys_operation_log` VALUES (2635, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:11:05');
INSERT INTO `sys_operation_log` VALUES (2636, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-23 00:11:05');
INSERT INTO `sys_operation_log` VALUES (2637, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:11:07');
INSERT INTO `sys_operation_log` VALUES (2638, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-23 00:11:07');
INSERT INTO `sys_operation_log` VALUES (2639, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 83ms', '2025-12-23 00:11:07');
INSERT INTO `sys_operation_log` VALUES (2640, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 00:11:52');
INSERT INTO `sys_operation_log` VALUES (2641, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 21ms', '2025-12-23 00:11:52');
INSERT INTO `sys_operation_log` VALUES (2642, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 100ms', '2025-12-23 00:11:52');
INSERT INTO `sys_operation_log` VALUES (2643, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 00:12:38');
INSERT INTO `sys_operation_log` VALUES (2644, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-23 00:12:38');
INSERT INTO `sys_operation_log` VALUES (2645, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:12:39');
INSERT INTO `sys_operation_log` VALUES (2646, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 44ms', '2025-12-23 00:12:39');
INSERT INTO `sys_operation_log` VALUES (2647, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 21ms', '2025-12-23 00:12:39');
INSERT INTO `sys_operation_log` VALUES (2648, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-23 00:20:03');
INSERT INTO `sys_operation_log` VALUES (2649, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 596ms', '2025-12-23 00:20:04');
INSERT INTO `sys_operation_log` VALUES (2650, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-23 00:20:17');
INSERT INTO `sys_operation_log` VALUES (2651, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 90ms', '2025-12-23 00:20:17');
INSERT INTO `sys_operation_log` VALUES (2652, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 87ms', '2025-12-23 00:20:17');
INSERT INTO `sys_operation_log` VALUES (2653, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 271ms', '2025-12-23 00:20:18');
INSERT INTO `sys_operation_log` VALUES (2654, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-23 00:20:18');
INSERT INTO `sys_operation_log` VALUES (2655, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-23 00:20:18');
INSERT INTO `sys_operation_log` VALUES (2656, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-23 00:21:21');
INSERT INTO `sys_operation_log` VALUES (2657, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-23 00:21:21');
INSERT INTO `sys_operation_log` VALUES (2658, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-23 00:21:21');
INSERT INTO `sys_operation_log` VALUES (2659, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 53ms', '2025-12-23 00:21:21');
INSERT INTO `sys_operation_log` VALUES (2660, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 00:21:22');
INSERT INTO `sys_operation_log` VALUES (2661, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-23 00:21:22');
INSERT INTO `sys_operation_log` VALUES (2662, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:21:46');
INSERT INTO `sys_operation_log` VALUES (2663, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-23 00:21:46');
INSERT INTO `sys_operation_log` VALUES (2664, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 00:21:52');
INSERT INTO `sys_operation_log` VALUES (2665, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 3178ms', '2025-12-23 00:21:56');
INSERT INTO `sys_operation_log` VALUES (2666, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3454ms', '2025-12-23 00:21:56');
INSERT INTO `sys_operation_log` VALUES (2667, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 121ms', '2025-12-23 00:22:01');
INSERT INTO `sys_operation_log` VALUES (2668, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 187ms', '2025-12-23 00:22:01');
INSERT INTO `sys_operation_log` VALUES (2669, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 271ms', '2025-12-23 00:30:57');
INSERT INTO `sys_operation_log` VALUES (2670, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 260ms', '2025-12-23 00:30:57');
INSERT INTO `sys_operation_log` VALUES (2671, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 285ms', '2025-12-23 00:30:57');
INSERT INTO `sys_operation_log` VALUES (2672, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-23 00:31:05');
INSERT INTO `sys_operation_log` VALUES (2673, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 411ms', '2025-12-23 00:31:05');
INSERT INTO `sys_operation_log` VALUES (2674, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-23 00:31:08');
INSERT INTO `sys_operation_log` VALUES (2675, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 24ms', '2025-12-23 00:31:08');
INSERT INTO `sys_operation_log` VALUES (2676, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 121ms', '2025-12-23 00:31:08');
INSERT INTO `sys_operation_log` VALUES (2677, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:31:25');
INSERT INTO `sys_operation_log` VALUES (2678, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-23 00:31:25');
INSERT INTO `sys_operation_log` VALUES (2679, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 00:43:11');
INSERT INTO `sys_operation_log` VALUES (2680, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-23 00:43:11');
INSERT INTO `sys_operation_log` VALUES (2681, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-12-23 00:43:11');
INSERT INTO `sys_operation_log` VALUES (2682, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 81ms', '2025-12-23 00:43:11');
INSERT INTO `sys_operation_log` VALUES (2683, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2684, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2685, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2686, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2687, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2688, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2689, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2690, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 00:47:30');
INSERT INTO `sys_operation_log` VALUES (2691, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 1538ms', '2025-12-23 21:06:32');
INSERT INTO `sys_operation_log` VALUES (2692, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 297ms', '2025-12-23 21:06:32');
INSERT INTO `sys_operation_log` VALUES (2693, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 299ms', '2025-12-23 21:06:32');
INSERT INTO `sys_operation_log` VALUES (2694, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 350ms', '2025-12-23 21:06:32');
INSERT INTO `sys_operation_log` VALUES (2695, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-23 21:06:37');
INSERT INTO `sys_operation_log` VALUES (2696, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-23 21:06:37');
INSERT INTO `sys_operation_log` VALUES (2697, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 50ms', '2025-12-23 21:06:37');
INSERT INTO `sys_operation_log` VALUES (2698, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-23 21:06:39');
INSERT INTO `sys_operation_log` VALUES (2699, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-23 21:06:39');
INSERT INTO `sys_operation_log` VALUES (2700, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-23 21:06:39');
INSERT INTO `sys_operation_log` VALUES (2701, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 25ms', '2025-12-23 21:06:39');
INSERT INTO `sys_operation_log` VALUES (2702, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 16ms', '2025-12-23 21:06:55');
INSERT INTO `sys_operation_log` VALUES (2703, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-23 21:06:58');
INSERT INTO `sys_operation_log` VALUES (2704, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-23 21:06:59');
INSERT INTO `sys_operation_log` VALUES (2705, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-23 21:07:05');
INSERT INTO `sys_operation_log` VALUES (2706, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-23 21:07:05');
INSERT INTO `sys_operation_log` VALUES (2707, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-23 21:07:05');
INSERT INTO `sys_operation_log` VALUES (2708, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 21:07:07');
INSERT INTO `sys_operation_log` VALUES (2709, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-23 21:07:07');
INSERT INTO `sys_operation_log` VALUES (2710, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-23 21:07:07');
INSERT INTO `sys_operation_log` VALUES (2711, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 126ms', '2025-12-23 21:07:07');
INSERT INTO `sys_operation_log` VALUES (2712, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-23 21:07:08');
INSERT INTO `sys_operation_log` VALUES (2713, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-23 21:07:08');
INSERT INTO `sys_operation_log` VALUES (2714, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-23 21:07:08');
INSERT INTO `sys_operation_log` VALUES (2715, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 21:07:15');
INSERT INTO `sys_operation_log` VALUES (2716, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-23 21:07:15');
INSERT INTO `sys_operation_log` VALUES (2717, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-23 21:07:15');
INSERT INTO `sys_operation_log` VALUES (2718, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-23 21:07:15');
INSERT INTO `sys_operation_log` VALUES (2719, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:07:33');
INSERT INTO `sys_operation_log` VALUES (2720, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-23 21:07:33');
INSERT INTO `sys_operation_log` VALUES (2721, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-23 21:07:33');
INSERT INTO `sys_operation_log` VALUES (2722, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-23 21:07:33');
INSERT INTO `sys_operation_log` VALUES (2723, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 21:07:45');
INSERT INTO `sys_operation_log` VALUES (2724, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-23 21:07:45');
INSERT INTO `sys_operation_log` VALUES (2725, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-23 21:07:45');
INSERT INTO `sys_operation_log` VALUES (2726, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-23 21:07:53');
INSERT INTO `sys_operation_log` VALUES (2727, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-23 21:07:53');
INSERT INTO `sys_operation_log` VALUES (2728, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-23 21:07:54');
INSERT INTO `sys_operation_log` VALUES (2729, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:08:06');
INSERT INTO `sys_operation_log` VALUES (2730, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:08:06');
INSERT INTO `sys_operation_log` VALUES (2731, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:08:06');
INSERT INTO `sys_operation_log` VALUES (2732, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-23 21:08:06');
INSERT INTO `sys_operation_log` VALUES (2733, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-23 21:08:15');
INSERT INTO `sys_operation_log` VALUES (2734, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:08:29');
INSERT INTO `sys_operation_log` VALUES (2735, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-23 21:08:29');
INSERT INTO `sys_operation_log` VALUES (2736, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-23 21:08:29');
INSERT INTO `sys_operation_log` VALUES (2737, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 60ms', '2025-12-23 21:08:29');
INSERT INTO `sys_operation_log` VALUES (2738, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:08:31');
INSERT INTO `sys_operation_log` VALUES (2739, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:08:31');
INSERT INTO `sys_operation_log` VALUES (2740, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:08:51');
INSERT INTO `sys_operation_log` VALUES (2741, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-23 21:08:51');
INSERT INTO `sys_operation_log` VALUES (2742, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-23 21:08:51');
INSERT INTO `sys_operation_log` VALUES (2743, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 21:08:53');
INSERT INTO `sys_operation_log` VALUES (2744, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:08:53');
INSERT INTO `sys_operation_log` VALUES (2745, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:08:54');
INSERT INTO `sys_operation_log` VALUES (2746, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-23 21:08:54');
INSERT INTO `sys_operation_log` VALUES (2747, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 46ms', '2025-12-23 21:08:54');
INSERT INTO `sys_operation_log` VALUES (2748, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:09:12');
INSERT INTO `sys_operation_log` VALUES (2749, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-23 21:09:12');
INSERT INTO `sys_operation_log` VALUES (2750, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 21:09:18');
INSERT INTO `sys_operation_log` VALUES (2751, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-23 21:09:18');
INSERT INTO `sys_operation_log` VALUES (2752, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:09:19');
INSERT INTO `sys_operation_log` VALUES (2753, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-23 21:09:19');
INSERT INTO `sys_operation_log` VALUES (2754, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-23 21:09:26');
INSERT INTO `sys_operation_log` VALUES (2755, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 231ms', '2025-12-23 21:09:28');
INSERT INTO `sys_operation_log` VALUES (2756, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-23 21:09:28');
INSERT INTO `sys_operation_log` VALUES (2757, 0, '查询', '题目管理', '分页查询题目 | 错误: 您没有权限执行此操作：查看题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-23 21:09:28');
INSERT INTO `sys_operation_log` VALUES (2758, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-23 21:09:28');
INSERT INTO `sys_operation_log` VALUES (2759, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:09:34');
INSERT INTO `sys_operation_log` VALUES (2760, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 195ms', '2025-12-23 21:09:36');
INSERT INTO `sys_operation_log` VALUES (2761, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-23 21:09:36');
INSERT INTO `sys_operation_log` VALUES (2762, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-23 21:09:36');
INSERT INTO `sys_operation_log` VALUES (2763, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-23 21:09:36');
INSERT INTO `sys_operation_log` VALUES (2764, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 7ms', '2025-12-23 21:09:52');
INSERT INTO `sys_operation_log` VALUES (2765, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 21:11:41');
INSERT INTO `sys_operation_log` VALUES (2766, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-23 21:11:41');
INSERT INTO `sys_operation_log` VALUES (2767, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-23 21:11:41');
INSERT INTO `sys_operation_log` VALUES (2768, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 21:11:53');
INSERT INTO `sys_operation_log` VALUES (2769, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:11:53');
INSERT INTO `sys_operation_log` VALUES (2770, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-23 21:11:53');
INSERT INTO `sys_operation_log` VALUES (2771, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:11:53');
INSERT INTO `sys_operation_log` VALUES (2772, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:11:55');
INSERT INTO `sys_operation_log` VALUES (2773, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:11:55');
INSERT INTO `sys_operation_log` VALUES (2774, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-23 21:11:55');
INSERT INTO `sys_operation_log` VALUES (2775, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-23 21:11:55');
INSERT INTO `sys_operation_log` VALUES (2776, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-23 21:12:16');
INSERT INTO `sys_operation_log` VALUES (2777, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-23 21:12:16');
INSERT INTO `sys_operation_log` VALUES (2778, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:12:16');
INSERT INTO `sys_operation_log` VALUES (2779, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:12:19');
INSERT INTO `sys_operation_log` VALUES (2780, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:12:19');
INSERT INTO `sys_operation_log` VALUES (2781, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-23 21:12:19');
INSERT INTO `sys_operation_log` VALUES (2782, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 21:12:19');
INSERT INTO `sys_operation_log` VALUES (2783, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:12:50');
INSERT INTO `sys_operation_log` VALUES (2784, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:12:51');
INSERT INTO `sys_operation_log` VALUES (2785, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:16:21');
INSERT INTO `sys_operation_log` VALUES (2786, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-23 21:16:21');
INSERT INTO `sys_operation_log` VALUES (2787, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 21:16:21');
INSERT INTO `sys_operation_log` VALUES (2788, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:18:21');
INSERT INTO `sys_operation_log` VALUES (2789, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:18:21');
INSERT INTO `sys_operation_log` VALUES (2790, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-23 21:18:21');
INSERT INTO `sys_operation_log` VALUES (2791, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:18:21');
INSERT INTO `sys_operation_log` VALUES (2792, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[268,{\"analysis\":\"test\",\"bankId\":1,\"correctAnswer\":\"A\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"createTime\":\"2025-12-22 03:47:55\",\"deleted\":0,\"isCorrect\":1,\"optionContent\":\"test\",\"optionId\":338,\"optionSeq\":\"A\",\"optionType\":\"NORMAL\",\"questionId\":268,\"sort\":0,\"updateTime\":\"2025-12-22 03:47:55\"},{\"createTime\":\"2025-12-22 03:47:55\",\"deleted\":0,\"isCorrect\":0,\"optionContent\":\"rwar\",\"optionId\":339,\"optionSeq\":\"B\",\"optionType\":\"NORMAL\",\"questionId\":268,\"sort\":0,\"updateTime\":\"202...', '2025-12-23 21:18:41');
INSERT INTO `sys_operation_log` VALUES (2793, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-23 21:18:41');
INSERT INTO `sys_operation_log` VALUES (2794, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[239,{\"analysis\":\"面向对象的三大特性是：封装、继承、多态。\",\"bankId\":53,\"correctAnswer\":\"\",\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":0,\"optionContent\":\"\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"\",\"optionSeq\":\"B\"}],\"questionContent\":\"Java中面向对象的三大特性包括哪些？\",\"questionId\":239,\"questionType\":2}] | 耗时: 25ms', '2025-12-23 21:22:19');
INSERT INTO `sys_operation_log` VALUES (2795, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-23 21:22:19');
INSERT INTO `sys_operation_log` VALUES (2796, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:25:33');
INSERT INTO `sys_operation_log` VALUES (2797, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:25:35');
INSERT INTO `sys_operation_log` VALUES (2798, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-23 21:26:02');
INSERT INTO `sys_operation_log` VALUES (2799, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:26:09');
INSERT INTO `sys_operation_log` VALUES (2800, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 227ms', '2025-12-23 21:27:18');
INSERT INTO `sys_operation_log` VALUES (2801, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:27:18');
INSERT INTO `sys_operation_log` VALUES (2802, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:27:18');
INSERT INTO `sys_operation_log` VALUES (2803, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-23 21:27:18');
INSERT INTO `sys_operation_log` VALUES (2804, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 21:27:20');
INSERT INTO `sys_operation_log` VALUES (2805, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:27:20');
INSERT INTO `sys_operation_log` VALUES (2806, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-23 21:27:20');
INSERT INTO `sys_operation_log` VALUES (2807, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"默认题库\",\"bankType\":1,\"createTime\":\"2025-11-07 09:08:07\",\"createUserId\":1,\"deleted\":0,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\",\"orgId\":1,\"questionCount\":4,\"sort\":5,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-22 02:25:09\"}] | 耗时: 18ms', '2025-12-23 21:27:39');
INSERT INTO `sys_operation_log` VALUES (2808, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 21:27:39');
INSERT INTO `sys_operation_log` VALUES (2809, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-23 22:02:04');
INSERT INTO `sys_operation_log` VALUES (2810, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-23 22:02:05');
INSERT INTO `sys_operation_log` VALUES (2811, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-23 22:02:07');
INSERT INTO `sys_operation_log` VALUES (2812, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 22:02:51');
INSERT INTO `sys_operation_log` VALUES (2813, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-23 22:02:51');
INSERT INTO `sys_operation_log` VALUES (2814, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 22:02:51');
INSERT INTO `sys_operation_log` VALUES (2815, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-23 22:02:54');
INSERT INTO `sys_operation_log` VALUES (2816, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-23 22:02:54');
INSERT INTO `sys_operation_log` VALUES (2817, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-23 22:02:54');
INSERT INTO `sys_operation_log` VALUES (2818, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-23 22:02:54');
INSERT INTO `sys_operation_log` VALUES (2819, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 40ms', '2025-12-23 22:50:49');
INSERT INTO `sys_operation_log` VALUES (2820, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:09:41');
INSERT INTO `sys_operation_log` VALUES (2821, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-24 01:09:41');
INSERT INTO `sys_operation_log` VALUES (2822, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-24 01:09:41');
INSERT INTO `sys_operation_log` VALUES (2823, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 56ms', '2025-12-24 01:09:41');
INSERT INTO `sys_operation_log` VALUES (2824, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:09:42');
INSERT INTO `sys_operation_log` VALUES (2825, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:09:44');
INSERT INTO `sys_operation_log` VALUES (2826, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:09:44');
INSERT INTO `sys_operation_log` VALUES (2827, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-24 01:09:44');
INSERT INTO `sys_operation_log` VALUES (2828, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:09:51');
INSERT INTO `sys_operation_log` VALUES (2829, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:09:51');
INSERT INTO `sys_operation_log` VALUES (2830, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:09:54');
INSERT INTO `sys_operation_log` VALUES (2831, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:09:54');
INSERT INTO `sys_operation_log` VALUES (2832, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:09:54');
INSERT INTO `sys_operation_log` VALUES (2833, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:09:59');
INSERT INTO `sys_operation_log` VALUES (2834, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:09:59');
INSERT INTO `sys_operation_log` VALUES (2835, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:10:02');
INSERT INTO `sys_operation_log` VALUES (2836, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:10:02');
INSERT INTO `sys_operation_log` VALUES (2837, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:10:02');
INSERT INTO `sys_operation_log` VALUES (2838, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:10:03');
INSERT INTO `sys_operation_log` VALUES (2839, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:10:03');
INSERT INTO `sys_operation_log` VALUES (2840, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:10:05');
INSERT INTO `sys_operation_log` VALUES (2841, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:05');
INSERT INTO `sys_operation_log` VALUES (2842, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:10:05');
INSERT INTO `sys_operation_log` VALUES (2843, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:10:06');
INSERT INTO `sys_operation_log` VALUES (2844, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:10:06');
INSERT INTO `sys_operation_log` VALUES (2845, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:10:07');
INSERT INTO `sys_operation_log` VALUES (2846, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:07');
INSERT INTO `sys_operation_log` VALUES (2847, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-24 01:10:07');
INSERT INTO `sys_operation_log` VALUES (2848, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:08');
INSERT INTO `sys_operation_log` VALUES (2849, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:08');
INSERT INTO `sys_operation_log` VALUES (2850, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:10:08');
INSERT INTO `sys_operation_log` VALUES (2851, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:10:08');
INSERT INTO `sys_operation_log` VALUES (2852, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:10:08');
INSERT INTO `sys_operation_log` VALUES (2853, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:10:21');
INSERT INTO `sys_operation_log` VALUES (2854, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:10:21');
INSERT INTO `sys_operation_log` VALUES (2855, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-24 01:10:21');
INSERT INTO `sys_operation_log` VALUES (2856, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:10:21');
INSERT INTO `sys_operation_log` VALUES (2857, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:10:26');
INSERT INTO `sys_operation_log` VALUES (2858, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:10:27');
INSERT INTO `sys_operation_log` VALUES (2859, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:10:27');
INSERT INTO `sys_operation_log` VALUES (2860, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:10:29');
INSERT INTO `sys_operation_log` VALUES (2861, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:10:30');
INSERT INTO `sys_operation_log` VALUES (2862, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:10:30');
INSERT INTO `sys_operation_log` VALUES (2863, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:10:30');
INSERT INTO `sys_operation_log` VALUES (2864, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:10:33');
INSERT INTO `sys_operation_log` VALUES (2865, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:10:33');
INSERT INTO `sys_operation_log` VALUES (2866, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:10:37');
INSERT INTO `sys_operation_log` VALUES (2867, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:10:37');
INSERT INTO `sys_operation_log` VALUES (2868, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:10:37');
INSERT INTO `sys_operation_log` VALUES (2869, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:10:38');
INSERT INTO `sys_operation_log` VALUES (2870, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-24 01:10:38');
INSERT INTO `sys_operation_log` VALUES (2871, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:10:41');
INSERT INTO `sys_operation_log` VALUES (2872, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:10:44');
INSERT INTO `sys_operation_log` VALUES (2873, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:10:44');
INSERT INTO `sys_operation_log` VALUES (2874, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:10:44');
INSERT INTO `sys_operation_log` VALUES (2875, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:10:48');
INSERT INTO `sys_operation_log` VALUES (2876, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:48');
INSERT INTO `sys_operation_log` VALUES (2877, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:10:48');
INSERT INTO `sys_operation_log` VALUES (2878, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:10:48');
INSERT INTO `sys_operation_log` VALUES (2879, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:10:58');
INSERT INTO `sys_operation_log` VALUES (2880, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:10:58');
INSERT INTO `sys_operation_log` VALUES (2881, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:10:58');
INSERT INTO `sys_operation_log` VALUES (2882, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:10:58');
INSERT INTO `sys_operation_log` VALUES (2883, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:00');
INSERT INTO `sys_operation_log` VALUES (2884, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:11:02');
INSERT INTO `sys_operation_log` VALUES (2885, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:02');
INSERT INTO `sys_operation_log` VALUES (2886, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:11:02');
INSERT INTO `sys_operation_log` VALUES (2887, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:11:02');
INSERT INTO `sys_operation_log` VALUES (2888, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:11:05');
INSERT INTO `sys_operation_log` VALUES (2889, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:11:05');
INSERT INTO `sys_operation_log` VALUES (2890, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:11:05');
INSERT INTO `sys_operation_log` VALUES (2891, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:11:05');
INSERT INTO `sys_operation_log` VALUES (2892, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:07');
INSERT INTO `sys_operation_log` VALUES (2893, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:11:09');
INSERT INTO `sys_operation_log` VALUES (2894, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:11:09');
INSERT INTO `sys_operation_log` VALUES (2895, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:09');
INSERT INTO `sys_operation_log` VALUES (2896, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:11:09');
INSERT INTO `sys_operation_log` VALUES (2897, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[240,{\"analysis\":\"Java的8种基本数据类型：byte、short、int、long、float、double、char、boolean。\",\"bankId\":53,\"correctAnswer\":\"\",\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"下列哪些是Java中的基本数据类型？\",\"questionId\":240,\"questionType\":2}] | 耗时: 22ms', '2025-12-24 01:11:15');
INSERT INTO `sys_operation_log` VALUES (2898, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:15');
INSERT INTO `sys_operation_log` VALUES (2899, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:11:16');
INSERT INTO `sys_operation_log` VALUES (2900, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[259,{\"analysis\":\"Spring Boot简化了Spring应用的配置和部署，提供了自动配置功能。\",\"bankId\":52,\"correctAnswer\":\"\",\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"Spring Boot的主要作用是什么？\",\"questionId\":259,\"questionType\":1}] | 耗时: 25ms', '2025-12-24 01:11:21');
INSERT INTO `sys_operation_log` VALUES (2901, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:21');
INSERT INTO `sys_operation_log` VALUES (2902, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[257,{\"analysis\":\"关键点：原子性、完全依赖、消除传递依赖\",\"bankId\":52,\"correctAnswer\":\"第一范式(1NF)：每个字段都是不可分割的原子值。第二范式(2NF)：消除部分依赖，非主键字段完全依赖主键。第三范式(3NF)：消除传递依赖，非主键字段不依赖其他非主键字段。\",\"defaultScore\":10,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"请解释数据库的三大范式，并举例说明。\",\"questionId\":257,\"questionType\":8}] | 耗时: 20ms', '2025-12-24 01:11:29');
INSERT INTO `sys_operation_log` VALUES (2903, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:11:29');
INSERT INTO `sys_operation_log` VALUES (2904, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[256,{\"analysis\":\"正确。索引需要额外的存储空间和维护成本，影响插入、更新、删除的性能。\",\"bankId\":52,\"correctAnswer\":\"\",\"defaultScore\":2,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"索引可以提高数据的查询速度，但会降低写入速度。\",\"questionId\":256,\"questionType\":4}] | 耗时: 23ms', '2025-12-24 01:11:34');
INSERT INTO `sys_operation_log` VALUES (2905, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:11:34');
INSERT INTO `sys_operation_log` VALUES (2906, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[254,{\"analysis\":\"索引可以加快查询速度、实现唯一性约束、加速表与表之间的连接。\",\"bankId\":52,\"correctAnswer\":\"\",\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"数据库索引的优点包括哪些？\",\"questionId\":254,\"questionType\":2}] | 耗时: 24ms', '2025-12-24 01:11:43');
INSERT INTO `sys_operation_log` VALUES (2907, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:11:43');
INSERT INTO `sys_operation_log` VALUES (2908, 0, '更新', '题目管理', '更新题目', NULL, '0:0:0:0:0:0:0:1', '[253,{\"analysis\":\"MySQL支持INT、VARCHAR、TEXT、DATE、DATETIME等多种数据类型。\",\"bankId\":52,\"correctAnswer\":\"\",\"defaultScore\":4,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[],\"questionContent\":\"以下哪些是MySQL支持的数据类型？\",\"questionId\":253,\"questionType\":2}] | 耗时: 26ms', '2025-12-24 01:11:48');
INSERT INTO `sys_operation_log` VALUES (2909, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:11:48');
INSERT INTO `sys_operation_log` VALUES (2910, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:11:50');
INSERT INTO `sys_operation_log` VALUES (2911, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:11:54');
INSERT INTO `sys_operation_log` VALUES (2912, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:12:08');
INSERT INTO `sys_operation_log` VALUES (2913, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:12:08');
INSERT INTO `sys_operation_log` VALUES (2914, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:12:08');
INSERT INTO `sys_operation_log` VALUES (2915, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-24 01:12:09');
INSERT INTO `sys_operation_log` VALUES (2916, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 25ms', '2025-12-24 01:12:17');
INSERT INTO `sys_operation_log` VALUES (2917, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 5ms', '2025-12-24 01:12:31');
INSERT INTO `sys_operation_log` VALUES (2918, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2919, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2920, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2921, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2922, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2923, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2924, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2925, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 23ms', '2025-12-24 01:12:42');
INSERT INTO `sys_operation_log` VALUES (2926, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:12:49');
INSERT INTO `sys_operation_log` VALUES (2927, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:12:49');
INSERT INTO `sys_operation_log` VALUES (2928, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:12:51');
INSERT INTO `sys_operation_log` VALUES (2929, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:12:51');
INSERT INTO `sys_operation_log` VALUES (2930, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:12:51');
INSERT INTO `sys_operation_log` VALUES (2931, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-24 01:12:51');
INSERT INTO `sys_operation_log` VALUES (2932, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:14:16');
INSERT INTO `sys_operation_log` VALUES (2933, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:14:16');
INSERT INTO `sys_operation_log` VALUES (2934, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-24 01:14:16');
INSERT INTO `sys_operation_log` VALUES (2935, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-24 01:14:16');
INSERT INTO `sys_operation_log` VALUES (2936, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 6ms', '2025-12-24 01:14:32');
INSERT INTO `sys_operation_log` VALUES (2937, 0, '创建', '试卷管理', '创建试卷', NULL, '0:0:0:0:0:0:0:1', '[{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":3,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 24ms', '2025-12-24 01:17:53');
INSERT INTO `sys_operation_log` VALUES (2938, 0, '删除', '试卷管理', '删除试卷', NULL, '0:0:0:0:0:0:0:1', '[5] | 耗时: 25ms', '2025-12-24 01:17:59');
INSERT INTO `sys_operation_log` VALUES (2939, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-24 01:17:59');
INSERT INTO `sys_operation_log` VALUES (2940, 0, '删除', '试卷管理', '删除试卷', NULL, '0:0:0:0:0:0:0:1', '[10] | 耗时: 16ms', '2025-12-24 01:18:05');
INSERT INTO `sys_operation_log` VALUES (2941, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-24 01:18:05');
INSERT INTO `sys_operation_log` VALUES (2942, 0, '创建', '试卷管理', '创建试卷', NULL, '0:0:0:0:0:0:0:1', '[{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 23ms', '2025-12-24 01:18:22');
INSERT INTO `sys_operation_log` VALUES (2943, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-24 01:18:36');
INSERT INTO `sys_operation_log` VALUES (2944, 0, '更新', '试卷管理', '更新试卷 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\r\n### The error may exist in com/example/exam/mapper/paper/PaperMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.paper.PaperMapper.updateById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE paper  SET bank_id=?, paper_name=?, description=?, paper_type=?, total_score=?, pass_score=?, org_id=?, create_user_id=?, audit_status=?,    publish_status=?,  allow_view_analysis=?, allow_reexam=?, reexam_limit=?, valid_days=?, version=?,  create_time=?, update_time=?  WHERE paper_id=? AND deleted=0\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 1104ms', '2025-12-24 01:22:43');
INSERT INTO `sys_operation_log` VALUES (2945, 0, '更新', '试卷管理', '更新试卷 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\r\n### The error may exist in com/example/exam/mapper/paper/PaperMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.paper.PaperMapper.updateById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE paper  SET bank_id=?, paper_name=?, description=?, paper_type=?, total_score=?, pass_score=?, org_id=?, create_user_id=?, audit_status=?,    publish_status=?,  allow_view_analysis=?, allow_reexam=?, reexam_limit=?, valid_days=?, version=?,  create_time=?, update_time=?  WHERE paper_id=? AND deleted=0\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 26ms', '2025-12-24 01:24:26');
INSERT INTO `sys_operation_log` VALUES (2946, 0, '更新', '试卷管理', '更新试卷 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\r\n### The error may exist in com/example/exam/mapper/paper/PaperMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.paper.PaperMapper.updateById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE paper  SET bank_id=?, paper_name=?, description=?, paper_type=?, total_score=?, pass_score=?, org_id=?, create_user_id=?, audit_status=?,    publish_status=?,  allow_view_analysis=?, allow_reexam=?, reexam_limit=?, valid_days=?, version=?,  create_time=?, update_time=?  WHERE paper_id=? AND deleted=0\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 16ms', '2025-12-24 01:24:33');
INSERT INTO `sys_operation_log` VALUES (2947, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 221ms', '2025-12-24 01:25:53');
INSERT INTO `sys_operation_log` VALUES (2948, 0, '更新', '试卷管理', '更新试卷 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\r\n### The error may exist in com/example/exam/mapper/paper/PaperMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.paper.PaperMapper.updateById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE paper  SET bank_id=?, paper_name=?, description=?, paper_type=?, total_score=?, pass_score=?, org_id=?, create_user_id=?, audit_status=?,    publish_status=?,  allow_view_analysis=?, allow_reexam=?, reexam_limit=?, valid_days=?, version=?,  create_time=?, update_time=?  WHERE paper_id=? AND deleted=0\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'bank_id\' in \'field list\'\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":36,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 10ms', '2025-12-24 01:26:04');
INSERT INTO `sys_operation_log` VALUES (2949, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-24 01:27:00');
INSERT INTO `sys_operation_log` VALUES (2950, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-24 01:27:00');
INSERT INTO `sys_operation_log` VALUES (2951, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 34ms', '2025-12-24 01:27:00');
INSERT INTO `sys_operation_log` VALUES (2952, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:27:02');
INSERT INTO `sys_operation_log` VALUES (2953, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 60ms', '2025-12-24 01:27:02');
INSERT INTO `sys_operation_log` VALUES (2954, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 33ms', '2025-12-24 01:27:02');
INSERT INTO `sys_operation_log` VALUES (2955, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 79ms', '2025-12-24 01:27:02');
INSERT INTO `sys_operation_log` VALUES (2956, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:30:34');
INSERT INTO `sys_operation_log` VALUES (2957, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-24 01:30:34');
INSERT INTO `sys_operation_log` VALUES (2958, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 20ms', '2025-12-24 01:30:34');
INSERT INTO `sys_operation_log` VALUES (2959, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 85ms', '2025-12-24 01:30:34');
INSERT INTO `sys_operation_log` VALUES (2960, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 17ms', '2025-12-24 01:30:38');
INSERT INTO `sys_operation_log` VALUES (2961, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[2,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"MySQL数据库原理期中考试试卷\",\"orgId\":1,\"paperId\":2,\"paperName\":\"数据库原理期中考试\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":72,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 21ms', '2025-12-24 01:30:45');
INSERT INTO `sys_operation_log` VALUES (2962, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[2,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":53,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"MySQL数据库原理期中考试试卷\",\"orgId\":1,\"paperId\":2,\"paperName\":\"数据库原理期中考试\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":72,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 31ms', '2025-12-24 01:30:55');
INSERT INTO `sys_operation_log` VALUES (2963, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[4,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":54,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java、数据库、Spring综合能力测试\",\"orgId\":1,\"paperId\":4,\"paperName\":\"综合能力测试卷\",\"paperType\":1,\"passScore\":70,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-12-22 23:48:11\",\"validDays\":30,\"version\":1}] | 耗时: 18ms', '2025-12-24 01:31:09');
INSERT INTO `sys_operation_log` VALUES (2964, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 10ms', '2025-12-24 01:32:04');
INSERT INTO `sys_operation_log` VALUES (2965, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 6ms', '2025-12-24 01:32:13');
INSERT INTO `sys_operation_log` VALUES (2966, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[2,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":53,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"MySQL数据库原理期中考试试卷\",\"orgId\":1,\"paperId\":2,\"paperName\":\"数据库原理期中考试\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":72,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 6ms', '2025-12-24 01:32:16');
INSERT INTO `sys_operation_log` VALUES (2967, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[3,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":52,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Spring框架知识点快速测试\",\"orgId\":1,\"paperId\":3,\"paperName\":\"Spring框架快速测试\",\"paperType\":2,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":100,\"updateTime\":\"2025-12-22 23:48:09\",\"validDays\":30,\"version\":1}] | 耗时: 14ms', '2025-12-24 01:32:20');
INSERT INTO `sys_operation_log` VALUES (2968, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 70ms', '2025-12-24 01:32:32');
INSERT INTO `sys_operation_log` VALUES (2969, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:35:43');
INSERT INTO `sys_operation_log` VALUES (2970, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-24 01:35:44');
INSERT INTO `sys_operation_log` VALUES (2971, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:35:53');
INSERT INTO `sys_operation_log` VALUES (2972, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:35:53');
INSERT INTO `sys_operation_log` VALUES (2973, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-24 01:35:53');
INSERT INTO `sys_operation_log` VALUES (2974, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-24 01:35:53');
INSERT INTO `sys_operation_log` VALUES (2975, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-24 01:35:55');
INSERT INTO `sys_operation_log` VALUES (2976, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:35:57');
INSERT INTO `sys_operation_log` VALUES (2977, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:35:57');
INSERT INTO `sys_operation_log` VALUES (2978, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-24 01:35:57');
INSERT INTO `sys_operation_log` VALUES (2979, 0, '创建', '题库管理', '创建题库', NULL, '0:0:0:0:0:0:0:1', '[{\"bankName\":\"test\",\"bankType\":1,\"description\":\"test\",\"sort\":0}] | 耗时: 50ms', '2025-12-24 01:36:13');
INSERT INTO `sys_operation_log` VALUES (2980, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-24 01:36:13');
INSERT INTO `sys_operation_log` VALUES (2981, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:36:22');
INSERT INTO `sys_operation_log` VALUES (2982, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:36:22');
INSERT INTO `sys_operation_log` VALUES (2983, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-24 01:36:23');
INSERT INTO `sys_operation_log` VALUES (2984, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:36:32');
INSERT INTO `sys_operation_log` VALUES (2985, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-24 01:37:07');
INSERT INTO `sys_operation_log` VALUES (2986, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:37:21');
INSERT INTO `sys_operation_log` VALUES (2987, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-24 01:37:22');
INSERT INTO `sys_operation_log` VALUES (2988, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:37:23');
INSERT INTO `sys_operation_log` VALUES (2989, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:37:30');
INSERT INTO `sys_operation_log` VALUES (2990, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:37:36');
INSERT INTO `sys_operation_log` VALUES (2991, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-24 01:38:01');
INSERT INTO `sys_operation_log` VALUES (2992, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[58,{\"questionIds\":[268,234,235,236,237,238,239,240,241,242]}] | 耗时: 142ms', '2025-12-24 01:38:05');
INSERT INTO `sys_operation_log` VALUES (2993, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-24 01:38:05');
INSERT INTO `sys_operation_log` VALUES (2994, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:38:05');
INSERT INTO `sys_operation_log` VALUES (2995, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:38:08');
INSERT INTO `sys_operation_log` VALUES (2996, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:38:14');
INSERT INTO `sys_operation_log` VALUES (2997, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:38:16');
INSERT INTO `sys_operation_log` VALUES (2998, 0, '更新', '题库管理', '批量添加题目', NULL, '0:0:0:0:0:0:0:1', '[58,{\"questionIds\":[268,234,235,236,237,238,239,240,241,242,268,234,235,236,237,238,239,240,241,242,268,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252]}] | 耗时: 125ms', '2025-12-24 01:38:21');
INSERT INTO `sys_operation_log` VALUES (2999, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:38:21');
INSERT INTO `sys_operation_log` VALUES (3000, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:38:21');
INSERT INTO `sys_operation_log` VALUES (3001, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:38:23');
INSERT INTO `sys_operation_log` VALUES (3002, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-24 01:38:25');
INSERT INTO `sys_operation_log` VALUES (3003, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-24 01:38:27');
INSERT INTO `sys_operation_log` VALUES (3004, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:38:45');
INSERT INTO `sys_operation_log` VALUES (3005, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:38:45');
INSERT INTO `sys_operation_log` VALUES (3006, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:38:45');
INSERT INTO `sys_operation_log` VALUES (3007, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 41ms', '2025-12-24 01:38:45');
INSERT INTO `sys_operation_log` VALUES (3008, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:38:59');
INSERT INTO `sys_operation_log` VALUES (3009, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:38:59');
INSERT INTO `sys_operation_log` VALUES (3010, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-24 01:38:59');
INSERT INTO `sys_operation_log` VALUES (3011, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:38:59');
INSERT INTO `sys_operation_log` VALUES (3012, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:39:00');
INSERT INTO `sys_operation_log` VALUES (3013, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:39:00');
INSERT INTO `sys_operation_log` VALUES (3014, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-24 01:39:00');
INSERT INTO `sys_operation_log` VALUES (3015, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 48ms', '2025-12-24 01:39:00');
INSERT INTO `sys_operation_log` VALUES (3016, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:40:45');
INSERT INTO `sys_operation_log` VALUES (3017, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:40:45');
INSERT INTO `sys_operation_log` VALUES (3018, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:40:45');
INSERT INTO `sys_operation_log` VALUES (3019, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:40:45');
INSERT INTO `sys_operation_log` VALUES (3020, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:40:49');
INSERT INTO `sys_operation_log` VALUES (3021, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:40:49');
INSERT INTO `sys_operation_log` VALUES (3022, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:42:31');
INSERT INTO `sys_operation_log` VALUES (3023, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3024, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3025, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3026, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3027, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3028, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3029, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:42:34');
INSERT INTO `sys_operation_log` VALUES (3030, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:42:47');
INSERT INTO `sys_operation_log` VALUES (3031, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:42:47');
INSERT INTO `sys_operation_log` VALUES (3032, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:42:47');
INSERT INTO `sys_operation_log` VALUES (3033, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:42:50');
INSERT INTO `sys_operation_log` VALUES (3034, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:42:50');
INSERT INTO `sys_operation_log` VALUES (3035, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:42:52');
INSERT INTO `sys_operation_log` VALUES (3036, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:42:52');
INSERT INTO `sys_operation_log` VALUES (3037, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:42:52');
INSERT INTO `sys_operation_log` VALUES (3038, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:42:53');
INSERT INTO `sys_operation_log` VALUES (3039, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:42:53');
INSERT INTO `sys_operation_log` VALUES (3040, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-24 01:42:55');
INSERT INTO `sys_operation_log` VALUES (3041, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-24 01:42:58');
INSERT INTO `sys_operation_log` VALUES (3042, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-24 01:43:04');
INSERT INTO `sys_operation_log` VALUES (3043, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-24 01:43:04');
INSERT INTO `sys_operation_log` VALUES (3044, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-24 01:43:04');
INSERT INTO `sys_operation_log` VALUES (3045, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-12-24 01:43:04');
INSERT INTO `sys_operation_log` VALUES (3046, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 01:43:21');
INSERT INTO `sys_operation_log` VALUES (3047, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:43:21');
INSERT INTO `sys_operation_log` VALUES (3048, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:43:21');
INSERT INTO `sys_operation_log` VALUES (3049, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-24 01:43:21');
INSERT INTO `sys_operation_log` VALUES (3050, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[4,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java、数据库、Spring综合能力测试\",\"orgId\":1,\"paperId\":4,\"paperName\":\"综合能力测试卷\",\"paperType\":1,\"passScore\":70,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-12-22 23:48:11\",\"validDays\":30,\"version\":1}] | 耗时: 18ms', '2025-12-24 01:43:52');
INSERT INTO `sys_operation_log` VALUES (3051, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[4,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":55,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java、数据库、Spring综合能力测试\",\"orgId\":1,\"paperId\":4,\"paperName\":\"综合能力测试卷\",\"paperType\":1,\"passScore\":70,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":30,\"updateTime\":\"2025-12-22 23:48:11\",\"validDays\":30,\"version\":1}] | 耗时: 23ms', '2025-12-24 01:44:14');
INSERT INTO `sys_operation_log` VALUES (3052, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:45:52');
INSERT INTO `sys_operation_log` VALUES (3053, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:45:52');
INSERT INTO `sys_operation_log` VALUES (3054, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:45:52');
INSERT INTO `sys_operation_log` VALUES (3055, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[53,{\"bankId\":53,\"bankName\":\"Spring框架题库\",\"bankType\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"deleted\":0,\"description\":\"Spring Boot、Spring MVC、Spring Cloud等框架知识\",\"orgId\":1,\"questionCount\":10,\"sort\":4,\"status\":1,\"subjectId\":6,\"updateTime\":\"2025-12-20 15:30:37\"}] | 耗时: 14ms', '2025-12-24 01:45:56');
INSERT INTO `sys_operation_log` VALUES (3056, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:45:56');
INSERT INTO `sys_operation_log` VALUES (3057, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:46:00');
INSERT INTO `sys_operation_log` VALUES (3058, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:46:00');
INSERT INTO `sys_operation_log` VALUES (3059, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:46:00');
INSERT INTO `sys_operation_log` VALUES (3060, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:46:00');
INSERT INTO `sys_operation_log` VALUES (3061, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:47:22');
INSERT INTO `sys_operation_log` VALUES (3062, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:47:22');
INSERT INTO `sys_operation_log` VALUES (3063, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-24 01:47:22');
INSERT INTO `sys_operation_log` VALUES (3064, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:47:22');
INSERT INTO `sys_operation_log` VALUES (3065, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 01:47:34');
INSERT INTO `sys_operation_log` VALUES (3066, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:47:34');
INSERT INTO `sys_operation_log` VALUES (3067, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:48:09');
INSERT INTO `sys_operation_log` VALUES (3068, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:48:09');
INSERT INTO `sys_operation_log` VALUES (3069, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:48:33');
INSERT INTO `sys_operation_log` VALUES (3070, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:48:33');
INSERT INTO `sys_operation_log` VALUES (3071, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:48:33');
INSERT INTO `sys_operation_log` VALUES (3072, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:48:35');
INSERT INTO `sys_operation_log` VALUES (3073, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:48:36');
INSERT INTO `sys_operation_log` VALUES (3074, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:48:39');
INSERT INTO `sys_operation_log` VALUES (3075, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:48:40');
INSERT INTO `sys_operation_log` VALUES (3076, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 01:54:14');
INSERT INTO `sys_operation_log` VALUES (3077, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-24 01:54:14');
INSERT INTO `sys_operation_log` VALUES (3078, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:54:18');
INSERT INTO `sys_operation_log` VALUES (3079, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:54:18');
INSERT INTO `sys_operation_log` VALUES (3080, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-12-24 01:54:18');
INSERT INTO `sys_operation_log` VALUES (3081, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:54:26');
INSERT INTO `sys_operation_log` VALUES (3082, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:54:26');
INSERT INTO `sys_operation_log` VALUES (3083, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:54:34');
INSERT INTO `sys_operation_log` VALUES (3084, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:54:34');
INSERT INTO `sys_operation_log` VALUES (3085, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 35ms', '2025-12-24 01:54:34');
INSERT INTO `sys_operation_log` VALUES (3086, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:54:43');
INSERT INTO `sys_operation_log` VALUES (3087, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-24 01:54:43');
INSERT INTO `sys_operation_log` VALUES (3088, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:55:45');
INSERT INTO `sys_operation_log` VALUES (3089, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:55:45');
INSERT INTO `sys_operation_log` VALUES (3090, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:55:46');
INSERT INTO `sys_operation_log` VALUES (3091, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-24 01:55:46');
INSERT INTO `sys_operation_log` VALUES (3092, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 6ms', '2025-12-24 01:55:46');
INSERT INTO `sys_operation_log` VALUES (3093, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:56:04');
INSERT INTO `sys_operation_log` VALUES (3094, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:56:04');
INSERT INTO `sys_operation_log` VALUES (3095, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-24 01:56:04');
INSERT INTO `sys_operation_log` VALUES (3096, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 01:56:04');
INSERT INTO `sys_operation_log` VALUES (3097, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 01:56:09');
INSERT INTO `sys_operation_log` VALUES (3098, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:56:09');
INSERT INTO `sys_operation_log` VALUES (3099, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 4ms', '2025-12-24 01:56:09');
INSERT INTO `sys_operation_log` VALUES (3100, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-24 01:56:09');
INSERT INTO `sys_operation_log` VALUES (3101, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-24 01:56:13');
INSERT INTO `sys_operation_log` VALUES (3102, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:56:39');
INSERT INTO `sys_operation_log` VALUES (3103, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-24 01:56:43');
INSERT INTO `sys_operation_log` VALUES (3104, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[11,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":58,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":11,\"paperName\":\"test\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":111,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 14ms', '2025-12-24 01:56:50');
INSERT INTO `sys_operation_log` VALUES (3105, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:57:03');
INSERT INTO `sys_operation_log` VALUES (3106, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 01:57:06');
INSERT INTO `sys_operation_log` VALUES (3107, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 01:57:06');
INSERT INTO `sys_operation_log` VALUES (3108, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 01:57:06');
INSERT INTO `sys_operation_log` VALUES (3109, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-24 01:57:06');
INSERT INTO `sys_operation_log` VALUES (3110, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[11,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":11,\"paperName\":\"test\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":111,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 20ms', '2025-12-24 01:57:10');
INSERT INTO `sys_operation_log` VALUES (3111, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[11,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":11,\"paperName\":\"test\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":111,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 4ms', '2025-12-24 01:58:05');
INSERT INTO `sys_operation_log` VALUES (3112, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[11,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":11,\"paperName\":\"test\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":111,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 4ms', '2025-12-24 01:58:22');
INSERT INTO `sys_operation_log` VALUES (3113, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:58:59');
INSERT INTO `sys_operation_log` VALUES (3114, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:59:04');
INSERT INTO `sys_operation_log` VALUES (3115, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:59:07');
INSERT INTO `sys_operation_log` VALUES (3116, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[11,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"\",\"orgId\":1,\"paperId\":11,\"paperName\":\"test\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":34,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 20ms', '2025-12-24 01:59:10');
INSERT INTO `sys_operation_log` VALUES (3117, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 01:59:13');
INSERT INTO `sys_operation_log` VALUES (3118, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 01:59:20');
INSERT INTO `sys_operation_log` VALUES (3119, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:59:25');
INSERT INTO `sys_operation_log` VALUES (3120, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-24 01:59:28');
INSERT INTO `sys_operation_log` VALUES (3121, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 02:00:01');
INSERT INTO `sys_operation_log` VALUES (3122, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 02:00:01');
INSERT INTO `sys_operation_log` VALUES (3123, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-24 02:00:01');
INSERT INTO `sys_operation_log` VALUES (3124, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 02:00:01');
INSERT INTO `sys_operation_log` VALUES (3125, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-24 02:00:13');
INSERT INTO `sys_operation_log` VALUES (3126, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 02:00:17');
INSERT INTO `sys_operation_log` VALUES (3127, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-24 02:00:17');
INSERT INTO `sys_operation_log` VALUES (3128, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 02:00:17');
INSERT INTO `sys_operation_log` VALUES (3129, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-24 02:00:17');
INSERT INTO `sys_operation_log` VALUES (3130, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 02:00:53');
INSERT INTO `sys_operation_log` VALUES (3131, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 02:00:53');
INSERT INTO `sys_operation_log` VALUES (3132, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-24 02:00:53');
INSERT INTO `sys_operation_log` VALUES (3133, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 02:01:07');
INSERT INTO `sys_operation_log` VALUES (3134, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 02:01:07');
INSERT INTO `sys_operation_log` VALUES (3135, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 02:01:16');
INSERT INTO `sys_operation_log` VALUES (3136, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 02:01:16');
INSERT INTO `sys_operation_log` VALUES (3137, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-24 02:01:16');
INSERT INTO `sys_operation_log` VALUES (3138, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 5ms', '2025-12-24 02:01:16');
INSERT INTO `sys_operation_log` VALUES (3139, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 02:01:20');
INSERT INTO `sys_operation_log` VALUES (3140, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-24 02:01:20');
INSERT INTO `sys_operation_log` VALUES (3141, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 02:01:20');
INSERT INTO `sys_operation_log` VALUES (3142, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 02:01:20');
INSERT INTO `sys_operation_log` VALUES (3143, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-24 02:04:13');
INSERT INTO `sys_operation_log` VALUES (3144, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-24 02:04:13');
INSERT INTO `sys_operation_log` VALUES (3145, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-24 02:04:19');
INSERT INTO `sys_operation_log` VALUES (3146, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 02:04:19');
INSERT INTO `sys_operation_log` VALUES (3147, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 02:04:19');
INSERT INTO `sys_operation_log` VALUES (3148, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-24 02:04:19');
INSERT INTO `sys_operation_log` VALUES (3149, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 02:04:32');
INSERT INTO `sys_operation_log` VALUES (3150, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 02:04:32');
INSERT INTO `sys_operation_log` VALUES (3151, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-24 02:04:32');
INSERT INTO `sys_operation_log` VALUES (3152, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 47ms', '2025-12-24 02:04:32');
INSERT INTO `sys_operation_log` VALUES (3153, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 02:04:42');
INSERT INTO `sys_operation_log` VALUES (3154, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-24 02:04:42');
INSERT INTO `sys_operation_log` VALUES (3155, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-24 02:04:42');
INSERT INTO `sys_operation_log` VALUES (3156, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-24 02:04:42');
INSERT INTO `sys_operation_log` VALUES (3157, 0, '更新', '试卷管理', '更新试卷', NULL, '0:0:0:0:0:0:0:1', '[1,{\"allowReexam\":0,\"allowViewAnalysis\":0,\"auditStatus\":2,\"bankId\":1,\"createTime\":\"2025-11-07 11:15:32\",\"createUserId\":1,\"description\":\"Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题\",\"orgId\":1,\"paperId\":1,\"paperName\":\"Java基础综合测试卷\",\"paperType\":1,\"passScore\":60,\"publishStatus\":0,\"reexamLimit\":0,\"totalScore\":0,\"updateTime\":\"2025-12-22 23:48:08\",\"validDays\":30,\"version\":1}] | 耗时: 6ms', '2025-12-24 02:17:25');
INSERT INTO `sys_operation_log` VALUES (3158, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 1639ms', '2025-12-24 23:44:44');
INSERT INTO `sys_operation_log` VALUES (3159, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 580ms', '2025-12-24 23:44:46');
INSERT INTO `sys_operation_log` VALUES (3160, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 590ms', '2025-12-24 23:44:46');
INSERT INTO `sys_operation_log` VALUES (3161, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 632ms', '2025-12-24 23:44:46');
INSERT INTO `sys_operation_log` VALUES (3162, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 77ms', '2025-12-24 23:44:50');
INSERT INTO `sys_operation_log` VALUES (3163, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-24 23:44:59');
INSERT INTO `sys_operation_log` VALUES (3164, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-24 23:44:59');
INSERT INTO `sys_operation_log` VALUES (3165, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-24 23:45:11');
INSERT INTO `sys_operation_log` VALUES (3166, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 16ms', '2025-12-24 23:45:11');
INSERT INTO `sys_operation_log` VALUES (3167, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-24 23:55:54');
INSERT INTO `sys_operation_log` VALUES (3168, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-24 23:55:54');
INSERT INTO `sys_operation_log` VALUES (3169, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:19:13');
INSERT INTO `sys_operation_log` VALUES (3170, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:19:13');
INSERT INTO `sys_operation_log` VALUES (3171, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 00:19:15');
INSERT INTO `sys_operation_log` VALUES (3172, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-25 00:19:15');
INSERT INTO `sys_operation_log` VALUES (3173, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:19:17');
INSERT INTO `sys_operation_log` VALUES (3174, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:19:17');
INSERT INTO `sys_operation_log` VALUES (3175, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:19:52');
INSERT INTO `sys_operation_log` VALUES (3176, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-25 00:19:52');
INSERT INTO `sys_operation_log` VALUES (3177, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 12ms', '2025-12-25 00:19:53');
INSERT INTO `sys_operation_log` VALUES (3178, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 00:19:55');
INSERT INTO `sys_operation_log` VALUES (3179, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 00:19:57');
INSERT INTO `sys_operation_log` VALUES (3180, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-25 00:19:57');
INSERT INTO `sys_operation_log` VALUES (3181, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 12ms', '2025-12-25 00:20:28');
INSERT INTO `sys_operation_log` VALUES (3182, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 00:20:29');
INSERT INTO `sys_operation_log` VALUES (3183, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 12ms', '2025-12-25 00:20:35');
INSERT INTO `sys_operation_log` VALUES (3184, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 00:20:36');
INSERT INTO `sys_operation_log` VALUES (3185, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 00:20:36');
INSERT INTO `sys_operation_log` VALUES (3186, 0, '查询', '科目管理', '查询科目学生 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT COUNT(*) AS total FROM subject_user WHERE deleted = 0 AND (subject_id = ? AND user_type = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 334ms', '2025-12-25 00:20:43');
INSERT INTO `sys_operation_log` VALUES (3187, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 10ms', '2025-12-25 00:20:50');
INSERT INTO `sys_operation_log` VALUES (3188, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:20:55');
INSERT INTO `sys_operation_log` VALUES (3189, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-25 00:20:55');
INSERT INTO `sys_operation_log` VALUES (3190, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:20:56');
INSERT INTO `sys_operation_log` VALUES (3191, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:20:56');
INSERT INTO `sys_operation_log` VALUES (3192, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:20:58');
INSERT INTO `sys_operation_log` VALUES (3193, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 00:20:58');
INSERT INTO `sys_operation_log` VALUES (3194, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 00:20:58');
INSERT INTO `sys_operation_log` VALUES (3195, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 00:21:00');
INSERT INTO `sys_operation_log` VALUES (3196, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-25 00:21:00');
INSERT INTO `sys_operation_log` VALUES (3197, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 00:21:02');
INSERT INTO `sys_operation_log` VALUES (3198, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-25 00:21:11');
INSERT INTO `sys_operation_log` VALUES (3199, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 00:21:22');
INSERT INTO `sys_operation_log` VALUES (3200, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 00:21:26');
INSERT INTO `sys_operation_log` VALUES (3201, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 00:21:29');
INSERT INTO `sys_operation_log` VALUES (3202, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-25 00:21:35');
INSERT INTO `sys_operation_log` VALUES (3203, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 00:21:40');
INSERT INTO `sys_operation_log` VALUES (3204, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-25 00:21:42');
INSERT INTO `sys_operation_log` VALUES (3205, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 00:21:43');
INSERT INTO `sys_operation_log` VALUES (3206, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 00:21:47');
INSERT INTO `sys_operation_log` VALUES (3207, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 00:22:13');
INSERT INTO `sys_operation_log` VALUES (3208, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 00:22:15');
INSERT INTO `sys_operation_log` VALUES (3209, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 00:22:16');
INSERT INTO `sys_operation_log` VALUES (3210, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:22:22');
INSERT INTO `sys_operation_log` VALUES (3211, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 00:22:22');
INSERT INTO `sys_operation_log` VALUES (3212, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 00:22:22');
INSERT INTO `sys_operation_log` VALUES (3213, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3214, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3215, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3216, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3217, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3218, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3219, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-25 00:22:25');
INSERT INTO `sys_operation_log` VALUES (3220, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:22:26');
INSERT INTO `sys_operation_log` VALUES (3221, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 00:22:26');
INSERT INTO `sys_operation_log` VALUES (3222, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:22:28');
INSERT INTO `sys_operation_log` VALUES (3223, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 00:22:28');
INSERT INTO `sys_operation_log` VALUES (3224, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-25 00:22:28');
INSERT INTO `sys_operation_log` VALUES (3225, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 8ms', '2025-12-25 00:22:28');
INSERT INTO `sys_operation_log` VALUES (3226, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:24:31');
INSERT INTO `sys_operation_log` VALUES (3227, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 00:24:31');
INSERT INTO `sys_operation_log` VALUES (3228, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 00:24:31');
INSERT INTO `sys_operation_log` VALUES (3229, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 00:24:31');
INSERT INTO `sys_operation_log` VALUES (3230, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:24:41');
INSERT INTO `sys_operation_log` VALUES (3231, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 00:24:41');
INSERT INTO `sys_operation_log` VALUES (3232, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 00:24:41');
INSERT INTO `sys_operation_log` VALUES (3233, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 00:24:42');
INSERT INTO `sys_operation_log` VALUES (3234, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 39ms', '2025-12-25 00:28:48');
INSERT INTO `sys_operation_log` VALUES (3235, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 1114ms', '2025-12-25 00:28:49');
INSERT INTO `sys_operation_log` VALUES (3236, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 00:33:09');
INSERT INTO `sys_operation_log` VALUES (3237, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 24ms', '2025-12-25 00:33:09');
INSERT INTO `sys_operation_log` VALUES (3238, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:34:45');
INSERT INTO `sys_operation_log` VALUES (3239, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 21ms', '2025-12-25 00:34:45');
INSERT INTO `sys_operation_log` VALUES (3240, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:35:11');
INSERT INTO `sys_operation_log` VALUES (3241, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 18ms', '2025-12-25 00:35:11');
INSERT INTO `sys_operation_log` VALUES (3242, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 141ms', '2025-12-25 00:35:11');
INSERT INTO `sys_operation_log` VALUES (3243, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:35:38');
INSERT INTO `sys_operation_log` VALUES (3244, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 17ms', '2025-12-25 00:35:38');
INSERT INTO `sys_operation_log` VALUES (3245, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:36:28');
INSERT INTO `sys_operation_log` VALUES (3246, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-25 00:36:28');
INSERT INTO `sys_operation_log` VALUES (3247, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:38:43');
INSERT INTO `sys_operation_log` VALUES (3248, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 15ms', '2025-12-25 00:38:43');
INSERT INTO `sys_operation_log` VALUES (3249, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 00:38:54');
INSERT INTO `sys_operation_log` VALUES (3250, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:38:54');
INSERT INTO `sys_operation_log` VALUES (3251, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:39:18');
INSERT INTO `sys_operation_log` VALUES (3252, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:39:18');
INSERT INTO `sys_operation_log` VALUES (3253, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:39:19');
INSERT INTO `sys_operation_log` VALUES (3254, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 00:39:19');
INSERT INTO `sys_operation_log` VALUES (3255, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 51ms', '2025-12-25 00:39:19');
INSERT INTO `sys_operation_log` VALUES (3256, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:39:35');
INSERT INTO `sys_operation_log` VALUES (3257, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 14ms', '2025-12-25 00:39:35');
INSERT INTO `sys_operation_log` VALUES (3258, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 00:46:37');
INSERT INTO `sys_operation_log` VALUES (3259, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 511ms', '2025-12-25 00:46:37');
INSERT INTO `sys_operation_log` VALUES (3260, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 00:54:41');
INSERT INTO `sys_operation_log` VALUES (3261, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 684ms', '2025-12-25 00:54:42');
INSERT INTO `sys_operation_log` VALUES (3262, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:54:42');
INSERT INTO `sys_operation_log` VALUES (3263, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 24ms', '2025-12-25 00:54:42');
INSERT INTO `sys_operation_log` VALUES (3264, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 146ms', '2025-12-25 00:54:42');
INSERT INTO `sys_operation_log` VALUES (3265, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:56:02');
INSERT INTO `sys_operation_log` VALUES (3266, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 22ms', '2025-12-25 00:56:02');
INSERT INTO `sys_operation_log` VALUES (3267, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 00:56:04');
INSERT INTO `sys_operation_log` VALUES (3268, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 22ms', '2025-12-25 00:56:04');
INSERT INTO `sys_operation_log` VALUES (3269, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 99ms', '2025-12-25 00:56:04');
INSERT INTO `sys_operation_log` VALUES (3270, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:56:07');
INSERT INTO `sys_operation_log` VALUES (3271, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 13ms', '2025-12-25 00:56:07');
INSERT INTO `sys_operation_log` VALUES (3272, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:56:08');
INSERT INTO `sys_operation_log` VALUES (3273, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-25 00:56:08');
INSERT INTO `sys_operation_log` VALUES (3274, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 52ms', '2025-12-25 00:56:08');
INSERT INTO `sys_operation_log` VALUES (3275, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:56:13');
INSERT INTO `sys_operation_log` VALUES (3276, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 11ms', '2025-12-25 00:56:13');
INSERT INTO `sys_operation_log` VALUES (3277, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 00:58:31');
INSERT INTO `sys_operation_log` VALUES (3278, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 12ms', '2025-12-25 00:58:31');
INSERT INTO `sys_operation_log` VALUES (3279, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 66ms', '2025-12-25 00:58:31');
INSERT INTO `sys_operation_log` VALUES (3280, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 00:58:57');
INSERT INTO `sys_operation_log` VALUES (3281, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-25 00:58:57');
INSERT INTO `sys_operation_log` VALUES (3282, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 00:58:58');
INSERT INTO `sys_operation_log` VALUES (3283, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-25 00:58:59');
INSERT INTO `sys_operation_log` VALUES (3284, 0, '查询', '试卷管理', '查询试卷列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 43ms', '2025-12-25 00:58:59');
INSERT INTO `sys_operation_log` VALUES (3285, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 01:00:05');
INSERT INTO `sys_operation_log` VALUES (3286, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 01:00:05');
INSERT INTO `sys_operation_log` VALUES (3287, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 01:00:14');
INSERT INTO `sys_operation_log` VALUES (3288, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-25 01:00:14');
INSERT INTO `sys_operation_log` VALUES (3289, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 01:00:40');
INSERT INTO `sys_operation_log` VALUES (3290, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 9ms', '2025-12-25 01:00:40');
INSERT INTO `sys_operation_log` VALUES (3291, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 01:01:06');
INSERT INTO `sys_operation_log` VALUES (3292, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 55ms', '2025-12-25 01:01:06');
INSERT INTO `sys_operation_log` VALUES (3293, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 01:01:09');
INSERT INTO `sys_operation_log` VALUES (3294, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 7ms', '2025-12-25 01:01:09');
INSERT INTO `sys_operation_log` VALUES (3295, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-25 01:03:28');
INSERT INTO `sys_operation_log` VALUES (3296, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 358ms', '2025-12-25 01:03:29');
INSERT INTO `sys_operation_log` VALUES (3297, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 18ms', '2025-12-25 01:04:44');
INSERT INTO `sys_operation_log` VALUES (3298, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 01:04:46');
INSERT INTO `sys_operation_log` VALUES (3299, 0, '查询', '科目管理', '查询科目学生 | 错误: \r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT COUNT(*) AS total FROM subject_user WHERE deleted = 0 AND (subject_id = ? AND user_type = ?)\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'exam_system.subject_user\' doesn\'t exist\n; bad SQL grammar []', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 282ms', '2025-12-25 01:04:48');
INSERT INTO `sys_operation_log` VALUES (3300, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 354ms', '2025-12-25 15:36:44');
INSERT INTO `sys_operation_log` VALUES (3301, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 304ms', '2025-12-25 15:36:45');
INSERT INTO `sys_operation_log` VALUES (3302, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 276ms', '2025-12-25 15:36:45');
INSERT INTO `sys_operation_log` VALUES (3303, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 329ms', '2025-12-25 15:36:45');
INSERT INTO `sys_operation_log` VALUES (3304, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 22ms', '2025-12-25 15:36:56');
INSERT INTO `sys_operation_log` VALUES (3305, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 31ms', '2025-12-25 15:36:56');
INSERT INTO `sys_operation_log` VALUES (3306, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-25 15:36:56');
INSERT INTO `sys_operation_log` VALUES (3307, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 15:37:15');
INSERT INTO `sys_operation_log` VALUES (3308, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 40ms', '2025-12-25 15:37:15');
INSERT INTO `sys_operation_log` VALUES (3309, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 41ms', '2025-12-25 15:37:15');
INSERT INTO `sys_operation_log` VALUES (3310, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 15:37:29');
INSERT INTO `sys_operation_log` VALUES (3311, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-25 15:37:29');
INSERT INTO `sys_operation_log` VALUES (3312, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 49ms', '2025-12-25 15:37:29');
INSERT INTO `sys_operation_log` VALUES (3313, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 15:37:31');
INSERT INTO `sys_operation_log` VALUES (3314, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-25 15:37:31');
INSERT INTO `sys_operation_log` VALUES (3315, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 10ms', '2025-12-25 15:37:31');
INSERT INTO `sys_operation_log` VALUES (3316, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 15:37:33');
INSERT INTO `sys_operation_log` VALUES (3317, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-25 15:37:33');
INSERT INTO `sys_operation_log` VALUES (3318, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 827ms', '2025-12-25 17:28:35');
INSERT INTO `sys_operation_log` VALUES (3319, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 17:28:37');
INSERT INTO `sys_operation_log` VALUES (3320, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 25ms', '2025-12-25 17:28:38');
INSERT INTO `sys_operation_log` VALUES (3321, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 87ms', '2025-12-25 17:28:38');
INSERT INTO `sys_operation_log` VALUES (3322, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 118ms', '2025-12-25 17:28:39');
INSERT INTO `sys_operation_log` VALUES (3323, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 45ms', '2025-12-25 17:28:45');
INSERT INTO `sys_operation_log` VALUES (3324, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 17:28:51');
INSERT INTO `sys_operation_log` VALUES (3325, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 17:28:51');
INSERT INTO `sys_operation_log` VALUES (3326, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 82ms', '2025-12-25 17:28:51');
INSERT INTO `sys_operation_log` VALUES (3327, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 17:28:53');
INSERT INTO `sys_operation_log` VALUES (3328, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 34ms', '2025-12-25 17:28:53');
INSERT INTO `sys_operation_log` VALUES (3329, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 17:28:54');
INSERT INTO `sys_operation_log` VALUES (3330, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 17:28:54');
INSERT INTO `sys_operation_log` VALUES (3331, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 61ms', '2025-12-25 17:28:54');
INSERT INTO `sys_operation_log` VALUES (3332, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 17:28:55');
INSERT INTO `sys_operation_log` VALUES (3333, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 61ms', '2025-12-25 17:28:55');
INSERT INTO `sys_operation_log` VALUES (3334, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 17:29:05');
INSERT INTO `sys_operation_log` VALUES (3335, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-25 17:29:05');
INSERT INTO `sys_operation_log` VALUES (3336, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 56ms', '2025-12-25 17:29:06');
INSERT INTO `sys_operation_log` VALUES (3337, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 17:29:47');
INSERT INTO `sys_operation_log` VALUES (3338, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 318ms', '2025-12-25 17:29:48');
INSERT INTO `sys_operation_log` VALUES (3339, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 20ms', '2025-12-25 17:29:48');
INSERT INTO `sys_operation_log` VALUES (3340, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 37ms', '2025-12-25 17:29:49');
INSERT INTO `sys_operation_log` VALUES (3341, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 62ms', '2025-12-25 17:29:49');
INSERT INTO `sys_operation_log` VALUES (3342, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 27ms', '2025-12-25 17:29:51');
INSERT INTO `sys_operation_log` VALUES (3343, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 33ms', '2025-12-25 17:30:05');
INSERT INTO `sys_operation_log` VALUES (3344, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 42ms', '2025-12-25 17:30:05');
INSERT INTO `sys_operation_log` VALUES (3345, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 55ms', '2025-12-25 17:30:05');
INSERT INTO `sys_operation_log` VALUES (3346, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 50ms', '2025-12-25 17:30:10');
INSERT INTO `sys_operation_log` VALUES (3347, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 17:30:13');
INSERT INTO `sys_operation_log` VALUES (3348, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 40ms', '2025-12-25 17:30:15');
INSERT INTO `sys_operation_log` VALUES (3349, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 17:30:15');
INSERT INTO `sys_operation_log` VALUES (3350, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 49ms', '2025-12-25 17:30:17');
INSERT INTO `sys_operation_log` VALUES (3351, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 17:30:19');
INSERT INTO `sys_operation_log` VALUES (3352, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 17:30:19');
INSERT INTO `sys_operation_log` VALUES (3353, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 17:30:21');
INSERT INTO `sys_operation_log` VALUES (3354, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 17:30:22');
INSERT INTO `sys_operation_log` VALUES (3355, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 17:30:22');
INSERT INTO `sys_operation_log` VALUES (3356, 0, '授权', '科目管理', '添加科目管理员', NULL, '0:0:0:0:0:0:0:1', '[1,{\"managerType\":1,\"permissions\":[\"MANAGE_STUDENT\",\"MANAGE_EXAM\",\"MANAGE_PAPER\",\"VIEW_ANALYSIS\",\"GRADE_EXAM\",\"MANAGE_QUESTION_BANK\"],\"userId\":3}] | 耗时: 43ms', '2025-12-25 17:30:33');
INSERT INTO `sys_operation_log` VALUES (3357, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 17:30:33');
INSERT INTO `sys_operation_log` VALUES (3358, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 17:30:39');
INSERT INTO `sys_operation_log` VALUES (3359, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 17:30:39');
INSERT INTO `sys_operation_log` VALUES (3360, 0, '查询', '科目管理', '查询科目学生', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 17:30:44');
INSERT INTO `sys_operation_log` VALUES (3361, 0, '查询', '科目管理', '查询可选学生', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 17:30:46');
INSERT INTO `sys_operation_log` VALUES (3362, 0, '学生管理', '科目管理', '添加学生到科目 | 错误: \r\n### Error updating database.  Cause: java.sql.SQLException: Field \'user_id\' doesn\'t have a default value\r\n### The error may exist in com/example/exam/mapper/subject/SubjectUserMapper.java (best guess)\r\n### The error may involve com.example.exam.mapper.subject.SubjectUserMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO subject_user  ( subject_id,  user_type,  join_time, create_time, update_time )  VALUES (  ?,  ?,  ?, ?, ?  )\r\n### Cause: java.sql.SQLException: Field \'user_id\' doesn\'t have a default value\n; Field \'user_id\' doesn\'t have a default value', NULL, '0:0:0:0:0:0:0:1', '[1,{\"enrollType\":1,\"studentIds\":[null]}] | 耗时: 322ms', '2025-12-25 17:30:53');
INSERT INTO `sys_operation_log` VALUES (3363, 0, '查询', '科目管理', '查询可选学生', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 17:31:01');
INSERT INTO `sys_operation_log` VALUES (3364, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 17:31:40');
INSERT INTO `sys_operation_log` VALUES (3365, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 43ms', '2025-12-25 17:31:42');
INSERT INTO `sys_operation_log` VALUES (3366, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 75ms', '2025-12-25 17:31:48');
INSERT INTO `sys_operation_log` VALUES (3367, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 43ms', '2025-12-25 17:31:51');
INSERT INTO `sys_operation_log` VALUES (3368, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 32ms', '2025-12-25 18:47:28');
INSERT INTO `sys_operation_log` VALUES (3369, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 57ms', '2025-12-25 18:47:32');
INSERT INTO `sys_operation_log` VALUES (3370, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:47:33');
INSERT INTO `sys_operation_log` VALUES (3371, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 38ms', '2025-12-25 18:47:34');
INSERT INTO `sys_operation_log` VALUES (3372, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:47:37');
INSERT INTO `sys_operation_log` VALUES (3373, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 227ms', '2025-12-25 18:47:38');
INSERT INTO `sys_operation_log` VALUES (3374, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 18:47:38');
INSERT INTO `sys_operation_log` VALUES (3375, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-25 18:47:38');
INSERT INTO `sys_operation_log` VALUES (3376, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 29ms', '2025-12-25 18:47:38');
INSERT INTO `sys_operation_log` VALUES (3377, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 42ms', '2025-12-25 18:47:39');
INSERT INTO `sys_operation_log` VALUES (3378, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:47:41');
INSERT INTO `sys_operation_log` VALUES (3379, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 32ms', '2025-12-25 18:47:42');
INSERT INTO `sys_operation_log` VALUES (3380, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 18:47:43');
INSERT INTO `sys_operation_log` VALUES (3381, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 36ms', '2025-12-25 18:47:43');
INSERT INTO `sys_operation_log` VALUES (3382, 0, '查询', '科目管理', '查询可选教师', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 18:47:44');
INSERT INTO `sys_operation_log` VALUES (3383, 0, '查询', '科目管理', '查询科目管理员', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 18:47:44');
INSERT INTO `sys_operation_log` VALUES (3384, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:47:47');
INSERT INTO `sys_operation_log` VALUES (3385, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 33ms', '2025-12-25 18:47:47');
INSERT INTO `sys_operation_log` VALUES (3386, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 18:47:50');
INSERT INTO `sys_operation_log` VALUES (3387, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 33ms', '2025-12-25 18:47:50');
INSERT INTO `sys_operation_log` VALUES (3388, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:52:28');
INSERT INTO `sys_operation_log` VALUES (3389, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 39ms', '2025-12-25 18:52:28');
INSERT INTO `sys_operation_log` VALUES (3390, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 18:52:30');
INSERT INTO `sys_operation_log` VALUES (3391, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 18:52:30');
INSERT INTO `sys_operation_log` VALUES (3392, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 18:52:30');
INSERT INTO `sys_operation_log` VALUES (3393, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 35ms', '2025-12-25 18:52:33');
INSERT INTO `sys_operation_log` VALUES (3394, 0, '查询', '科目管理', '查询科目学生', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:52:36');
INSERT INTO `sys_operation_log` VALUES (3395, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:52:38');
INSERT INTO `sys_operation_log` VALUES (3396, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 18:52:38');
INSERT INTO `sys_operation_log` VALUES (3397, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 36ms', '2025-12-25 18:52:38');
INSERT INTO `sys_operation_log` VALUES (3398, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 81ms', '2025-12-25 18:52:38');
INSERT INTO `sys_operation_log` VALUES (3399, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:52:43');
INSERT INTO `sys_operation_log` VALUES (3400, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:52:43');
INSERT INTO `sys_operation_log` VALUES (3401, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 28ms', '2025-12-25 18:52:43');
INSERT INTO `sys_operation_log` VALUES (3402, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 18:52:43');
INSERT INTO `sys_operation_log` VALUES (3403, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:52:57');
INSERT INTO `sys_operation_log` VALUES (3404, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:52:57');
INSERT INTO `sys_operation_log` VALUES (3405, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 56ms', '2025-12-25 18:52:57');
INSERT INTO `sys_operation_log` VALUES (3406, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 36ms', '2025-12-25 18:52:57');
INSERT INTO `sys_operation_log` VALUES (3407, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 33ms', '2025-12-25 18:53:06');
INSERT INTO `sys_operation_log` VALUES (3408, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:53:08');
INSERT INTO `sys_operation_log` VALUES (3409, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 18:53:11');
INSERT INTO `sys_operation_log` VALUES (3410, 0, '查询', '组织管理', '查询组织树', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:53:14');
INSERT INTO `sys_operation_log` VALUES (3411, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 18:53:19');
INSERT INTO `sys_operation_log` VALUES (3412, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 18:53:19');
INSERT INTO `sys_operation_log` VALUES (3413, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-25 18:53:19');
INSERT INTO `sys_operation_log` VALUES (3414, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 32ms', '2025-12-25 18:53:19');
INSERT INTO `sys_operation_log` VALUES (3415, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:53:23');
INSERT INTO `sys_operation_log` VALUES (3416, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:53:23');
INSERT INTO `sys_operation_log` VALUES (3417, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-25 18:53:23');
INSERT INTO `sys_operation_log` VALUES (3418, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:53:24');
INSERT INTO `sys_operation_log` VALUES (3419, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:53:24');
INSERT INTO `sys_operation_log` VALUES (3420, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:57:27');
INSERT INTO `sys_operation_log` VALUES (3421, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 18:57:27');
INSERT INTO `sys_operation_log` VALUES (3422, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 18:57:27');
INSERT INTO `sys_operation_log` VALUES (3423, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:57:32');
INSERT INTO `sys_operation_log` VALUES (3424, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 18:57:32');
INSERT INTO `sys_operation_log` VALUES (3425, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 18:57:33');
INSERT INTO `sys_operation_log` VALUES (3426, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 18:57:33');
INSERT INTO `sys_operation_log` VALUES (3427, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 18:57:33');
INSERT INTO `sys_operation_log` VALUES (3428, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 18:57:36');
INSERT INTO `sys_operation_log` VALUES (3429, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:57:36');
INSERT INTO `sys_operation_log` VALUES (3430, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 18:57:39');
INSERT INTO `sys_operation_log` VALUES (3431, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 18:57:39');
INSERT INTO `sys_operation_log` VALUES (3432, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:57:39');
INSERT INTO `sys_operation_log` VALUES (3433, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-25 18:57:39');
INSERT INTO `sys_operation_log` VALUES (3434, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:58:49');
INSERT INTO `sys_operation_log` VALUES (3435, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 214ms', '2025-12-25 18:58:50');
INSERT INTO `sys_operation_log` VALUES (3436, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 18:58:50');
INSERT INTO `sys_operation_log` VALUES (3437, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 18:58:50');
INSERT INTO `sys_operation_log` VALUES (3438, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 18:58:50');
INSERT INTO `sys_operation_log` VALUES (3439, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:58:59');
INSERT INTO `sys_operation_log` VALUES (3440, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 18:58:59');
INSERT INTO `sys_operation_log` VALUES (3441, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 26ms', '2025-12-25 18:58:59');
INSERT INTO `sys_operation_log` VALUES (3442, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:59:03');
INSERT INTO `sys_operation_log` VALUES (3443, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 206ms', '2025-12-25 18:59:04');
INSERT INTO `sys_operation_log` VALUES (3444, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 18:59:04');
INSERT INTO `sys_operation_log` VALUES (3445, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 18:59:04');
INSERT INTO `sys_operation_log` VALUES (3446, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 18:59:04');
INSERT INTO `sys_operation_log` VALUES (3447, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:59:19');
INSERT INTO `sys_operation_log` VALUES (3448, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 202ms', '2025-12-25 18:59:22');
INSERT INTO `sys_operation_log` VALUES (3449, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:59:22');
INSERT INTO `sys_operation_log` VALUES (3450, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 18:59:22');
INSERT INTO `sys_operation_log` VALUES (3451, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:59:22');
INSERT INTO `sys_operation_log` VALUES (3452, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 18:59:27');
INSERT INTO `sys_operation_log` VALUES (3453, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 18:59:27');
INSERT INTO `sys_operation_log` VALUES (3454, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 34ms', '2025-12-25 18:59:27');
INSERT INTO `sys_operation_log` VALUES (3455, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:59:31');
INSERT INTO `sys_operation_log` VALUES (3456, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 18:59:31');
INSERT INTO `sys_operation_log` VALUES (3457, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 18:59:31');
INSERT INTO `sys_operation_log` VALUES (3458, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 28ms', '2025-12-25 18:59:31');
INSERT INTO `sys_operation_log` VALUES (3459, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 18:59:47');
INSERT INTO `sys_operation_log` VALUES (3460, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 18:59:47');
INSERT INTO `sys_operation_log` VALUES (3461, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-25 18:59:47');
INSERT INTO `sys_operation_log` VALUES (3462, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 18:59:47');
INSERT INTO `sys_operation_log` VALUES (3463, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 18:59:59');
INSERT INTO `sys_operation_log` VALUES (3464, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 18:59:59');
INSERT INTO `sys_operation_log` VALUES (3465, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 19:00:07');
INSERT INTO `sys_operation_log` VALUES (3466, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:00:07');
INSERT INTO `sys_operation_log` VALUES (3467, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 30ms', '2025-12-25 19:00:07');
INSERT INTO `sys_operation_log` VALUES (3468, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:00:08');
INSERT INTO `sys_operation_log` VALUES (3469, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:00:08');
INSERT INTO `sys_operation_log` VALUES (3470, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:00:08');
INSERT INTO `sys_operation_log` VALUES (3471, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 19:00:10');
INSERT INTO `sys_operation_log` VALUES (3472, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:00:10');
INSERT INTO `sys_operation_log` VALUES (3473, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:00:10');
INSERT INTO `sys_operation_log` VALUES (3474, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 28ms', '2025-12-25 19:00:10');
INSERT INTO `sys_operation_log` VALUES (3475, 0, '创建', '题目管理', '创建题目', NULL, '0:0:0:0:0:0:0:1', '[{\"analysis\":\"我个人\",\"bankId\":1,\"correctAnswer\":\"\",\"defaultScore\":5,\"difficulty\":2,\"knowledgeIds\":\"\",\"options\":[{\"isCorrect\":1,\"optionContent\":\"为如果\",\"optionSeq\":\"A\"},{\"isCorrect\":0,\"optionContent\":\"为如果\",\"optionSeq\":\"B\"},{\"isCorrect\":0,\"optionContent\":\" 为如果\",\"optionSeq\":\"C\"}],\"questionContent\":\"还是热回收\",\"questionType\":1}] | 耗时: 74ms', '2025-12-25 19:00:32');
INSERT INTO `sys_operation_log` VALUES (3476, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:00:32');
INSERT INTO `sys_operation_log` VALUES (3477, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 19:01:29');
INSERT INTO `sys_operation_log` VALUES (3478, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 19:01:34');
INSERT INTO `sys_operation_log` VALUES (3479, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-25 19:02:32');
INSERT INTO `sys_operation_log` VALUES (3480, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 19:04:28');
INSERT INTO `sys_operation_log` VALUES (3481, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:22:31');
INSERT INTO `sys_operation_log` VALUES (3482, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 19:22:31');
INSERT INTO `sys_operation_log` VALUES (3483, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 14ms', '2025-12-25 19:22:31');
INSERT INTO `sys_operation_log` VALUES (3484, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:22:34');
INSERT INTO `sys_operation_log` VALUES (3485, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 19:22:34');
INSERT INTO `sys_operation_log` VALUES (3486, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 26ms', '2025-12-25 19:22:34');
INSERT INTO `sys_operation_log` VALUES (3487, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 19:22:35');
INSERT INTO `sys_operation_log` VALUES (3488, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:22:35');
INSERT INTO `sys_operation_log` VALUES (3489, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:24:05');
INSERT INTO `sys_operation_log` VALUES (3490, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:24:08');
INSERT INTO `sys_operation_log` VALUES (3491, 0, '更新', '题库管理', '更新题库', NULL, '0:0:0:0:0:0:0:1', '[1,{\"bankId\":1,\"bankName\":\"默认题库\",\"bankType\":1,\"description\":\"Java编程语言基础知识题库，包含语法、面向对象、集合等内容\"}] | 耗时: 26ms', '2025-12-25 19:24:11');
INSERT INTO `sys_operation_log` VALUES (3492, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 19:24:11');
INSERT INTO `sys_operation_log` VALUES (3493, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 13ms', '2025-12-25 19:24:11');
INSERT INTO `sys_operation_log` VALUES (3494, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:26:30');
INSERT INTO `sys_operation_log` VALUES (3495, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:26:30');
INSERT INTO `sys_operation_log` VALUES (3496, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 19:26:30');
INSERT INTO `sys_operation_log` VALUES (3497, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 26ms', '2025-12-25 19:26:30');
INSERT INTO `sys_operation_log` VALUES (3498, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:26:39');
INSERT INTO `sys_operation_log` VALUES (3499, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:26:39');
INSERT INTO `sys_operation_log` VALUES (3500, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:26:39');
INSERT INTO `sys_operation_log` VALUES (3501, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 29ms', '2025-12-25 19:26:39');
INSERT INTO `sys_operation_log` VALUES (3502, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 19:26:44');
INSERT INTO `sys_operation_log` VALUES (3503, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 19:26:44');
INSERT INTO `sys_operation_log` VALUES (3504, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:26:44');
INSERT INTO `sys_operation_log` VALUES (3505, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 31ms', '2025-12-25 19:26:44');
INSERT INTO `sys_operation_log` VALUES (3506, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:32:45');
INSERT INTO `sys_operation_log` VALUES (3507, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:32:45');
INSERT INTO `sys_operation_log` VALUES (3508, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-25 19:32:45');
INSERT INTO `sys_operation_log` VALUES (3509, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 38ms', '2025-12-25 19:32:45');
INSERT INTO `sys_operation_log` VALUES (3510, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:32:49');
INSERT INTO `sys_operation_log` VALUES (3511, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:32:49');
INSERT INTO `sys_operation_log` VALUES (3512, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 34ms', '2025-12-25 19:32:49');
INSERT INTO `sys_operation_log` VALUES (3513, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:32:51');
INSERT INTO `sys_operation_log` VALUES (3514, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:32:51');
INSERT INTO `sys_operation_log` VALUES (3515, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-25 19:32:52');
INSERT INTO `sys_operation_log` VALUES (3516, 0, '查询', '科目管理', '获取我的科目列表', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 19:33:01');
INSERT INTO `sys_operation_log` VALUES (3517, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 7ms', '2025-12-25 19:33:01');
INSERT INTO `sys_operation_log` VALUES (3518, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"size\":100}] | 耗时: 25ms', '2025-12-25 19:33:01');
INSERT INTO `sys_operation_log` VALUES (3519, 0, '查询', '题库管理', '查询题库统计信息', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 19:33:06');
INSERT INTO `sys_operation_log` VALUES (3520, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-25 19:33:06');
INSERT INTO `sys_operation_log` VALUES (3521, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 10ms', '2025-12-25 19:33:07');
INSERT INTO `sys_operation_log` VALUES (3522, 0, '查询', '科目管理', '分页查询科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 24ms', '2025-12-25 19:35:49');
INSERT INTO `sys_operation_log` VALUES (3523, 0, '查询', '科目管理', '查询科目详情', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 19:35:51');
INSERT INTO `sys_operation_log` VALUES (3524, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 38ms', '2025-12-25 21:05:17');
INSERT INTO `sys_operation_log` VALUES (3525, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 332ms', '2025-12-25 21:05:20');
INSERT INTO `sys_operation_log` VALUES (3526, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 24ms', '2025-12-25 21:05:20');
INSERT INTO `sys_operation_log` VALUES (3527, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 21:05:20');
INSERT INTO `sys_operation_log` VALUES (3528, 0, '查询', '题目管理', '分页查询题目 | 错误: 您没有权限执行此操作：查看题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 26ms', '2025-12-25 21:05:20');
INSERT INTO `sys_operation_log` VALUES (3529, 0, '查询', '题目管理', '分页查询题目 | 错误: 您没有权限执行此操作：查看题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 21:06:20');
INSERT INTO `sys_operation_log` VALUES (3530, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 19ms', '2025-12-25 21:06:20');
INSERT INTO `sys_operation_log` VALUES (3531, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 18ms', '2025-12-25 21:06:20');
INSERT INTO `sys_operation_log` VALUES (3532, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 21:11:11');
INSERT INTO `sys_operation_log` VALUES (3533, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 216ms', '2025-12-25 21:11:12');
INSERT INTO `sys_operation_log` VALUES (3534, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:12:02');
INSERT INTO `sys_operation_log` VALUES (3535, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 437ms', '2025-12-25 21:12:07');
INSERT INTO `sys_operation_log` VALUES (3536, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 6ms', '2025-12-25 21:12:07');
INSERT INTO `sys_operation_log` VALUES (3537, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:12:07');
INSERT INTO `sys_operation_log` VALUES (3538, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-25 21:12:07');
INSERT INTO `sys_operation_log` VALUES (3539, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 21:12:18');
INSERT INTO `sys_operation_log` VALUES (3540, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:12:18');
INSERT INTO `sys_operation_log` VALUES (3541, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 21:12:27');
INSERT INTO `sys_operation_log` VALUES (3542, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:12:27');
INSERT INTO `sys_operation_log` VALUES (3543, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 12ms', '2025-12-25 21:12:27');
INSERT INTO `sys_operation_log` VALUES (3544, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:15:54');
INSERT INTO `sys_operation_log` VALUES (3545, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:15:54');
INSERT INTO `sys_operation_log` VALUES (3546, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 36ms', '2025-12-25 21:15:54');
INSERT INTO `sys_operation_log` VALUES (3547, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 21:16:01');
INSERT INTO `sys_operation_log` VALUES (3548, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 195ms', '2025-12-25 21:16:03');
INSERT INTO `sys_operation_log` VALUES (3549, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:16:36');
INSERT INTO `sys_operation_log` VALUES (3550, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 206ms', '2025-12-25 21:23:36');
INSERT INTO `sys_operation_log` VALUES (3551, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:23:36');
INSERT INTO `sys_operation_log` VALUES (3552, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:23:36');
INSERT INTO `sys_operation_log` VALUES (3553, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 16ms', '2025-12-25 21:23:36');
INSERT INTO `sys_operation_log` VALUES (3554, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:26:27');
INSERT INTO `sys_operation_log` VALUES (3555, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:26:30');
INSERT INTO `sys_operation_log` VALUES (3556, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:26:30');
INSERT INTO `sys_operation_log` VALUES (3557, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 50ms', '2025-12-25 21:26:30');
INSERT INTO `sys_operation_log` VALUES (3558, 0, '查询', '科目管理', '分页查询科目 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', '[{\"current\":1,\"keyword\":\"\",\"size\":10}] | 耗时: 5ms', '2025-12-25 21:26:35');
INSERT INTO `sys_operation_log` VALUES (3559, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:26:37');
INSERT INTO `sys_operation_log` VALUES (3560, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:26:37');
INSERT INTO `sys_operation_log` VALUES (3561, 0, '查询', '试卷管理', '分页查询试卷', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 30ms', '2025-12-25 21:26:37');
INSERT INTO `sys_operation_log` VALUES (3562, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:26:38');
INSERT INTO `sys_operation_log` VALUES (3563, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 21:26:38');
INSERT INTO `sys_operation_log` VALUES (3564, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 21:26:39');
INSERT INTO `sys_operation_log` VALUES (3565, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 4ms', '2025-12-25 21:26:39');
INSERT INTO `sys_operation_log` VALUES (3566, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 15ms', '2025-12-25 21:26:39');
INSERT INTO `sys_operation_log` VALUES (3567, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 1ms', '2025-12-25 21:29:59');
INSERT INTO `sys_operation_log` VALUES (3568, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 0ms', '2025-12-25 21:29:59');
INSERT INTO `sys_operation_log` VALUES (3569, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 5ms', '2025-12-25 21:29:59');
INSERT INTO `sys_operation_log` VALUES (3570, 0, '查询', '科目管理', '获取我的科目列表 | 错误: 您没有权限执行此操作：查看科目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 2ms', '2025-12-25 22:07:33');
INSERT INTO `sys_operation_log` VALUES (3571, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 3ms', '2025-12-25 22:07:33');
INSERT INTO `sys_operation_log` VALUES (3572, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 21ms', '2025-12-25 22:07:33');
INSERT INTO `sys_operation_log` VALUES (3573, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 17ms', '2025-12-25 22:26:47');
INSERT INTO `sys_operation_log` VALUES (3574, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 811ms', '2025-12-25 22:26:52');
INSERT INTO `sys_operation_log` VALUES (3575, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 239ms', '2025-12-25 22:26:52');
INSERT INTO `sys_operation_log` VALUES (3576, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 263ms', '2025-12-25 22:26:52');
INSERT INTO `sys_operation_log` VALUES (3577, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 308ms', '2025-12-25 22:26:52');
INSERT INTO `sys_operation_log` VALUES (3578, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 1468ms', '2025-12-26 01:08:24');
INSERT INTO `sys_operation_log` VALUES (3579, 0, '查询', '题库管理', '分页查询题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 271ms', '2025-12-26 01:08:26');
INSERT INTO `sys_operation_log` VALUES (3580, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 333ms', '2025-12-26 01:08:26');
INSERT INTO `sys_operation_log` VALUES (3581, 0, '查询', '用户管理', '分页查询用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 361ms', '2025-12-26 01:08:26');
INSERT INTO `sys_operation_log` VALUES (3582, 0, '登出', '认证模块', '用户登出', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 9ms', '2025-12-26 01:08:38');
INSERT INTO `sys_operation_log` VALUES (3583, 0, '登录', '认证模块', '用户登录', NULL, '0:0:0:0:0:0:0:1', '参数序列化失败 | 耗时: 226ms', '2025-12-26 01:08:50');
INSERT INTO `sys_operation_log` VALUES (3584, 0, '查询', '题库管理', '分页查询题库 | 错误: 您没有权限执行此操作：查看题库', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 11ms', '2025-12-26 01:08:50');
INSERT INTO `sys_operation_log` VALUES (3585, 0, '查询', '用户管理', '分页查询用户 | 错误: 您没有权限执行此操作：查看用户', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 8ms', '2025-12-26 01:08:50');
INSERT INTO `sys_operation_log` VALUES (3586, 0, '查询', '题目管理', '分页查询题目', NULL, '0:0:0:0:0:0:0:1', ' | 耗时: 52ms', '2025-12-26 01:08:50');

-- ----------------------------
-- Table structure for sys_organization
-- ----------------------------
DROP TABLE IF EXISTS `sys_organization`;
CREATE TABLE `sys_organization`  (
  `org_id` bigint NOT NULL AUTO_INCREMENT COMMENT '组织ID',
  `org_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织名称',
  `org_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织编码',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父组织ID（0为顶级）',
  `org_level` tinyint NOT NULL DEFAULT 1 COMMENT '组织层级：1-一级，2-二级，3-三级，4-四级',
  `org_type` tinyint NOT NULL DEFAULT 1 COMMENT '组织类型：1-学校，2-企业，3-培训机构',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`org_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_org_level`(`org_level` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 243 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组织表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_organization
-- ----------------------------
INSERT INTO `sys_organization` VALUES (1, '系统默认组织', 'DEFAULT_ORG', 0, 1, 1, 1, 1, '2025-11-06 11:08:34', '2025-11-09 02:30:42', 0);
INSERT INTO `sys_organization` VALUES (227, '示例大学', 'SCHOOL_001', 0, 1, 1, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:30:42', 0);
INSERT INTO `sys_organization` VALUES (228, '示例科技公司', 'ENTERPRISE_001', 0, 1, 2, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:30:42', 0);
INSERT INTO `sys_organization` VALUES (229, '计算机学院', 'COLLEGE_CS', 227, 2, 1, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:18', 0);
INSERT INTO `sys_organization` VALUES (230, '软件学院', 'COLLEGE_SE', 227, 2, 1, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:21', 0);
INSERT INTO `sys_organization` VALUES (231, '信息学院', 'COLLEGE_IT', 227, 2, 1, 3, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:24', 0);
INSERT INTO `sys_organization` VALUES (232, '技术部', 'DEPT_TECH', 228, 2, 2, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:26', 0);
INSERT INTO `sys_organization` VALUES (233, '产品部', 'DEPT_PRODUCT', 228, 2, 2, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:37', 0);
INSERT INTO `sys_organization` VALUES (234, '2021级计算机1班', 'CLASS_CS_2021_1', 229, 3, 1, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:39', 0);
INSERT INTO `sys_organization` VALUES (235, '2021级计算机2班', 'CLASS_CS_2021_2', 229, 3, 1, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:41', 0);
INSERT INTO `sys_organization` VALUES (236, '2022级计算机1班', 'CLASS_CS_2022_1', 229, 3, 1, 3, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:44', 0);
INSERT INTO `sys_organization` VALUES (237, '2021级软件1班', 'CLASS_SE_2021_1', 230, 3, 1, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:46', 0);
INSERT INTO `sys_organization` VALUES (238, '2021级软件2班', 'CLASS_SE_2021_2', 230, 3, 1, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:50', 0);
INSERT INTO `sys_organization` VALUES (239, '前端组', 'TEAM_FRONTEND', 232, 3, 2, 1, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:53', 0);
INSERT INTO `sys_organization` VALUES (240, '后端组', 'TEAM_BACKEND', 232, 3, 2, 2, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:54', 0);
INSERT INTO `sys_organization` VALUES (241, '测试组', 'TEAM_QA', 232, 3, 2, 3, 1, '2025-11-07 11:15:32', '2025-11-09 02:32:57', 0);
INSERT INTO `sys_organization` VALUES (242, 'testorg', 'testcode', 0, 1, 1, 0, 1, '2025-11-20 10:46:27', '2025-11-20 10:46:27', 0);

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `perm_id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `perm_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限名称',
  `perm_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限编码',
  `perm_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限类型：MENU-菜单，BUTTON-按钮，API-接口',
  `perm_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限URL或路由',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父权限ID',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`perm_id`) USING BTREE,
  UNIQUE INDEX `uk_perm_code`(`perm_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 56 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, '系统管理', 'system', 'MENU', '/system', 0, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (2, '用户管理', 'system:user', 'MENU', '/system/user', 1, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (3, '查看用户', 'system:user:view', 'BUTTON', NULL, 2, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (4, '创建用户', 'system:user:create', 'BUTTON', NULL, 2, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (5, '编辑用户', 'system:user:update', 'BUTTON', NULL, 2, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (6, '删除用户', 'system:user:delete', 'BUTTON', NULL, 2, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (7, '审核用户', 'system:user:audit', 'BUTTON', NULL, 2, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (8, '角色管理', 'system:role', 'MENU', '/system/role', 1, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (9, '查看角色', 'system:role:view', 'BUTTON', NULL, 8, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (10, '创建角色', 'system:role:create', 'BUTTON', NULL, 8, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (11, '编辑角色', 'system:role:update', 'BUTTON', NULL, 8, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (12, '删除角色', 'system:role:delete', 'BUTTON', NULL, 8, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (13, '分配权限', 'system:role:assign', 'BUTTON', NULL, 8, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (14, '组织管理', 'system:org', 'MENU', '/system/organization', 1, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (15, '查看组织', 'system:org:view', 'BUTTON', NULL, 14, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (16, '创建组织', 'system:org:create', 'BUTTON', NULL, 14, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (17, '编辑组织', 'system:org:update', 'BUTTON', NULL, 14, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (18, '删除组织', 'system:org:delete', 'BUTTON', NULL, 14, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (19, '题库管理', 'bank', 'MENU', '/question-bank', 0, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (20, '查看题库', 'bank:view', 'BUTTON', NULL, 19, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (21, '创建题库', 'bank:create', 'BUTTON', NULL, 19, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (22, '编辑题库', 'bank:update', 'BUTTON', NULL, 19, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (23, '删除题库', 'bank:delete', 'BUTTON', NULL, 19, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (24, '题目管理', 'question', 'MENU', '/question', 0, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (25, '查看题目', 'question:view', 'BUTTON', NULL, 24, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (26, '创建题目', 'question:create', 'BUTTON', NULL, 24, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (27, '编辑题目', 'question:update', 'BUTTON', NULL, 24, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (28, '删除题目', 'question:delete', 'BUTTON', NULL, 24, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (29, '导入题目', 'question:import', 'BUTTON', NULL, 24, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (30, '导出题目', 'question:export', 'BUTTON', NULL, 24, 6, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (31, '试卷管理', 'paper', 'MENU', '/paper', 0, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (32, '查看试卷', 'paper:view', 'BUTTON', NULL, 31, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (33, '创建试卷', 'paper:create', 'BUTTON', NULL, 31, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (34, '编辑试卷', 'paper:update', 'BUTTON', NULL, 31, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (35, '删除试卷', 'paper:delete', 'BUTTON', NULL, 31, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (36, '审核试卷', 'paper:audit', 'BUTTON', NULL, 31, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (37, '发布试卷', 'paper:publish', 'BUTTON', NULL, 31, 6, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (38, '考试管理', 'exam', 'MENU', '/exam', 0, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (39, '查看考试', 'exam:view', 'BUTTON', NULL, 38, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (40, '创建考试', 'exam:create', 'BUTTON', NULL, 38, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (41, '编辑考试', 'exam:update', 'BUTTON', NULL, 38, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (42, '删除考试', 'exam:delete', 'BUTTON', NULL, 38, 4, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (43, '发布考试', 'exam:publish', 'BUTTON', NULL, 38, 5, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (44, '开始考试', 'exam:start', 'BUTTON', NULL, 38, 6, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (45, '结束考试', 'exam:end', 'BUTTON', NULL, 38, 7, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (46, '监控考试', 'exam:monitor', 'BUTTON', NULL, 38, 8, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (47, '参加考试', 'exam:take', 'BUTTON', NULL, 38, 9, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (48, '阅卷管理', 'grading', 'MENU', '/grading', 0, 6, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (49, '查看答卷', 'grading:view', 'BUTTON', NULL, 48, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (50, '批阅试卷', 'grading:grade', 'BUTTON', NULL, 48, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (51, '发布成绩', 'grading:publish', 'BUTTON', NULL, 48, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (52, '统计分析', 'statistics', 'MENU', '/statistics', 0, 7, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (53, '考试统计', 'statistics:exam', 'BUTTON', NULL, 52, 1, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (54, '成绩统计', 'statistics:score', 'BUTTON', NULL, 52, 2, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);
INSERT INTO `sys_permission` VALUES (55, '题目统计', 'statistics:question', 'BUTTON', NULL, 52, 3, '2025-11-24 09:48:40', '2025-11-24 09:48:40', 0);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `role_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色编码',
  `role_desc` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色描述',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否预设角色：0-自定义，1-预设（不可删除）',
  `create_user_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 68 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '系统管理员', 'ADMIN', '系统管理员，拥有所有权限', 1, NULL, 1, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34', 0);
INSERT INTO `sys_role` VALUES (2, '教师', 'TEACHER', '教师角色，可以出题、组卷、批改、查看成绩', 1, NULL, 2, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34', 0);
INSERT INTO `sys_role` VALUES (3, '考生', 'STUDENT', '考生角色，可以参加考试、查看成绩', 1, NULL, 3, 1, '2025-11-06 11:08:34', '2025-11-06 11:08:34', 0);
INSERT INTO `sys_role` VALUES (4, '教务管理员', 'ACADEMIC_ADMIN', '负责教务管理工作，可管理课程、考试等', 0, NULL, 4, 1, '2025-11-07 11:15:32', '2025-11-24 09:47:12', 0);
INSERT INTO `sys_role` VALUES (5, '班主任', 'CLASS_TEACHER', '负责班级管理，可查看本班学生成绩', 0, NULL, 5, 1, '2025-11-07 11:15:32', '2025-11-24 09:47:14', 0);
INSERT INTO `sys_role` VALUES (6, '助教', 'ASSISTANT', '协助教师工作，可批改作业和试卷', 0, NULL, 6, 1, '2025-11-07 11:15:32', '2025-11-24 09:47:15', 0);
INSERT INTO `sys_role` VALUES (67, '访客', 'GUEST', '访客角色，仅有查看权限', 0, NULL, 7, 1, '2025-11-07 11:15:32', '2025-11-07 11:15:32', 0);

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `perm_id` bigint NOT NULL COMMENT '权限ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_perm`(`role_id` ASC, `perm_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_perm_id`(`perm_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 132 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (1, 1, 1, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (2, 1, 2, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (3, 1, 3, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (4, 1, 4, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (5, 1, 5, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (6, 1, 6, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (7, 1, 7, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (8, 1, 8, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (9, 1, 9, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (10, 1, 10, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (11, 1, 11, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (12, 1, 12, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (13, 1, 13, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (14, 1, 14, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (15, 1, 15, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (16, 1, 16, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (17, 1, 17, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (18, 1, 18, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (19, 1, 19, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (20, 1, 20, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (21, 1, 21, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (22, 1, 22, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (23, 1, 23, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (24, 1, 24, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (25, 1, 25, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (26, 1, 26, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (27, 1, 27, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (28, 1, 28, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (29, 1, 29, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (30, 1, 30, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (31, 1, 31, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (32, 1, 32, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (33, 1, 33, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (34, 1, 34, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (35, 1, 35, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (36, 1, 36, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (37, 1, 37, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (38, 1, 38, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (39, 1, 39, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (40, 1, 40, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (41, 1, 41, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (42, 1, 42, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (43, 1, 43, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (44, 1, 44, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (45, 1, 45, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (46, 1, 46, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (47, 1, 47, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (48, 1, 48, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (49, 1, 49, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (50, 1, 50, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (51, 1, 51, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (52, 1, 52, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (53, 1, 53, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (54, 1, 54, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (55, 1, 55, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (64, 2, 19, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (65, 2, 20, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (66, 2, 21, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (67, 2, 22, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (68, 2, 23, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (69, 2, 24, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (70, 2, 25, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (71, 2, 26, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (72, 2, 27, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (73, 2, 28, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (74, 2, 29, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (75, 2, 30, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (76, 2, 31, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (77, 2, 32, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (78, 2, 33, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (79, 2, 34, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (80, 2, 35, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (81, 2, 38, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (82, 2, 39, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (83, 2, 40, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (84, 2, 41, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (85, 2, 43, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (86, 2, 44, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (87, 2, 45, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (88, 2, 46, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (89, 2, 48, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (90, 2, 49, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (91, 2, 50, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (92, 2, 51, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (93, 2, 52, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (94, 2, 53, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (95, 2, 54, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (96, 2, 55, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (127, 3, 38, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (128, 3, 47, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (129, 3, 39, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (130, 3, 52, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);
INSERT INTO `sys_role_permission` VALUES (131, 3, 54, '2025-11-24 09:48:40', '2025-11-30 22:13:50', 0);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（登录账号）',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（Bcrypt加密）',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号（AES-256加密）',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱（AES-256加密）',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `gender` tinyint NULL DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
  `org_id` bigint NULL DEFAULT 1 COMMENT '组织ID（可为空）',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `audit_status` tinyint NULL DEFAULT 1 COMMENT '审核状态：0-待审核，1-已通过，2-已拒绝',
  `audit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_audit_status`(`audit_status` ASC) USING BTREE,
  INDEX `idx_deleted`(`deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$V9x1fo.fCyKlJRhOtdyuweI7M78Pha/vVLFJ/SD.PIKTLw1gHsvv.', '系统管理员', '18431043674', '252905733@qq.com', NULL, 0, 1, 1, 1, 1, NULL, '2025-12-26 01:08:24', '0:0:0:0:0:0:0:1', '2025-11-06 11:08:34', '2025-12-26 01:08:24', 0);
INSERT INTO `sys_user` VALUES (3, 'Test', '$2a$10$V9x1fo.fCyKlJRhOtdyuweI7M78Pha/vVLFJ/SD.PIKTLw1gHsvv.', '杨克言', '18531043673', '252905763@qq.com', NULL, 0, 1, 2, 1, 0, NULL, '2025-12-26 01:08:50', '0:0:0:0:0:0:0:1', '2025-11-06 21:53:20', '2025-12-26 01:08:50', 0);
INSERT INTO `sys_user` VALUES (5, 'Student', '$2a$10$V9x1fo.fCyKlJRhOtdyuweI7M78Pha/vVLFJ/SD.PIKTLw1gHsvv.', '王琳焱', '18531043676', '252905764@qq.com', NULL, 0, 1, 3, 1, 0, NULL, '2025-12-25 21:16:03', '0:0:0:0:0:0:0:1', '2025-11-10 10:38:43', '2025-12-25 21:16:03', 0);

SET FOREIGN_KEY_CHECKS = 1;
