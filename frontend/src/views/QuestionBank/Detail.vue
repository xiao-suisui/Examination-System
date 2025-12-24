<template>
  <div class="question-bank-detail-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button @click="goBack">
        <el-icon>
          <ArrowLeft/>
        </el-icon>
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
                <el-icon>
                  <Plus/>
                </el-icon>
                添加题目
              </el-button>
            </div>
          </template>
          <el-table :data="questions" stripe>
            <el-table-column prop="questionId" label="ID" width="80"/>
            <el-table-column prop="questionContent" label="题目内容" show-overflow-tooltip/>
            <el-table-column prop="questionType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag size="small">{{ getQuestionTypeName(row.questionType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="difficulty" label="难度" width="120">
              <template #default="{ row }">
                <el-rate :model-value="Number(row.difficulty) || 0" :max="3" disabled size="small"/>
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
          <el-divider/>
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

    <!-- 编辑题库对话框 -->
    <el-dialog
        v-model="editDialogVisible"
        title="编辑题库"
        width="600px"
        :close-on-click-modal="false"
    >
      <el-form
          ref="editFormRef"
          :model="editForm"
          :rules="editFormRules"
          label-width="100px"
      >
        <el-form-item label="题库名称" prop="bankName">
          <el-input v-model="editForm.bankName" placeholder="请输入题库名称"/>
        </el-form-item>
        <el-form-item label="题库类型" prop="bankType">
          <el-select v-model="editForm.bankType" placeholder="请选择题库类型" style="width: 100%">
            <el-option label="公共题库" :value="1"/>
            <el-option label="私有题库" :value="2"/>
          </el-select>
        </el-form-item>
        <el-form-item label="题库描述" prop="description">
          <el-input
              v-model="editForm.description"
              type="textarea"
              :rows="4"
              placeholder="请输入题库描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submitEdit">
          保存
        </el-button>
      </template>
    </el-dialog>

    <!-- 题目选择器 -->
    <QuestionSelector
        v-model="selectorVisible"
        :bank-id="bank.bankId"
        @confirm="handleQuestionsSelected"
    />
  </div>
</template>

<script setup>
import {onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {ElMessage, ElMessageBox} from 'element-plus'
import {ArrowLeft, Plus} from '@element-plus/icons-vue'
import questionBankApi from '@/api/questionBank'
import questionApi from '@/api/question'
import QuestionSelector from '@/components/QuestionSelector.vue'
import {getBankTypeColor, getBankTypeName, getQuestionTypeName} from '@/utils/enums'

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

// 编辑对话框
const editDialogVisible = ref(false)
const editFormRef = ref(null)
const submitLoading = ref(false)
const editForm = ref({
  bankId: null,
  bankName: '',
  bankType: null,
  description: ''
})

const editFormRules = {
  bankName: [
    {required: true, message: '请输入题库名称', trigger: 'blur'},
    {min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur'}
  ],
  bankType: [
    {required: true, message: '请选择题库类型', trigger: 'change'}
  ]
}

// 题目选择器
const selectorVisible = ref(false)


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

// 编辑题库
const handleEdit = () => {
  // 填充表单数据
  editForm.value = {
    bankId: bank.value.bankId,
    bankName: bank.value.bankName,
    bankType: bank.value.bankType,
    description: bank.value.description || ''
  }
  editDialogVisible.value = true
}

// 提交编辑
const submitEdit = async () => {
  if (!editFormRef.value) return

  await editFormRef.value.validate(async (valid) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const res = await questionBankApi.update(editForm.value.bankId, editForm.value)
      if (res.code === 200) {
        ElMessage.success('修改成功')
        editDialogVisible.value = false
        // 重新加载题库信息
        await loadBankDetail()
      } else {
        ElMessage.error(res.message || '修改失败')
      }
    } catch (error) {
      console.error('修改失败:', error)
      ElMessage.error('修改失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 删除
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
        `确定要删除题库"${bank.value.bankName}"吗？删除后将无法恢复！`,
        '警告',
        {type: 'warning'}
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

// 添加题目 - 打开题目选择器
const handleAddQuestion = () => {
  selectorVisible.value = true
}

// 处理题目选择器确认
const handleQuestionsSelected = async (selectedQuestions) => {
  if (!selectedQuestions || selectedQuestions.length === 0) {
    ElMessage.warning('请选择至少一个题目')
    return
  }

  try {
    const questionIds = selectedQuestions.map(q => q.questionId)
    console.log('添加题目到题库:', bank.value.bankId, '题目IDs:', questionIds)

    // 调用批量添加题目接口
    const res = await questionBankApi.addQuestions(bank.value.bankId, questionIds)

    if (res && res.code === 200) {
      ElMessage.success(`成功添加 ${questionIds.length} 个题目`)
      selectorVisible.value = false
      // 刷新题目列表和统计数据
      await loadQuestions()
      await loadStatistics()
    } else {
      ElMessage.error(res.message || '添加失败')
    }
  } catch (error) {
    console.error('添加题目失败:', error)
    ElMessage.error('添加失败')
  }
}

// 查看题目
const viewQuestion = (questionId) => {
  router.push({name: 'QuestionDetail', params: {id: questionId}})
}

// 移除题目
const removeQuestion = async (questionId) => {
  try {
    await ElMessageBox.confirm(
        '确定要从该题库移除此题目吗？移除后题目仍然存在，只是不再属于此题库。',
        '提示',
        {
          type: 'warning',
          confirmButtonText: '确定移除',
          cancelButtonText: '取消'
        }
    )

    console.log('开始移除题目，questionId:', questionId, 'bankId:', route.params.id)

    // 调用专门的移除题目接口
    const res = await questionBankApi.removeQuestion(route.params.id, questionId)

    console.log('移除响应:', res)

    if (res && res.code === 200) {
      ElMessage.success('移除成功')
      // 延迟刷新，确保数据库更新完成
      setTimeout(async () => {
        await loadQuestions()
        await loadStatistics()
      }, 300)
    } else {
      const errorMsg = res.message || res.msg || '移除失败'
      console.error('移除失败:', errorMsg, res)
      ElMessage.error(errorMsg)
    }
  } catch (error) {
    if (error === 'cancel') {
      console.log('用户取消移除')
    } else {
      console.error('移除异常:', error)
      const errorMsg = error?.response?.data?.message || error?.message || '移除失败'
      ElMessage.error(errorMsg)
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
