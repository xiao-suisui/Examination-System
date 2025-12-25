import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import subjectApi from '@/api/subject'
import { ElMessage } from 'element-plus'

/**
 * 科目管理Store
 */
export const useSubjectStore = defineStore('subject', () => {
  // 状态
  const mySubjects = ref([]) // 我的科目列表
  const currentSubject = ref(null) // 当前选中的科目
  const subjectList = ref([]) // 所有科目列表（用于选择器）
  const loading = ref(false)

  // 计算属性
  const hasSubjects = computed(() => mySubjects.value.length > 0)
  const currentSubjectId = computed(() => currentSubject.value?.subjectId || null)
  const currentSubjectName = computed(() => currentSubject.value?.subjectName || '请选择科目')

  /**
   * 加载我的科目列表
   */
  const loadMySubjects = async () => {
    try {
      loading.value = true
      const res = await subjectApi.getMySubjects()
      if (res.code === 200) {
        mySubjects.value = res.data || []

        // 如果有科目且未选中，自动选中第一个
        if (mySubjects.value.length > 0 && !currentSubject.value) {
          await selectSubject(mySubjects.value[0])
        }
      }
    } catch (error) {
      console.error('加载我的科目列表失败:', error)
      ElMessage.error('加载科目列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 加载所有科目列表（用于下拉选择）
   */
  const loadAllSubjects = async (query = {}) => {
    try {
      const res = await subjectApi.page({
        current: 1,
        size: 100,
        ...query
      })
      if (res.code === 200) {
        subjectList.value = res.data?.records || []
      }
    } catch (error) {
      console.error('加载科目列表失败:', error)
    }
  }

  /**
   * 选择科目
   */
  const selectSubject = async (subjectId) => {
    try {
      if (typeof subjectId === 'object') {
        // 如果传入的是科目对象
        currentSubject.value = subjectId
      } else {
        // 如果传入的是科目ID，需要查询详情
        const res = await subjectApi.getById(subjectId)
        if (res.code === 200) {
          currentSubject.value = res.data
        }
      }

      // 保存到localStorage
      if (currentSubject.value) {
        localStorage.setItem('currentSubjectId', currentSubject.value.subjectId)
      }
    } catch (error) {
      console.error('选择科目失败:', error)
      ElMessage.error('切换科目失败')
    }
  }

  /**
   * 从localStorage恢复当前科目
   */
  const restoreCurrentSubject = async () => {
    const savedSubjectId = localStorage.getItem('currentSubjectId')
    if (savedSubjectId) {
      await selectSubject(Number(savedSubjectId))
    }
  }

  /**
   * 清除当前科目
   */
  const clearCurrentSubject = () => {
    currentSubject.value = null
    localStorage.removeItem('currentSubjectId')
  }

  /**
   * 检查是否有科目权限
   */
  const hasPermission = (permission) => {
    if (!currentSubject.value) return false
    // TODO: 从后端获取当前用户在该科目的权限
    return true
  }

  /**
   * 重置Store
   */
  const reset = () => {
    mySubjects.value = []
    currentSubject.value = null
    subjectList.value = []
    loading.value = false
    localStorage.removeItem('currentSubjectId')
  }

  return {
    // 状态
    mySubjects,
    currentSubject,
    subjectList,
    loading,

    // 计算属性
    hasSubjects,
    currentSubjectId,
    currentSubjectName,

    // 方法
    loadMySubjects,
    loadAllSubjects,
    selectSubject,
    restoreCurrentSubject,
    clearCurrentSubject,
    hasPermission,
    reset
  }
})

