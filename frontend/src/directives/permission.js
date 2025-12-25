/**
 * 权限指令
 *
 * @description v-permission 按钮级别权限控制
 * @usage v-permission="'question:create'"
 * @usage v-permission="['question:create', 'question:update']"
 * @author Exam System
 * @since 2025-12-20
 */

import { usePermissionStore } from '@/stores/modules/permission'

/**
 * 检查元素权限
 * @param {HTMLElement} el - DOM元素
 * @param {Object} binding - 指令绑定对象
 */
function checkPermission(el, binding) {
  const { value } = binding
  const permissionStore = usePermissionStore()

  if (value) {
    let hasPermission = false

    // 支持字符串或数组
    if (typeof value === 'string') {
      hasPermission = permissionStore.hasPermission(value)
    } else if (Array.isArray(value)) {
      // 数组默认使用"或"逻辑（有任意一个权限即可）
      hasPermission = permissionStore.hasAnyPermission(value)
    }

    // 如果没有权限，移除元素
    if (!hasPermission) {
      el.parentNode?.removeChild(el)
    }
  }
}

export default {
  /**
   * 元素挂载时
   */
  mounted(el, binding) {
    checkPermission(el, binding)
  },

  /**
   * 元素更新时
   */
  updated(el, binding) {
    checkPermission(el, binding)
  }
}

