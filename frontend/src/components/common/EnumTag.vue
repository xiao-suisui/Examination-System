<template>
  <el-tag
    :type="typeMap[modelValue]"
    :size="size"
    :effect="effect"
    :closable="closable"
    @close="emit('close')"
  >
    {{ labelMap[modelValue] || defaultLabel }}
  </el-tag>
</template>

<script setup>
/**
 * 枚举标签组件
 * 根据枚举值自动显示对应的标签和颜色
 *
 * @component EnumTag
 * @example
 * <EnumTag
 *   :model-value="1"
 *   :label-map="QUESTION_TYPE_LABELS"
 *   :type-map="QUESTION_TYPE_COLORS"
 * />
 */
const props = defineProps({
  // 枚举值
  modelValue: {
    type: [Number, String],
    required: true
  },
  // 标签映射表
  labelMap: {
    type: Object,
    required: true
  },
  // 类型映射表（颜色）
  typeMap: {
    type: Object,
    default: () => ({})
  },
  // 默认标签（找不到映射时）
  defaultLabel: {
    type: String,
    default: '未知'
  },
  // 尺寸
  size: {
    type: String,
    default: 'default'
  },
  // 主题
  effect: {
    type: String,
    default: 'light'
  },
  // 是否可关闭
  closable: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])
</script>

