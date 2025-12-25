<template>
  <div class="student-exam-page">
    <!-- 顶部导航栏 -->
    <div class="exam-header">
      <div class="header-left">
        <h2>{{ examInfo.examName }}</h2>
        <el-tag>{{ examInfo.paperName }}</el-tag>
      </div>
      <div class="header-right">
        <div class="timer">
          <el-icon><Clock /></el-icon>
          <span>剩余时间：{{ formatTime(remainingTime) }}</span>
        </div>
        <el-button type="primary" @click="handleSubmit">
          提交试卷
        </el-button>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="exam-content">
      <!-- 左侧题目区域 -->
      <div class="question-area">
        <el-scrollbar height="calc(100vh - 120px)">
          <div v-if="currentQuestion" class="question-card">
            <!-- 题目信息 -->
            <div class="question-header">
              <span class="question-number">
                第 {{ currentQuestionIndex + 1 }} 题
              </span>
              <el-tag :type="getDifficultyType(currentQuestion.difficulty)">
                {{ getDifficultyText(currentQuestion.difficulty) }}
              </el-tag>
              <el-tag>{{ currentQuestion.defaultScore }} 分</el-tag>
              <el-button
                link
                :type="isMarked(currentQuestion.questionId) ? 'warning' : 'info'"
                @click="toggleMark(currentQuestion.questionId)"
              >
                <el-icon><Star /></el-icon>
                {{ isMarked(currentQuestion.questionId) ? '已标记' : '标记' }}
              </el-button>
            </div>

            <!-- 题目内容 -->
            <div class="question-content" v-html="currentQuestion.questionContent"></div>

            <!-- 答题区域 -->
            <div class="answer-area">
              <!-- 单选题 -->
              <el-radio-group
                v-if="currentQuestion.questionType.code === 1"
                v-model="currentAnswer.optionIds"
                @change="handleAnswerChange"
              >
                <el-radio
                  v-for="option in currentQuestion.options"
                  :key="option.optionId"
                  :value="String(option.optionId)"
                  class="option-item"
                >
                  <span class="option-label">{{ option.optionSeq }}.</span>
                  <span v-html="option.optionContent"></span>
                </el-radio>
              </el-radio-group>

              <!-- 多选题 -->
              <el-checkbox-group
                v-else-if="currentQuestion.questionType.code === 2"
                v-model="selectedOptions"
                @change="handleMultipleChoiceChange"
              >
                <el-checkbox
                  v-for="option in currentQuestion.options"
                  :key="option.optionId"
                  :value="option.optionId"
                  class="option-item"
                >
                  <span class="option-label">{{ option.optionSeq }}.</span>
                  <span v-html="option.optionContent"></span>
                </el-checkbox>
              </el-checkbox-group>

              <!-- 判断题 -->
              <el-radio-group
                v-else-if="currentQuestion.questionType.code === 3"
                v-model="currentAnswer.optionIds"
                @change="handleAnswerChange"
              >
                <el-radio value="true" class="option-item">正确</el-radio>
                <el-radio value="false" class="option-item">错误</el-radio>
              </el-radio-group>

              <!-- 填空题 -->
              <el-input
                v-else-if="currentQuestion.questionType.code === 4"
                v-model="currentAnswer.userAnswer"
                type="textarea"
                :rows="4"
                placeholder="请输入答案"
                @change="handleAnswerChange"
              />

              <!-- 主观题 -->
              <el-input
                v-else-if="currentQuestion.questionType.code === 5"
                v-model="currentAnswer.userAnswer"
                type="textarea"
                :rows="8"
                placeholder="请输入答案"
                @change="handleAnswerChange"
              />
            </div>

            <!-- 题目导航按钮 -->
            <div class="question-nav">
              <el-button
                :disabled="currentQuestionIndex === 0"
                @click="previousQuestion"
              >
                上一题
              </el-button>
              <el-button
                :disabled="currentQuestionIndex === questions.length - 1"
                @click="nextQuestion"
              >
                下一题
              </el-button>
            </div>
          </div>
        </el-scrollbar>
      </div>

      <!-- 右侧答题卡 -->
      <div class="answer-card">
        <div class="card-title">答题卡</div>
        <div class="card-stats">
          <div class="stat-item">
            <span class="label">已答：</span>
            <span class="value">{{ answeredCount }}</span>
          </div>
          <div class="stat-item">
            <span class="label">未答：</span>
            <span class="value">{{ unansweredCount }}</span>
          </div>
          <div class="stat-item">
            <span class="label">标记：</span>
            <span class="value">{{ markedCount }}</span>
          </div>
        </div>

        <el-scrollbar height="calc(100vh - 280px)">
          <div class="question-grid">
            <div
              v-for="(q, index) in questions"
              :key="q.questionId"
              class="grid-item"
              :class="{
                'is-current': index === currentQuestionIndex,
                'is-answered': isAnswered(q.questionId),
                'is-marked': isMarked(q.questionId)
              }"
              @click="goToQuestion(index)"
            >
              {{ index + 1 }}
            </div>
          </div>
        </el-scrollbar>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Clock, Star } from '@element-plus/icons-vue'
