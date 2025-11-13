<template>
  <div class="exam-start-container">
    <el-card shadow="never" class="exam-card">
      <div class="exam-header">
        <h2>{{ examInfo.examName }}</h2>
        <el-tag :type="getStatusTagType()">{{ getStatusText() }}</el-tag>
      </div>

      <!-- 考试信息 -->
      <el-descriptions :column="2" border class="exam-info">
        <el-descriptions-item label="考试时长">
          <el-icon><Timer /></el-icon>
          {{ examInfo.duration }} 分钟
        </el-descriptions-item>
        <el-descriptions-item label="试卷名称">
          {{ examInfo.paperName || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="开始时间">
          <el-icon><Calendar /></el-icon>
          {{ formatDateTime(examInfo.startTime) }}
        </el-descriptions-item>
        <el-descriptions-item label="结束时间">
          <el-icon><Calendar /></el-icon>
          {{ formatDateTime(examInfo.endTime) }}
        </el-descriptions-item>
        <el-descriptions-item label="剩余时间" :span="2">
          <div class="remaining-time" :class="{'time-warning': isTimeWarning}">
            <el-icon><Clock /></el-icon>
            {{ remainingTime }}
          </div>
        </el-descriptions-item>
      </el-descriptions>

      <!-- 考试说明 -->
      <el-alert
        v-if="examInfo.description"
        :title="examInfo.description"
        type="info"
        :closable="false"
        show-icon
        style="margin-top: 20px"
      />

      <!-- 考试规则 -->
      <div class="exam-rules">
        <h3><el-icon><Warning /></el-icon> 考试规则与注意事项</h3>
        <ul>
          <li v-if="examInfo.cutScreenLimit > 0">
            <el-icon><Monitor /></el-icon>
            允许切屏次数：<strong>{{ examInfo.cutScreenLimit }}</strong> 次，超过将强制提交试卷
          </li>
          <li v-if="examInfo.cutScreenTimer === 1">
            <el-icon><Clock /></el-icon>
            切屏时间将<strong>计入</strong>考试时间
          </li>
          <li v-if="examInfo.forbidCopy === 1">
            <el-icon><CopyDocument /></el-icon>
            考试期间<strong>禁止复制粘贴</strong>
          </li>
          <li v-if="examInfo.singleDevice === 1">
            <el-icon><Cellphone /></el-icon>
            仅允许<strong>单设备登录</strong>，其他设备将被强制下线
          </li>
          <li>
            <el-icon><CircleCheck /></el-icon>
            请确保网络连接稳定，避免因网络问题影响考试
          </li>
          <li>
            <el-icon><QuestionFilled /></el-icon>
            考试过程中如遇问题，请及时联系监考老师
          </li>
          <li>
            <el-icon><DocumentChecked /></el-icon>
            提交试卷后将<strong>无法修改</strong>答案，请仔细检查后再提交
          </li>
        </ul>
      </div>

      <!-- 考前确认 -->
      <div class="exam-confirm">
        <el-checkbox v-model="hasReadRules" size="large">
          我已阅读并同意遵守以上考试规则
        </el-checkbox>
      </div>

      <!-- 操作按钮 -->
      <div class="exam-actions">
        <el-button size="large" @click="handleBack">返回</el-button>
        <el-button
          type="primary"
          size="large"
          :disabled="!hasReadRules || !canStart"
          :loading="starting"
          @click="handleStartExam"
        >
          {{ startButtonText }}
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Timer, Calendar, Clock, Warning, Monitor, CopyDocument,
  Cellphone, CircleCheck, QuestionFilled, DocumentChecked
} from '@element-plus/icons-vue'
import { getExamDetail } from '@/api/exam'
import { createExamSession } from '@/api/examSession'

const route = useRoute()
const router = useRouter()

const examInfo = ref({})
const hasReadRules = ref(false)
const starting = ref(false)
const remainingTime = ref('')
let timer = null

// 是否可以开始
const canStart = computed(() => {
  if (!examInfo.value.startTime || !examInfo.value.endTime) return false
  const now = new Date()
  const startTime = new Date(examInfo.value.startTime)
  const endTime = new Date(examInfo.value.endTime)
  return now >= startTime && now < endTime
})

// 时间告警
const isTimeWarning = computed(() => {
  if (!examInfo.value.endTime) return false
  const now = new Date()
  const endTime = new Date(examInfo.value.endTime)
  const diff = endTime - now
  return diff <= 1800000 // 30分钟
})

// 开始按钮文本
const startButtonText = computed(() => {
  if (!canStart.value) return '未到考试时间'
  return starting.value ? '正在进入...' : '开始考试'
})

// 获取考试详情
const getDetail = async () => {
  try {
    const res = await getExamDetail(route.params.examId)
    if (res.code === 200) {
      examInfo.value = res.data
      updateRemainingTime()
    }
  } catch (error) {
    ElMessage.error('获取考试信息失败')
  }
}

// 更新剩余时间
const updateRemainingTime = () => {
  if (!examInfo.value.endTime) return

  const now = new Date()
  const endTime = new Date(examInfo.value.endTime)
  const diff = endTime - now

  if (diff <= 0) {
    remainingTime.value = '考试已结束'
    return
  }

  const hours = Math.floor(diff / 3600000)
  const minutes = Math.floor((diff % 3600000) / 60000)
  const seconds = Math.floor((diff % 60000) / 1000)

  remainingTime.value = `${hours}小时 ${minutes}分钟 ${seconds}秒`
}

// 开始考试
const handleStartExam = async () => {
  try {
    await ElMessageBox.confirm(
      '确认开始考试吗？开始后将计时，请合理安排答题时间。',
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    starting.value = true

    // 创建考试会话
    const res = await createExamSession({
      examId: route.params.examId
    })

    if (res.code === 200) {
      const sessionId = res.data
      ElMessage.success('进入考试')

      // 跳转到答题页面
      router.push({
        name: 'ExamPaper',
        params: { sessionId }
      })
    } else {
      ElMessage.error(res.message || '创建考试会话失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('开始考试失败')
    }
  } finally {
    starting.value = false
  }
}

// 返回
const handleBack = () => {
  router.back()
}

// 状态标签类型
const getStatusTagType = () => {
  if (!canStart.value) return 'info'
  return 'warning'
}

// 状态文本
const getStatusText = () => {
  if (!canStart.value) return '未开始'
  return '进行中'
}

// 格式化时间
const formatDateTime = (datetime) => {
  if (!datetime) return '-'
  return datetime.replace('T', ' ')
}

// 启动定时器
const startTimer = () => {
  timer = setInterval(() => {
    updateRemainingTime()
  }, 1000)
}

// 停止定时器
const stopTimer = () => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

onMounted(async () => {
  await getDetail()
  startTimer()
})

onUnmounted(() => {
  stopTimer()
})
</script>

<style scoped>
.exam-start-container {
  padding: 40px 20px;
  max-width: 900px;
  margin: 0 auto;
}

.exam-card {
  padding: 20px;
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e4e7ed;
}

.exam-header h2 {
  margin: 0;
  color: #303133;
}

.exam-info {
  margin-bottom: 20px;
}

.remaining-time {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: bold;
  color: #409eff;
}

.remaining-time .el-icon {
  margin-right: 8px;
}

.remaining-time.time-warning {
  color: #f56c6c;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

.exam-rules {
  margin-top: 30px;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
}

.exam-rules h3 {
  display: flex;
  align-items: center;
  margin: 0 0 15px 0;
  color: #e6a23c;
  font-size: 16px;
}

.exam-rules h3 .el-icon {
  margin-right: 8px;
}

.exam-rules ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.exam-rules li {
  display: flex;
  align-items: center;
  padding: 10px 0;
  color: #606266;
  line-height: 1.6;
}

.exam-rules li .el-icon {
  margin-right: 10px;
  color: #909399;
}

.exam-rules li strong {
  color: #e6a23c;
  margin: 0 4px;
}

.exam-confirm {
  margin-top: 30px;
  padding: 20px;
  background: #fff9e6;
  border: 1px solid #e6a23c;
  border-radius: 8px;
  text-align: center;
}

.exam-actions {
  margin-top: 30px;
  text-align: center;
}

.exam-actions .el-button {
  min-width: 120px;
  margin: 0 10px;
}
</style>

