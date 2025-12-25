<template>
  <el-form
    ref="formRef"
    :inline="inline"
    :model="modelValue"
    :label-width="labelWidth"
    class="search-form"
    @submit.prevent="handleSearch"
  >
    <slot></slot>

    <el-form-item>
      <el-button type="primary" @click="handleSearch" :loading="loading">
        <el-icon><Search /></el-icon>
        查询
      </el-button>
      <el-button @click="handleReset">
        <el-icon><Refresh /></el-icon>
        重置
      </el-button>
      <slot name="extra"></slot>
    </el-form-item>
  </el-form>
</template>

<script setup>
import { ref } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'

/**
 * 搜索表单组件
 * 统一的搜索表单样式和行为
 *
 * @component SearchForm
 * @example
 * <SearchForm v-model="searchForm" @search="handleSearch" @reset="handleReset">
 *   <el-form-item label="关键词">
 *     <el-input v-model="searchForm.keyword" />
 *   </el-form-item>
 * </SearchForm>
 */
const props = defineProps({
  // 表单数据
  modelValue: {
    type: Object,
    required: true
  },
  // 是否行内表单
  inline: {
    type: Boolean,
    default: true
  },
  // 标签宽度
  labelWidth: {
    type: String,
    default: '80px'
  },
  // 加载状态
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'search', 'reset'])

const formRef = ref()

/**
 * 搜索
 */
const handleSearch = () => {
  emit('search')
}

/**
 * 重置
 */
const handleReset = () => {
  formRef.value?.resetFields()
  emit('reset')
}

// 暴露方法给父组件
defineExpose({
  reset: handleReset,
  formRef
})
</script>

<style scoped>
.search-form {
  padding: 16px;
  background-color: #f5f7fa;
  border-radius: 4px;
  margin-bottom: 16px;
}

:deep(.el-form-item) {
  margin-bottom: 8px;
}

:deep(.el-form-item:last-child) {
  margin-right: 0;
}
</style>

