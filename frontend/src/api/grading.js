/**
 * 阅卷管理 API
 * @description 对应后端 GradingController (/api/grading/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 查询待阅卷列表
   * @param {Object} params {page, size, examId}
   * @returns {Promise}
   */
  getPendingGradingList(params) {
    return request({
      url: `/grading/pending`,
      method: `get`,
      params
    })
  },

  /**
   * 单题阅卷
   * @param {Object} data {answerId, score, remark}
   * @returns {Promise}
   */
  gradeAnswer(data) {
    return request({
      url: `/grading/grade`,
      method: `post`,
      data
    })
  },

  /**
   * 批量阅卷
   * @param {Array} data 阅卷数据数组
   * @returns {Promise}
   */
  batchGrade(data) {
    return request({
      url: `/grading/batch-grade`,
      method: `post`,
      data
    })
  },

  /**
   * 我的阅卷任务
   * @param {Object} params {page, size}
   * @returns {Promise}
   */
  getMyTasks(params) {
    return request({
      url: `/grading/my-tasks`,
      method: `get`,
      params
    })
  },

  /**
   * 分配阅卷任务
   * @param {Object} data {examId, teacherIds, questionIds}
   * @returns {Promise}
   */
  assignTasks(data) {
    return request({
      url: `/grading/assign`,
      method: `post`,
      data
    })
  },

  /**
   * 查询阅卷进度
   * @param {number} examId 考试ID
   * @returns {Promise}
   */
  getGradingProgress(examId) {
    return request({
      url: `/grading/progress/${examId}`,
      method: `get`
    })
  },

  /**
   * 成绩复核请求
   * @param {Object} data {sessionId, reason}
   * @returns {Promise}
   */
  requestReview(data) {
    return request({
      url: `/grading/review-request`,
      method: `post`,
      data
    })
  },

  /**
   * 处理成绩复核
   * @param {Object} data {reviewId, approved, newScore, remark}
   * @returns {Promise}
   */
  handleReview(data) {
    return request({
      url: `/grading/review-handle`,
      method: `post`,
      data
    })
  }
}

