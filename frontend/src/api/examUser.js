import request from '@/utils/request'

/**
 * 考生管理API
 */

// 获取考试的考生列表
export function getExamStudents(examId) {
  return request({
    url: `/api/exam/${examId}/students`,
    method: 'get'
  })
}

// 添加考生到考试
export function addStudentsToExam(examId, userIds) {
  return request({
    url: `/api/exam/${examId}/students`,
    method: 'post',
    data: { userIds }
  })
}

// 移除考生
export function removeStudent(examId, userId) {
  return request({
    url: `/api/exam/${examId}/students/${userId}`,
    method: 'delete'
  })
}

// 检查考试权限
export function checkExamPermission(examId, userId) {
  return request({
    url: `/api/exam/${examId}/students/check-permission`,
    method: 'get',
    params: { userId }
  })
}

export default {
  getExamStudents,
  addStudentsToExam,
  removeStudent,
  checkExamPermission
}

