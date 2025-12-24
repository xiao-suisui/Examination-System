/**
 * 题库管理 API
 */

import request from '@/utils/request'

export default {
  /**
   * 分页查询题库
   */
  page(params) {
    return request({
      url: `/question-bank/page`,
      method: `get`,
      params
    })
  },

  /**
   * 查询所有题库
   */
  list() {
    return request({
      url: `/question-bank/list`,
      method: `get`
    })
  },

  /**
   * 根据ID查询题库
   */
  getById(id) {
    return request({
      url: `/question-bank/${id}`,
      method: `get`
    })
  },

  /**
   * 创建题库
   */
  create(data) {
    return request({
      url: `/question-bank`,
      method: `post`,
      data
    })
  },

  /**
   * 更新题库
   */
  update(id, data) {
    return request({
      url: `/question-bank/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除题库
   */
  deleteById(id) {
    return request({
      url: `/question-bank/${id}`,
      method: `delete`
    })
  },

  /**
   * 获取题库统计信息
   */
  getStatistics(id) {
    return request({
      url: `/question-bank/${id}/statistics`,
      method: `get`
    })
  },

  /**
   * 批量添加题目到题库
   */
  addQuestions(bankId, questionIds) {
    return request({
      url: `/question-bank/${bankId}/questions`,
      method: `post`,
      data: { questionIds }
    })
  },

  /**
   * 从题库移除题目
   */
  removeQuestion(bankId, questionId) {
    return request({
      url: `/question-bank/${bankId}/questions/${questionId}`,
      method: `delete`
    })
  }
}

