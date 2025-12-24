/**
 * 考试管理 API
 */
import request from '@/utils/request'

export default {
  /**
   * 分页查询考试列表
   */
  page(params) {
    return request({
      url: `/exam/page`,
      method: `get`,
      params
    })
  },

  /**
   * 获取考试详情
   */
  getById(id) {
    return request({
      url: `/exam/${id}`,
      method: `get`
    })
  },

  /**
   * 创建考试
   */
  create(data) {
    return request({
      url: `/exam`,
      method: `post`,
      data
    })
  },

  /**
   * 更新考试
   */
  update(id, data) {
    return request({
      url: `/exam/${id}`,
      method: `put`,
      data
    })
  },

  /**
   * 删除考试
   */
  deleteById(id) {
    return request({
      url: `/exam/${id}`,
      method: `delete`
    })
  },

  /**
   * 发布考试
   */
  publish(id) {
    return request({
      url: `/exam/${id}/publish`,
      method: `post`
    })
  },

  /**
   * 开始考试
   */
  start(id) {
    return request({
      url: `/exam/${id}/start`,
      method: `post`
    })
  },

  /**
   * 结束考试
   */
  end(id) {
    return request({
      url: `/exam/${id}/end`,
      method: `post`
    })
  },

  /**
   * 取消考试
   */
  cancel(id) {
    return request({
      url: `/exam/${id}/cancel`,
      method: `post`
    })
  },

  /**
   * 复制考试
   */
  copy(id, newTitle) {
    return request({
      url: `/exam/${id}/copy`,
      method: `post`,
      params: { newTitle }
    })
  },

  /**
   * 获取考试监控数据
   */
  getMonitor(id) {
    return request({
      url: `/exam/${id}/monitor`,
      method: `get`
    })
  },

  /**
   * 获取考试统计数据
   */
  getStatistics(id) {
    return request({
      url: `/exam/${id}/statistics`,
      method: `get`
    })
  },

  /**
   * 获取考生的考试列表
   */
  getUserExams(userId, orgId) {
    return request({
      url: `/exam/user/${userId}`,
      method: `get`,
      params: { orgId }
    })
  },

  /**
   * 获取学生的考试列表（当前登录学生）
   */
  getMyExams(params) {
    return request({
      url: `/exam/my-exams`,
      method: `get`,
      params
    })
  },

  /**
   * 学生进入考试（创建考试会话）
   */
  enterExam(examId) {
    return request({
      url: `/exam/${examId}/enter`,
      method: `post`
    })
  },

  /**
   * 获取考试会话详情（含试卷和题目）
   */
  getSession(sessionId) {
    return request({
      url: `/exam/session/${sessionId}`,
      method: `get`
    })
  },

  /**
   * 保存答题（单题提交）
   */
  saveAnswer(sessionId, data) {
    return request({
      url: `/exam/session/${sessionId}/answer`,
      method: `post`,
      data
    })
  },

  /**
   * 提交试卷
   */
  submitPaper(sessionId) {
    return request({
      url: `/exam/session/${sessionId}/submit`,
      method: `post`
    })
  },

  /**
   * 获取考试结果
   */
  getResult(sessionId) {
    return request({
      url: `/exam/session/${sessionId}/result`,
      method: `get`
    })
  },

  /**
   * 心跳（保持在线状态）
   */
  heartbeat(sessionId) {
    return request({
      url: `/exam/session/${sessionId}/heartbeat`,
      method: `post`
    })
  }
}

