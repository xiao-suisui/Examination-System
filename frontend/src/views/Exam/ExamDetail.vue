<template>
  <div class="exam-detail-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>考试详情</span>
          <div>
            <el-button type="primary" @click="handleEdit" v-if="examInfo.examStatus === 0">编辑</el-button>
            <el-button type="success" @click="handlePublish" v-if="examInfo.examStatus === 0">发布</el-button>
            <el-button type="warning" @click="handleMonitor" v-if="examInfo.examStatus === 2">监控</el-button>
            <el-button @click="handleBack">返回</el-button>
          </div>
        </div>
      </template>

      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <!-- 基本信息 -->
        <el-tab-pane label="基本信息" name="basic">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="考试名称">{{ examInfo.examName }}</el-descriptions-item>
            <el-descriptions-item label="考试状态">
              <el-tag :type="getStatusColor(examInfo.examStatus)">
                {{ getStatusText(examInfo.examStatus) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="试卷名称">{{ examInfo.paperName || '-' }}</el-descriptions-item>
            <el-descriptions-item label="考试时长">{{ examInfo.duration }} 分钟</el-descriptions-item>
            <el-descriptions-item label="开始时间">{{ formatDateTime(examInfo.startTime) }}</el-descriptions-item>
            <el-descriptions-item label="结束时间">{{ formatDateTime(examInfo.endTime) }}</el-descriptions-item>
            <el-descriptions-item label="参与范围">
              {{ getRangeTypeText(examInfo.examRangeType) }}
            </el-descriptions-item>
            <el-descriptions-item label="范围ID">{{ examInfo.examRangeIds || '-' }}</el-descriptions-item>
            <el-descriptions-item label="参与人数" :span="2">
              {{ examInfo.participantCount || 0 }} 人（已提交：{{ examInfo.submittedCount || 0 }}）
            </el-descriptions-item>
            <el-descriptions-item label="考试描述" :span="2">
              {{ examInfo.description || '-' }}
            </el-descriptions-item>
          </el-descriptions>

          <el-divider content-position="left">防作弊设置</el-divider>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="允许切屏次数">{{ examInfo.cutScreenLimit }} 次</el-descriptions-item>
            <el-descriptions-item label="切屏时间">
              {{ examInfo.cutScreenTimer === 1 ? '计入考试时间' : '不计入考试时间' }}
            </el-descriptions-item>
            <el-descriptions-item label="禁止复制粘贴">
              <el-tag :type="examInfo.forbidCopy === 1 ? 'danger' : 'success'">
                {{ examInfo.forbidCopy === 1 ? '是' : '否' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="单设备登录">
              <el-tag :type="examInfo.singleDevice === 1 ? 'warning' : 'success'">
                {{ examInfo.singleDevice === 1 ? '是' : '否' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="乱序题目">
              {{ examInfo.shuffleQuestions === 1 ? '是' : '否' }}
            </el-descriptions-item>
            <el-descriptions-item label="乱序选项">
              {{ examInfo.shuffleOptions === 1 ? '是' : '否' }}
            </el-descriptions-item>
            <el-descriptions-item label="主观题防抄袭">
              {{ examInfo.antiPlagiarism === 1 ? '开启' : '关闭' }}
            </el-descriptions-item>
            <el-descriptions-item label="相似度阈值" v-if="examInfo.antiPlagiarism === 1">
              {{ examInfo.plagiarismThreshold }}%
            </el-descriptions-item>
          </el-descriptions>

          <el-divider content-position="left">其他设置</el-divider>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="考前提醒">{{ examInfo.remindTime }} 分钟</el-descriptions-item>
            <el-descriptions-item label="立即显示成绩">
              {{ examInfo.showScoreImmediately === 1 ? '是' : '否' }}
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ formatDateTime(examInfo.createTime) }}</el-descriptions-item>
            <el-descriptions-item label="更新时间">{{ formatDateTime(examInfo.updateTime) }}</el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 统计数据 -->
        <el-tab-pane label="统计数据" name="statistics">
          <div v-if="statistics">
            <!-- 总览统计 -->
            <el-row :gutter="20" class="stats-row">
              <el-col :span="6">
                <el-card class="stat-card">
                  <div class="stat-label">参与人数</div>
                  <div class="stat-value">{{ statistics.totalParticipants }}</div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card class="stat-card">
                  <div class="stat-label">已提交</div>
                  <div class="stat-value success">{{ statistics.submittedCount }}</div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card class="stat-card">
                  <div class="stat-label">已批改</div>
                  <div class="stat-value warning">{{ statistics.gradedCount }}</div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card class="stat-card">
                  <div class="stat-label">待批改</div>
                  <div class="stat-value info">{{ statistics.pendingGradeCount }}</div>
                </el-card>
              </el-col>
            </el-row>

            <!-- 成绩统计 -->
            <el-divider content-position="left">成绩统计</el-divider>
            <el-row :gutter="20" class="stats-row">
              <el-col :span="8">
                <el-card>
                  <div class="score-stat">
                    <div class="label">平均分</div>
                    <div class="value primary">{{ statistics.averageScore }}</div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card>
                  <div class="score-stat">
                    <div class="label">最高分</div>
                    <div class="value success">{{ statistics.highestScore }}</div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card>
                  <div class="score-stat">
                    <div class="label">最低分</div>
                    <div class="value danger">{{ statistics.lowestScore }}</div>
                  </div>
                </el-card>
              </el-col>
            </el-row>

            <!-- 及格率统计 -->
            <el-divider content-position="left">及格率统计</el-divider>
            <el-row :gutter="20" class="stats-row">
              <el-col :span="12">
                <el-card>
                  <div class="pass-stat">
                    <div class="label">及格人数</div>
                    <div class="value">{{ statistics.passCount }} 人</div>
                    <el-progress
                      :percentage="parseFloat(statistics.passRate)"
                      :color="getPassRateColor(statistics.passRate)"
                    />
                  </div>
                </el-card>
              </el-col>
              <el-col :span="12">
                <el-card>
                  <div class="pass-stat">
                    <div class="label">不及格人数</div>
                    <div class="value">{{ statistics.failCount }} 人</div>
                    <el-progress
                      :percentage="100 - parseFloat(statistics.passRate)"
                      color="#f56c6c"
                    />
                  </div>
                </el-card>
              </el-col>
            </el-row>

            <!-- 分数段分布 -->
            <el-divider content-position="left">分数段分布</el-divider>
            <el-row :gutter="20">
              <el-col :span="6">
                <el-card>
                  <div class="grade-stat">
                    <div class="label">优秀（≥90分）</div>
                    <div class="value">{{ statistics.excellentCount }} 人</div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card>
                  <div class="grade-stat">
                    <div class="label">良好（80-89分）</div>
                    <div class="value">{{ statistics.goodCount }} 人</div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card>
                  <div class="grade-stat">
                    <div class="label">中等（70-79分）</div>
                    <div class="value">{{ statistics.mediumCount }} 人</div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="6">
                <el-card>
                  <div class="grade-stat">
                    <div class="label">一般（60-69分）</div>
                    <div class="value">{{ statistics.fairCount }} 人</div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
          <el-empty v-else description="暂无统计数据" />
        </el-tab-pane>

        <!-- 试卷预览 -->
        <el-tab-pane label="试卷预览" name="paper">
          <div v-if="examInfo.paperId">
            <el-button type="primary" @click="handlePreviewPaper">
              预览试卷
            </el-button>
          </div>
          <el-empty v-else description="未关联试卷" />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getExamDetail, getExamStatistics, publishExam } from '@/api/exam'

const route = useRoute()
const router = useRouter()

const activeTab = ref('basic')
const examInfo = ref({})
const statistics = ref(null)

// 获取考试详情
const getDetail = async () => {
  try {
    const res = await getExamDetail(route.params.id)
    if (res.code === 200) {
      examInfo.value = res.data
    }
  } catch (error) {
    ElMessage.error('获取考试详情失败')
  }
}

// 获取统计数据
const getStatistics = async () => {
  try {
    const res = await getExamStatistics(route.params.id)
    if (res.code === 200) {
      statistics.value = res.data
    }
  } catch (error) {
    console.error('获取统计数据失败', error)
  }
}

// 标签页切换
const handleTabChange = (tabName) => {
  if (tabName === 'statistics' && !statistics.value) {
    getStatistics()
  }
}

// 编辑
const handleEdit = () => {
  router.push({ name: 'ExamEdit', params: { id: route.params.id } })
}

// 发布
const handlePublish = async () => {
  try {
    await ElMessageBox.confirm('确认发布该考试吗？发布后考生将收到通知。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await publishExam(route.params.id)
    if (res.code === 200) {
      ElMessage.success('发布成功')
      await getDetail()
    } else {
      ElMessage.error(res.message || '发布失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('发布失败')
    }
  }
}

// 监控
const handleMonitor = () => {
  router.push({ name: 'ExamMonitor', params: { id: route.params.id } })
}

// 预览试卷
const handlePreviewPaper = () => {
  router.push({ name: 'PaperPreview', params: { id: examInfo.value.paperId } })
}

// 返回
const handleBack = () => {
  router.back()
}

// 格式化时间
const formatDateTime = (datetime) => {
  if (!datetime) return '-'
  return datetime.replace('T', ' ')
}

// 状态颜色
const getStatusColor = (status) => {
  const colorMap = { 0: 'info', 1: 'success', 2: 'warning', 3: '', 4: 'danger' }
  return colorMap[status] || ''
}

// 状态文本
const getStatusText = (status) => {
  const textMap = { 0: '草稿', 1: '已发布', 2: '进行中', 3: '已结束', 4: '已取消' }
  return textMap[status] || '未知'
}

// 范围类型文本
const getRangeTypeText = (type) => {
  const textMap = { 1: '指定考生', 2: '指定班级', 3: '指定组织' }
  return textMap[type] || '-'
}

// 及格率颜色
const getPassRateColor = (rate) => {
  const r = parseFloat(rate)
  if (r >= 80) return '#67c23a'
  if (r >= 60) return '#e6a23c'
  return '#f56c6c'
}

// 监听路由参数变化
watch(() => route.query.tab, (newTab) => {
  if (newTab) {
    activeTab.value = newTab
    if (newTab === 'statistics') {
      getStatistics()
    }
  }
}, { immediate: true })

onMounted(async () => {
  await getDetail()
  if (route.query.tab === 'statistics') {
    await getStatistics()
  }
})
</script>

<style scoped>
.exam-detail-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  padding: 20px 0;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
}

.stat-value.success {
  color: #67c23a;
}

.stat-value.warning {
  color: #e6a23c;
}

.stat-value.info {
  color: #909399;
}

.score-stat, .pass-stat, .grade-stat {
  text-align: center;
  padding: 10px 0;
}

.score-stat .label, .pass-stat .label, .grade-stat .label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.score-stat .value {
  font-size: 36px;
  font-weight: bold;
  margin-bottom: 10px;
}

.score-stat .value.primary {
  color: #409eff;
}

.score-stat .value.success {
  color: #67c23a;
}

.score-stat .value.danger {
  color: #f56c6c;
}

.pass-stat .value, .grade-stat .value {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 15px;
  color: #303133;
}
</style>

