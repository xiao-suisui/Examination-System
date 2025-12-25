<template>
  <el-select
    :model-value="modelValue"
    @update:model-value="handleChange"
    :placeholder="placeholder"
    :clearable="clearable"
    :disabled="disabled"
    :size="size"
    :multiple="multiple"
    :filterable="filterable"
    style="width: 100%"
  >
    <el-option
      v-for="(label, value) in options"
      :key="value"
      :label="label"
      :value="Number(value)"
    />
  </el-select>
</template>

<script setup>
/**
 * 枚举选择器通用组件
 *
 * @example
 * <EnumSelect
 *   v-model="form.questionType"
 *   :options="QUESTION_TYPE_LABELS"
 *   placeholder="选择题型"
 * />
 */

const props = defineProps({
  modelValue: {
    type: [Number, String, Array],
    default: null
  },
  // 枚举选项对象 { 1: '选项1', 2: '选项2' }
  options: {
    type: Object,
    required: true
  },
  placeholder: {
    type: String,
    default: '请选择'
  },
  clearable: {
    type: Boolean,
    default: true
  },
  disabled: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'default'
  },
  multiple: {
    type: Boolean,
    default: false
  },
  filterable: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const handleChange = (value) => {
  emit('update:modelValue', value)
  emit('change', value)
}
</script>

<style scoped>
/* 样式继承 Element Plus */
</style>

