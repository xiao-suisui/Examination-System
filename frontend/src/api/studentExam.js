import request from '@/utils/request'

/**
 * 学生答卷API
 */

// 开始考试
export function startExam(examId, userId) {
  return request({
    url: `/student/exam/${examId}/start`,
    method: 'post',
    params: { userId }
  })
}

// 获取考试会话信息
export function getSession(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}`,
    method: 'get'
  })
}

// 保存单个答案
export function saveAnswer(sessionId, answer) {
  return request({
    url: `/student/exam/session/${sessionId}/answer`,
    method: 'post',
    data: answer
  })
}

// 批量保存答案
export function saveAnswers(sessionId, answers) {
  return request({
    url: `/student/exam/session/${sessionId}/answers`,
    method: 'post',
    data: { answers }
  })
}

// 获取答案列表
export function getAnswers(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}/answers`,
    method: 'get'
  })
}

// 获取单个答案
export function getAnswer(sessionId, questionId) {
  return request({
    url: `/student/exam/session/${sessionId}/answer/${questionId}`,
    method: 'get'
  })
}

// 提交考试
export function submitExam(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}/submit`,
    method: 'post'
  })
}

// 记录切屏
export function recordTabSwitch(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}/tab-switch`,
    method: 'post'
  })
}

// 心跳
export function heartbeat(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}/heartbeat`,
    method: 'post'
  })
}

// 获取考试进度
export function getProgress(sessionId) {
  return request({
    url: `/student/exam/session/${sessionId}/progress`,
    method: 'get'
  })
}

// 记录违规行为
export function recordViolation(sessionId, data) {
  return request({
    url: `/student/exam/session/${sessionId}/violation`,
    method: 'post',
    data
  })
}

export default {
  startExam,
  getSession,
  saveAnswer,
  saveAnswers,
  getAnswers,
  getAnswer,
  submitExam,
  recordTabSwitch,
  heartbeat,
  getProgress,
  recordViolation
}

