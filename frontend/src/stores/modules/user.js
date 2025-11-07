/**
 * 用户状态管理
 * @description 管理当前登录用户的个人信息和偏好设置
 */

import { defineStore } from 'pinia'
import { ref } from 'vue'
import userApi from '@/api/user'

export const useUserStore = defineStore('user', () => {
  // ==================== State ====================
  const profile = ref(null)
  const preferences = ref({
    theme: 'light',
    sidebarCollapsed: false,
    language: 'zh-CN'
  })

  // ==================== Actions ====================

  /**
   * 获取用户资料
   */
  async function getProfile() {
    try {
      const res = await userApi.getProfile()
      if (res.code === 200) {
        profile.value = res.data
        return res.data
      }
    } catch (error) {
      console.error('获取用户资料失败:', error)
      throw error
    }
  }

  /**
   * 更新用户资料
   * @param {Object} data 用户资料
   */
  async function updateProfile(data) {
    try {
      const res = await userApi.updateProfile(data)
      if (res.code === 200) {
        profile.value = { ...profile.value, ...data }
        return res.data
      }
    } catch (error) {
      console.error('更新用户资料失败:', error)
      throw error
    }
  }

  /**
   * 修改密码
   * @param {Object} data {oldPassword, newPassword}
   */
  async function changePassword(data) {
    try {
      const res = await userApi.changePassword(data)
      return res
    } catch (error) {
      console.error('修改密码失败:', error)
      throw error
    }
  }

  /**
   * 设置主题
   * @param {string} theme 主题
   */
  function setTheme(theme) {
    preferences.value.theme = theme
    document.documentElement.setAttribute('data-theme', theme)
  }

  /**
   * 切换侧边栏折叠状态
   */
  function toggleSidebar() {
    preferences.value.sidebarCollapsed = !preferences.value.sidebarCollapsed
  }

  /**
   * 设置语言
   * @param {string} lang 语言代码
   */
  function setLanguage(lang) {
    preferences.value.language = lang
  }

  return {
    // State
    profile,
    preferences,

    // Actions
    getProfile,
    updateProfile,
    changePassword,
    setTheme,
    toggleSidebar,
    setLanguage
  }
}, {
  persist: {
    key: 'exam-user',
    paths: ['preferences']
  }
})

