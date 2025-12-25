/**
 * 权限管理Store
 *
 * @description 管理用户权限、动态路由、菜单生成
 * @author Exam System
 * @since 2025-12-20
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import permissionApi from '@/api/permission'
import { useAuthStore } from './auth'

export const usePermissionStore = defineStore('permission', () => {
  // ==================== State ====================

  /** 用户权限编码列表 */
  const permissions = ref(new Set())

  /** 权限是否已加载 */
  const loaded = ref(false)

  /** 动态路由列表 */
  const dynamicRoutes = ref([])

  /** 侧边栏菜单 */
  const menuList = ref([])

  // ==================== Getters ====================

  /**
   * 获取权限数组
   */
  const permissionList = computed(() => Array.from(permissions.value))

  /**
   * 检查是否有指定权限
   * @param {string} permission - 权限编码
   * @returns {boolean}
   */
  const hasPermission = (permission) => {
    if (!permission) return true
    return permissions.value.has(permission)
  }

  /**
   * 检查是否有任意一个权限
   * @param {string[]} perms - 权限编码数组
   * @returns {boolean}
   */
  const hasAnyPermission = (perms) => {
    if (!perms || perms.length === 0) return true
    return perms.some(p => permissions.value.has(p))
  }

  /**
   * 检查是否有所有权限
   * @param {string[]} perms - 权限编码数组
   * @returns {boolean}
   */
  const hasAllPermissions = (perms) => {
    if (!perms || perms.length === 0) return true
    return perms.every(p => permissions.value.has(p))
  }

  // ==================== Actions ====================

  /**
   * 加载用户权限
   */
  const loadPermissions = async () => {
    try {
      const authStore = useAuthStore()
      if (!authStore.userId) {
        console.warn('[Permission] 用户未登录，无法加载权限')
        return
      }

      console.log('[Permission] 正在加载用户权限...')
      const res = await permissionApi.getUserPermissions(authStore.userId)

      if (res.code === 200 && res.data) {
        // 使用Set存储权限，提高查询性能
        permissions.value = new Set(res.data)
        loaded.value = true
        console.log('[Permission] 权限加载成功，共', permissions.value.size, '个权限')
        console.log('[Permission] 权限列表:', Array.from(permissions.value))
      } else {
        console.error('[Permission] 权限加载失败:', res.message)
      }
    } catch (error) {
      console.error('[Permission] 加载权限异常:', error)
      throw error
    }
  }

  /**
   * 清空权限
   */
  const clearPermissions = () => {
    permissions.value.clear()
    loaded.value = false
    dynamicRoutes.value = []
    menuList.value = []
    console.log('[Permission] 权限已清空')
  }

  /**
   * 重新加载权限
   */
  const reloadPermissions = async () => {
    clearPermissions()
    await loadPermissions()
  }

  /**
   * 生成动态路由
   * @param {Array} routes - 路由配置
   * @returns {Array} - 过滤后的路由
   */
  const generateRoutes = (routes) => {
    const accessedRoutes = filterRoutes(routes)
    dynamicRoutes.value = accessedRoutes
    console.log('[Permission] 动态路由生成完成')
    return accessedRoutes
  }

  /**
   * 过滤路由（根据权限）
   * @param {Array} routes - 路由配置
   * @returns {Array} - 过滤后的路由
   */
  const filterRoutes = (routes) => {
    const res = []

    routes.forEach(route => {
      const tmp = { ...route }

      // 检查路由权限
      if (hasRoutePermission(tmp)) {
        // 递归过滤子路由
        if (tmp.children) {
          tmp.children = filterRoutes(tmp.children)
        }
        res.push(tmp)
      }
    })

    return res
  }

  /**
   * 检查路由权限
   * @param {Object} route - 路由对象
   * @returns {boolean}
   */
  const hasRoutePermission = (route) => {
    // 如果路由没有设置权限要求，默认可访问
    if (!route.meta) {
      return true
    }

    const authStore = useAuthStore()
    const userRole = authStore.user?.roleCode || authStore.user?.roleName

    // 1. 检查 roles 配置（角色权限）
    if (route.meta.roles && route.meta.roles.length > 0) {
      const allowedRoles = route.meta.roles

      // 检查用户角色是否在允许的角色列表中
      const hasRoleAccess = allowedRoles.some(role => {
        // 支持多种角色格式匹配
        return userRole === role ||
               userRole?.toUpperCase() === role?.toUpperCase() ||
               // 管理员特殊处理
               (userRole === 'ADMIN')
      })

      if (!hasRoleAccess) {
        console.log('[Permission] 角色权限检查失败:', {
          route: route.path,
          userRole,
          allowedRoles
        })
        return false
      }
    }

    // 2. 检查 permission 配置（功能权限）
    if (route.meta.permission) {
      const permission = route.meta.permission
d
      // 支持字符串或数组
      if (typeof permission === 'string') {
        if (!hasPermission(permission)) {
          console.log('[Permission] 功能权限检查失败:', {
            route: route.path,
            permission,
            hasPermission: hasPermission(permission)
          })
          return false
        }
      } else if (Array.isArray(permission)) {
        // 数组默认使用"或"逻辑（有任意一个权限即可）
        if (!hasAnyPermission(permission)) {
          console.log('[Permission] 功能权限检查失败:', {
            route: route.path,
            permissions: permission,
            hasAnyPermission: hasAnyPermission(permission)
          })
          return false
        }
      }
    }

    // 没有配置任何权限要求，或者权限检查通过
    return true
  }

  /**
   * 生成侧边栏菜单
   * @param {Array} routes - 路由配置
   * @returns {Array} - 菜单列表
   */
  const generateMenus = (routes) => {
    const menus = []

    routes.forEach(route => {
      // 跳过隐藏的菜单
      if (route.meta?.hidden) return

      const menu = {
        path: route.path,
        name: route.name,
        title: route.meta?.title || route.name,
        icon: route.meta?.icon,
        children: []
      }

      // 递归处理子菜单
      if (route.children && route.children.length > 0) {
        menu.children = generateMenus(route.children)
      }

      menus.push(menu)
    })

    menuList.value = menus
    return menus
  }

  // ==================== Return ====================

  return {
    // State
    permissions,
    loaded,
    dynamicRoutes,
    menuList,

    // Getters
    permissionList,
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,

    // Actions
    loadPermissions,
    clearPermissions,
    reloadPermissions,
    generateRoutes,
    generateMenus,
    hasRoutePermission
  }
})

