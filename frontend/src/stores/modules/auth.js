/**
 * 认证状态管理
 * @description 管理用户认证状态、Token、登录登出等
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import authApi from '@/api/auth'
import { setToken, removeToken, getToken } from '@/utils/auth'
import { ElMessage } from 'element-plus'
import router from '@/router'

export const useAuthStore = defineStore('auth', () => {
  // ==================== State ====================
  const token = ref(getToken() || null)
  const isAuthenticated = ref(!!getToken())
  const userInfo = ref(null)

  // ==================== Getters ====================
  const isLoggedIn = computed(() => isAuthenticated.value && !!token.value)

  const userRole = computed(() => userInfo.value?.role || null)

  const userId = computed(() => userInfo.value?.userId || null)

  const username = computed(() => userInfo.value?.username || '')

  const permissions = computed(() => userInfo.value?.permissions || [])

  /**
   * 检查是否有某个权限
   */
  const hasPermission = computed(() => {
    return (permission) => {
      if (!permissions.value || permissions.value.length === 0) {
        return false
      }
      return permissions.value.includes(permission)
    }
  })

  /**
   * 检查是否有某个角色
   */
  const hasRole = computed(() => {
    return (role) => {
      return userRole.value === role
    }
  })

  // ==================== Actions ====================

  /**
   * 用户登录
   * @param {Object} credentials 登录凭证 {username, password}
   */
  async function login(credentials) {
    try {
      const res = await authApi.login(credentials)

      if (res.code === 200) {
        // res.data是一个对象，包含token、refreshToken、userId等
        const loginData = res.data

        // 保存Token
        token.value = loginData.token
        isAuthenticated.value = true
        setToken(loginData.token)

        // 保存用户基本信息（从登录返回中获取）
        userInfo.value = {
          userId: loginData.userId,
          username: loginData.username,
          realName: loginData.realName,
          roleId: loginData.roleId
        }

        ElMessage.success('登录成功')

        // 跳转到首页
        router.push('/')

        return res
      }
    } catch (error) {
      ElMessage.error(error.message || '登录失败')
      throw error
    }
  }

  /**
   * 用户登出
   */
  async function logout() {
    try {
      await authApi.logout()
    } catch (error) {
      console.error('登出失败:', error)
    } finally {
      // 清空状态
      token.value = null
      isAuthenticated.value = false
      userInfo.value = null
      removeToken()

      ElMessage.success('已退出登录')

      // 跳转到登录页
      router.push('/login')
    }
  }

  /**
   * 获取当前用户信息
   */
  async function getCurrentUser() {
    try {
      const res = await authApi.getCurrentUser()

      if (res.code === 200) {
        userInfo.value = res.data
        return res.data
      }
    } catch (error) {
      console.error('获取用户信息失败:', error)
      // 如果获取用户信息失败，清空登录状态
      await logout()
      throw error
    }
  }

  /**
   * 刷新Token
   * @param {string} refreshToken 刷新Token
   */
  async function refreshToken(refreshToken) {
    try {
      const res = await authApi.refresh({ refreshToken })

      if (res.code === 200) {
        token.value = res.data
        setToken(res.data)
        return res.data
      }
    } catch (error) {
      console.error('刷新Token失败:', error)
      await logout()
      throw error
    }
  }

  /**
   * 初始化认证状态
   * 应用启动时调用，验证Token有效性
   */
  async function initAuth() {
    if (token.value) {
      try {
        await getCurrentUser()
      } catch (error) {
        console.error('初始化认证失败:', error)
        await logout()
      }
    }
  }

  /**
   * 更新用户信息
   * @param {Object} newUserInfo 新的用户信息
   */
  function updateUserInfo(newUserInfo) {
    if (userInfo.value) {
      userInfo.value = {
        ...userInfo.value,
        ...newUserInfo
      }
    }
  }

  return {
    // State
    token,
    isAuthenticated,
    userInfo,

    // Getters
    isLoggedIn,
    userRole,
    userId,
    username,
    permissions,
    hasPermission,
    hasRole,

    // Actions
    login,
    logout,
    getCurrentUser,
    refreshToken,
    initAuth,
    updateUserInfo
  }
}, {
  persist: {
    key: 'exam-auth',
    paths: ['token', 'isAuthenticated']
  }
})

