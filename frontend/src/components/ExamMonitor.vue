<template>
  <div class="exam-monitor">
    <!-- 监控组件是无UI的，只负责监控和上报 -->
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import studentExamApi from '@/api/studentExam'

const props = defineProps({
  sessionId: {
    type: String,
    required: true
  },
  examId: {
    type: Number,
    required: true
  },
  config: {
    type: Object,
    default: () => ({
      enableTabSwitch: true,      // 切屏检测
      enableCopy: true,            // 复制检测
      enablePaste: true,           // 粘贴检测
      enableRightClick: true,      // 右键检测
      enableFullscreen: true,      // 全屏检测
      enableIdleTimeout: true,     // 长时间无操作检测
      tabSwitchLimit: 3,           // 切屏次数限制
      idleTimeout: 300,            // 无操作超时时间（秒）
      autoSubmitOnViolation: false // 达到限制是否自动提交
    })
  }
})

const emit = defineEmits(['violation', 'limitReached'])

// 状态
const violationCount = ref({
  tabSwitch: 0,
  copy: 0,
  paste: 0,
  rightClick: 0,
  exitFullscreen: 0,
  idleTimeout: 0
})

let idleTimer = null
let lastActivityTime = Date.now()

// ==================== 违规记录 ====================

/**
 * 记录违规行为
 */
const recordViolation = async (type, detail = {}) => {
  try {
    // 增加违规计数
    if (violationCount.value[type] !== undefined) {
      violationCount.value[type]++
    }

    // 上报到服务器
    const res = await studentExamApi.recordViolation(props.sessionId, {
      violationType: type,
      violationDetail: JSON.stringify(detail),
      violationTime: new Date().toISOString()
    })

    if (res.code === 200) {
      const totalViolations = res.data?.totalViolations || 0

      // 触发违规事件
      emit('violation', {
        type,
        count: violationCount.value[type],
        total: totalViolations,
        detail
      })

      // 显示警告
      showViolationWarning(type, violationCount.value[type], totalViolations)

      // 检查是否达到限制
      if (props.config.tabSwitchLimit > 0 && totalViolations >= props.config.tabSwitchLimit) {
        handleLimitReached(totalViolations)
      }
    }
  } catch (error) {
    console.error('记录违规失败:', error)
  }
}

/**
 * 显示违规警告
 */
const showViolationWarning = (type, count, total) => {
  const messages = {
    tabSwitch: `检测到切屏行为（${count}次）`,
    copy: `检测到复制行为（${count}次）`,
    paste: `检测到粘贴行为（${count}次）`,
    rightClick: `请勿使用右键菜单（${count}次）`,
    exitFullscreen: `请保持全屏模式（${count}次）`,
    idleTimeout: `检测到长时间无操作（${count}次）`
  }

  const limit = props.config.tabSwitchLimit
  const message = limit > 0
    ? `${messages[type] || '检测到异常行为'}，总计：${total}/${limit}`
    : messages[type] || '检测到异常行为'

  ElMessage.warning(message)
}

/**
 * 达到违规限制
 */
const handleLimitReached = async (total) => {
  emit('limitReached', total)

  if (props.config.autoSubmitOnViolation) {
    try {
      await ElMessageBox.alert(
        `您的违规次数已达到上限（${total}次），系统将自动提交试卷。`,
        '警告',
        {
          type: 'error',
          showClose: false,
          closeOnClickModal: false,
          closeOnPressEscape: false
        }
      )

      // 触发自动提交
      emit('auto-submit')
    } catch (error) {
      console.error('自动提交失败:', error)
    }
  } else {
    ElMessageBox.alert(
      `您的违规次数已达到上限（${total}次），请注意考试纪律。`,
      '严重警告',
      {
        type: 'error'
      }
    )
  }
}

// ==================== 切屏检测 ====================

const handleVisibilityChange = () => {
  if (!props.config.enableTabSwitch) return

  if (document.hidden) {
    recordViolation('tabSwitch', {
      timestamp: Date.now(),
      action: 'tab_hidden'
    })
  }
}

// ==================== 复制/粘贴检测 ====================

