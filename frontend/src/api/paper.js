/**
 * 试卷管理 API
 */

import request from '@/utils/request'

export default {
  /**
   * 获取试卷列表（全部）
   */
  list(params) {
    return request({
      url: `/paper/list`,
      method: `get`,
      params
    })
  },

  /**
   * 分页查询试卷
   */
  page(params) {
    return request({
      url: `/paper/page`,
      method: `get`,
      params
    })
  },

  /**
   * 根据ID查询试卷
   */
  getById(id) {
    return request({
      url: `/paper/${id}`,
      method: `get`
    })
  },

  /**
   * 创建试卷
   */
  create(data) {
    return request({
      url: `/paper`,
      method: `post`,
      data
    })
  },

  /**
   * 更新试卷
   */
  update(id, data) {
    return request({
      url: `/paper/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除试卷
   */
  deleteById(id) {
    return request({
      url: `/paper/${id}`,
      method: `delete`
    })
  },

  /**
   * 智能组卷
   */
  autoGenerate(data) {
    return request({
      url: `/api/paper/auto-generate`,
      method: 'post',
      data
    })
  },

  /**
   * 发布试卷
   */
  publish(id) {
    return request({
      url: `/paper/${id}/publish`,
      method: `post`
    })
  },

  /**
   * 归档试卷
   */
  archive(id) {
    return request({
      url: `/paper/${id}/archive`,
      method: `post`
    })
  },

  /**
   * 获取试卷统计信息
   */
  getStatistics(id) {
    return request({
      url: `/paper/${id}/statistics`,
      method: `get`
    })
  },

  /**
   * 预览试卷
   */
  preview(id) {
    return request({
      url: `/paper/${id}/preview`,
      method: `get`
    })
  },

  /**
   * 添加题目到试卷
   */
  addQuestions(id, questionIds) {
    return request({
      url: `/paper/${id}/questions`,
      method: `post`,
      data: questionIds
    })
  },

  /**
   * 从试卷移除题目
   */
  removeQuestions(id, questionIds) {
    return request({
      url: `/paper/${id}/questions`,
      method: `delete`,
      data: questionIds
    })
  }
}

