<template>
  <div class="subject-edit-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ isEdit ? '编辑科目' : '创建科目' }}</span>
          <el-button text :icon="Back" @click="handleBack">返回</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
      >
        <el-form-item label="科目名称" prop="subjectName">
          <el-input
            v-model="form.subjectName"
            placeholder="请输入科目名称"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="科目编码" prop="subjectCode">
          <el-input
            v-model="form.subjectCode"
            placeholder="请输入科目编码（如CS101）"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="归属学院" prop="orgId">
          <el-select
            v-model="form.orgId"
            placeholder="请选择归属学院"
            filterable
          >
            <el-option
              v-for="org in academyList"
              :key="org.orgId"
              :label="org.orgName"
              :value="org.orgId"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="学分" prop="credit">
          <el-input-number
            v-model="form.credit"
            :min="0"
            :max="10"
            :step="0.5"
            :precision="1"
            placeholder="请输入学分"
          />
        </el-form-item>

        <el-form-item label="科目描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="4"
            placeholder="请输入科目描述"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="科目封面" prop="coverImage">
          <el-upload
            class="cover-uploader"
            action="/api/file/upload"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <img alt="" v-if="form.coverImage" :src="form.coverImage" class="cover">
            <el-icon v-else class="cover-uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>

        <el-form-item label="排序" prop="sort">
          <el-input-number
            v-model="form.sort"
            :min="0"
            :max="9999"
            placeholder="排序值（越小越靠前）"
          />
        </el-form-item>

        <el-form-item v-if="isEdit" label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            {{ isEdit ? '更新' : '创建' }}
          </el-button>
          <el-button @click="handleBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Back, Plus } from '@element-plus/icons-vue'
import subjectApi from '@/api/subject'
import organizationApi from '@/api/organization'

const router = useRouter()
const route = useRoute()

const formRef = ref(null)
const submitting = ref(false)
const isEdit = ref(false)
const academyList = ref([])

const form = reactive({
  subjectId: null,
  subjectName: '',
  subjectCode: '',
  orgId: null,
  description: '',
  coverImage: '',
  credit: null,
  sort: 0,
  status: 1
})

const rules = {
  subjectName: [
    { required: true, message: '请输入科目名称', trigger: 'blur' }
  ],
  subjectCode: [
    { required: true, message: '请输入科目编码', trigger: 'blur' },
    { pattern: /^[A-Z0-9]+$/, message: '科目编码只能包含大写字母和数字', trigger: 'blur' }
  ],
  orgId: [
    { required: true, message: '请选择归属学院', trigger: 'change' }
  ]
}

// 加载学院列表
const loadAcademyList = async () => {
  try {
    const res = await organizationApi.tree()
    if (res.code === 200) {
      // 筛选出学院（org_level=2）
      academyList.value = filterAcademies(res.data)
    }
  } catch (error) {
    console.error('加载学院列表失败:', error)
    ElMessage.error('加载学院列表失败')
  }
}

// 递归筛选学院
const filterAcademies = (nodes) => {
  let academies = []
  nodes.forEach(node => {
    if (node.orgLevel === 2) {
      academies.push(node)
    }
    if (node.children && node.children.length > 0) {
      academies = academies.concat(filterAcademies(node.children))
    }
  })
  return academies
}

// 加载科目详情
const loadSubjectDetail = async (id) => {
  try {
    const res = await subjectApi.getById(id)
    if (res.code === 200) {
      Object.assign(form, res.data)
    }
  } catch (error) {
    console.error('加载科目详情失败:', error)
    ElMessage.error('加载科目详情失败')
  }
}

// 上传成功回调
const handleUploadSuccess = (response) => {
  if (response.code === 200) {
    form.coverImage = response.data.url
    ElMessage.success('上传成功')
  }
}

// 上传前校验
const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 提交
const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    submitting.value = true

    const apiMethod = isEdit.value ? subjectApi.update : subjectApi.create
    const res = await apiMethod(form)

    if (res.code === 200) {
      ElMessage.success(isEdit.value ? '更新成功' : '创建成功')
      router.back()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('提交失败:', error)
      ElMessage.error(error.message || '操作失败')
    }
  } finally {
    submitting.value = false
  }
}

// 返回
const handleBack = () => {
  router.back()
}

onMounted(async () => {
  await loadAcademyList()

  const id = route.query.id
  if (id) {
    isEdit.value = true
    await loadSubjectDetail(id)
  }
})
</script>

<style scoped>
.subject-edit-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-form {
  max-width: 800px;
}

.cover-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s;
}

.cover-uploader:hover {
  border-color: #409eff;
}

.cover-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  line-height: 178px;
  text-align: center;
}

.cover {
  width: 178px;
  height: 178px;
  display: block;
}
</style>

