<template>
  <div class="role-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span class="title">角色管理</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增角色
          </el-button>
        </div>
      </template>

      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="请输入角色名称或编码"
          clearable
          style="width: 300px; margin-right: 10px"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-select
          v-model="searchStatus"
          placeholder="状态"
          clearable
          style="width: 150px; margin-right: 10px"
        >
          <el-option label="启用" :value="1" />
          <el-option label="禁用" :value="0" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table
        :data="tableData"
        style="width: 100%; margin-top: 20px"
        border
        v-loading="loading"
      >
        <el-table-column prop="roleId" label="角色ID" width="80" />
        <el-table-column prop="roleName" label="角色名称" min-width="150" />
        <el-table-column prop="roleCode" label="角色编码" width="150" />
        <el-table-column prop="roleDesc" label="角色描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="isDefault" label="角色类型" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.isDefault === 1" type="warning">预设</el-tag>
            <el-tag v-else type="info">自定义</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)" link>
              编辑
            </el-button>
            <el-button type="primary" size="small" @click="handleAssignPermissions(row)" link>
              分配权限
            </el-button>
            <el-button
              type="danger"
              size="small"
              @click="handleDelete(row)"
              link
              :disabled="row.isDefault === 1"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSearch"
        @current-change="handleSearch"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
      >
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="form.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色编码" prop="roleCode">
          <el-input
            v-model="form.roleCode"
            placeholder="请输入角色编码（如：TEACHER）"
            :disabled="form.roleId && form.isDefault === 1"
          />
        </el-form-item>
        <el-form-item label="角色描述" prop="roleDesc">
          <el-input
            v-model="form.roleDesc"
            type="textarea"
            :rows="3"
            placeholder="请输入角色描述"
          />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :max="9999" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 分配权限对话框 -->
    <el-dialog
      v-model="permissionDialogVisible"
      title="分配权限"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-tree
        ref="permissionTreeRef"
        :data="permissionTree"
        show-checkbox
        node-key="permId"
        :props="{ label: 'permName', children: 'children' }"
        default-expand-all
      />
      <template #footer>
        <el-button @click="permissionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSavePermissions">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 数据
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const searchStatus = ref(null)
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref()
const permissionDialogVisible = ref(false)
const permissionTreeRef = ref()
const permissionTree = ref([])
const currentRoleId = ref(null)

// 分页
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 表单数据
const form = reactive({
  roleId: null,
  roleName: '',
  roleCode: '',
  roleDesc: '',
  isDefault: 0,
  sort: 0,
  status: 1
})

// 表单验证规则
const rules = {
  roleName: [
    { required: true, message: '请输入角色名称', trigger: 'blur' }
  ],
  roleCode: [
    { required: true, message: '请输入角色编码', trigger: 'blur' },
    { pattern: /^[A-Z_]+$/, message: '角色编码只能包含大写字母和下划线', trigger: 'blur' }
  ]
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await request.get('/api/role/page', {
      params: {
        current: pagination.current,
        size: pagination.size,
        keyword: searchKeyword.value || undefined,
        status: searchStatus.value
      }
    })
    if (res.code === 200) {
      tableData.value = res.data.records || []
      pagination.total = res.data.total || 0
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 加载权限树
const loadPermissionTree = async () => {
  try {
    const res = await request.get('/api/permission/tree')
    if (res.code === 200) {
      permissionTree.value = res.data || []
    }
  } catch (error) {
    ElMessage.error('加载权限树失败')
  }
}

// 搜索
const handleSearch = () => {
  pagination.current = 1
  loadData()
}

// 重置
const handleReset = () => {
  searchKeyword.value = ''
  searchStatus.value = null
  handleSearch()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增角色'
  Object.assign(form, {
    roleId: null,
    roleName: '',
    roleCode: '',
    roleDesc: '',
    isDefault: 0,
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑角色'
  Object.assign(form, {
    roleId: row.roleId,
    roleName: row.roleName,
    roleCode: row.roleCode,
    roleDesc: row.roleDesc,
    isDefault: row.isDefault,
    sort: row.sort,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  if (row.isDefault === 1) {
    ElMessage.warning('预设角色不允许删除')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除角色"${row.roleName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await request.delete(`/api/role/${row.roleId}`)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadData()
    } else {
      ElMessage.error(res.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 状态切换
const handleStatusChange = async (row) => {
  try {
    const res = await request.put(`/api/role/${row.roleId}/status`, null, {
      params: { status: row.status }
    })
    if (res.code === 200) {
      ElMessage.success('状态更新成功')
    } else {
      ElMessage.error(res.message || '状态更新失败')
      row.status = row.status === 1 ? 0 : 1
    }
  } catch (error) {
    ElMessage.error('状态更新失败')
    row.status = row.status === 1 ? 0 : 1
  }
}

// 分配权限
const handleAssignPermissions = async (row) => {
  currentRoleId.value = row.roleId

  // 加载权限树
  await loadPermissionTree()

  // 加载角色已有权限
  try {
    const res = await request.get(`/api/role/${row.roleId}/permissions`)
    if (res.code === 200) {
      // 设置选中的权限
      permissionTreeRef.value?.setCheckedKeys(res.data || [], false)
    }
  } catch (error) {
    ElMessage.error('加载角色权限失败')
  }

  permissionDialogVisible.value = true
}

// 保存权限
const handleSavePermissions = async () => {
  try {
    const checkedKeys = permissionTreeRef.value?.getCheckedKeys() || []
    const halfCheckedKeys = permissionTreeRef.value?.getHalfCheckedKeys() || []
    const allKeys = [...checkedKeys, ...halfCheckedKeys]

    const res = await request.post(`/api/role/${currentRoleId.value}/permissions`, {
      permissionIds: allKeys
    })

    if (res.code === 200) {
      ElMessage.success('权限分配成功')
      permissionDialogVisible.value = false
    } else {
      ElMessage.error(res.message || '权限分配失败')
    }
  } catch (error) {
    ElMessage.error('权限分配失败')
  }
}

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value.validate()

    const url = form.roleId ? `/api/role/${form.roleId}` : '/api/role'
    const method = form.roleId ? 'put' : 'post'

    const res = await request[method](url, form)
    if (res.code === 200) {
      ElMessage.success(form.roleId ? '更新成功' : '创建成功')
      dialogVisible.value = false
      loadData()
    } else {
      ElMessage.error(res.message || '操作失败')
    }
  } catch (error) {
    if (error !== false) {
      ElMessage.error('操作失败')
    }
  }
}

// 页面加载
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.role-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 18px;
  font-weight: bold;
}

.search-bar {
  margin-bottom: 20px;
}
</style>

