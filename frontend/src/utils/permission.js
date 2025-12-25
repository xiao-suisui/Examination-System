/**
 * 权限工具函数
 *
 * @description 提供便捷的权限检查函数
 * @author Exam System
 * @since 2025-12-20
 */

import { usePermissionStore } from '@/stores/modules/permission'

/**
 * 检查是否有指定权限
 * @param {string|string[]} permission - 权限编码或数组
 * @returns {boolean}
 */
export function hasPermission(permission) {
  const permissionStore = usePermissionStore()

  if (!permission) return true

  if (typeof permission === 'string') {
    return permissionStore.hasPermission(permission)
  } else if (Array.isArray(permission)) {
    return permissionStore.hasAnyPermission(permission)
  }

  return false
}

/**
 * 检查是否有任意一个权限
 * @param {string[]} permissions - 权限编码数组
 * @returns {boolean}
 */
export function hasAnyPermission(permissions) {
  const permissionStore = usePermissionStore()
  return permissionStore.hasAnyPermission(permissions)
}

/**
 * 检查是否有所有权限
 * @param {string[]} permissions - 权限编码数组
 * @returns {boolean}
 */
export function hasAllPermissions(permissions) {
  const permissionStore = usePermissionStore()
  return permissionStore.hasAllPermissions(permissions)
}

/**
 * 获取用户权限列表
 * @returns {string[]}
 */
export function getPermissions() {
  const permissionStore = usePermissionStore()
  return permissionStore.permissionList
}

/**
 * 权限组合对象（用于模板）
 */
export const Permission = {
  hasPermission,
  hasAnyPermission,
  hasAllPermissions,
  getPermissions
}

export default Permission

