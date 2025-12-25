/**
 * 表格列表通用逻辑
 *
 * @example
 * const {
 *   loading,
 *   tableData,
 *   total,
 *   searchForm,
 *   loadData,
 *   handleSearch,
 *   handleReset,
 *   handlePageChange,
 *   handleSizeChange,
 *   handleDelete
 * } = useTableList(questionApi)
 */

import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

export function useTableList(api, initialSearchForm = {}) {
  // 加载状态
  const loading = ref(false)

  // 表格数据
  const tableData = ref([])

  // 总数
  const total = ref(0)

  // 搜索表单
  const searchForm = reactive({
    current: 1,
    size: 10,
    ...initialSearchForm
  })

  /**
   * 加载数据
   */
  const loadData = async () => {
    loading.value = true
    try {
      const res = await api.page(searchForm)

      if (res.code === 200) {
        tableData.value = res.data.records || []
        total.value = res.data.total || 0
      } else {
        ElMessage.error(res.message || '加载数据失败')
      }
    } catch (error) {
      console.error('加载数据失败:', error)
      ElMessage.error('加载数据失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 搜索
   */
  const handleSearch = () => {
    searchForm.current = 1
    loadData()
  }

  /**
   * 重置搜索条件
   */
  const handleReset = () => {
    // 重置除了 current 和 size 之外的所有字段
    Object.keys(searchForm).forEach(key => {
      if (key !== 'current' && key !== 'size') {
        searchForm[key] = undefined
      }
    })
    searchForm.current = 1
    loadData()
  }

  /**
   * 页码变化
   */
  const handlePageChange = (page) => {
    searchForm.current = page
    loadData()
  }

  /**
   * 每页数量变化
   */
  const handleSizeChange = (size) => {
    searchForm.size = size
    searchForm.current = 1
    loadData()
  }

  /**
   * 删除单个记录
   */
  const handleDelete = async (id, confirmMessage = '确定要删除吗？', successCallback) => {
    try {
      await ElMessageBox.confirm(confirmMessage, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })

      const res = await api.deleteById(id)

      if (res.code === 200) {
        ElMessage.success('删除成功')

        // 如果当前页只有一条数据且不是第一页，则返回上一页
        if (tableData.value.length === 1 && searchForm.current > 1) {
          searchForm.current--
        }

        loadData()

        // 执行成功回调
        if (successCallback) {
          successCallback()
        }
      } else {
        ElMessage.error(res.message || '删除失败')
      }
    } catch (error) {
      if (error !== 'cancel') {
        console.error('删除失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 批量删除
   */
  const handleBatchDelete = async (ids, confirmMessage = '确定要批量删除吗？', successCallback) => {
    if (!ids || ids.length === 0) {
      ElMessage.warning('请选择要删除的数据')
      return
    }

    try {
      await ElMessageBox.confirm(
        confirmMessage + `（共${ids.length}条）`,
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )

      const res = await api.batchDelete(ids)

      if (res.code === 200) {
        ElMessage.success('批量删除成功')
        loadData()

        if (successCallback) {
          successCallback()
        }
      } else {
        ElMessage.error(res.message || '批量删除失败')
      }
    } catch (error) {
      if (error !== 'cancel') {
        console.error('批量删除失败:', error)
        ElMessage.error('批量删除失败')
      }
    }
  }

  /**
   * 刷新当前页
   */
  const refresh = () => {
    loadData()
  }

  return {
    // 状态
    loading,
    tableData,
    total,
    searchForm,

    // 方法
    loadData,
    handleSearch,
    handleReset,
    handlePageChange,
    handleSizeChange,
    handleDelete,
    handleBatchDelete,
    refresh
  }
}

