# 数据完整性保证方案

## 📋 目录
1. [为什么不使用物理外键](#为什么不使用物理外键)
2. [如何保证数据完整性](#如何保证数据完整性)
3. [Service层实现示例](#service层实现示例)
4. [数据一致性校验](#数据一致性校验)
5. [如果必须使用外键](#如果必须使用外键)

---

## 🤔 为什么不使用物理外键

### 1. 性能问题

**问题描述：**
- 每次 INSERT/UPDATE/DELETE 操作都需要检查外键约束
- 高并发场景下，外键检查会成为性能瓶颈
- 外键会增加锁竞争，降低系统吞吐量

**实际影响：**
```sql
-- 没有外键：直接插入
INSERT INTO exam_answer (...) VALUES (...);  -- 耗时: ~1ms

-- 有外键：需要检查 session_id、exam_id、question_id、user_id 四个外键
INSERT INTO exam_answer (...) VALUES (...);  -- 耗时: ~5-10ms
```

在考试高峰期（500人同时答题，每人100题），每秒可能有：
- 500 人 × 100 题 / 3600 秒 ≈ **14 次/秒** 的答案保存
- 外键检查会使响应时间增加 **5-10 倍**

### 2. 扩展性问题

**问题描述：**
- 水平分库分表时，外键约束无法跨库生效
- 分布式事务复杂度增加
- 数据迁移困难

**场景示例：**
```
# 单库场景（可以用外键）
[MySQL单库] - 包含所有表

# 分库场景（外键失效）
[用户库] - sys_user, sys_role
[题库] - question, question_bank
[考试库] - exam, exam_session, exam_answer
```

### 3. 灵活性问题

**问题描述：**
- 某些业务场景需要先插入子表数据
- 数据批量导入时外键约束增加复杂度
- 测试数据准备困难

**场景示例：**
```java
// 场景：从Excel批量导入题目和选项
// 有外键：必须先插入题目，再插入选项，两次数据库交互
question.insert();          // 第1次
Long questionId = question.getId();
option.setQuestionId(questionId);
option.insert();            // 第2次

// 无外键：可以批量插入，一次性提交
questionService.batchInsert(List<Question> questions, List<Option> options);
```

---

## ✅ 如何保证数据完整性

### 方案1：Service层强校验（推荐）⭐⭐⭐⭐⭐

在业务逻辑层实现数据完整性检查，性能好、灵活性高。

#### 实现原则

1. **创建前校验**：插入数据前检查关联数据是否存在
2. **删除前校验**：删除数据前检查是否有子数据引用
3. **事务保证**：使用 `@Transactional` 确保操作的原子性
4. **异常处理**：抛出明确的业务异常，便于前端展示

#### 核心检查点

| 操作 | 检查内容 | 失败处理 |
|-----|---------|---------|
| 创建题目 | 题库是否存在 | 抛异常：题库不存在 |
| 创建试卷 | 题目是否存在、是否已审核 | 抛异常：题目不存在或未审核 |
| 创建考试 | 试卷是否存在、是否已审核 | 抛异常：试卷不存在或未审核 |
| 删除题库 | 是否有题目引用 | 抛异常：存在题目，无法删除 |
| 删除题目 | 是否已被组卷 | 抛异常：已组卷，只能禁用 |
| 删除用户 | 是否有考试记录 | 抛异常：有考试记录，只能禁用 |

---

## 💻 Service层实现示例

### 1. 创建题目时检查题库

```java
@Service
public class QuestionServiceImpl implements QuestionService {
    
    @Autowired
    private QuestionMapper questionMapper;
    
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Override
    public boolean createQuestion(QuestionDTO dto) {
        // 1. 检查题库是否存在
        QuestionBank bank = questionBankMapper.selectById(dto.getBankId());
        if (bank == null) {
            throw new BusinessException("题库不存在");
        }
        
        // 2. 检查题库是否启用
        if (bank.getStatus() == 0) {
            throw new BusinessException("题库已禁用，无法添加题目");
        }
        
        // 3. 检查组织权限（数据隔离）
        Long currentOrgId = SecurityUtils.getCurrentOrgId();
        if (!bank.getOrgId().equals(currentOrgId)) {
            throw new BusinessException("无权限在此题库添加题目");
        }
        
        // 4. 插入题目
        Question question = BeanUtil.copyProperties(dto, Question.class);
        question.setCreateUserId(SecurityUtils.getCurrentUserId());
        question.setOrgId(currentOrgId);
        question.setAuditStatus(0); // 草稿状态
        
        return questionMapper.insert(question) > 0;
    }
}
```

### 2. 删除题库时检查题目

```java
@Service
public class QuestionBankServiceImpl implements QuestionBankService {
    
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Autowired
    private QuestionMapper questionMapper;
    
    @Override
    public boolean deleteQuestionBank(Long bankId) {
        // 1. 检查题库是否存在
        QuestionBank bank = questionBankMapper.selectById(bankId);
        if (bank == null) {
            throw new BusinessException("题库不存在");
        }
        
        // 2. 检查是否有题目（关键：替代外键检查）
        QueryWrapper<Question> query = new QueryWrapper<>();
        query.eq("bank_id", bankId).eq("deleted", 0);
        long questionCount = questionMapper.selectCount(query);
        
        if (questionCount > 0) {
            throw new BusinessException(
                String.format("该题库下还有 %d 道题目，无法删除", questionCount)
            );
        }
        
        // 3. 软删除题库
        bank.setDeleted(1);
        return questionBankMapper.updateById(bank) > 0;
    }
}
```

### 3. 删除题目时检查是否已组卷

```java
@Service
public class QuestionServiceImpl implements QuestionService {
    
    @Autowired
    private QuestionMapper questionMapper;
    
    @Autowired
    private PaperQuestionMapper paperQuestionMapper;
    
    @Override
    public boolean deleteQuestion(Long questionId) {
        // 1. 检查题目是否存在
        Question question = questionMapper.selectById(questionId);
        if (question == null) {
            throw new BusinessException("题目不存在");
        }
        
        // 2. 检查是否已被组卷（关键：替代外键检查）
        QueryWrapper<PaperQuestion> query = new QueryWrapper<>();
        query.eq("question_id", questionId);
        long paperCount = paperQuestionMapper.selectCount(query);
        
        if (paperCount > 0) {
            throw new BusinessException(
                String.format("该题目已被 %d 份试卷使用，无法删除，只能禁用", paperCount)
            );
        }
        
        // 3. 软删除题目
        question.setDeleted(1);
        return questionMapper.updateById(question) > 0;
    }
    
    @Override
    public boolean disableQuestion(Long questionId) {
        // 禁用题目（不检查是否已组卷）
        Question question = new Question();
        question.setQuestionId(questionId);
        question.setStatus(0);
        return questionMapper.updateById(question) > 0;
    }
}
```

### 4. 创建考试时检查试卷

```java
@Service
public class ExamServiceImpl implements ExamService {
    
    @Autowired
    private ExamMapper examMapper;
    
    @Autowired
    private PaperMapper paperMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createExam(ExamDTO dto) {
        // 1. 检查试卷是否存在
        Paper paper = paperMapper.selectById(dto.getPaperId());
        if (paper == null) {
            throw new BusinessException("试卷不存在");
        }
        
        // 2. 检查试卷是否已审核
        if (paper.getAuditStatus() != 2) {
            throw new BusinessException("试卷未通过审核，无法创建考试");
        }
        
        // 3. 检查试卷是否已发布
        if (paper.getPublishStatus() != 1) {
            throw new BusinessException("试卷未发布，无法创建考试");
        }
        
        // 4. 检查时间合理性
        if (dto.getStartTime().after(dto.getEndTime())) {
            throw new BusinessException("开始时间不能晚于结束时间");
        }
        
        if (dto.getStartTime().before(new Date())) {
            throw new BusinessException("开始时间不能早于当前时间");
        }
        
        // 5. 创建考试
        Exam exam = BeanUtil.copyProperties(dto, Exam.class);
        exam.setOrgId(SecurityUtils.getCurrentOrgId());
        exam.setCreateUserId(SecurityUtils.getCurrentUserId());
        exam.setExamStatus(0); // 未开始
        
        boolean created = examMapper.insert(exam) > 0;
        
        // 6. 创建考生关联（事务保证）
        if (created && dto.getUserIds() != null && !dto.getUserIds().isEmpty()) {
            List<ExamUser> examUsers = dto.getUserIds().stream()
                .map(userId -> {
                    ExamUser eu = new ExamUser();
                    eu.setExamId(exam.getExamId());
                    eu.setUserId(userId);
                    eu.setExamStatus(0); // 未参考
                    return eu;
                })
                .collect(Collectors.toList());
            
            examUserMapper.insertBatch(examUsers);
        }
        
        return created;
    }
}
```

### 5. 删除试卷时级联删除关联数据

```java
@Service
public class PaperServiceImpl implements PaperService {
    
    @Autowired
    private PaperMapper paperMapper;
    
    @Autowired
    private PaperQuestionMapper paperQuestionMapper;
    
    @Autowired
    private PaperRuleMapper paperRuleMapper;
    
    @Autowired
    private ExamMapper examMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deletePaper(Long paperId) {
        // 1. 检查试卷是否存在
        Paper paper = paperMapper.selectById(paperId);
        if (paper == null) {
            throw new BusinessException("试卷不存在");
        }
        
        // 2. 检查是否已被考试使用（关键：替代外键检查）
        QueryWrapper<Exam> examQuery = new QueryWrapper<>();
        examQuery.eq("paper_id", paperId).eq("deleted", 0);
        long examCount = examMapper.selectCount(examQuery);
        
        if (examCount > 0) {
            throw new BusinessException(
                String.format("该试卷已被 %d 场考试使用，无法删除，只能禁用", examCount)
            );
        }
        
        // 3. 级联删除关联数据（模拟外键的 ON DELETE CASCADE）
        // 删除试卷题目关联
        QueryWrapper<PaperQuestion> pqQuery = new QueryWrapper<>();
        pqQuery.eq("paper_id", paperId);
        paperQuestionMapper.delete(pqQuery);
        
        // 删除组卷规则
        QueryWrapper<PaperRule> ruleQuery = new QueryWrapper<>();
        ruleQuery.eq("paper_id", paperId);
        paperRuleMapper.delete(ruleQuery);
        
        // 4. 软删除试卷
        paper.setDeleted(1);
        return paperMapper.updateById(paper) > 0;
    }
}
```

### 6. 批量操作时的事务控制

```java
@Service
public class QuestionServiceImpl implements QuestionService {
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public ImportResult batchImportQuestions(MultipartFile file, Long bankId) {
        ImportResult result = new ImportResult();
        
        try {
            // 1. 检查题库是否存在（统一校验）
            QuestionBank bank = questionBankMapper.selectById(bankId);
            if (bank == null) {
                throw new BusinessException("题库不存在");
            }
            
            // 2. 解析Excel
            List<QuestionImportDTO> importList = EasyExcel.read(file.getInputStream())
                .head(QuestionImportDTO.class)
                .sheet()
                .doReadSync();
            
            // 3. 批量插入题目和选项（事务保证原子性）
            List<Question> questions = new ArrayList<>();
            List<QuestionOption> allOptions = new ArrayList<>();
            
            for (QuestionImportDTO dto : importList) {
                // 转换为Question实体
                Question question = convertToQuestion(dto, bankId);
                questions.add(question);
                
                // 准备选项（暂时使用临时ID）
                List<QuestionOption> options = convertToOptions(dto);
                allOptions.addAll(options);
            }
            
            // 4. 批量插入题目
            questionMapper.insertBatch(questions);
            
            // 5. 更新选项的question_id并批量插入
            int index = 0;
            for (Question question : questions) {
                int optionCount = getOptionCount(importList.get(index));
                for (int i = 0; i < optionCount; i++) {
                    allOptions.get(index * optionCount + i).setQuestionId(question.getQuestionId());
                }
                index++;
            }
            optionMapper.insertBatch(allOptions);
            
            result.setSuccessCount(questions.size());
            result.setMessage("导入成功");
            
        } catch (Exception e) {
            log.error("批量导入题目失败", e);
            throw new BusinessException("导入失败：" + e.getMessage());
        }
        
        return result;
    }
}
```

---

## 🔍 数据一致性校验

### 定时任务：每日数据一致性检查

```java
@Component
public class DataIntegrityCheckTask {
    
    @Autowired
    private DataIntegrityService dataIntegrityService;
    
    /**
     * 每天凌晨2点执行数据一致性检查
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void checkDataIntegrity() {
        log.info("开始执行数据一致性检查...");
        
        try {
            DataIntegrityReport report = dataIntegrityService.checkAll();
            
            if (report.hasIssues()) {
                // 发送告警邮件给管理员
                String message = String.format(
                    "发现数据不一致问题：\n" +
                    "- 孤儿用户数：%d\n" +
                    "- 孤儿题目数：%d\n" +
                    "- 孤儿选项数：%d\n" +
                    "- 孤儿答案数：%d\n" +
                    "详情请查看日志。",
                    report.getOrphanUserCount(),
                    report.getOrphanQuestionCount(),
                    report.getOrphanOptionCount(),
                    report.getOrphanAnswerCount()
                );
                
                emailService.sendToAdmin("数据一致性检查告警", message);
                log.warn("数据一致性检查发现问题：{}", message);
            } else {
                log.info("数据一致性检查通过");
            }
            
        } catch (Exception e) {
            log.error("数据一致性检查失败", e);
            emailService.sendToAdmin("数据一致性检查失败", e.getMessage());
        }
    }
}
```

### 数据一致性检查Service

```java
@Service
public class DataIntegrityServiceImpl implements DataIntegrityService {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Override
    public DataIntegrityReport checkAll() {
        DataIntegrityReport report = new DataIntegrityReport();
        
        // 1. 检查孤儿用户（用户引用了不存在的组织或角色）
        String sql1 = "SELECT COUNT(*) FROM sys_user " +
                     "WHERE org_id NOT IN (SELECT org_id FROM sys_organization) " +
                     "OR role_id NOT IN (SELECT role_id FROM sys_role)";
        Integer orphanUsers = jdbcTemplate.queryForObject(sql1, Integer.class);
        report.setOrphanUserCount(orphanUsers);
        
        // 2. 检查孤儿题目（题目引用了不存在的题库）
        String sql2 = "SELECT COUNT(*) FROM question " +
                     "WHERE bank_id NOT IN (SELECT bank_id FROM question_bank) " +
                     "AND deleted = 0";
        Integer orphanQuestions = jdbcTemplate.queryForObject(sql2, Integer.class);
        report.setOrphanQuestionCount(orphanQuestions);
        
        // 3. 检查孤儿选项（选项引用了不存在的题目）
        String sql3 = "SELECT COUNT(*) FROM question_option " +
                     "WHERE question_id NOT IN (SELECT question_id FROM question) " +
                     "AND deleted = 0";
        Integer orphanOptions = jdbcTemplate.queryForObject(sql3, Integer.class);
        report.setOrphanOptionCount(orphanOptions);
        
        // 4. 检查孤儿试卷题目（试卷题目关联引用了不存在的试卷或题目）
        String sql4 = "SELECT COUNT(*) FROM paper_question " +
                     "WHERE paper_id NOT IN (SELECT paper_id FROM paper) " +
                     "OR question_id NOT IN (SELECT question_id FROM question)";
        Integer orphanPaperQuestions = jdbcTemplate.queryForObject(sql4, Integer.class);
        report.setOrphanPaperQuestionCount(orphanPaperQuestions);
        
        // 5. 检查孤儿考试（考试引用了不存在的试卷）
        String sql5 = "SELECT COUNT(*) FROM exam " +
                     "WHERE paper_id NOT IN (SELECT paper_id FROM paper) " +
                     "AND deleted = 0";
        Integer orphanExams = jdbcTemplate.queryForObject(sql5, Integer.class);
        report.setOrphanExamCount(orphanExams);
        
        // 6. 检查孤儿答案（答案引用了不存在的会话或题目）
        String sql6 = "SELECT COUNT(*) FROM exam_answer " +
                     "WHERE session_id NOT IN (SELECT session_id FROM exam_session) " +
                     "OR question_id NOT IN (SELECT question_id FROM question) " +
                     "AND deleted = 0";
        Integer orphanAnswers = jdbcTemplate.queryForObject(sql6, Integer.class);
        report.setOrphanAnswerCount(orphanAnswers);
        
        return report;
    }
    
    @Override
    public boolean cleanOrphanData() {
        // 谨慎操作：清理孤儿数据
        // 建议先备份，再执行清理
        // ...
        return true;
    }
}
```

### 数据一致性修复脚本

```sql
-- ============================================================
-- 数据一致性修复脚本（谨慎执行！）
-- ============================================================

-- 1. 清理孤儿选项（引用了不存在的题目）
DELETE FROM question_option 
WHERE question_id NOT IN (SELECT question_id FROM question)
AND deleted = 0;

-- 2. 清理孤儿试卷题目（引用了不存在的试卷或题目）
DELETE FROM paper_question 
WHERE paper_id NOT IN (SELECT paper_id FROM paper)
OR question_id NOT IN (SELECT question_id FROM question);

-- 3. 清理孤儿答案（引用了不存在的会话）
-- 注意：这个操作可能丢失数据，请先备份！
DELETE FROM exam_answer 
WHERE session_id NOT IN (SELECT session_id FROM exam_session)
AND deleted = 0;

-- 4. 修正用户的组织ID（如果组织被删除，迁移到默认组织）
UPDATE sys_user 
SET org_id = 1 
WHERE org_id NOT IN (SELECT org_id FROM sys_organization);

-- 5. 统计修复结果
SELECT 
  'question_option' AS table_name,
  COUNT(*) AS orphan_count
FROM question_option 
WHERE question_id NOT IN (SELECT question_id FROM question)
UNION ALL
SELECT 
  'paper_question',
  COUNT(*)
FROM paper_question 
WHERE paper_id NOT IN (SELECT paper_id FROM paper)
   OR question_id NOT IN (SELECT question_id FROM question)
UNION ALL
SELECT 
  'exam_answer',
  COUNT(*)
FROM exam_answer 
WHERE session_id NOT IN (SELECT session_id FROM exam_session);
```

---

## 🔧 如果必须使用外键

### 适用场景

如果您的项目满足以下条件，可以考虑使用外键：

1. **规模较小**：日活用户 < 1000，并发 < 50
2. **数据一致性要求极高**：金融、医疗等行业
3. **不考虑水平扩展**：单库单表即可满足业务需求
4. **团队经验不足**：无法保证Service层实现的正确性

### 启用方法

在数据库脚本中，找到"可选：外键约束"部分，取消注释即可：

```sql
-- 取消注释以下代码
ALTER TABLE `sys_user`
  ADD CONSTRAINT `fk_user_org` FOREIGN KEY (`org_id`) REFERENCES `sys_organization` (`org_id`),
  ADD CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`);

-- ... 其他外键约束
```

### 外键使用建议

如果使用外键，请遵循以下原则：

1. **谨慎使用级联删除**：仅在确定需要时使用 `ON DELETE CASCADE`
2. **设置级联更新**：对于经常变化的主键（不推荐），使用 `ON UPDATE CASCADE`
3. **监控性能**：定期检查外键检查的性能影响
4. **准备降级方案**：如果性能不足，准备好去除外键的方案

---

## 📊 总结对比

| 维度 | 物理外键 | 逻辑外键（推荐） |
|-----|---------|---------------|
| 数据完整性 | 数据库保证（强） | 应用层保证（较强） |
| 性能 | 差（检查开销大） | 好 |
| 并发能力 | 差（锁竞争多） | 好 |
| 扩展性 | 差（难以分库） | 好（易于分库） |
| 灵活性 | 低 | 高 |
| 开发成本 | 低（自动检查） | 中（需要编码） |
| 维护成本 | 低 | 中 |
| 适用规模 | 小型项目 | 中大型项目 |

## 🎯 最终建议

**对于考试系统项目，强烈推荐使用"逻辑外键 + Service层校验"方案：**

1. ✅ 性能优秀，支持高并发（500+ 人同时考试）
2. ✅ 易于扩展，未来可分库分表
3. ✅ 灵活度高，支持复杂业务场景
4. ✅ 行业主流做法（阿里、腾讯等大厂都是这样做的）

只需要：
- 在Service层做好数据校验
- 使用`@Transactional`保证事务一致性
- 定期运行数据一致性检查脚本

这样既保证了数据完整性，又不影响系统性能！🚀

