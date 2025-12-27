<template>
  <div class="exam-result">
    <el-card v-loading="loading" class="result-card">
      <!-- 头部信息 -->
      <template #header>
        <div class="result-header">
          <el-icon :size="24" color="#409eff"><DocumentChecked /></el-icon>
          <span>考试结果</span>
        </div>
      </template>

      <!-- 考试信息 -->
      <div v-if="!loading && resultData" class="result-content">
        <!-- 成绩展示 -->
        <div class="score-section">
          <div class="score-card">
            <div class="score-label">总分</div>
            <div class="score-value">
              <span v-if="resultData.totalScore !== null" class="score-number">
                {{ resultData.totalScore }}
              </span>
              <span v-else class="score-pending">待批改</span>
            </div>
            <div v-if="resultData.totalScore !== null" class="score-status">
              <el-tag :type="resultData.isPassed ? 'success' : 'danger'" size="large">
                {{ resultData.isPassed ? '及格' : '不及格' }}
              </el-tag>
            </div>
          </div>

          <el-divider direction="vertical" style="height: 120px" />

          <div class="score-detail">
            <div class="detail-item">
              <span class="detail-label">客观题得分：</span>
              <span class="detail-value">{{ resultData.objectiveScore || 0 }} 分</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">主观题得分：</span>
              <span class="detail-value">
                {{ resultData.subjectiveScore !== null ? resultData.subjectiveScore + ' 分' : '待批改' }}
              </span>
            </div>
            <div class="detail-item">
              <span class="detail-label">考试用时：</span>
              <span class="detail-value">{{ resultData.duration }} 分钟</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">提交时间：</span>
              <span class="detail-value">{{ formatDateTime(resultData.submitTime) }}</span>
            </div>
          </div>
        </div>

        <!-- 考试信息 -->
        <el-descriptions title="考试信息" :column="2" border style="margin-top: 30px">
          <el-descriptions-item label="考试名称">
            {{ resultData.examName }}
          </el-descriptions-item>
          <el-descriptions-item label="考试状态">
            <el-tag :type="getStatusTagType(resultData.sessionStatus)">
              {{ getStatusName(resultData.sessionStatus) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="试卷名称">
            {{ resultData.paperName }}
          </el-descriptions-item>
          <el-descriptions-item label="满分">
            {{ resultData.totalPossibleScore }} 分
          </el-descriptions-item>
          <el-descriptions-item label="答题数量">
            {{ resultData.answeredCount }} / {{ resultData.totalQuestions }}
          </el-descriptions-item>
          <el-descriptions-item label="正确率">
            {{ resultData.correctRate }}%
          </el-descriptions-item>
        </el-descriptions>

        <!-- 答题统计 -->
        <div class="statistics-section">
          <h3>答题统计</h3>
          <el-row :gutter="20">
            <el-col :span="6">
              <el-statistic title="总题数" :value="resultData.totalQuestions" />
            </el-col>
            <el-col :span="6">
              <el-statistic title="正确题数" :value="resultData.correctCount">
                <template #suffix>
                  <span style="color: #67c23a"> / {{ resultData.totalQuestions }}</span>
                </template>
              </el-statistic>
            </el-col>
            <el-col :span="6">
              <el-statistic title="错误题数" :value="resultData.wrongCount">
                <template #suffix>
                  <span style="color: #f56c6c"> / {{ resultData.totalQuestions }}</span>
                </template>
              </el-statistic>
            </el-col>
            <el-col :span="6">
              <el-statistic title="正确率" :value="resultData.correctRate" suffix="%" />
            </el-col>
          </el-row>
        </div>

        <!-- 违规记录 -->
        <div v-if="resultData.violations && resultData.violations.length > 0" class="violation-section">
          <h3>违规记录</h3>
          <el-alert
            type="warning"
            :closable="false"
            show-icon
            style="margin-bottom: 15px"
          >
            <template #title>
              检测到 {{ resultData.violations.length }} 次违规行为
            </template>
          </el-alert>
          <el-table :data="resultData.violations" border>
            <el-table-column prop="violationType" label="违规类型" width="150">
              <template #default="{ row }">
                {{ getViolationTypeName(row.violationType) }}
              </template>
            </el-table-column>
            <el-table-column prop="violationTime" label="违规时间" width="180">
              <template #default="{ row }">
                {{ formatDateTime(row.violationTime) }}
              </template>
            </el-table-column>
            <el-table-column prop="severity" label="严重程度" width="120">
              <template #default="{ row }">
                <el-tag :type="getSeverityTagType(row.severity)">
                  {{ getSeverityName(row.severity) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="violationDetail" label="详情" show-overflow-tooltip />
          </el-table>
        </div>

        <!-- 操作按钮 -->
        <div class="action-section">
          <el-button type="primary" @click="handleViewDetails">
            <el-icon><View /></el-icon>
            查看答题详情
          </el-button>
          <el-button @click="handleBackToList">
            <el-icon><Back /></el-icon>
            返回考试列表
          </el-button>
        </div>
      </div>

      <!-- 空状态 -->
      <el-empty v-else-if="!loading" description="未找到考试结果" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { DocumentChecked, View, Back } from '@element-plus/icons-vue'
import studentExamApi from '@/api/studentExam'

const route = useRoute()
const router = useRouter()

// 数据
const loading = ref(false)
const sessionId = ref(route.params.sessionId)
const resultData = ref(null)

// 方法

// 加载考试结果
const loadResult = async () => {
  loading.value = true
  try {
    const res = await studentExamApi.getSession(sessionId.value)
    if (res.code === 200) {
      resultData.value = processResultData(res.data)
    } else {
      ElMessage.error(res.message || '加载考试结果失败')
    }
  } catch (error) {
    console.error('加载考试结果失败:', error)
    ElMessage.error('加载考试结果失败')
  } finally {
    loading.value = false
  }
}

// 处理结果数据
const processResultData = (data) => {
  const session = data.session || {}
  const exam = data.examInfo || {}
  const answers = data.answers || []

  // 计算统计数据
  const totalQuestions = answers.length
  const answeredCount = answers.filter(a => a.userAnswer).length
  const correctCount = answers.filter(a => a.isCorrect === 1).length
  const wrongCount = answers.filter(a => a.isCorrect === 0).length
  const correctRate = totalQuestions > 0 ? ((correctCount / totalQuestions) * 100).toFixed(1) : 0

  // 判断是否及格（假设60分及格）
  const isPassed = session.totalScore !== null && session.totalScore >= 60

  return {
    sessionId: session.sessionId,
    examName: exam.examName,
    paperName: exam.paperName || '未知试卷',
    totalScore: session.totalScore,
    objectiveScore: session.objectiveScore,
    subjectiveScore: session.subjectiveScore,
    duration: session.duration,
    submitTime: session.submitTime,
    sessionStatus: session.sessionStatus,
    totalPossibleScore: exam.totalScore || 100,
    totalQuestions,
    answeredCount,
    correctCount,
    wrongCount,
    correctRate,
    isPassed,
    violations: data.violations || []
  }
}

// 查看答题详情
const handleViewDetails = () => {
  ElMessage.info('答题详情功能开发中...')
  // TODO: 跳转到答题详情页面
}

// 返回考试列表
const handleBackToList = () => {
  router.push({ name: 'StudentExam' })
}

// 获取状态名称
const getStatusName = (status) => {
  const statusMap = {
    'IN_PROGRESS': '进行中',
    'SUBMITTED': '已提交',
    'GRADED': '已批改',
    'TIMEOUT_SUBMITTED': '超时提交',
    'TERMINATED': '已终止'
  }
  return statusMap[status] || status
}

// 获取状态标签类型
const getStatusTagType = (status) => {
  const typeMap = {
    'IN_PROGRESS': 'warning',
    'SUBMITTED': 'info',
    'GRADED': 'success',
    'TIMEOUT_SUBMITTED': 'warning',
    'TERMINATED': 'danger'
  }
  return typeMap[status] || 'info'
}

// 获取违规类型名称
const getViolationTypeName = (type) => {
  const typeMap = {
    'TAB_SWITCH': '切屏',
    'COPY': '复制',
    'PASTE': '粘贴',
    'RIGHT_CLICK': '右键',
    'EXIT_FULLSCREEN': '退出全屏',
    'IDLE_TIMEOUT': '长时间无操作'
  }
  return typeMap[type] || type
}

// 获取严重程度名称
const getSeverityName = (severity) => {
  const nameMap = {
    1: '轻微',
    2: '一般',
    3: '严重',
    4: '非常严重',
    5: '致命'
  }
  return nameMap[severity] || '未知'
}

// 获取严重程度标签类型
const getSeverityTagType = (severity) => {
  if (severity <= 2) return 'info'
  if (severity === 3) return 'warning'
  return 'danger'
}

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  return new Date(dateTime).toLocaleString('zh-CN')
}

// 生命周期
onMounted(() => {
  loadResult()
})
</script>

<style scoped>
.exam-result {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding: 20px;
}

.result-card {
  max-width: 1200px;
  margin: 0 auto;
}

.result-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: bold;
}

.result-content {
  padding: 20px 0;
}

/* 成绩展示 */
.score-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 40px;
  padding: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  color: white;
}

.score-card {
  text-align: center;
}

.score-label {
  font-size: 16px;
  margin-bottom: 10px;
  opacity: 0.9;
}

.score-value {
  font-size: 64px;
  font-weight: bold;
  margin-bottom: 10px;
}

.score-number {
  color: #fff;
}

.score-pending {
  font-size: 32px;
  color: #ffd700;
}

.score-status {
  margin-top: 10px;
}

.score-detail {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.detail-item {
  display: flex;
  align-items: center;
  font-size: 16px;
}

.detail-label {
  min-width: 120px;
  opacity: 0.9;
}

.detail-value {
  font-weight: bold;
}

/* 统计部分 */
.statistics-section {
  margin-top: 30px;
  padding: 20px;
  background-color: #f9fafb;
  border-radius: 8px;
}

.statistics-section h3 {
  margin-bottom: 20px;
  color: #303133;
}

/* 违规记录 */
.violation-section {
  margin-top: 30px;
}

.violation-section h3 {
  margin-bottom: 15px;
  color: #303133;
}

/* 操作按钮 */
.action-section {
  margin-top: 30px;
  display: flex;
  justify-content: center;
  gap: 20px;
}

/* 响应式 */
@media (max-width: 768px) {
  .score-section {
    flex-direction: column;
    gap: 20px;
  }

  .score-value {
    font-size: 48px;
  }
}
</style>

