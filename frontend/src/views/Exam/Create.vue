<template>
  <div class="exam-create-container">
    <!-- 页面头部 -->
    <el-page-header @back="goBack" :title="isEdit ? '编辑考试' : '创建考试'" />

    <!-- 表单区域 -->
    <el-card style="margin-top: 20px" v-loading="loading">
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="140px"
        style="max-width: 900px"
      >
        <!-- 基本信息 -->
        <el-divider content-position="left">
          <el-icon><InfoFilled /></el-icon>
          基本信息
        </el-divider>

        <el-form-item label="考试名称" prop="examName">
          <el-input
            v-model="formData.examName"
            placeholder="请输入考试名称"
            clearable
            maxlength="200"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="所属科目" prop="subjectId">
          <SubjectSelector
            v-model="formData.subjectId"
            :only-managed="true"
            placeholder="请选择所属科目"
          />
        </el-form-item>

        <el-form-item label="选择试卷" prop="paperId">
          <el-select
            v-model="formData.paperId"
            filterable
            placeholder="请选择试卷"
            style="width: 100%"
            @change="handlePaperChange"
          >
            <el-option
              v-for="paper in paperList"
              :key="paper.paperId"
              :label="`${paper.paperName} (${paper.totalScore}分)`"
              :value="paper.paperId"
            >
              <span style="float: left">{{ paper.paperName }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                {{ paper.questionCount }}题 / {{ paper.totalScore }}分
              </span>
            </el-option>
          </el-select>
          <el-button
            link
            type="primary"
            style="margin-left: 10px"
            @click="handlePreviewPaper"
            :disabled="!formData.paperId"
          >
            预览试卷
          </el-button>
        </el-form-item>

        <el-form-item label="考试封面">
          <el-input
            v-model="formData.coverImage"
            placeholder="请输入封面图片URL（选填）"
            clearable
          />
        </el-form-item>

        <el-form-item label="考试说明">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="4"
            placeholder="请输入考试说明（选填）"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <!-- 考试时间设置 -->
        <el-divider content-position="left">
          <el-icon><Clock /></el-icon>
          时间设置
        </el-divider>

        <el-form-item label="考试时间" prop="startTime">
          <el-date-picker
            v-model="examTime"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            :disabled-date="disabledDate"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DDTHH:mm:ss"
            style="width: 100%"
            @change="handleTimeChange"
          />
        </el-form-item>

        <el-form-item label="考试时长" prop="duration">
          <el-input-number
            v-model="formData.duration"
            :min="1"
            :max="600"
            :step="1"
            disabled
          />
          <span style="margin-left: 10px; color: #909399">分钟（自动计算）</span>
        </el-form-item>

        <el-form-item label="考前提醒时间" prop="remindTime">
          <el-input-number
            v-model="formData.remindTime"
            :min="0"
            :max="60"
            :step="5"
          />
          <span style="margin-left: 10px; color: #909399">分钟（0表示不提醒）</span>
        </el-form-item>

        <!-- 考试范围 -->
        <el-divider content-position="left">
          <el-icon><User /></el-icon>
          考试范围
        </el-divider>

        <el-form-item label="考试范围类型" prop="examRangeType">
          <el-radio-group v-model="formData.examRangeType">
            <el-radio :label="1">指定考生</el-radio>
            <el-radio :label="2">指定班级</el-radio>
            <el-radio :label="3">指定组织</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="考试范围" prop="examRangeIds">
          <el-input
            v-model="formData.examRangeIds"
            type="textarea"
            :rows="2"
            placeholder="请输入ID列表，多个ID用逗号分隔，例如: 1,2,3"
          />
          <div style="color: #909399; font-size: 12px; margin-top: 5px">
            根据范围类型输入对应的用户ID、班级ID或组织ID
          </div>
        </el-form-item>

        <!-- 成绩设置 -->
        <el-divider content-position="left">
          <el-icon><TrophyBase /></el-icon>
          成绩设置
        </el-divider>

        <el-form-item label="立即显示成绩">
          <el-switch
            v-model="formData.showScoreImmediately"
            :active-value="1"
            :inactive-value="0"
          />
          <span style="margin-left: 10px; color: #909399; font-size: 13px">
            交卷后是否立即显示成绩
          </span>
        </el-form-item>

        <!-- 防作弊设置 -->
        <el-divider content-position="left">
          <el-icon><Lock /></el-icon>
          防作弊设置
        </el-divider>

        <el-form-item label="允许切屏次数">
          <el-input-number
            v-model="formData.cutScreenLimit"
            :min="0"
            :max="10"
            :step="1"
          />
          <span style="margin-left: 10px; color: #909399">次（0表示不限制）</span>
        </el-form-item>

        <el-form-item label="切屏时长计入">
          <el-switch
            v-model="formData.cutScreenTimer"
            :active-value="1"
            :inactive-value="0"
          />
          <span style="margin-left: 10px; color: #909399; font-size: 13px">
            切屏时长是否计入考试时间
          </span>
        </el-form-item>

        <el-form-item label="禁止复制粘贴">
          <el-switch
            v-model="formData.forbidCopy"
            :active-value="1"
            :inactive-value="0"
          />
        </el-form-item>

        <el-form-item label="单设备登录">
          <el-switch
            v-model="formData.singleDevice"
            :active-value="1"
            :inactive-value="0"
          />
          <span style="margin-left: 10px; color: #909399; font-size: 13px">
            是否仅允许单个设备登录考试
          </span>
        </el-form-item>

        <!-- 题目设置 -->
        <el-divider content-position="left">
          <el-icon><Operation /></el-icon>
          题目设置
        </el-divider>

        <el-form-item label="乱序题目">
          <el-switch
            v-model="formData.shuffleQuestions"
            :active-value="1"
            :inactive-value="0"
          />
          <span style="margin-left: 10px; color: #909399; font-size: 13px">
            每个考生看到的题目顺序不同
          </span>
        </el-form-item>

        <el-form-item label="乱序选项">
          <el-switch
            v-model="formData.shuffleOptions"
            :active-value="1"
            :inactive-value="0"
          />
          <span style="margin-left: 10px; color: #909399; font-size: 13px">
            每个考生看到的选项顺序不同
          </span>
        </el-form-item>

        <!-- 主观题防抄袭 -->
        <el-form-item label="主观题防抄袭">
          <el-switch
            v-model="formData.antiPlagiarism"
            :active-value="1"
            :inactive-value="0"
          />
        </el-form-item>

        <el-form-item label="相似度阈值" v-if="formData.antiPlagiarism === 1">
          <el-slider
            v-model="formData.plagiarismThreshold"
            :min="0"
            :max="100"
            :step="5"
            show-input
          />
          <div style="color: #909399; font-size: 12px; margin-top: 5px">
            超过此相似度将标记为疑似抄袭
          </div>
        </el-form-item>

        <!-- 操作按钮 -->
        <el-form-item style="margin-top: 40px">
          <el-button type="primary" @click="handleSubmit" :loading="submitting">
            {{ isEdit ? '保存修改' : '创建考试' }}
          </el-button>
          <el-button @click="handleSaveDraft" :loading="submitting">
            保存草稿
          </el-button>
          <el-button @click="goBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  InfoFilled,
  Clock,
  User,
  TrophyBase,
  Lock,
  Operation
} from '@element-plus/icons-vue'
import SubjectSelector from '@/components/SubjectSelector.vue'
import examApi from '@/api/exam'
import paperApi from '@/api/paper'

