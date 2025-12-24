<template>
  <div class="question-container">
    <!-- 页面头部 -->
    <PageHeader title="题目管理" description="管理系统中的所有题目">
      <template #extra>
        <el-button type="primary" @click="handleCreate">
          <el-icon><Plus /></el-icon>
          创建题目
        </el-button>
      </template>
    </PageHeader>

    <!-- 搜索区域 -->
    <SearchForm v-model="searchForm" @search="handleSearch" @reset="handleReset">
      <el-form-item label="所属科目">
        <SubjectSelector
          v-model="searchForm.subjectId"
          :only-managed="true"
          clearable
          style="width: 200px"
          @change="handleSubjectChange"
        />
      </el-form-item>

      <el-form-item label="题目内容">
        <el-input
          v-model="searchForm.keyword"
          placeholder="请输入题目内容"
          clearable
          style="width: 200px"
        />
      </el-form-item>

      <el-form-item label="题库">
        <el-select
          v-model="searchForm.bankId"
          placeholder="选择题库"
          clearable
          filterable
          style="width: 150px"
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
        <EnumSelect
          v-model="searchForm.questionType"
          :options="QUESTION_TYPE_LABELS"
          placeholder="选择类型"
          style="width: 150px"
        />
      </el-form-item>

      <el-form-item label="难度">
        <EnumSelect
          v-model="searchForm.difficulty"
          :options="DIFFICULTY_LABELS"
          placeholder="选择难度"
          style="width: 120px"
        />
      </el-form-item>
    </SearchForm>

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
            <EnumTag
              v-if="row.questionType !== undefined"
              :model-value="row.questionType"
              :label-map="QUESTION_TYPE_LABELS"
              :type-map="QUESTION_TYPE_COLORS"
              size="small"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>

        <el-table-column prop="difficulty" label="难度" width="120">
          <template #default="{ row }">
            <el-rate
              :model-value="Number(row.difficulty) || 0"
              :max="3"
              disabled
              text-color="#ff9900"
            />
          </template>
        </el-table-column>

        <el-table-column prop="defaultScore" label="分值" width="80">
          <template #default="{ row }">
            {{ row.defaultScore || '-' }}
          </template>
        </el-table-column>

        <el-table-column prop="auditStatus" label="审核状态" width="100">
          <template #default="{ row }">
            <EnumTag
              v-if="row.auditStatus !== undefined"
              :model-value="row.auditStatus"
              :label-map="AUDIT_STATUS_LABELS"
              :type-map="AUDIT_STATUS_COLORS"
              size="small"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">查看</el-button>
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteQuestion(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="searchForm.current"
          v-model:page-size="searchForm.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
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
            <el-option label="单选题" :value="QUESTION_TYPE.SINGLE_CHOICE" />
            <el-option label="多选题" :value="QUESTION_TYPE.MULTIPLE_CHOICE" />
            <el-option label="判断题" :value="QUESTION_TYPE.TRUE_FALSE" />
            <el-option label="填空题" :value="QUESTION_TYPE.FILL_BLANK" />
            <el-option label="简答题" :value="QUESTION_TYPE.SUBJECTIVE" />
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
          <el-rate v-model="formData.difficulty" :max="3"/>
        </el-form-item>

        <el-form-item label="分值" prop="defaultScore">
          <el-input-number
            v-model="formData.defaultScore"
            :min="1"
            :max="100"
            controls-position="right"
          />
        </el-form-item>

        <!-- 选项（选择题和判断题） -->
        <template v-if="[QUESTION_TYPE.SINGLE_CHOICE, QUESTION_TYPE.MULTIPLE_CHOICE, QUESTION_TYPE.TRUE_FALSE].includes(formData.questionType)">
          <el-form-item label="选项">
            <div v-for="(option, index) in formData.options" :key="index" class="option-item">
              <span class="option-seq">{{ option.optionSeq }}.</span>
              <el-input
                v-model="option.optionContent"
                placeholder="请输入选项内容"
                style="width: 350px; margin-left: 10px"
              />
              <el-checkbox
                :model-value="option.isCorrect === 1"
                @change="(val) => option.isCorrect = val ? 1 : 0"
                style="margin-left: 10px"
              >
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
          v-if="[QUESTION_TYPE.FILL_BLANK, QUESTION_TYPE.SUBJECTIVE].includes(formData.questionType)"
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
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { PageHeader, SearchForm, EnumTag } from '@/components/common'
import EnumSelect from '@/components/EnumSelect.vue'
import SubjectSelector from '@/components/SubjectSelector.vue'
import { useTableList } from '@/composables/useTableList'
import questionApi from '@/api/question'
import questionBankApi from '@/api/questionBank'
import {
  QUESTION_TYPE,
  QUESTION_TYPE_LABELS,
  QUESTION_TYPE_COLORS,
  DIFFICULTY_LABELS,
  AUDIT_STATUS_LABELS,
  AUDIT_STATUS_COLORS
} from '@/utils/enums'
import { required, length, range } from '@/utils/validate'

const router = useRouter()

// ==================== 使用组合式函数 ====================
const {
  loading,
  tableData,
  total,
  searchForm,
  loadData,
  handleSearch,
  handleReset,
  handlePageChange,
  handleSizeChange,
  handleDelete
} = useTableList(questionApi, {
  keyword: '',
  subjectId: null,
  bankId: null,
  questionType: null,
  difficulty: null
})

// ==================== 题库列表 ====================
const questionBanks = ref([])

const loadQuestionBanks = async (subjectId = null) => {
  try {
    const params = subjectId ? { subjectId } : {}
    const res = await questionBankApi.page({
      current: 1,
      size: 100,
      ...params
    })
    if (res.code === 200) {
      questionBanks.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载题库失败', error)
  }
}

// 科目选择变化
const handleSubjectChange = (subjectId) => {
  // 清空题库选择
  searchForm.bankId = null
  // 重新加载该科目的题库
  if (subjectId) {
    loadQuestionBanks(subjectId)
  } else {
    loadQuestionBanks()
  }
  // 执行搜索
  handleSearch()
}

// ==================== 对话框 ====================
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const formRef = ref(null)

// 表单数据
const formData = reactive({
  questionId: null,
  bankId: null,
  questionType: QUESTION_TYPE.SINGLE_CHOICE,  // 默认单选题（值为 1）
  questionContent: '',
  difficulty: 2,
  defaultScore: 5,
  options: [],
  correctAnswer: '',
  analysis: '',
  knowledgeIds: ''
})

// 表单验证规则（使用通用验证函数）
const formRules = {
  bankId: [required('请选择题库', 'change')],
  questionType: [required('请选择题目类型', 'change')],
  questionContent: [
    required('请输入题目内容'),
    length(5, 1000)
  ],
  defaultScore: [
    required('请输入分值'),
    range(0, 100, '分值必须在 0 到 100 之间')
  ],
  difficulty: [required('请选择难度', 'change')]
}

// ==================== 对话框操作 ====================

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建题目'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = async (row) => {
  dialogTitle.value = '编辑题目'

  // 先加载完整的题目详情（包含选项）
  try {
    const res = await questionApi.getById(row.questionId)
    if (res.code === 200) {
      const question = res.data

      // 正确赋值表单数据
      Object.assign(formData, {
        questionId: question.questionId,
        bankId: question.bankId,
        questionType: question.questionType,
        questionContent: question.questionContent,
        difficulty: Number(question.difficulty) || 2,
        defaultScore: question.defaultScore,
        analysis: question.answerAnalysis || question.analysis || '',
        // 深拷贝选项数组
        options: question.options ? JSON.parse(JSON.stringify(question.options)) : [],
        // 填空题和主观题的答案
        correctAnswer: question.correctAnswer || question.referenceAnswer || ''
      })

      dialogVisible.value = true
    } else {
      ElMessage.error('加载题目详情失败')
    }
  } catch (error) {
    console.error('加载题目详情失败:', error)
    ElMessage.error('加载题目详情失败')
  }
}

// 查看
const handleView = (row) => {
  router.push({
    name: 'QuestionDetail',
    params: { id: row.questionId }
  }).catch(err => {
    console.error('路由跳转失败:', err)
    ElMessage.error('页面跳转失败')
  })
}

// 删除（使用 useTableList 提供的，只需传递 ID 和确认消息）
const handleDeleteQuestion = (row) => {
  handleDelete(
    row.questionId,
    `确定要删除题目"${row.questionContent.substring(0, 20)}..."吗？`
  )
}

// 添加选项
const addOption = () => {
  const optionSeq = String.fromCharCode(65 + formData.options.length) // A, B, C, D...
  formData.options.push({
    optionSeq: optionSeq,
    optionContent: '',
    isCorrect: 0  // 后端使用 0/1 表示
  })
}

// 删除选项
const removeOption = (index) => {
  formData.options.splice(index, 1)

  // 重新生成选项序号
  formData.options.forEach((option, idx) => {
    option.optionSeq = String.fromCharCode(65 + idx) // A, B, C, D...
  })
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
        loadData()
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
  // 重置所有表单字段
  formData.questionId = null
  formData.bankId = null
  formData.questionType = QUESTION_TYPE.SINGLE_CHOICE
  formData.questionContent = ''
  formData.difficulty = 2
  formData.defaultScore = 5
  formData.options = []
  formData.correctAnswer = ''
  formData.analysis = ''
  formData.knowledgeIds = ''

  // 清除表单验证状态
  formRef.value?.resetFields()
}


// ==================== 初始化 ====================
onMounted(() => {
  loadQuestionBanks()
  loadData()
})
</script>

<style scoped>
.question-container {
  padding: 20px;
}

.table-card {
  margin-top: 16px;
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

.option-seq {
  font-weight: bold;
  font-size: 16px;
  color: #409eff;
  min-width: 30px;
}
</style>
