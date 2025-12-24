<template>
  <div class="home-container">
    <!-- 统计卡片区域 -->
    <el-row :gutter="20">
      <el-col :span="6">
        <StatCard
          icon="Document"
          icon-color="#409eff"
          label="题库总数"
          :value="statistics.questionBankCount"
        />
      </el-col>

      <el-col :span="6">
        <StatCard
          icon="EditPen"
          icon-color="#67c23a"
          label="题目总数"
          :value="statistics.questionCount"
        />
      </el-col>

      <el-col :span="6">
        <StatCard
          icon="Files"
          icon-color="#e6a23c"
          label="考试总数"
          :value="statistics.examCount"
        />
      </el-col>

      <el-col :span="6">
        <StatCard
          icon="User"
          icon-color="#f56c6c"
          label="用户总数"
          :value="statistics.userCount"
        />
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
            <el-button type="primary" @click="goTo('/question-bank')">
              <el-icon><Collection /></el-icon>
              题库管理
            </el-button>
            <el-button type="success" @click="goTo('/question')">
              <el-icon><EditPen /></el-icon>
              题目管理
            </el-button>
            <el-button type="warning" @click="goTo('/paper')">
              <el-icon><Document /></el-icon>
              试卷管理
            </el-button>
            <el-button type="danger" @click="goTo('/exam')">
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
import { Collection, EditPen, Document, Files } from '@element-plus/icons-vue'
import { StatCard } from '@/components/common'
import { EXAM_STATUS_LABELS, EXAM_STATUS_COLORS } from '@/utils/enums'
import api from '@/api'

const router = useRouter()

const statistics = ref({
  questionBankCount: 0,
  questionCount: 0,
  examCount: 0,
  userCount: 0
})

const recentExams = ref([])
const loading = ref(false)

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
})
</script>

<style scoped>
.home-container {
  padding: 20px;
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

.quick-links :deep(.el-button) {
  width: 100%;
  justify-content: flex-start;
}
</style>

