<template>
  <div class="subject-detail-container">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <span>科目详情</span>
          <el-button text :icon="Back" @click="handleBack">返回</el-button>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="科目名称">
          {{ subject.subjectName }}
        </el-descriptions-item>
        <el-descriptions-item label="科目编码">
          {{ subject.subjectCode }}
        </el-descriptions-item>
        <el-descriptions-item label="归属学院">
          {{ subject.orgName }}
        </el-descriptions-item>
        <el-descriptions-item label="学分">
          {{ subject.credit }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="subject.status === 1 ? 'success' : 'danger'">
            {{ subject.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建人">
          {{ subject.createUserName }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间" :span="2">
          {{ subject.createTime }}
        </el-descriptions-item>
        <el-descriptions-item label="科目描述" :span="2">
          {{ subject.description || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="科目封面" :span="2">
          <el-image
            v-if="subject.coverImage"
            :src="subject.coverImage"
            :preview-src-list="[subject.coverImage]"
            fit="cover"
            style="width: 200px; height: 200px;"
          />
          <span v-else>无</span>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 统计信息 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="6">
        <el-card>
          <el-statistic title="学生人数" :value="subject.studentCount || 0">
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <el-statistic title="题库数量" :value="subject.questionBankCount || 0">
            <template #prefix>
              <el-icon><Folder /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <el-statistic title="试卷数量" :value="subject.paperCount || 0">
            <template #prefix>
              <el-icon><Document /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <el-statistic title="考试数量" :value="subject.examCount || 0">
            <template #prefix>
              <el-icon><Tickets /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <!-- 管理员列表 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>科目管理员</span>
          <el-button
            v-if="hasPermission('subject:auth')"
            type="primary"
            size="small"
            :icon="Plus"
            @click="handleAddManager"
          >
            添加管理员
          </el-button>
        </div>
      </template>

      <el-table :data="managerList" border stripe>
        <el-table-column prop="userName" label="姓名" />
        <el-table-column prop="isCreator" label="角色" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.isCreator === 1" type="danger">创建者</el-tag>
            <el-tag v-else-if="row.managerType === 1" type="success">主讲教师</el-tag>
            <el-tag v-else-if="row.managerType === 2" type="warning">协作教师</el-tag>
            <el-tag v-else type="info">助教</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="permissions" label="权限" min-width="200">
          <template #default="{ row }">
            <el-tag
              v-for="(perm, index) in parsePermissions(row.permissions)"
              :key="index"
              size="small"
              style="margin-right: 5px;"
            >
              {{ getPermissionName(perm) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="添加时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.isCreator !== 1 && hasPermission('subject:auth')"
              type="danger"
              link
              :icon="Delete"
              @click="handleRemoveManager(row)"
            >
              移除
            </el-button>
            <span v-else>-</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 学生列表 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>科目学生</span>
          <el-button
            v-if="hasPermission('subject:students')"
            type="primary"
            size="small"
            :icon="Plus"
            @click="handleAddStudent"
          >
            添加学生
          </el-button>
        </div>
      </template>

      <el-table :data="studentList" border stripe>
        <el-table-column prop="realName" label="姓名" />
        <el-table-column prop="username" label="学号" />
        <el-table-column prop="orgName" label="班级" />
        <el-table-column prop="enrollType" label="选课类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.enrollType === 1 ? 'success' : 'info'">
              {{ row.enrollType === 1 ? '必修' : '选修' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="enrollTime" label="选课时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="hasPermission('subject:students')"
              type="danger"
              link
              :icon="Delete"
              @click="handleRemoveStudent(row)"
            >
              移除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 管理员管理对话框 -->
    <ManagerDialog
      v-model="managerDialogVisible"
      :subject="subject"
      @refresh="loadSubjectDetail"
    />

    <!-- 学生管理对话框 -->
    <StudentDialog
      v-model="studentDialogVisible"
      :subject="subject"
      @refresh="loadSubjectDetail"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Back, Plus, Delete, User, Folder, Document, Tickets } from '@element-plus/icons-vue'
import subjectApi from '@/api/subject'
import { useAuthStore } from '@/stores/modules/auth'
import ManagerDialog from './components/ManagerDialog.vue'
import StudentDialog from './components/StudentDialog.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const loading = ref(false)
const subject = ref({})
const managerList = ref([])
const studentList = ref([])
const managerDialogVisible = ref(false)
const studentDialogVisible = ref(false)

// 权限映射
const permissionMap = {
  'MANAGE_STUDENT': '学生管理',
  'MANAGE_EXAM': '考试管理',
  'MANAGE_PAPER': '试卷管理',
  'MANAGE_QUESTION_BANK': '题库管理',
  'GRADE_EXAM': '批改考试',
  'VIEW_ANALYSIS': '数据分析'
}

// 检查权限
const hasPermission = (permission) => {
  return authStore.hasPermission(permission)
}

// 解析权限JSON
const parsePermissions = (permissionsJson) => {
  try {
    return JSON.parse(permissionsJson || '[]')
  } catch {
    return []
  }
}

// 获取权限名称
const getPermissionName = (permission) => {
  return permissionMap[permission] || permission
}

// 加载科目详情
const loadSubjectDetail = async () => {
  try {
    loading.value = true
    const id = route.query.id
    const res = await subjectApi.getById(id)
    if (res.code === 200) {
      subject.value = res.data
      // TODO: 加载管理员和学生列表
      // loadManagers()
      // loadStudents()
    }
  } catch (error) {
    console.error('加载科目详情失败:', error)
    ElMessage.error('加载科目详情失败')
  } finally {
    loading.value = false
  }
}

// 添加管理员
const handleAddManager = () => {
  managerDialogVisible.value = true
}

// 移除管理员
const handleRemoveManager = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要移除管理员"${row.userName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await subjectApi.removeManager(subject.value.subjectId, row.userId)
    if (res.code === 200) {
      ElMessage.success('移除成功')
      loadSubjectDetail()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('移除管理员失败:', error)
      ElMessage.error('移除失败')
    }
  }
}

// 添加学生
const handleAddStudent = () => {
  studentDialogVisible.value = true
}

// 移除学生
const handleRemoveStudent = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要移除学生"${row.realName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await subjectApi.withdrawStudent(subject.value.subjectId, row.studentId)
    if (res.code === 200) {
      ElMessage.success('移除成功')
      loadSubjectDetail()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('移除学生失败:', error)
      ElMessage.error('移除失败')
    }
  }
}

// 返回
const handleBack = () => {
  router.back()
}

onMounted(() => {
  loadSubjectDetail()
})
</script>

<style scoped>
.subject-detail-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>