import studentExamApi from '@/api/studentExam'
import paperApi from '@/api/paper'

const route = useRoute()
const router = useRouter()

// 数据
const examId = ref(route.params.examId)
const sessionId = ref(null)
const examInfo = ref({})
const questions = ref([])
const answers = ref({}) // 所有答案的映射 { questionId: answer }
const markedQuestions = ref(new Set()) // 标记的题目ID
const currentQuestionIndex = ref(0)
const remainingTime = ref(0) // 剩余秒数
const selectedOptions = ref([]) // 多选题临时选项

let timer = null
let heartbeatTimer = null

// 当前题目
const currentQuestion = computed(() => {
  return questions.value[currentQuestionIndex.value]
})

// 当前答案
const currentAnswer = computed(() => {
  if (!currentQuestion.value) return {}

  const questionId = currentQuestion.value.questionId
  if (!answers.value[questionId]) {
    answers.value[questionId] = {
      sessionId: sessionId.value,
      examId: examId.value,
      questionId: questionId,
      bankId: currentQuestion.value.bankId,
      userId: null, // TODO: 从store获取
      optionIds: '',
      userAnswer: '',
      answerOrder: '',
      isMarked: 0
    }
  }
  return answers.value[questionId]
})

// 统计
const answeredCount = computed(() => {
  return Object.values(answers.value).filter(a =>
    a.optionIds || a.userAnswer
  ).length
})

const unansweredCount = computed(() => {
  return questions.value.length - answeredCount.value
})

const markedCount = computed(() => {
  return markedQuestions.value.size
})

// 开始考试
const startExam = async () => {
  try {
    const res = await studentExamApi.startExam(examId.value)
    if (res.code === 200 && res.data) {
      sessionId.value = res.data.sessionId
      examInfo.value = res.data
      loadPaperQuestions()
      loadAnswers()
      startTimer()
      startHeartbeat()
    } else {
      ElMessage.error(res.message || '开始考试失败')
      router.back()
    }
  } catch (error) {
    console.error('开始考试失败:', error)
    ElMessage.error('开始考试失败')
    router.back()
  }
}

// 加载试卷题目
const loadPaperQuestions = async () => {
  try {
    const res = await paperApi.getDetail(examInfo.value.paperId)
    if (res.code === 200 && res.data) {
      questions.value = res.data.questions || []
    }
  } catch (error) {
    console.error('加载题目失败:', error)
    ElMessage.error('加载题目失败')
  }
}

