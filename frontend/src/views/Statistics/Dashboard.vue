<template>
  <div class="statistics-dashboard">
    <el-card class="dashboard-header">
      <template #header>
        <div class="header-title">
          <el-icon size="24"><DataAnalysis /></el-icon>
          <span>数据统计分析</span>
        </div>
      </template>

      <!-- 统计卡片 -->
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="待批改" :value="dashboardData.pendingGrading || 0">
              <template #prefix>
                <el-icon color="#f56c6c"><EditPen /></el-icon>
              </template>
              <template #suffix>
                <span style="font-size: 14px">份</span>
              </template>
            </el-statistic>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="今日提交" :value="dashboardData.todaySubmissions || 0">
              <template #prefix>
                <el-icon color="#67c23a"><DocumentChecked /></el-icon>
              </template>
              <template #suffix>
                <span style="font-size: 14px">份</span>
              </template>
            </el-statistic>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="进行中" :value="dashboardData.inProgressExams || 0">
              <template #prefix>
                <el-icon color="#409eff"><Timer /></el-icon>
              </template>
              <template #suffix>
                <span style="font-size: 14px">场</span>
              </template>
            </el-statistic>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="总考试数" :value="dashboardData.totalExams || 0">
              <template #prefix>
                <el-icon color="#e6a23c"><Files /></el-icon>
              </template>
              <template #suffix>
                <span style="font-size: 14px">场</span>
              </template>
            </el-statistic>
          </el-card>
        </el-col>
      </el-row>
    </el-card>

    <!-- 考试选择 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <span>考试统计详情</span>
      </template>

      <el-form :inline="true" :model="queryForm">
        <el-form-item label="选择考试">
          <el-select
            v-model="queryForm.examId"
            placeholder="请选择考试"
            clearable
            filterable
            style="width: 300px"
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
          <el-button type="primary" @click="loadStatistics">
            <el-icon><Search /></el-icon>
            查询统计
          </el-button>
        </el-form-item>
      </el-form>

      <!-- 统计数据展示 -->
      <div v-if="overview && queryForm.examId" class="statistics-content">
        <!-- 考试概览 -->
        <el-descriptions title="考试概览" :column="4" border>
          <el-descriptions-item label="总学生数">{{ overview.totalStudents }}</el-descriptions-item>
          <el-descriptions-item label="提交人数">{{ overview.submittedCount }}</el-descriptions-item>
          <el-descriptions-item label="缺考人数">{{ overview.absentCount }}</el-descriptions-item>
          <el-descriptions-item label="及格率">
            <el-tag :type="overview.passRate >= 60 ? 'success' : 'danger'">
              {{ overview.passRate.toFixed(1) }}%
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="平均分">
            <span style="font-size: 18px; font-weight: bold; color: #409eff">
              {{ overview.averageScore }}
            </span>
          </el-descriptions-item>
          <el-descriptions-item label="最高分">{{ overview.maxScore }}</el-descriptions-item>
          <el-descriptions-item label="最低分">{{ overview.minScore }}</el-descriptions-item>
          <el-descriptions-item label="及格人数">{{ overview.passCount }}</el-descriptions-item>
        </el-descriptions>

        <!-- 成绩分布图表 -->
        <el-card style="margin-top: 20px" v-if="distribution">
          <template #header>
            <span>成绩分布</span>
          </template>
          <div ref="distributionChart" style="width: 100%; height: 400px"></div>
        </el-card>

        <!-- 违规统计 -->
        <el-card style="margin-top: 20px" v-if="violationStats">
          <template #header>
            <div style="display: flex; justify-content: space-between; align-items: center">
              <span>违规统计</span>
              <el-tag type="warning">共 {{ violationStats.totalViolations }} 次违规</el-tag>
            </div>
          </template>

          <el-row :gutter="20">
            <el-col :span="12">
              <div ref="violationTypeChart" style="width: 100%; height: 300px"></div>
            </el-col>
            <el-col :span="12">
              <div ref="violationSeverityChart" style="width: 100%; height: 300px"></div>
            </el-col>
          </el-row>
        </el-card>
      </div>

      <el-empty v-else description="请选择考试查看统计数据" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import {
  DataAnalysis, EditPen, DocumentChecked, Timer, Files, Search
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import statisticsApi from '@/api/statistics'
import examApi from '@/api/exam'
import { useAuthStore } from '@/stores/modules/auth'

const authStore = useAuthStore()

// 数据
const dashboardData = ref({})
const examList = ref([])
const overview = ref(null)
const distribution = ref(null)
const violationStats = ref(null)

const queryForm = reactive({
  examId: null
})

// 图表实例
let distributionChartInstance = null
let violationTypeChartInstance = null
let violationSeverityChartInstance = null

const distributionChart = ref(null)
const violationTypeChart = ref(null)
const violationSeverityChart = ref(null)

// 方法

// 加载仪表盘数据
const loadDashboard = async () => {
  try {
    const res = await statisticsApi.getDashboard(authStore.userId, authStore.user?.roleId || 'TEACHER')
    if (res.code === 200) {
      dashboardData.value = res.data
    }
  } catch (error) {
    console.error('加载仪表盘数据失败:', error)
  }
}

// 加载考试列表
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

// 加载统计数据
const loadStatistics = async () => {
  if (!queryForm.examId) {
    ElMessage.warning('请选择考试')
    return
  }

  try {
    // 加载考试概览
    const overviewRes = await statisticsApi.getExamOverview(queryForm.examId)
    if (overviewRes.code === 200) {
      overview.value = overviewRes.data
    }

    // 加载成绩分布
    const distributionRes = await statisticsApi.getScoreDistribution(queryForm.examId)
    if (distributionRes.code === 200) {
      distribution.value = distributionRes.data
      await nextTick()
      renderDistributionChart()
    }

    // 加载违规统计
    const violationRes = await statisticsApi.getViolationStatistics(queryForm.examId)
    if (violationRes.code === 200) {
      violationStats.value = violationRes.data
      await nextTick()
      renderViolationCharts()
    }

    ElMessage.success('统计数据加载成功')
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败')
  }
}

// 考试改变
const handleExamChange = () => {
  if (queryForm.examId) {
    loadStatistics()
  }
}

// 渲染成绩分布图表
const renderDistributionChart = () => {
  if (!distributionChart.value || !distribution.value) return

  if (distributionChartInstance) {
    distributionChartInstance.dispose()
  }

  distributionChartInstance = echarts.init(distributionChart.value)

  const option = {
    title: {
      text: '成绩分布',
      left: 'center'
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    xAxis: {
      type: 'category',
      data: Object.keys(distribution.value.distribution || {}),
      axisLabel: {
        rotate: 0
      }
    },
    yAxis: {
      type: 'value',
      name: '人数'
    },
    series: [
      {
        name: '人数',
        type: 'bar',
        data: Object.values(distribution.value.distribution || {}),
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        },
        label: {
          show: true,
          position: 'top'
        }
      }
    ]
  }

  distributionChartInstance.setOption(option)
}

// 渲染违规图表
const renderViolationCharts = () => {
  if (!violationStats.value) return

  // 违规类型图表
  if (violationTypeChart.value) {
    if (violationTypeChartInstance) {
      violationTypeChartInstance.dispose()
    }

    violationTypeChartInstance = echarts.init(violationTypeChart.value)

    const typeData = Object.entries(violationStats.value.typeStatistics || {}).map(([key, value]) => ({
      name: getViolationTypeName(key),
      value: value
    }))

    const typeOption = {
      title: {
        text: '违规类型分布',
        left: 'center'
      },
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [
        {
          name: '违规次数',
          type: 'pie',
          radius: '50%',
          data: typeData,
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    }

    violationTypeChartInstance.setOption(typeOption)
  }

  // 违规严重程度图表
  if (violationSeverityChart.value) {
    if (violationSeverityChartInstance) {
      violationSeverityChartInstance.dispose()
    }

    violationSeverityChartInstance = echarts.init(violationSeverityChart.value)

    const severityData = Object.entries(violationStats.value.severityStatistics || {}).map(([key, value]) => ({
      name: getSeverityName(key),
      value: value
    }))

    const severityOption = {
      title: {
        text: '违规严重程度分布',
        left: 'center'
      },
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [
        {
          name: '违规次数',
          type: 'pie',
          radius: '50%',
          data: severityData,
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    }

    violationSeverityChartInstance.setOption(severityOption)
  }
}

// 获取违规类型名称
const getViolationTypeName = (type) => {
  const typeMap = {
    'TAB_SWITCH': '切屏',
    'COPY': '复制',
    'PASTE': '粘贴',
    'RIGHT_CLICK': '右键',
    'EXIT_FULLSCREEN': '退出全屏',
    'IDLE_TIMEOUT': '长时间无操作'
  }
  return typeMap[type] || type
}

// 获取严重程度名称
const getSeverityName = (severity) => {
  const nameMap = {
    '1': '轻微',
    '2': '一般',
    '3': '严重',
    '4': '非常严重',
    '5': '致命'
  }
  return nameMap[severity] || '未知'
}

// 生命周期
onMounted(() => {
  loadDashboard()
  loadExamList()
})

// 窗口resize时重绘图表
window.addEventListener('resize', () => {
  distributionChartInstance?.resize()
  violationTypeChartInstance?.resize()
  violationSeverityChartInstance?.resize()
})
</script>

<style scoped>
.statistics-dashboard {
  padding: 20px;
}

.dashboard-header .header-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: bold;
}

.stat-card {
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.statistics-content {
  margin-top: 20px;
}
</style>

