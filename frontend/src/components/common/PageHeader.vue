<template>
  <div class="page-header">
    <div class="header-left">
      <h2 class="title">{{ title }}</h2>
      <p v-if="description" class="description">{{ description }}</p>
    </div>
    <div v-if="$slots.extra" class="header-right">
      <slot name="extra"></slot>
    </div>
  </div>
</template>

<script setup>
/**
 * 页面头部组件
 * 统一的页面标题和描述展示组件
 *
 * @component PageHeader
 * @example
 * <PageHeader title="题库管理" description="管理系统中的所有题库">
 *   <template #extra>
 *     <el-button type="primary">新增</el-button>
 *   </template>
 * </PageHeader>
 */
defineProps({
  // 标题
  title: {
    type: String,
    required: true
  },
  // 描述
  description: {
    type: String,
    default: ''
  }
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  margin-bottom: 16px;
  border-bottom: 1px solid #ebeef5;
}

.header-left {
  flex: 1;
}

.title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
  color: #303133;
}

.description {
  margin: 8px 0 0;
  font-size: 14px;
  color: #909399;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
</style>

