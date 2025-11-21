<template>
  <div class="error-page">
    <div class="error-content">
      <div class="error-code">403</div>
      <div class="error-message">无权限访问</div>
      <div class="error-description">
        抱歉，您没有权限访问此页面
      </div>
      <el-button type="primary" @click="goBack">
        返回上一页
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const goBack = () => {
  router.go(-1)
}
</script>

<style scoped>
.error-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f7fa;
}

.error-content {
  text-align: center;
}

.error-code {
  font-size: 120px;
  font-weight: bold;
  color: #f56c6c;
  line-height: 1;
}

.error-message {
  font-size: 28px;
  color: #303133;
  margin: 20px 0 10px;
}

.error-description {
  font-size: 16px;
  color: #909399;
  margin-bottom: 30px;
}
</style>

