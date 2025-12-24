-- ========================================
-- 在线考试系统 - 完整测试数据
-- 版本: 2.0
-- 生成时间: 2025-11-06
-- ========================================

USE exam_system;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
-- 0. 组织测试数据（新增）
-- ========================================
-- 清空现有组织数据（保留ID=1的默认组织）
DELETE FROM sys_organization WHERE org_id > 1;

-- 插入组织数据
INSERT INTO sys_organization (org_name, org_code, parent_id, org_level, org_type, sort, status, create_time, update_time) VALUES
-- 顶级组织（学校）
('示例大学', 'SCHOOL_001', 0, 1, 'SCHOOL', 1, 1, NOW(), NOW()),
('示例科技公司', 'ENTERPRISE_001', 0, 1, 'ENTERPRISE', 2, 1, NOW(), NOW()),

-- 二级组织（学院/部门）
('计算机学院', 'COLLEGE_CS', 2, 2, 'SCHOOL', 1, 1, NOW(), NOW()),
('软件学院', 'COLLEGE_SE', 2, 2, 'SCHOOL', 2, 1, NOW(), NOW()),
('信息学院', 'COLLEGE_IT', 2, 2, 'SCHOOL', 3, 1, NOW(), NOW()),
('技术部', 'DEPT_TECH', 3, 2, 'ENTERPRISE', 1, 1, NOW(), NOW()),
('产品部', 'DEPT_PRODUCT', 3, 2, 'ENTERPRISE', 2, 1, NOW(), NOW()),

-- 三级组织（班级/小组）
('2021级计算机1班', 'CLASS_CS_2021_1', 4, 3, 'SCHOOL', 1, 1, NOW(), NOW()),
('2021级计算机2班', 'CLASS_CS_2021_2', 4, 3, 'SCHOOL', 2, 1, NOW(), NOW()),
('2022级计算机1班', 'CLASS_CS_2022_1', 4, 3, 'SCHOOL', 3, 1, NOW(), NOW()),
('2021级软件1班', 'CLASS_SE_2021_1', 5, 3, 'SCHOOL', 1, 1, NOW(), NOW()),
('2021级软件2班', 'CLASS_SE_2021_2', 5, 3, 'SCHOOL', 2, 1, NOW(), NOW()),
('前端组', 'TEAM_FRONTEND', 7, 3, 'ENTERPRISE', 1, 1, NOW(), NOW()),
('后端组', 'TEAM_BACKEND', 7, 3, 'ENTERPRISE', 2, 1, NOW(), NOW()),
('测试组', 'TEAM_QA', 7, 3, 'ENTERPRISE', 3, 1, NOW(), NOW());

-- ========================================
-- 0.5 角色测试数据（新增）
-- ========================================
-- 注意：角色表已有3个预设角色（role_id: 1-系统管理员, 2-教师, 3-学生）
-- 这里添加一些自定义角色

-- 先删除可能存在的测试角色（role_id > 3）
DELETE FROM sys_role WHERE role_id > 3;

INSERT INTO sys_role (role_name, role_code, role_desc, is_default, sort, status, create_time, update_time) VALUES
-- 自定义角色
('教务管理员', 'ACADEMIC_ADMIN', '负责教务管理工作，可管理课程、考试等', 0, 4, 1, NOW(), NOW()),
('班主任', 'CLASS_TEACHER', '负责班级管理，可查看本班学生成绩', 0, 5, 1, NOW(), NOW()),
('助教', 'ASSISTANT', '协助教师工作，可批改作业和试卷', 0, 6, 1, NOW(), NOW()),
('访客', 'GUEST', '访客角色，仅有查看权限', 0, 7, 1, NOW(), NOW());

-- ========================================
-- 0.6 权限测试数据（新增）
-- ========================================
-- 注意：权限表已有预设权限，这里添加完整的权限树结构

DELETE FROM sys_permission WHERE perm_id > 0;

