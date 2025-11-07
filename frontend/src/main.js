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

// 挂载应用
app.mount('#app')

// 开发环境配置
if (import.meta.env.DEV) {
  console.log('🚀 应用启动成功！')
  console.log('📦 当前环境:', import.meta.env.MODE)
  console.log('🌐 API地址:', import.meta.env.VITE_API_BASE_URL)
}

