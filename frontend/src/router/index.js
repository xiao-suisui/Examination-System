/**
 * Vue Router 路由实例
 * @description 创建路由实例，配置路由守卫
 */

import { createRouter, createWebHistory } from 'vue-router'
import routes from './routes-new' // 使用重构后的路由配置
import { setupBeforeEach, setupAfterEach, setupOnError } from './guards'

// 创建路由实例
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// 配置路由守卫
setupBeforeEach(router)
setupAfterEach(router)
setupOnError(router)

export default router

