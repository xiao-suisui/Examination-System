 /**
 * 组织管理API
 */
import request from '@/utils/request'

export default {
  /**
   * 获取组织树
   */
  getTree() {
    return request({
      url: `/organization/tree`,
      method: `get`
    })
  },

  /**
   * 分页查询组织
   */
  page(params) {
    return request({
      url: `/organization/page`,
      method: `get`,
      params
    })
  },

  /**
   * 根据ID查询组织
   */
  getById(id) {
    return request({
      url: `/organization/${id}`,
      method: `get`
    })
  },

  /**
   * 创建组织
   */
  create(data) {
    return request({
      url: `/organization`,
      method: `post`,
      data
    })
  },

  /**
   * 更新组织
   */
  update(id, data) {
    return request({
      url: `/organization/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除组织
   */
  deleteById(id) {
    return request({
      url: `/organization/${id}`,
      method: `delete`
    })
  },

  /**
   * 获取子组织列表
   */
  getChildren(id) {
    return request({
      url: `/organization/${id}/children`,
      method: `get`
    })
  },

  /**
   * 移动组织
   */
  move(id, newParentId) {
    return request({
      url: `/organization/${id}/move`,
      method: `put`,
      params: { newParentId }
    })
  }
}

