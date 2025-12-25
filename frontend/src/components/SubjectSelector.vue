<template>
  <el-select
    v-model="selectedSubjectId"
    :placeholder="placeholder"
    :clearable="clearable"
    :filterable="filterable"
    :disabled="disabled"
    :loading="loading"
    :size="size"
    class="subject-selector"
    @change="handleChange"
  >
    <el-option
      v-for="subject in subjectList"
      :key="subject.subjectId"
      :label="subject.subjectName"
      :value="subject.subjectId"
    >
      <div class="subject-option">
        <span class="subject-name">{{ subject.subjectName }}</span>
        <span class="subject-code">{{ subject.subjectCode }}</span>
      </div>
    </el-option>
  </el-select>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import subjectApi from '@/api/subject'
import { ElMessage } from 'element-plus'

const props = defineProps({
  modelValue: {
    type: [Number, String],
    default: null
  },
  placeholder: {
    type: String,
    default: '请选择科目'
  },
  clearable: {
    type: Boolean,
    default: false
  },
  filterable: {
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
  // 查询条件
  query: {
    type: Object,
    default: () => ({})
  },
  // 是否只显示我管理的科目
  onlyManaged: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const selectedSubjectId = ref(props.modelValue)
const subjectList = ref([])
const loading = ref(false)

// 监听modelValue变化
watch(() => props.modelValue, (newVal) => {
  selectedSubjectId.value = newVal
})

// 监听查询条件变化
watch(() => props.query, () => {
  loadSubjects()
}, { deep: true })

// 加载科目列表
const loadSubjects = async () => {
  try {
    loading.value = true

    if (props.onlyManaged) {
      // 只加载我管理的科目
      const res = await subjectApi.getMySubjects()
      if (res.code === 200) {
        // 获取科目ID列表后，需要查询详细信息
        const subjectIds = res.data || []
        if (subjectIds.length > 0) {
          const pageRes = await subjectApi.page({
            current: 1,
            size: 100,
            ...props.query
          })
          if (pageRes.code === 200) {
            subjectList.value = pageRes.data?.records?.filter(s =>
              subjectIds.includes(s.subjectId)
            ) || []
          }
        } else {
          subjectList.value = []
        }
      }
    } else {
      // 加载所有科目
      const res = await subjectApi.page({
        current: 1,
        size: 100,
        ...props.query
      })
      if (res.code === 200) {
        subjectList.value = res.data?.records || []
      }
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
    ElMessage.error('加载科目列表失败')
  } finally {
    loading.value = false
  }
}

// 处理选择变化
const handleChange = (value) => {
  emit('update:modelValue', value)

  // 查找选中的科目对象
  const selectedSubject = subjectList.value.find(s => s.subjectId === value)
  emit('change', value, selectedSubject)
}

onMounted(() => {
  loadSubjects()
})
</script>

<style scoped>
.subject-selector {
  width: 100%;
}

.subject-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.subject-name {
  font-size: 14px;
  color: #303133;
}

.subject-code {
  font-size: 12px;
  color: #909399;
  margin-left: 8px;
}
</style>

