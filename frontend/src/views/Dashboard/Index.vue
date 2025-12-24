<template>
  <div class="dashboard-container">
    <!-- 欢迎横幅 -->
    <el-card class="welcome-card">
      <div class="welcome-content">
        <div class="welcome-text">
          <h2>欢迎回来，{{ userInfo.realName || userInfo.username }}！</h2>
          <p>{{ currentGreeting }}</p>
        </div>
        <div class="welcome-icon">
          <el-icon :size="80" color="#409EFF"><User /></el-icon>
        </div>
      </div>
    </el-card>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409EFF20">
              <el-icon :size="30" color="#409EFF"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.questionBankCount }}</div>
              <div class="stat-label">题库总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67C23A20">
              <el-icon :size="30" color="#67C23A"><EditPen /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.questionCount }}</div>
              <div class="stat-label">题目总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: #E6A23C20">
              <el-icon :size="30" color="#E6A23C"><Reading /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.examCount }}</div>
              <div class="stat-label">考试总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: #F56C6C20">
              <el-icon :size="30" color="#F56C6C"><UserFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.userCount }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 快捷入口 -->
    <el-row :gutter="20" class="quick-actions-row">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>快捷入口</span>
            </div>
          </template>
          <div class="quick-actions">
            <div class="action-item" @click="goTo('/admin/question-bank')">
              <el-icon :size="40" color="#409EFF"><Files /></el-icon>
              <span>题库管理</span>
            </div>
            <div class="action-item" @click="goTo('/admin/question')">
              <el-icon :size="40" color="#67C23A"><Edit /></el-icon>
              <span>题目管理</span>
            </div>
            <div class="action-item" @click="goTo('/paper')">
              <el-icon :size="40" color="#E6A23C"><Document /></el-icon>
              <span>试卷管理</span>
            </div>
            <div class="action-item" @click="goTo('/exam')">
              <el-icon :size="40" color="#F56C6C"><Notebook /></el-icon>
              <span>考试管理</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近活动 -->
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>最近活动</span>
            </div>
          </template>
          <el-timeline>
            <el-timeline-item
              v-for="activity in recentActivities"
              :key="activity.id"
              :timestamp="activity.time"
              placement="top"
            >
              <el-card>
                <h4>{{ activity.title }}</h4>
                <p>{{ activity.description }}</p>
              </el-card>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="recentActivities.length === 0" description="暂无活动记录" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/modules/auth'
import {
  User,
  Document,
  EditPen,
  Reading,
  UserFilled,
  Files,
  Edit,
  Notebook
} from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

// 用户信息
const userInfo = computed(() => authStore.userInfo || {})

// 当前问候语
const currentGreeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了，注意休息！'
  if (hour < 9) return '早上好！'
  if (hour < 12) return '上午好！'
  if (hour < 14) return '中午好！'
  if (hour < 18) return '下午好！'
  if (hour < 22) return '晚上好！'
  return '夜深了，注意休息！'
})

// 统计数据
const stats = reactive({
  questionBankCount: 0,
  questionCount: 0,
  examCount: 0,
  userCount: 0
})

// 最近活动
const recentActivities = ref([])

// 加载统计数据
const loadStats = async () => {
  try {
    // TODO: 调用统计API
    // const res = await statisticsApi.getDashboardStats()
    // Object.assign(stats, res.data)

    // 模拟数据
    stats.questionBankCount = 15
    stats.questionCount = 350
    stats.examCount = 28
    stats.userCount = 156
  } catch (error) {
    console.error('加载统计数据失败', error)
  }
}

// 加载最近活动
const loadRecentActivities = async () => {
  try {
    // TODO: 调用活动API
    // const res = await activityApi.getRecent()
    // recentActivities.value = res.data

    // 模拟数据
    recentActivities.value = [
      {
        id: 1,
        title: '创建了新题库',
        description: '创建了"Java基础"题库',
        time: '2025-11-06 10:30'
      },
      {
        id: 2,
        title: '发布了考试',
        description: '发布了"期中考试"',
        time: '2025-11-05 15:20'
      }
    ]
  } catch (error) {
    console.error('加载活动失败', error)
  }
}

// 跳转
const goTo = (path) => {
  router.push(path)
}

// 初始化
onMounted(() => {
  loadStats()
  loadRecentActivities()
})
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.welcome-card {
  margin-bottom: 20px;
}

.welcome-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.welcome-text h2 {
  margin: 0 0 10px 0;
  font-size: 24px;
  color: #303133;
}

.welcome-text p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  margin-bottom: 10px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.quick-actions-row {
  margin-bottom: 20px;
}

.card-header {
  font-weight: 500;
  font-size: 16px;
}

.quick-actions {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.action-item {
  flex: 1;
  min-width: 120px;
  padding: 20px;
  border: 1px solid #EBEEF5;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.3s;
}

.action-item:hover {
  border-color: #409EFF;
  box-shadow: 0 2px 12px 0 rgba(64, 158, 255, 0.2);
  transform: translateY(-2px);
}

.action-item span {
  font-size: 14px;
  color: #606266;
}
</style>

