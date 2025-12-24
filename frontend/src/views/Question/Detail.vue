<template>
  <div class="question-detail-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <div class="header-title">
        <h2>题目详情</h2>
        <el-tag :type="getQuestionTypeColor(question.questionType)">
          {{ getQuestionTypeName(question.questionType) }}
        </el-tag>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="handleEdit">编辑</el-button>
        <el-button type="danger" @click="handleDelete">删除</el-button>
      </div>
    </div>

    <!-- 加载状态 -->
    <el-card v-loading="loading" class="detail-card">
      <template v-if="!loading && question.questionId">
        <!-- 基本信息 -->
        <div class="info-section">
          <h3>基本信息</h3>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="题目ID">
              {{ question.questionId }}
            </el-descriptions-item>
            <el-descriptions-item label="题目类型">
              <el-tag :type="getQuestionTypeColor(question.questionType)">
                {{ question.questionTypeName || getQuestionTypeName(question.questionType) || '未知' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="所属题库">
              {{ question.bankName || '未知' }}
            </el-descriptions-item>
            <el-descriptions-item label="难度">
              <el-rate
                :model-value="question.difficulty || 0"
                :max="3"
                disabled
              />
              <span style="margin-left: 10px;">
                {{ question.difficultyName || getDifficultyName(question.difficulty) || '未知' }}
              </span>
            </el-descriptions-item>
            <el-descriptions-item label="分值">
              {{ question.defaultScore || 0 }} 分
            </el-descriptions-item>
            <el-descriptions-item label="审核状态">
              <el-tag :type="getAuditStatusColor(question.auditStatus)">
                {{ question.auditStatusName || getAuditStatusName(question.auditStatus) || '未知' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">
              {{ question.createTime || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="更新时间">
              {{ question.updateTime || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 题目内容 -->
        <div class="info-section">
          <h3>题目内容</h3>
          <el-card class="content-card">
            <div class="question-content" v-html="formatContent(question.questionContent)"></div>
          </el-card>
        </div>

        <!-- 选项（选择题和判断题） -->
        <div
          v-if="[QUESTION_TYPE.SINGLE_CHOICE, QUESTION_TYPE.MULTIPLE_CHOICE, QUESTION_TYPE.TRUE_FALSE].includes(question.questionType)"
          class="info-section"
        >
          <h3>题目选项</h3>
          <el-card class="options-card">
            <div
              v-for="(option, index) in question.options"
              :key="index"
              class="option-item"
              :class="{ 'correct-option': option.isCorrect === 1 }"
            >
              <div class="option-label">
                <el-tag v-if="option.isCorrect === 1" type="success" size="small">正确答案</el-tag>
                <span class="label">{{ option.optionSeq }}.</span>
              </div>
              <div class="option-content">{{ option.optionContent }}</div>
            </div>
          </el-card>
        </div>

        <!-- 参考答案（填空题和简答题） -->
        <div
          v-if="[QUESTION_TYPE.FILL_BLANK, QUESTION_TYPE.SUBJECTIVE].includes(question.questionType)"
          class="info-section"
        >
          <h3>参考答案</h3>
          <el-card class="answer-card">
            <div class="answer-content">{{ question.correctAnswer || '暂无参考答案' }}</div>
          </el-card>
        </div>

        <!-- 题目解析 -->
        <div v-if="question.analysis" class="info-section">
          <h3>题目解析</h3>
          <el-card class="analysis-card">
            <div class="analysis-content" v-html="formatContent(question.analysis)"></div>
          </el-card>
        </div>

        <!-- 关联知识点 -->
        <div v-if="question.knowledgePoints && question.knowledgePoints.length > 0" class="info-section">
          <h3>关联知识点</h3>
          <el-card class="knowledge-card">
            <el-tag
              v-for="point in question.knowledgePoints"
              :key="point.id"
              style="margin-right: 10px"
            >
              {{ point.name }}
            </el-tag>
          </el-card>
        </div>

        <!-- 使用记录 -->
        <div class="info-section">
          <h3>使用记录</h3>
          <el-card class="usage-card">
            <el-empty v-if="!usageRecords || usageRecords.length === 0" description="该题目暂未被使用" />
            <el-table v-else :data="usageRecords" style="width: 100%">
              <el-table-column prop="paperName" label="试卷名称" />
              <el-table-column prop="examName" label="考试名称" />
              <el-table-column prop="useCount" label="使用次数" width="100" />
              <el-table-column prop="useTime" label="使用时间" width="180" />
            </el-table>
          </el-card>
        </div>
      </template>

      <!-- 无数据 -->
      <el-empty v-else-if="!loading" description="题目不存在或已被删除" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import questionApi from '@/api/question'
import {
  QUESTION_TYPE,
  getQuestionTypeName,
  getQuestionTypeColor,
  getAuditStatusName,
  getAuditStatusColor
} from '@/utils/enums'

const route = useRoute()
const router = useRouter()

// 状态
const loading = ref(false)
const question = ref({})
const usageRecords = ref([])

// 获取难度名称
const getDifficultyName = (difficulty) => {
  if (!difficulty) return '未知'
  const difficultyMap = {
    1: '简单',
    2: '中等',
    3: '困难'
  }
  return difficultyMap[difficulty] || '未知'
}

// 加载题目详情
const loadQuestionDetail = async () => {
  loading.value = true
  try {
    const questionId = route.params.id
    console.log('[Detail] 加载题目详情，ID:', questionId)

    const res = await questionApi.getById(questionId)
    console.log('[Detail] 题目详情响应:', res)

    if (res.code === 200) {
      question.value = res.data
      console.log('[Detail] 题目数据:', question.value)
      console.log('[Detail] 选项数据:', question.value.options)

      // TODO: 加载使用记录
      // loadUsageRecords(questionId)
    } else {
      ElMessage.error(res.message || '加载失败')
    }
  } catch (error) {
    console.error('[Detail] 加载失败:', error)
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// 返回
const goBack = () => {
  router.back()
}

// 编辑
const handleEdit = () => {
  // 回到题目列表页，触发编辑对话框
  router.push({ name: 'Question', query: { edit: question.value.questionId } })
}

// 删除
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目"${question.value.questionContent.substring(0, 20)}..."吗？`,
      '警告',
      { type: 'warning' }
    )

    console.log('开始删除题目，ID:', question.value.questionId)
    const res = await questionApi.deleteById(question.value.questionId)
    console.log('删除响应:', res)

    if (res && res.code === 200) {
      ElMessage.success('删除成功')
      // 延迟返回，确保消息显示
      setTimeout(() => {
        router.back()
      }, 500)
    } else {
      // 处理失败情况
      const errorMsg = res?.message || res?.msg || '删除失败'
      console.error('删除失败:', errorMsg, res)
      ElMessage.error(errorMsg)
    }
  } catch (error) {
    // 区分用户取消和真实错误
    if (error === 'cancel') {
      console.log('用户取消删除')
    } else {
      console.error('删除异常:', error)
      const errorMsg = error?.response?.data?.message || error?.message || '删除失败'
      ElMessage.error(errorMsg)
    }
  }
}

// 格式化内容（处理换行等）
const formatContent = (content) => {
  if (!content) return ''
  return content.replace(/\n/g, '<br/>')
}


// 初始化
onMounted(() => {
  loadQuestionDetail()
})
</script>

<style scoped>
.question-detail-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-title {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 15px;
  margin-left: 20px;
}

.header-title h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.detail-card {
  margin-bottom: 20px;
}

.info-section {
  margin-bottom: 30px;
}

.info-section:last-child {
  margin-bottom: 0;
}

.info-section h3 {
  margin: 0 0 15px 0;
  font-size: 18px;
  font-weight: 500;
  color: #303133;
  border-left: 4px solid #409eff;
  padding-left: 10px;
}

.content-card,
.options-card,
.answer-card,
.analysis-card,
.knowledge-card,
.usage-card {
  background: #f5f7fa;
}

.question-content,
.analysis-content {
  line-height: 1.8;
  font-size: 15px;
  color: #303133;
}

.option-item {
  display: flex;
  align-items: flex-start;
  padding: 15px;
  margin-bottom: 10px;
  background: #fff;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  transition: all 0.3s;
}

.option-item:last-child {
  margin-bottom: 0;
}

.option-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.1);
}

.correct-option {
  border-color: #67c23a;
  background: #f0f9ff;
}

.option-label {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 80px;
  font-weight: 600;
  color: #409eff;
}

.correct-option .option-label {
  color: #67c23a;
}

.option-label .label {
  font-size: 16px;
}

.option-content {
  flex: 1;
  line-height: 1.6;
  color: #606266;
}

.answer-content {
  line-height: 1.8;
  font-size: 15px;
  color: #303133;
  white-space: pre-wrap;
}
</style>
