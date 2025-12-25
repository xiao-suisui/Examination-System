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
        <el-form-item label="所属科目">
          <SubjectSelector
            v-model="searchForm.subjectId"
            :only-managed="true"
            clearable
            style="width: 200px"
            @change="handleSubjectChange"
          />
        </el-form-item>
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
            filterable
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
          <EnumSelect
            v-model="searchForm.auditStatus"
            :options="AUDIT_STATUS_LABELS"
            placeholder="选择状态"
            style="width: 120px"
          />
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
        :row-key="row => row.paperId"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="paperId" label="ID" width="80" />
        <el-table-column prop="paperName" label="试卷名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="paperType" label="试卷类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getPaperTypeColor(row.paperType)" v-if="row.paperType !== undefined">
              {{ getPaperTypeName(row.paperType) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="totalScore" label="总分" width="80" />
        <el-table-column prop="questionCount" label="题目数" width="80" />
        <el-table-column prop="auditStatus" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getAuditStatusColor(row.auditStatus)" v-if="row.auditStatus !== undefined">
              {{ getAuditStatusName(row.auditStatus) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">查看</el-button>
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="success" @click="handlePreview(row)">预览</el-button>
            <el-button link type="danger" @click="handleDeletePaper(row)">删除</el-button>
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

    <!-- 创建/编辑对话框（仅基础信息） -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
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
            <el-form-item label="所属科目" prop="subjectId">
              <SubjectSelector
                v-model="formData.subjectId"
                :only-managed="true"
                placeholder="请选择科目"
                style="width: 100%"
                @change="handleFormSubjectChange"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="组卷方式" prop="paperType">
              <EnumSelect
                v-model="formData.paperType"
                :options="PAPER_TYPE_LABELS"
                placeholder="请选择组卷方式"
              />
            </el-form-item>
          </el-col>
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

        <el-alert
          v-if="formData.paperId"
          title="提示：题目管理请在试卷详情页进行"
          type="info"
          show-icon
          :closable="false"
          style="margin-bottom: 15px"
        />
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
            <el-radio value="EASY">简单为主</el-radio>
            <el-radio value="MEDIUM">中等为主</el-radio>
            <el-radio value="HARD">困难为主</el-radio>
            <el-radio value="MIXED">均衡分布</el-radio>
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
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, MagicStick } from '@element-plus/icons-vue'
import EnumSelect from '@/components/EnumSelect.vue'
import SubjectSelector from '@/components/SubjectSelector.vue'
import { useTableList } from '@/composables/useTableList'
import paperApi from '@/api/paper'
import questionBankApi from '@/api/questionBank'
import {
  PAPER_TYPE,
  PAPER_TYPE_LABELS,
  AUDIT_STATUS_LABELS,
  getPaperTypeName,
  getPaperTypeColor,
  getAuditStatusName,
  getAuditStatusColor
} from '@/utils/enums'
import { required } from '@/utils/validate'

const router = useRouter()
const route = useRoute()

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
} = useTableList(paperApi, {
  keyword: '',
  subjectId: null,
  bankId: null,
  paperType: null,
  auditStatus: null
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
  searchForm.bankId = null
  if (subjectId) {
    loadQuestionBanks(subjectId)
  } else {
    loadQuestionBanks()
  }
}

// 表单中科目变化（加载对应的题库）
const handleFormSubjectChange = (subjectId) => {
  formData.bankId = null
  if (subjectId) {
    loadQuestionBanks(subjectId)
  } else {
    loadQuestionBanks()
  }
}

// ==================== 对话框 ====================
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const formRef = ref(null)

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
  paperType: PAPER_TYPE.MANUAL,
  subjectId: null,
  bankId: null,
  passScore: 60,
  totalScore: 100,
  description: ''
})

// 表单验证规则（使用统一验证函数）
const formRules = {
  paperName: [required('请输入试卷名称')],
  paperType: [required('请选择组卷方式', 'change')],
  subjectId: [required('请选择所属科目', 'change')],
  bankId: [required('请选择题库', 'change')]
}


// ==================== 对话框操作 ====================

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建试卷'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = async (row) => {
  dialogTitle.value = '编辑试卷基础信息'

  // 如果传入的是试卷ID（从URL参数来），需要先加载试卷数据
  if (typeof row === 'number' || typeof row === 'string') {
    try {
      const res = await paperApi.getById(row)
      if (res.code === 200 && res.data) {
        Object.assign(formData, {
          paperId: res.data.paperId,
          paperName: res.data.paperName,
          paperType: res.data.paperType,
          subjectId: res.data.subjectId,
          bankId: res.data.bankId,
          passScore: res.data.passScore,
          totalScore: res.data.totalScore,
          description: res.data.description
        })
        // 加载该科目的题库
        if (res.data.subjectId) {
          loadQuestionBanks(res.data.subjectId)
        }
      } else {
        ElMessage.error('加载试卷数据失败')
        return
      }
    } catch (error) {
      console.error('加载试卷数据失败:', error)
      ElMessage.error('加载试卷数据失败')
      return
    }
  } else {
    // 如果传入的是完整的试卷对象
    Object.assign(formData, {
      paperId: row.paperId,
      paperName: row.paperName,
      paperType: row.paperType,
      subjectId: row.subjectId,
      bankId: row.bankId,
      description: row.description
    })
    // 加载该科目的题库
    if (row.subjectId) {
      loadQuestionBanks(row.subjectId)
    }
  }

  dialogVisible.value = true
}

