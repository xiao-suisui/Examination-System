/**
 * 考试管理 API
 * @description 对应后端 ExamController (/api/exam/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 分页查询考试
   * @param {Object} params {page, size, keyword, status}
   * @returns {Promise}
   */
  getExamPage(params) {
    return request({
      url: '/api/exam/page',
      method: 'get',
      params
    })
  },

  /**
   * 根据ID查询考试
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  getExamById(id) {
    return request({
      url: `/api/exam/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建考试
   * @param {Object} data 考试信息
   * @returns {Promise}
   */
  createExam(data) {
    return request({
      url: '/api/exam',
      method: 'post',
      data
    })
  },

  /**
   * 更新考试
   * @param {number} id 考试ID
   * @param {Object} data 考试信息
   * @returns {Promise}
   */
  updateExam(id, data) {
    return request({
      url: `/api/exam/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除考试
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  deleteExam(id) {
    return request({
      url: `/api/exam/${id}`,
      method: 'delete'
    })
  },

  /**
   * 发布考试
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  publishExam(id) {
    return request({
      url: `/api/exam/${id}/publish`,
      method: 'post'
    })
  },

  /**
   * 开始考试
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  startExam(id) {
    return request({
      url: `/api/exam/${id}/start`,
      method: 'post'
    })
  },

  /**
   * 结束考试
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  endExam(id) {
    return request({
      url: `/api/exam/${id}/end`,
      method: 'post'
    })
  },

  /**
   * 考试监控
   * @param {number} id 考试ID
   * @returns {Promise}
   */
  getExamMonitor(id) {
    return request({
      url: `/api/exam/${id}/monitor`,
      method: 'get'
    })
  },

  /**
   * 获取我的考试列表
   * @returns {Promise}
   */
  getMyExams() {
    return request({
      url: '/api/exam/my-exams',
      method: 'get'
    })
  }
}

