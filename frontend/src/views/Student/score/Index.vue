<template>
  <div class="score-container">
    <!-- 页面头部 -->
    <PageHeader title="成绩查询" description="查看我的考试成绩和统计分析">
      <template #extra>
        <el-button @click="handleExport">
          <el-icon><Download /></el-icon>
          导出成绩
        </el-button>
      </template>
    </PageHeader>

    <!-- 统计卡片 -->
    <el-row :gutter="20" style="margin-bottom: 20px">
      <el-col :span="6">
        <StatCard
          title="考试总数"
          :value="statistics.totalExams"
          icon="Tickets"
          color="#409eff"
        />
      </el-col>
      <el-col :span="6">
        <StatCard
          title="平均分"
          :value="statistics.averageScore"
          suffix="分"
          icon="TrendCharts"
          color="#67c23a"
        />
      </el-col>
      <el-col :span="6">
        <StatCard
          title="及格率"
          :value="statistics.passRate"
          suffix="%"
          icon="CircleCheck"
          color="#e6a23c"
        />
      </el-col>
      <el-col :span="6">
        <StatCard
          title="最高分"
          :value="statistics.highestScore"
          suffix="分"
          icon="Trophy"
          color="#f56c6c"
        />
      </el-col>
    </el-row>

    <!-- 搜索和筛选 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="考试名称">
          <el-input
            v-model="searchForm.keyword"
            placeholder="搜索考试名称"
            clearable
            style="width: 200px"
          />
        </el-form-item>

        <el-form-item label="成绩范围">
          <el-select
            v-model="searchForm.scoreRange"
            placeholder="选择成绩范围"
            clearable
            style="width: 150px"
          >
            <el-option label="不及格 (<60分)" value="fail" />
            <el-option label="及格 (60-79分)" value="pass" />
            <el-option label="良好 (80-89分)" value="good" />
            <el-option label="优秀 (90-100分)" value="excellent" />
          </el-select>
        </el-form-item>

        <el-form-item label="时间范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="-"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 240px"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="handleReset">
            <el-icon><RefreshLeft /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 成绩列表 -->
    <el-card class="table-card">
      <el-table
        :data="tableData"
        :loading="loading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="examName" label="考试名称" min-width="200" show-overflow-tooltip />

        <el-table-column prop="paperName" label="试卷名称" min-width="180" show-overflow-tooltip />

        <el-table-column prop="score" label="得分" width="100" sortable>
          <template #default="{ row }">
            <span :style="{ color: getScoreColor(row.score, row.totalScore) }">
              {{ row.score }}
            </span>
          </template>
        </el-table-column>

        <el-table-column prop="totalScore" label="总分" width="80" />

        <el-table-column prop="scoreRate" label="得分率" width="100" sortable>
          <template #default="{ row }">
            <el-progress
              :percentage="getScorePercentage(row.score, row.totalScore)"
              :color="getProgressColor(row.score, row.totalScore)"
              :stroke-width="12"
            />
          </template>
        </el-table-column>

        <el-table-column prop="rank" label="排名" width="100" sortable>
          <template #default="{ row }">
            <el-tag v-if="row.rank <= 3" :type="getRankType(row.rank)" size="small">
              <el-icon v-if="row.rank === 1"><Trophy /></el-icon>
              第 {{ row.rank }} 名
            </el-tag>
            <span v-else>第 {{ row.rank }} 名</span>
          </template>
        </el-table-column>

        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isPassed ? 'success' : 'danger'" size="small">
              {{ row.isPassed ? '及格' : '不及格' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="submitTime" label="提交时间" width="180" />

        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewDetail(row)">
              <el-icon><View /></el-icon>
              查看详情
            </el-button>
            <el-button
              v-if="row.allowViewAnalysis"
              link
              type="success"
              @click="viewAnalysis(row)"
            >
              <el-icon><DataAnalysis /></el-icon>
              查看解析
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadScores"
          @current-change="loadScores"
        />
      </div>
    </el-card>

    <!-- 成绩趋势图 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div style="display: flex; align-items: center; gap: 8px">
          <el-icon><TrendCharts /></el-icon>
          <span>成绩趋势</span>
        </div>
      </template>

      <div class="chart-container">
        <!-- 这里可以集成 ECharts 显示成绩趋势图 -->
        <el-empty description="成绩趋势图功能开发中" />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Download,
  Search,
  RefreshLeft,
  View,
  DataAnalysis,
  Trophy,
  TrendCharts
} from '@element-plus/icons-vue'
import { PageHeader, StatCard } from '@/components/common'
import examSessionApi from '@/api/examSession'

const router = useRouter()

// 状态
const loading = ref(false)
const tableData = ref([])

// 统计数据
const statistics = reactive({
  totalExams: 0,
  averageScore: 0,
  passRate: 0,
  highestScore: 0
})

// 搜索表单
const searchForm = reactive({
  keyword: '',
  scoreRange: '',
  dateRange: []
})

// 分页
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

/**
 * 加载成绩列表
 */
const loadScores = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword,
      scoreRange: searchForm.scoreRange,
      startDate: searchForm.dateRange?.[0] || undefined,
      endDate: searchForm.dateRange?.[1] || undefined
    }

    const res = await examSessionApi.getMyScores(params)
    if (res.code === 200) {
      tableData.value = res.data.records || []
      pagination.total = res.data.total || 0

      // 计算统计数据
      calculateStatistics(tableData.value)
    } else {
      ElMessage.error(res.msg || '加载失败')
    }
  } catch (error) {
    console.error('加载成绩失败:', error)
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

/**
 * 计算统计数据
 */
const calculateStatistics = (data) => {
  if (!data || data.length === 0) {
    Object.assign(statistics, {
      totalExams: 0,
      averageScore: 0,
      passRate: 0,
      highestScore: 0
    })
    return
  }

  statistics.totalExams = data.length

  const totalScore = data.reduce((sum, item) => sum + (item.score || 0), 0)
  statistics.averageScore = Math.round(totalScore / data.length * 10) / 10

  const passedCount = data.filter(item => item.isPassed).length
  statistics.passRate = Math.round((passedCount / data.length) * 100)

  statistics.highestScore = Math.max(...data.map(item => item.score || 0))
}

/**
 * 获取分数颜色
 */
const getScoreColor = (score, totalScore) => {
  const percentage = (score / totalScore) * 100
  if (percentage >= 90) return '#67c23a'
  if (percentage >= 80) return '#409eff'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

/**
 * 获取得分百分比
 */
const getScorePercentage = (score, totalScore) => {
  if (!totalScore) return 0
  return Math.round((score / totalScore) * 100)
}

/**
 * 获取进度条颜色
 */
const getProgressColor = (score, totalScore) => {
  const percentage = (score / totalScore) * 100
  if (percentage >= 90) return '#67c23a'
  if (percentage >= 80) return '#409eff'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

/**
 * 获取排名标签类型
 */
const getRankType = (rank) => {
  if (rank === 1) return 'danger'
  if (rank === 2) return 'warning'
  if (rank === 3) return 'success'
  return ''
}

/**
 * 搜索
 */
const handleSearch = () => {
  pagination.current = 1
  loadScores()
}

/**
 * 重置
 */
const handleReset = () => {
  Object.assign(searchForm, {
    keyword: '',
    scoreRange: '',
    dateRange: []
  })
  handleSearch()
}

/**
 * 导出成绩
 */
const handleExport = () => {
  ElMessage.info('导出功能开发中')
  // TODO: 实现导出功能
}

/**
 * 查看详情
 */
const viewDetail = (row) => {
  router.push({
    name: 'StudentExamResult',
    params: { sessionId: row.sessionId }
  })
}

/**
 * 查看解析
 */
const viewAnalysis = (row) => {
  router.push({
    name: 'StudentExamResult',
    params: { sessionId: row.sessionId },
    query: { showAnalysis: 'true' }
  })
}

// 初始化
onMounted(() => {
  loadScores()
})
</script>

<style scoped>
.score-container {
  padding: 20px;
}

.search-card,
.table-card {
  margin-top: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.chart-container {
  min-height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

:deep(.el-table) {
  font-size: 14px;
}

:deep(.el-progress__text) {
  font-size: 12px !important;
}
</style>

