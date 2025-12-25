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
          <span>科目管理员 ({{ managerList.length }})</span>
          <el-button
            v-if="hasPermission('subject:manage')"
            type="primary"
            size="small"
            :icon="Plus"
            @click="handleAddManager"
          >
            添加管理员
          </el-button>
        </div>
      </template>

      <el-table
        v-loading="managerLoading"
        :data="managerList"
        border
        stripe
      >
        <el-table-column prop="realName" label="姓名" width="120">
          <template #default="{ row }">
            {{ row.realName || row.username }}
          </template>
        </el-table-column>
        <el-table-column prop="username" label="工号/用户名" width="150" />
        <el-table-column prop="orgName" label="所属学院" min-width="150" />
        <el-table-column prop="isCreator" label="角色" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.isCreator === 1" type="danger">创建者</el-tag>
            <el-tag v-else-if="row.managerType === 1" type="success">主讲教师</el-tag>
            <el-tag v-else-if="row.managerType === 2" type="warning">协作教师</el-tag>
            <el-tag v-else type="info">助教</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="permissions" label="权限" min-width="250">
          <template #default="{ row }">
            <el-tag
              v-for="(perm, index) in parsePermissions(row.permissions)"
              :key="index"
              size="small"
              style="margin-right: 5px; margin-bottom: 5px;"
            >
              {{ getPermissionName(perm) }}
            </el-tag>
            <span v-if="!row.permissions || parsePermissions(row.permissions).length === 0" style="color: #999;">
              暂无权限
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="添加时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.isCreator !== 1 && hasPermission('subject:manage')"
              type="danger"
              link
              :icon="Delete"
              @click="handleRemoveManager(row)"
            >
              移除
            </el-button>
            <span v-else style="color: #999;">-</span>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="managerList.length === 0 && !managerLoading" style="text-align: center; padding: 40px; color: #999;">
        暂无管理员
      </div>
    </el-card>

    <!-- 学生列表 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>科目学生 ({{ studentTotal }})</span>
          <div>
            <el-input
              v-model="studentSearchKeyword"
              placeholder="搜索学生姓名或学号"
              style="width: 200px; margin-right: 10px;"
              clearable
              @clear="loadStudents"
              @keyup.enter="loadStudents"
            >
              <template #append>
                <el-button :icon="Search" @click="loadStudents" />
              </template>
            </el-input>
            <el-button
              v-if="hasPermission('subject:manage')"
              type="primary"
              size="small"
              :icon="Plus"
              @click="handleAddStudent"
            >
              添加学生
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        v-loading="studentLoading"
        :data="studentList"
        border
        stripe
      >
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="realName" label="姓名" width="120" />
        <el-table-column prop="username" label="学号" width="150" />
        <el-table-column prop="orgName" label="班级" min-width="180" />
        <el-table-column prop="enrollType" label="选课类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.enrollType === 1 ? 'success' : 'info'">
              {{ row.enrollType === 1 ? '必修' : '选修' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="enrollTime" label="选课时间" width="180" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '正常' : '已退课' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 1 && hasPermission('subject:manage')"
              type="danger"
              link
              :icon="Delete"
              @click="handleRemoveStudent(row)"
            >
              移除
            </el-button>
            <span v-else style="color: #999;">-</span>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div v-if="studentTotal > 0" style="margin-top: 20px; text-align: right;">
        <el-pagination
          v-model:current-page="studentPage.current"
          v-model:page-size="studentPage.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="studentTotal"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleStudentSizeChange"
          @current-change="handleStudentPageChange"
        />
      </div>

      <div v-if="studentList.length === 0 && !studentLoading" style="text-align: center; padding: 40px; color: #999;">
        {{ studentSearchKeyword ? '暂无搜索结果' : '暂无学生' }}
      </div>
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
import { Back, Plus, Delete, User, Folder, Document, Tickets, Search } from '@element-plus/icons-vue'
import subjectApi from '@/api/subject'
import { useAuthStore } from '@/stores/modules/auth'
import ManagerDialog from './components/ManagerDialog.vue'
import StudentDialog from './components/StudentDialog.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const loading = ref(false)
const managerLoading = ref(false)
const studentLoading = ref(false)
const subject = ref({})
const managerList = ref([])
const studentList = ref([])
const studentTotal = ref(0)
const studentSearchKeyword = ref('')
const studentPage = ref({
  current: 1,
  size: 20
})
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
      // 加载管理员和学生列表
      loadManagers()
      loadStudents()
    }
  } catch (error) {
    console.error('加载科目详情失败:', error)
    ElMessage.error('加载科目详情失败')
  } finally {
    loading.value = false
  }
}

// 加载管理员列表
const loadManagers = async () => {
  try {
    managerLoading.value = true
    const res = await subjectApi.getManagers(subject.value.subjectId)
    if (res.code === 200) {
      managerList.value = res.data || []
    }
  } catch (error) {
    console.error('加载管理员列表失败:', error)
    ElMessage.error('加载管理员列表失败')
  } finally {
    managerLoading.value = false
  }
}

// 加载学生列表
const loadStudents = async () => {
  try {
    studentLoading.value = true
    const res = await subjectApi.getStudents(subject.value.subjectId, {
      current: studentPage.value.current,
      size: studentPage.value.size,
      keyword: studentSearchKeyword.value
    })
    if (res.code === 200) {
      studentList.value = res.data?.records || []
      studentTotal.value = res.data?.total || 0
    }
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  } finally {
    studentLoading.value = false
  }
}

// 学生分页改变
const handleStudentPageChange = (page) => {
  studentPage.value.current = page
  loadStudents()
}

// 学生每页数量改变
const handleStudentSizeChange = (size) => {
  studentPage.value.size = size
  studentPage.value.current = 1
  loadStudents()
}

// 添加管理员
const handleAddManager = () => {
  managerDialogVisible.value = true
}

// 移除管理员
const handleRemoveManager = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要移除管理员"${row.realName || row.username}"吗？`,
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
      loadManagers()
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
      loadStudents()
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

