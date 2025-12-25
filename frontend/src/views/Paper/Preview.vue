<template>
  <div class="paper-preview-container">
    <!-- 页面头部 -->
    <div class="page-header no-print">
      <el-button @click="goBack">
        <el-icon>
          <ArrowLeft/>
        </el-icon>
        返回
      </el-button>
      <div class="header-title">
        <h2>试卷预览</h2>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="handlePrint">
          <el-icon>
            <Printer/>
          </el-icon>
          打印试卷
        </el-button>
        <el-button type="success" @click="toggleAnswer">
          <el-icon>
            <View/>
          </el-icon>
          {{ showAnswer ? '隐藏答案' : '显示答案' }}
        </el-button>
      </div>
    </div>

    <!-- 试卷内容 -->
    <div class="paper-content" v-loading="loading">
      <!-- 试卷头部信息 -->
      <div class="paper-header">
        <h1 class="paper-title">{{ paper.paperName }}</h1>
        <div class="paper-info-grid">
          <div class="info-item">
            <span class="info-label">总分：</span>
            <span class="info-value">{{ paper.totalScore || 0 }}分</span>
          </div>
          <div class="info-item">
            <span class="info-label">题目数：</span>
            <span class="info-value">{{ paper.questionCount || 0 }}道</span>
          </div>
          <div class="info-item">
            <span class="info-label">及格分：</span>
            <span class="info-value">{{ paper.passScore || 0 }}分</span>
          </div>
          <div class="info-item">
            <span class="info-label">试卷类型：</span>
            <span class="info-value">{{ getPaperTypeName(paper.paperType) }}</span>
          </div>
        </div>
        <div class="paper-desc" v-if="paper.description">
          <div class="desc-title">试卷说明：</div>
          <div class="desc-content">{{ paper.description }}</div>
        </div>
      </div>

      <!-- 题目列表（按题型分组） -->
      <div class="questions-wrapper">
        <!-- 单选题 -->
        <div v-if="questionsByType[1]?.length" class="question-section">
          <div class="section-header">
            <div class="section-title">一、单选题</div>
            <div class="section-info">
              共{{ questionsByType[1].length }}题，
              每题{{ calculateAvgScore(questionsByType[1]) }}分，
              小计{{ calculateTotalScore(questionsByType[1]) }}分
            </div>
          </div>
          <div
              v-for="(question, index) in questionsByType[1]"
              :key="question.questionId"
              class="question-item"
          >
            <div class="question-header">
              <span class="question-number">{{ index + 1 }}.</span>
              <span class="question-score">（{{ question.defaultScore }}分）</span>
            </div>
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
            <div class="question-options" v-if="question.options && question.options.length">
              <div
                  v-for="option in question.options"
                  :key="option.optionId"
                  class="option-item"
                  :class="{ 'correct-answer': showAnswer && option.isCorrect }"
              >
                <span class="option-seq">{{ option.optionSeq }}.</span>
                <span class="option-content">{{ option.optionContent }}</span>
                <el-tag v-if="showAnswer && option.isCorrect" type="success" size="small" class="answer-tag no-print">
                  ✓ 正确答案
                </el-tag>
              </div>
            </div>
            <div v-if="showAnswer" class="answer-section">
              <div v-if="question.correctAnswer" class="correct-answer-text">
                <span class="label">正确答案：</span>
                <span class="value">{{ question.correctAnswer }}</span>
              </div>
              <div v-if="question.answerAnalysis" class="analysis">
                <div class="analysis-title">解析：</div>
                <div class="analysis-content">{{ question.answerAnalysis }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 多选题 -->
        <div v-if="questionsByType[2]?.length" class="question-section">
          <div class="section-header">
            <div class="section-title">二、多选题</div>
            <div class="section-info">
              共{{ questionsByType[2].length }}题，
              每题{{ calculateAvgScore(questionsByType[2]) }}分，
              小计{{ calculateTotalScore(questionsByType[2]) }}分
            </div>
          </div>
          <div
              v-for="(question, index) in questionsByType[2]"
              :key="question.questionId"
              class="question-item"
          >
            <div class="question-header">
              <span class="question-number">{{ index + 1 }}.</span>
              <span class="question-score">（{{ question.defaultScore }}分）</span>
            </div>
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
            <div class="question-options" v-if="question.options && question.options.length">
              <div
                  v-for="option in question.options"
                  :key="option.optionId"
                  class="option-item"
                  :class="{ 'correct-answer': showAnswer && option.isCorrect }"
              >
                <span class="option-seq">{{ option.optionSeq }}.</span>
                <span class="option-content">{{ option.optionContent }}</span>
                <el-tag v-if="showAnswer && option.isCorrect" type="success" size="small" class="answer-tag no-print">
                  ✓ 正确答案
                </el-tag>
              </div>
            </div>
            <div v-if="showAnswer" class="answer-section">
              <div v-if="question.correctAnswer" class="correct-answer-text">
                <span class="label">正确答案：</span>
                <span class="value">{{ question.correctAnswer }}</span>
              </div>
              <div v-if="question.answerAnalysis" class="analysis">
                <div class="analysis-title">解析：</div>
                <div class="analysis-content">{{ question.answerAnalysis }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 判断题 -->
        <div v-if="questionsByType[3]?.length" class="question-section">
          <div class="section-header">
            <div class="section-title">三、判断题</div>
            <div class="section-info">
              共{{ questionsByType[3].length }}题，
              每题{{ calculateAvgScore(questionsByType[3]) }}分，
              小计{{ calculateTotalScore(questionsByType[3]) }}分
            </div>
          </div>
          <div
              v-for="(question, index) in questionsByType[3]"
              :key="question.questionId"
              class="question-item"
          >
            <div class="question-header">
              <span class="question-number">{{ index + 1 }}.</span>
              <span class="question-score">（{{ question.defaultScore }}分）</span>
            </div>
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
            <div class="question-options" v-if="question.options && question.options.length">
              <div
                  v-for="option in question.options"
                  :key="option.optionId"
                  class="option-item"
                  :class="{ 'correct-answer': showAnswer && option.isCorrect }"
              >
                <span class="option-seq">{{ option.optionSeq }}.</span>
                <span class="option-content">{{ option.optionContent }}</span>
                <el-tag v-if="showAnswer && option.isCorrect" type="success" size="small" class="answer-tag no-print">
                  ✓ 正确答案
                </el-tag>
              </div>
            </div>
            <div v-if="showAnswer" class="answer-section">
              <div v-if="question.correctAnswer" class="correct-answer-text">
                <span class="label">正确答案：</span>
                <span class="value">{{ question.correctAnswer }}</span>
              </div>
              <div v-if="question.answerAnalysis" class="analysis">
                <div class="analysis-title">解析：</div>
                <div class="analysis-content">{{ question.answerAnalysis }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 填空题 -->
        <div v-if="questionsByType[4]?.length" class="question-section">
          <div class="section-header">
            <div class="section-title">四、填空题</div>
            <div class="section-info">
              共{{ questionsByType[4].length }}题，
              每题{{ calculateAvgScore(questionsByType[4]) }}分，
              小计{{ calculateTotalScore(questionsByType[4]) }}分
            </div>
          </div>
          <div
              v-for="(question, index) in questionsByType[4]"
              :key="question.questionId"
              class="question-item"
          >
            <div class="question-header">
              <span class="question-number">{{ index + 1 }}.</span>
              <span class="question-score">（{{ question.defaultScore }}分）</span>
            </div>
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
            <div class="answer-input-line"></div>
            <div v-if="showAnswer" class="answer-section">
              <div v-if="question.correctAnswer" class="correct-answer-text">
                <span class="label">参考答案：</span>
                <span class="value">{{ question.correctAnswer }}</span>
              </div>
              <div v-if="question.answerAnalysis" class="analysis">
                <div class="analysis-title">解析：</div>
                <div class="analysis-content">{{ question.answerAnalysis }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 简答题 -->
        <div v-if="questionsByType[5]?.length" class="question-section">
          <div class="section-header">
            <div class="section-title">五、简答题</div>
            <div class="section-info">
              共{{ questionsByType[5].length }}题，
              每题{{ calculateAvgScore(questionsByType[5]) }}分，
              小计{{ calculateTotalScore(questionsByType[5]) }}分
            </div>
          </div>
          <div
              v-for="(question, index) in questionsByType[5]"
              :key="question.questionId"
              class="question-item"
          >
            <div class="question-header">
              <span class="question-number">{{ index + 1 }}.</span>
              <span class="question-score">（{{ question.defaultScore }}分）</span>
            </div>
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
            <div class="answer-area"></div>
            <div v-if="showAnswer" class="answer-section">
              <div v-if="question.correctAnswer" class="correct-answer-text">
                <span class="label">参考答案：</span>
                <div class="value" v-html="formatContent(question.correctAnswer)"></div>
              </div>
              <div v-if="question.answerAnalysis" class="analysis">
                <div class="analysis-title">解析：</div>
                <div class="analysis-content">{{ question.answerAnalysis }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 无题目提示 -->
        <el-empty v-if="!paper.questions || paper.questions.length === 0" description="该试卷暂无题目"/>
      </div>
    </div>
  </div>
</template>

<script setup>
import {computed, onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {ElMessage} from 'element-plus'
import {ArrowLeft, Printer, View} from '@element-plus/icons-vue'
import paperApi from '@/api/paper'
import {getPaperTypeName} from '@/utils/enums'

const route = useRoute()
const router = useRouter()

// 状态
const loading = ref(false)
const paper = ref({})
const showAnswer = ref(false)

// 按题型分组的题目
const questionsByType = computed(() => {
  if (!paper.value.questions) return {}

  return paper.value.questions.reduce((acc, question) => {
    const type = question.questionType
    if (!acc[type]) {
      acc[type] = []
    }
    acc[type].push(question)
    return acc
  }, {})
})

// 计算题型的平均分数
const calculateAvgScore = (questions) => {
  if (!questions || questions.length === 0) return 0
  const total = questions.reduce((sum, q) => sum + (q.defaultScore || 0), 0)
  return (total / questions.length).toFixed(1)
}

// 计算题型的总分
const calculateTotalScore = (questions) => {
  if (!questions || questions.length === 0) return 0
  return questions.reduce((sum, q) => sum + (q.defaultScore || 0), 0).toFixed(1)
}

// 格式化内容（处理换行等）
const formatContent = (content) => {
  if (!content) return ''
  return content.replace(/\n/g, '<br>')
}

// 加载试卷详情
const loadPaperDetail = async () => {
  loading.value = true
  try {
    const paperId = route.params.id
    if (!paperId) {
      ElMessage.error('试卷ID不存在')
      router.back()
      return
    }

    // 使用getById接口获取完整数据（包含答案）
    const res = await paperApi.getById(paperId)
    if (res.code === 200 && res.data) {
      paper.value = res.data
    } else {
      ElMessage.error(res.message || '加载失败')
      router.back()
    }
  } catch (error) {
    console.error('加载试卷失败:', error)
    ElMessage.error('加载失败')
    router.back()
  } finally {
    loading.value = false
  }
}

// 返回
const goBack = () => {
  router.back()
}

// 切换答案显示
const toggleAnswer = () => {
  showAnswer.value = !showAnswer.value
  if (showAnswer.value) {
    ElMessage.success('答案已显示')
  } else {
    ElMessage.info('答案已隐藏')
  }
}

// 打印试卷
const handlePrint = () => {
  // 打印时隐藏答案
  const originalShowAnswer = showAnswer.value
  showAnswer.value = false

  // 延迟打印，确保DOM更新
  setTimeout(() => {
    window.print()
    // 打印后恢复答案显示状态
    showAnswer.value = originalShowAnswer
  }, 100)
}

onMounted(() => {
  loadPaperDetail()
})
</script>

<style scoped>
.paper-preview-container {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 15px 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.header-title h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.paper-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 50px 60px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.paper-header {
  padding-bottom: 30px;
  border-bottom: 2px solid #e4e7ed;
  margin-bottom: 40px;
}

.paper-title {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  margin: 0 0 20px 0;
  text-align: center;
  line-height: 1.4;
}

.paper-info-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  margin: 20px 0;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 6px;
}

.info-item {
  text-align: center;
}

.info-label {
  font-size: 13px;
  color: #909399;
  display: block;
  margin-bottom: 5px;
}

.info-value {
  font-size: 16px;
  font-weight: 600;
  color: #409eff;
}

.paper-desc {
  margin-top: 20px;
  padding: 15px;
  background: #fef0f0;
  border-left: 4px solid #f56c6c;
  border-radius: 4px;
}

.desc-title {
  font-size: 14px;
  font-weight: bold;
  color: #f56c6c;
  margin-bottom: 8px;
}

.desc-content {
  font-size: 14px;
  color: #606266;
  line-height: 1.8;
}

.questions-wrapper {
  margin-top: 30px;
}

.question-section {
  margin-bottom: 50px;
  page-break-inside: avoid;
}

.section-header {
  margin-bottom: 25px;
}

.section-title {
  font-size: 20px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
  padding-bottom: 10px;
  border-bottom: 3px solid #409eff;
  display: inline-block;
  min-width: 150px;
}

.section-info {
  font-size: 13px;
  color: #909399;
  margin-top: 8px;
}

.question-item {
  margin-bottom: 35px;
  padding: 25px;
  background: #fafbfc;
  border-radius: 6px;
  border-left: 4px solid #409eff;
  page-break-inside: avoid;
}

.question-header {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.question-number {
  font-size: 17px;
  font-weight: bold;
  color: #303133;
  margin-right: 10px;
}

.question-score {
  font-size: 14px;
  color: #909399;
  font-weight: 500;
}

.question-content {
  font-size: 16px;
  line-height: 2;
  color: #303133;
  margin-bottom: 18px;
  padding-left: 5px;
}

.question-options {
  margin-left: 10px;
  margin-top: 15px;
}

.option-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 15px;
  margin-bottom: 10px;
  background: white;
  border-radius: 6px;
  border: 1.5px solid #e4e7ed;
  transition: all 0.3s;
}

.option-item.correct-answer {
  background: #f0f9ff;
  border-color: #67c23a;
  box-shadow: 0 2px 6px rgba(103, 194, 58, 0.2);
}

.option-seq {
  font-weight: 600;
  color: #606266;
  margin-right: 12px;
  min-width: 25px;
}

.option-content {
  flex: 1;
  color: #303133;
  line-height: 1.6;
}

.answer-tag {
  margin-left: 10px;
  font-weight: 500;
}

.answer-input-line {
  margin: 20px 0;
  height: 40px;
  border-bottom: 1px solid #dcdfe6;
}

.answer-area {
  margin: 20px 0;
  min-height: 150px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background: #fafafa;
}

.answer-section {
  margin-top: 20px;
  padding: 18px;
  background: #ecf5ff;
  border-radius: 6px;
  border-left: 4px solid #409eff;
}

.correct-answer-text {
  margin-bottom: 12px;
}

.correct-answer-text .label {
  font-size: 14px;
  font-weight: bold;
  color: #409eff;
}

.correct-answer-text .value {
  font-size: 15px;
  color: #303133;
  font-weight: 600;
  margin-left: 8px;
}

.analysis {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed #c0c4cc;
}

.analysis-title {
  font-size: 14px;
  font-weight: bold;
  color: #67c23a;
  margin-bottom: 8px;
}

.analysis-content {
  font-size: 14px;
  line-height: 1.8;
  color: #606266;
}

/* 打印样式 */
@media print {
  .no-print {
    display: none !important;
  }

  .paper-preview-container {
    background: white;
    padding: 0;
  }

  .paper-content {
    box-shadow: none;
    padding: 20mm;
    max-width: 100%;
  }

  .paper-title {
    font-size: 24pt;
  }

  .question-item {
    page-break-inside: avoid;
    background: white;
    border: none;
    padding: 10px 0;
  }

  .option-item {
    border: none;
    background: transparent;
    padding: 5px 0;
  }

  .section-title {
    page-break-after: avoid;
  }

  /* 打印时隐藏答案 */
  .answer-section {
    display: none !important;
  }

  .correct-answer {
    background: white !important;
    border-color: #e4e7ed !important;
  }
}
</style>
