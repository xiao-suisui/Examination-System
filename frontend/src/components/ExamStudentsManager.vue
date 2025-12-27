<template>
  <div class="exam-students-manager">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>考生管理 ({{ students.length }})</span>
          <div class="header-actions">
            <el-button
              v-if="subjectId"
              type="success"
              @click="handleImportFromSubject"
              :loading="importing"
            >
              <el-icon><Download /></el-icon>
              从科目导入
            </el-button>
            <el-button type="primary" @click="showAddDialog = true">
              <el-icon><Plus /></el-icon>
              添加考生
            </el-button>
          </div>
        </div>
      </template>

      <!-- 考生列表 -->
      <el-table
        v-loading="loading"
        :data="students"
        stripe
        style="width: 100%"
      >
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="userName" label="姓名" width="120" />
        <el-table-column prop="username" label="学号" width="150">
          <template #default="{ row }">
            {{ row.username || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="orgName" label="班级" width="150">
          <template #default="{ row }">
            {{ row.orgName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="examStatus" label="考试状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.examStatus)">
              {{ getStatusText(row.examStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="finalScore" label="最终成绩" width="100">
          <template #default="{ row }">
            {{ row.finalScore !== null && row.finalScore !== undefined ? row.finalScore : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="passStatus" label="及格状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.passStatus !== null && row.passStatus !== undefined" :type="row.passStatus === 1 ? 'success' : 'danger'">
              {{ row.passStatus === 1 ? '及格' : '不及格' }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="reexamCount" label="补考次数" width="100">
          <template #default="{ row }">
            {{ row.reexamCount || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              type="danger"
              link
              @click="handleRemove(row)"
            >
              移除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加考生对话框 -->
    <el-dialog
      v-model="showAddDialog"
      title="添加考生"
      width="900px"
      @close="handleDialogClose"
    >
      <el-alert
        title="提示"
        type="info"
        :closable="false"
        style="margin-bottom: 20px"
      >
        <template #default>
          <div>支持按班级筛选或搜索学生，可以一次选择多个考生添加到考试中。</div>
        </template>
      </el-alert>

      <el-form :model="addForm" label-width="100px">
        <el-form-item label="筛选条件">
          <el-row :gutter="10">
            <el-col :span="12">
              <el-select
                v-model="filterOrgId"
                filterable
                placeholder="按班级筛选"
                @change="handleFilterChange"
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="org in orgList"
                  :key="org.orgId"
                  :label="org.orgName"
                  :value="org.orgId"
                />
              </el-select>
            </el-col>
            <el-col :span="12">
              <el-input
                v-model="searchKeyword"
                placeholder="搜索学生姓名或学号"
                @input="handleFilterChange"
                clearable
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </el-col>
          </el-row>
        </el-form-item>
        <el-form-item label="选择考生" required>
          <el-select
            v-model="addForm.userIds"
            multiple
            filterable
            placeholder="请选择学生（可多选）"
            style="width: 100%"
            :loading="searchLoading"
          >
            <el-option
              v-for="student in availableStudents"
              :key="student.userId"
              :label="`${student.realName}（${student.username}）${student.orgName ? ' - ' + student.orgName : ''}`"
              :value="student.userId"
            >
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ student.realName }}</span>
                <span style="color: #8492a6; font-size: 13px; margin-left: 10px">
                  {{ student.username }}
                  <span v-if="student.orgName" style="margin-left: 8px">· {{ student.orgName }}</span>
                </span>
              </div>
            </el-option>
          </el-select>
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            已选择 {{ addForm.userIds.length }} 名考生
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button
          type="primary"
          @click="handleAdd"
          :loading="submitting"
          :disabled="addForm.userIds.length === 0"
        >
          确定添加（{{ addForm.userIds.length }}）
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download, Search } from '@element-plus/icons-vue'
import examUserApi from '@/api/examUser'
import userApi from '@/api/user'
import subjectApi from '@/api/subject'
import organizationApi from '@/api/organization'

const props = defineProps({
  examId: {
    type: Number,
    required: true
  },
  subjectId: {
    type: Number,
    default: null
  }
})

// 数据
const loading = ref(false)
const students = ref([])
const showAddDialog = ref(false)
const submitting = ref(false)
const searchLoading = ref(false)
const importing = ref(false)
const availableStudents = ref([])
const orgList = ref([])
const filterOrgId = ref(null)
const searchKeyword = ref('')

const addForm = ref({
  userIds: []
})

// 加载考生列表
const loadStudents = async () => {
  try {
    loading.value = true
    const res = await examUserApi.getExamStudents(props.examId)
    if (res.code === 200) {
      students.value = res.data || []
    }
  } catch (error) {
    console.error('加载考生列表失败:', error)
    ElMessage.error('加载考生列表失败')
  } finally {
    loading.value = false
  }
}

// 加载组织列表
const loadOrgList = async () => {
  try {
    const res = await organizationApi.getTree()
    if (res.code === 200) {
      orgList.value = flattenOrgTree(res.data)
    }
  } catch (error) {
    console.error('加载组织列表失败:', error)
  }
}

// 扁平化组织树
const flattenOrgTree = (nodes, result = []) => {
  nodes.forEach(node => {
    result.push({
      orgId: node.orgId,
      orgName: node.orgName,
      orgLevel: node.orgLevel
    })
    if (node.children && node.children.length > 0) {
      flattenOrgTree(node.children, result)
    }
  })
  return result
}

// 加载可选学生列表
const loadAvailableStudents = async (orgId = null, keyword = '') => {
  try {
    searchLoading.value = true

    const params = {
      current: 1,
      size: 100,
      roleId: 3 // 学生角色
    }

    // 如果有关键词，添加搜索条件
    if (keyword) {
      params.keyword = keyword
    }

    // 如果有组织ID，添加组织筛选
    if (orgId) {
      params.orgId = orgId
    }

    // 如果有科目ID，优先搜索该科目下的学生
    if (props.subjectId && !orgId && !keyword) {
      // 尝试获取科目的学生
      const subjectRes = await subjectApi.getStudents(props.subjectId, {
        current: 1,
        size: 999
      })
      if (subjectRes.code === 200) {
        availableStudents.value = subjectRes.data?.records || []
        return
      }
    }

    // 否则使用通用用户搜索
    const res = await userApi.page(params)
    if (res.code === 200 && res.data) {
      availableStudents.value = res.data.records || []
    }
  } catch (error) {
    console.error('加载可选学生列表失败:', error)
  } finally {
    searchLoading.value = false
  }
}

// 筛选条件变化
const handleFilterChange = async () => {
  await loadAvailableStudents(filterOrgId.value, searchKeyword.value)

  // 清空已选择的学生（如果他们不在筛选结果中）
  const filteredIds = new Set(availableStudents.value.map(s => s.userId))
  addForm.value.userIds = addForm.value.userIds.filter(id => filteredIds.has(id))
}

// 从科目导入学生
const handleImportFromSubject = async () => {
  if (!props.subjectId) {
    ElMessage.warning('未指定科目ID')
    return
  }

  try {
    await ElMessageBox.confirm(
      '确定要从该科目导入所有学生吗？已存在的学生将被跳过。',
      '从科目导入学生',
      {
        type: 'info',
        confirmButtonText: '确定导入',
        cancelButtonText: '取消'
      }
    )

    importing.value = true

    // 获取科目的所有学生
    const res = await subjectApi.getStudents(props.subjectId, {
      current: 1,
      size: 999
    })

    if (res.code === 200) {
      const subjectStudents = res.data?.records || []

      if (subjectStudents.length === 0) {
        ElMessage.info('该科目下没有学生')
        return
      }

      // 提取学生ID
      const studentIds = subjectStudents.map(s => s.userId)

      // 批量添加到考试
      const addRes = await examUserApi.addStudentsToExam(props.examId, studentIds)

      if (addRes.code === 200) {
        ElMessage.success(`成功从科目导入 ${studentIds.length} 名学生`)
        loadStudents()
      } else {
        ElMessage.error(addRes.message || '导入失败')
      }
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('从科目导入失败:', error)
      ElMessage.error('导入失败')
    }
  } finally {
    importing.value = false
  }
}

// 添加考生
const handleAdd = async () => {
  if (addForm.value.userIds.length === 0) {
    ElMessage.warning('请选择至少一个考生')
    return
  }

  try {
    submitting.value = true
    const res = await examUserApi.addStudentsToExam(props.examId, addForm.value.userIds)
    if (res.code === 200) {
      ElMessage.success(`成功添加 ${addForm.value.userIds.length} 名考生`)
      showAddDialog.value = false
      loadStudents()
    } else {
      ElMessage.error(res.message || '添加失败')
    }
  } catch (error) {
    console.error('添加考生失败:', error)
    ElMessage.error('添加失败')
  } finally {
    submitting.value = false
  }
}

// 移除考生
const handleRemove = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要移除考生"${row.userName}"吗？`,
      '提示',
      {
        type: 'warning'
      }
    )

    const res = await examUserApi.removeStudent(props.examId, row.userId)
    if (res.code === 200) {
      ElMessage.success('移除成功')
      loadStudents()
    } else {
      ElMessage.error(res.message || '移除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('移除考生失败:', error)
      ElMessage.error('移除失败')
    }
  }
}

// 关闭对话框
const handleDialogClose = () => {
  addForm.value.userIds = []
  availableStudents.value = []
  filterOrgId.value = null
  searchKeyword.value = ''
}

// 获取状态类型
const getStatusType = (status) => {
  const types = {
    0: 'info',     // 未参考
    1: 'warning',  // 参考中
    2: 'success',  // 已提交
    3: 'danger'    // 缺考
  }
  return types[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    0: '未参考',
    1: '参考中',
    2: '已提交',
    3: '缺考'
  }
  return texts[status] || '未知'
}

// 初始化
onMounted(() => {
  loadStudents()
})

// 监听对话框打开，自动加载数据
watch(showAddDialog, (newVal) => {
  if (newVal) {
    loadAvailableStudents()
    loadOrgList()
  }
})
</script>

<style scoped lang="scss">
.exam-students-manager {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .header-actions {
      display: flex;
      gap: 10px;
    }
  }
}
</style>

