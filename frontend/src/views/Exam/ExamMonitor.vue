<template>
  <div class="exam-monitor-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>考试监控</span>
          <div>
            <el-button :icon="Refresh" @click="refreshData">刷新</el-button>
            <el-button @click="handleBack">返回</el-button>
          </div>
        </div>
      </template>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-label">总参与人数</div>
            <div class="stat-value">{{ monitorData.totalParticipants || 0 }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-label">当前在线</div>
            <div class="stat-value online">{{ monitorData.currentOnline || 0 }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-label">已提交</div>
            <div class="stat-value success">{{ monitorData.submitted || 0 }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-label">答题中</div>
            <div class="stat-value warning">{{ monitorData.answering || 0 }}</div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 异常统计 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="stat-label">切屏异常</div>
            <div class="stat-value danger">{{ monitorData.cutScreenAbnormal || 0 }}</div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="stat-label">设备异常</div>
            <div class="stat-value danger">{{ monitorData.deviceAbnormal || 0 }}</div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="stat-label">疑似作弊</div>
            <div class="stat-value danger">{{ monitorData.suspectedCheating || 0 }}</div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 考试信息 -->
      <el-descriptions title="考试信息" :column="2" border style="margin-top: 20px">
        <el-descriptions-item label="考试名称">{{ examInfo.examName }}</el-descriptions-item>
        <el-descriptions-item label="考试状态">
          <el-tag :type="getStatusColor(examInfo.examStatus)">
            {{ getStatusText(examInfo.examStatus) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ examInfo.startTime }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ examInfo.endTime }}</el-descriptions-item>
        <el-descriptions-item label="考试时长">{{ examInfo.duration }} 分钟</el-descriptions-item>
        <el-descriptions-item label="允许切屏">{{ examInfo.cutScreenLimit }} 次</el-descriptions-item>
      </el-descriptions>

      <!-- 操作按钮 -->
      <div style="margin-top: 20px; text-align: center">
        <el-button type="warning" @click="handleEndExam" v-if="examInfo.examStatus === 2">
          结束考试
        </el-button>
        <el-button type="primary" @click="handleViewStatistics">
          查看统计
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import { getExamDetail, getExamMonitor, endExam } from '@/api/exam'

const route = useRoute()
const router = useRouter()

const examInfo = ref({})
const monitorData = reactive({
  totalParticipants: 0,
  currentOnline: 0,
  submitted: 0,
  answering: 0,
  cutScreenAbnormal: 0,
  deviceAbnormal: 0,
  suspectedCheating: 0
})

let refreshTimer = null

// 获取考试信息
const getExamInfo = async () => {
  try {
    const res = await getExamDetail(route.params.id)
    if (res.code === 200) {
      examInfo.value = res.data
    }
  } catch (error) {
    ElMessage.error('获取考试信息失败')
  }
}

// 获取监控数据
const getMonitorData = async () => {
  try {
    const res = await getExamMonitor(route.params.id)
    if (res.code === 200) {
      Object.assign(monitorData, res.data)
    }
  } catch (error) {
    console.error('获取监控数据失败', error)
  }
}

// 刷新数据
const refreshData = async () => {
  await Promise.all([getExamInfo(), getMonitorData()])
}

// 自动刷新
const startAutoRefresh = () => {
  refreshTimer = setInterval(() => {
    getMonitorData()
  }, 10000) // 每10秒刷新一次
}

// 停止自动刷新
const stopAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
}

// 结束考试
const handleEndExam = async () => {
  try {
    await ElMessageBox.confirm('确认结束该考试吗？结束后将无法继续作答。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await endExam(route.params.id)
    if (res.code === 200) {
      ElMessage.success('结束成功')
      await refreshData()
    } else {
      ElMessage.error(res.message || '结束失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('结束失败')
    }
  }
}

// 查看统计
const handleViewStatistics = () => {
  router.push({ name: 'ExamDetail', params: { id: route.params.id }, query: { tab: 'statistics' } })
}

// 返回
const handleBack = () => {
  router.back()
}

// 状态颜色
const getStatusColor = (status) => {
  const colorMap = {
    0: 'info',
    1: 'success',
    2: 'warning',
    3: '',
    4: 'danger'
  }
  return colorMap[status] || ''
}

// 状态文本
const getStatusText = (status) => {
  const textMap = {
    0: '草稿',
    1: '已发布',
    2: '进行中',
    3: '已结束',
    4: '已取消'
  }
  return textMap[status] || '未知'
}

onMounted(async () => {
  await refreshData()
  startAutoRefresh()
})

onUnmounted(() => {
  stopAutoRefresh()
})
</script>

<style scoped>
.exam-monitor-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  padding: 20px 0;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
}

.stat-value.online {
  color: #67c23a;
}

.stat-value.success {
  color: #409eff;
}

.stat-value.warning {
  color: #e6a23c;
}

.stat-value.danger {
  color: #f56c6c;
}
</style>

