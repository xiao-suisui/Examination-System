/**
 * 用户管理 API
 * @description 对应后端 UserController (/api/user/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 用户注册
   * @param {Object} data 用户信息
   * @returns {Promise}
   */
  register(data) {
    return request({
      url: '/api/user/register',
      method: 'post',
      data
    })
  },

  /**
   * 根据ID查询用户
   * @param {number} id 用户ID
   * @returns {Promise}
   */
  getUserById(id) {
    return request({
      url: `/api/user/${id}`,
      method: 'get'
    })
  },

  /**
   * 根据用户名查询用户
   * @param {string} username 用户名
   * @returns {Promise}
   */
  getUserByUsername(username) {
    return request({
      url: `/api/user/username/${username}`,
      method: 'get'
    })
  },

  /**
   * 更新用户信息
   * @param {number} id 用户ID
   * @param {Object} data 用户信息
   * @returns {Promise}
   */
  updateUser(id, data) {
    return request({
      url: `/api/user/${id}`,
      method: 'put',
      data
    })
  },

  /**
   * 删除用户
   * @param {number} id 用户ID
   * @returns {Promise}
   */
  deleteUser(id) {
    return request({
      url: `/api/user/${id}`,
      method: 'delete'
    })
  },

  /**
   * 获取用户资料
   * @returns {Promise}
   */
  getProfile() {
    return request({
      url: '/api/user/profile',
      method: 'get'
    })
  },

  /**
   * 更新用户资料
   * @param {Object} data 用户资料
   * @returns {Promise}
   */
  updateProfile(data) {
    return request({
      url: '/api/user/profile',
      method: 'put',
      data
    })
  },

  /**
   * 修改密码
   * @param {Object} data {oldPassword, newPassword}
   * @returns {Promise}
   */
  changePassword(data) {
    return request({
      url: '/api/user/change-password',
      method: 'post',
      data
    })
  }
}

