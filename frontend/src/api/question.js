/**
 * 题目管理 API
 */

import request from '@/utils/request'

export default {
  /**
   * 分页查询题目
   */
  page(params) {
    return request({
      url: '/api/question/page',
      method: 'get',
      params
    })
  },

  /**
   * 查询所有题目
   */
  list(params) {
    return request({
      url: '/api/question/list',
      method: 'get',
      params
    })
  },

  /**
   * 根据ID查询题目
   */
  getById(id) {
    return request({
      url: `/api/question/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建题目
   */
  create(data) {
    return request({
      url: '/api/question',
      method: 'post',
      data
    })
  },

  /**
   * 更新题目
   */
  update(id, data) {
    return request({
      url: `/api/question/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除题目
   */
  deleteById(id) {
    return request({
      url: `/api/question/${id}`,
      method: 'delete'
    })
  },

  /**
   * 批量删除题目
   */
  batchDelete(ids) {
    return request({
      url: '/api/question/batch',
      method: 'delete',
      data: ids
    })
  },

  /**
   * 审核题目
   */
  audit(id, data) {
    return request({
      url: `/api/question/${id}/audit`,
      method: 'post',
      data
    })
  },

  /**
   * 导入题目
   */
  importQuestions(bankId, file) {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('bankId', bankId)

    return request({
      url: '/api/question/import',
      method: 'post',
      data: formData,
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  /**
   * 导出题目
   */
  exportQuestions(params) {
    return request({
      url: '/api/question/export',
      method: 'get',
      params,
      responseType: 'blob'
    })
  }
}

