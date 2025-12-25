<template>
  <el-card class="question-card" :body-style="{ padding: '20px' }">
    <!-- 题目头部 -->
    <div class="question-header">
      <div class="question-info">
        <EnumTag
          :model-value="question.questionType"
          :label-map="QUESTION_TYPE_LABELS"
          :type-map="QUESTION_TYPE_COLORS"
          size="small"
        />
        <el-divider direction="vertical" />
        <span class="question-score">{{ question.defaultScore }}分</span>
        <el-divider direction="vertical" />
        <el-rate
          :model-value="question.difficulty"
          disabled
          :max="3"
          :colors="['#67C23A', '#E6A23C', '#F56C6C']"
          size="small"
        />
      </div>
      <div v-if="showActions" class="question-actions">
        <slot name="actions"></slot>
      </div>
    </div>

    <!-- 题目内容 -->
    <div class="question-content" v-html="question.questionContent"></div>

    <!-- 选项（选择题/判断题） -->
    <div
      v-if="showOptions && question.options && question.options.length > 0"
      class="question-options"
    >
      <div
        v-for="option in question.options"
        :key="option.optionId"
        class="option-item"
        :class="{ 'is-correct': showAnswer && option.isCorrect }"
      >
        <span class="option-label">{{ option.optionSeq }}.</span>
        <span class="option-content" v-html="option.optionContent"></span>
        <el-icon v-if="showAnswer && option.isCorrect" class="correct-icon" color="#67c23a">
          <CircleCheck />
        </el-icon>
      </div>
    </div>

    <!-- 答案区域 -->
    <div v-if="showAnswer" class="question-answer">
      <el-divider content-position="left">
        <el-text type="success">参考答案</el-text>
      </el-divider>
      <div class="answer-content">
        <template v-if="question.questionType <= 4">
          <!-- 选择题/判断题答案 -->
          <el-tag
            v-for="optionSeq in correctOptions"
            :key="optionSeq"
            type="success"
            size="small"
            style="margin-right: 8px"
          >
            {{ optionSeq }}
          </el-tag>
        </template>
        <template v-else>
          <!-- 主观题答案 -->
          <div v-html="question.correctAnswer || '无标准答案'"></div>
        </template>
      </div>
    </div>

    <!-- 解析 -->
    <div v-if="showAnswer && question.analysis" class="question-analysis">
      <el-divider content-position="left">
        <el-text type="info">答案解析</el-text>
      </el-divider>
      <div class="analysis-content" v-html="question.analysis"></div>
    </div>
  </el-card>
</template>

<script setup>
import { computed } from 'vue'
import { CircleCheck } from '@element-plus/icons-vue'
import EnumTag from '../common/EnumTag.vue'
import { QUESTION_TYPE_LABELS, QUESTION_TYPE_COLORS } from '@/utils/enums'

/**
 * 题目卡片组件
 * 展示题目详细信息，包括题目内容、选项、答案、解析等
 *
 * @component QuestionCard
 * @example
 * <QuestionCard
 *   :question="questionData"
 *   show-answer
 *   show-actions
 * >
 *   <template #actions>
 *     <el-button size="small">编辑</el-button>
 *   </template>
 * </QuestionCard>
 */
const props = defineProps({
  // 题目数据
  question: {
    type: Object,
    required: true
  },
  // 是否显示选项
  showOptions: {
    type: Boolean,
    default: true
  },
  // 是否显示答案
  showAnswer: {
    type: Boolean,
    default: false
  },
  // 是否显示操作按钮
  showActions: {
    type: Boolean,
    default: false
  }
})

/**
 * 正确选项列表
 */
const correctOptions = computed(() => {
  if (!props.question.options) return []
  return props.question.options
    .filter(opt => opt.isCorrect)
    .map(opt => opt.optionSeq)
})
</script>

<style scoped>
.question-card {
  margin-bottom: 16px;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
}

.question-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.question-score {
  font-size: 14px;
  color: #f56c6c;
  font-weight: 500;
}

.question-actions {
  display: flex;
  gap: 8px;
}

.question-content {
  font-size: 15px;
  line-height: 1.8;
  color: #303133;
  margin-bottom: 16px;
}

.question-options {
  margin: 16px 0;
}

.option-item {
  display: flex;
  align-items: flex-start;
  padding: 12px;
  margin-bottom: 8px;
  background-color: #f5f7fa;
  border-radius: 4px;
  transition: all 0.3s;
}

.option-item:hover {
  background-color: #e9ecf1;
}

.option-item.is-correct {
  background-color: #f0f9ff;
  border: 1px solid #67c23a;
}

.option-label {
  min-width: 30px;
  font-weight: 500;
  color: #606266;
}

.option-content {
  flex: 1;
  color: #303133;
}

.correct-icon {
  margin-left: 8px;
}

.question-answer,
.question-analysis {
  margin-top: 16px;
}

.answer-content,
.analysis-content {
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 4px;
  line-height: 1.8;
}

:deep(.el-divider__text) {
  background-color: #fff;
}
</style>

