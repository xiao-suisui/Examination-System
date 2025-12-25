<template>
  <el-card class="stat-card" :body-style="{ padding: '20px' }">
    <div class="stat-icon" :style="{ background: iconColor }">
      <el-icon :size="32">
        <component :is="icon" />
      </el-icon>
    </div>
    <div class="stat-content">
      <div class="stat-label">{{ label }}</div>
      <div class="stat-value">{{ value }}</div>
      <div v-if="subLabel" class="stat-sub-label">{{ subLabel }}</div>
    </div>
  </el-card>
</template>

<script setup>
/**
 * 统计卡片组件
 * 用于展示统计数据的卡片，支持自定义图标、颜色和标签
 *
 * @component StatCard
 * @example
 * <StatCard
 *   icon="Document"
 *   icon-color="#409eff"
 *   label="题库总数"
 *   :value="100"
 *   sub-label="较上月+10"
 * />
 */
defineProps({
  // 图标组件名称
  icon: {
    type: String,
    required: true
  },
  // 图标背景颜色
  iconColor: {
    type: String,
    default: '#409eff'
  },
  // 主标签
  label: {
    type: String,
    required: true
  },
  // 统计值
  value: {
    type: [Number, String],
    required: true
  },
  // 副标签（可选）
  subLabel: {
    type: String,
    default: ''
  }
})
</script>

<style scoped>
.stat-card {
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s;
}

.stat-card:hover {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  margin-right: 16px;
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.stat-sub-label {
  font-size: 12px;
  color: #67c23a;
  margin-top: 4px;
}
</style>

