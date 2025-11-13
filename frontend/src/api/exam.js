/**
 * 考试管理 API
 */
import request from '@/utils/request'

/**
 * 分页查询考试列表
 */
export function getExamPage(params) {
  return request({
    url: '/exam/page',
    method: 'get',
    params
  })
}

/**
 * 获取考试详情
 */
export function getExamDetail(id) {
  return request({
    url: `/exam/${id}`,
    method: 'get'
  })
}

/**
 * 创建考试
 */
export function createExam(data) {
  return request({
    url: '/exam',
    method: 'post',
    data
  })
}

/**
 * 更新考试
 */
export function updateExam(id, data) {
  return request({
    url: `/exam/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除考试
 */
export function deleteExam(id) {
  return request({
    url: `/exam/${id}`,
    method: 'delete'
  })
}

/**
 * 发布考试
 */
export function publishExam(id) {
  return request({
    url: `/exam/${id}/publish`,
    method: 'post'
  })
}

/**
 * 开始考试
 */
export function startExam(id) {
  return request({
    url: `/exam/${id}/start`,
    method: 'post'
  })
}

/**
 * 结束考试
 */
export function endExam(id) {
  return request({
    url: `/exam/${id}/end`,
    method: 'post'
  })
}

/**
 * 取消考试
 */
export function cancelExam(id) {
  return request({
    url: `/exam/${id}/cancel`,
    method: 'post'
  })
}

/**
 * 复制考试
 */
export function copyExam(id, newTitle) {
  return request({
    url: `/exam/${id}/copy`,
    method: 'post',
    params: { newTitle }
  })
}

/**
 * 获取考试监控数据
 */
export function getExamMonitor(id) {
  return request({
    url: `/exam/${id}/monitor`,
    method: 'get'
  })
}

/**
 * 获取考试统计数据
 */
export function getExamStatistics(id) {
  return request({
    url: `/exam/${id}/statistics`,
    method: 'get'
  })
}

/**
 * 获取考生的考试列表
 */
export function getUserExams(userId, orgId) {
  return request({
    url: `/exam/user/${userId}`,
    method: 'get',
    params: { orgId }
  })
}

