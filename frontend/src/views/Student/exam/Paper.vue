<template>
  <div class="exam-paper">
    <!-- 顶部工具栏 -->
    <div class="exam-header">
      <div class="exam-info">
        <span class="exam-title">{{ examInfo.examName }}</span>
        <el-tag type="warning" style="margin-left: 10px">
          <el-icon><Timer /></el-icon>
          {{ remainingTime }}
        </el-tag>
      </div>
      <div class="exam-actions">
        <el-button type="primary" @click="handleSubmit">
          <el-icon><DocumentChecked /></el-icon>
          提交试卷
        </el-button>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="exam-content">
      <!-- 左侧：题目内容 -->
      <div class="question-area">
        <el-card v-loading="loading">
          <template #header>
            <div class="question-header">
              <span>第 {{ currentQuestionIndex + 1 }} 题</span>
              <el-tag :type="getQuestionTypeTag(currentQuestion.questionType)">
                {{ getQuestionTypeName(currentQuestion.questionType) }}
              </el-tag>
              <span style="margin-left: auto">
                分值: {{ currentQuestion.defaultScore }} 分
              </span>
            </div>
          </template>

          <!-- 题目内容 -->
          <div class="question-content">
            <div class="question-text" v-html="currentQuestion.questionContent"></div>

            <!-- 答案区域 -->
            <div class="answer-area">
              <!-- 单选题 -->
              <el-radio-group
                v-if="currentQuestion.questionType === 'SINGLE_CHOICE' || currentQuestion.questionType === 'TRUE_FALSE'"
                v-model="currentAnswer"
                @change="handleAnswerChange"
              >
                <el-radio
                  v-for="option in currentQuestion.options"
                  :key="option.optionId"
                  :label="option.optionKey"
                  class="answer-option"
                >
                  <span class="option-label">{{ option.optionKey }}.</span>
                  <span v-html="option.optionContent"></span>
                </el-radio>
              </el-radio-group>

              <!-- 多选题/不定项选择 -->
              <el-checkbox-group
                v-else-if="currentQuestion.questionType === 'MULTIPLE_CHOICE' || currentQuestion.questionType === 'INDEFINITE_CHOICE'"
                v-model="currentAnswer"
                @change="handleAnswerChange"
              >
                <el-checkbox
                  v-for="option in currentQuestion.options"
                  :key="option.optionId"
                  :label="option.optionKey"
                  class="answer-option"
                >
                  <span class="option-label">{{ option.optionKey }}.</span>
                  <span v-html="option.optionContent"></span>
                </el-checkbox>
              </el-checkbox-group>

              <!-- 填空题 -->
              <div v-else-if="currentQuestion.questionType === 'FILL_BLANK'" class="fill-blank-area">
                <div v-for="(blank, index) in fillBlanks" :key="index" class="blank-item">
                  <span class="blank-label">第 {{ index + 1 }} 空：</span>
                  <el-input
                    v-model="fillBlanks[index]"
                    placeholder="请输入答案"
                    @input="handleFillBlankChange"
                    style="width: 300px"
                  />
                </div>
              </div>

              <!-- 主观题 -->
              <div v-else-if="currentQuestion.questionType === 'SUBJECTIVE'" class="subjective-area">
                <el-input
                  v-model="currentAnswer"
                  type="textarea"
                  :rows="10"
                  placeholder="请输入你的答案..."
                  @input="handleAnswerChange"
                  maxlength="2000"
                  show-word-limit
                />
              </div>
            </div>
          </div>

          <!-- 底部操作 -->
          <div class="question-footer">
            <el-button
              :disabled="currentQuestionIndex === 0"
              @click="handlePrevQuestion"
            >
              <el-icon><ArrowLeft /></el-icon>
              上一题
            </el-button>
            <el-button
              :disabled="currentQuestionIndex === questions.length - 1"
              @click="handleNextQuestion"
            >
              下一题
              <el-icon><ArrowRight /></el-icon>
            </el-button>
          </div>
        </el-card>
      </div>

      <!-- 右侧：答题卡 -->
      <div class="answer-sheet">
        <el-card class="answer-sheet-card">
          <template #header>
            <div style="display: flex; align-items: center; justify-content: space-between">
              <span>答题卡</span>
              <el-button type="primary" size="small" @click="handleSubmit">
                提交
              </el-button>
            </div>
          </template>

          <!-- 答题进度 -->
          <div class="progress-info">
            <div class="progress-item">
              <span>已答：</span>
              <span class="answered-count">{{ answeredCount }}</span>
            </div>
            <div class="progress-item">
              <span>未答：</span>
              <span class="unanswered-count">{{ unansweredCount }}</span>
            </div>
            <div class="progress-item">
              <span>总题数：</span>
              <span>{{ questions.length }}</span>
            </div>
          </div>

          <el-divider />

          <!-- 答题卡网格 -->
          <div class="answer-grid">
            <div
              v-for="(question, index) in questions"
              :key="question.questionId"
              :class="[
                'answer-item',
                {
                  'is-current': index === currentQuestionIndex,
                  'is-answered': answers[question.questionId]
                }
              ]"
              @click="handleJumpToQuestion(index)"
            >
              {{ index + 1 }}
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 考试监控组件 -->
    <ExamMonitor
      v-if="sessionId"
      :session-id="sessionId"
      :exam-id="examInfo.examId"
      :config="monitorConfig"
      @violation="handleViolation"
      @limit-reached="handleLimitReached"
      @auto-submit="handleAutoSubmit"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Timer, DocumentChecked, ArrowLeft, ArrowRight
} from '@element-plus/icons-vue'
import studentExamApi from '@/api/studentExam'
import ExamMonitor from '@/components/ExamMonitor.vue'

