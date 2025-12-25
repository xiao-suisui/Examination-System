/**
 * 全局指令注册
 *
 * @description 注册所有全局自定义指令
 * @author Exam System
 * @since 2025-12-20
 */

import permission from './permission'

export default {
  install(app) {
    // 注册权限指令 v-permission
    app.directive('permission', permission)

    console.log('[Directives] 权限指令已注册: v-permission')
  }
}

