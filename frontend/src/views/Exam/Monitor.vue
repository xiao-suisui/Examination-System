﻿<template>
  <div class="exam-monitor-container">
    <!-- 页面头部 -->
    <el-page-header @back="goBack" title="返回">
      <template #content>
        <span class="page-title">考试监控</span>
      </template>
      <template #extra>
        <el-space>
          <el-tag type="info" size="large">
            <el-icon><Clock /></el-icon>
            自动刷新：{{ autoRefresh ? `${refreshInterval}秒` : '已关闭' }}
          </el-tag>
          <el-switch
            v-model="autoRefresh"
            active-text="自动刷新"
            @change="handleAutoRefreshChange"
          />
          <el-button type="primary" @click="loadMonitorData">
            <el-icon><Refresh /></el-icon>
            手动刷新
          </el-button>
        </el-space>
      </template>
    </el-page-header>

    <!-- 统计卡片 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>实时统计</span>
          <span class="update-time">
            最后更新：{{ lastUpdateTime }}
          </span>
        </div>
      </template>

      <el-row :gutter="20">
        <el-col :span="6">
          <div class="stat-card stat-total">
            <div class="stat-icon">
              <el-icon size="40"><User /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ monitorData.totalCount || 0 }}</div>
              <div class="stat-label">应考人数</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-online">
            <div class="stat-icon">
              <el-icon size="40"><VideoCameraFilled /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ monitorData.onlineCount || 0 }}</div>
              <div class="stat-label">在线人数</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-submitted">
            <div class="stat-icon">
              <el-icon size="40"><Check /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ monitorData.submittedCount || 0 }}</div>
              <div class="stat-label">已交卷</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-notstarted">
            <div class="stat-icon">
              <el-icon size="40"><Timer /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ monitorData.notStartedCount || 0 }}</div>
              <div class="stat-label">未开始</div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 进度条 -->
      <div class="progress-wrapper">
        <div class="progress-label">考试进度</div>
        <el-progress
          :percentage="completionRate"
          :color="progressColors"
          :stroke-width="20"
        >
          <span class="progress-text">{{ completionRate }}%</span>
        </el-progress>
      </div>
    </el-card>

    <!-- 学生监控列表 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>学生监控</span>
          <el-space>
            <el-input
              v-model="searchKeyword"
              placeholder="搜索学生姓名或学号"
              clearable
              style="width: 200px"
              @input="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-select
              v-model="filterStatus"
              placeholder="筛选状态"
              clearable
              style="width: 150px"
              @change="handleSearch"
            >
              <el-option label="全部" value="" />
              <el-option label="未开始" :value="0" />
              <el-option label="考试中" :value="1" />
              <el-option label="已交卷" :value="2" />
              <el-option label="已批改" :value="3" />
            </el-select>
          </el-space>
        </div>
      </template>

      <el-table
        :data="filteredStudents"
        :loading="loading"
        stripe
        style="width: 100%"
        :default-sort="{ prop: 'status', order: 'descending' }"
      >
        <el-table-column type="expand">
          <template #default="{ row }">
            <div class="expand-content">
              <el-descriptions :column="3" border>
                <el-descriptions-item label="学生姓名">
                  {{ row.studentName }}
                </el-descriptions-item>
                <el-descriptions-item label="学号">
                  {{ row.studentNo }}
                </el-descriptions-item>
                <el-descriptions-item label="班级">
                  {{ row.className || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="IP地址">
                  {{ row.ipAddress || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="答题进度">
                  已答 {{ row.answeredCount || 0 }} / 共 {{ row.totalCount || 0 }} 题
                </el-descriptions-item>
                <el-descriptions-item label="剩余时间">
                  {{ formatRemainingTime(row.remainingTime) }}
                </el-descriptions-item>
                <el-descriptions-item label="开始时间" :span="3">
                  {{ row.startTime || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="交卷时间" :span="3">
                  {{ row.submitTime || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="异常记录" :span="3">
                  <el-tag v-if="row.switchCount > 0" type="warning">
                    切屏 {{ row.switchCount }} 次
                  </el-tag>
                  <el-tag v-if="row.exitFullscreenCount > 0" type="warning">
                    退出全屏 {{ row.exitFullscreenCount }} 次
                  </el-tag>
                  <el-tag v-if="!row.switchCount && !row.exitFullscreenCount" type="success">
                    无异常
                  </el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="studentName" label="学生姓名" width="120" fixed />
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="在线状态" width="100" align="center">
          <template #default="{ row }">
            <el-badge
              :value="row.isOnline ? '在线' : '离线'"
              :type="row.isOnline ? 'success' : 'info'"
            />
          </template>
        </el-table-column>
        <el-table-column label="答题进度" width="180">
          <template #default="{ row }">
            <el-progress
              :percentage="row.progress || 0"
              :color="getProgressColor(row.progress)"
              :show-text="false"
            />
            <span style="margin-left: 10px">{{ row.progress || 0 }}%</span>
          </template>
        </el-table-column>
        <el-table-column prop="score" label="分数" width="100" align="center">
          <template #default="{ row }">
            {{ row.score !== null && row.score !== undefined ? row.score : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="160" show-overflow-tooltip />
        <el-table-column prop="submitTime" label="交卷时间" width="160" show-overflow-tooltip />
        <el-table-column label="剩余时间" width="120">
          <template #default="{ row }">
            <span :class="{ 'time-warning': row.remainingTime < 10 }">
              {{ formatRemainingTime(row.remainingTime) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 1"
              link
              type="warning"
              @click="handleForceSubmit(row)"
            >
              强制交卷
            </el-button>
            <el-button
              v-if="row.status >= 2"
              link
              type="primary"
              @click="handleViewAnswer(row)"
            >
              查看答卷
            </el-button>
            <el-button
              link
              type="info"
              @click="handleViewDetail(row)"
            >
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Refresh, Clock, User, VideoCameraFilled, Check, Timer, Search
} from '@element-plus/icons-vue'
import examApi from '@/api/exam'

const router = useRouter()
const route = useRoute()

// ==================== 状态 ====================
const loading = ref(false)
const autoRefresh = ref(true)
const refreshInterval = ref(10) // 10秒刷新一次
const lastUpdateTime = ref('')
const searchKeyword = ref('')
const filterStatus = ref('')
let refreshTimer = null

const monitorData = ref({
  totalCount: 0,
  onlineCount: 0,
  submittedCount: 0,
  notStartedCount: 0,
  students: []
})

// ==================== 计算属性 ====================
// 完成率
const completionRate = computed(() => {
  const total = monitorData.value.totalCount
  const submitted = monitorData.value.submittedCount
  if (total === 0) return 0
  return Math.round((submitted / total) * 100)
})

// 进度条颜色
const progressColors = [
  { color: '#f56c6c', percentage: 30 },
  { color: '#e6a23c', percentage: 60 },
  { color: '#67c23a', percentage: 100 }
]

// 过滤后的学生列表
const filteredStudents = computed(() => {
  let students = monitorData.value.students || []

  // 关键词搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    students = students.filter(s =>
      s.studentName?.toLowerCase().includes(keyword) ||
      s.studentNo?.toLowerCase().includes(keyword)
    )
  }

  // 状态筛选
  if (filterStatus.value !== '') {
    students = students.filter(s => s.status === filterStatus.value)
  }

  return students
})

// ==================== 返回 ====================
const goBack = () => {
  router.back()
}

// ==================== 加载监控数据 ====================
const loadMonitorData = async () => {
  try {
    loading.value = true
    const examId = route.query.examId

    // 检查 examId 是否存在
    if (!examId || examId === 'undefined') {
      console.error('examId 未定义，route.query:', route.query)
      ElMessage.error('考试ID获取失败，请重新进入')
      return
    }

    const res = await examApi.getMonitor(examId)
    if (res.code === 200 && res.data) {
      monitorData.value = res.data
      lastUpdateTime.value = new Date().toLocaleTimeString()
    }
  } catch (error) {
    console.error('加载监控数据失败:', error)
  } finally {
    loading.value = false
  }
}

// ==================== 自动刷新 ====================
const handleAutoRefreshChange = (value) => {
  if (value) {
    startAutoRefresh()
  } else {
    stopAutoRefresh()
  }
}

const startAutoRefresh = () => {
  stopAutoRefresh()
  refreshTimer = setInterval(() => {
    loadMonitorData()
  }, refreshInterval.value * 1000)
}

const stopAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
}

// ==================== 搜索 ====================
const handleSearch = () => {
  // 搜索逻辑在计算属性中处理
}

// ==================== 获取状态类型 ====================
const getStatusType = (status) => {
  const statusMap = {
    0: 'info',     // 未开始
    1: 'warning',  // 考试中
    2: 'success',  // 已交卷
    3: 'primary'   // 已批改
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    0: '未开始',
    1: '考试中',
    2: '已交卷',
    3: '已批改'
  }
  return statusMap[status] || '未知'
}

// ==================== 获取进度颜色 ====================
const getProgressColor = (progress) => {
  if (progress < 30) return '#f56c6c'
  if (progress < 60) return '#e6a23c'
  if (progress < 100) return '#409eff'
  return '#67c23a'
}

// ==================== 格式化剩余时间 ====================
const formatRemainingTime = (minutes) => {
  if (!minutes || minutes <= 0) return '-'
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  if (hours > 0) {
    return `${hours}小时${mins}分钟`
  }
  return `${mins}分钟`
}

// ==================== 强制交卷 ====================
const handleForceSubmit = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要强制 ${row.studentName} 交卷吗？`,
      '警告',
      {
        type: 'warning',
        confirmButtonText: '确定',
        cancelButtonText: '取消'
      }
    )

    // TODO: 调用强制交卷API
    ElMessage.success('强制交卷成功')
    loadMonitorData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// ==================== 查看答卷 ====================
const handleViewAnswer = (row) => {
  router.push(`/admin/exam/answer/${row.sessionId}`)
}

// ==================== 查看详情 ====================
const handleViewDetail = (row) => {
  ElMessageBox.alert(
    `
    <div style="line-height: 1.8;">
      <p><strong>学生信息：</strong></p>
      <p>姓名：${row.studentName}</p>
      <p>学号：${row.studentNo}</p>
      <p>班级：${row.className || '-'}</p>
      <p><strong>考试信息：</strong></p>
      <p>状态：${getStatusText(row.status)}</p>
      <p>答题进度：${row.progress || 0}%</p>
      <p>分数：${row.score || '-'}</p>
      <p>开始时间：${row.startTime || '-'}</p>
      <p>交卷时间：${row.submitTime || '-'}</p>
      <p><strong>异常记录：</strong></p>
      <p>切屏次数：${row.switchCount || 0}</p>
      <p>退出全屏：${row.exitFullscreenCount || 0}</p>
    </div>
    `,
    '学生详情',
    {
      dangerouslyUseHTMLString: true
    }
  )
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadMonitorData()
  if (autoRefresh.value) {
    startAutoRefresh()
  }
})

onUnmounted(() => {
  stopAutoRefresh()
})
</script>

<style scoped>
.exam-monitor-container {
  padding: 20px;
}

.page-title {
  font-size: 18px;
  font-weight: bold;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: bold;
}

.update-time {
  font-size: 14px;
  color: #909399;
  font-weight: normal;
}

/* 统计卡片 */
.stat-card {
  display: flex;
  align-items: center;
  padding: 24px;
  border-radius: 12px;
  transition: all 0.3s;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.stat-card.stat-total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stat-card.stat-online {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.stat-card.stat-submitted {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.stat-card.stat-notstarted {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.stat-icon {
  margin-right: 20px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
}

/* 进度条 */
.progress-wrapper {
  margin-top: 24px;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
}

.progress-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 12px;
}

.progress-text {
  font-size: 14px;
  font-weight: bold;
}

/* 扩展内容 */
.expand-content {
  padding: 16px;
  background: #f5f7fa;
}

/* 时间警告 */
.time-warning {
  color: #f56c6c;
  font-weight: bold;
  animation: blink 1s linear infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
</style>