const router = useRouter()
const route = useRoute()

// ==================== 状态 ====================
const loading = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const paperList = ref([])
const examTime = ref([])

// 是否编辑模式
const isEdit = computed(() => !!route.params.id)

// ==================== 表单数据 ====================
const formData = ref({
  examName: '',
  subjectId: null,
  description: '',
  coverImage: '',
  paperId: null,
  startTime: '',
  endTime: '',
  duration: 60,
  examRangeType: 1,
  examRangeIds: '',
  examStatus: 0,
  cutScreenLimit: 3,
  cutScreenTimer: 1,
  forbidCopy: 1,
  singleDevice: 1,
  shuffleQuestions: 0,
  shuffleOptions: 0,
  antiPlagiarism: 0,
  plagiarismThreshold: 80,
  remindTime: 15,
  showScoreImmediately: 1
})

// ==================== 表单验证规则 ====================
const validateExamTime = (rule, value, callback) => {
  if (!formData.value.startTime || !formData.value.endTime) {
    callback(new Error('请选择考试时间'))
  } else {
    callback()
  }
}

const validateDuration = (rule, value, callback) => {
  if (!value || value <= 0) {
    callback(new Error('请选择有效的考试时间，时长必须大于0'))
  } else if (value > 600) {
    callback(new Error('考试时长不能超过600分钟（10小时）'))
  } else {
    callback()
  }
}

