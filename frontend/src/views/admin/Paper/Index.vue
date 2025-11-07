<template>
  <div class="paper-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>试卷管理</h2>
      <div class="header-actions">
        <el-button type="success" @click="handleAutoGenerate">
          <el-icon><MagicStick /></el-icon>
          智能组卷
        </el-button>
        <el-button type="primary" @click="handleCreate">
          <el-icon><Plus /></el-icon>
          创建试卷
        </el-button>
      </div>
    </div>

    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="试卷名称">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入试卷名称"
            clearable
            style="width: 200px"
            @clear="handleSearch"
          />
        </el-form-item>
        <el-form-item label="题库">
          <el-select
            v-model="searchForm.bankId"
            placeholder="选择题库"
            clearable
            style="width: 150px"
            @clear="handleSearch"
          >
            <el-option
              v-for="bank in questionBanks"
              :key="bank.bankId"
              :label="bank.bankName"
              :value="bank.bankId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="searchForm.status"
            placeholder="选择状态"
            clearable
            style="width: 120px"
            @clear="handleSearch"
          >
            <el-option label="草稿" :value="0" />
            <el-option label="已发布" :value="1" />
            <el-option label="已归档" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格区域 -->
    <el-card class="table-card">
      <el-table
        :data="tableData"
        :loading="loading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="paperId" label="ID" width="80" />
        <el-table-column prop="paperName" label="试卷名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="paperType" label="试卷类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getPaperTypeColor(row.paperType)">
              {{ getPaperTypeName(row.paperType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="totalScore" label="总分" width="80" />
        <el-table-column prop="questionCount" label="题目数" width="80" />
        <el-table-column prop="duration" label="时长(分钟)" width="100" />
        <el-table-column prop="bankName" label="所属题库" width="150" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusColor(row.status)">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">查看</el-button>
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="success" @click="handlePreview(row)">预览</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 创建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="900px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="试卷名称" prop="paperName">
              <el-input v-model="formData.paperName" placeholder="请输入试卷名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="试卷类型" prop="paperType">
              <el-select v-model="formData.paperType" placeholder="请选择类型" style="width: 100%">
                <el-option label="正式考试" value="FORMAL" />
                <el-option label="模拟考试" value="MOCK" />
                <el-option label="练习卷" value="PRACTICE" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="题库" prop="bankId">
              <el-select v-model="formData.bankId" placeholder="请选择题库" style="width: 100%">
                <el-option
                  v-for="bank in questionBanks"
                  :key="bank.bankId"
                  :label="bank.bankName"
                  :value="bank.bankId"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="考试时长" prop="duration">
              <el-input-number
                v-model="formData.duration"
                :min="10"
                :max="300"
                controls-position="right"
                style="width: 100%"
              />
              <span style="margin-left: 10px">分钟</span>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="及格分数" prop="passScore">
              <el-input-number
                v-model="formData.passScore"
                :min="0"
                :max="100"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总分" prop="totalScore">
              <el-input-number
                v-model="formData.totalScore"
                :min="0"
                :max="1000"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="试卷说明">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入试卷说明（可选）"
          />
        </el-form-item>

        <el-form-item label="选择题目">
          <el-button @click="showQuestionSelector">选择题目</el-button>
          <span style="margin-left: 10px; color: #909399">
            已选择 {{ selectedQuestions.length }} 道题目
          </span>
        </el-form-item>

        <!-- 已选题目列表 -->
        <el-form-item label="题目列表" v-if="selectedQuestions.length > 0">
          <el-table :data="selectedQuestions" style="width: 100%" max-height="300">
            <el-table-column prop="questionContent" label="题目内容" show-overflow-tooltip />
            <el-table-column prop="questionType" label="类型" width="80">
              <template #default="{ row }">
                <el-tag size="small">{{ getQuestionTypeName(row.questionType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="score" label="分值" width="60" />
            <el-table-column label="操作" width="80">
              <template #default="{ row, $index }">
                <el-button link type="danger" @click="removeQuestion($index)">移除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 智能组卷对话框 -->
    <el-dialog
      v-model="autoGenerateVisible"
      title="智能组卷"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="autoGenerateForm" label-width="120px">
        <el-form-item label="试卷名称">
          <el-input v-model="autoGenerateForm.paperName" placeholder="请输入试卷名称" />
        </el-form-item>
        <el-form-item label="题库">
          <el-select v-model="autoGenerateForm.bankId" placeholder="请选择题库" style="width: 100%">
            <el-option
              v-for="bank in questionBanks"
              :key="bank.bankId"
              :label="bank.bankName"
              :value="bank.bankId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="单选题数量">
          <el-input-number v-model="autoGenerateForm.singleChoiceCount" :min="0" :max="50" />
        </el-form-item>
        <el-form-item label="多选题数量">
          <el-input-number v-model="autoGenerateForm.multipleChoiceCount" :min="0" :max="50" />
        </el-form-item>
        <el-form-item label="判断题数量">
          <el-input-number v-model="autoGenerateForm.trueFalseCount" :min="0" :max="50" />
        </el-form-item>
        <el-form-item label="填空题数量">
          <el-input-number v-model="autoGenerateForm.fillBlankCount" :min="0" :max="20" />
        </el-form-item>
        <el-form-item label="简答题数量">
          <el-input-number v-model="autoGenerateForm.shortAnswerCount" :min="0" :max="10" />
        </el-form-item>
        <el-form-item label="难度分布">
          <el-radio-group v-model="autoGenerateForm.difficultyMode">
            <el-radio label="EASY">简单为主</el-radio>
            <el-radio label="MEDIUM">中等为主</el-radio>
            <el-radio label="HARD">困难为主</el-radio>
            <el-radio label="MIXED">均衡分布</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="autoGenerateVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAutoGenerate">生成试卷</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, MagicStick } from '@element-plus/icons-vue'
import paperApi from '@/api/paper'
import questionBankApi from '@/api/questionBank'

const router = useRouter()

// 搜索表单
const searchForm = reactive({
  keyword: '',
  bankId: null,
  status: null
})

// 表格数据
const tableData = ref([])
const loading = ref(false)
const questionBanks = ref([])

// 分页
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const formRef = ref(null)
const selectedQuestions = ref([])

// 智能组卷对话框
const autoGenerateVisible = ref(false)
const autoGenerateForm = reactive({
  paperName: '',
  bankId: null,
  singleChoiceCount: 10,
  multipleChoiceCount: 5,
  trueFalseCount: 5,
  fillBlankCount: 3,
  shortAnswerCount: 2,
  difficultyMode: 'MIXED'
})

// 表单数据
const formData = reactive({
  paperId: null,
  paperName: '',
  paperType: 'FORMAL',
  bankId: null,
  duration: 120,
  passScore: 60,
  totalScore: 100,
  description: ''
})

// 表单验证规则
const formRules = {
  paperName: [
    { required: true, message: '请输入试卷名称', trigger: 'blur' }
  ],
  paperType: [
    { required: true, message: '请选择试卷类型', trigger: 'change' }
  ],
  bankId: [
    { required: true, message: '请选择题库', trigger: 'change' }
  ],
  duration: [
    { required: true, message: '请输入考试时长', trigger: 'blur' }
  ]
}

// 加载题库列表
const loadQuestionBanks = async () => {
  try {
    const res = await questionBankApi.list()
    if (res.code === 200) {
      questionBanks.value = res.data
    }
  } catch (error) {
    console.error('加载题库失败', error)
  }
}

// 加载试卷列表
const loadPapers = async () => {
  loading.value = true
  try {
    const res = await paperApi.page({
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword || undefined,
      bankId: searchForm.bankId || undefined,
      status: searchForm.status
    })
    if (res.code === 200) {
      tableData.value = res.data.records
      pagination.total = res.data.total
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.current = 1
  loadPapers()
}

// 重置
const handleReset = () => {
  searchForm.keyword = ''
  searchForm.bankId = null
  searchForm.status = null
  handleSearch()
}

// 分页变化
const handleSizeChange = () => loadPapers()
const handleCurrentChange = () => loadPapers()

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建试卷'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑试卷'
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 查看
const handleView = (row) => {
  router.push(`/admin/paper/${row.paperId}`)
}

// 预览
const handlePreview = (row) => {
  ElMessage.info('预览试卷：' + row.paperName)
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除试卷"${row.paperName}"吗？`,
      '警告',
      { type: 'warning' }
    )

    const res = await paperApi.deleteById(row.paperId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadPapers()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 智能组卷
const handleAutoGenerate = () => {
  autoGenerateVisible.value = true
}

const submitAutoGenerate = async () => {
  const res = await paperApi.autoGenerate(autoGenerateForm)
  if (res.code === 200) {
    ElMessage.success('组卷成功')
    autoGenerateVisible.value = false
    loadPapers()
  }
}

// 选择题目
const showQuestionSelector = () => {
  ElMessage.info('打开题目选择器')
}

// 移除题目
const removeQuestion = (index) => {
  selectedQuestions.value.splice(index, 1)
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const res = formData.paperId
        ? await paperApi.update(formData.paperId, formData)
        : await paperApi.create(formData)

      if (res.code === 200) {
        ElMessage.success(formData.paperId ? '更新成功' : '创建成功')
        dialogVisible.value = false
        loadPapers()
      }
    } catch (error) {
      ElMessage.error(formData.paperId ? '更新失败' : '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 重置表单
const resetForm = () => {
  formData.paperId = null
  formData.paperName = ''
  formData.paperType = 'FORMAL'
  formData.bankId = null
  formData.duration = 120
  formData.passScore = 60
  formData.totalScore = 100
  formData.description = ''
  selectedQuestions.value = []
  formRef.value?.resetFields()
}

// 辅助方法
const getPaperTypeName = (type) => {
  const map = { FORMAL: '正式', MOCK: '模拟', PRACTICE: '练习' }
  return map[type] || type
}

const getPaperTypeColor = (type) => {
  const map = { FORMAL: 'danger', MOCK: 'warning', PRACTICE: 'success' }
  return map[type] || ''
}

const getStatusName = (status) => {
  const map = { 0: '草稿', 1: '已发布', 2: '已归档' }
  return map[status] || '未知'
}

const getStatusColor = (status) => {
  const map = { 0: 'info', 1: 'success', 2: 'warning' }
  return map[status] || 'info'
}

const getQuestionTypeName = (type) => {
  const map = {
    SINGLE_CHOICE: '单选',
    MULTIPLE_CHOICE: '多选',
    TRUE_FALSE: '判断',
    FILL_BLANK: '填空',
    SHORT_ANSWER: '简答'
  }
  return map[type] || type
}

// 初始化
onMounted(() => {
  loadQuestionBanks()
  loadPapers()
})
</script>

<style scoped>
.paper-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.search-card,
.table-card {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>

