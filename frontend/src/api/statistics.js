/**
 * 统计分析 API
 * @description 对应后端 StatisticsController (/api/statistics/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 考试统计
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getExamStatistics(examId) {
    return request({
      url: `/statistics/exam/${examId}`,
      method: `get`
    })
  },

  /**
   * 考生统计
   * @param {number} userId 用户ID
   * @returns {Promise}
   */
  getUserStatistics(userId) {
    return request({
      url: `/statistics/user/${userId}`,
      method: `get`
    })
  },

  /**
   * 题目统计
   * @param {number} questionId 题目ID
   * @returns {Promise}
   */
  getQuestionStatistics(questionId) {
    return request({
      url: `/statistics/question/${questionId}`,
      method: `get`
    })
  },

  /**
   * 题库统计
   * @param {number} bankId 题库ID
   * @returns {Promise}
   */
  getBankStatistics(bankId) {
    return request({
      url: `/statistics/bank/${bankId}`,
      method: `get`
    })
  },

  /**
   * 成绩分布
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getScoreDistribution(examId) {
    return request({
      url: `/statistics/exam/${examId}/score-distribution`,
      method: `get`
    })
  },

  /**
   * 答题率统计
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getAnswerRate(examId) {
    return request({
      url: `/statistics/exam/${examId}/answer-rate`,
      method: `get`
    })
  },

  /**
   * 错题分析
   * @param {number} userId 用户ID
   * @returns {Promise}
   */
  getWrongQuestions(userId) {
    return request({
      url: `/statistics/user/${userId}/wrong-questions`,
      method: `get`
    })
  },

  /**
   * 能力分析
   * @param {number} userId 用户ID
   * @returns {Promise}
   */
  getAbilityAnalysis(userId) {
    return request({
      url: `/statistics/user/${userId}/ability`,
      method: `get`
    })
  },

  /**
   * 获取首页仪表盘数据
   * @param {number} userId 用户ID
   * @param {string} role 用户角色
   * @returns {Promise}
   */
  getDashboard(userId, role) {
    return request({
      url: `/statistics/dashboard`,
      method: `get`,
      params: { userId, role }
    })
  },

  /**
   * 获取系统统计概览
   * @returns {Promise}
   */
  getSystemOverview() {
    return request({
      url: `/statistics/overview`,
      method: `get`
    })
  }
}

