<template>
  <div class="permission-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span class="title">权限管理</span>
          <el-button type="primary" @click="handleAdd(null)">
            <el-icon><Plus /></el-icon>
            新增权限
          </el-button>
        </div>
      </template>

      <div class="toolbar">
        <el-button type="success" @click="expandAll">展开全部</el-button>
        <el-button type="warning" @click="collapseAll">折叠全部</el-button>
        <el-button @click="loadData">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>

      <el-table
        :data="tableData"
        style="width: 100%; margin-top: 20px"
        row-key="permId"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        :default-expand-all="isExpandAll"
        border
        v-loading="loading"
      >
        <el-table-column prop="permName" label="权限名称" min-width="200" />
        <el-table-column prop="permCode" label="权限编码" width="200" />
        <el-table-column prop="permType" label="权限类型" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.permType === 'MENU'" type="primary">菜单</el-tag>
            <el-tag v-else-if="row.permType === 'BUTTON'" type="success">按钮</el-tag>
            <el-tag v-else-if="row.permType === 'API'" type="info">接口</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="permUrl" label="权限URL" min-width="200" show-overflow-tooltip />
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="handleAdd(row.permId)"
              link
            >
              新增子权限
            </el-button>
            <el-button type="primary" size="small" @click="handleEdit(row)" link>
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)" link>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
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
        <el-form-item label="上级权限" prop="parentId">
          <el-tree-select
            v-model="form.parentId"
            :data="treeSelectData"
            :props="{ label: 'permName', value: 'permId' }"
            placeholder="请选择上级权限（为空则为顶级）"
            check-strictly
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="权限名称" prop="permName">
          <el-input v-model="form.permName" placeholder="请输入权限名称" />
        </el-form-item>
        <el-form-item label="权限编码" prop="permCode">
          <el-input v-model="form.permCode" placeholder="如：user:view" />
        </el-form-item>
        <el-form-item label="权限类型" prop="permType">
          <el-select v-model="form.permType" placeholder="请选择权限类型" style="width: 100%">
            <el-option label="菜单" value="MENU" />
            <el-option label="按钮" value="BUTTON" />
            <el-option label="接口" value="API" />
          </el-select>
        </el-form-item>
        <el-form-item label="权限URL" prop="permUrl">
          <el-input v-model="form.permUrl" placeholder="如：/api/user/list" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :max="9999" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 数据
const loading = ref(false)
const tableData = ref([])
const isExpandAll = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref()
const treeSelectData = ref([])

// 表单数据
const form = reactive({
  permId: null,
  permName: '',
  permCode: '',
  permType: 'MENU',
  permUrl: '',
  parentId: 0,
  sort: 0
})

// 表单验证规则
const rules = {
  permName: [
    { required: true, message: '请输入权限名称', trigger: 'blur' }
  ],
  permCode: [
    { required: true, message: '请输入权限编码', trigger: 'blur' }
  ],
  permType: [
    { required: true, message: '请选择权限类型', trigger: 'change' }
  ]
}

// 加载权限树
const loadData = async () => {
  loading.value = true
  try {
    const res = await request.get('/api/permission/tree')
    if (res.code === 200) {
      tableData.value = buildTreeData(res.data || [])
      // 为树形选择器准备数据
      treeSelectData.value = [
        { permId: 0, permName: '顶级权限', children: tableData.value }
      ]
    }
  } catch (error) {
    ElMessage.error('加载权限数据失败')
  } finally {
    loading.value = false
  }
}

// 递归构建树形数据
const buildTreeData = (data) => {
  return data.map(item => {
    const node = { ...item }
    if (item.children && item.children.length > 0) {
      node.children = buildTreeData(item.children)
      node.hasChildren = true
    } else {
      node.hasChildren = false
    }
    return node
  })
}

// 展开全部
const expandAll = () => {
  isExpandAll.value = true
}

// 折叠全部
const collapseAll = () => {
  isExpandAll.value = false
}

// 新增
const handleAdd = (parentId) => {
  dialogTitle.value = '新增权限'
  Object.assign(form, {
    permId: null,
    permName: '',
    permCode: '',
    permType: 'MENU',
    permUrl: '',
    parentId: parentId || 0,
    sort: 0
  })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑权限'
  Object.assign(form, {
    permId: row.permId,
    permName: row.permName,
    permCode: row.permCode,
    permType: row.permType,
    permUrl: row.permUrl,
    parentId: row.parentId,
    sort: row.sort
  })
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除权限"${row.permName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await request.delete(`/api/permission/${row.permId}`)
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

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value.validate()

    const url = form.permId
      ? `/api/permission/${form.permId}`
      : '/api/permission'
    const method = form.permId ? 'put' : 'post'

    const res = await request[method](url, form)
    if (res.code === 200) {
      ElMessage.success(form.permId ? '更新成功' : '创建成功')
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
.permission-container {
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

.toolbar {
  margin-bottom: 20px;
}
</style>

