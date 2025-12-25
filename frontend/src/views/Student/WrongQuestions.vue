<template>
  <div class="wrong-questions-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #ecf5ff; color: #409eff;">
              <el-icon :size="24"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ totalCount }}</div>
              <div class="stat-label">错题总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #fef0f0; color: #f56c6c;">
              <el-icon :size="24"><Warning /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ highErrorCount }}</div>
              <div class="stat-label">高频错题</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #f0f9ff; color: #67c23a;">
              <el-icon :size="24"><CircleCheck /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ masteredCount }}</div>
              <div class="stat-label">已掌握</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #fdf6ec; color: #e6a23c;">
              <el-icon :size="24"><TrendCharts /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ practiceCount }}</div>
              <div class="stat-label">练习次数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 主内容卡片 -->
    <el-card class="main-card">
      <template #header>
        <div class="card-header">
          <span class="header-title">我的错题集</span>
          <div class="header-actions">
            <el-button type="primary" :icon="Reading" @click="startPractice">开始练习</el-button>
            <el-button :icon="Refresh" @click="loadWrongQuestions">刷新</el-button>
          </div>
        </div>
      </template>

      <!-- 筛选栏 -->
      <div class="filter-bar">
        <el-form :inline="true">
          <el-form-item label="题型">
            <el-select v-model="filterForm.questionType" placeholder="全部题型" clearable style="width: 150px">
              <el-option label="单选题" value="SINGLE_CHOICE" />
              <el-option label="多选题" value="MULTIPLE_CHOICE" />
              <el-option label="判断题" value="TRUE_FALSE" />
              <el-option label="填空题" value="FILL_BLANK" />
              <el-option label="简答题" value="SHORT_ANSWER" />
            </el-select>
          </el-form-item>
          <el-form-item label="难度">
            <el-select v-model="filterForm.difficulty" placeholder="全部难度" clearable style="width: 120px">
              <el-option label="简单" value="EASY" />
              <el-option label="中等" value="MEDIUM" />
              <el-option label="困难" value="HARD" />
            </el-select>
          </el-form-item>
          <el-form-item label="错误次数">
            <el-select v-model="filterForm.errorLevel" placeholder="全部" clearable style="width: 120px">
              <el-option label="3次以上" value="high" />
              <el-option label="2次" value="medium" />
              <el-option label="1次" value="low" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :icon="Search" @click="handleFilter">查询</el-button>
            <el-button :icon="RefreshLeft" @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 错题列表 -->
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="全部错题" name="all">
          <el-empty v-if="filteredQuestions.length === 0" description="暂无错题，继续努力！" />
          <div v-else class="question-list">
            <el-card
              v-for="(question, index) in filteredQuestions"
              :key="question.questionId"
              class="question-item"
              shadow="hover"
            >
              <div class="question-header">
                <div class="question-number">题目 {{ index + 1 }}</div>
                <div class="question-tags">
                  <el-tag size="small">{{ getQuestionTypeLabel(question.questionType) }}</el-tag>
                  <el-tag size="small" :type="getDifficultyType(question.difficulty)">
                    {{ getDifficultyLabel(question.difficulty) }}
                  </el-tag>
                  <el-tag size="small" type="danger" effect="dark">
                    错误 {{ question.errorCount }} 次
                  </el-tag>
                </div>
              </div>
              <div class="question-content" v-html="question.questionContent"></div>
              <div class="question-footer">
                <div class="question-meta">
                  <span class="meta-item">
                    <el-icon><Calendar /></el-icon>
                    最后错误: {{ question.lastErrorTime }}
                  </span>
                </div>
                <div class="question-actions">
                  <el-button size="small" type="primary" link @click="viewDetail(question)">
                    查看详情
                  </el-button>
                  <el-button size="small" type="success" link @click="markAsMastered(question)">
                    标记已掌握
                  </el-button>
                </div>
              </div>
            </el-card>
          </div>
        </el-tab-pane>

        <el-tab-pane label="按题型" name="type">
          <div class="category-view">
            <el-collapse v-model="activeTypeCollapse">
              <el-collapse-item
                v-for="type in questionTypeStats"
                :key="type.code"
                :name="type.code"
              >
                <template #title>
                  <div class="collapse-title">
                    <span>{{ type.label }}</span>
                    <el-badge :value="type.count" class="badge" />
                  </div>
                </template>
                <el-empty v-if="type.count === 0" description="暂无此类型错题" />
              </el-collapse-item>
            </el-collapse>
          </div>
        </el-tab-pane>

        <el-tab-pane label="按知识点" name="knowledge">
          <div class="category-view">
            <el-empty description="知识点分类功能开发中" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Document, Warning, CircleCheck, TrendCharts,
  Reading, Refresh, Search, RefreshLeft, Calendar
} from '@element-plus/icons-vue'

