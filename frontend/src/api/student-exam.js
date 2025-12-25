/**
 * 学生考试相关API
 * @description 学生参加考试、答题、提交等功能
 */

import request from '@/utils/request'

export default {
  /**
   * 获取我的考试列表
   * @param {Object} params - 查询参数
   * @param {String} params.status - 考试状态（可选）
   * @returns {Promise}
   */
  getMyExams(params) {
    return request({
      url: '/exam/my-exams',
      method: 'get',
      params
    })
  },

  /**
   * 开始考试
   * @param {Number} examId - 考试ID
   * @returns {Promise<ExamSession>}
   */
  startExam(examId) {
    return request({
      url: `/student/exam/${examId}/start`,
      method: 'post'
    })
  },

  /**
   * 获取考试会话信息
   * @param {String} sessionId - 会话ID
   * @returns {Promise<ExamSession>}
   */
  getSession(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}`,
      method: 'get'
    })
  },

  /**
   * 保存单个答案
   * @param {String} sessionId - 会话ID
   * @param {Object} answer - 答案对象
   * @returns {Promise}
   */
  saveAnswer(sessionId, answer) {
    return request({
      url: `/student/exam/session/${sessionId}/answer`,
      method: 'post',
      data: answer
    })
  },

  /**
   * 批量保存答案
   * @param {String} sessionId - 会话ID
   * @param {Array} answers - 答案列表
   * @returns {Promise}
   */
  saveAnswers(sessionId, answers) {
    return request({
      url: `/student/exam/session/${sessionId}/answers`,
      method: 'post',
      data: { answers }
    })
  },

  /**
   * 获取会话的所有答案
   * @param {String} sessionId - 会话ID
   * @returns {Promise<Array<ExamAnswer>>}
   */
  getAnswers(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}/answers`,
      method: 'get'
    })
  },

  /**
   * 获取单个题目的答案
   * @param {String} sessionId - 会话ID
   * @param {Number} questionId - 题目ID
   * @returns {Promise<ExamAnswer>}
   */
  getAnswer(sessionId, questionId) {
    return request({
      url: `/student/exam/session/${sessionId}/answer/${questionId}`,
      method: 'get'
    })
  },

  /**
   * 提交考试
   * @param {String} sessionId - 会话ID
   * @returns {Promise}
   */
  submitExam(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}/submit`,
      method: 'post'
    })
  },

  /**
   * 记录切屏行为
   * @param {String} sessionId - 会话ID
   * @returns {Promise<Number>} 返回切屏次数
   */
  recordTabSwitch(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}/tab-switch`,
      method: 'post'
    })
  },

  /**
   * 发送心跳，保持会话活跃
   * @param {String} sessionId - 会话ID
   * @returns {Promise}
   */
  heartbeat(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}/heartbeat`,
      method: 'post'
    })
  },

  /**
   * 获取考试进度
   * @param {String} sessionId - 会话ID
   * @returns {Promise}
   */
  getProgress(sessionId) {
    return request({
      url: `/student/exam/session/${sessionId}/progress`,
      method: 'get'
    })
  }
}

