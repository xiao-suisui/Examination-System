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
      url: '/api/question-bank/page',
      method: 'get',
      params
    })
  },

  /**
   * 查询所有题库
   */
  list() {
    return request({
      url: '/api/question-bank/list',
      method: 'get'
    })
  },

  /**
   * 根据ID查询题库
   */
  getById(id) {
    return request({
      url: `/api/question-bank/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建题库
   */
  create(data) {
    return request({
      url: '/api/question-bank',
      method: 'post',
      data
    })
  },

  /**
   * 更新题库
   */
  update(id, data) {
    return request({
      url: `/api/question-bank/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除题库
   */
  deleteById(id) {
    return request({
      url: `/api/question-bank/${id}`,
      method: 'delete'
    })
  }
}

