<template>
  <el-dialog
    v-model="visible"
    title="管理员管理"
    width="800px"
    @close="handleClose"
  >
    <el-button type="primary" :icon="Plus" @click="handleAdd" style="margin-bottom: 15px;">
      添加管理员
    </el-button>

    <el-table :data="managerList" border>
      <el-table-column prop="userName" label="姓名" />
      <el-table-column prop="managerType" label="类型" width="120">
        <template #default="{ row }">
          <el-tag v-if="row.managerType === 1">主讲教师</el-tag>
          <el-tag v-else-if="row.managerType === 2" type="warning">协作教师</el-tag>
          <el-tag v-else type="info">助教</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button
            v-if="row.isCreator !== 1"
            type="danger"
            link
            @click="handleRemove(row)"
          >
            移除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加管理员表单对话框 -->
    <el-dialog
      v-model="addDialogVisible"
      title="添加管理员"
      width="500px"
      append-to-body
    >
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="选择用户">
          <el-select v-model="addForm.userId" filterable placeholder="请选择">
            <el-option
              v-for="user in userList"
              :key="user.userId"
              :label="`${user.realName}（${user.username}）`"
              :value="user.userId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="管理员类型">
          <el-radio-group v-model="addForm.managerType">
            <el-radio :value="1">主讲教师</el-radio>
            <el-radio :value="2">协作教师</el-radio>
            <el-radio :value="3">助教</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="权限">
          <el-checkbox-group v-model="addForm.permissions">
            <el-checkbox value="MANAGE_STUDENT">学生管理</el-checkbox>
            <el-checkbox value="MANAGE_EXAM">考试管理</el-checkbox>
            <el-checkbox value="MANAGE_PAPER">试卷管理</el-checkbox>
            <el-checkbox value="MANAGE_QUESTION_BANK">题库管理</el-checkbox>
            <el-checkbox value="GRADE_EXAM">批改考试</el-checkbox>
            <el-checkbox value="VIEW_ANALYSIS">数据分析</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAdd">确定</el-button>
      </template>
    </el-dialog>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import subjectApi from '@/api/subject'

const props = defineProps({
  modelValue: Boolean,
  subject: Object
})

const emit = defineEmits(['update:modelValue', 'refresh'])

const visible = ref(false)
const addDialogVisible = ref(false)
const managerList = ref([])
const userList = ref([])

const addForm = ref({
  userId: null,
  managerType: 2,
  permissions: []
})

watch(() => props.modelValue, (val) => {
  visible.value = val
  if (val && props.subject) {
    loadManagers()
    loadAvailableTeachers()
  }
})

watch(visible, (val) => {
  emit('update:modelValue', val)
})

// 加载管理员列表
const loadManagers = async () => {
  try {
    const res = await subjectApi.getManagers(props.subject.subjectId)
    if (res.code === 200) {
      managerList.value = res.data || []
    }
  } catch (error) {
    console.error('加载管理员列表失败:', error)
  }
}

// 加载可选教师列表
const loadAvailableTeachers = async () => {
  try {
    const res = await subjectApi.getAvailableTeachers(props.subject.orgId)
    if (res.code === 200) {
      userList.value = res.data || []
    }
  } catch (error) {
    console.error('加载教师列表失败:', error)
  }
}

const handleAdd = () => {
  addDialogVisible.value = true
  addForm.value = {
    userId: null,
    managerType: 2,
    permissions: []
  }
}

const handleConfirmAdd = async () => {
  try {
    const res = await subjectApi.addManager(props.subject.subjectId, addForm.value)
    if (res.code === 200) {
      ElMessage.success('添加成功')
      addDialogVisible.value = false
      emit('refresh')
    }
  } catch (error) {
    ElMessage.error('添加失败')
  }
}

const handleRemove = async (row) => {
  try {
    const res = await subjectApi.removeManager(props.subject.subjectId, row.userId)
    if (res.code === 200) {
      ElMessage.success('移除成功')
      emit('refresh')
    }
  } catch (error) {
    ElMessage.error('移除失败')
  }
}

const handleClose = () => {
  visible.value = false
}
</script>

