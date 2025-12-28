<template>
  <div class="grading-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>阅卷管理</span>
          <el-button type="primary" @click="refreshList">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
        </div>
      </template>

      <!-- 筛选条件 -->
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="考试">
          <el-select
            v-model="queryForm.examId"
            placeholder="请选择考试"
            clearable
            filterable
            style="width: 200px"
            @change="handleExamChange"
          >
            <el-option
              v-for="exam in examList"
              :key="exam.examId"
              :label="exam.examName"
              :value="exam.examId"
            />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleQuery">
            <el-icon><Search /></el-icon>
            查询
          </el-button>
          <el-button @click="resetQuery">
            <el-icon><RefreshLeft /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>

      <!-- 批改进度 -->
      <div v-if="progress" class="progress-section">
        <el-row :gutter="20">
          <el-col :span="6">
            <el-statistic title="待批改" :value="progress.pending">
              <template #suffix>
                <span style="font-size: 14px">题</span>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="已批改" :value="progress.graded">
              <template #suffix>
                <span style="font-size: 14px">题</span>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="总数" :value="progress.total">
              <template #suffix>
                <span style="font-size: 14px">题</span>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-progress
              :percentage="progress.progress || 0"
              :stroke-width="20"
              :format="(p) => p.toFixed(1) + '%'"
            />
          </el-col>
        </el-row>
      </div>

      <el-divider />

      <!-- 答案列表 -->
      <el-table
        v-loading="loading"
        :data="answerList"
        border
        stripe
        style="width: 100%"
      >
        <el-table-column prop="answerId" label="ID" width="80" />
        <el-table-column prop="userId" label="学生ID" width="100" />
        <el-table-column prop="questionId" label="题目ID" width="100" />
        <el-table-column label="学生答案" min-width="200">
          <template #default="{ row }">
            <div class="answer-preview">{{ row.userAnswer || '（未作答）' }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="score" label="得分" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.score !== null" type="success">{{ row.score }}</el-tag>
            <el-tag v-else type="warning">待批改</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="提交时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="handleGrade(row)"
              :disabled="row.score !== null"
            >
              {{ row.score !== null ? '已批改' : '批改' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @size-change="handleQuery"
        @current-change="handleQuery"
      />
    </el-card>

    <!-- 批改对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="批改答案"
      width="700px"
      :close-on-click-modal="false"
    >
      <div v-if="currentAnswer" class="grading-dialog">
        <!-- 题目信息 -->
        <el-descriptions title="答题信息" :column="2" border>
          <el-descriptions-item label="答案ID">{{ currentAnswer.answerId }}</el-descriptions-item>
          <el-descriptions-item label="题目ID">{{ currentAnswer.questionId }}</el-descriptions-item>
          <el-descriptions-item label="学生ID">{{ currentAnswer.userId }}</el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ formatDateTime(currentAnswer.createTime) }}</el-descriptions-item>
        </el-descriptions>

        <!-- 学生答案 -->
        <el-card class="answer-card" style="margin-top: 20px">
          <template #header>
            <span>学生答案</span>
          </template>
          <div class="answer-content">
            {{ currentAnswer.userAnswer || '（未作答）' }}
          </div>
        </el-card>

        <!-- 评分表单 -->
        <el-form
          ref="formRef"
          :model="gradeForm"
          :rules="rules"
          label-width="100px"
          style="margin-top: 20px"
        >
          <el-form-item label="得分" prop="score">
            <el-input-number
              v-model="gradeForm.score"
              :min="0"
              :max="100"
              :precision="1"
              :step="1"
              controls-position="right"
              style="width: 200px"
            />
          </el-form-item>

          <el-form-item label="批注" prop="comment">
            <el-input
              v-model="gradeForm.comment"
              type="textarea"
              :rows="4"
              placeholder="请输入批注或评语（选填）"
              maxlength="500"
              show-word-limit
            />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmitGrade">
          提交批改
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh, Search, RefreshLeft } from '@element-plus/icons-vue'
import gradingApi from '@/api/grading'
import examApi from '@/api/exam'
import { useAuthStore } from '@/stores/modules/auth'

const authStore = useAuthStore()

// 数据
const loading = ref(false)
const submitting = ref(false)
const answerList = ref([])
const examList = ref([])
const progress = ref(null)
const dialogVisible = ref(false)
const currentAnswer = ref(null)
const formRef = ref(null)

// 查询表单
const queryForm = reactive({
  examId: null
})

// 分页
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 批改表单
const gradeForm = reactive({
  score: 0,
  comment: ''
})

const rules = {
  score: [
    { required: true, message: '请输入得分', trigger: 'blur' }
  ]
}

// 方法
const loadExamList = async () => {
  try {
    const res = await examApi.page({ current: 1, size: 100 })
    if (res.code === 200) {
      examList.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载考试列表失败:', error)
  }
}

const loadPendingAnswers = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
      examId: queryForm.examId
    }

    const res = await gradingApi.getPendingGradingList(params)
    if (res.code === 200) {
      answerList.value = res.data?.records || []
      pagination.total = res.data?.total || 0
    }
  } catch (error) {
    console.error('加载待批改答案失败:', error)
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

const loadProgress = async () => {
  if (!queryForm.examId) {
    progress.value = null
    return
  }

  try {
    const res = await gradingApi.getGradingProgress(queryForm.examId)
    if (res.code === 200) {
      progress.value = res.data
    }
  } catch (error) {
    console.error('加载批改进度失败:', error)
  }
}

const handleExamChange = () => {
  pagination.current = 1
  loadPendingAnswers()
  loadProgress()
}

const handleQuery = () => {
  loadPendingAnswers()
  loadProgress()
}

const resetQuery = () => {
  queryForm.examId = null
  pagination.current = 1
  progress.value = null
  loadPendingAnswers()
}

const refreshList = () => {
  loadPendingAnswers()
  loadProgress()
}

const handleGrade = (row) => {
  currentAnswer.value = row
  gradeForm.score = 0
  gradeForm.comment = ''
  dialogVisible.value = true
}

const handleSubmitGrade = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitting.value = true
    try {
      const params = {
        answerId: currentAnswer.value.answerId,
        score: gradeForm.score,
        comment: gradeForm.comment,
        teacherId: authStore.userId || 1
      }

      const res = await gradingApi.gradeAnswer(params)
      if (res.code === 200) {
        ElMessage.success('批改成功')
        dialogVisible.value = false
        refreshList()
      } else {
        ElMessage.error(res.message || '批改失败')
      }
    } catch (error) {
      console.error('批改失败:', error)
      ElMessage.error('批改失败')
    } finally {
      submitting.value = false
    }
  })
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  return new Date(dateTime).toLocaleString('zh-CN')
}

// 生命周期
onMounted(() => {
  loadExamList()
  loadPendingAnswers()
})
</script>

<style scoped>
.grading-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.query-form {
  margin-bottom: 20px;
}

.progress-section {
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 8px;
  margin-bottom: 20px;
}

.answer-preview {
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.grading-dialog {
  max-height: 500px;
  overflow-y: auto;
}

.answer-card {
  margin-top: 20px;
}

.answer-content {
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  line-height: 1.8;
  white-space: pre-wrap;
  word-break: break-word;
  min-height: 100px;
}
</style>