INSERT INTO sys_permission (perm_name, perm_code, perm_type, perm_url, parent_id, sort, create_time) VALUES
-- 系统管理模块
('系统管理', 'system', 'MENU', '/system', 0, 1, NOW()),
('组织管理', 'organization:view', 'MENU', '/system/organization', 1, 1, NOW()),
('组织新增', 'organization:create', 'BUTTON', '/api/organization', 2, 1, NOW()),
('组织编辑', 'organization:edit', 'BUTTON', '/api/organization/*', 2, 2, NOW()),
('组织删除', 'organization:delete', 'BUTTON', '/api/organization/*', 2, 3, NOW()),
('角色管理', 'role:view', 'MENU', '/system/role', 1, 2, NOW()),
('角色新增', 'role:create', 'BUTTON', '/api/role', 6, 1, NOW()),
('角色编辑', 'role:edit', 'BUTTON', '/api/role/*', 6, 2, NOW()),
('角色删除', 'role:delete', 'BUTTON', '/api/role/*', 6, 3, NOW()),
('权限管理', 'permission:view', 'MENU', '/system/permission', 1, 3, NOW()),
('知识点管理', 'knowledge:view', 'MENU', '/system/knowledge', 1, 4, NOW()),

-- 题库管理模块
('题库管理', 'question_bank', 'MENU', '/question-bank', 0, 2, NOW()),
('题库查看', 'question_bank:view', 'BUTTON', '/api/question-bank/*', 12, 1, NOW()),
('题库新增', 'question_bank:create', 'BUTTON', '/api/question-bank', 12, 2, NOW()),
('题库编辑', 'question_bank:edit', 'BUTTON', '/api/question-bank/*', 12, 3, NOW()),
('题库删除', 'question_bank:delete', 'BUTTON', '/api/question-bank/*', 12, 4, NOW()),

-- 题目管理模块
('题目管理', 'question', 'MENU', '/question', 0, 3, NOW()),
('题目查看', 'question:view', 'BUTTON', '/api/question/*', 17, 1, NOW()),
('题目新增', 'question:create', 'BUTTON', '/api/question', 17, 2, NOW()),
('题目编辑', 'question:edit', 'BUTTON', '/api/question/*', 17, 3, NOW()),
('题目删除', 'question:delete', 'BUTTON', '/api/question/*', 17, 4, NOW()),
('题目审核', 'question:audit', 'BUTTON', '/api/question/audit/*', 17, 5, NOW()),

-- 试卷管理模块
('试卷管理', 'paper', 'MENU', '/paper', 0, 4, NOW()),
('试卷查看', 'paper:view', 'BUTTON', '/api/paper/*', 23, 1, NOW()),
('试卷新增', 'paper:create', 'BUTTON', '/api/paper', 23, 2, NOW()),
('试卷编辑', 'paper:edit', 'BUTTON', '/api/paper/*', 23, 3, NOW()),
('试卷删除', 'paper:delete', 'BUTTON', '/api/paper/*', 23, 4, NOW()),

-- 考试管理模块
('考试管理', 'exam', 'MENU', '/exam', 0, 5, NOW()),
('考试查看', 'exam:view', 'BUTTON', '/api/exam/*', 28, 1, NOW()),
('考试新增', 'exam:create', 'BUTTON', '/api/exam', 28, 2, NOW()),
('考试编辑', 'exam:edit', 'BUTTON', '/api/exam/*', 28, 3, NOW()),
('考试删除', 'exam:delete', 'BUTTON', '/api/exam/*', 28, 4, NOW()),
('考试监控', 'exam:monitor', 'BUTTON', '/api/exam/monitor/*', 28, 5, NOW());

-- ========================================
-- 1. 题库测试数据
-- ========================================
DELETE FROM question_bank WHERE bank_id > 1;

INSERT INTO question_bank (bank_name, description, bank_type, question_count, create_user_id, org_id, status, create_time, update_time) VALUES
                                                                                                                                            ('Java基础题库', 'Java编程语言基础知识题库，包含语法、面向对象、集合等内容', 'PUBLIC', 0, 1, 1, 1, NOW(), NOW()),
                                                                                                                                            ('数据库原理题库', 'MySQL、SQL语句、索引、事务等数据库相关知识', 'PUBLIC', 0, 1, 1, 1, NOW(), NOW()),
                                                                                                                                            ('Spring框架题库', 'Spring Boot、Spring MVC、Spring Cloud等框架知识', 'PUBLIC', 0, 1, 1, 1, NOW(), NOW()),
                                                                                                                                            ('算法与数据结构题库', '常见算法、数据结构、时间复杂度等计算机基础', 'PUBLIC', 0, 1, 1, 1, NOW(), NOW()),
                                                                                                                                            ('计算机网络题库', 'TCP/IP、HTTP协议、网络安全等网络基础知识', 'PUBLIC', 0, 1, 1, 1, NOW(), NOW());

