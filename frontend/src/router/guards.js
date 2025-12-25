/**
 * 路由守卫
 * @description 权限验证、登录验证、页面标题设置等
 * @author Exam System (Updated 2025-12-20)
 */

import { useAuthStore } from '@/stores/modules/auth'
import { usePermissionStore } from '@/stores/modules/permission'
import { ElMessage } from 'element-plus'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

// NProgress配置
NProgress.configure({ showSpinner: false })

/**
 * 前置守卫
 */
export function setupBeforeEach(router) {
  router.beforeEach(async (to, from, next) => {
    // 开始进度条
    NProgress.start()

    // 设置页面标题
    document.title = to.meta.title ? `${to.meta.title} - 在线考试系统` : '在线考试系统'

    const authStore = useAuthStore()
    const permissionStore = usePermissionStore()
    const isAuthenticated = authStore.isLoggedIn

    // 不需要认证的页面，直接放行
    if (to.meta.requiresAuth === false) {
      // 如果已登录，访问登录页则根据角色跳转到不同页面
      if (to.path === '/login' && isAuthenticated) {
        const roleCode = authStore.user?.roleCode

        // 学生跳转到"我的考试"，其他角色跳转到首页
        if (roleCode === 'STUDENT') {
          next('/student/exam')
        } else {
          next('/')
        }
        return
      }
      next()
      return
    }

    // 需要认证的页面
    if (!isAuthenticated) {
      // 未登录，跳转到登录页
      ElMessage.warning('请先登录')
      next({
        path: '/login',
        query: { redirect: to.fullPath } // 记录要跳转的页面
      })
      return
    }

    // ========== 防御性检查：确保用户信息已加载 ==========
    // 如果Token存在但用户信息为空（可能是刷新后状态丢失），尝试重新获取
    if (authStore.token && !authStore.userInfo) {
      try {
        console.log('[Guards] 检测到Token但用户信息为空，正在获取用户信息...')
        await authStore.getCurrentUser()
      } catch (error) {
        console.error('[Guards] 获取用户信息失败:', error)
        ElMessage.error('获取用户信息失败，请重新登录')
        authStore.logout()
        next('/login')
        return
      }
    }
    // ==================================================

    // 确保权限已加载
    if (!permissionStore.loaded) {
      try {
        await permissionStore.loadPermissions()
      } catch (error) {
        console.error('[Guards] 加载权限失败:', error)
        ElMessage.error('加载权限失败，请重新登录')
        authStore.logout()
        next('/login')
        return
      }
    }

    // 检查路由权限（包含角色和功能权限检查）
    if (!permissionStore.hasRoutePermission(to)) {
      console.warn('[Guards] 权限验证失败:', {
        path: to.path,
        user: authStore.user?.username,
        role: authStore.user?.roleCode || authStore.user?.roleName
      })
      ElMessage.error('您没有权限访问此页面')
      next('/403')
      return
    }

    // ========== 智能跳转：学生访问首页时跳转到"我的考试" ==========
    if (to.path === '/' || to.path === '/home') {
      const roleCode = authStore.user?.roleCode

      // 学生自动跳转到"我的考试"页面
      if (roleCode === 'STUDENT') {
        next('/student/exam')
        return
      }
    }
    // ==================================================

    next()
  })
}

/**
 * 后置守卫
 */
export function setupAfterEach(router) {
  router.afterEach(() => {
    // 结束进度条
    NProgress.done()
  })
}

/**
 * 错误处理
 */
export function setupOnError(router) {
  router.onError((error) => {
    console.error('路由错误:', error)
    NProgress.done()

    // 处理组件加载失败
    if (error.message.includes('Failed to fetch dynamically imported module')) {
      ElMessage.error('页面加载失败，请刷新重试')
      // 可以选择重新加载页面
      // window.location.reload()
    } else if (error.message.includes('Cannot read properties of null')) {
      ElMessage.error('页面渲染出错，正在重新加载...')
      setTimeout(() => {
        window.location.reload()
      }, 1000)
    }
  })
}

