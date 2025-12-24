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
  getTree(bankId) {
    return request({
      url: `/knowledge-point/tree`,
      method: `get`,
      params: { bankId }
    })
  },

  /**
   * 根据ID查询知识点
   * @param {number} id 知识点ID
   * @returns {Promise}
   */
  getById(id) {
    return request({
      url: `/knowledge-point/${id}`,
      method: `get`
    })
  },

  /**
   * 创建知识点
   * @param {Object} data 知识点信息
   * @returns {Promise}
   */
  create(data) {
    return request({
      url: `/knowledge-point`,
      method: `post`,
      data
    })
  },

  /**
   * 更新知识点
   * @param {number} id 知识点ID
   * @param {Object} data 知识点信息
   * @returns {Promise}
   */
  update(id, data) {
    return request({
      url: `/knowledge-point/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除知识点
   * @param {number} id 知识点ID
   * @returns {Promise}
   */
  deleteById(id) {
    return request({
      url: `/knowledge-point/${id}`,
      method: `delete`
    })
  },

  /**
   * 移动知识点
   * @param {number} id 知识点ID
   * @param {Object} data {targetParentId, position}
   * @returns {Promise}
   */
  move(id, data) {
    return request({
      url: `/knowledge-point/${id}/move`,
      method: `post`,
      data
    })
  }
}

