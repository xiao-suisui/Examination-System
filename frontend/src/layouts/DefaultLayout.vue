<template>
  <div class="layout-container">
    <el-container>
      <!-- 侧边栏 -->
      <el-aside :width="sidebarWidth">
        <div class="logo">
          <h2>考试系统</h2>
        </div>
        <el-menu
          :default-active="activeMenu"
          :collapse="isCollapse"
          router
        >
          <!-- 首页 -->
          <el-menu-item index="/home">
            <el-icon><HomeFilled /></el-icon>
            <span>首页</span>
          </el-menu-item>

          <!-- 题库管理 -->
          <el-sub-menu index="question-manage">
            <template #title>
              <el-icon><Collection /></el-icon>
              <span>题库管理</span>
            </template>
            <el-menu-item index="/question-bank">
              <el-icon><Collection /></el-icon>
              <span>题库列表</span>
            </el-menu-item>
            <el-menu-item index="/question">
              <el-icon><EditPen /></el-icon>
              <span>题目管理</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- 试卷管理 -->
          <el-menu-item index="/paper">
            <el-icon><Document /></el-icon>
            <span>试卷管理</span>
          </el-menu-item>

          <!-- 考试管理 -->
          <el-sub-menu index="exam-manage">
            <template #title>
              <el-icon><Files /></el-icon>
              <span>考试管理</span>
            </template>
            <el-menu-item index="/exam">
              <el-icon><Files /></el-icon>
              <span>考试列表</span>
            </el-menu-item>
            <el-menu-item index="/exam/monitor">
              <el-icon><Share /></el-icon>
              <span>考试监控</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- 科目管理 -->
          <el-menu-item index="/subject">
            <el-icon><School /></el-icon>
            <span>科目管理</span>
          </el-menu-item>

          <!-- 系统管理（仅管理员可见） -->
          <el-sub-menu v-if="isAdmin" index="system-manage">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>系统管理</span>
            </template>
            <el-menu-item index="/user">
              <el-icon><User /></el-icon>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="/organization">
              <el-icon><OfficeBuilding /></el-icon>
              <span>组织管理</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- 统计分析 -->
          <el-menu-item index="/statistics">
            <el-icon><DataAnalysis /></el-icon>
            <span>统计分析</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 主内容区 -->
      <el-container>
        <!-- 顶部导航栏 -->
        <el-header>
          <div class="header-left">
            <el-icon class="collapse-icon" @click="toggleSidebar">
              <Fold v-if="!isCollapse" />
              <Expand v-else />
            </el-icon>
          </div>
          <div class="header-right">
            <el-dropdown @command="handleCommand">
              <span class="user-info">
                <el-icon><User /></el-icon>
                <span>{{ username }}</span>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile" >个人资料</el-dropdown-item>
                  <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-header>

        <!-- 内容区域 -->
        <el-main>
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/modules/auth'
import { useAppStore } from '@/stores/modules/app'
import { ElMessageBox } from 'element-plus'
import {
  HomeFilled,
  Setting,
  User,
  OfficeBuilding,
  Collection,
  EditPen,
  Document,
  Files,
  Share,
  Fold,
  Expand,
  School,
  DataAnalysis
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()

const isCollapse = computed(() => !appStore.sidebarOpened)
const sidebarWidth = computed(() => isCollapse.value ? '64px' : '240px')
const activeMenu = computed(() => route.path)
const username = computed(() => authStore.username || '用户')
const isAdmin = computed(() => {
  const roleCode = authStore.user?.roleCode
  return roleCode === 'ADMIN' || roleCode === 'SUPER_ADMIN'
})

const toggleSidebar = () => {
  appStore.toggleSidebar()
}

const handleCommand = async (command) => {
  if (command === 'logout') {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      type: 'warning'
    })
    await authStore.logout()
  } else if (command === 'profile') {
    router.push('/user/profile')
  }
}
</script>

<style scoped>
.layout-container {
  width: 100%;
  height: 100vh;
}

.el-container {
  height: 100%;
}

/* 嵌套的el-container也需要设置为flex方向为column */
.el-container .el-container {
  flex-direction: column;
}

.el-aside {
  background: #304156;
  transition: width 0.3s;
  overflow-y: auto;
  overflow-x: hidden;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #304156;
  color: #fff;
  font-size: 20px;
  font-weight: bold;
}

.el-menu {
  border-right: none;
  background: #304156;
}

:deep(.el-menu-item),
:deep(.el-sub-menu__title) {
  color: #bfcbd9;
}

:deep(.el-menu-item.is-active) {
  color: #fff;
  background: #409eff !important;
}

:deep(.el-menu-item:hover),
:deep(.el-sub-menu__title:hover) {
  background: #263445 !important;
  color: #fff;
}

.el-header {
  background: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
}

.collapse-icon {
  font-size: 24px;
  cursor: pointer;
  color: #606266;
}

.collapse-icon:hover {
  color: #409eff;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
}

.user-info:hover {
  background: #f5f7fa;
}

.el-main {
  background: #f0f2f5;
  padding: 20px;
  height: calc(100vh - 60px); /* 减去header高度 */
  overflow-y: auto;
}
</style>

