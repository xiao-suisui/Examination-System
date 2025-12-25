/**
 * 应用入口文件
 * @description 初始化Vue应用、配置插件、挂载应用
 */

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import pinia from './stores'

// Element Plus
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

// NProgress
import 'nprogress/nprogress.css'

// 全局指令
import directives from './directives'

// 创建应用实例
const app = createApp(App)

// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 使用插件
app.use(pinia)
app.use(router)
app.use(ElementPlus, {
  locale: zhCn,
  size: 'default'
})
app.use(directives)  // 注册全局指令

// 全局错误处理
app.config.errorHandler = (err, instance, info) => {
  console.error('全局错误捕获:', err)
  console.error('错误信息:', info)
  console.error('组件实例:', instance)

  // 可以在这里发送错误到日志服务器
  // 或显示友好的错误提示
}

// 全局警告处理（开发环境）
if (import.meta.env.DEV) {
  app.config.warnHandler = (msg, instance, trace) => {
    console.warn('Vue警告:', msg)
    console.warn('组件追踪:', trace)
  }
}

// ========== 初始化认证状态 ==========
// 在挂载应用前初始化认证状态
import { useAuthStore } from '@/stores/modules/auth'
const authStore = useAuthStore()

// 如果有Token但没有用户信息，则从后端获取最新用户信息
if (authStore.token && !authStore.userInfo) {
  console.log('[App] 检测到Token但用户信息为空，正在初始化...')
  authStore.initAuth().catch(error => {
    console.error('[App] 初始化认证失败:', error)
  })
} else if (authStore.token && authStore.userInfo) {
  console.log('[App] 用户已登录:', authStore.userInfo.username)
}
// ====================================

// 挂载应用
app.mount('#app')

// 开发环境配置
if (import.meta.env.DEV) {
  console.log('🚀 应用启动成功！')
  console.log('📦 当前环境:', import.meta.env.MODE)
  console.log('🌐 API地址:', import.meta.env.VITE_API_BASE_URL)
}

