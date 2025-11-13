<template>
  <div class="exam-list-container">
    <el-card shadow="never">
      <!-- 搜索栏 -->
      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="考试名称">
          <el-input
            v-model="queryForm.keyword"
            placeholder="请输入考试名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="考试状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable>
            <el-option label="全部" :value="null" />
            <el-option label="草稿" :value="0" />
            <el-option label="已发布" :value="1" />
            <el-option label="进行中" :value="2" />
            <el-option label="已结束" :value="3" />
            <el-option label="已取消" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
          <el-button :icon="Refresh" @click="handleReset">重置</el-button>
          <el-button type="success" :icon="Plus" @click="handleCreate">创建考试</el-button>
        </el-form-item>
      </el-form>

      <!-- 考试列表 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        stripe
        border
        style="width: 100%"
      >
        <el-table-column prop="examId" label="ID" width="80" />
        <el-table-column prop="examName" label="考试名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="paperName" label="试卷名称" min-width="150" show-overflow-tooltip />
        <el-table-column label="考试状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusColor(row.examStatus)">
              {{ getStatusText(row.examStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.startTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="endTime" label="结束时间" width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.endTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
        <el-table-column label="参与情况" width="120" align="center">
          <template #default="{ row }">
            <span>{{ row.submittedCount || 0 }} / {{ row.participantCount || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="300" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleView(row)">详情</el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)" v-if="row.examStatus === 0">编辑</el-button>
            <el-button link type="success" size="small" @click="handlePublish(row)" v-if="row.examStatus === 0">发布</el-button>
            <el-button link type="warning" size="small" @click="handleStart(row)" v-if="row.examStatus === 1">开始</el-button>
            <el-button link type="info" size="small" @click="handleEnd(row)" v-if="row.examStatus === 2">结束</el-button>
            <el-button link type="primary" size="small" @click="handleMonitor(row)" v-if="row.examStatus === 2">监控</el-button>
            <el-button link type="primary" size="small" @click="handleStatistics(row)" v-if="row.examStatus === 3">统计</el-button>
            <el-dropdown @command="(cmd) => handleMoreAction(cmd, row)">
              <el-button link type="primary" size="small">
                更多<el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="copy">复制</el-dropdown-item>
                  <el-dropdown-item command="cancel" v-if="[0, 1].includes(row.examStatus)">取消</el-dropdown-item>
                  <el-dropdown-item command="delete" v-if="row.examStatus === 0" divided>删除</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryForm.current"
        v-model:page-size="queryForm.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 复制考试对话框 -->
    <el-dialog v-model="copyDialogVisible" title="复制考试" width="400px">
      <el-form :model="copyForm" label-width="100px">
        <el-form-item label="新考试名称" required>
          <el-input v-model="copyForm.newTitle" placeholder="请输入新考试名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="copyDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCopyConfirm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, ArrowDown } from '@element-plus/icons-vue'
import { getExamPage, deleteExam, publishExam, startExam, endExam, cancelExam, copyExam } from '@/api/exam'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const total = ref(0)

const queryForm = reactive({
  current: 1,
  size: 10,
  keyword: '',
  status: null
})

const copyDialogVisible = ref(false)
const copyForm = reactive({
  examId: null,
  newTitle: ''
})

// 获取考试列表
const getList = async () => {
  loading.value = true
  try {
    const res = await getExamPage(queryForm)
    if (res.code === 200) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } catch (error) {
    ElMessage.error('获取考试列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryForm.current = 1
  getList()
}

// 重置
const handleReset = () => {
  queryForm.keyword = ''
  queryForm.status = null
  queryForm.current = 1
  getList()
}

// 创建考试
const handleCreate = () => {
  router.push({ name: 'ExamEdit' })
}

// 查看详情
const handleView = (row) => {
  router.push({ name: 'ExamDetail', params: { id: row.examId } })
}

// 编辑
const handleEdit = (row) => {
  router.push({ name: 'ExamEdit', params: { id: row.examId } })
}

// 发布
const handlePublish = async (row) => {
  try {
    await ElMessageBox.confirm('确认发布该考试吗？发布后考生将收到通知。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await publishExam(row.examId)
    if (res.code === 200) {
      ElMessage.success('发布成功')
      getList()
    } else {
      ElMessage.error(res.message || '发布失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('发布失败')
    }
  }
}

// 开始考试
const handleStart = async (row) => {
  try {
    await ElMessageBox.confirm('确认开始该考试吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await startExam(row.examId)
    if (res.code === 200) {
      ElMessage.success('开始成功')
      getList()
    } else {
      ElMessage.error(res.message || '开始失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('开始失败')
    }
  }
}

// 结束考试
const handleEnd = async (row) => {
  try {
    await ElMessageBox.confirm('确认结束该考试吗？结束后将无法继续作答。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await endExam(row.examId)
    if (res.code === 200) {
      ElMessage.success('结束成功')
      getList()
    } else {
      ElMessage.error(res.message || '结束失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('结束失败')
    }
  }
}

// 监控
const handleMonitor = (row) => {
  router.push({ name: 'ExamMonitor', params: { id: row.examId } })
}

// 统计
const handleStatistics = (row) => {
  router.push({ name: 'ExamDetail', params: { id: row.examId }, query: { tab: 'statistics' } })
}

// 更多操作
const handleMoreAction = (command, row) => {
  switch (command) {
    case 'copy':
      copyForm.examId = row.examId
      copyForm.newTitle = row.examName + ' - 副本'
      copyDialogVisible.value = true
      break
    case 'cancel':
      handleCancel(row)
      break
    case 'delete':
      handleDelete(row)
      break
  }
}

// 取消考试
const handleCancel = async (row) => {
  try {
    await ElMessageBox.confirm('确认取消该考试吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await cancelExam(row.examId)
    if (res.code === 200) {
      ElMessage.success('取消成功')
      getList()
    } else {
      ElMessage.error(res.message || '取消失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('取消失败')
    }
  }
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除该考试吗？此操作不可恢复。', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'error'
    })

    const res = await deleteExam(row.examId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      getList()
    } else {
      ElMessage.error(res.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 确认复制
const handleCopyConfirm = async () => {
  if (!copyForm.newTitle) {
    ElMessage.warning('请输入新考试名称')
    return
  }

  try {
    const res = await copyExam(copyForm.examId, copyForm.newTitle)
    if (res.code === 200) {
      ElMessage.success('复制成功')
      copyDialogVisible.value = false
      getList()
    } else {
      ElMessage.error(res.message || '复制失败')
    }
  } catch (error) {
    ElMessage.error('复制失败')
  }
}

// 分页
const handleSizeChange = (size) => {
  queryForm.size = size
  getList()
}

const handleCurrentChange = (current) => {
  queryForm.current = current
  getList()
}

// 状态颜色
const getStatusColor = (status) => {
  const colorMap = {
    0: 'info',     // 草稿
    1: 'success',  // 已发布
    2: 'warning',  // 进行中
    3: '',         // 已结束
    4: 'danger'    // 已取消
  }
  return colorMap[status] || ''
}

// 状态文本
const getStatusText = (status) => {
  const textMap = {
    0: '草稿',
    1: '已发布',
    2: '进行中',
    3: '已结束',
    4: '已取消'
  }
  return textMap[status] || '未知'
}

// 格式化时间
const formatDateTime = (datetime) => {
  if (!datetime) return '-'
  return datetime.replace('T', ' ')
}

onMounted(() => {
  getList()
})
</script>

<style scoped>
.exam-list-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}
</style>