const route = useRoute()
const router = useRouter()

// 数据
const loading = ref(false)
const sessionId = ref(route.params.sessionId)
const examInfo = ref({})
const questions = ref([])
const answers = ref({}) // { questionId: answer }
const currentQuestionIndex = ref(0)
const remainingTime = ref('加载中...')
let timer = null

// 当前题目
const currentQuestion = computed(() => {
  return questions.value[currentQuestionIndex.value] || {}
})

// 当前答案
const currentAnswer = ref(null)
const fillBlanks = ref([]) // 填空题答案数组

// 答题统计
const answeredCount = computed(() => {
  return Object.keys(answers.value).filter(key => {
    const answer = answers.value[key]
    if (Array.isArray(answer)) {
      return answer.length > 0
    }
    return answer !== null && answer !== undefined && answer !== ''
  }).length
})

const unansweredCount = computed(() => {
  return questions.value.length - answeredCount.value
})

// 监控配置
const monitorConfig = computed(() => ({
  enableTabSwitch: examInfo.value.cutScreenLimit > 0,
  enableCopy: examInfo.value.forbidCopy === 1,
  enablePaste: examInfo.value.forbidCopy === 1,
  enableRightClick: true,
  enableFullscreen: false,
  enableIdleTimeout: false,
  tabSwitchLimit: examInfo.value.cutScreenLimit || 3,
  autoSubmitOnViolation: true
}))

// 方法

// 加载会话信息
const loadSession = async () => {
  loading.value = true
  try {
    const res = await studentExamApi.getSession(sessionId.value)
    if (res.code === 200) {
      examInfo.value = res.data.examInfo || {}
      questions.value = res.data.questions || []

      // 加载已保存的答案（从响应中直接获取）
      const answerList = res.data.answers || []
      answerList.forEach(item => {
        let answer = item.userAnswer
        // 处理多选题答案（字符串转数组）
        const question = questions.value.find(q => q.questionId === item.questionId)
        if (question && (question.questionType === 'MULTIPLE_CHOICE' || question.questionType === 'INDEFINITE_CHOICE')) {
          answer = answer ? answer.split(',') : []
        }
        answers.value[item.questionId] = answer
      })

      // 初始化当前题目答案
      loadCurrentAnswer()

      // 启动倒计时
      startTimer()
    } else {
      ElMessage.error(res.message || '加载考试失败')
      router.back()
    }
  } catch (error) {
    console.error('加载考试失败:', error)
    ElMessage.error('加载考试失败')
    router.back()
  } finally {
    loading.value = false
  }
}

