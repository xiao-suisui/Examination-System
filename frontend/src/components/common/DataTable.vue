<template>
  <el-table
    v-bind="$attrs"
    :data="data"
    v-loading="loading"
    stripe
    border
    :default-sort="defaultSort"
    style="width: 100%"
  >
    <slot></slot>
  </el-table>

  <el-pagination
    v-if="showPagination && total > 0"
    v-model:current-page="currentPage"
    v-model:page-size="pageSize"
    :page-sizes="pageSizes"
    :total="total"
    :layout="layout"
    :background="background"
    class="pagination"
    @size-change="handleSizeChange"
    @current-change="handleCurrentChange"
  />
</template>

<script setup>
import { computed } from 'vue'

/**
 * 数据表格组件
 * 封装 Element Plus Table 和 Pagination，统一分页逻辑
 *
 * @component DataTable
 * @example
 * <DataTable
 *   :data="tableData"
 *   :loading="loading"
 *   :total="total"
 *   v-model:current="pagination.current"
 *   v-model:size="pagination.size"
 *   @change="loadData"
 * >
 *   <el-table-column prop="name" label="名称" />
 * </DataTable>
 */
const props = defineProps({
  // 表格数据
  data: {
    type: Array,
    default: () => []
  },
  // 加载状态
  loading: {
    type: Boolean,
    default: false
  },
  // 是否显示分页
  showPagination: {
    type: Boolean,
    default: true
  },
  // 总记录数
  total: {
    type: Number,
    default: 0
  },
  // 当前页码
  current: {
    type: Number,
    default: 1
  },
  // 每页大小
  size: {
    type: Number,
    default: 10
  },
  // 每页大小选项
  pageSizes: {
    type: Array,
    default: () => [10, 20, 50, 100]
  },
  // 分页布局
  layout: {
    type: String,
    default: 'total, sizes, prev, pager, next, jumper'
  },
  // 是否背景色
  background: {
    type: Boolean,
    default: true
  },
  // 默认排序
  defaultSort: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:current', 'update:size', 'change'])

const currentPage = computed({
  get: () => props.current,
  set: (val) => emit('update:current', val)
})

const pageSize = computed({
  get: () => props.size,
  set: (val) => emit('update:size', val)
})

/**
 * 每页大小变化
 */
const handleSizeChange = (size) => {
  emit('update:size', size)
  emit('update:current', 1) // 重置到第一页
  emit('change')
}

/**
 * 当前页码变化
 */
const handleCurrentChange = (current) => {
  emit('update:current', current)
  emit('change')
}
</script>

<style scoped>
.pagination {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>