const rules = {
  examName: [
    { required: true, message: '请输入考试名称', trigger: 'blur' },
    { min: 2, max: 200, message: '长度在 2 到 200 个字符', trigger: 'blur' }
  ],
  subjectId: [
    { required: true, message: '请选择所属科目', trigger: 'change' }
  ],
  paperId: [
    { required: true, message: '请选择试卷', trigger: 'change' }
  ],
  startTime: [
    { required: true, validator: validateExamTime, trigger: 'change' }
  ],
  duration: [
    { required: true, validator: validateDuration, trigger: 'change' }
  ],
  examRangeType: [
    { required: true, message: '请选择考试范围类型', trigger: 'change' }
  ]
}

// ==================== 加载试卷列表 ====================
const loadPaperList = async () => {
  try {
    const res = await paperApi.list({
      auditStatus: 2
    })
    if (res.code === 200 && res.data) {
      paperList.value = res.data || []
      if (paperList.value.length === 0) {
        ElMessage.warning('暂无可用试卷，请先创建并审核试卷')
      }
    }
  } catch (error) {
    console.error('加载试卷列表失败:', error)
    ElMessage.error('加载试卷列表失败')
  }
}

// ==================== 加载考试详情（编辑模式） ====================
const loadExamDetail = async () => {
  try {
    loading.value = true
    const res = await examApi.getById(route.params.id)
    if (res.code === 200 && res.data) {
      const data = res.data

      // 复制所有字段
      Object.keys(formData.value).forEach(key => {
        if (data[key] !== undefined && data[key] !== null) {
          formData.value[key] = data[key]
        }
      })

      // 设置考试时间
      if (data.startTime && data.endTime) {
        examTime.value = [data.startTime, data.endTime]
      }
    }
  } catch (error) {
    ElMessage.error('加载考试详情失败')
    goBack()
  } finally {
    loading.value = false
  }
}

// ==================== 处理试卷选择 ====================
const handlePaperChange = (paperId) => {
  console.log('选择试卷:', paperId)
}

// ==================== 预览试卷 ====================
const handlePreviewPaper = () => {
  if (formData.value.paperId) {
    const routeData = router.resolve({
      name: 'PaperPreview',
      params: { id: formData.value.paperId }
    })
    window.open(routeData.href, '_blank')
  }
}

// ==================== 处理时间变化 ====================
const handleTimeChange = (value) => {
  if (value && value.length === 2) {
    formData.value.startTime = value[0]
    formData.value.endTime = value[1]

    // 自动计算考试时长（分钟）
    const startTime = new Date(value[0]).getTime()
    const endTime = new Date(value[1]).getTime()
    const durationMinutes = Math.round((endTime - startTime) / (1000 * 60))
    formData.value.duration = durationMinutes

    formRef.value?.clearValidate(['startTime', 'duration'])
  } else {
    formData.value.startTime = ''
    formData.value.endTime = ''
    formData.value.duration = 0
  }
}

// ==================== 禁用过去的日期 ====================
const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7
}

// ==================== 提交表单 ====================
const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    formData.value.examStatus = 1
    await saveExam()
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// ==================== 保存草稿 ====================
const handleSaveDraft = async () => {
  try {
    await formRef.value.validateField(['examName', 'subjectId', 'paperId'])
    formData.value.examStatus = 0
    await saveExam()
  } catch (error) {
    console.error('保存草稿失败:', error)
  }
}

// ==================== 保存考试 ====================
const saveExam = async () => {
  try {
    submitting.value = true

    // 处理日期格式
    if (formData.value.startTime && typeof formData.value.startTime === 'string') {
      formData.value.startTime = formData.value.startTime.replace(' ', 'T')
    }
    if (formData.value.endTime && typeof formData.value.endTime === 'string') {
      formData.value.endTime = formData.value.endTime.replace(' ', 'T')
    }

    // 调用API
    const apiMethod = isEdit.value ? examApi.update : examApi.create
    const params = isEdit.value
      ? [route.params.id, formData.value]
      : [formData.value]

    const res = await apiMethod(...params)

    if (res.code === 200) {
      ElMessage.success(
        isEdit.value ? '修改成功' :
        formData.value.examStatus === 1 ? '创建成功' : '保存草稿成功'
      )
      goBack()
    }
  } catch (error) {
    ElMessage.error(isEdit.value ? '修改失败' : '创建失败')
  } finally {
    submitting.value = false
  }
}

// ==================== 返回 ====================
const goBack = () => {
  router.back()
}

// ==================== 初始化 ====================
onMounted(() => {
  loadPaperList()
  if (isEdit.value) {
    loadExamDetail()
  }
})
</script>

<style scoped>
.exam-create-container {
  padding: 20px;
}

:deep(.el-divider__text) {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

:deep(.el-form-item) {
  margin-bottom: 22px;
}
</style>