// 加载已有答案
const loadAnswers = async () => {
  try {
    const res = await studentExamApi.getAnswers(sessionId.value)
    if (res.code === 200 && res.data) {
      res.data.forEach(answer => {
        answers.value[answer.questionId] = answer
        if (answer.isMarked === 1) {
          markedQuestions.value.add(answer.questionId)
        }
      })

      // 恢复多选题选项
      if (currentAnswer.value.optionIds) {
        selectedOptions.value = currentAnswer.value.optionIds
          .split(',')
          .filter(id => id)
          .map(id => parseInt(id))
      }
    }
  } catch (error) {
    console.error('加载答案失败:', error)
  }
}

// 答案变更处理
const handleAnswerChange = () => {
  saveAnswer()
}

// 多选题答案变更
const handleMultipleChoiceChange = () => {
  currentAnswer.value.optionIds = selectedOptions.value.join(',')
  saveAnswer()
}

// 保存答案
const saveAnswer = async () => {
  try {
    await studentExamApi.saveAnswer(sessionId.value, currentAnswer.value)
  } catch (error) {
    console.error('保存答案失败:', error)
  }
}

// 标记/取消标记
const toggleMark = (questionId) => {
  if (markedQuestions.value.has(questionId)) {
    markedQuestions.value.delete(questionId)
    if (answers.value[questionId]) {
      answers.value[questionId].isMarked = 0
    }
  } else {
    markedQuestions.value.add(questionId)
    if (answers.value[questionId]) {
      answers.value[questionId].isMarked = 1
    }
  }
  saveAnswer()
}

// 是否已答
const isAnswered = (questionId) => {
  const answer = answers.value[questionId]
  return answer && (answer.optionIds || answer.userAnswer)
}

// 是否已标记
const isMarked = (questionId) => {
  return markedQuestions.value.has(questionId)
}

// 上一题
const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
    updateSelectedOptions()
  }
}

// 下一题
const nextQuestion = () => {
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++
    updateSelectedOptions()
  }
}

// 跳转到指定题目
const goToQuestion = (index) => {
  currentQuestionIndex.value = index
  updateSelectedOptions()
}

// 更新多选题选项
const updateSelectedOptions = () => {
  if (currentQuestion.value && currentQuestion.value.questionType.code === 2) {
    const answer = currentAnswer.value
    selectedOptions.value = answer.optionIds
      ? answer.optionIds.split(',').filter(id => id).map(id => parseInt(id))
      : []
  }
}

// 提交试卷
const handleSubmit = async () => {
  try {
    await ElMessageBox.confirm(
      `您还有 ${unansweredCount.value} 道题未作答，确定要提交试卷吗？`,
      '提交确认',
      {
        type: 'warning',
        confirmButtonText: '确定提交',
        cancelButtonText: '继续答题'
      }
    )

    const res = await studentExamApi.submitExam(sessionId.value)
    if (res.code === 200) {
      ElMessage.success('提交成功')
      stopTimer()
      stopHeartbeat()
      router.push({ name: 'ExamResult', params: { sessionId: sessionId.value } })
    } else {
      ElMessage.error(res.message || '提交失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('提交失败:', error)
      ElMessage.error('提交失败')
    }
  }
}

// 启动倒计时
const startTimer = () => {
  // TODO: 从服务器获取剩余时间
  remainingTime.value = 3600 // 临时设置为60分钟

  timer = setInterval(() => {
    if (remainingTime.value > 0) {
      remainingTime.value--
    } else {
      // 时间到，自动提交
      ElMessage.warning('考试时间已到，正在自动提交...')
      handleSubmit()
    }
  }, 1000)
}

// 停止倒计时
const stopTimer = () => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

// 启动心跳
const startHeartbeat = () => {
  heartbeatTimer = setInterval(() => {
    studentExamApi.heartbeat(sessionId.value).catch(err => {
      console.error('心跳失败:', err)
    })
  }, 30000) // 30秒一次
}

// 停止心跳
const stopHeartbeat = () => {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }
}

// 格式化时间
const formatTime = (seconds) => {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const secs = seconds % 60
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
}

// 获取难度类型
const getDifficultyType = (difficulty) => {
  const types = { 1: 'success', 2: '', 3: 'warning', 4: 'danger' }
  return types[difficulty] || ''
}