const activeTab = ref('all')
const activeTypeCollapse = ref([])
const wrongQuestions = ref([])

// 筛选表单
const filterForm = ref({
  questionType: '',
  difficulty: '',
  errorLevel: ''
})

// 统计数据
const totalCount = computed(() => wrongQuestions.value.length)
const highErrorCount = computed(() => wrongQuestions.value.filter(q => q.errorCount >= 3).length)
const masteredCount = computed(() => wrongQuestions.value.filter(q => q.mastered).length)
const practiceCount = ref(0)

// 过滤后的题目
const filteredQuestions = computed(() => {
  let result = wrongQuestions.value

  if (filterForm.value.questionType) {
    result = result.filter(q => q.questionType === filterForm.value.questionType)
  }

  if (filterForm.value.difficulty) {
    result = result.filter(q => q.difficulty === filterForm.value.difficulty)
  }

  if (filterForm.value.errorLevel) {
    const levelMap = { high: 3, medium: 2, low: 1 }
    const minError = levelMap[filterForm.value.errorLevel]
    if (filterForm.value.errorLevel === 'high') {
      result = result.filter(q => q.errorCount >= minError)
    } else {
      result = result.filter(q => q.errorCount === minError)
    }
  }

  return result
})

// 题型统计
const questionTypeStats = computed(() => {
  const types = [
    { code: 'SINGLE_CHOICE', label: '单选题' },
    { code: 'MULTIPLE_CHOICE', label: '多选题' },
    { code: 'TRUE_FALSE', label: '判断题' },
    { code: 'FILL_BLANK', label: '填空题' },
    { code: 'SHORT_ANSWER', label: '简答题' }
  ]

  return types.map(type => ({
    ...type,
    count: wrongQuestions.value.filter(q => q.questionType === type.code).length
  }))
})

// 获取题型标签
const getQuestionTypeLabel = (type) => {
  const map = {
    SINGLE_CHOICE: '单选',
    MULTIPLE_CHOICE: '多选',
    TRUE_FALSE: '判断',
    FILL_BLANK: '填空',
    SHORT_ANSWER: '简答'
  }
  return map[type] || type
}

// 获取难度标签
const getDifficultyLabel = (difficulty) => {
  const map = {
    EASY: '简单',
    MEDIUM: '中等',
    HARD: '困难'
  }
  return map[difficulty] || difficulty
}

// 获取难度类型
const getDifficultyType = (difficulty) => {
  const map = {
    EASY: 'success',
    MEDIUM: 'warning',
    HARD: 'danger'
  }
  return map[difficulty] || 'info'
}

// 加载错题
const loadWrongQuestions = async () => {
  try {
    // TODO: 调用API获取错题列表
    // const res = await api.wrongQuestion.list()
    // wrongQuestions.value = res.data

    ElMessage.info('错题集功能开发中，将显示模拟数据')
  } catch (error) {
    ElMessage.error('加载错题失败')
  }
}

// 开始练习
const startPractice = () => {
  if (filteredQuestions.value.length === 0) {
    ElMessage.warning('暂无可练习的错题')
    return
  }
  // TODO: 跳转到练习页面
  ElMessage.info('错题练习功能开发中')
}

// 查看详情
const viewDetail = (question) => {
  // TODO: 查看题目详情
  ElMessage.info('查看详情功能开发中')
}

// 标记已掌握
const markAsMastered = async (question) => {
  try {
    // TODO: 调用API标记已掌握
    ElMessage.success('已标记为掌握')
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

// 筛选
const handleFilter = () => {
  // 筛选逻辑已在computed中处理
}

// 重置
const handleReset = () => {
  filterForm.value = {
    questionType: '',
    difficulty: '',
    errorLevel: ''
  }
}

// 切换标签
const handleTabChange = (tabName) => {
  // 可以在这里处理标签切换逻辑
}

onMounted(() => {
  loadWrongQuestions()
})
</script>

<style scoped>
.wrong-questions-container {
  padding: 20px;
}

/* 统计卡片 */
.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-4px);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

/* 主卡片 */
.main-card {
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  font-size: 18px;
  font-weight: 500;
}

.header-actions {
  display: flex;
  gap: 8px;
}

/* 筛选栏 */
.filter-bar {
  margin-bottom: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 4px;
}

/* 题目列表 */
.question-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.question-item {
  transition: all 0.3s;
}

.question-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.question-number {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
}

.question-tags {
  display: flex;
  gap: 8px;
}

.question-content {
  font-size: 14px;
  line-height: 1.8;
  color: #303133;
  margin-bottom: 16px;
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
}

.question-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
}

.question-meta {
  display: flex;
  gap: 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #909399;
}

.question-actions {
  display: flex;
  gap: 8px;
}

/* 分类视图 */
.category-view {
  padding: 16px;
}

.collapse-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding-right: 16px;
}

.badge {
  margin-right: 16px;
}

</style>

