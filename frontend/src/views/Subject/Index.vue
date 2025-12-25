<template>
  <div class="subject-container">
    <el-card>
      <!-- 搜索表单 -->
      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="关键词">
          <el-input
            v-model="queryForm.keyword"
            placeholder="科目名称/编码"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryForm.status" placeholder="请选择" clearable>
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch">
            查询
          </el-button>
          <el-button :icon="Refresh" @click="handleReset">重置</el-button>
          <el-button
            v-if="hasPermission('subject:create')"
            type="success"
            :icon="Plus"
            @click="handleCreate"
          >
            创建科目
          </el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        stripe
        style="width: 100%"
      >
        <el-table-column prop="subjectName" label="科目名称" min-width="150" />
        <el-table-column prop="subjectCode" label="科目编码" width="120" />
        <el-table-column prop="orgName" label="归属学院" width="150" />
        <el-table-column prop="credit" label="学分" width="80" align="center" />
        <el-table-column prop="studentCount" label="学生人数" width="100" align="center">
          <template #default="{ row }">
            <el-tag>{{ row.studentCount || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createUserName" label="创建人" width="120" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              link
              :icon="View"
              @click="handleDetail(row)"
            >
              详情
            </el-button>
            <el-button
              v-if="hasPermission('subject:update')"
              type="warning"
              link
              :icon="Edit"
              @click="handleEdit(row)"
            >
              编辑
            </el-button>
            <el-button
              v-if="hasPermission('subject:auth')"
              type="success"
              link
              :icon="User"
              @click="handleManagers(row)"
            >
              管理员
            </el-button>
            <el-button
              v-if="hasPermission('subject:students')"
              type="info"
              link
              :icon="User"
              @click="handleStudents(row)"
            >
              学生
            </el-button>
            <el-button
              v-if="hasPermission('subject:delete')"
              type="danger"
              link
              :icon="Delete"
              @click="handleDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryForm.current"
        v-model:page-size="queryForm.size"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSearch"
        @current-change="handleSearch"
      />
    </el-card>

    <!-- 管理员管理对话框 -->
    <ManagerDialog
      v-model="managerDialogVisible"
      :subject="currentSubject"
      @refresh="handleSearch"
    />

    <!-- 学生管理对话框 -->
    <StudentDialog
      v-model="studentDialogVisible"
      :subject="currentSubject"
      @refresh="handleSearch"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, View, Edit, Delete, User } from '@element-plus/icons-vue'
import subjectApi from '@/api/subject'
import { useAuthStore } from '@/stores/modules/auth'
import ManagerDialog from './components/ManagerDialog.vue'
import StudentDialog from './components/StudentDialog.vue'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const managerDialogVisible = ref(false)
const studentDialogVisible = ref(false)
const currentSubject = ref(null)

const queryForm = reactive({
  current: 1,
  size: 10,
  keyword: '',
  status: null
})

// 检查权限
const hasPermission = (permission) => {
  return authStore.hasPermission(permission)
}

// 查询
const handleSearch = async () => {
  try {
    loading.value = true
    const res = await subjectApi.page(queryForm)
    if (res.code === 200) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } catch (error) {
    console.error('查询科目失败:', error)
    ElMessage.error('查询科目失败')
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  queryForm.current = 1
  queryForm.size = 10
  queryForm.keyword = ''
  queryForm.status = null
  handleSearch()
}

// 创建
const handleCreate = () => {
  router.push('/subject/edit')
}

// 详情
const handleDetail = (row) => {
  router.push({
    path: '/subject/detail',
    query: { id: row.subjectId }
  })
}

// 编辑（只修改科目基本信息）
const handleEdit = (row) => {
  router.push({
    path: '/subject/edit',
    query: { id: row.subjectId }
  })
}

// 管理员管理
const handleManagers = (row) => {
  currentSubject.value = row
  managerDialogVisible.value = true
}

// 学生管理
const handleStudents = (row) => {
  currentSubject.value = row
  studentDialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除科目"${row.subjectName}"吗？此操作不可恢复！`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await subjectApi.deleteById(row.subjectId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      handleSearch()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除科目失败:', error)
      ElMessage.error(error.message || '删除失败')
    }
  }
}

onMounted(() => {
  handleSearch()
})
</script>

<style scoped>
.subject-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  justify-content: flex-end;
}
</style>