// 查看
const handleView = (row) => {
  router.push({ name: 'PaperDetail', params: { id: row.paperId } })
}

// 预览
const handlePreview = (row) => {
  ElMessage.info('预览试卷：' + row.paperName)
}

// 删除（使用 useTableList 提供的）
const handleDeletePaper = (row) => {
  handleDelete(
    row.paperId,
    `确定要删除试卷"${row.paperName}"吗？`
  )
}

// 智能组卷
const handleAutoGenerate = () => {
  autoGenerateVisible.value = true
}

const submitAutoGenerate = async () => {
  // 验证必填项
  if (!autoGenerateForm.paperName) {
    ElMessage.warning('请输入试卷名称')
    return
  }
  if (!autoGenerateForm.bankId) {
    ElMessage.warning('请选择题库')
    return
  }

  // 构建组卷规则列表
  const rules = []

  // 单选题规则
  if (autoGenerateForm.singleChoiceCount > 0) {
    rules.push({
      bankId: autoGenerateForm.bankId,
      questionType: 1, // 单选题
      totalNum: autoGenerateForm.singleChoiceCount,
      singleScore: 2,
      easyNum: 0,
      mediumNum: 0,
      hardNum: 0
    })
  }

  // 多选题规则
  if (autoGenerateForm.multipleChoiceCount > 0) {
    rules.push({
      bankId: autoGenerateForm.bankId,
      questionType: 2, // 多选题
      totalNum: autoGenerateForm.multipleChoiceCount,
      singleScore: 3,
      easyNum: 0,
      mediumNum: 0,
      hardNum: 0
    })
  }

  // 判断题规则
  if (autoGenerateForm.trueFalseCount > 0) {
    rules.push({
      bankId: autoGenerateForm.bankId,
      questionType: 3, // 判断题
      totalNum: autoGenerateForm.trueFalseCount,
      singleScore: 2,
      easyNum: 0,
      mediumNum: 0,
      hardNum: 0
    })
  }

  // 填空题规则
  if (autoGenerateForm.fillBlankCount > 0) {
    rules.push({
      bankId: autoGenerateForm.bankId,
      questionType: 4, // 填空题
      totalNum: autoGenerateForm.fillBlankCount,
      singleScore: 5,
      easyNum: 0,
      mediumNum: 0,
      hardNum: 0
    })
  }

  // 主观题规则
  if (autoGenerateForm.shortAnswerCount > 0) {
    rules.push({
      bankId: autoGenerateForm.bankId,
      questionType: 5, // 主观题
      totalNum: autoGenerateForm.shortAnswerCount,
      singleScore: 10,
      easyNum: 0,
      mediumNum: 0,
      hardNum: 0
    })
  }

  if (rules.length === 0) {
    ElMessage.warning('请至少选择一种题型')
    return
  }

  // 构建请求数据
  const requestData = {
    paper: {
      paperName: autoGenerateForm.paperName,
      paperType: 2, // 自动组卷
      description: '通过智能组卷生成的试卷',
      passScore: 60,
      auditStatus: 0 // 草稿
    },
    rules: rules
  }

  try {
    const res = await paperApi.autoGenerate(requestData)
    if (res.code === 200) {
      ElMessage.success('组卷成功')
      autoGenerateVisible.value = false
      loadPapers()
      // 重置表单
      autoGenerateForm.paperName = ''
      autoGenerateForm.bankId = null
      autoGenerateForm.singleChoiceCount = 10
      autoGenerateForm.multipleChoiceCount = 5
      autoGenerateForm.trueFalseCount = 5
      autoGenerateForm.fillBlankCount = 3
      autoGenerateForm.shortAnswerCount = 2
      autoGenerateForm.difficultyMode = 'MIXED'
    } else {
      ElMessage.error(res.message || '组卷失败')
    }
  } catch (error) {
    console.error('组卷失败:', error)
    ElMessage.error('组卷失败')
  }
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
  formData.paperType = PAPER_TYPE.MANUAL  // 默认手动组卷
  formData.subjectId = null
  formData.bankId = null
  formData.passScore = 60
  formData.totalScore = 100
  formData.description = ''
  formData.questions = []
  selectedQuestions.value = []
  formRef.value.resetFields()
}


// ==================== 初始化 ====================
onMounted(async () => {
  loadQuestionBanks()
  await loadData()

  // 处理 URL query 参数
  const { edit, tab } = route.query
  if (edit) {
    // 如果有 edit 参数，自动打开编辑对话框
    await nextTick()
    await handleEdit(edit)


    // 清除 URL 参数，避免刷新页面时重复打开
    router.replace({ query: {} })
  }
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
