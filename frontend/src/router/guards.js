/**
 * 路由守卫
 * @description 权限验证、登录验证、页面标题设置等
 */

import { useAuthStore } from '@/stores/modules/auth'
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

    // 检查权限
    if (to.meta.permission) {
      const hasPermission = authStore.hasPermission(to.meta.permission)
      if (!hasPermission) {
        ElMessage.error('您没有权限访问此页面')
        next('/403')
        return
      }
    }

    // 检查角色
    if (to.meta.role) {
      const roles = Array.isArray(to.meta.role) ? to.meta.role : [to.meta.role]
      const hasRole = roles.includes(authStore.userRole)
      if (!hasRole) {
        ElMessage.error('您的角色无法访问此页面')
        next('/403')
        return
      }
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
  })
}