-- ========================================
-- 2. 知识点测试数据
-- ========================================
DELETE FROM knowledge_point WHERE knowledge_id > 1;

INSERT INTO knowledge_point (knowledge_name, parent_id, level, org_id, description, create_time, update_time) VALUES
-- Java基础知识点
('Java基础', NULL, 1, 1, 'Java编程语言基础', NOW(), NOW()),
('面向对象', 1, 2, 1, '封装、继承、多态', NOW(), NOW()),
('集合框架', 1, 2, 1, 'List、Set、Map等集合', NOW(), NOW()),
('异常处理', 1, 2, 1, '异常机制与处理', NOW(), NOW()),
('多线程', 1, 2, 1, '线程、并发、同步', NOW(), NOW()),

-- 数据库知识点
('数据库', NULL, 1, 1, '数据库相关知识', NOW(), NOW()),
('SQL语句', 6, 2, 1, 'SELECT、INSERT、UPDATE、DELETE', NOW(), NOW()),
('索引优化', 6, 2, 1, '索引类型与优化策略', NOW(), NOW()),
('事务管理', 6, 2, 1, 'ACID特性与事务隔离级别', NOW(), NOW()),

-- Spring框架知识点
('Spring框架', NULL, 1, 1, 'Spring生态体系', NOW(), NOW()),
('IOC容器', 10, 2, 1, '依赖注入与控制反转', NOW(), NOW()),
('AOP编程', 10, 2, 1, '面向切面编程', NOW(), NOW()),
('Spring MVC', 10, 2, 1, 'Web MVC框架', NOW(), NOW()),

-- 算法知识点
('算法', NULL, 1, 1, '算法与数据结构', NOW(), NOW()),
('排序算法', 14, 2, 1, '冒泡、快排、归并等', NOW(), NOW()),
('查找算法', 14, 2, 1, '二分查找、哈希查找', NOW(), NOW()),
('动态规划', 14, 2, 1, 'DP算法思想', NOW(), NOW());


-- ========================================
-- 3. 题目测试数据 - Java基础
-- ========================================
DELETE FROM question WHERE question_id > 1;

