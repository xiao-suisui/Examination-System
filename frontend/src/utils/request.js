/**
 * HTTP请求封装 - Axios实例配置
 */

import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getToken, removeToken } from './auth'
import router from '@/router'

const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json;charset=UTF-8'
  }
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const token = getToken()
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data

    if (res.code !== 200) {
      ElMessage.error(res.msg || res.message || '请求失败')

      if (res.code === 401) {
        ElMessageBox.confirm('登录已过期，请重新登录', '提示', {
          confirmButtonText: '重新登录',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          removeToken()
          router.push('/login')
        })
      }

      return Promise.reject(new Error(res.msg || res.message || '请求失败'))
    }

    return res
  },
  error => {
    console.error('响应错误:', error)

    let message = '网络错误，请稍后重试'

    if (error.response) {
      const status = error.response.status
      const data = error.response.data

      // 优先使用后端返回的错误信息
      if (data && (data.msg || data.message)) {
        message = data.msg || data.message
      } else {
        switch (status) {
          case 400:
            message = '请求参数错误'
            break
          case 401:
            message = '未授权，请登录'
            removeToken()
            router.push('/login')
            break
          case 403:
            message = '拒绝访问，权限不足'
            break
          case 404:
            message = '请求资源不存在'
            break
          case 500:
            message = '服务器内部错误'
            break
          case 503:
            message = '服务不可用'
            break
          default:
            message = `错误代码: ${status}`
        }
      }
    } else if (error.code === 'ECONNABORTED') {
      message = '请求超时，请检查网络'
    }

    ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default service

