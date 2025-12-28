<template>
  <el-dialog
    v-model="visible"
    title="批改答案"
    width="800px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <div v-if="answer" class="grading-dialog">
      <!-- 题目信息 -->
      <el-card class="info-card">
        <template #header>
          <span>题目信息</span>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="题目内容">
            {{ answer.questionContent }}
          </el-descriptions-item>
          <el-descriptions-item label="题目类型">
            {{ getQuestionTypeName(answer.questionType) }}
          </el-descriptions-item>
          <el-descriptions-item label="分值">
            {{ answer.defaultScore }} 分
          </el-descriptions-item>
          <el-descriptions-item label="学生姓名">
            {{ answer.studentName }}
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 学生答案 -->
      <el-card class="answer-card">
        <template #header>
          <span>学生答案</span>
        </template>
        <div class="answer-content">
          {{ answer.userAnswer || '（未作答）' }}
        </div>
      </el-card>

      <!-- 参考答案 -->
      <el-card v-if="answer.correctAnswer" class="reference-card">
        <template #header>
          <span>参考答案</span>
        </template>
        <div class="answer-content">
          {{ answer.correctAnswer }}
        </div>
      </el-card>

      <!-- 评分表单 -->
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="grade-form"
      >
        <el-form-item label="得分" prop="score">
          <el-input-number
            v-model="form.score"
            :min="0"
            :max="answer.defaultScore"
            :precision="1"
            :step="0.5"
            controls-position="right"
            style="width: 200px"
          />
          <span style="margin-left: 10px; color: #909399">
            满分: {{ answer.defaultScore }} 分
          </span>
        </el-form-item>

        <el-form-item label="批注" prop="comment">
          <el-input
            v-model="form.comment"
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
      <el-button @click="handleClose">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="handleSubmit">
        提交批改
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import gradingApi from '@/api/grading'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  answer: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'success'])

// 数据
const visible = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})

const formRef = ref(null)
const submitting = ref(false)

const form = reactive({
  score: 0,
  comment: ''
})

const rules = {
  score: [
    { required: true, message: '请输入得分', trigger: 'blur' },
    { type: 'number', min: 0, message: '得分不能小于0', trigger: 'blur' }
  ]
}

// 监听答案变化
watch(() => props.answer, (newVal) => {
  if (newVal) {
    form.score = 0
    form.comment = ''
  }
}, { immediate: true })

// 方法
const getQuestionTypeName = (type) => {
  const typeMap = {
    'SINGLE_CHOICE': '单选题',
    'MULTIPLE_CHOICE': '多选题',
    'TRUE_FALSE': '判断题',
    'FILL_BLANK': '填空题',
    'SUBJECTIVE': '主观题',
    'INDEFINITE_CHOICE': '不定项选择',
    'MATCHING': '匹配题',
    'SORT': '排序题'
  }
  return typeMap[type] || type
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitting.value = true
    try {
      const data = {
        answerId: props.answer.answerId,
        score: form.score,
        comment: form.comment,
        teacherId: getUserId() // TODO: 从store获取当前教师ID
      }

      const res = await gradingApi.gradeAnswer(data)
      if (res.code === 200) {
        ElMessage.success('批改成功')
        emit('success')
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

const handleClose = () => {
  visible.value = false
  formRef.value?.resetFields()
}

const getUserId = () => {
  // TODO: 从store或localStorage获取当前用户ID
  return 1
}
</script>

<style scoped>
.grading-dialog {
  max-height: 600px;
  overflow-y: auto;
}

.info-card,
.answer-card,
.reference-card {
  margin-bottom: 20px;
}

.answer-content {
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  line-height: 1.8;
  white-space: pre-wrap;
  word-break: break-word;
}

.grade-form {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}
</style>

