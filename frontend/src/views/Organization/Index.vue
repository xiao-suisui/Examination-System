<template>
  <div class="organization-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>组织管理</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        创建组织
      </el-button>
    </div>

    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="组织名称">
          <el-input
            v-model="searchForm.orgName"
            placeholder="请输入组织名称"
            clearable
            style="width: 200px"
            @clear="handleSearch"
          />
        </el-form-item>
        <el-form-item label="组织代码">
          <el-input
            v-model="searchForm.orgCode"
            placeholder="请输入组织代码"
            clearable
            style="width: 200px"
            @clear="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button @click="handleToggleView">
            {{ viewMode === 'tree' ? '切换到列表视图' : '切换到树形视图' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 树形视图 -->
    <el-card class="table-card" v-if="viewMode === 'tree'">
      <el-tree
        :data="treeData"
        :props="treeProps"
        node-key="orgId"
        default-expand-all
        :expand-on-click-node="false"
      >
        <template #default="{ node, data }">
          <div class="tree-node">
            <span class="node-label">
              <el-icon><OfficeBuilding /></el-icon>
              {{ data.orgName }}
              <el-tag size="small" type="info" style="margin-left: 10px">
                {{ data.orgCode }}
              </el-tag>
            </span>
            <span class="node-actions">
              <el-button link type="primary" size="small" @click="handleCreateChild(data)">
                <el-icon><Plus /></el-icon>
                添加子组织
              </el-button>
              <el-button link type="primary" size="small" @click="handleEdit(data)">
                编辑
              </el-button>
              <el-button link type="danger" size="small" @click="handleDelete(data)">
                删除
              </el-button>
            </span>
          </div>
        </template>
      </el-tree>
    </el-card>

    <!-- 列表视图 -->
    <el-card class="table-card" v-else>
      <el-table :data="tableData" :loading="loading" stripe style="width: 100%">
        <el-table-column prop="orgId" label="ID" width="80" />
        <el-table-column prop="orgName" label="组织名称" min-width="180" />
        <el-table-column prop="orgCode" label="组织代码" width="150" />
        <el-table-column prop="parentName" label="上级组织" width="180" />
        <el-table-column prop="orgLevel" label="层级" width="80">
          <template #default="{ row }">
            <el-tag size="small">{{ getLevelName(row.orgLevel) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orgType" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getOrgTypeColor(row.orgType)" size="small">
              {{ getTypeName(row.orgType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="warning" @click="handleMove(row)">移动</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadOrganizations"
          @current-change="loadOrganizations"
        />
      </div>
    </el-card>

    <!-- 创建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="上级组织" prop="parentId">
          <el-tree-select
            v-model="formData.parentId"
            :data="treeData"
            :props="treeProps"
            check-strictly
            :render-after-expand="false"
            placeholder="请选择上级组织（不选则为顶级组织）"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="组织名称" prop="orgName">
          <el-input v-model="formData.orgName" placeholder="请输入组织名称" />
        </el-form-item>

        <el-form-item label="组织代码" prop="orgCode">
          <el-input v-model="formData.orgCode" placeholder="请输入组织代码" />
        </el-form-item>

        <el-form-item label="组织层级" prop="orgLevel">
          <el-select v-model="formData.orgLevel" placeholder="请选择层级" style="width: 100%">
            <el-option label="一级（学校/企业）" :value="ORG_LEVEL.LEVEL_1" />
            <el-option label="二级（学院/部门）" :value="ORG_LEVEL.LEVEL_2" />
            <el-option label="三级（系/小组）" :value="ORG_LEVEL.LEVEL_3" />
            <el-option label="四级（班级）" :value="ORG_LEVEL.LEVEL_4" />
          </el-select>
        </el-form-item>

        <el-form-item label="组织类型" prop="orgType">
          <el-select v-model="formData.orgType" placeholder="请选择类型" style="width: 100%">
            <el-option label="学校" :value="ORG_TYPE.SCHOOL" />
            <el-option label="企业" :value="ORG_TYPE.ENTERPRISE" />
            <el-option label="培训机构" :value="ORG_TYPE.TRAINING" />
          </el-select>
        </el-form-item>

        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="formData.sort" :min="0" controls-position="right" style="width: 100%" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 移动组织对话框 -->
    <el-dialog
      v-model="moveDialogVisible"
      title="移动组织"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form label-width="100px">
        <el-form-item label="当前组织">
          <el-input :value="currentOrg.orgName" disabled />
        </el-form-item>
        <el-form-item label="移动到">
          <el-tree-select
            v-model="newParentId"
            :data="treeData"
            :props="treeProps"
            check-strictly
            :render-after-expand="false"
            placeholder="请选择新的上级组织"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="moveDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleMoveSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, OfficeBuilding } from '@element-plus/icons-vue'
import organizationApi from '@/api/organization'
import {
  ORG_TYPE,
  ORG_LEVEL,
  getOrgTypeName,
  getOrgTypeColor,
  getOrgLevelName,
  getOrgLevelDescription
} from '@/utils/enums'

// 视图模式
const viewMode = ref('tree') // tree 或 list

// 树形数据
const treeData = ref([])
const treeProps = {
  children: 'children',
  label: 'orgName',
  value: 'orgId'
}

// 搜索表单
const searchForm = reactive({
  orgName: '',
  orgCode: ''
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 分页
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const formRef = ref(null)

// 表单数据
const formData = reactive({
  orgId: null,
  orgName: '',
  orgCode: '',
  parentId: 0,
  orgLevel: 1,      // 默认一级
  orgType: 1,       // 默认学校
  sort: 0,
  status: 1
})

// 表单验证规则
const formRules = {
  orgName: [
    { required: true, message: '请输入组织名称', trigger: 'blur' }
  ],
  orgCode: [
    { required: true, message: '请输入组织代码', trigger: 'blur' }
  ],
  orgLevel: [
    { required: true, message: '请选择组织层级', trigger: 'change' }
  ],
  orgType: [
    { required: true, message: '请选择组织类型', trigger: 'change' }
  ]
}

// 移动组织
const moveDialogVisible = ref(false)
const currentOrg = ref({})
const newParentId = ref(null)

// 加载组织树
const loadOrganizationTree = async () => {
  try {
    const res = await organizationApi.getTree()
    if (res.code === 200) {
      treeData.value = res.data
    }
  } catch (error) {
    ElMessage.error('加载组织树失败')
  }
}

// 加载组织列表
const loadOrganizations = async () => {
  loading.value = true
  try {
    const res = await organizationApi.page({
      current: pagination.current,
      size: pagination.size,
      orgName: searchForm.orgName || undefined,
      orgCode: searchForm.orgCode || undefined
    })
    if (res.code === 200) {
      tableData.value = res.data.records
      pagination.total = res.data.total
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

// 切换视图
const handleToggleView = () => {
  viewMode.value = viewMode.value === 'tree' ? 'list' : 'tree'
  if (viewMode.value === 'list') {
    loadOrganizations()
  }
}

// 搜索
const handleSearch = () => {
  if (viewMode.value === 'tree') {
    // 树形视图不支持搜索，切换到列表视图
    viewMode.value = 'list'
  }
  pagination.current = 1
  loadOrganizations()
}

// 重置
const handleReset = () => {
  searchForm.orgName = ''
  searchForm.orgCode = ''
  if (viewMode.value === 'tree') {
    loadOrganizationTree()
  } else {
    handleSearch()
  }
}

// 创建
const handleCreate = () => {
  dialogTitle.value = '创建组织'
  resetForm()
  dialogVisible.value = true
}

// 创建子组织
const handleCreateChild = (parent) => {
  dialogTitle.value = '创建子组织'
  resetForm()
  formData.parentId = parent.orgId
  formData.orgLevel = (parent.orgLevel || 0) + 1
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑组织'
  Object.assign(formData, {
    orgId: row.orgId,
    orgName: row.orgName,
    orgCode: row.orgCode,
    parentId: row.parentId || 0,
    orgLevel: row.orgLevel,
    orgType: row.orgType,
    sort: row.sort,
    status: row.status
  })
  dialogVisible.value = true
}

// 移动
const handleMove = (row) => {
  currentOrg.value = row
  newParentId.value = row.parentId
  moveDialogVisible.value = true
}

// 移动提交
const handleMoveSubmit = async () => {
  if (newParentId.value === currentOrg.value.parentId) {
    ElMessage.warning('新上级组织与当前相同')
    return
  }

  try {
    const res = await organizationApi.move(currentOrg.value.orgId, newParentId.value)
    if (res.code === 200) {
      ElMessage.success('移动成功')
      moveDialogVisible.value = false
      loadOrganizationTree()
      if (viewMode.value === 'list') {
        loadOrganizations()
      }
    }
  } catch (error) {
    ElMessage.error('移动失败')
  }
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除组织"${row.orgName}"吗？如果该组织下有子组织，将无法删除。`,
      '警告',
      { type: 'warning' }
    )

    const res = await organizationApi.deleteById(row.orgId)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadOrganizationTree()
      if (viewMode.value === 'list') {
        loadOrganizations()
      }
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(typeof error === 'string' ? error : '删除失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const res = formData.orgId
        ? await organizationApi.update(formData.orgId, formData)
        : await organizationApi.create(formData)

      if (res.code === 200) {
        ElMessage.success(formData.orgId ? '更新成功' : '创建成功')
        dialogVisible.value = false
        loadOrganizationTree()
        if (viewMode.value === 'list') {
          loadOrganizations()
        }
      }
    } catch (error) {
      ElMessage.error(formData.orgId ? '更新失败' : '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 重置表单
const resetForm = () => {
  formData.orgId = null
  formData.orgName = ''
  formData.orgCode = ''
  formData.parentId = 0
  formData.orgLevel = 1      // 默认一级
  formData.orgType = 1       // 默认学校
  formData.sort = 0
  formData.status = 1
  formRef.value?.resetFields()
}

// 获取层级名称（使用导入的枚举函数）
const getLevelName = (level) => getOrgLevelName(level)

// 获取类型名称（使用导入的枚举函数）
const getTypeName = (type) => getOrgTypeName(type)

// 初始化
onMounted(() => {
  loadOrganizationTree()
})
</script>

<style scoped>
.organization-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.search-card,
.table-card {
  margin-bottom: 20px;
}

.search-form {
  margin-bottom: 0;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.tree-node {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 14px;
  padding-right: 8px;
}

.node-label {
  display: flex;
  align-items: center;
  gap: 8px;
}

.node-actions {
  display: none;
}

.tree-node:hover .node-actions {
  display: block;
}
</style>

