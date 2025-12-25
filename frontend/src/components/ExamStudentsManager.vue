<template>
  <div class="exam-students-manager">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>考生管理</span>
          <el-button type="primary" @click="showAddDialog = true">
            <el-icon><Plus /></el-icon>
            添加考生
          </el-button>
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
        <el-table-column prop="userId" label="考生ID" width="100" />
        <el-table-column prop="userName" label="姓名" />
        <el-table-column prop="examStatus" label="考试状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.examStatus)">
              {{ getStatusText(row.examStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="finalScore" label="最终成绩" width="100" />
        <el-table-column prop="passStatus" label="及格状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.passStatus === 1 ? 'success' : 'danger'">
              {{ row.passStatus === 1 ? '及格' : '不及格' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reexamCount" label="补考次数" width="100" />
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
      width="700px"
      @close="handleDialogClose"
    >
      <el-alert
        title="提示"
        type="info"
        :closable="false"
        style="margin-bottom: 20px"
      >
        <template #default>
          <div>请输入学生姓名或学号进行搜索，可以一次选择多个考生添加到考试中。</div>
        </template>
      </el-alert>

      <el-form :model="addForm" label-width="100px">
        <el-form-item label="选择考生" required>
          <el-select
            v-model="addForm.userIds"
            multiple
            filterable
            remote
            reserve-keyword
            placeholder="请输入学生姓名或学号搜索"
            :remote-method="searchStudents"
            :loading="searchLoading"
            style="width: 100%"
            clearable
          >
            <el-option
              v-for="student in studentOptions"
              :key="student.userId"
              :label="`${student.realName} (${student.username})`"
              :value="student.userId"
            >
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ student.realName }}</span>
                <span style="color: #8492a6; font-size: 13px; margin-left: 10px">
                  {{ student.username }}
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
          确定添加
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import examUserApi from '@/api/examUser'
import userApi from '@/api/user'

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
const studentOptions = ref([])
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

// 搜索学生
const searchStudents = async (query) => {
  if (!query) {
    studentOptions.value = []
    return
  }

  try {
    searchLoading.value = true
    const params = {
      current: 1,
      size: 20,
      keyword: query,
      roleId: 3 // 学生角色
    }

    // 如果有科目ID，只搜索该科目下的学生
    if (props.subjectId) {
      params.subjectId = props.subjectId
    }

    const res = await userApi.page(params)
    if (res.code === 200 && res.data) {
      studentOptions.value = res.data.records || []
    }
  } catch (error) {
    console.error('搜索学生失败:', error)
  } finally {
    searchLoading.value = false
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
      ElMessage.success('添加成功')
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
  studentOptions.value = []
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
</script>

<style scoped lang="scss">
.exam-students-manager {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}
</style>

