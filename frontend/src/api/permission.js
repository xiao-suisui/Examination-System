/**
 * 权限管理API
 *
 * @description 权限相关接口
 * @author Exam System
 * @since 2025-12-20
 */

import request from '@/utils/request'

/**
 * 获取权限树
 */
export function getPermissionTree() {
  return request({
    url: '/permission/tree',
    method: 'get'
  })
}

/**
 * 获取用户权限
 * @param {number} userId - 用户ID
 */
export function getUserPermissions(userId) {
  return request({
    url: `/permission/user/${userId}`,
    method: 'get'
  })
}

/**
 * 获取角色权限
 * @param {number} roleId - 角色ID
 */
export function getRolePermissions(roleId) {
  return request({
    url: `/permission/role/${roleId}`,
    method: 'get'
  })
}

/**
 * 为角色分配权限
 * @param {number} roleId - 角色ID
 * @param {number[]} permIds - 权限ID数组
 */
export function assignPermissions(roleId, permIds) {
  return request({
    url: `/permission/role/${roleId}/assign`,
    method: 'post',
    data: permIds
  })
}

/**
 * 创建权限
 * @param {Object} data - 权限数据
 */
export function createPermission(data) {
  return request({
    url: '/permission',
    method: 'post',
    data
  })
}

/**
 * 更新权限
 * @param {number} id - 权限ID
 * @param {Object} data - 权限数据
 */
export function updatePermission(id, data) {
  return request({
    url: `/permission/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除权限
 * @param {number} id - 权限ID
 */
export function deletePermission(id) {
  return request({
    url: `/permission/${id}`,
    method: 'delete'
  })
}

/**
 * 初始化默认权限
 */
export function initPermissions() {
  return request({
    url: '/permission/init',
    method: 'post'
  })
}

/**
 * 检查用户权限
 * @param {number} userId - 用户ID
 * @param {string} permCode - 权限编码
 */
export function checkPermission(userId, permCode) {
  return request({
    url: `/permission/check/${userId}/${permCode}`,
    method: 'get'
  })
}

// 默认导出
export default {
  getPermissionTree,
  getUserPermissions,
  getRolePermissions,
  assignPermissions,
  createPermission,
  updatePermission,
  deletePermission,
  initPermissions,
  checkPermission
}

