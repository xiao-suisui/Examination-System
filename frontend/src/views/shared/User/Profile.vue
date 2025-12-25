<template>
  <div class="profile-container">
    <el-card class="profile-card">
      <template #header>
        <div class="card-header">
          <span>个人资料</span>
        </div>
      </template>

      <el-row :gutter="20">
        <!-- 左侧：头像和基本信息 -->
        <el-col :span="8">
          <div class="avatar-section">
            <el-avatar :size="120" :src="userInfo.avatar || defaultAvatar" />
            <el-upload
              class="avatar-uploader"
              :show-file-list="false"
              :before-upload="beforeAvatarUpload"
              :http-request="handleAvatarUpload"
              accept="image/*"
            >
              <el-button type="primary" size="small" class="upload-btn">
                <el-icon><Upload /></el-icon>
                更换头像
              </el-button>
            </el-upload>
            <div class="user-basic-info">
              <h2>{{ userInfo.realName || userInfo.username }}</h2>
              <p class="user-role">{{ getRoleName(userInfo.roleId) }}</p>
              <p class="user-org">{{ userInfo.orgName || '未分配组织' }}</p>
            </div>
          </div>
        </el-col>

        <!-- 右侧：详细信息表单 -->
        <el-col :span="16">
          <el-tabs v-model="activeTab">
            <!-- 基本信息 -->
            <el-tab-pane label="基本信息" name="basic">
              <el-form
                ref="profileFormRef"
                :model="profileForm"
                :rules="profileRules"
                label-width="100px"
                class="profile-form"
              >
                <el-form-item label="用户名">
                  <el-input v-model="userInfo.username" disabled />
                </el-form-item>
                <el-form-item label="真实姓名" prop="realName">
                  <el-input v-model="profileForm.realName" placeholder="请输入真实姓名" />
                </el-form-item>
                <el-form-item label="手机号" prop="phone">
                  <el-input v-model="profileForm.phone" placeholder="请输入手机号" />
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                  <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
                </el-form-item>
                <el-form-item label="性别" prop="gender">
                  <el-radio-group v-model="profileForm.gender">
                    <el-radio :value="0">男</el-radio>
                    <el-radio :value="1">女</el-radio>
                  </el-radio-group>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="handleUpdateProfile">保存修改</el-button>
                  <el-button @click="resetProfileForm">重置</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 修改密码 -->
            <el-tab-pane label="修改密码" name="password">
              <el-form
                ref="passwordFormRef"
                :model="passwordForm"
                :rules="passwordRules"
                label-width="100px"
                class="password-form"
              >
                <el-form-item label="原密码" prop="oldPassword">
                  <el-input
                    v-model="passwordForm.oldPassword"
                    type="password"
                    placeholder="请输入原密码"
                    show-password
                  />
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword">
                  <el-input
                    v-model="passwordForm.newPassword"
                    type="password"
                    placeholder="请输入新密码"
                    show-password
                  />
                </el-form-item>
                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input
                    v-model="passwordForm.confirmPassword"
                    type="password"
                    placeholder="请再次输入新密码"
                    show-password
                  />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="handleUpdatePassword">修改密码</el-button>
                  <el-button @click="resetPasswordForm">重置</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 账户信息 -->
            <el-tab-pane label="账户信息" name="account">
              <el-descriptions :column="1" border>
                <el-descriptions-item label="用户ID">
                  {{ userInfo.userId }}
                </el-descriptions-item>
                <el-descriptions-item label="账户状态">
                  <el-tag :type="userInfo.status === 1 ? 'success' : 'danger'">
                    {{ userInfo.status === 1 ? '正常' : '禁用' }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="审核状态">
                  <el-tag :type="getAuditStatusType(userInfo.auditStatus)">
                    {{ getAuditStatusText(userInfo.auditStatus) }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="最后登录时间">
                  {{ userInfo.lastLoginTime || '从未登录' }}
                </el-descriptions-item>
                <el-descriptions-item label="最后登录IP">
                  {{ userInfo.lastLoginIp || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="注册时间">
                  {{ userInfo.createTime }}
                </el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
          </el-tabs>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Upload } from '@element-plus/icons-vue'
import userApi from '@/api/user'
import { useAuthStore } from '@/stores/modules/auth'

const authStore = useAuthStore()

// 默认头像
const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

// 当前激活的标签页
const activeTab = ref('basic')

// 用户信息
const userInfo = ref({
  userId: null,
  username: '',
  realName: '',
  phone: '',
  email: '',
  avatar: '',
  gender: 0,
  orgId: null,
  orgName: '',
  roleId: null,
  status: 1,
  auditStatus: 1,
  lastLoginTime: '',
  lastLoginIp: '',
  createTime: ''
})

// 个人资料表单
const profileFormRef = ref(null)
const profileForm = reactive({
  realName: '',
  phone: '',
  email: '',
  gender: 0
})

// 个人资料表单验证规则
const profileRules = {
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

// 密码表单
const passwordFormRef = ref(null)
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 密码表单验证规则
const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 获取当前用户信息
const loadUserInfo = async () => {
  try {
    const res = await userApi.getCurrentUser()
    if (res.code === 200) {
      Object.assign(userInfo.value, res.data)
      // 初始化表单数据
      profileForm.realName = res.data.realName || ''
      profileForm.phone = res.data.phone || ''
      profileForm.email = res.data.email || ''
      profileForm.gender = res.data.gender || 0
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
    ElMessage.error('加载用户信息失败')
  }
}

// 上传头像前的校验
const beforeAvatarUpload = (file) => {
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

// 自定义上传头像
const handleAvatarUpload = async ({ file }) => {
  try {
    const res = await userApi.uploadAvatar(file)
    if (res.code === 200) {
      userInfo.value.avatar = res.data.url
      ElMessage.success('头像上传成功')
      // 更新store中的用户头像
      authStore.updateUserInfo({ avatar: res.data.url })
    }
  } catch (error) {
    console.error('上传头像失败:', error)
    ElMessage.error('上传头像失败')
  }
}

// 更新个人资料
const handleUpdateProfile = async () => {
  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const res = await userApi.updateProfile(profileForm)
        if (res.code === 200) {
          ElMessage.success('个人资料更新成功')
          // 刷新用户信息
          await loadUserInfo()
          // 更新store中的用户信息
          authStore.updateUserInfo(profileForm)
        }
      } catch (error) {
        console.error('更新个人资料失败:', error)
        ElMessage.error(error.message || '更新个人资料失败')
      }
    }
  })
}

// 重置个人资料表单
const resetProfileForm = () => {
  profileForm.realName = userInfo.value.realName || ''
  profileForm.phone = userInfo.value.phone || ''
  profileForm.email = userInfo.value.email || ''
  profileForm.gender = userInfo.value.gender || 0
  profileFormRef.value?.clearValidate()
}

// 修改密码
const handleUpdatePassword = async () => {
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const res = await userApi.updatePassword({
          oldPassword: passwordForm.oldPassword,
          newPassword: passwordForm.newPassword
        })
        if (res.code === 200) {
          ElMessage.success('密码修改成功，请重新登录')
          // 重置表单
          resetPasswordForm()
          // 2秒后退出登录
          setTimeout(() => {
            authStore.logout()
          }, 2000)
        }
      } catch (error) {
        console.error('修改密码失败:', error)
        ElMessage.error(error.message || '修改密码失败')
      }
    }
  })
}

