<template>
  <div class="question-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>题目管理</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        创建题目
      </el-button>
    </div>

    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="题目内容">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入题目内容"
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
        <el-form-item label="题目类型">
          <el-select
            v-model="searchForm.questionType"
            placeholder="选择类型"
            clearable
            style="width: 120px"
            @clear="handleSearch"
          >
            <el-option label="单选题" value="SINGLE_CHOICE" />
            <el-option label="多选题" value="MULTIPLE_CHOICE" />
            <el-option label="判断题" value="TRUE_FALSE" />
            <el-option label="填空题" value="FILL_BLANK" />
            <el-option label="简答题" value="SHORT_ANSWER" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select
            v-model="searchForm.difficulty"
            placeholder="选择难度"
            clearable
            style="width: 100px"
            @clear="handleSearch"
          >
            <el-option label="简单" :value="1" />
            <el-option label="中等" :value="2" />
            <el-option label="困难" :value="3" />
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
        <el-table-column prop="questionId" label="ID" width="80" />
        <el-table-column prop="questionContent" label="题目内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="questionType" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getQuestionTypeColor(row.questionType)">
              {{ getQuestionTypeName(row.questionType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="difficulty" label="难度" width="100">
          <template #default="{ row }">
            <el-rate
              v-model="row.difficulty"
              disabled
              show-score
              text-color="#ff9900"
            />
          </template>
        </el-table-column>
        <el-table-column prop="score" label="分值" width="80" />
        <el-table-column prop="bankName" label="所属题库" width="150" show-overflow-tooltip />
        <el-table-column prop="auditStatus" label="审核状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getAuditStatusColor(row.auditStatus)">
              {{ getAuditStatusName(row.auditStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">查看</el-button>
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
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
      width="800px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
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

        <el-form-item label="题目类型" prop="questionType">
          <el-select v-model="formData.questionType" placeholder="请选择题目类型" style="width: 100%">
            <el-option label="单选题" value="SINGLE_CHOICE" />
            <el-option label="多选题" value="MULTIPLE_CHOICE" />
            <el-option label="判断题" value="TRUE_FALSE" />
            <el-option label="填空题" value="FILL_BLANK" />
            <el-option label="简答题" value="SHORT_ANSWER" />
          </el-select>
        </el-form-item>

        <el-form-item label="题目内容" prop="questionContent">
          <el-input
            v-model="formData.questionContent"
            type="textarea"
            :rows="4"
            placeholder="请输入题目内容"
          />
        </el-form-item>

        <el-form-item label="难度" prop="difficulty">
          <el-rate v-model="formData.difficulty" :max="3" />
        </el-form-item>

        <el-form-item label="分值" prop="score">
          <el-input-number
            v-model="formData.score"
            :min="1"
            :max="100"
            controls-position="right"
          />
        </el-form-item>

        <!-- 选项（选择题和判断题） -->
        <template v-if="['SINGLE_CHOICE', 'MULTIPLE_CHOICE', 'TRUE_FALSE'].includes(formData.questionType)">
          <el-form-item label="选项">
            <div v-for="(option, index) in formData.options" :key="index" class="option-item">
              <el-input
                v-model="option.content"
                placeholder="请输入选项内容"
                style="width: 400px"
              />
              <el-checkbox v-model="option.isCorrect" style="margin-left: 10px">
                正确答案
              </el-checkbox>
              <el-button
                link
                type="danger"
                @click="removeOption(index)"
                style="margin-left: 10px"
              >
                删除
              </el-button>
            </div>
            <el-button @click="addOption" style="margin-top: 10px">添加选项</el-button>
          </el-form-item>
        </template>

        <!-- 答案（填空题和简答题） -->
        <el-form-item
          v-if="['FILL_BLANK', 'SHORT_ANSWER'].includes(formData.questionType)"
          label="参考答案"
          prop="correctAnswer"
        >
          <el-input
            v-model="formData.correctAnswer"
            type="textarea"
            :rows="3"
            placeholder="请输入参考答案"
          />
        </el-form-item>

        <el-form-item label="解析">
          <el-input
            v-model="formData.analysis"
            type="textarea"
            :rows="3"
            placeholder="请输入题目解析（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import questionApi from '@/api/question'
import questionBankApi from '@/api/questionBank'

const router = useRouter()

// 搜索表单
const searchForm = reactive({
  keyword: '',
  bankId: null,
  questionType: '',
  difficulty: null
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 题库列表
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

// 表单数据
const formData = reactive({
  questionId: null,
  bankId: null,
  questionType: 'SINGLE_CHOICE',
  questionContent: '',
  difficulty: 2,
  score: 5,
  options: [],
  correctAnswer: '',
  analysis: ''
})

// 表单验证规则
const formRules = {
  bankId: [
    { required: true, message: '请选择题库', trigger: 'change' }
  ],
  questionType: [
    { required: true, message: '请选择题目类型', trigger: 'change' }
  ],
  questionContent: [
    { required: true, message: '请输入题目内容', trigger: 'blur' },
    { min: 5, max: 1000, message: '长度在 5 到 1000 个字符', trigger: 'blur' }
  ],
  score: [
    { required: true, message: '请输入分值', trigger: 'blur' }
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

// 加载题目列表
const loadQuestions = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword || undefined,
      bankId: searchForm.bankId || undefined,
      questionType: searchForm.questionType || undefined,
      difficulty: searchForm.difficulty || undefined
    }
    const res = await questionApi.page(params)
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
  loadQuestions()
}

// 重置
const handleReset = () => {
  searchForm.keyword = ''
  searchForm.bankId = null
  searchForm.questionType = ''
  searchForm.difficulty = null
  handleSearch()
}

// 分页变化
const handleSizeChange = () => {
  loadQuestions()
}

const handleCurrentChange = () => {
  loadQuestions()
}

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建题目'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑题目'
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 查看
const handleView = (row) => {
  router.push(`/admin/question/${row.questionId}`)
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目"${row.questionContent}"吗？`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await questionApi.deleteById(row.questionId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadQuestions()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 添加选项
const addOption = () => {
  formData.options.push({
    content: '',
    isCorrect: false
  })
}

// 删除选项
const removeOption = (index) => {
  formData.options.splice(index, 1)
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const res = formData.questionId
        ? await questionApi.update(formData.questionId, formData)
        : await questionApi.create(formData)

      if (res.code === 200) {
        ElMessage.success(formData.questionId ? '更新成功' : '创建成功')
        dialogVisible.value = false
        loadQuestions()
      }
    } catch (error) {
      ElMessage.error(formData.questionId ? '更新失败' : '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 重置表单
const resetForm = () => {
  formData.questionId = null
  formData.bankId = null
  formData.questionType = 'SINGLE_CHOICE'
  formData.questionContent = ''
  formData.difficulty = 2
  formData.score = 5
  formData.options = []
  formData.correctAnswer = ''
  formData.analysis = ''
  formRef.value?.resetFields()
}

// 获取题目类型名称
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

// 获取题目类型颜色
const getQuestionTypeColor = (type) => {
  const map = {
    SINGLE_CHOICE: 'primary',
    MULTIPLE_CHOICE: 'success',
    TRUE_FALSE: 'warning',
    FILL_BLANK: 'info',
    SHORT_ANSWER: 'danger'
  }
  return map[type] || ''
}

// 获取审核状态名称
const getAuditStatusName = (status) => {
  const map = {
    0: '待审核',
    1: '已通过',
    2: '未通过'
  }
  return map[status] || '未知'
}

// 获取审核状态颜色
const getAuditStatusColor = (status) => {
  const map = {
    0: 'warning',
    1: 'success',
    2: 'danger'
  }
  return map[status] || 'info'
}

// 初始化
onMounted(() => {
  loadQuestionBanks()
  loadQuestions()
})
</script>

<style scoped>
.question-container {
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

.search-card,
.table-card {
  margin-bottom: 20px;
}

.search-form {
  margin-bottom: 0;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.option-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
</style>