// 加载已保存的答案（备用，从单独的API获取）
const loadAnswers = async () => {
  try {
    const res = await studentExamApi.getAnswers(sessionId.value)
    if (res.code === 200) {
      const answerList = res.data || []
      answerList.forEach(item => {
        let answer = item.userAnswer
        // 处理多选题答案（字符串转数组）
        const question = questions.value.find(q => q.questionId === item.questionId)
        if (question && (question.questionType === 'MULTIPLE_CHOICE' || question.questionType === 'INDEFINITE_CHOICE')) {
          answer = answer ? answer.split(',') : []
        }
        answers.value[item.questionId] = answer
      })

      // 初始化当前题目答案
      loadCurrentAnswer()
    }
  } catch (error) {
    console.error('加载答案失败:', error)
  }
}

// 加载当前题目答案
const loadCurrentAnswer = () => {
  const questionId = currentQuestion.value.questionId
  const answer = answers.value[questionId]

  if (currentQuestion.value.questionType === 'FILL_BLANK') {
    // 填空题：分割答案
    fillBlanks.value = answer ? answer.split('|') : Array(currentQuestion.value.blankCount || 1).fill('')
  } else {
    currentAnswer.value = answer || (
      currentQuestion.value.questionType === 'MULTIPLE_CHOICE' ||
      currentQuestion.value.questionType === 'INDEFINITE_CHOICE'
        ? []
        : null
    )
  }
}

// 启动倒计时
const startTimer = () => {
  updateRemainingTime()
  timer = setInterval(updateRemainingTime, 1000)
}

