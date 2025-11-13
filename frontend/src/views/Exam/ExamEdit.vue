<template>
  <div class="exam-edit-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>{{ isEdit ? '编辑考试' : '创建考试' }}</span>
          <el-button @click="handleBack">返回</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="140px"
        style="max-width: 800px"
      >
        <!-- 基本信息 -->
        <el-divider content-position="left">基本信息</el-divider>

        <el-form-item label="考试名称" prop="examName">
          <el-input
            v-model="formData.examName"
            placeholder="请输入考试名称"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="考试描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入考试描述"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="选择试卷" prop="paperId">
          <el-select
            v-model="formData.paperId"
            placeholder="请选择试卷"
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="paper in paperList"
              :key="paper.paperId"
              :label="paper.paperName"
              :value="paper.paperId"
            />
          </el-select>
        </el-form-item>

        <!-- 时间设置 -->
        <el-divider content-position="left">时间设置</el-divider>

        <el-form-item label="考试时间" prop="timeRange">
          <el-date-picker
            v-model="formData.timeRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="考试时长" prop="duration">
          <el-input-number
            v-model="formData.duration"
            :min="1"
            :max="999"
            :step="1"
          />
          <span style="margin-left: 10px">分钟</span>
        </el-form-item>

        <el-form-item label="考前提醒" prop="remindTime">
          <el-input-number
            v-model="formData.remindTime"
            :min="0"
            :max="60"
            :step="5"
          />
          <span style="margin-left: 10px">分钟前提醒</span>
        </el-form-item>

        <!-- 参与范围 -->
        <el-divider content-position="left">参与范围</el-divider>

        <el-form-item label="范围类型" prop="examRangeType">
          <el-radio-group v-model="formData.examRangeType">
            <el-radio :value="1">指定考生</el-radio>
            <el-radio :value="2">指定班级</el-radio>
            <el-radio :value="3">指定组织</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="选择范围" prop="examRangeIds">
          <el-input
            v-model="formData.examRangeIds"
            placeholder="请输入ID列表，多个用逗号分隔，如：1,2,3"
          />
          <div class="form-tip">提示：暂时请手动输入ID，后续将支持可视化选择</div>
        </el-form-item>

        <!-- 防作弊设置 -->
        <el-divider content-position="left">防作弊设置</el-divider>

        <el-form-item label="允许切屏次数">
          <el-input-number
            v-model="formData.cutScreenLimit"
            :min="0"
            :max="5"
          />
          <span style="margin-left: 10px">次（超过后将强制提交）</span>
        </el-form-item>

        <el-form-item label="切屏时间">
          <el-radio-group v-model="formData.cutScreenTimer">
            <el-radio :value="0">不计入考试时间</el-radio>
            <el-radio :value="1">计入考试时间</el-radio>
          </el-radio-group>
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
          <div class="form-tip">开启后，同一账号仅能在一个设备上答题</div>
        </el-form-item>

        <!-- 题目设置 -->
        <el-divider content-position="left">题目设置</el-divider>

        <el-form-item label="乱序题目">
          <el-switch
            v-model="formData.shuffleQuestions"
            :active-value="1"
            :inactive-value="0"
          />
          <div class="form-tip">开启后，每个考生看到的题目顺序不同</div>
        </el-form-item>

        <el-form-item label="乱序选项">
          <el-switch
            v-model="formData.shuffleOptions"
            :active-value="1"
            :inactive-value="0"
          />
          <div class="form-tip">开启后，每个考生看到的选项顺序不同</div>
        </el-form-item>

        <!-- 其他设置 -->
        <el-divider content-position="left">其他设置</el-divider>

        <el-form-item label="立即显示成绩">
          <el-switch
            v-model="formData.showScoreImmediately"
            :active-value="1"
            :inactive-value="0"
          />
          <div class="form-tip">开启后，考生提交试卷后立即显示成绩</div>
        </el-form-item>

        <el-form-item label="主观题防抄袭">
          <el-switch
            v-model="formData.antiPlagiarism"
            :active-value="1"
            :inactive-value="0"
          />
        </el-form-item>

        <el-form-item label="相似度阈值" v-if="formData.antiPlagiarism === 1">
          <el-input-number
            v-model="formData.plagiarismThreshold"
            :min="0"
            :max="100"
            :step="5"
          />
          <span style="margin-left: 10px">%（超过此值将标记为疑似抄袭）</span>
        </el-form-item>

        <!-- 按钮 -->
        <el-form-item>
          <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
            {{ isEdit ? '保存' : '创建' }}
          </el-button>
          <el-button @click="handleBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getExamDetail, createExam, updateExam } from '@/api/exam'
