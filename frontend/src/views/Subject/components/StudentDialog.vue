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
      width="800px"
      append-to-body
    >
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="筛选条件">
          <el-row :gutter="10">
            <el-col :span="12">
              <el-select
                v-model="filterOrgId"
                filterable
                placeholder="按组织筛选"
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
              />
            </el-col>
          </el-row>
        </el-form-item>
        <el-form-item label="选择学生">
          <el-select
            v-model="addForm.studentIds"
            multiple
            filterable
            placeholder="请选择学生（可多选）"
            style="width: 100%;"
          >
            <el-option
              v-for="student in availableStudents"
              :key="student.userId"
              :label="`${student.realName}（${student.username}）${student.orgName ? ' - ' + student.orgName : ''}`"
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
        <el-button type="primary" @click="handleConfirmAdd" :disabled="addForm.studentIds.length === 0">
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
import organizationApi from '@/api/organization'

const props = defineProps({
  modelValue: Boolean,
  subject: Object
})

const emit = defineEmits(['update:modelValue', 'refresh'])

const visible = ref(false)
const addDialogVisible = ref(false)
const studentList = ref([])
const availableStudents = ref([])
const orgList = ref([])
const filterOrgId = ref(null)
const searchKeyword = ref('')

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

// 加载学生列表
const loadStudents = async () => {
  try {
    const res = await subjectApi.getStudents(props.subject.subjectId, {
      current: 1,
      size: 999
    })
    if (res.code === 200) {
      studentList.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载学生列表失败:', error)
  }
}

// 加载可选学生列表
const loadAvailableStudents = async (orgId = null, keyword = '') => {
  try {
    const res = await subjectApi.getAvailableStudents(keyword, orgId)
    if (res.code === 200) {
      availableStudents.value = res.data || []
    }
  } catch (error) {
    console.error('加载可选学生列表失败:', error)
  }
}

// 筛选条件变化
const handleFilterChange = async () => {
  // 重新加载学生列表（按组织和关键词）
  await loadAvailableStudents(filterOrgId.value, searchKeyword.value)

  // 清空已选择的学生（如果他们不在筛选结果中）
  const filteredIds = new Set(availableStudents.value.map(s => s.userId))
  addForm.value.studentIds = addForm.value.studentIds.filter(id => filteredIds.has(id))
}

const handleBatchAdd = () => {
  addDialogVisible.value = true
  addForm.value.studentIds = []
  filterOrgId.value = null
  searchKeyword.value = ''
  loadAvailableStudents()
  loadOrgList()
}

const handleConfirmAdd = async () => {
  if (addForm.value.studentIds.length === 0) {
    ElMessage.warning('请选择至少一个学生')
    return
  }

  try {
    const res = await subjectApi.enrollStudents(props.subject.subjectId, addForm.value)
    if (res.code === 200) {
      ElMessage.success(`成功添加 ${addForm.value.studentIds.length} 名学生`)
      addDialogVisible.value = false
      addForm.value.studentIds = []
      loadStudents()
      emit('refresh')
    }
  } catch (error) {
    ElMessage.error(error.message || '添加失败')
  }
}

const handleRemove = async (row) => {
  try {
    const res = await subjectApi.withdrawStudent(props.subject.subjectId, row.studentId)
    if (res.code === 200) {
      ElMessage.success('移除成功')
      loadStudents()
      emit('refresh')
    }
  } catch (error) {
    ElMessage.error(error.message || '移除失败')
  }
}

const handleClose = () => {
  visible.value = false
}
</script>

