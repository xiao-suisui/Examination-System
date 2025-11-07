<template>
  <div class="knowledge-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span class="title">知识点管理</span>
          <el-button type="primary" @click="handleAdd(null)">
            <el-icon><Plus /></el-icon>
            新增知识点
          </el-button>
        </div>
      </template>

      <div class="search-bar">
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
        row-key="knowledgeId"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        :default-expand-all="isExpandAll"
        border
        v-loading="loading"
      >
        <el-table-column prop="knowledgeName" label="知识点名称" min-width="250" />
        <el-table-column prop="level" label="层级" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.level === 1" type="primary">一级</el-tag>
            <el-tag v-else-if="row.level === 2" type="success">二级</el-tag>
            <el-tag v-else-if="row.level === 3" type="info">三级</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="handleAdd(row.knowledgeId)"
              link
              v-if="row.level < 3"
            >
              新增子节点
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
        <el-form-item label="上级知识点" prop="parentId">
          <el-tree-select
            v-model="form.parentId"
            :data="treeSelectData"
            :props="{ label: 'knowledgeName', value: 'knowledgeId' }"
            placeholder="请选择上级知识点（为空则为顶级）"
            check-strictly
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="知识点名称" prop="knowledgeName">
          <el-input v-model="form.knowledgeName" placeholder="请输入知识点名称" />
        </el-form-item>
        <el-form-item label="层级" prop="level">
          <el-select v-model="form.level" placeholder="请选择层级" style="width: 100%">
            <el-option label="一级" :value="1" />
            <el-option label="二级" :value="2" />
            <el-option label="三级" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入知识点描述"
          />
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
  knowledgeId: null,
  knowledgeName: '',
  parentId: 0,
  level: 1,
  orgId: 1, // 默认组织ID，实际应该从用户信息获取
  description: '',
  sort: 0
})

// 表单验证规则
const rules = {
  knowledgeName: [
    { required: true, message: '请输入知识点名称', trigger: 'blur' }
  ],
  level: [
    { required: true, message: '请选择层级', trigger: 'change' }
  ]
}

// 加载知识点树
const loadData = async () => {
  loading.value = true
  try {
    const res = await request.get('/api/knowledge-point/tree', {
      params: {
        orgId: 1 // 实际应该从用户信息获取
      }
    })
    if (res.code === 200) {
      tableData.value = buildTreeData(res.data || [])
      // 为树形选择器准备数据
      treeSelectData.value = [
        { knowledgeId: 0, knowledgeName: '顶级知识点', children: tableData.value }
      ]
    }
  } catch (error) {
    ElMessage.error('加载知识点数据失败')
  } finally {
    loading.value = false
  }
}

// 递归构建树形数据（添加children属性）
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
  dialogTitle.value = '新增知识点'
  Object.assign(form, {
    knowledgeId: null,
    knowledgeName: '',
    parentId: parentId || 0,
    level: parentId ? 2 : 1,
    orgId: 1,
    description: '',
    sort: 0
  })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑知识点'
  Object.assign(form, {
    knowledgeId: row.knowledgeId,
    knowledgeName: row.knowledgeName,
    parentId: row.parentId,
    level: row.level,
    orgId: row.orgId,
    description: row.description,
    sort: row.sort
  })
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除知识点"${row.knowledgeName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await request.delete(`/api/knowledge-point/${row.knowledgeId}`)
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

    const url = form.knowledgeId
      ? `/api/knowledge-point/${form.knowledgeId}`
      : '/api/knowledge-point'
    const method = form.knowledgeId ? 'put' : 'post'

    const res = await request[method](url, form)
    if (res.code === 200) {
      ElMessage.success(form.knowledgeId ? '更新成功' : '创建成功')
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
.knowledge-container {
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

