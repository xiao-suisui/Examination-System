/**
 * 用户管理API
 */
import request from '@/utils/request'

export default {
  /**
   * 分页查询用户
   */
  page(params) {
    return request({
      url: `/user/page`,
      method: `get`,
      params
    })
  },

  /**
   * 根据ID查询用户
   */
  getById(id) {
    return request({
      url: `/user/${id}`,
      method: `get`
    })
  },

  /**
   * 创建用户
   */
  create(data) {
    return request({
      url: `/user`,
      method: `post`,
      data
    })
  },

  /**
   * 更新用户
   */
  update(id, data) {
    return request({
      url: `/user/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除用户
   */
  deleteById(id) {
    return request({
      url: `/user/${id}`,
      method: `delete`
    })
  },

  /**
   * 用户注册
   */
  register(data) {
    return request({
      url: `/user/register`,
      method: `post`,
      data
    })
  },

  /**
   * 修改密码
   */
  changePassword(data) {
    return request({
      url: `/user/change-password`,
      method: `post`,
      data
    })
  },

  /**
   * 重置密码
   */
  resetPassword(userId) {
    return request({
      url: `/user/${userId}/reset-password`,
      method: `post`
    })
  },

  /**
   * 获取当前用户信息
   */
  getCurrentUser() {
    return request({
      url: `/auth/current-user`,
      method: `get`
    })
  },

  /**
   * 更新当前用户资料
   */
  updateProfile(data) {
    return request({
      url: `/user/profile`,
      method: `put`,
      data
    })
  },

  /**
   * 修改当前用户密码
   */
  updatePassword(data) {
    return request({
      url: `/user/update-password`,
      method: `post`,
      data
    })
  },

  /**
   * 上传头像
   */
  uploadAvatar(file) {
    const formData = new FormData()
    formData.append('file', file)
    return request({
      url: `/user/avatar`,
      method: `post`,
      data: formData,
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  }
}