import { getPaperPage } from '@/api/paper'

const route = useRoute()
const router = useRouter()

const formRef = ref(null)
const submitLoading = ref(false)
const paperList = ref([])

const isEdit = computed(() => !!route.params.id)

const formData = reactive({
  examName: '',
  description: '',
  paperId: null,
  timeRange: [],
  startTime: '',
  endTime: '',
  duration: 60,
  examRangeType: 1,
  examRangeIds: '',
  examStatus: 0,
  cutScreenLimit: 3,
  cutScreenTimer: 0,
  forbidCopy: 1,
  singleDevice: 1,
  shuffleQuestions: 0,
  shuffleOptions: 0,
  antiPlagiarism: 0,
  plagiarismThreshold: 80,
  remindTime: 15,
  showScoreImmediately: 0
})

const rules = {
  examName: [
    { required: true, message: '请输入考试名称', trigger: 'blur' }
  ],
  paperId: [
    { required: true, message: '请选择试卷', trigger: 'change' }
  ],
  timeRange: [
    { required: true, message: '请选择考试时间', trigger: 'change' }
  ],
  duration: [
    { required: true, message: '请输入考试时长', trigger: 'blur' }
  ],
  examRangeType: [
    { required: true, message: '请选择范围类型', trigger: 'change' }
  ],
  examRangeIds: [
    { required: true, message: '请输入范围ID', trigger: 'blur' }
  ]
}

// 获取试卷列表
const getPaperList = async () => {
  try {
    const res = await getPaperPage({ current: 1, size: 1000, auditStatus: 2 })
    if (res.code === 200) {
      paperList.value = res.data.records
    }
  } catch (error) {
    console.error('获取试卷列表失败', error)
  }
}

// 获取考试详情
const getDetail = async () => {
  try {
    const res = await getExamDetail(route.params.id)
    if (res.code === 200) {
      const data = res.data
      Object.assign(formData, data)
      // 处理时间范围
      if (data.startTime && data.endTime) {
        formData.timeRange = [data.startTime, data.endTime]
      }
    }
  } catch (error) {
    ElMessage.error('获取考试详情失败')
  }
}

// 提交
const handleSubmit = async () => {
  try {
    await formRef.value.validate()

    // 处理时间
    if (formData.timeRange && formData.timeRange.length === 2) {
      formData.startTime = formData.timeRange[0]
      formData.endTime = formData.timeRange[1]
    }

    submitLoading.value = true

    let res
    if (isEdit.value) {
      res = await updateExam(route.params.id, formData)
    } else {
      res = await createExam(formData)
    }

    if (res.code === 200) {
      ElMessage.success(isEdit.value ? '保存成功' : '创建成功')
      router.push({ name: 'ExamList' })
    } else {
      ElMessage.error(res.message || (isEdit.value ? '保存失败' : '创建失败'))
    }
  } catch (error) {
    console.error('提交失败', error)
  } finally {
    submitLoading.value = false
  }
}

// 返回
const handleBack = () => {
  router.back()
}

onMounted(async () => {
  await getPaperList()
  if (isEdit.value) {
    await getDetail()
  }
})
</script>

<style scoped>
.exam-edit-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.form-tip {
  color: #909399;
  font-size: 12px;
  margin-top: 5px;
}
</style>

