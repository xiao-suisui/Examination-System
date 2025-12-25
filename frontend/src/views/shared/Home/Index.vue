<template>
  <div class="home-container">
    <!-- 欢迎信息 -->
    <div class="welcome-banner">
      <div class="welcome-content">
        <h2>欢迎使用在线考试系统</h2>
        <p>{{ getCurrentGreeting() }}，{{ username }}</p>
      </div>
      <div class="welcome-time">
        <el-icon><Clock /></el-icon>
        <span>{{ currentTime }}</span>
      </div>
    </div>

    <!-- 统计卡片区域 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :xs="12" :sm="12" :md="6" :lg="6">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon">
            <el-icon><Collection /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ statistics.questionBankCount }}</div>
            <div class="stat-label">题库总数</div>
          </div>
        </div>
      </el-col>

      <el-col :xs="12" :sm="12" :md="6" :lg="6">
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <el-icon><EditPen /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ statistics.questionCount }}</div>
            <div class="stat-label">题目总数</div>
          </div>
        </div>
      </el-col>

      <el-col :xs="12" :sm="12" :md="6" :lg="6">
        <div class="stat-card stat-card-warning">
          <div class="stat-icon">
            <el-icon><Files /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ statistics.examCount }}</div>
            <div class="stat-label">考试总数</div>
          </div>
        </div>
      </el-col>

      <el-col :xs="12" :sm="12" :md="6" :lg="6">
        <div class="stat-card stat-card-danger">
          <div class="stat-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ statistics.userCount }}</div>
            <div class="stat-label">用户总数</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 主要内容区域 -->
    <el-row :gutter="20" class="content-area">
      <!-- 最近考试 -->
      <el-col :xs="24" :sm="24" :md="16" :lg="16">
        <el-card class="content-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <div class="header-title">
                <el-icon><Calendar /></el-icon>
                <span>最近考试</span>
              </div>
              <el-link type="primary" @click="goTo('/admin/exam')">查看全部</el-link>
            </div>
          </template>
          <el-empty v-if="recentExams.length === 0" description="暂无考试" :image-size="100" />
          <el-table v-else :data="recentExams" stripe style="width: 100%">
            <el-table-column prop="examName" label="考试名称" min-width="200" show-overflow-tooltip />
            <el-table-column prop="startTime" label="开始时间" width="180" />
            <el-table-column prop="endTime" label="结束时间" width="180" />
            <el-table-column label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)" size="small">
                  {{ getStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 快捷入口 -->
      <el-col :xs="24" :sm="24" :md="8" :lg="8">
        <el-card class="content-card quick-links-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <div class="header-title">
                <el-icon><Compass /></el-icon>
                <span>快捷入口</span>
              </div>
            </div>
          </template>
          <div class="quick-links">
            <div class="quick-link-item" @click="goTo('/admin/question-bank')">
              <div class="link-icon link-icon-primary">
                <el-icon><Collection /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">题库管理</div>
                <div class="link-desc">管理题库和分类</div>
              </div>
            </div>

            <div class="quick-link-item" @click="goTo('/admin/question')">
              <div class="link-icon link-icon-success">
                <el-icon><EditPen /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">题目管理</div>
                <div class="link-desc">添加和编辑题目</div>
              </div>
            </div>

            <div class="quick-link-item" @click="goTo('/admin/paper')">
              <div class="link-icon link-icon-warning">
                <el-icon><Document /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">试卷管理</div>
                <div class="link-desc">创建和组织试卷</div>
              </div>
            </div>

            <div class="quick-link-item" @click="goTo('/admin/exam')">
              <div class="link-icon link-icon-danger">
                <el-icon><Files /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">考试管理</div>
                <div class="link-desc">安排和监控考试</div>
              </div>
            </div>

            <div class="quick-link-item" @click="goTo('/admin/user')">
              <div class="link-icon link-icon-info">
                <el-icon><User /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">用户管理</div>
                <div class="link-desc">管理系统用户</div>
              </div>
            </div>

            <div class="quick-link-item" @click="goTo('/admin/organization')">
              <div class="link-icon link-icon-primary">
                <el-icon><OfficeBuilding /></el-icon>
              </div>
              <div class="link-content">
                <div class="link-title">组织管理</div>
                <div class="link-desc">管理组织架构</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/modules/auth'
import {
  Collection,
  EditPen,
  Document,
  Files,
  User,
  Clock,
  Calendar,
  Compass,
  OfficeBuilding
} from '@element-plus/icons-vue'
import { EXAM_STATUS_LABELS, EXAM_STATUS_COLORS } from '@/utils/enums'
import api from '@/api'

const router = useRouter()
const authStore = useAuthStore()

const username = computed(() => authStore.user?.realName || authStore.username || '用户')
const currentTime = ref('')
let timeInterval = null

const statistics = ref({
  questionBankCount: 0,
  questionCount: 0,
  examCount: 0,
  userCount: 0
})

const recentExams = ref([])
const loading = ref(false)

/**
 * 更新当前时间
 */
const updateTime = () => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const hours = String(now.getHours()).padStart(2, '0')
  const minutes = String(now.getMinutes()).padStart(2, '0')
  const seconds = String(now.getSeconds()).padStart(2, '0')
  currentTime.value = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

/**
 * 获取问候语
 */
const getCurrentGreeting = () => {
  const hour = new Date().getHours()
  if (hour < 6) return '凌晨好'
  if (hour < 9) return '早上好'
  if (hour < 12) return '上午好'
  if (hour < 14) return '中午好'
  if (hour < 17) return '下午好'
  if (hour < 19) return '傍晚好'
  if (hour < 22) return '晚上好'
  return '深夜好'
}

const goTo = (path) => {
  router.push(path)
}

const getStatusText = (status) => {
  return EXAM_STATUS_LABELS[status] || '未知'
}

const getStatusType = (status) => {
  return EXAM_STATUS_COLORS[status] || 'info'
}

/**
 * 加载系统统计数据
 */
const loadStatistics = async () => {
  try {
    loading.value = true

    // 获取各模块的数量统计
    const [bankRes, questionRes, examRes, userRes] = await Promise.all([
      api.questionBank.page({ current: 1, size: 1 }),
      api.question.page({ current: 1, size: 1 }),
      api.exam.page({ current: 1, size: 1 }),
      api.user.page({ current: 1, size: 1 })
    ])

    statistics.value = {
      questionBankCount: bankRes.data?.total || 0,
      questionCount: questionRes.data?.total || 0,
      examCount: examRes.data?.total || 0,
      userCount: userRes.data?.total || 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    // 使用默认值，不显示错误提示
    statistics.value = {
      questionBankCount: 0,
      questionCount: 0,
      examCount: 0,
      userCount: 0
    }
  } finally {
    loading.value = false
  }
}

/**
 * 加载最近的考试
 */
const loadRecentExams = async () => {
  try {
     const res = await api.exam.page({
      current: 1,
      size: 5,
      sortField: 'startTime',
      sortOrder: 'desc'
    })

    if (res.code === 200 && res.data?.records) {
      recentExams.value = res.data.records
    }
  } catch (error) {
    console.error('加载最近考试失败:', error)
    recentExams.value = []
  }
}

onMounted(() => {
  loadStatistics()
  loadRecentExams()

  // 更新时间
  updateTime()
  timeInterval = setInterval(updateTime, 1000)
})

onUnmounted(() => {
  if (timeInterval) {
    clearInterval(timeInterval)
  }
})
</script>

<style scoped>
.home-container {
  min-height: 100%;
  background: #f0f2f5;
}

/* 欢迎横幅 */
.welcome-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 30px 40px;
  margin-bottom: 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #fff;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.welcome-content h2 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
}

.welcome-content p {
  margin: 0;
  font-size: 16px;
  opacity: 0.9;
}

.welcome-time {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 500;
}

.welcome-time .el-icon {
  font-size: 24px;
}

/* 统计卡片 */
.stat-cards {
  margin-bottom: 24px;
}

.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  height: 120px;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 64px;
  height: 64px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: #fff;
  flex-shrink: 0;
}

.stat-card-primary .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card-success .stat-icon {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.stat-card-warning .stat-icon {
  background: linear-gradient(135deg, #fbc2eb 0%, #a6c1ee 100%);
}

.stat-card-danger .stat-icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  font-weight: 500;
}

/* 内容区域 */
.content-area {
  margin-bottom: 24px;
}

.content-card {
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
}

.content-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.header-title .el-icon {
  font-size: 20px;
  color: #409eff;
}

/* 快捷链接 */
.quick-links-card {
  height: 100%;
}

.quick-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.quick-link-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: 8px;
  background: #f5f7fa;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quick-link-item:hover {
  background: #e6f7ff;
  transform: translateX(4px);
}

.link-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #fff;
  flex-shrink: 0;
}

.link-icon-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.link-icon-success {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.link-icon-warning {
  background: linear-gradient(135deg, #fbc2eb 0%, #a6c1ee 100%);
}

.link-icon-danger {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.link-icon-info {
  background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);
}

.link-content {
  flex: 1;
}

.link-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.link-desc {
  font-size: 13px;
  color: #909399;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .welcome-banner {
    flex-direction: column;
    align-items: flex-start;
    padding: 20px;
  }

  .welcome-time {
    margin-top: 12px;
  }

  .stat-card {
    padding: 16px;
    height: auto;
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .stat-value {
    font-size: 24px;
  }
}

/* 表格优化 */
:deep(.el-table) {
  font-size: 14px;
}

:deep(.el-table th) {
  background: #f5f7fa;
  color: #606266;
  font-weight: 600;
}

:deep(.el-table td) {
  padding: 12px 0;
}
</style>

