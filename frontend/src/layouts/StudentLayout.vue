<template>
  <div class="student-layout">
    <el-container>
      <!-- 顶部导航栏 -->
      <el-header class="student-header">
        <div class="header-left">
          <div class="logo">
            <el-icon :size="24"><Reading /></el-icon>
            <span class="logo-text">学生考试系统</span>
          </div>
        </div>

        <div class="header-center">
          <el-menu
            :default-active="activeMenu"
            mode="horizontal"
            :ellipsis="false"
            router
          >
            <el-menu-item index="/student/exam">
              <el-icon><Tickets /></el-icon>
              <span>我的考试</span>
            </el-menu-item>
            <el-menu-item index="/student/score">
              <el-icon><Medal /></el-icon>
              <span>成绩查询</span>
            </el-menu-item>
            <el-menu-item index="/student/wrong-questions">
              <el-icon><Warning /></el-icon>
              <span>错题集</span>
            </el-menu-item>
          </el-menu>
        </div>

        <div class="header-right">
          <div class="user-info">
            <el-icon><User /></el-icon>
            <el-dropdown @command="handleCommand">
              <span class="user-name">{{ username }}</span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon>
                    个人资料
                  </el-dropdown-item>
                  <el-dropdown-item command="logout" divided>
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-header>

      <!-- 主内容区 -->
      <el-main class="student-main">
        <router-view />
      </el-main>

      <!-- 底部 -->
      <el-footer class="student-footer">
        <span>© 2025 学生考试系统</span>
      </el-footer>
    </el-container>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/modules/auth'
import { ElMessageBox } from 'element-plus'
import {
  Reading,
  Tickets,
  Medal,
  Warning,
  User,
  SwitchButton
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const activeMenu = computed(() => {
  // 处理子路由，返回父路由路径
  if (route.path.startsWith('/student/exam')) {
    return '/student/exam'
  } else if (route.path.startsWith('/student/score')) {
    return '/student/score'
  } else if (route.path.startsWith('/student/wrong-questions')) {
    return '/student/wrong-questions'
  }
  return route.path
})

const username = computed(() => {
  return authStore.user?.realName || authStore.username || '学生'
})

const handleCommand = async (command) => {
  if (command === 'logout') {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      type: 'warning'
    })
    await authStore.logout()
  } else if (command === 'profile') {
    router.push('/profile')
  }
}
</script>

<style scoped>
.student-layout {
  width: 100%;
  height: 100vh;
  background: #f5f7fa;
}

.el-container {
  height: 100%;
  flex-direction: column;
}

/* 顶部导航栏 */
.student-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 0 20px;
  height: 60px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
  min-width: 200px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.logo-text {
  font-size: 18px;
  font-weight: 600;
  color: #409eff;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
}

.header-center .el-menu {
  border-bottom: none;
  background: transparent;
}

.header-center .el-menu-item {
  font-size: 15px;
  font-weight: 500;
  border-bottom: 2px solid transparent;
}

.header-center .el-menu-item:hover {
  background: rgba(64, 158, 255, 0.1);
  border-bottom-color: #409eff;
}

.header-center .el-menu-item.is-active {
  color: #409eff;
  border-bottom-color: #409eff;
}

.header-right {
  display: flex;
  align-items: center;
  min-width: 150px;
  justify-content: flex-end;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
  transition: all 0.3s;
}

.user-info:hover {
  background: rgba(64, 158, 255, 0.1);
}

.user-name {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

/* 主内容区 */
.student-main {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f5f7fa;
}

/* 底部 */
.student-footer {
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border-top: 1px solid #e4e7ed;
  color: #909399;
  font-size: 14px;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .student-header {
    padding: 0 10px;
  }

  .logo-text {
    font-size: 16px;
  }

  .header-center .el-menu-item {
    font-size: 14px;
    padding: 0 10px;
  }

  .student-main {
    padding: 10px;
  }
}

/* 下拉菜单样式 */
:deep(.el-dropdown-menu__item) {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>

