/**
 * API统一导出
 * @description 集中导出所有API模块，方便统一管理和使用
 */

import auth from './auth'
import user from './user'
import questionBank from './questionBank'
import question from './question'
import knowledgePoint from './knowledgePoint'
import paper from './paper'
import exam from './exam'
import examSession from './examSession'
import grading from './grading'
import statistics from './statistics'

export default {
  auth,
  user,
  questionBank,
  question,
  knowledgePoint,
  paper,
  exam,
  examSession,
  grading,
  statistics
}

// 也可以按需导出
export {
  auth,
  user,
  questionBank,
  question,
  knowledgePoint,
  paper,
  exam,
  examSession,
  grading,
  statistics
}

