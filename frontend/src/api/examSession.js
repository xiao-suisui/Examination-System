/**
 * 考试会话 API
 * @description 对应后端 ExamSessionController (/api/exam-session/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 开始考试
   * @param {Object} data {examId}
   * @returns {Promise}
   */
  startExamSession(data) {
    return request({
      url: '/api/exam-session/start',
      method: 'post',
      data
    })
  },

  /**
   * 获取考试试卷
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  getExamPaper(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/paper`,
      method: 'get'
    })
  },

  /**
   * 保存答案（单题）
   * @param {number} sessionId 会话ID
   * @param {Object} data 答案信息
   * @returns {Promise}
   */
  saveAnswer(sessionId, data) {
    return request({
      url: `/api/exam-session/${sessionId}/answer`,
      method: 'post',
      data
    })
  },

  /**
   * 批量保存答案
   * @param {number} sessionId 会话ID
   * @param {Array} data 答案列表
   * @returns {Promise}
   */
  saveAnswers(sessionId, data) {
    return request({
      url: `/api/exam-session/${sessionId}/answers`,
      method: 'post',
      data
    })
  },

  /**
   * 提交考试
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  submitExam(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/submit`,
      method: 'post'
    })
  },

  /**
   * 暂停考试
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  pauseExam(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/pause`,
      method: 'post'
    })
  },

  /**
   * 恢复考试
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  resumeExam(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/resume`,
      method: 'post'
    })
  },

  /**
   * 查询答题进度
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  getProgress(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/progress`,
      method: 'get'
    })
  },

  /**
   * 标记题目
   * @param {number} sessionId 会话ID
   * @param {Object} params {questionId, markType}
   * @returns {Promise}
   */
  markQuestion(sessionId, params) {
    return request({
      url: `/api/exam-session/${sessionId}/mark-question`,
      method: 'post',
      params
    })
  },

  /**
   * 获取考试结果
   * @param {number} sessionId 会话ID
   * @returns {Promise}
   */
  getExamResult(sessionId) {
    return request({
      url: `/api/exam-session/${sessionId}/result`,
      method: 'get'
    })
  }
}

