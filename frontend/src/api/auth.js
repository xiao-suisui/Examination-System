/**
 * 认证授权 API
 * @description 对应后端 AuthController (/api/auth/**)
 */

import request from '@/utils/request'

export default {
  /**
   * 用户登录
   * @param {Object} data {username, password}
   * @returns {Promise}
   */
  login(data) {
    return request({
      url: '/api/auth/login',
      method: 'post',
      data: data  // 使用JSON格式，不是query参数
    })
  },

  /**
   * 用户登出
   * @returns {Promise}
   */
  logout() {
    return request({
      url: '/api/auth/logout',
      method: 'post'
    })
  },

  /**
   * 刷新Token
   * @param {Object} data {refreshToken}
   * @returns {Promise}
   */
  refresh(data) {
    return request({
      url: '/api/auth/refresh',
      method: 'post',
      params: data
    })
  },

  /**
   * 获取当前用户信息
   * @returns {Promise}
   */
  getCurrentUser() {
    return request({
      url: '/api/auth/current-user',
      method: 'get'
    })
  }
}

