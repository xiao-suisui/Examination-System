<template>
  <div class="question-bank-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>题库管理</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        创建题库
      </el-button>
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
        <el-form-item label="题库名称">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入题库名称"
            clearable
            @clear="handleSearch"
          />
        </el-form-item>
        <el-form-item label="题库类型">
          <el-select
            v-model="searchForm.bankType"
            placeholder="选择类型"
            clearable
            style="width: 120px"
          >
            <el-option label="公共题库" :value="BANK_TYPE.PUBLIC" />
            <el-option label="私有题库" :value="BANK_TYPE.PRIVATE" />
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
        <el-table-column prop="bankId" label="ID" width="80" />
        <el-table-column prop="bankName" label="题库名称" min-width="200" />
        <el-table-column prop="description" label="描述" min-width="300" show-overflow-tooltip />
        <el-table-column prop="bankType" label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getBankTypeColor(row.bankType)" v-if="row.bankType">
              {{ getBankTypeName(row.bankType) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="questionCount" label="题目数" width="100" align="center" />
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
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="题库名称" prop="bankName">
          <el-input v-model="formData.bankName" placeholder="请输入题库名称" />
        </el-form-item>
        <el-form-item label="题库类型" prop="bankType">
          <el-radio-group v-model="formData.bankType">
            <el-radio :value="BANK_TYPE.PUBLIC">公共题库</el-radio>
            <el-radio :value="BANK_TYPE.PRIVATE">私有题库</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="题库描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="4"
            placeholder="请输入题库描述"
          />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number
            v-model="formData.sort"
            :min="0"
            :max="9999"
            controls-position="right"
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
import questionBankApi from '@/api/questionBank'
import SubjectSelector from '@/components/SubjectSelector.vue'
import {
  BANK_TYPE,
  getBankTypeName,
  getBankTypeColor
} from '@/utils/enums'

const router = useRouter()

// 搜索表单
const searchForm = reactive({
  keyword: '',
  bankType: null,
  subjectId: null
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

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
  bankId: null,
  bankName: '',
  bankType: BANK_TYPE.PUBLIC,
  description: '',
  sort: 0
})

// 表单验证规则
const formRules = {
  bankName: [
    { required: true, message: '请输入题库名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  subjectId: [
    { required: true, message: '请选择所属科目', trigger: 'change' }
  ],
  bankType: [
    { required: true, message: '请选择题库类型', trigger: 'change' }
  ]
}

// 加载题库列表
const loadQuestionBanks = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword || undefined,
      bankType: searchForm.bankType || undefined,
      subjectId: searchForm.subjectId || undefined
    }
    const res = await questionBankApi.page(params)
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
  loadQuestionBanks()
}

// 重置
const handleReset = () => {
  searchForm.keyword = ''
  searchForm.bankType = null
  searchForm.subjectId = null
  handleSearch()
}

// 科目选择变化
const handleSubjectChange = (subjectId) => {
  handleSearch()
}

// 分页变化
const handleSizeChange = () => {
  loadQuestionBanks()
}

const handleCurrentChange = () => {
  loadQuestionBanks()
}

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建题库'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑题库'
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 查看
const handleView = (row) => {
  router.push({
    name: 'QuestionBankDetail',
    params: { id: row.bankId }
  }).catch(err => {
    console.error('路由跳转失败:', err)
    ElMessage.error('页面跳转失败')
  })
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题库"${row.bankName}"吗？`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await questionBankApi.deleteById(row.bankId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadQuestionBanks()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const res = formData.bankId
        ? await questionBankApi.update(formData.bankId, formData)
        : await questionBankApi.create(formData)

      if (res.code === 200) {
        ElMessage.success(formData.bankId ? '更新成功' : '创建成功')
        dialogVisible.value = false
        loadQuestionBanks()
      }
    } catch (error) {
      ElMessage.error(formData.bankId ? '更新失败' : '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 重置表单
const resetForm = () => {
  formData.bankId = null
  formData.bankName = ''
  formData.subjectId = null
  formData.bankType = BANK_TYPE.PUBLIC
  formData.description = ''
  formData.sort = 0
  formRef.value?.resetFields()
}


// 初始化
onMounted(() => {
  loadQuestionBanks()
})
</script>

<style scoped>
.question-bank-container {
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

.form-tip {
  margin-left: 10px;
  color: #909399;
  font-size: 12px;
}
</style>
