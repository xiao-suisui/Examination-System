/**
 * 试卷管理 API
 */

import request from '@/utils/request'

export default {
  /**
   * 分页查询试卷
   */
  page(params) {
    return request({
      url: '/api/paper/page',
      method: 'get',
      params
    })
  },

  /**
   * 根据ID查询试卷
   */
  getById(id) {
    return request({
      url: `/api/paper/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建试卷
   */
  create(data) {
    return request({
      url: '/api/paper',
      method: 'post',
      data
    })
  },

  /**
   * 更新试卷
   */
  update(id, data) {
    return request({
      url: `/api/paper/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除试卷
   */
  deleteById(id) {
    return request({
      url: `/api/paper/${id}`,
      method: 'delete'
    })
  },

  /**
   * 智能组卷
   */
  autoGenerate(data) {
    return request({
      url: '/api/paper/auto-generate',
      method: 'post',
      data
    })
  },

  /**
   * 发布试卷
   */
  publish(id) {
    return request({
      url: `/api/paper/${id}/publish`,
      method: 'post'
    })
  },

  /**
   * 归档试卷
   */
  archive(id) {
    return request({
      url: `/api/paper/${id}/archive`,
      method: 'post'
    })
  },

  /**
   * 获取试卷统计信息
   */
  getStatistics(id) {
    return request({
      url: `/api/paper/${id}/statistics`,
      method: 'get'
    })
  },

  /**
   * 预览试卷
   */
  preview(id) {
    return request({
      url: `/api/paper/${id}/preview`,
      method: 'get'
    })
  }
}

