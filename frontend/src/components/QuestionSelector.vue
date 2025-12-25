<template>
  <el-dialog
    v-model="visible"
    title="选择题目"
    width="80%"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <!-- 搜索栏 -->
    <el-form :inline="true" :model="searchForm" class="search-form">
      <el-form-item label="关键词">
        <el-input
          v-model="searchForm.keyword"
          placeholder="搜索题目内容"
          clearable
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item label="题库">
        <el-select
          v-model="searchForm.bankId"
          placeholder="全部题库"
          clearable
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
      <el-form-item label="题型">
        <el-select
          v-model="searchForm.questionType"
          placeholder="全部题型"
          clearable
          style="width: 150px"
        >
          <el-option label="单选题" :value="QUESTION_TYPE.SINGLE_CHOICE" />
          <el-option label="多选题" :value="QUESTION_TYPE.MULTIPLE_CHOICE" />
          <el-option label="判断题" :value="QUESTION_TYPE.TRUE_FALSE" />
          <el-option label="填空题" :value="QUESTION_TYPE.FILL_BLANK" />
          <el-option label="简答题" :value="QUESTION_TYPE.SUBJECTIVE" />
        </el-select>
      </el-form-item>
      <el-form-item label="难度">
        <el-select
          v-model="searchForm.difficulty"
          placeholder="全部难度"
          clearable
          style="width: 120px"
        >
          <el-option label="简单" :value="1" />
          <el-option label="中等" :value="2" />
          <el-option label="困难" :value="3" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 题目列表 -->
    <el-table
      ref="tableRef"
      :data="tableData"
      v-loading="loading"
      :row-key="row => row.questionId"
      @selection-change="handleSelectionChange"
      max-height="400"
    >
      <el-table-column type="selection" width="55" :reserve-selection="true" />
      <el-table-column prop="questionContent" label="题目内容" show-overflow-tooltip min-width="300">
        <template #default="{ row }">
          <div v-html="row.questionContent"></div>
        </template>
      </el-table-column>
      <el-table-column prop="questionType" label="题型" width="100">
        <template #default="{ row }">
          <el-tag :type="getQuestionTypeColor(row.questionType)" size="small">
            {{ getQuestionTypeName(row.questionType) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="difficulty" label="难度" width="80">
        <template #default="{ row }">
          <el-rate
            :model-value="row.difficulty"
            disabled
            :max="3"
            :colors="['#67C23A', '#E6A23C', '#F56C6C']"
            void-color="#dcdfe6"
          />
        </template>
      </el-table-column>
      <el-table-column prop="defaultScore" label="默认分值" width="90" />
      <el-table-column label="自定义分值" width="120">
        <template #default="{ row }">
          <el-input-number
            v-model="row.customScore"
            :min="0.5"
            :max="100"
            :step="0.5"
            size="small"
            controls-position="right"
            style="width: 100%"
          />
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination
      v-model:current-page="pagination.current"
      v-model:page-size="pagination.size"
      :total="pagination.total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="loadQuestions"
      @current-change="loadQuestions"
      style="margin-top: 20px"
    />

    <template #footer>
      <div class="dialog-footer">
        <div class="selected-info">
          已选择 <span class="count">{{ selectedQuestions.length }}</span> 道题目，
          总分 <span class="score">{{ totalScore }}</span> 分
        </div>
        <div>
          <el-button @click="handleClose">取消</el-button>
          <el-button type="primary" @click="handleConfirm">
            确定（{{ selectedQuestions.length }}）
          </el-button>
        </div>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import questionApi from '@/api/question'
import questionBankApi from '@/api/questionBank'
import { QUESTION_TYPE, getQuestionTypeName, getQuestionTypeColor } from '@/utils/enums'

// Props
const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  bankId: {
    type: Number,
    default: null
  },
  existingQuestions: {
    type: Array,
    default: () => []
  }
})

// Emits
const emit = defineEmits(['update:modelValue', 'confirm'])

// 控制显示隐藏
const visible = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})

// 状态
const loading = ref(false)
const tableRef = ref()
const tableData = ref([])
const questionBanks = ref([])
const selectedQuestions = ref([])

// 搜索表单
const searchForm = ref({
  keyword: '',
  bankId: null,
  questionType: null,
  difficulty: null
})

// 分页
const pagination = ref({
  current: 1,
  size: 10,
  total: 0
})

// 总分
const totalScore = computed(() => {
  return selectedQuestions.value.reduce((sum, q) => {
    return sum + (q.customScore || q.defaultScore || 0)
  }, 0)
})

// 监听bankId变化
watch(() => props.bankId, (newVal) => {
  if (newVal) {
    searchForm.value.bankId = newVal
  }
}, { immediate: true })

// 监听visible变化
watch(visible, (newVal) => {
  if (newVal) {
    loadQuestionBanks()
    loadQuestions()
    // 恢复已选择的题目
    if (props.existingQuestions.length > 0) {
      selectedQuestions.value = JSON.parse(JSON.stringify(props.existingQuestions))
    }
  }
})

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
    const res = await questionApi.page({
      current: pagination.value.current,
      size: pagination.value.size,
      keyword: searchForm.value.keyword || undefined,
      bankId: searchForm.value.bankId || undefined,
      questionType: searchForm.value.questionType || undefined,
      difficulty: searchForm.value.difficulty || undefined
    })

    if (res.code === 200) {
      tableData.value = res.data.records.map(q => ({
        ...q,
        customScore: q.defaultScore
      }))
      pagination.value.total = res.data.total

      // 恢复选中状态
      await nextTick()
      tableData.value.forEach(row => {
        const isSelected = selectedQuestions.value.some(q => q.questionId === row.questionId)
        if (isSelected) {
          tableRef.value?.toggleRowSelection(row, true)
        }
      })
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.value.current = 1
  loadQuestions()
}

// 重置
const handleReset = () => {
  searchForm.value = {
    keyword: '',
    bankId: props.bankId || null,
    questionType: null,
    difficulty: null
  }
  handleSearch()
}

// 选择变化
const handleSelectionChange = (selection) => {
  // 合并当前页的选择和其他页已选择的题目
  const currentPageIds = tableData.value.map(q => q.questionId)
  const otherPageSelected = selectedQuestions.value.filter(
    q => !currentPageIds.includes(q.questionId)
  )
  selectedQuestions.value = [...otherPageSelected, ...selection]
}

// 确定
const handleConfirm = () => {
  if (selectedQuestions.value.length === 0) {
    ElMessage.warning('请至少选择一道题目')
    return
  }

  // 确保每道题都有分值
  const questionsWithScore = selectedQuestions.value.map(q => ({
    ...q,
    score: q.customScore || q.defaultScore
  }))

  emit('confirm', questionsWithScore)
  handleClose()
}

// 关闭
const handleClose = () => {
  visible.value = false
  // 使用 nextTick 替代 setTimeout，更安全
  nextTick(() => {
    // 重置状态
    selectedQuestions.value = []
    searchForm.value = {
      keyword: '',
      bankId: props.bankId || null,
      questionType: null,
      difficulty: null
    }
    pagination.value = {
      current: 1,
      size: 10,
      total: 0
    }
  })
}
</script>

<style scoped>
.search-form {
  padding: 10px;
  background: #f5f5f5;
  border-radius: 4px;
  margin-bottom: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.selected-info {
  font-size: 14px;
  color: #606266;
}

.selected-info .count {
  color: #409eff;
  font-weight: bold;
  font-size: 16px;
}

.selected-info .score {
  color: #67c23a;
  font-weight: bold;
  font-size: 16px;
}
</style>

