<template>
  <el-dialog
    v-model="visible"
    title="学生管理"
    width="900px"
    @close="handleClose"
  >
    <el-button type="primary" :icon="Plus" @click="handleBatchAdd" style="margin-bottom: 15px;">
      批量添加学生
    </el-button>

    <el-table :data="studentList" border>
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
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button type="danger" link @click="handleRemove(row)">
            移除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 批量添加学生对话框 -->
    <el-dialog
      v-model="addDialogVisible"
      title="批量添加学生"
      width="700px"
      append-to-body
    >
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="选择学生">
          <el-select
            v-model="addForm.studentIds"
            multiple
            filterable
            placeholder="请选择学生"
            style="width: 100%;"
          >
            <el-option
              v-for="student in availableStudents"
              :key="student.userId"
              :label="`${student.realName}（${student.username}）- ${student.orgName}`"
              :value="student.userId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="选课类型">
          <el-radio-group v-model="addForm.enrollType">
            <el-radio :value="1">必修</el-radio>
            <el-radio :value="2">选修</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAdd">
          添加（{{ addForm.studentIds.length }}）
        </el-button>
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
const studentList = ref([])
const availableStudents = ref([])

const addForm = ref({
  studentIds: [],
  enrollType: 1
})

watch(() => props.modelValue, (val) => {
  visible.value = val
  if (val && props.subject) {
    loadStudents()
  }
})

watch(visible, (val) => {
  emit('update:modelValue', val)
})

// 加载学生列表
const loadStudents = async () => {
  try {
    const res = await subjectApi.getStudents(props.subject.subjectId, {
      current: 1,
      size: 100
    })
    if (res.code === 200) {
      studentList.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载学生列表失败:', error)
  }
}

// 加载可选学生列表
const loadAvailableStudents = async () => {
  try {
    const res = await subjectApi.getAvailableStudents('')
    if (res.code === 200) {
      availableStudents.value = res.data || []
    }
  } catch (error) {
    console.error('加载可选学生列表失败:', error)
  }
}

const handleBatchAdd = () => {
  addDialogVisible.value = true
  addForm.value.studentIds = []
  loadAvailableStudents()
}

const handleConfirmAdd = async () => {
  try {
    const res = await subjectApi.enrollStudents(props.subject.subjectId, addForm.value)
    if (res.code === 200) {
      ElMessage.success('添加成功')
      addDialogVisible.value = false
      addForm.value.studentIds = []
      emit('refresh')
    }
  } catch (error) {
    ElMessage.error('添加失败')
  }
}

const handleRemove = async (row) => {
  try {
    const res = await subjectApi.withdrawStudent(props.subject.subjectId, row.studentId)
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

