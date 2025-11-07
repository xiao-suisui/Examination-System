<template>
  <div class="home-container">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon" style="background: #409eff">
            <el-icon :size="32"><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">题库总数</div>
            <div class="stat-value">{{ statistics.questionBankCount }}</div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon" style="background: #67c23a">
            <el-icon :size="32"><EditPen /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">题目总数</div>
            <div class="stat-value">{{ statistics.questionCount }}</div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon" style="background: #e6a23c">
            <el-icon :size="32"><Files /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">考试总数</div>
            <div class="stat-value">{{ statistics.examCount }}</div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon" style="background: #f56c6c">
            <el-icon :size="32"><User /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">用户总数</div>
            <div class="stat-value">{{ statistics.userCount }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>最近考试</span>
            </div>
          </template>
          <el-empty v-if="recentExams.length === 0" description="暂无考试" />
          <el-table v-else :data="recentExams" stripe>
            <el-table-column prop="examName" label="考试名称" />
            <el-table-column prop="startTime" label="开始时间" width="180" />
            <el-table-column prop="endTime" label="结束时间" width="180" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">
                  {{ getStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>快捷入口</span>
            </div>
          </template>
          <div class="quick-links">
            <el-button type="primary" @click="goTo('/question-bank/list')">
              <el-icon><Collection /></el-icon>
              题库管理
            </el-button>
            <el-button type="success" @click="goTo('/question/list')">
              <el-icon><EditPen /></el-icon>
              题目管理
            </el-button>
            <el-button type="warning" @click="goTo('/paper/list')">
              <el-icon><Document /></el-icon>
              试卷管理
            </el-button>
            <el-button type="danger" @click="goTo('/exam/list')">
              <el-icon><Files /></el-icon>
              考试管理
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { EXAM_STATUS, EXAM_STATUS_LABELS, EXAM_STATUS_COLORS } from '@/utils/constants'

const router = useRouter()

const statistics = ref({
  questionBankCount: 0,
  questionCount: 0,
  examCount: 0,
  userCount: 0
})

const recentExams = ref([])

const goTo = (path) => {
  router.push(path)
}

const getStatusText = (status) => {
  return EXAM_STATUS_LABELS[status] || '未知'
}

const getStatusType = (status) => {
  return EXAM_STATUS_COLORS[status] || 'info'
}

onMounted(() => {
  // TODO: 从API获取统计数据
  statistics.value = {
    questionBankCount: 10,
    questionCount: 500,
    examCount: 20,
    userCount: 100
  }
})
</script>

<style scoped>
.home-container {
  padding: 20px;
}

.stat-card {
  position: relative;
  overflow: hidden;
}

:deep(.stat-card .el-card__body) {
  display: flex;
  align-items: center;
  padding: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  margin-right: 20px;
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.card-header {
  font-size: 16px;
  font-weight: bold;
}

.quick-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.quick-links .el-button {
  width: 100%;
  justify-content: flex-start;
}
</style>