const handleCopy = (e) => {
  if (!props.config.enableCopy) return

  // 阻止复制
  e.preventDefault()

  recordViolation('copy', {
    timestamp: Date.now(),
    selection: window.getSelection()?.toString().substring(0, 100)
  })
}

const handlePaste = (e) => {
  if (!props.config.enablePaste) return

  // 阻止粘贴
  e.preventDefault()

  recordViolation('paste', {
    timestamp: Date.now(),
    data: e.clipboardData?.getData('text')?.substring(0, 100)
  })
}

// ==================== 右键菜单检测 ====================

const handleContextMenu = (e) => {
  if (!props.config.enableRightClick) return

  // 阻止右键菜单
  e.preventDefault()

  recordViolation('rightClick', {
    timestamp: Date.now(),
    target: e.target?.tagName
  })
}

// ==================== 全屏检测 ====================

const handleFullscreenChange = () => {
  if (!props.config.enableFullscreen) return

  if (!document.fullscreenElement) {
    recordViolation('exitFullscreen', {
      timestamp: Date.now()
    })

    // 提示重新进入全屏
    ElMessage.warning('检测到退出全屏，请重新进入全屏模式')

    // 尝试重新进入全屏
    setTimeout(() => {
      requestFullscreen()
    }, 2000)
  }
}

/**
 * 请求进入全屏
 */
const requestFullscreen = () => {
  const elem = document.documentElement
  if (elem.requestFullscreen) {
    elem.requestFullscreen().catch(err => {
      console.error('进入全屏失败:', err)
    })
  }
}

// ==================== 长时间无操作检测 ====================

const resetIdleTimer = () => {
  lastActivityTime = Date.now()

  if (idleTimer) {
    clearTimeout(idleTimer)
  }

  if (props.config.enableIdleTimeout && props.config.idleTimeout > 0) {
    idleTimer = setTimeout(() => {
      checkIdle()
    }, props.config.idleTimeout * 1000)
  }
}

const checkIdle = () => {
  const idleTime = (Date.now() - lastActivityTime) / 1000

  if (idleTime >= props.config.idleTimeout) {
    recordViolation('idleTimeout', {
      timestamp: Date.now(),
      idleTime: Math.floor(idleTime)
    })
  }

  // 重新设置定时器
  resetIdleTimer()
}

// 监听用户活动
const handleUserActivity = () => {
  resetIdleTimer()
}

// ==================== 生命周期 ====================

onMounted(() => {
  // 添加事件监听
  if (props.config.enableTabSwitch) {
    document.addEventListener('visibilitychange', handleVisibilityChange)
  }

  if (props.config.enableCopy) {
    document.addEventListener('copy', handleCopy)
  }

  if (props.config.enablePaste) {
    document.addEventListener('paste', handlePaste)
  }

  if (props.config.enableRightClick) {
    document.addEventListener('contextmenu', handleContextMenu)
  }

  if (props.config.enableFullscreen) {
    document.addEventListener('fullscreenchange', handleFullscreenChange)

    // 初始进入全屏
    setTimeout(() => {
      requestFullscreen()
    }, 1000)
  }

  if (props.config.enableIdleTimeout) {
    // 监听用户活动
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']
    events.forEach(event => {
      document.addEventListener(event, handleUserActivity)
    })

    // 启动定时器
    resetIdleTimer()
  }

  console.log('[ExamMonitor] 异常检测已启动', props.config)
})

onBeforeUnmount(() => {
  // 移除事件监听
  document.removeEventListener('visibilitychange', handleVisibilityChange)
  document.removeEventListener('copy', handleCopy)
  document.removeEventListener('paste', handlePaste)
  document.removeEventListener('contextmenu', handleContextMenu)
  document.removeEventListener('fullscreenchange', handleFullscreenChange)

  const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']
  events.forEach(event => {
    document.removeEventListener(event, handleUserActivity)
  })

  if (idleTimer) {
    clearTimeout(idleTimer)
  }

  console.log('[ExamMonitor] 异常检测已停止')
})

// 暴露方法给父组件
defineExpose({
  getViolationCount: () => violationCount.value,
  requestFullscreen
})
</script>

<style scoped>
.exam-monitor {
  display: none;
}
</style>

