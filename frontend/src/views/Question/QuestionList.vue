<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <h3>{{ title }}</h3>
      </template>
      <el-empty description="功能开发中，敬请期待" />
    </el-card>
  </div>
</template>

<script setup>
import { defineProps } from 'vue'

const props = defineProps({
  title: {
    type: String,
    default: '页面'
  }
})
</script>

<style scoped>
.page-container {
  padding: 20px;
}
</style>