-- Java单选题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (1, 1, '下列哪个关键字用于定义Java类？', 'SINGLE_CHOICE', 2.0, 'EASY', '1,2', NULL, '正确答案是class。class是Java中定义类的关键字。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, 'Java中的String类是否可以被继承？', 'SINGLE_CHOICE', 2.0, 'MEDIUM', '1,2', NULL, '正确答案是不能。String类被final修饰，无法被继承。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, '下列哪个不是Java的访问修饰符？', 'SINGLE_CHOICE', 2.0, 'EASY', '1,2', NULL, '正确答案是friendly。Java中的访问修饰符有public、protected、private和默认(包访问权限)。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, 'Java中equals()和==的区别是什么？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '1,2', NULL, '==比较的是对象的引用地址，equals()比较的是对象的内容。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, '以下哪个集合类是线程安全的？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '1,3', NULL, '正确答案是Vector。Vector是线程安全的，而ArrayList不是。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- Java多选题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (1, 1, 'Java中面向对象的三大特性包括哪些？', 'MULTIPLE_CHOICE', 4.0, 'EASY', '1,2', NULL, '面向对象的三大特性是：封装、继承、多态。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, '下列哪些是Java中的基本数据类型？', 'MULTIPLE_CHOICE', 4.0, 'EASY', '1', NULL, 'Java的8种基本数据类型：byte、short、int、long、float、double、char、boolean。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, 'Java异常处理中，下列哪些是正确的？', 'MULTIPLE_CHOICE', 5.0, 'MEDIUM', '1,4', NULL, 'try块必须配合catch或finally使用；finally块一定会执行（除非JVM退出）。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- Java判断题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (1, 1, 'Java是纯面向对象的编程语言。', 'TRUE_FALSE', 2.0, 'EASY', '1,2', NULL, '错误。Java不是纯面向对象语言，因为它包含8种基本数据类型，它们不是对象。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, 'Java中的方法可以重载(overload)也可以重写(override)。', 'TRUE_FALSE', 2.0, 'MEDIUM', '1,2', NULL, '正确。重载发生在同一个类中，重写发生在父类和子类之间。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- Java填空题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (1, 1, 'Java中，_____关键字用于继承父类，_____关键字用于实现接口。', 'FILL_BLANK', 4.0, 'EASY', '1,2', 'extends|implements', '第一空：extends，第二空：implements', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (1, 1, 'HashMap的默认初始容量是_____，默认负载因子是_____。', 'FILL_BLANK', 4.0, 'MEDIUM', '1,3', '16|0.75', 'HashMap默认容量为16，负载因子为0.75', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- Java主观题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, reference_answer, score_rule, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                                              (1, 1, '请简述Java中ArrayList和LinkedList的区别，并说明在什么场景下使用哪种数据结构更合适。', 'SUBJECTIVE', 10.0, 'MEDIUM', '1,3',
                                                                                                                                                                                                                                                               'ArrayList基于动态数组实现，查询快(O(1))，插入删除慢(O(n))；LinkedList基于双向链表实现，插入删除快(O(1))，查询慢(O(n))。使用场景：频繁查询用ArrayList，频繁插入删除用LinkedList。',
                                                                                                                                                                                                                                                               '答出数据结构差异4分，答出时间复杂度3分，答出使用场景3分',
                                                                                                                                                                                                                                                               '关键点：底层数据结构、时间复杂度、使用场景', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                                              (1, 1, '请解释Java中的垃圾回收机制(GC)，并说明常见的垃圾回收算法。', 'SUBJECTIVE', 10.0, 'HARD', '1,5',
                                                                                                                                                                                                                                                               'Java的垃圾回收机制自动管理内存，回收不再使用的对象。常见算法：1.标记-清除算法 2.复制算法 3.标记-整理算法 4.分代收集算法。',
                                                                                                                                                                                                                                                               '答出GC基本概念3分，答出2-3种算法4分，详细说明算法原理3分',
                                                                                                                                                                                                                                                               '关键点：自动内存管理、可达性分析、GC算法', 0, 0.00, 1, 1, 1, NOW(), NOW());


-- ========================================
-- 4. 题目测试数据 - 数据库
-- ========================================
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
-- 数据库单选题
(2, 1, '在MySQL中，哪个存储引擎支持事务？', 'SINGLE_CHOICE', 2.0, 'EASY', '6,9', NULL, '正确答案是InnoDB。InnoDB支持事务、外键等特性。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
(2, 1, 'SQL语句中，DISTINCT关键字的作用是什么？', 'SINGLE_CHOICE', 2.0, 'EASY', '6,7', NULL, 'DISTINCT用于去除重复的记录。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
(2, 1, '数据库的ACID特性中，I代表什么？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '6,9', NULL, 'I代表Isolation（隔离性），表示并发事务之间相互隔离。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
(2, 1, '以下哪种索引类型查询效率最高？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '6,8', NULL, '主键索引效率最高，因为数据按主键物理排序。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
(2, 1, 'MySQL中，LEFT JOIN和RIGHT JOIN的区别是什么？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '6,7', NULL, 'LEFT JOIN返回左表所有记录和右表匹配记录，RIGHT JOIN相反。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- 数据库多选题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (2, 1, '以下哪些是MySQL支持的数据类型？', 'MULTIPLE_CHOICE', 4.0, 'EASY', '6', NULL, 'MySQL支持INT、VARCHAR、TEXT、DATE、DATETIME等多种数据类型。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (2, 1, '数据库索引的优点包括哪些？', 'MULTIPLE_CHOICE', 4.0, 'MEDIUM', '6,8', NULL, '索引可以加快查询速度、实现唯一性约束、加速表与表之间的连接。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- 数据库判断题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (2, 1, '数据库的主键可以为NULL值。', 'TRUE_FALSE', 2.0, 'EASY', '6', NULL, '错误。主键不能为NULL，必须唯一且非空。', 0, 0.00, 1, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (2, 1, '索引可以提高数据的查询速度，但会降低写入速度。', 'TRUE_FALSE', 2.0, 'MEDIUM', '6,8', NULL, '正确。索引需要额外的存储空间和维护成本，影响插入、更新、删除的性能。', 0, 0.00, 1, 1, 1, NOW(), NOW());

-- 数据库主观题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, reference_answer, score_rule, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
    (2, 1, '请解释数据库的三大范式，并举例说明。', 'SUBJECTIVE', 10.0, 'MEDIUM', '6',
     '第一范式(1NF)：每个字段都是不可分割的原子值。第二范式(2NF)：消除部分依赖，非主键字段完全依赖主键。第三范式(3NF)：消除传递依赖，非主键字段不依赖其他非主键字段。',
     '每个范式定义正确3分，举例说明1分',
     '关键点：原子性、完全依赖、消除传递依赖', 0, 0.00, 2, 1, 1, NOW(), NOW());


-- ========================================
-- 5. 题目测试数据 - Spring框架
-- ========================================
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
-- Spring单选题
(3, 1, 'Spring框架的核心是什么？', 'SINGLE_CHOICE', 2.0, 'EASY', '10,11', NULL, '正确答案是IOC和AOP。IOC(控制反转)和AOP(面向切面编程)是Spring的两大核心。', 0, 0.00, 2, 1, 1, NOW(), NOW()),
(3, 1, 'Spring Boot的主要作用是什么？', 'SINGLE_CHOICE', 2.0, 'EASY', '10', NULL, 'Spring Boot简化了Spring应用的配置和部署，提供了自动配置功能。', 0, 0.00, 2, 1, 1, NOW(), NOW()),
(3, 1, '@Autowired注解的作用是什么？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '10,11', NULL, '@Autowired实现依赖注入，自动装配Bean。', 0, 0.00, 2, 1, 1, NOW(), NOW()),
(3, 1, 'Spring中Bean的默认作用域是什么？', 'SINGLE_CHOICE', 3.0, 'MEDIUM', '10,11', NULL, '默认作用域是singleton（单例模式）。', 0, 0.00, 2, 1, 1, NOW(), NOW());

-- Spring多选题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, answer_list, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
                                                                                                                                                                                                                                             (3, 1, 'Spring Boot的优点包括哪些？', 'MULTIPLE_CHOICE', 4.0, 'EASY', '10', NULL, 'Spring Boot提供自动配置、内嵌服务器、简化依赖管理、生产就绪特性等。', 0, 0.00, 2, 1, 1, NOW(), NOW()),
                                                                                                                                                                                                                                             (3, 1, 'Spring AOP的应用场景包括哪些？', 'MULTIPLE_CHOICE', 5.0, 'MEDIUM', '10,12', NULL, 'AOP常用于日志记录、事务管理、权限控制、性能监控等场景。', 0, 0.00, 2, 1, 1, NOW(), NOW());

-- Spring主观题
INSERT INTO question (bank_id, org_id, question_content, question_type, default_score, difficulty, knowledge_ids, reference_answer, score_rule, answer_analysis, use_count, correct_rate, audit_status, create_user_id, status, create_time, update_time) VALUES
    (3, 1, '请解释Spring IOC的工作原理，并说明依赖注入的三种方式。', 'SUBJECTIVE', 10.0, 'MEDIUM', '10,11',
     'IOC将对象创建和依赖关系的管理交给容器，降低耦合度。三种依赖注入方式：1.构造器注入 2.Setter注入 3.字段注入。推荐使用构造器注入。',
     '答出IOC原理4分，答出三种注入方式6分',
     '关键点：控制反转、依赖注入、容器管理', 0, 0.00, 2, 1, 1, NOW(), NOW());


-- ========================================
-- 6. 题目选项数据（单选、多选、判断）
-- ========================================
DELETE FROM question_option WHERE option_id > 1;

-- Java题目选项
INSERT INTO question_option (question_id, option_seq, option_content, is_correct, sort) VALUES
-- 题目1：Java类定义关键字
(1, 'A', 'class', 1, 1),
(1, 'B', 'Class', 0, 2),
(1, 'C', 'struct', 0, 3),
(1, 'D', 'interface', 0, 4),

-- 题目2：String是否可继承
(2, 'A', '可以', 0, 1),
(2, 'B', '不能', 1, 2),
(2, 'C', '看情况', 0, 3),
(2, 'D', '需要配置', 0, 4),

-- 题目3：访问修饰符
(3, 'A', 'public', 0, 1),
(3, 'B', 'protected', 0, 2),
(3, 'C', 'private', 0, 3),
(3, 'D', 'friendly', 1, 4),

-- 题目4：equals和==
(4, 'A', '没有区别', 0, 1),
(4, 'B', '==比较引用，equals比较内容', 1, 2),
(4, 'C', '==比较内容，equals比较引用', 0, 3),
(4, 'D', '都比较引用', 0, 4),

-- 题目5：线程安全集合
(5, 'A', 'ArrayList', 0, 1),
(5, 'B', 'Vector', 1, 2),
(5, 'C', 'LinkedList', 0, 3),
(5, 'D', 'HashMap', 0, 4),

-- 题目6：面向对象三大特性（多选）
(6, 'A', '封装', 1, 1),
(6, 'B', '继承', 1, 2),
(6, 'C', '多态', 1, 3),
(6, 'D', '抽象', 0, 4),

-- 题目7：基本数据类型（多选）
(7, 'A', 'int', 1, 1),
(7, 'B', 'long', 1, 2),
(7, 'C', 'String', 0, 3),
(7, 'D', 'boolean', 1, 4),
(7, 'E', 'char', 1, 5),

-- 题目8：异常处理（多选）
(8, 'A', 'try块必须配合catch或finally', 1, 1),
(8, 'B', 'finally块一定会执行', 1, 2),
(8, 'C', 'catch块可以有多个', 1, 3),
(8, 'D', 'try块可以单独使用', 0, 4),

-- 题目9：判断-Java是纯面向对象
(9, 'A', '正确', 0, 1),
(9, 'B', '错误', 1, 2),

-- 题目10：判断-方法重载和重写
(10, 'A', '正确', 1, 1),
(10, 'B', '错误', 0, 2);

-- 数据库题目选项
INSERT INTO question_option (question_id, option_seq, option_content, is_correct, sort) VALUES
-- 题目15：支持事务的存储引擎
(15, 'A', 'MyISAM', 0, 1),
(15, 'B', 'InnoDB', 1, 2),
(15, 'C', 'Memory', 0, 3),
(15, 'D', 'CSV', 0, 4),

-- 题目16：DISTINCT作用
(16, 'A', '排序', 0, 1),
(16, 'B', '去重', 1, 2),
(16, 'C', '分组', 0, 3),
(16, 'D', '过滤', 0, 4),

-- 题目17：ACID中的I
(17, 'A', 'Atomicity原子性', 0, 1),
(17, 'B', 'Consistency一致性', 0, 2),
(17, 'C', 'Isolation隔离性', 1, 3),
(17, 'D', 'Durability持久性', 0, 4),

-- 题目18：索引类型效率
(18, 'A', '主键索引', 1, 1),
(18, 'B', '唯一索引', 0, 2),
(18, 'C', '普通索引', 0, 3),
(18, 'D', '全文索引', 0, 4),

-- 题目19：LEFT JOIN和RIGHT JOIN
(19, 'A', '没有区别', 0, 1),
(19, 'B', 'LEFT JOIN返回左表所有记录', 1, 2),
(19, 'C', 'RIGHT JOIN返回左表所有记录', 0, 3),
(19, 'D', '两者都返回所有记录', 0, 4),

-- 题目20：MySQL数据类型（多选）
(20, 'A', 'INT', 1, 1),
(20, 'B', 'VARCHAR', 1, 2),
(20, 'C', 'TEXT', 1, 3),
(20, 'D', 'DATE', 1, 4),

-- 题目21：索引优点（多选）
(21, 'A', '加快查询速度', 1, 1),
(21, 'B', '实现唯一性约束', 1, 2),
(21, 'C', '加速表连接', 1, 3),
(21, 'D', '减少存储空间', 0, 4),

-- 题目22：判断-主键可为NULL
(22, 'A', '正确', 0, 1),
(22, 'B', '错误', 1, 2),

-- 题目23：判断-索引影响写入
(23, 'A', '正确', 1, 1),
(23, 'B', '错误', 0, 2);

-- Spring题目选项
INSERT INTO question_option (question_id, option_seq, option_content, is_correct, sort) VALUES
-- 题目25：Spring核心
(25, 'A', 'IOC和AOP', 1, 1),
(25, 'B', 'MVC和ORM', 0, 2),
(25, 'C', 'REST和SOAP', 0, 3),
(25, 'D', 'JPA和Hibernate', 0, 4),

-- 题目26：Spring Boot作用
(26, 'A', '简化配置和部署', 1, 1),
(26, 'B', '提高运行速度', 0, 2),
(26, 'C', '增强安全性', 0, 3),
(26, 'D', '优化数据库', 0, 4),

-- 题目27：@Autowired作用
(27, 'A', '创建Bean', 0, 1),
(27, 'B', '依赖注入', 1, 2),
(27, 'C', '配置属性', 0, 3),
(27, 'D', '声明事务', 0, 4),

-- 题目28：Bean默认作用域
(28, 'A', 'singleton', 1, 1),
(28, 'B', 'prototype', 0, 2),
(28, 'C', 'request', 0, 3),
(28, 'D', 'session', 0, 4),

-- 题目29：Spring Boot优点（多选）
(29, 'A', '自动配置', 1, 1),
(29, 'B', '内嵌服务器', 1, 2),
(29, 'C', '简化依赖', 1, 3),
(29, 'D', '生产就绪', 1, 4),

-- 题目30：AOP应用场景（多选）
(30, 'A', '日志记录', 1, 1),
(30, 'B', '事务管理', 1, 2),
(30, 'C', '权限控制', 1, 3),
(30, 'D', '性能监控', 1, 4);


-- ========================================
-- 7. 试卷测试数据
-- ========================================
DELETE FROM paper WHERE paper_id > 1;

INSERT INTO paper (paper_name, description, paper_type, pass_score, total_score, org_id, create_user_id, audit_status, publish_status, create_time, update_time) VALUES
                                                                                                                                                                     ('Java基础综合测试卷', 'Java语言基础知识综合测试，包含单选、多选、判断、填空、主观题', 1, 60.0, 100.0, 1, 1, 0, 0, NOW(), NOW()),
                                                                                                                                                                     ('数据库原理期中考试', 'MySQL数据库原理期中考试试卷', 1, 60.0, 100.0, 1, 1, 0, 0, NOW(), NOW()),
                                                                                                                                                                     ('Spring框架快速测试', 'Spring框架知识点快速测试', 2, 60.0, 100.0, 1, 1, 0, 0, NOW(), NOW()),
                                                                                                                                                                     ('综合能力测试卷', 'Java、数据库、Spring综合能力测试', 1, 70.0, 150.0, 1, 1, 0, 0, NOW(), NOW());


-- ========================================
-- 8. 试卷-题目关联数据
-- ========================================
-- 注意：paper_question表的主键是id，不是relation_id

-- 试卷1：Java基础综合测试卷（50道题，100分）
INSERT INTO paper_question (paper_id, question_id, question_score, sort_order) VALUES
-- 单选题（20题，每题2分，共40分）
(1, 1, 2.0, 1), (1, 2, 2.0, 2), (1, 3, 2.0, 3), (1, 4, 3.0, 4), (1, 5, 3.0, 5),
-- 多选题（8题，每题4-5分，共35分）
(1, 6, 4.0, 6), (1, 7, 4.0, 7), (1, 8, 5.0, 8),
-- 判断题（5题，每题2分，共10分）
(1, 9, 2.0, 9), (1, 10, 2.0, 10),
-- 填空题（2题，每题4分，共8分）
(1, 11, 4.0, 11), (1, 12, 4.0, 12),
-- 主观题（2题，每题10分，共20分）
(1, 13, 10.0, 13), (1, 14, 10.0, 14);

-- 试卷2：数据库原理期中考试（45道题，100分）
INSERT INTO paper_question (paper_id, question_id, question_score, sort_order) VALUES
-- 单选题（20题，每题2-3分，共50分）
(2, 15, 2.0, 1), (2, 16, 2.0, 2), (2, 17, 3.0, 3), (2, 18, 3.0, 4), (2, 19, 3.0, 5),
-- 多选题（5题，每题4分，共20分）
(2, 20, 4.0, 6), (2, 21, 4.0, 7),
-- 判断题（5题，每题2分，共10分）
(2, 22, 2.0, 8), (2, 23, 2.0, 9),
-- 主观题（2题，每题10分，共20分）
(2, 24, 10.0, 10);

-- 试卷3：Spring框架快速测试（30道题，100分）
INSERT INTO paper_question (paper_id, question_id, question_score, sort_order) VALUES
-- 单选题（15题，每题2-3分，共40分）
(3, 25, 2.0, 1), (3, 26, 2.0, 2), (3, 27, 3.0, 3), (3, 28, 3.0, 4),
-- 多选题（5题，每题4-5分，共22分）
(3, 29, 4.0, 5), (3, 30, 5.0, 6),
-- 主观题（1题，10分）
(3, 31, 10.0, 7);

-- 试卷4：综合能力测试卷（60道题，150分）
INSERT INTO paper_question (paper_id, question_id, question_score, sort_order) VALUES
-- Java题目
(4, 1, 2.0, 1), (4, 2, 2.0, 2), (4, 3, 2.0, 3), (4, 4, 3.0, 4), (4, 5, 3.0, 5),
(4, 6, 4.0, 6), (4, 7, 4.0, 7), (4, 8, 5.0, 8),
(4, 9, 2.0, 9), (4, 10, 2.0, 10),
(4, 11, 4.0, 11), (4, 12, 4.0, 12),
(4, 13, 10.0, 13), (4, 14, 10.0, 14),
-- 数据库题目
(4, 15, 2.0, 15), (4, 16, 2.0, 16), (4, 17, 3.0, 17), (4, 18, 3.0, 18), (4, 19, 3.0, 19),
(4, 20, 4.0, 20), (4, 21, 4.0, 21),
(4, 22, 2.0, 22), (4, 23, 2.0, 23),
(4, 24, 10.0, 24),
-- Spring题目
(4, 25, 2.0, 25), (4, 26, 2.0, 26), (4, 27, 3.0, 27), (4, 28, 3.0, 28),
(4, 29, 4.0, 29), (4, 30, 5.0, 30),
(4, 31, 10.0, 31);


-- ========================================
-- 9. 更新统计数据
-- ========================================
-- 更新题库题目数量
UPDATE question_bank qb SET question_count = (
    SELECT COUNT(*) FROM question q WHERE q.bank_id = qb.bank_id AND q.deleted = 0
) WHERE qb.deleted = 0;



-- ========================================
-- 10. 验证数据
-- ========================================
SELECT '题库数据统计：' AS info;
SELECT bank_id, bank_name, question_count, bank_type FROM question_bank WHERE deleted = 0;

SELECT '题目数据统计：' AS info;
SELECT
    bank_id,
    question_type,
    difficulty,
    COUNT(*) as count
FROM question
WHERE deleted = 0
GROUP BY bank_id, question_type, difficulty
ORDER BY bank_id, question_type;

SELECT '试卷数据统计：' AS info;
SELECT
    paper_id,
    paper_name,
    paper_type,
    total_score,
    pass_score,
    (SELECT COUNT(*) FROM paper_question pq WHERE pq.paper_id = paper.paper_id) AS question_count
FROM paper
WHERE deleted = 0;

SELECT '知识点数据统计：' AS info;
SELECT knowledge_id, knowledge_name, parent_id, level FROM knowledge_point ORDER BY knowledge_id;

-- 启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- ========================================
-- 数据生成完成
-- ========================================
SELECT '测试数据生成完成！' AS message;
SELECT CONCAT('题库数量：', COUNT(*)) AS info FROM question_bank WHERE deleted = 0
UNION ALL
SELECT CONCAT('题目数量：', COUNT(*)) FROM question WHERE deleted = 0
UNION ALL
SELECT CONCAT('试卷数量：', COUNT(*)) FROM paper WHERE deleted = 0
UNION ALL
SELECT CONCAT('知识点数量：', COUNT(*)) FROM knowledge_point;

