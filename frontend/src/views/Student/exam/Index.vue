<template>
  <div class="my-exam-list-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #ecf5ff; color: #409eff;">
              <el-icon :size="24"><Tickets /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ totalExams }}</div>
              <div class="stat-label">总考试数</div>
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
              <div class="stat-value">{{ completedExams }}</div>
              <div class="stat-label">已完成</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #fef0f0; color: #f56c6c;">
              <el-icon :size="24"><Clock /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ upcomingExams }}</div>
              <div class="stat-label">待参加</div>
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
              <div class="stat-value">{{ averageScore }}</div>
              <div class="stat-label">平均分</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="main-card">
      <template #header>
        <div class="card-header">
          <h3>我的考试</h3>
          <el-button :icon="Refresh" @click="getList">刷新</el-button>
        </div>
      </template>

      <!-- 标签页 -->
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <!-- 考试列表 -->
        <el-tab-pane label="考试列表" name="exams">
          <!-- 筛选标签 -->
          <el-radio-group v-model="filterStatus" @change="handleFilterChange" class="filter-tabs">
            <el-radio-button value="all">全部</el-radio-button>
            <el-radio-button value="upcoming">即将开始</el-radio-button>
            <el-radio-button value="in-progress">进行中</el-radio-button>
            <el-radio-button value="ended">已结束</el-radio-button>
          </el-radio-group>

          <!-- 考试列表 -->
          <div v-loading="loading" class="exam-list">
        <el-empty v-if="!examList.length" description="暂无考试" />

        <div v-for="exam in examList" :key="exam.examId" class="exam-item">
          <el-card shadow="hover" :class="getExamStatusClass(exam)">
            <div class="exam-content">
              <!-- 左侧信息 -->
              <div class="exam-info">
                <div class="exam-title">
                  {{ exam.examName }}
                  <el-tag :type="getStatusTagType(exam)" size="small" style="margin-left: 10px">
                    {{ getStatusText(exam) }}
                  </el-tag>
                </div>
                <div class="exam-meta">
                  <el-icon><Calendar /></el-icon>
                  <span>开始时间：{{ formatDateTime(exam.startTime) }}</span>
                </div>
                <div class="exam-meta">
                  <el-icon><Clock /></el-icon>
                  <span>结束时间：{{ formatDateTime(exam.endTime) }}</span>
                </div>
                <div class="exam-meta">
                  <el-icon><Timer /></el-icon>
                  <span>考试时长：{{ exam.duration }} 分钟</span>
                </div>
                <div class="exam-description" v-if="exam.description">
                  {{ exam.description }}
                </div>
              </div>

              <!-- 右侧操作 -->
              <div class="exam-actions">
                <!-- 即将开始 -->
                <template v-if="isUpcoming(exam)">
                  <el-statistic :value="getCountdown(exam)" format="HH:mm:ss" title="距离开始">
                    <template #suffix>
                      <span style="font-size: 14px; color: #909399">后开始</span>
                    </template>
                  </el-statistic>
                  <el-button type="info" disabled style="margin-top: 20px">未到考试时间</el-button>
                </template>

                <!-- 进行中 -->
                <template v-else-if="isInProgress(exam)">
                  <div class="countdown-box">
                    <div class="countdown-label">剩余时间</div>
                    <div class="countdown-value" :class="{'countdown-warning': isTimeWarning(exam)}">
                      {{ getRemainingTime(exam) }}
                    </div>
                  </div>
                  <el-button
                    type="primary"
                    size="large"
                    @click="handleStartExam(exam)"
                    style="margin-top: 20px"
                  >
                    {{ hasStarted(exam) ? '继续答题' : '开始考试' }}
                  </el-button>
                </template>

                <!-- 已结束 -->
                <template v-else-if="isEnded(exam)">
                  <div class="result-info">
                    <div class="result-label">考试已结束</div>
                    <div class="result-score" v-if="exam.score !== null && exam.score !== undefined">
                      <span class="score-label">得分：</span>
                      <span class="score-value">{{ exam.score }}</span>
                    </div>
                  </div>
                  <el-button
                    type="success"
                    @click="handleViewResult(exam)"
                    style="margin-top: 20px"
                  >
                    查看结果
                  </el-button>
                </template>
              </div>
            </div>
          </el-card>
        </div>
      </div>

          <!-- 分页 -->
          <el-pagination
            v-if="total > 0"
            v-model:current-page="queryForm.current"
            v-model:page-size="queryForm.size"
            :page-sizes="[10, 20, 50]"
            :total="total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            style="margin-top: 20px; justify-content: flex-end"
          />
        </el-tab-pane>

        <!-- 成绩记录 -->
        <el-tab-pane label="成绩记录" name="scores">
          <div v-loading="scoresLoading" class="scores-content">
            <el-empty v-if="scoreList.length === 0" description="暂无成绩记录" />

            <el-table v-else :data="scoreList" border style="width: 100%">
              <el-table-column type="index" label="#" width="60" />
              <el-table-column prop="examName" label="考试名称" min-width="200" show-overflow-tooltip />
              <el-table-column prop="paperName" label="试卷名称" min-width="180" show-overflow-tooltip />
              <el-table-column label="得分" width="100" align="center">
                <template #default="{ row }">
                  <span :class="row.score >= row.passScore ? 'text-success' : 'text-danger'">
                    {{ row.score }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="totalScore" label="总分" width="100" align="center" />
              <el-table-column prop="passScore" label="及格分" width="100" align="center" />
              <el-table-column label="状态" width="100" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.score >= row.passScore ? 'success' : 'danger'" size="small">
                    {{ row.score >= row.passScore ? '通过' : '未通过' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="正确率" width="120" align="center">
                <template #default="{ row }">
                  <el-progress
                    :percentage="Math.round((row.score / row.totalScore) * 100)"
                    :color="getProgressColor(row.score, row.totalScore)"
                    :stroke-width="8"
                  />
                </template>
              </el-table-column>
              <el-table-column prop="submitTime" label="提交时间" width="180" />
              <el-table-column label="操作" fixed="right" width="150" align="center">
                <template #default="{ row }">
                  <el-button type="primary" link size="small" @click="viewScoreDetail(row)">
                    查看详情
                  </el-button>
                </template>
              </el-table-column>
            </el-table>

            <!-- 成绩分页 -->
            <el-pagination
              v-if="scoreTotal > 0"
              v-model:current-page="scoreQuery.current"
              v-model:page-size="scoreQuery.size"
              :page-sizes="[10, 20, 50]"
              :total="scoreTotal"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleScoreSizeChange"
              @current-change="handleScoreCurrentChange"
              style="margin-top: 20px; justify-content: flex-end"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Calendar, Clock, Timer, Refresh, Tickets, CircleCheck, TrendCharts
} from '@element-plus/icons-vue'
import api from '@/api'
import { useAuthStore } from '@/stores/modules/auth'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const scoresLoading = ref(false)
const examList = ref([])
const scoreList = ref([])
const total = ref(0)
const scoreTotal = ref(0)
const filterStatus = ref('all')
const activeTab = ref('exams')

const queryForm = reactive({
  current: 1,
  size: 10
})

const scoreQuery = reactive({
  current: 1,
  size: 10
})

// 统计数据
const totalExams = computed(() => examList.value.length)
const completedExams = computed(() => examList.value.filter(e => isEnded(e)).length)
const upcomingExams = computed(() => examList.value.filter(e => isUpcoming(e) || isInProgress(e)).length)
const averageScore = computed(() => {
  if (scoreList.value.length === 0) return 0
  const sum = scoreList.value.reduce((acc, cur) => acc + cur.score, 0)
  return Math.round(sum / scoreList.value.length)
})

let refreshTimer = null

// 获取考试列表
const getList = async () => {
  loading.value = true
  try {
    const userId = authStore.userId
    const orgId = authStore.userInfo?.orgId

    const res = await api.exam.getUserExams(userId, orgId)
    if (res.code === 200) {
      examList.value = res.data || []
      total.value = examList.value.length

      // 根据筛选状态过滤
      filterExams()
    }
  } catch (error) {
    ElMessage.error('获取考试列表失败')
  } finally {
    loading.value = false
  }
}

// 过滤考试
const filterExams = () => {
  let filtered = examList.value
  const now = new Date()

  switch (filterStatus.value) {
    case 'upcoming':
      filtered = examList.value.filter(exam => new Date(exam.startTime) > now)
      break
    case 'in-progress':
      filtered = examList.value.filter(exam => isInProgress(exam))
      break
    case 'ended':
      filtered = examList.value.filter(exam => new Date(exam.endTime) < now)
      break
  }

  examList.value = filtered
  total.value = filtered.length
}

// 筛选改变
const handleFilterChange = () => {
  queryForm.current = 1
  getList()
}

// 判断是否即将开始
const isUpcoming = (exam) => {
  const now = new Date()
  return new Date(exam.startTime) > now
}

// 判断是否进行中
const isInProgress = (exam) => {
  const now = new Date()
  return new Date(exam.startTime) <= now && new Date(exam.endTime) > now
}

// 判断是否已结束
const isEnded = (exam) => {
  return new Date(exam.endTime) < new Date()
}

// 判断是否已开始答题
const hasStarted = (exam) => {
  // TODO: 根据实际情况判断是否已开始答题
  return false
}

// 获取倒计时（毫秒）
const getCountdown = (exam) => {
  const now = new Date()
  const startTime = new Date(exam.startTime)
  return startTime - now
}

// 获取剩余时间（格式化）
const getRemainingTime = (exam) => {
  const now = new Date()
  const endTime = new Date(exam.endTime)
  const diff = endTime - now

  if (diff <= 0) return '00:00:00'

  const hours = Math.floor(diff / 3600000)
  const minutes = Math.floor((diff % 3600000) / 60000)
  const seconds = Math.floor((diff % 60000) / 1000)

  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
}

// 判断时间是否告警（少于30分钟）
const isTimeWarning = (exam) => {
  const now = new Date()
  const endTime = new Date(exam.endTime)
  const diff = endTime - now
  return diff <= 1800000 // 30分钟
}

// 开始考试
const handleStartExam = (exam) => {
  router.push({ name: 'ExamStart', params: { examId: exam.examId } })
}

// 查看结果
const handleViewResult = (exam) => {
  // TODO: 获取sessionId后跳转
  router.push({ name: 'ExamResult', params: { sessionId: 'temp-session-id' } })
}

// 获取状态标签类型
const getStatusTagType = (exam) => {
  if (isUpcoming(exam)) return 'info'
  if (isInProgress(exam)) return 'warning'
  if (isEnded(exam)) return 'success'
  return ''
}

// 获取状态文本
const getStatusText = (exam) => {
  if (isUpcoming(exam)) return '即将开始'
  if (isInProgress(exam)) return '进行中'
  if (isEnded(exam)) return '已结束'
  return ''
}

// 标签页切换
const handleTabChange = (tabName) => {
  if (tabName === 'scores') {
    loadScores()
  }
}

// 加载成绩列表
const loadScores = async () => {
  scoresLoading.value = true
  try {
    // TODO: 调用API获取成绩列表
    // const res = await api.examSession.getMyScores(scoreQuery)
    // scoreList.value = res.data.records
    // scoreTotal.value = res.data.total

    ElMessage.info('成绩功能开发中，将显示模拟数据')

    // 模拟数据
    scoreList.value = []
    scoreTotal.value = 0
  } catch (error) {
    ElMessage.error('加载成绩失败')
  } finally {
    scoresLoading.value = false
  }
}

// 查看成绩详情
const viewScoreDetail = (row) => {
  // TODO: 跳转到成绩详情页面
  ElMessage.info('查看详情功能开发中')
}

// 获取进度条颜色
const getProgressColor = (score, totalScore) => {
  const percentage = (score / totalScore) * 100
  if (percentage >= 90) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

// 成绩分页
const handleScoreSizeChange = (size) => {
  scoreQuery.size = size
  scoreQuery.current = 1
  loadScores()
}

const handleScoreCurrentChange = (page) => {
  scoreQuery.current = page
  loadScores()
}

// 获取考试状态class
const getExamStatusClass = (exam) => {
  if (isUpcoming(exam)) return 'exam-upcoming'
  if (isInProgress(exam)) return 'exam-in-progress'
  if (isEnded(exam)) return 'exam-ended'
  return ''
}

// 格式化时间
const formatDateTime = (datetime) => {
  if (!datetime) return '-'
  return datetime.replace('T', ' ')
}

// 分页
const handleSizeChange = (size) => {
  queryForm.size = size
  getList()
}

const handleCurrentChange = (current) => {
  queryForm.current = current
  getList()
}

// 自动刷新
const startAutoRefresh = () => {
  refreshTimer = setInterval(() => {
    getList()
  }, 60000) // 每分钟刷新一次
}

const stopAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
}

onMounted(() => {
  getList()
  startAutoRefresh()
})

onUnmounted(() => {
  stopAutoRefresh()
})
</script>

<style scoped>
.my-exam-list-container {
  padding: 20px;
}

/* 统计卡片样式 */
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

.card-header h3 {
  margin: 0;
}

.filter-tabs {
  margin-bottom: 20px;
}

.exam-list {
  min-height: 400px;
}

.exam-item {
  margin-bottom: 20px;
}

.exam-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exam-info {
  flex: 1;
}

.exam-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
}

.exam-meta {
  display: flex;
  align-items: center;
  color: #606266;
  margin-bottom: 8px;
  font-size: 14px;
}

.exam-meta .el-icon {
  margin-right: 8px;
  color: #909399;
}

.exam-description {
  margin-top: 10px;
  color: #909399;
  font-size: 14px;
  line-height: 1.6;
}

.exam-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-left: 40px;
  min-width: 200px;
}

.countdown-box {
  text-align: center;
}

.countdown-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.countdown-value {
  font-size: 32px;
  font-weight: bold;
  color: #409eff;
  font-family: 'Courier New', monospace;
}

.countdown-value.countdown-warning {
  color: #f56c6c;
  animation: blink 1s infinite;
}

@keyframes blink {
  0%, 50%, 100% { opacity: 1; }
  25%, 75% { opacity: 0.5; }
}

.result-info {
  text-align: center;
}

.result-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.result-score {
  margin-top: 10px;
}

.score-label {
  font-size: 14px;
  color: #606266;
}

.score-value {
  font-size: 28px;
  font-weight: bold;
  color: #67c23a;
  margin-left: 5px;
}

.exam-upcoming {
  border-left: 4px solid #909399;
}

.exam-in-progress {
  border-left: 4px solid #e6a23c;
}

.exam-ended {
  border-left: 4px solid #67c23a;
}

/* 成绩标签页样式 */
.scores-content {
  min-height: 400px;
}

.text-success {
  color: #67c23a;
  font-weight: bold;
  font-size: 16px;
}

.text-danger {
  color: #f56c6c;
  font-weight: bold;
  font-size: 16px;
}
</style>

