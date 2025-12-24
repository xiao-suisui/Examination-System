/**
 * 考试会话 API
 */
import request from '@/utils/request'

export default {
  /**
   * 创建考试会话（开始考试）
   */
  create(data) {
    return request({
      url: `/exam-session`,
      method: `post`,
      data
    })
  },

  /**
   * 获取考试会话详情
   */
  getById(sessionId) {
    return request({
      url: `/exam-session/${sessionId}`,
      method: `get`
    })
  },

  /**
   * 提交答案
   */
  submitAnswer(data) {
    return request({
      url: `/exam-session/answer`,
      method: `post`,
      data
    })
  },

  /**
   * 提交试卷
   */
  submit(sessionId) {
    return request({
      url: `/exam-session/${sessionId}/submit`,
      method: `delete`
    })
  },

  /**
   * 记录切屏
   */
  recordTabSwitch(sessionId) {
    return request({
      url: `/exam-session/${sessionId}/tab-switch`,
      method: `post`
    })
  },

  /**
   * 获取考试结果
   */
  getResult(sessionId) {
    return request({
      url: `/exam-session/${sessionId}/result`,
      method: `get`
    })
  },

  /**
   * 获取我的考试会话列表
   */
  getMySessions(params) {
    return request({
      url: `/exam-session/my-sessions`,
      method: `get`,
      params
    })
  },

  /**
   * 心跳（保持在线状态）
   */
  heartbeat(sessionId) {
    return request({
      url: `/exam-session/${sessionId}/heartbeat`,
      method: `post`
    })
  },

  /**
   * 获取我的成绩列表（学生端）
   */
  getMyScores(params) {
    return request({
      url: `/exam-session/my-scores`,
      method: `get`,
      params
    })
  },

  /**
   * 获取考试统计信息（学生端）
   */
  getMyStatistics() {
    return request({
      url: `/exam-session/my-statistics`,
      method: `get`
    })
  }
}

