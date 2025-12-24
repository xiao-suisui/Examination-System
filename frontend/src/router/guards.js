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
      // 如果已登录，访问登录页则跳转到首页
      if (to.path === '/login' && isAuthenticated) {
        next('/')
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

