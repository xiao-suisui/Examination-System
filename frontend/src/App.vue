<template>
  <router-view />
</template>

<script setup>
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/modules/auth'

// 应用启动时初始化认证状态
const authStore = useAuthStore()

onMounted(() => {
  // 如果有Token，验证Token有效性并获取用户信息
  if (authStore.token) {
    authStore.initAuth()
  }
})
</script>

<style>
/* 导入全局样式 */
@import '@/assets/styles/variables.css';
@import '@/assets/styles/reset.css';
@import '@/assets/styles/common.css';
</style>

