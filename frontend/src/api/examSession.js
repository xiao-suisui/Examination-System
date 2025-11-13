/**
 * 考试会话 API
 */
import request from '@/utils/request'

/**
 * 创建考试会话（开始考试）
 */
export function createExamSession(data) {
  return request({
    url: '/exam-session',
    method: 'post',
    data
  })
}

/**
 * 获取考试会话详情
 */
export function getExamSession(sessionId) {
  return request({
    url: `/exam-session/${sessionId}`,
    method: 'get'
  })
}

/**
 * 提交答案
 */
export function submitAnswer(data) {
  return request({
    url: '/exam-session/answer',
    method: 'post',
    data
  })
}

/**
 * 提交试卷
 */
export function submitExamPaper(sessionId) {
  return request({
    url: `/exam-session/${sessionId}/submit`,
    method: 'post'
  })
}

/**
 * 记录切屏
 */
export function recordTabSwitch(sessionId) {
  return request({
    url: `/exam-session/${sessionId}/tab-switch`,
    method: 'post'
  })
}

/**
 * 获取考试结果
 */
export function getExamResult(sessionId) {
  return request({
    url: `/exam-session/${sessionId}/result`,
    method: 'get'
  })
}

/**
 * 获取我的考试会话列表
 */
export function getMyExamSessions(params) {
  return request({
    url: '/exam-session/my-sessions',
    method: 'get',
    params
  })
}

/**
 * 心跳（保持在线状态）
 */
export function heartbeat(sessionId) {
  return request({
    url: `/exam-session/${sessionId}/heartbeat`,
    method: 'post'
  })
}

