<template>
  <div class="paper-detail-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button @click="goBack">
        <el-icon>
          <ArrowLeft/>
        </el-icon>
        返回
      </el-button>
      <div class="header-title">
        <h2>{{ paper.paperName }}</h2>
        <el-tag :type="getPaperTypeColor(paper.paperType)">
          {{ getPaperTypeName(paper.paperType) }}
        </el-tag>
      </div>
      <div class="header-actions">
        <el-button type="success" @click="handlePreview">预览</el-button>
        <el-button type="primary" @click="handleEdit">编辑</el-button>
        <el-button type="danger" @click="handleDelete">删除</el-button>
      </div>
    </div>

    <!-- 试卷信息 -->
    <el-row :gutter="20" v-loading="loading">
      <!-- 基本信息 -->
      <el-col :span="16">
        <el-card class="info-card">
          <template #header>
            <div class="card-header">
              <span>基本信息</span>
            </div>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="试卷ID">
              {{ paper.paperId }}
            </el-descriptions-item>
            <el-descriptions-item label="试卷类型">
              <el-tag :type="getPaperTypeColor(paper.paperType)">
                {{ getPaperTypeName(paper.paperType) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="总分">
              <span style="font-size: 18px; font-weight: bold; color: #409eff">
                {{ paper.totalScore }} 分
              </span>
            </el-descriptions-item>
            <el-descriptions-item label="题目数量">
              {{ paper.questionCount || 0 }} 道
            </el-descriptions-item>
            <el-descriptions-item label="及格分数">
              {{ paper.passScore }} 分
            </el-descriptions-item>
            <el-descriptions-item label="状态">
              <el-tag :type="getPaperStatusColor(paper.auditStatus)">
                {{ getPaperStatusName(paper.auditStatus) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间" :span="2">
              {{ paper.createTime }}
            </el-descriptions-item>
            <el-descriptions-item label="试卷说明" :span="2">
              {{ paper.description || '暂无说明' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 题目列表 -->
        <el-card class="questions-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>题目列表</span>
              <el-button type="primary" size="small" @click="showQuestionSelector">
                <el-icon>
                  <Plus/>
                </el-icon>
                添加题目
              </el-button>
            </div>
          </template>

          <!-- 按题型分组显示 -->
          <el-collapse v-model="activeCollapse">
            <el-collapse-item
                v-for="(questions, type) in questionsByType"
                :key="type"
                :name="type"
            >
              <template #title>
                <div class="collapse-title">
                  <el-tag :type="getQuestionTypeColor(type)" size="large">
                    {{ getQuestionTypeName(type) }}
                  </el-tag>
                  <span style="margin-left: 10px; color: #909399">
                    共 {{ questions.length }} 道题，{{ calculateTypeScore(questions) }} 分
                  </span>
                </div>
              </template>

              <div class="question-list">
                <div
                    v-for="(question, index) in questions"
                    :key="question.questionId"
                    class="question-item"
                >
                  <div class="question-number">{{ index + 1 }}</div>
                  <div class="question-content">
                    <div class="content-text">{{ question.questionContent }}</div>
                    <div class="content-info">
                      <el-tag size="small">难度: {{ getDifficultyName(question.difficulty) }}</el-tag>
                      <el-tag size="small" type="warning" style="margin-left: 8px">
                        {{ question.defaultScore }} 分
                      </el-tag>
                    </div>
                  </div>
                  <div class="question-actions">
                    <el-button link type="primary" @click="viewQuestion(question.questionId)">
                      查看
                    </el-button>
                    <el-button link type="danger" @click="handleRemoveQuestion(question.questionId)">
                      移除
                    </el-button>
                  </div>
                </div>
              </div>
            </el-collapse-item>
          </el-collapse>

          <el-empty v-if="!paper.questions || paper.questions.length === 0" description="暂无题目"/>
        </el-card>
      </el-col>

      <!-- 统计信息 -->
      <el-col :span="8">
        <!-- 题型统计 -->
        <el-card class="stats-card">
          <template #header>
            <div class="card-header">
              <span>题型分布</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">单选题</div>
            <div class="stat-value">{{ statistics.singleChoiceCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">多选题</div>
            <div class="stat-value">{{ statistics.multipleChoiceCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">判断题</div>
            <div class="stat-value">{{ statistics.trueFalseCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">填空题</div>
            <div class="stat-value">{{ statistics.fillBlankCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">简答题</div>
            <div class="stat-value">{{ statistics.shortAnswerCount || 0 }} 道</div>
          </div>
        </el-card>

        <!-- 难度分布 -->
        <el-card class="stats-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>难度分布</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">简单</div>
            <div class="stat-value success">{{ statistics.easyCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">中等</div>
            <div class="stat-value warning">{{ statistics.mediumCount || 0 }} 道</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">困难</div>
            <div class="stat-value danger">{{ statistics.hardCount || 0 }} 道</div>
          </div>
        </el-card>

        <!-- 分数分布 -->
        <el-card class="stats-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>分数设置</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">总分</div>
            <div class="stat-value primary">{{ paper.totalScore || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">及格分</div>
            <div class="stat-value">{{ paper.passScore || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">及格率要求</div>
            <div class="stat-value">{{ passRatePercent }}%</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 题目选择器 -->
    <QuestionSelector
        v-model="questionSelectorVisible"
        :existing-questions="paper.questions || []"
        @confirm="handleQuestionsSelected"
    />
  </div>
</template>

<script setup>
import {computed, nextTick, onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {ElMessage, ElMessageBox} from 'element-plus'
import {ArrowLeft, Plus} from '@element-plus/icons-vue'
import paperApi from '@/api/paper'
import QuestionSelector from '@/components/QuestionSelector.vue'
import {
  getDifficultyName,
  getPaperStatusColor,
  getPaperStatusName,
  getPaperTypeColor,
  getPaperTypeName,
  getQuestionTypeColor,
  getQuestionTypeName,
  QUESTION_TYPE
} from '@/utils/enums'

const route = useRoute()
const router = useRouter()

// 状态
const loading = ref(false)
const paper = ref({})
const statistics = ref({})
const activeCollapse = ref([QUESTION_TYPE.SINGLE_CHOICE, QUESTION_TYPE.MULTIPLE_CHOICE])

// 题目选择器状态
const questionSelectorVisible = ref(false)

// 按题型分组的题目
const questionsByType = computed(() => {
  if (!paper.value.questions) return {}

  return paper.value.questions.reduce((acc, question) => {
    const type = question.questionType
    if (!acc[type]) {
      acc[type] = []
    }
    acc[type].push(question)
    return acc
  }, {})
})

// 及格率百分比
const passRatePercent = computed(() => {
  if (!paper.value.totalScore || !paper.value.passScore) return 0
  return Math.round((paper.value.passScore / paper.value.totalScore) * 100)
})

// 加载试卷详情
const loadPaperDetail = async () => {
  loading.value = true
  try {
    const paperId = route.params.id
    if (!paperId) {
      ElMessage.error('试卷ID不存在')
      router.back()
      return
    }

    const res = await paperApi.getById(paperId)
    if (res.code === 200 && res.data) {
      paper.value = res.data
      await nextTick()
      calculateStatistics()
    } else {
      ElMessage.error(res.msg || '加载失败')
      router.back()
    }
  } catch (error) {
    console.error('加载试卷详情失败:', error)
    ElMessage.error('加载失败')
    router.back()
  } finally {
    loading.value = false
  }
}

// 计算统计数据
const calculateStatistics = () => {
  if (!paper.value.questions) {
    statistics.value = {}
    return
  }

  const questions = paper.value.questions
  statistics.value = {
    singleChoiceCount: questions.filter(q => q.questionType === QUESTION_TYPE.SINGLE_CHOICE).length,
    multipleChoiceCount: questions.filter(q => q.questionType === QUESTION_TYPE.MULTIPLE_CHOICE).length,
    trueFalseCount: questions.filter(q => q.questionType === QUESTION_TYPE.TRUE_FALSE).length,
    fillBlankCount: questions.filter(q => q.questionType === QUESTION_TYPE.FILL_BLANK).length,
    shortAnswerCount: questions.filter(q => q.questionType === QUESTION_TYPE.SUBJECTIVE).length,
    easyCount: questions.filter(q => q.difficulty === 1).length,
    mediumCount: questions.filter(q => q.difficulty === 2).length,
    hardCount: questions.filter(q => q.difficulty === 3).length
  }
}

// 计算某题型的总分
const calculateTypeScore = (questions) => {
  return questions.reduce((sum, q) => sum + (q.defaultScore || 0), 0)
}

// 返回
const goBack = () => {
  router.back()
}

// 预览
const handlePreview = () => {
  router.push({name: 'PaperPreview', params: {id: paper.value.paperId}})
}

// 编辑
const handleEdit = () => {
  // 跳转到试卷列表页，并传递编辑参数
  router.push({name: 'Paper', query: {edit: paper.value.paperId}})
}

// 删除
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
        `确定要删除试卷"${paper.value.paperName}"吗？`,
        '警告',
        {type: 'warning'}
    )

    const res = await paperApi.deleteById(paper.value.paperId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      router.back()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 显示题目选择器
const showQuestionSelector = () => {
  questionSelectorVisible.value = true
}

// 处理题目选择确认
const handleQuestionsSelected = async (selectedQuestions) => {
  try {
    // 过滤出新添加的题目（排除已存在的）
    const existingIds = paper.value.questions ? paper.value.questions.map(q => q.questionId) : []
    const newQuestions = selectedQuestions.filter(
        q => !existingIds.includes(q.questionId)
    )

    if (newQuestions.length === 0) {
      ElMessage.info('没有新增题目')
      return
    }

    // 提取新题目的ID
    const newQuestionIds = newQuestions.map(q => q.questionId)

    // 调用API添加题目
    const res = await paperApi.addQuestions(paper.value.paperId, newQuestionIds)

    if (res.code === 200) {
      ElMessage.success(`成功添加 ${newQuestions.length} 道题目`)
      // 重新加载试卷详情
      await loadPaperDetail()
    } else {
      ElMessage.error(res.message || '添加题目失败')
    }
  } catch (error) {
    console.error('添加题目失败:', error)
    ElMessage.error('添加题目失败')
  }
}

// 移除题目
const handleRemoveQuestion = async (questionId) => {
  try {
    await ElMessageBox.confirm(
        '确定要从试卷中移除该题目吗？',
        '提示',
        {
          type: 'warning',
          confirmButtonText: '确定',
          cancelButtonText: '取消'
        }
    )

    // 调用API移除题目
    const res = await paperApi.removeQuestions(paper.value.paperId, [questionId])

    if (res.code === 200) {
      ElMessage.success('移除成功')
      // 重新加载试卷详情（后端已自动更新总分和及格分）
      await loadPaperDetail()
    } else {
      ElMessage.error(res.message || '移除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('移除题目失败:', error)
      ElMessage.error('移除失败')
    }
  }
}

// 查看题目
const viewQuestion = (questionId) => {
  router.push({name: 'QuestionDetail', params: {id: questionId}})
}

// 自动更新试卷总分和及格分
const updatePaperScores = async () => {
  try {
    if (!paper.value.questions || paper.value.questions.length === 0) {
      // 没有题目时，总分和及格分都设为0
      const updateData = {
        totalScore: 0,
        passScore: 0
      }
      await paperApi.update(paper.value.paperId, updateData)
      paper.value.totalScore = 0
      paper.value.passScore = 0
      return
    }

    // 计算总分（所有题目分数之和）
    const totalScore = paper.value.questions.reduce((sum, q) => sum + (q.defaultScore || 0), 0)

    // 计算及格分（总分的60%，四舍五入）
    const passScore = Math.round(totalScore * 0.6)

    // 更新到后端
    const updateData = {
      totalScore: totalScore,
      passScore: passScore
    }

    const res = await paperApi.update(paper.value.paperId, updateData)

    if (res.code === 200) {
      // 更新本地数据
      paper.value.totalScore = totalScore
      paper.value.passScore = passScore
      console.log(`试卷分数已更新：总分=${totalScore}，及格分=${passScore}`)
    }
  } catch (error) {
    console.error('更新试卷分数失败:', error)
  }
}


// 初始化
onMounted(() => {
  loadPaperDetail()
})
</script>

<style scoped>
.paper-detail-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-title {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 15px;
  margin-left: 20px;
}

.header-title h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.collapse-title {
  display: flex;
  align-items: center;
}

.question-list {
  padding: 10px 0;
}

.question-item {
  display: flex;
  align-items: flex-start;
  padding: 15px;
  margin-bottom: 10px;
  background: #f5f7fa;
  border-radius: 4px;
  transition: all 0.3s;
}

.question-item:hover {
  background: #e8f4ff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.1);
}

.question-number {
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #409eff;
  color: white;
  border-radius: 50%;
  font-weight: bold;
  flex-shrink: 0;
}

.question-content {
  flex: 1;
  margin: 0 15px;
}

.content-text {
  line-height: 1.6;
  color: #303133;
  margin-bottom: 8px;
}

.content-info {
  display: flex;
  gap: 8px;
}

.question-actions {
  flex-shrink: 0;
}

.stats-card .stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.stat-item:not(:last-child) {
  border-bottom: 1px solid #f0f0f0;
}

.stat-label {
  font-size: 14px;
  color: #606266;
}

.stat-value {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.stat-value.primary {
  color: #409eff;
  font-size: 28px;
}

.stat-value.success {
  color: #67c23a;
}

.stat-value.warning {
  color: #e6a23c;
}

.stat-value.danger {
  color: #f56c6c;
}
</style>

