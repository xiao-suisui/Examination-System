<template>
  <div class="organization-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span class="title">组织管理</span>
          <el-button type="primary" @click="handleAdd(null)">
            <el-icon><Plus /></el-icon>
            新增组织
          </el-button>
        </div>
      </template>

      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="请输入组织名称或编码"
          clearable
          style="width: 300px; margin-right: 10px"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button type="success" @click="expandAll">展开全部</el-button>
        <el-button type="warning" @click="collapseAll">折叠全部</el-button>
      </div>

      <el-table
        :data="tableData"
        style="width: 100%; margin-top: 20px"
        row-key="orgId"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        :default-expand-all="isExpandAll"
        border
        v-loading="loading"
      >
        <el-table-column prop="orgName" label="组织名称" min-width="200" />
        <el-table-column prop="orgCode" label="组织编码" width="150" />
        <el-table-column prop="orgLevel" label="层级" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.orgLevel === 1" type="primary">一级</el-tag>
            <el-tag v-else-if="row.orgLevel === 2" type="success">二级</el-tag>
            <el-tag v-else-if="row.orgLevel === 3" type="info">三级</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orgType" label="类型" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.orgType === 'SCHOOL'" type="primary">学校</el-tag>
            <el-tag v-else-if="row.orgType === 'ENTERPRISE'" type="success">企业</el-tag>
            <el-tag v-else-if="row.orgType === 'TRAINING'" type="warning">培训机构</el-tag>
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
            <el-button
              type="primary"
              size="small"
              @click="handleAdd(row.orgId)"
              link
            >
              新增子组织
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
        <el-form-item label="上级组织" prop="parentId">
          <el-tree-select
            v-model="form.parentId"
            :data="treeSelectData"
            :props="{ label: 'orgName', value: 'orgId' }"
            placeholder="请选择上级组织（为空则为顶级组织）"
            check-strictly
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="组织名称" prop="orgName">
          <el-input v-model="form.orgName" placeholder="请输入组织名称" />
        </el-form-item>
        <el-form-item label="组织编码" prop="orgCode">
          <el-input v-model="form.orgCode" placeholder="请输入组织编码" />
        </el-form-item>
        <el-form-item label="组织层级" prop="orgLevel">
          <el-select v-model="form.orgLevel" placeholder="请选择组织层级" style="width: 100%">
            <el-option label="一级（学校/企业）" :value="1" />
            <el-option label="二级（学院/部门）" :value="2" />
            <el-option label="三级（班级/小组）" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="组织类型" prop="orgType">
          <el-select v-model="form.orgType" placeholder="请选择组织类型" style="width: 100%">
            <el-option label="学校" value="SCHOOL" />
            <el-option label="企业" value="ENTERPRISE" />
            <el-option label="培训机构" value="TRAINING" />
          </el-select>
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :max="9999" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
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
import { Plus, Search } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 数据
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const isExpandAll = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref()
const treeSelectData = ref([])

// 表单数据
const form = reactive({
  orgId: null,
  orgName: '',
  orgCode: '',
  parentId: 0,
  orgLevel: 1,
  orgType: 'SCHOOL',
  sort: 0,
  status: 1
})

// 表单验证规则
const rules = {
  orgName: [
    { required: true, message: '请输入组织名称', trigger: 'blur' }
  ],
  orgLevel: [
    { required: true, message: '请选择组织层级', trigger: 'change' }
  ],
  parentId: [
    { required: true, message: '请选择上级组织', trigger: 'change' }
  ]
}

// 加载组织树
const loadTreeData = async () => {
  loading.value = true
  try {
    const res = await request.get('/api/organization/tree')
    if (res.code === 200) {
      tableData.value = res.data || []
      // 为树形选择器准备数据（添加顶级选项）
      treeSelectData.value = [
        { orgId: 0, orgName: '顶级组织', children: res.data || [] }
      ]
    }
  } catch (error) {
    ElMessage.error('加载组织数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = async () => {
  if (!searchKeyword.value) {
    loadTreeData()
    return
  }

  loading.value = true
  try {
    const res = await request.get('/api/organization/page', {
      params: {
        current: 1,
        size: 1000,
        keyword: searchKeyword.value
      }
    })
    if (res.code === 200) {
      tableData.value = res.data.records || []
    }
  } catch (error) {
    ElMessage.error('搜索失败')
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  searchKeyword.value = ''
  loadTreeData()
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
  dialogTitle.value = '新增组织'
  Object.assign(form, {
    orgId: null,
    orgName: '',
    orgCode: '',
    parentId: parentId || 0,
    orgLevel: parentId ? 2 : 1, // 如果有父节点，默认为二级
    orgType: 'SCHOOL',
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑组织'
  Object.assign(form, {
    orgId: row.orgId,
    orgName: row.orgName,
    orgCode: row.orgCode,
    parentId: row.parentId,
    orgLevel: row.orgLevel,
    orgType: row.orgType,
    sort: row.sort,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除组织"${row.orgName}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const res = await request.delete(`/api/organization/${row.orgId}`)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadTreeData()
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
    const res = await request.put(`/api/organization/${row.orgId}/status`, null, {
      params: { status: row.status }
    })
    if (res.code === 200) {
      ElMessage.success('状态更新成功')
    } else {
      ElMessage.error(res.message || '状态更新失败')
      row.status = row.status === 1 ? 0 : 1 // 恢复原状态
    }
  } catch (error) {
    ElMessage.error('状态更新失败')
    row.status = row.status === 1 ? 0 : 1 // 恢复原状态
  }
}

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value.validate()

    const url = form.orgId ? `/api/organization/${form.orgId}` : '/api/organization'
    const method = form.orgId ? 'put' : 'post'

    const res = await request[method](url, form)
    if (res.code === 200) {
      ElMessage.success(form.orgId ? '更新成功' : '创建成功')
      dialogVisible.value = false
      loadTreeData()
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
  loadTreeData()
})
</script>

<style scoped>
.organization-container {
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

