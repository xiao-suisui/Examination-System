import request from '@/utils/request'

/**
 * 科目管理API
 */
export default {
  /**
   * 分页查询科目
   */
  page(query) {
    return request({
      url: '/subject/page',
      method: 'get',
      params: query
    })
  },

  /**
   * 查询科目详情
   */
  getById(id) {
    return request({
      url: `/subject/${id}`,
      method: 'get'
    })
  },

  /**
   * 创建科目
   */
  create(data) {
    return request({
      url: '/subject',
      method: 'post',
      data
    })
  },

  /**
   * 更新科目
   */
  update(data) {
    return request({
      url: '/subject',
      method: 'put',
      data
    })
  },

  /**
   * 删除科目
   */
  deleteById(id) {
    return request({
      url: `/subject/${id}`,
      method: 'delete'
    })
  },

  /**
   * 添加科目管理员
   */
  addManager(subjectId, data) {
    return request({
      url: `/subject/${subjectId}/managers`,
      method: 'post',
      data
    })
  },

  /**
   * 移除科目管理员
   */
  removeManager(subjectId, userId) {
    return request({
      url: `/subject/${subjectId}/managers/${userId}`,
      method: 'delete'
    })
  },

  /**
   * 批量添加学生
   */
  enrollStudents(subjectId, data) {
    return request({
      url: `/subject/${subjectId}/students`,
      method: 'post',
      data
    })
  },

  /**
   * 移除学生
   */
  withdrawStudent(subjectId, studentId) {
    return request({
      url: `/subject/${subjectId}/students/${studentId}`,
      method: 'delete'
    })
  },

  /**
   * 获取我的科目列表
   */
  getMySubjects() {
    return request({
      url: '/subject/my-subjects',
      method: 'get'
    })
  },

  /**
   * 获取科目管理员列表
   */
  getManagers(subjectId) {
    return request({
      url: `/subject/${subjectId}/managers`,
      method: 'get'
    })
  },

  /**
   * 分页获取科目学生列表
   */
  getStudents(subjectId, params) {
    return request({
      url: `/subject/${subjectId}/students`,
      method: 'get',
      params
    })
  },

  /**
   * 获取可选教师列表
   */
  getAvailableTeachers(orgId) {
    return request({
      url: '/subject/available-teachers',
      method: 'get',
      params: { orgId }
    })
  },

  /**
   * 获取可选学生列表
   */
  getAvailableStudents(keyword) {
    return request({
      url: '/subject/available-students',
      method: 'get',
      params: { keyword }
    })
  }
}

