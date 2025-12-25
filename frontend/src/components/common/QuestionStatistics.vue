<template>
  <div class="question-statistics">
    <!-- 题型统计 -->
    <el-card class="stats-card">
      <template #header>
        <div class="card-header">
          <el-icon><DataAnalysis /></el-icon>
          <span>题型分布</span>
        </div>
      </template>

      <div class="stat-item total">
        <div class="stat-label">
          <el-icon><Collection /></el-icon>
          题目总数
        </div>
        <div class="stat-value primary">{{ totalCount }}</div>
      </div>

      <el-divider />

      <div v-for="item in typeStatistics" :key="item.type" class="stat-item">
        <div class="stat-label">
          <EnumTag
            :model-value="item.type"
            :label-map="QUESTION_TYPE_LABELS"
            :type-map="QUESTION_TYPE_COLORS"
            size="small"
          />
        </div>
        <div class="stat-value">
          {{ item.count }}
          <span class="unit">道</span>
        </div>
      </div>
    </el-card>

    <!-- 难度分布 -->
    <el-card class="stats-card" style="margin-top: 16px">
      <template #header>
        <div class="card-header">
          <el-icon><TrendCharts /></el-icon>
          <span>难度分布</span>
        </div>
      </template>

      <div v-for="item in difficultyStatistics" :key="item.level" class="stat-item">
        <div class="stat-label">
          <el-rate
            :model-value="item.level"
            :max="3"
            disabled
            size="small"
            :colors="['#67C23A', '#E6A23C', '#F56C6C']"
          />
          <span style="margin-left: 8px">{{ getDifficultyName(item.level) }}</span>
        </div>
        <div class="stat-value" :class="getDifficultyClass(item.level)">
          {{ item.count }}
          <span class="unit">道</span>
        </div>
      </div>

      <!-- 难度分布图表（可选） -->
      <div v-if="showChart" class="difficulty-chart">
        <el-progress
          v-for="item in difficultyStatistics"
          :key="item.level"
          :percentage="calculatePercentage(item.count)"
          :color="getDifficultyColor(item.level)"
          :format="() => `${item.count}道`"
          style="margin-bottom: 12px"
        />
      </div>
    </el-card>

    <!-- 审核状态（可选） -->
    <el-card v-if="showAuditStatus" class="stats-card" style="margin-top: 16px">
      <template #header>
        <div class="card-header">
          <el-icon><Check /></el-icon>
          <span>审核状态</span>
        </div>
      </template>

      <div v-for="item in auditStatistics" :key="item.status" class="stat-item">
        <div class="stat-label">
          <EnumTag
            :model-value="item.status"
            :label-map="AUDIT_STATUS_LABELS"
            :type-map="AUDIT_STATUS_COLORS"
            size="small"
          />
        </div>
        <div class="stat-value" :class="getAuditStatusClass(item.status)">
          {{ item.count }}
          <span class="unit">道</span>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { DataAnalysis, TrendCharts, Check, Collection } from '@element-plus/icons-vue'
import { EnumTag } from '@/components/common'
import {
  QUESTION_TYPE,
  QUESTION_TYPE_LABELS,
  QUESTION_TYPE_COLORS,
  DIFFICULTY_LEVEL,
  DIFFICULTY_LABELS,
  AUDIT_STATUS,
  AUDIT_STATUS_LABELS,
  AUDIT_STATUS_COLORS,
  getDifficultyName
} from '@/utils/enums'

/**
 * 题目统计组件
 * 用于展示题型分布、难度分布、审核状态等统计信息
 *
 * @component QuestionStatistics
 * @example
 * <QuestionStatistics
 *   :statistics="statistics"
 *   show-chart
 *   show-audit-status
 * />
 */
const props = defineProps({
  // 统计数据对象
  statistics: {
    type: Object,
    default: () => ({})
  },
  // 是否显示图表
  showChart: {
    type: Boolean,
    default: false
  },
  // 是否显示审核状态
  showAuditStatus: {
    type: Boolean,
    default: true
  }
})

/**
 * 题目总数
 */
const totalCount = computed(() => {
  return props.statistics.totalCount || 0
})

/**
 * 题型统计数据
 */
