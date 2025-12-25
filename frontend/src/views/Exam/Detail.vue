<template>
  <div class="exam-detail-container">
    <!-- 页面头部 -->
    <el-page-header @back="goBack" title="返回">
      <template #content>
        <span class="page-title">考试详情</span>
      </template>
      <template #extra>
        <el-button-group>
          <el-button type="primary" @click="handleEdit" :disabled="exam.examStatus === 2">
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
          <el-button type="success" @click="handleMonitor">
            <el-icon><Monitor /></el-icon>
            监控
          </el-button>
          <el-button type="info" @click="handlePreviewPaper" :disabled="!exam.paperId">
            <el-icon><View /></el-icon>
            预览试卷
          </el-button>
        </el-button-group>
      </template>
    </el-page-header>

    <!-- 基本信息卡片 -->
    <el-card v-loading="loading" style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>基本信息</span>
          <el-tag :type="getExamStatusColor(exam.examStatus)" size="large">
            {{ getExamStatusName(exam.examStatus) }}
          </el-tag>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="考试名称">
          {{ exam.examName || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="所属科目">
          {{ exam.subjectName || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="试卷名称">
          {{ exam.paperName || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="考试时长">
          {{ exam.duration || 0 }} 分钟
        </el-descriptions-item>
        <el-descriptions-item label="开始时间">
          {{ exam.startTime || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="结束时间">
          {{ exam.endTime || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="创建人">
          {{ exam.createUserName || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">
          {{ exam.createTime || '-' }}
        </el-descriptions-item>
      </el-descriptions>

      <el-descriptions v-if="exam.description" title="考试说明" :column="1" border style="margin-top: 20px">
        <el-descriptions-item label="说明">
          {{ exam.description }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 统计信息卡片 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>统计信息</span>
          <el-button link type="primary" @click="loadStatistics">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
        </div>
      </template>

      <el-row :gutter="20">
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon stat-total">
              <el-icon size="32"><User /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">应考人数</div>
              <div class="stat-value">{{ statistics.totalCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon stat-submitted">
              <el-icon size="32"><Check /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">已交卷</div>
              <div class="stat-value">{{ statistics.submittedCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon stat-testing">
              <el-icon size="32"><Clock /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">考试中</div>
              <div class="stat-value">{{ statistics.testingCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon stat-notstart">
              <el-icon size="32"><Timer /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">未开始</div>
              <div class="stat-value">{{ statistics.notStartedCount || 0 }}</div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 成绩统计 -->
      <el-row :gutter="20" style="margin-top: 20px" v-if="statistics.avgScore !== undefined">
        <el-col :span="8">
          <div class="score-stat">
            <div class="score-label">平均分</div>
            <div class="score-value">{{ statistics.avgScore || 0 }}</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="score-stat">
            <div class="score-label">最高分</div>
            <div class="score-value">{{ statistics.maxScore || 0 }}</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="score-stat">
            <div class="score-label">及格率</div>
            <div class="score-value">{{ statistics.passRate || 0 }}%</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- 操作按钮 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <span>考试操作</span>
      </template>

      <el-space wrap>
        <el-button
          v-if="exam.examStatus === 0"
          type="primary"
          @click="handlePublish"
        >
          <el-icon><Promotion /></el-icon>
          发布考试
        </el-button>
        <el-button
          v-if="exam.examStatus === 1"
          type="success"
          @click="handleStart"
        >
          <el-icon><VideoPlay /></el-icon>
          开始考试
        </el-button>
        <el-button
          v-if="exam.examStatus === 2"
          type="warning"
          @click="handleEnd"
        >
          <el-icon><VideoPause /></el-icon>
          结束考试
        </el-button>
        <el-button
          v-if="exam.examStatus !== 4"
          type="danger"
          @click="handleCancel"
        >
          <el-icon><Close /></el-icon>
          取消考试
        </el-button>
        <el-button @click="handleCopy">
          <el-icon><CopyDocument /></el-icon>
          复制考试
        </el-button>
        <el-button type="danger" @click="handleDelete">
          <el-icon><Delete /></el-icon>
          删除考试
        </el-button>
      </el-space>
    </el-card>

    <!-- 参加考试的学生列表 -->
    <ExamStudentsManager
      v-if="exam.examId"
      :exam-id="exam.examId"
      :subject-id="exam.subjectId"
      style="margin-top: 20px"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Edit, Monitor, View, Refresh, User, Check, Clock, Timer,
  Promotion, VideoPlay, VideoPause, Close, CopyDocument, Delete
} from '@element-plus/icons-vue'
import ExamStudentsManager from '@/components/ExamStudentsManager.vue'
import examApi from '@/api/exam'
import {
  getExamStatusName,
  getExamStatusColor
} from '@/utils/enums'

const router = useRouter()
const route = useRoute()

// ==================== 状态 ====================
const loading = ref(false)
const exam = ref({})
const statistics = ref({})

// ==================== 返回 ====================
const goBack = () => {
  router.back()
}

// ==================== 加载考试详情 ====================
const loadExam = async () => {
  try {
    loading.value = true
    const res = await examApi.getById(route.params.id)
    if (res.code === 200 && res.data) {
      exam.value = res.data
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// ==================== 加载统计信息 ====================
const loadStatistics = async () => {
  try {
    const res = await examApi.getStatistics(route.params.id)
    if (res.code === 200 && res.data) {
      statistics.value = res.data
    }
  } catch (error) {
    console.error('加载统计信息失败:', error)
  }
}

// ==================== 编辑考试 ====================
const handleEdit = () => {
  router.push(`/exam/edit/${exam.value.examId}`)
}

// ==================== 监控考试 ====================
const handleMonitor = () => {
  if (!exam.value.examId) {
    ElMessage.error('考试ID获取失败')
    return
  }
  console.log('跳转到监控页面，examId:', exam.value.examId)
  router.push(`/exam/monitor?examId=${exam.value.examId}`)
}

// ==================== 预览试卷 ====================
const handlePreviewPaper = () => {
  const routeData = router.resolve({
    name: 'PaperPreview',
    params: { id: exam.value.paperId }
  })
  window.open(routeData.href, '_blank')
}

// ==================== 发布考试 ====================
const handlePublish = async () => {
  try {
    await ElMessageBox.confirm('确定要发布此考试吗？', '提示', {
      type: 'warning'
    })

    const res = await examApi.publish(exam.value.examId)
    if (res.code === 200) {
      ElMessage.success('发布成功')
      loadExam()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('发布失败')
    }
  }
}

// ==================== 开始考试 ====================
const handleStart = async () => {
  try {
    await ElMessageBox.confirm('确定要开始此考试吗？', '提示', {
      type: 'warning'
    })

    const res = await examApi.start(exam.value.examId)
    if (res.code === 200) {
      ElMessage.success('考试已开始')
      loadExam()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// ==================== 结束考试 ====================
const handleEnd = async () => {
  try {
    await ElMessageBox.confirm('确定要结束此考试吗？结束后无法恢复！', '警告', {
      type: 'warning',
      confirmButtonText: '确定结束',
      cancelButtonText: '取消'
    })

    const res = await examApi.end(exam.value.examId)
    if (res.code === 200) {
      ElMessage.success('考试已结束')
      loadExam()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// ==================== 取消考试 ====================
const handleCancel = async () => {
  try {
    await ElMessageBox.confirm('确定要取消此考试吗？', '警告', {
      type: 'warning'
    })

    const res = await examApi.cancel(exam.value.examId)
    if (res.code === 200) {
      ElMessage.success('已取消考试')
      loadExam()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// ==================== 复制考试 ====================
const handleCopy = async () => {
  try {
    const { value: newTitle } = await ElMessageBox.prompt('请输入新考试名称', '复制考试', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValue: `${exam.value.examName} - 副本`,
      inputValidator: (value) => {
        if (!value) {
          return '请输入考试名称'
        }
        return true
      }
    })

    const res = await examApi.copy(exam.value.examId, newTitle)
    if (res.code === 200) {
      ElMessage.success('复制成功')
      router.push(`/exam/${res.data}`)
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('复制失败')
    }
  }
}

// ==================== 删除考试 ====================
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要删除考试"${exam.value.examName}"吗？此操作不可恢复！`,
      '警告',
      {
        type: 'error',
        confirmButtonText: '确定删除',
        cancelButtonText: '取消'
      }
    )

    const res = await examApi.deleteById(exam.value.examId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      goBack()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}


// ==================== 初始化 ====================
onMounted(() => {
  loadExam()
  loadStatistics()
})
</script>

<style scoped>
.exam-detail-container {
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

/* 统计卡片 */
.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
  transition: all 0.3s;
}

.stat-card:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
}

.stat-icon.stat-total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stat-icon.stat-submitted {
  background: linear-gradient(135deg, #67c23a 0%, #409eff 100%);
  color: white;
}

.stat-icon.stat-testing {
  background: linear-gradient(135deg, #e6a23c 0%, #f56c6c 100%);
  color: white;
}

.stat-icon.stat-notstart {
  background: linear-gradient(135deg, #909399 0%, #606266 100%);
  color: white;
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
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

/* 分数统计 */
.score-stat {
  text-align: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  color: white;
}

.score-label {
  font-size: 14px;
  margin-bottom: 10px;
  opacity: 0.9;
}

.score-value {
  font-size: 32px;
  font-weight: bold;
}
</style>

