<template>
  <div class="question-bank-detail-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <div class="header-title">
        <h2>{{ bank.bankName }}</h2>
        <el-tag :type="getBankTypeColor(bank.bankType)">
          {{ getBankTypeName(bank.bankType) }}
        </el-tag>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="handleEdit">编辑</el-button>
        <el-button type="danger" @click="handleDelete">删除</el-button>
      </div>
    </div>

    <!-- 题库信息卡片 -->
    <el-row :gutter="20" v-loading="loading">
      <!-- 基本信息 -->
      <el-col :span="16">
        <el-card class="info-card">
          <template #header>
            <div class="card-header">
              <span>基本信息</span>
            </div>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="题库ID">
              {{ bank.bankId }}
            </el-descriptions-item>
            <el-descriptions-item label="题库类型">
              <el-tag :type="getBankTypeColor(bank.bankType)">
                {{ getBankTypeName(bank.bankType) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="题库名称" :span="2">
              {{ bank.bankName }}
            </el-descriptions-item>
            <el-descriptions-item label="题库描述" :span="2">
              {{ bank.description || '暂无描述' }}
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">
              {{ bank.createTime }}
            </el-descriptions-item>
            <el-descriptions-item label="更新时间">
              {{ bank.updateTime }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 题目列表 -->
        <el-card class="questions-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>题目列表</span>
              <el-button type="primary" size="small" @click="handleAddQuestion">
                <el-icon><Plus /></el-icon>
                添加题目
              </el-button>
            </div>
          </template>
          <el-table :data="questions" stripe>
            <el-table-column prop="questionId" label="ID" width="80" />
            <el-table-column prop="questionContent" label="题目内容" show-overflow-tooltip />
            <el-table-column prop="questionType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag size="small">{{ getQuestionTypeName(row.questionType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="difficulty" label="难度" width="120">
              <template #default="{ row }">
                <el-rate :model-value="Number(row.difficulty) || 0" :max="3" disabled size="small" />
              </template>
            </el-table-column>
            <el-table-column prop="defaultScore" label="分值" width="80">
              <template #default="{ row }">
                {{ row.defaultScore || '-' }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button link type="primary" @click="viewQuestion(row.questionId)">
                  查看
                </el-button>
                <el-button link type="danger" @click="removeQuestion(row.questionId)">
                  移除
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
              layout="total, sizes, prev, pager, next"
              @size-change="loadQuestions"
              @current-change="loadQuestions"
            />
          </div>
        </el-card>
      </el-col>

      <!-- 统计信息 -->
      <el-col :span="8">
        <!-- 题目统计 -->
        <el-card class="stats-card">
          <template #header>
            <div class="card-header">
              <span>题目统计</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">题目总数</div>
            <div class="stat-value primary">{{ statistics.totalCount || 0 }}</div>
          </div>
          <el-divider />
          <div class="stat-item">
            <div class="stat-label">单选题</div>
            <div class="stat-value">{{ statistics.singleChoiceCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">多选题</div>
            <div class="stat-value">{{ statistics.multipleChoiceCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">判断题</div>
            <div class="stat-value">{{ statistics.trueFalseCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">填空题</div>
            <div class="stat-value">{{ statistics.fillBlankCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">简答题</div>
            <div class="stat-value">{{ statistics.shortAnswerCount || 0 }}</div>
          </div>
        </el-card>

        <!-- 难度分布 -->
        <el-card class="stats-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>难度分布</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">简单</div>
            <div class="stat-value success">{{ statistics.easyCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">中等</div>
            <div class="stat-value warning">{{ statistics.mediumCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">困难</div>
            <div class="stat-value danger">{{ statistics.hardCount || 0 }}</div>
          </div>
        </el-card>

        <!-- 审核状态 -->
        <el-card class="stats-card" style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>审核状态</span>
            </div>
          </template>
          <div class="stat-item">
            <div class="stat-label">已通过</div>
            <div class="stat-value success">{{ statistics.approvedCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">待审核</div>
            <div class="stat-value warning">{{ statistics.pendingCount || 0 }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">已拒绝</div>
            <div class="stat-value danger">{{ statistics.rejectedCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, Plus } from '@element-plus/icons-vue'
import questionBankApi from '@/api/questionBank'
import questionApi from '@/api/question'
import {
  getQuestionTypeName,
  getQuestionTypeColor,
  getDifficultyName,
  getBankTypeName,
  getBankTypeColor
} from '@/utils/enums'

const route = useRoute()
const router = useRouter()

// 状态
const loading = ref(false)
const bank = ref({})
const questions = ref([])
const statistics = ref({})
const pagination = ref({
  current: 1,
  size: 10,
  total: 0
})

// 加载题库详情
const loadBankDetail = async () => {
  loading.value = true
  try {
    const bankId = route.params.id
    const res = await questionBankApi.getById(bankId)
    if (res.code === 200) {
      bank.value = res.data
      loadQuestions()
      loadStatistics()
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// 加载题目列表
const loadQuestions = async () => {
  try {
    const res = await questionApi.page({
      current: pagination.value.current,
      size: pagination.value.size,
      bankId: route.params.id
    })
    if (res.code === 200) {
      questions.value = res.data.records
      pagination.value.total = res.data.total
    }
  } catch (error) {
    console.error('加载题目列表失败', error)
  }
}

// 加载统计信息
const loadStatistics = async () => {
  try {
    const res = await questionBankApi.getStatistics(route.params.id)
    if (res.code === 200 && res.data) {
      statistics.value = {
        totalCount: res.data.totalQuestions || 0,
        singleChoiceCount: res.data.singleChoiceCount || 0,
        multipleChoiceCount: res.data.multipleChoiceCount || 0,
        trueFalseCount: res.data.trueFalseCount || 0,
        fillBlankCount: res.data.fillBlankCount || 0,
        shortAnswerCount: res.data.shortAnswerCount || 0,
        easyCount: res.data.easyCount || 0,
        mediumCount: res.data.mediumCount || 0,
        hardCount: res.data.hardCount || 0,
        approvedCount: res.data.approvedCount || 0,
        pendingCount: res.data.pendingCount || 0,
        rejectedCount: res.data.rejectedCount || 0
      }
    }
  } catch (error) {
    console.error('加载统计信息失败', error)
  }
}

// 返回
const goBack = () => {
  router.back()
}

// 编辑
const handleEdit = () => {
  router.push(`/admin/question-bank/edit/${bank.value.bankId}`)
}

// 删除
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题库"${bank.value.bankName}"吗？删除后将无法恢复！`,
      '警告',
      { type: 'warning' }
    )

    const res = await questionBankApi.deleteById(bank.value.bankId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      router.back()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 添加题目
const handleAddQuestion = () => {
  router.push(`/admin/question?bankId=${bank.value.bankId}`)
}

// 查看题目
const viewQuestion = (questionId) => {
  router.push(`/admin/question/${questionId}`)
}

// 移除题目
const removeQuestion = async (questionId) => {
  try {
    await ElMessageBox.confirm('确定要从该题库移除此题目吗？', '提示', {
      type: 'warning'
    })

    // TODO: 调用移除API
    ElMessage.success('移除成功')
    loadQuestions()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('移除失败')
    }
  }
}




// 初始化
onMounted(() => {
  loadBankDetail()
})
</script>

<style scoped>
.question-bank-detail-container {
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

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.stats-card .stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.stat-item:not(:last-child) {
  border-bottom: 1px solid #f0f0f0;
}

.stat-label {
  font-size: 14px;
  color: #606266;
}

.stat-value {
  font-size: 20px;
  font-weight: bold;
  color: #303133;
}

.stat-value.primary {
  color: #409eff;
  font-size: 32px;
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
</style>