const typeStatistics = computed(() => {
  const stats = []

  // 单选题
  if (props.statistics.singleChoiceCount !== undefined) {
    stats.push({
      type: QUESTION_TYPE.SINGLE_CHOICE,
      count: props.statistics.singleChoiceCount || 0
    })
  }

  // 多选题
  if (props.statistics.multipleChoiceCount !== undefined) {
    stats.push({
      type: QUESTION_TYPE.MULTIPLE_CHOICE,
      count: props.statistics.multipleChoiceCount || 0
    })
  }

  // 判断题
  if (props.statistics.trueFalseCount !== undefined) {
    stats.push({
      type: QUESTION_TYPE.TRUE_FALSE,
      count: props.statistics.trueFalseCount || 0
    })
  }

  // 填空题
  if (props.statistics.fillBlankCount !== undefined) {
    stats.push({
      type: QUESTION_TYPE.FILL_BLANK,
      count: props.statistics.fillBlankCount || 0
    })
  }

  // 简答题
  if (props.statistics.subjectiveCount !== undefined || props.statistics.shortAnswerCount !== undefined) {
    stats.push({
      type: QUESTION_TYPE.SUBJECTIVE,
      count: props.statistics.subjectiveCount || props.statistics.shortAnswerCount || 0
    })
  }

  return stats.filter(s => s.count > 0)
})

/**
 * 难度统计数据
 */
const difficultyStatistics = computed(() => {
  return [
    {
      level: DIFFICULTY_LEVEL.EASY,
      count: props.statistics.easyCount || 0
    },
    {
      level: DIFFICULTY_LEVEL.MEDIUM,
      count: props.statistics.mediumCount || 0
    },
    {
      level: DIFFICULTY_LEVEL.HARD,
      count: props.statistics.hardCount || 0
    }
  ]
})

/**
 * 审核状态统计数据
 */
const auditStatistics = computed(() => {
  return [
    {
      status: AUDIT_STATUS.APPROVED,
      count: props.statistics.approvedCount || 0
    },
    {
      status: AUDIT_STATUS.PENDING,
      count: props.statistics.pendingCount || 0
    },
    {
      status: AUDIT_STATUS.REJECTED,
      count: props.statistics.rejectedCount || 0
    }
  ].filter(s => s.count > 0)
})

/**
 * 获取难度样式类
 */
const getDifficultyClass = (level) => {
  const classMap = {
    [DIFFICULTY_LEVEL.EASY]: 'success',
    [DIFFICULTY_LEVEL.MEDIUM]: 'warning',
    [DIFFICULTY_LEVEL.HARD]: 'danger'
  }
  return classMap[level] || ''
}

/**
 * 获取难度颜色
 */
const getDifficultyColor = (level) => {
  const colorMap = {
    [DIFFICULTY_LEVEL.EASY]: '#67C23A',
    [DIFFICULTY_LEVEL.MEDIUM]: '#E6A23C',
    [DIFFICULTY_LEVEL.HARD]: '#F56C6C'
  }
  return colorMap[level] || '#909399'
}

/**
 * 获取审核状态样式类
 */
const getAuditStatusClass = (status) => {
  const classMap = {
    [AUDIT_STATUS.APPROVED]: 'success',
    [AUDIT_STATUS.PENDING]: 'warning',
    [AUDIT_STATUS.REJECTED]: 'danger'
  }
  return classMap[status] || ''
}

/**
 * 计算百分比
 */
const calculatePercentage = (count) => {
  if (totalCount.value === 0) return 0
  return Math.round((count / totalCount.value) * 100)
}
</script>

<style scoped>
.question-statistics {
  width: 100%;
}

.stats-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.stat-item:last-child {
  border-bottom: none;
}

.stat-item.total {
  padding: 16px 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #ffffff 100%);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 8px;
  border: none;
}

.stat-item.total .stat-label {
  font-size: 16px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
}

.stat-item.total .stat-value {
  font-size: 32px;
  font-weight: bold;
}

.stat-label {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #606266;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.stat-value.primary {
  color: #409eff;
}

.stat-value.success {
  color: #67c23a;
}

.stat-value.warning {
  color: #e6a23c;
}

.stat-value.danger {
  color: #f56c6c;
}

.unit {
  font-size: 14px;
  font-weight: normal;
  color: #909399;
  margin-left: 4px;
}

.difficulty-chart {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

:deep(.el-progress__text) {
  font-size: 12px !important;
  min-width: 50px;
}

:deep(.el-divider) {
  margin: 12px 0;
}
</style>

