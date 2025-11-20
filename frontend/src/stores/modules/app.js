/**
 * 应用全局状态管理
 * @description 管理应用级别的状态（加载状态、面包屑、标签页等）
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAppStore = defineStore('app', () => {
  // ==================== State ====================
  const loading = ref(false)
  const loadingText = ref('加载中...')

  const breadcrumbs = ref([])
  const visitedViews = ref([]) // 已访问的页面标签
  const cachedViews = ref([])  // 需要缓存的页面

  const sidebar = ref({
    opened: true,
    withoutAnimation: false
  })

  const device = ref('desktop') // desktop | mobile

  // ==================== Getters ====================
  const sidebarOpened = computed(() => sidebar.value.opened)

  // ==================== Actions ====================

  /**
   * 显示全局加载
   * @param {string} text 加载文本
   */
  function showLoading(text = '加载中...') {
    loading.value = true
    loadingText.value = text
  }

  /**
   * 隐藏全局加载
   */
  function hideLoading() {
    loading.value = false
  }

  /**
   * 设置面包屑
   * @param {Array} crumbs 面包屑数组
   */
  function setBreadcrumbs(crumbs) {
    breadcrumbs.value = crumbs
  }

  /**
   * 添加访问的页面标签
   * @param {Object} view 视图对象 {name, path, title}
   */
  function addVisitedView(view) {
    if (visitedViews.value.some(v => v.path === view.path)) return

    visitedViews.value.push({
      name: view.name,
      path: view.path,
      title: view.title || view.meta?.title || 'Unknown'
    })
  }

  /**
   * 添加缓存的页面
   * @param {string} name 组件名称
   */
  function addCachedView(name) {
    if (cachedViews.value.includes(name)) return
    cachedViews.value.push(name)
  }

  /**
   * 删除访问的页面标签
   * @param {string} path 页面路径
   */
  function delVisitedView(path) {
    const index = visitedViews.value.findIndex(v => v.path === path)
    if (index > -1) {
      visitedViews.value.splice(index, 1)
    }
  }

  /**
   * 删除缓存的页面
   * @param {string} name 组件名称
   */
  function delCachedView(name) {
    const index = cachedViews.value.indexOf(name)
    if (index > -1) {
      cachedViews.value.splice(index, 1)
    }
  }

  /**
   * 删除其他页面标签
   * @param {string} path 保留的页面路径
   */
  function delOthersVisitedViews(path) {
    visitedViews.value = visitedViews.value.filter(v => v.path === path)
  }

  /**
   * 删除所有页面标签
   */
  function delAllVisitedViews() {
    visitedViews.value = []
    cachedViews.value = []
  }

  /**
   * 切换侧边栏
   */
  function toggleSidebar() {
    sidebar.value.opened = !sidebar.value.opened
    sidebar.value.withoutAnimation = false
  }

  /**
   * 关闭侧边栏
   */
  function closeSidebar(withoutAnimation = false) {
    sidebar.value.opened = false
    sidebar.value.withoutAnimation = withoutAnimation
  }

  /**
   * 切换设备类型
   * @param {string} deviceType desktop | mobile
   */
  function toggleDevice(deviceType) {
    device.value = deviceType
  }

  return {
    // State
    loading,
    loadingText,
    breadcrumbs,
    visitedViews,
    cachedViews,
    sidebar,
    device,

    // Getters
    sidebarOpened,

    // Actions
    showLoading,
    hideLoading,
    setBreadcrumbs,
    addVisitedView,
    addCachedView,
    delVisitedView,
    delCachedView,
    delOthersVisitedViews,
    delAllVisitedViews,
    toggleSidebar,
    closeSidebar,
    toggleDevice
  }
}, {
  persist: {
    key: 'exam-app',
    paths: ['sidebar', 'device']
  }
})

