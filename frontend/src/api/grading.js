/**
 * 阅卷管理 API
 * @description 对应后端 GradingController (/api/grading/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 查询待阅卷列表
   * @param {Object} params {current, size, examId, questionId, teacherId}
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
   * @param {Object} params {answerId, score, comment, teacherId}
   * @returns {Promise}
   */
  gradeAnswer(params) {
    return request({
      url: `/grading/grade`,
      method: `post`,
      params
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
   * @param {number} teacherId 教师ID
   * @returns {Promise}
   */
  getMyTasks(teacherId) {
    return request({
      url: `/grading/my-tasks`,
      method: `get`,
      params: { teacherId }
    })
  },

  /**
   * 分配阅卷任务
   * @param {number} examId 考试ID
   * @param {number} questionId 题目ID
   * @param {Array} teacherIds 教师ID列表
   * @returns {Promise}
   */
  assignTasks(examId, questionId, teacherIds) {
    return request({
      url: `/grading/assign`,
      method: `post`,
      params: { examId, questionId },
      data: teacherIds
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

