<template>
  <div class="exam-container">
    <!-- 搜索区域 -->
    <SearchForm v-model="searchForm" @search="handleSearch" @reset="handleReset">
      <el-form-item label="所属科目">
        <SubjectSelector
          v-model="searchForm.subjectId"
          :only-managed="true"
          clearable
          style="width: 200px"
          @change="handleSearch"
        />
      </el-form-item>

      <el-form-item label="考试名称">
        <el-input
          v-model="searchForm.keyword"
          placeholder="请输入考试名称"
          clearable
          style="width: 200px"
        />
      </el-form-item>

      <el-form-item label="考试状态">
        <EnumSelect
          v-model="searchForm.status"
          :options="EXAM_STATUS_LABELS"
          placeholder="选择状态"
          style="width: 150px"
        />
      </el-form-item>
    </SearchForm>

    <!-- 表格区域 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>考试列表</span>
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            创建考试
          </el-button>
        </div>
      </template>

      <el-table
        :data="tableData"
        :loading="loading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="examId" label="ID" width="80" />
        <el-table-column prop="examName" label="考试名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="paperName" label="试卷名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="startTime" label="开始时间" width="180" />
        <el-table-column prop="endTime" label="结束时间" width="180" />
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getExamStatusColor(row.examStatus)" size="small">
              {{ getExamStatusName(row.examStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">查看</el-button>
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="success" @click="handleMonitor(row)">监控</el-button>
            <el-button link type="danger" @click="handleDeleteExam(row)">删除</el-button>
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
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import { useTableList } from '@/composables/useTableList'
import EnumSelect from '@/components/EnumSelect.vue'
import SubjectSelector from '@/components/SubjectSelector.vue'
import SearchForm from '@/components/common/SearchForm.vue'
import examApi from '@/api/exam'
import {
  EXAM_STATUS_LABELS,
  getExamStatusName,
  getExamStatusColor
} from '@/utils/enums'

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
} = useTableList(examApi, {
  keyword: '',
  subjectId: null,
  status: null
})

// ==================== 生命周期 ====================
onMounted(() => {
  loadData()
})

// ==================== 页面操作 ====================
const handleCreate = () => {
  router.push('/exam/create')
}

const handleView = (row) => {
  router.push(`/exam/${row.examId}`)
}

const handleEdit = (row) => {
  router.push(`/exam/edit/${row.examId}`)
}

const handleMonitor = (row) => {
  router.push(`/exam/monitor?examId=${row.examId}`)
}

const handleDeleteExam = (row) => {
  handleDelete(
    row.examId,
    `确定要删除考试"${row.examName}"吗？`
  )
}
</script>

<style scoped>
.exam-container {
  padding: 20px;
}

.table-card {
  margin-top: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: bold;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>