// 更新剩余时间
const updateRemainingTime = () => {
  if (!examInfo.value.endTime) return

  const now = new Date()
  const end = new Date(examInfo.value.endTime)
  const diff = end - now

  if (diff <= 0) {
    remainingTime.value = '考试已结束'
    clearInterval(timer)
    handleAutoSubmit()
    return
  }

  const hours = Math.floor(diff / 3600000)
  const minutes = Math.floor((diff % 3600000) / 60000)
  const seconds = Math.floor((diff % 60000) / 1000)

  remainingTime.value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`

  // 最后5分钟警告
  if (diff <= 300000 && diff > 299000) {
    ElMessage.warning('考试还剩最后5分钟，请注意时间！')
  }
}

// 答案改变
const handleAnswerChange = () => {
  saveCurrentAnswer()
}

// 填空题答案改变
const handleFillBlankChange = () => {
  currentAnswer.value = fillBlanks.value.join('|')
  saveCurrentAnswer()
}

// 保存当前答案
const saveCurrentAnswer = async () => {
  const questionId = currentQuestion.value.questionId
  let answer = currentAnswer.value

  // 多选题：数组转字符串
  if (Array.isArray(answer)) {
    answer = answer.join(',')
  }

  // 保存到本地状态
  answers.value[questionId] = currentAnswer.value

  // 保存到服务器
  try {
    await studentExamApi.saveAnswer(sessionId.value, {
      questionId: questionId,
      userAnswer: answer || ''
    })
  } catch (error) {
    console.error('保存答案失败:', error)
    // 不显示错误消息，避免干扰用户答题
  }
}

// 上一题
const handlePrevQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
    loadCurrentAnswer()
  }
}

// 下一题
const handleNextQuestion = () => {
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++
    loadCurrentAnswer()
  }
}

// 跳转到指定题目
const handleJumpToQuestion = (index) => {
  currentQuestionIndex.value = index
  loadCurrentAnswer()
}

// 提交试卷
const handleSubmit = async () => {
  try {
    await ElMessageBox.confirm(
      `您已答 ${answeredCount.value} 题，还有 ${unansweredCount.value} 题未答。确认提交试卷吗？`,
      '提交确认',
      {
        confirmButtonText: '确认提交',
        cancelButtonText: '继续答题',
        type: 'warning'
      }
    )

    await submitExam()
  } catch (error) {
    // 用户取消
  }
}

// 自动提交（时间到或违规）
const handleAutoSubmit = async () => {
  await submitExam()
}

// 提交考试
const submitExam = async () => {
  loading.value = true
  try {
    const res = await studentExamApi.submitExam(sessionId.value)
    if (res.code === 200) {
      ElMessage.success('提交成功')
      clearInterval(timer)
      // 跳转到结果页面
      router.replace({
        name: 'StudentExamResult',
        params: { sessionId: sessionId.value }
      })
    } else {
      ElMessage.error(res.message || '提交失败')
    }
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('提交失败')
  } finally {
    loading.value = false
  }
}

// 违规处理
const handleViolation = (violation) => {
  console.log('检测到违规行为:', violation)
}

// 违规次数达到上限
const handleLimitReached = () => {
  ElMessage.error('违规次数已达上限，系统将自动提交试卷')
  setTimeout(() => {
    handleAutoSubmit()
  }, 3000)
}

// 获取题目类型名称
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

// 获取题目类型标签
const getQuestionTypeTag = (type) => {
  const tagMap = {
    'SINGLE_CHOICE': 'success',
    'MULTIPLE_CHOICE': 'warning',
    'TRUE_FALSE': 'info',
    'FILL_BLANK': 'primary',
    'SUBJECTIVE': 'danger',
    'INDEFINITE_CHOICE': 'warning'
  }
  return tagMap[type] || 'info'
}

// 生命周期
onMounted(() => {
  loadSession()
})

onBeforeUnmount(() => {
  if (timer) {
    clearInterval(timer)
  }
})

// 阻止页面刷新和关闭
window.addEventListener('beforeunload', (e) => {
  e.preventDefault()
  e.returnValue = '考试进行中，确定要离开吗？'
})
</script>

<style scoped>
.exam-paper {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f5f7fa;
}

/* 顶部工具栏 */
.exam-header {
  background: white;
  padding: 15px 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 100;
}

.exam-info {
  display: flex;
  align-items: center;
}

.exam-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

/* 主体内容 */
.exam-content {
  flex: 1;
  display: flex;
  gap: 20px;
  padding: 20px;
  overflow: hidden;
}

/* 左侧题目区域 */
.question-area {
  flex: 1;
  overflow-y: auto;
}

.question-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: bold;
}

.question-content {
  padding: 20px 0;
}

.question-text {
  font-size: 16px;
  line-height: 1.8;
  margin-bottom: 30px;
  color: #303133;
}

.answer-area {
  margin-top: 20px;
}

.answer-option {
  display: flex;
  align-items: flex-start;
  padding: 15px;
  margin-bottom: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  width: 100%;
}

.answer-option:hover {
  border-color: #409eff;
  background-color: #f0f9ff;
}

.option-label {
  font-weight: bold;
  margin-right: 10px;
  color: #409eff;
}

.fill-blank-area {
  padding: 20px;
}

.blank-item {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.blank-label {
  width: 80px;
  font-weight: bold;
  color: #606266;
}

.subjective-area {
  padding: 20px;
}

.question-footer {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

/* 右侧答题卡 */
.answer-sheet {
  width: 280px;
  flex-shrink: 0;
}

.answer-sheet-card {
  position: sticky;
  top: 20px;
  max-height: calc(100vh - 140px);
  overflow-y: auto;
}

.progress-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.progress-item {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.answered-count {
  color: #67c23a;
  font-weight: bold;
}

.unanswered-count {
  color: #f56c6c;
  font-weight: bold;
}

.answer-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
}

.answer-item {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  font-weight: bold;
}

.answer-item:hover {
  border-color: #409eff;
  color: #409eff;
}

.answer-item.is-current {
  background-color: #409eff;
  color: white;
  border-color: #409eff;
}

.answer-item.is-answered {
  background-color: #67c23a;
  color: white;
  border-color: #67c23a;
}

.answer-item.is-current.is-answered {
  background-color: #409eff;
}

/* 响应式 */
@media (max-width: 1200px) {
  .exam-content {
    flex-direction: column;
  }

  .answer-sheet {
    width: 100%;
  }

  .answer-sheet-card {
    position: relative;
    top: 0;
    max-height: none;
  }
}
</style>