// 获取难度文本
const getDifficultyText = (difficulty) => {
  const texts = { 1: '简单', 2: '中等', 3: '困难', 4: '非常困难' }
  return texts[difficulty] || '未知'
}

// 监听切屏（防作弊）
const handleVisibilityChange = () => {
  if (document.hidden) {
    studentExamApi.recordTabSwitch(sessionId.value).then(res => {
      if (res.code === 200) {
        ElMessage.warning(`检测到切屏行为，已记录（${res.data}/${examInfo.value.cutScreenLimit}）`)
      }
    }).catch(err => {
      console.error('记录切屏失败:', err)
    })
  }
}

// 初始化
onMounted(() => {
  startExam()
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

// 清理
onBeforeUnmount(() => {
  stopTimer()
  stopHeartbeat()
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})
</script>

<style scoped lang="scss">
.student-exam-page {
  height: 100vh;
  background-color: #f5f5f5;

  .exam-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 24px;
    background-color: white;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

    .header-left {
      display: flex;
      align-items: center;
      gap: 12px;

      h2 {
        margin: 0;
        font-size: 20px;
      }
    }

    .header-right {
      display: flex;
      align-items: center;
      gap: 20px;

      .timer {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 16px;
        font-weight: 500;
        color: #e6a23c;
      }
    }
  }

  .exam-content {
    display: flex;
    height: calc(100vh - 80px);
    gap: 16px;
    padding: 16px;

    .question-area {
      flex: 1;
      background-color: white;
      border-radius: 8px;
      padding: 24px;

      .question-card {
        .question-header {
          display: flex;
          align-items: center;
          gap: 12px;
          margin-bottom: 20px;
          padding-bottom: 12px;
          border-bottom: 1px solid #e0e0e0;

          .question-number {
            font-size: 18px;
            font-weight: 600;
          }
        }

        .question-content {
          font-size: 16px;
          line-height: 1.8;
          margin-bottom: 24px;
        }

        .answer-area {
          margin-bottom: 24px;

          .option-item {
            display: flex;
            align-items: flex-start;
            padding: 12px;
            margin-bottom: 12px;
            border-radius: 6px;
            border: 1px solid #e0e0e0;
            transition: all 0.3s;

            &:hover {
              background-color: #f5f7fa;
              border-color: #409eff;
            }

            .option-label {
              font-weight: 600;
              margin-right: 8px;
            }
          }
        }

        .question-nav {
          display: flex;
          justify-content: center;
          gap: 16px;
        }
      }
    }

    .answer-card {
      width: 280px;
      background-color: white;
      border-radius: 8px;
      padding: 24px;

      .card-title {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 16px;
      }

      .card-stats {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-bottom: 20px;
        padding: 16px;
        background-color: #f5f7fa;
        border-radius: 6px;

        .stat-item {
          display: flex;
          justify-content: space-between;

          .label {
            color: #606266;
          }

          .value {
            font-weight: 600;
            color: #409eff;
          }
        }
      }

      .question-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 8px;

        .grid-item {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 40px;
          height: 40px;
          border-radius: 4px;
          border: 1px solid #dcdfe6;
          cursor: pointer;
          transition: all 0.3s;

          &:hover {
            border-color: #409eff;
            color: #409eff;
          }

          &.is-current {
            background-color: #409eff;
            color: white;
            border-color: #409eff;
          }

          &.is-answered {
            background-color: #67c23a;
            color: white;
            border-color: #67c23a;
          }

          &.is-marked {
            border-color: #e6a23c;
            color: #e6a23c;
            position: relative;

            &::after {
              content: '';
              position: absolute;
              top: 0;
              right: 0;
              width: 0;
              height: 0;
              border-style: solid;
              border-width: 0 8px 8px 0;
              border-color: transparent #e6a23c transparent transparent;
            }
          }
        }
      }
    }
  }
}
</style>

