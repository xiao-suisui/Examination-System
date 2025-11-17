/**
 * 知识点管理 API
 * @description 对应后端 KnowledgePointController (/api/knowledge-point/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 获取知识点树
   * @param {number} bankId 题库ID
   * @returns {Promise}
   */
  getKnowledgeTree(bankId) {
    return request({
      url: '/api/knowledge-point/tree',
      method: 'get',
      params: { bankId }
    })
  },

  /**
   * 根据ID查询知识点
   * @param {number} id 知识点ID
   * @returns {Promise}
   */
  getKnowledgePointById(id) {
    return request({
      url: `/api/knowledge-point/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建知识点
   * @param {Object} data 知识点信息
   * @returns {Promise}
   */
  createKnowledgePoint(data) {
    return request({
      url: '/api/knowledge-point',
      method: 'post',
      data
    })
  },

  /**
   * 更新知识点
   * @param {number} id 知识点ID
   * @param {Object} data 知识点信息
   * @returns {Promise}
   */
  updateKnowledgePoint(id, data) {
    return request({
      url: `/api/knowledge-point/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除知识点
   * @param {number} id 知识点ID
   * @returns {Promise}
   */
  deleteKnowledgePoint(id) {
    return request({
      url: `/api/knowledge-point/${id}`,
      method: 'delete'
    })
  },

  /**
   * 移动知识点
   * @param {number} id 知识点ID
   * @param {Object} data {targetParentId, position}
   * @returns {Promise}
   */
  moveKnowledgePoint(id, data) {
    return request({
      url: `/api/knowledge-point/${id}/move`,
      method: 'post',
      data
    })
  }
}

