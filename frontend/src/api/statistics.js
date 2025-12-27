/**
 * 统计分析 API
 * @description 对应后端 StatisticsController (/api/statistics/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 获取仪表盘数据
   * @param {number} userId 用户ID
   * @param {string} role 角色
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
   * 考试统计概览
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getExamOverview(examId) {
    return request({
      url: `/statistics/exam/${examId}/overview`,
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
   * 题目统计
   * @param {number} questionId 题目ID
   * @param {number} examId 考试ID (可选)
   * @returns {Promise}
   */
  getQuestionStatistics(questionId, examId) {
    return request({
      url: `/statistics/question/${questionId}`,
      method: `get`,
      params: { examId }
    })
  },

  /**
   * 知识点掌握度
   * @param {number} userId 用户ID
   * @param {number} bankId 题库ID (可选)
   * @returns {Promise}
   */
  getKnowledgeMastery(userId, bankId) {
    return request({
      url: `/statistics/knowledge-mastery`,
      method: `get`,
      params: { userId, bankId }
    })
  },

  /**
   * 学生成绩报告
   * @param {number} userId 用户ID
   * @param {number} examId 考试ID (可选)
   * @param {string} startTime 开始时间 (可选)
   * @param {string} endTime 结束时间 (可选)
   * @returns {Promise}
   */
  getStudentReport(userId, examId, startTime, endTime) {
    return request({
      url: `/statistics/student/${userId}/report`,
      method: `get`,
      params: { examId, startTime, endTime }
    })
  },

  /**
   * 班级成绩对比
   * @param {number} examId 考试ID
   * @param {Array} organizationIds 组织ID列表
   * @returns {Promise}
   */
  getClassComparison(examId, organizationIds) {
    return request({
      url: `/statistics/class-comparison`,
      method: `get`,
      params: { examId, organizationIds: organizationIds.join(',') }
    })
  },

  /**
   * 趋势分析
   * @param {number} userId 用户ID (可选)
   * @param {string} startTime 开始时间
   * @param {string} endTime 结束时间
   * @returns {Promise}
   */
  getTrendAnalysis(userId, startTime, endTime) {
    return request({
      url: `/statistics/trend`,
      method: `get`,
      params: { userId, startTime, endTime }
    })
  },

  /**
   * 题库质量分析
   * @param {number} bankId 题库ID
   * @returns {Promise}
   */
  getBankQualityAnalysis(bankId) {
    return request({
      url: `/statistics/bank/${bankId}/quality`,
      method: `get`
    })
  },

  /**
   * 系统使用统计
   * @param {string} startTime 开始时间
   * @param {string} endTime 结束时间
   * @returns {Promise}
   */
  getSystemUsage(startTime, endTime) {
    return request({
      url: `/statistics/system-usage`,
      method: `get`,
      params: { startTime, endTime }
    })
  },

  /**
   * 导出报表
   * @param {string} type 报表类型
   * @param {number} examId 考试ID (可选)
   * @param {string} startTime 开始时间 (可选)
   * @param {string} endTime 结束时间 (可选)
   * @returns {Promise}
   */
  exportReport(type, examId, startTime, endTime) {
    return request({
      url: `/statistics/export/${type}`,
      method: `get`,
      params: { examId, startTime, endTime },
      responseType: 'blob'
    })
  },

  /**
   * 违规统计
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getViolationStatistics(examId) {
    return request({
      url: `/statistics/exam/${examId}/violations`,
      method: `get`
    })
  }
}