// 重置密码表单
const resetPasswordForm = () => {
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  passwordFormRef.value?.clearValidate()
}

// 获取角色名称
const getRoleName = (roleId) => {
  const roleMap = {
    1: '系统管理员',
    2: '教师',
    3: '学生',
    4: '学术管理员'
  }
  return roleMap[roleId] || '未知角色'
}

// 获取审核状态文本
const getAuditStatusText = (status) => {
  const statusMap = {
    0: '待审核',
    1: '已通过',
    2: '已拒绝'
  }
  return statusMap[status] || '未知'
}

// 获取审核状态类型
const getAuditStatusType = (status) => {
  const typeMap = {
    0: 'warning',
    1: 'success',
    2: 'danger'
  }
  return typeMap[status] || 'info'
}

onMounted(() => {
  loadUserInfo()
})
</script>

<style scoped>
.profile-container {
  padding: 20px;
}

.profile-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
}

.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
}

.avatar-uploader {
  margin-top: 20px;
}

.upload-btn {
  display: flex;
  align-items: center;
  gap: 5px;
}

.user-basic-info {
  text-align: center;
  margin-top: 20px;
}

.user-basic-info h2 {
  margin: 10px 0;
  font-size: 24px;
}

.user-role {
  color: #409eff;
  font-size: 14px;
  margin: 5px 0;
}

.user-org {
  color: #909399;
  font-size: 14px;
}

.profile-form,
.password-form {
  padding: 20px;
  max-width: 600px;
}

:deep(.el-descriptions__label) {
  font-weight: bold;
  width: 150px;
}
</style>

