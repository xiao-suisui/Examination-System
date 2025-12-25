/**
 * 系统枚举常量定义
 * 与后端枚举类保持一致，统一使用数字类型
 *
 * @version 2.0
 * @since 2025-11-07
 */

// ==================== 题型相关 ====================

/**
 * 题型编码
 */
export const QUESTION_TYPE = {
  SINGLE_CHOICE: 1,       // 单选题
  MULTIPLE_CHOICE: 2,     // 多选题
  INDEFINITE_CHOICE: 3,   // 不定项选择题
  TRUE_FALSE: 4,          // 判断题
  MATCHING: 5,            // 匹配题
  SORT: 6,                // 排序题
  FILL_BLANK: 7,          // 填空题
  SUBJECTIVE: 8           // 主观题
}

/**
 * 题型名称映射
 */
export const QUESTION_TYPE_LABELS = {
  1: '单选题',
  2: '多选题',
  3: '不定项选择题',
  4: '判断题',
  5: '匹配题',
  6: '排序题',
  7: '填空题',
  8: '主观题'
}

/**
 * 题型颜色映射（用于 el-tag）
 */
export const QUESTION_TYPE_COLORS = {
  1: 'primary',
  2: 'success',
  3: 'warning',
  4: 'info',
  5: 'danger',
  6: 'warning',
  7: 'info',
  8: 'danger'
}

// ==================== 难度相关 ====================

/**
 * 难度等级编码
 */
export const DIFFICULTY_LEVEL = {
  EASY: 1,      // 简单
  MEDIUM: 2,    // 中等
  HARD: 3       // 困难
}

/**
 * 难度名称映射
 */
export const DIFFICULTY_LABELS = {
  1: '简单',
  2: '中等',
  3: '困难'
}

/**
 * 难度颜色映射（用于 el-tag）
 */
export const DIFFICULTY_COLORS = {
  1: 'success',
  2: 'warning',
  3: 'danger'
}

// ==================== 审核状态相关 ====================

/**
 * 审核状态编码
 */
export const AUDIT_STATUS = {
  DRAFT: 0,      // 草稿
  PENDING: 1,    // 待审核
  APPROVED: 2,   // 已通过
  REJECTED: 3    // 已拒绝
}

/**
 * 审核状态名称映射
 */
export const AUDIT_STATUS_LABELS = {
  0: '草稿',
  1: '待审核',
  2: '已通过',
  3: '已拒绝'
}

/**
 * 审核状态颜色映射（用于 el-tag）
 */
export const AUDIT_STATUS_COLORS = {
  0: 'info',
  1: 'warning',
  2: 'success',
  3: 'danger'
}

// ==================== 考试状态相关 ====================

/**
 * 考试状态编码
 */
export const EXAM_STATUS = {
  DRAFT: 0,          // 草稿
  PUBLISHED: 1,      // 已发布
  IN_PROGRESS: 2,    // 进行中
  ENDED: 3,          // 已结束
  CANCELLED: 4       // 已取消
}

/**
 * 考试状态名称映射
 */
export const EXAM_STATUS_LABELS = {
  0: '草稿',
  1: '已发布',
  2: '进行中',
  3: '已结束',
  4: '已取消'
}

/**
 * 考试状态颜色映射（用于 el-tag）
 */
export const EXAM_STATUS_COLORS = {
  0: 'info',
  1: 'primary',
  2: 'success',
  3: 'warning',
  4: 'danger'
}

// ==================== 考试会话状态相关 ====================

/**
 * 考试会话状态编码
 */
export const SESSION_STATUS = {
  NOT_STARTED: 0,    // 未开始
  IN_PROGRESS: 1,    // 进行中
  SUBMITTED: 2,      // 已交卷
  GRADED: 3,         // 已批改
  CANCELLED: 4       // 已取消
}

/**
 * 考试会话状态名称映射
 */
export const SESSION_STATUS_LABELS = {
  0: '未开始',
  1: '进行中',
  2: '已交卷',
  3: '已批改',
  4: '已取消'
}

/**
 * 考试会话状态颜色映射（用于 el-tag）
 */
export const SESSION_STATUS_COLORS = {
  0: 'info',
  1: 'warning',
  2: 'success',
  3: 'primary',
  4: 'danger'
}

// ==================== 试卷相关 ====================

/**
 * 组卷方式编码（对应数据库 paper_type 字段）
 */
export const PAPER_TYPE = {
  MANUAL: 1,      // 手动组卷
  AUTO: 2,        // 自动组卷
  RANDOM: 3       // 随机组卷
}

/**
 * 组卷方式名称映射
 */
export const PAPER_TYPE_LABELS = {
  1: '手动组卷',
  2: '自动组卷',
  3: '随机组卷'
}

/**
 * 组卷方式颜色映射（用于 el-tag）
 */
export const PAPER_TYPE_COLORS = {
  1: 'primary',
  2: 'success',
  3: 'warning'
}

/**
 * 试卷状态编码
 */
export const PAPER_STATUS = {
  DRAFT: 0,       // 草稿
  PUBLISHED: 1,   // 已发布
  ARCHIVED: 2     // 已归档
}

/**
 * 试卷状态名称映射
 */
export const PAPER_STATUS_LABELS = {
  0: '草稿',
  1: '已发布',
  2: '已归档'
}

/**
 * 试卷状态颜色映射（用于 el-tag）
 */
export const PAPER_STATUS_COLORS = {
  0: 'info',
  1: 'success',
  2: 'warning'
}

// ==================== 题库相关 ====================

/**
 * 题库类型编码（与后端保持一致，使用数字）
 */
export const BANK_TYPE = {
  PUBLIC: 1,    // 公共题库
  PRIVATE: 2    // 私有题库
}

/**
 * 题库类型名称映射
 */
export const BANK_TYPE_LABELS = {
  1: '公共题库',
  2: '私有题库'
}

/**
 * 题库类型颜色映射（用于 el-tag）
 */
export const BANK_TYPE_COLORS = {
  1: 'success',
  2: 'info'
}

// ==================== 用户相关 ====================

/**
 * 性别编码
 */
export const GENDER = {
  UNKNOWN: 0,   // 未知
  MALE: 1,      // 男
  FEMALE: 2     // 女
}

/**
 * 性别名称映射
 */
export const GENDER_LABELS = {
  0: '未知',
  1: '男',
  2: '女'
}

/**
 * 用户状态编码
 */
export const USER_STATUS = {
  DISABLED: 0,  // 禁用
  ENABLED: 1    // 启用
}

/**
 * 用户状态名称映射
 */
export const USER_STATUS_LABELS = {
  0: '禁用',
  1: '启用'
}

/**
 * 用户状态颜色映射（用于 el-tag）
 */
export const USER_STATUS_COLORS = {
  0: 'danger',
  1: 'success'
}

// ==================== 工具函数 ====================

/**
 * 获取题型名称
 */
export function getQuestionTypeName(code) {
  return QUESTION_TYPE_LABELS[code] || '未知'
}

/**
 * 获取题型颜色
 */
export function getQuestionTypeColor(code) {
  return QUESTION_TYPE_COLORS[code] || 'info'
}

/**
 * 获取难度名称
 */
export function getDifficultyName(level) {
  return DIFFICULTY_LABELS[level] || '未知'
}

/**
 * 获取难度颜色
 */
export function getDifficultyColor(level) {
  return DIFFICULTY_COLORS[level] || 'info'
}

/**
 * 获取审核状态名称
 */
export function getAuditStatusName(status) {
  return AUDIT_STATUS_LABELS[status] || '未知'
}

/**
 * 获取审核状态颜色
 */
export function getAuditStatusColor(status) {
  return AUDIT_STATUS_COLORS[status] || 'info'
}

/**
 * 获取考试状态名称
 */
export function getExamStatusName(status) {
  return EXAM_STATUS_LABELS[status] || '未知'
}

/**
 * 获取考试状态颜色
 */
export function getExamStatusColor(status) {
  return EXAM_STATUS_COLORS[status] || 'info'
}

/**
 * 获取考试会话状态名称
 */
export function getSessionStatusName(status) {
  return SESSION_STATUS_LABELS[status] || '未知'
}

/**
 * 获取考试会话状态颜色
 */
export function getSessionStatusColor(status) {
  return SESSION_STATUS_COLORS[status] || 'info'
}

/**
 * 获取组卷方式名称
 */
export function getPaperTypeName(type) {
  return PAPER_TYPE_LABELS[type] || '未知'
}

/**
 * 获取组卷方式颜色
 */
export function getPaperTypeColor(type) {
  return PAPER_TYPE_COLORS[type] || 'info'
}

/**
 * 获取题库类型名称
 */
export function getBankTypeName(type) {
  return BANK_TYPE_LABELS[type] || '未知'
}

/**
 * 获取题库类型颜色
 */
export function getBankTypeColor(type) {
  return BANK_TYPE_COLORS[type] || 'info'
}

/**
 * 获取性别名称
 */
export function getGenderName(gender) {
  return GENDER_LABELS[gender] || '未知'
}

/**
 * 获取用户状态名称
 */
export function getUserStatusName(status) {
  return USER_STATUS_LABELS[status] || '未知'
}

/**
 * 获取用户状态颜色
 */
export function getUserStatusColor(status) {
  return USER_STATUS_COLORS[status] || 'info'
}

/**
 * 获取试卷状态名称
 */
export function getPaperStatusName(code) {
  return PAPER_STATUS_LABELS[code] || '未知'
}

/**
 * 获取试卷状态颜色
 */
export function getPaperStatusColor(code) {
  return PAPER_STATUS_COLORS[code] || 'info'
}


// ==================== 组织管理相关枚举 ====================

/**
 * 组织类型编码
 */
export const ORG_TYPE = {
  SCHOOL: 1,      // 学校
  ENTERPRISE: 2,  // 企业
  TRAINING: 3     // 培训机构
}

/**
 * 组织类型名称映射
 */
export const ORG_TYPE_LABELS = {
  1: '学校',
  2: '企业',
  3: '培训机构'
}

/**
 * 组织类型颜色映射（用于 el-tag）
 */
export const ORG_TYPE_COLORS = {
  1: 'primary',
  2: 'success',
  3: 'warning'
}

/**
 * 组织层级编码
 */
export const ORG_LEVEL = {
  LEVEL_1: 1,  // 一级（学校/企业）
  LEVEL_2: 2,  // 二级（学院/部门）
  LEVEL_3: 3,  // 三级（系/小组）
  LEVEL_4: 4   // 四级（班级）
}

/**
 * 组织层级名称映射
 */
export const ORG_LEVEL_LABELS = {
  1: '一级',
  2: '二级',
  3: '三级',
  4: '四级'
}

/**
 * 组织层级描述映射
 */
export const ORG_LEVEL_DESCRIPTIONS = {
  1: '一级（学校/企业）',
  2: '二级（学院/部门）',
  3: '三级（系/小组）',
  4: '四级（班级）'
}

/**
 * 获取组织类型名称
 */
export function getOrgTypeName(code) {
  return ORG_TYPE_LABELS[code] || '未知'
}

/**
 * 获取组织类型颜色
 */
export function getOrgTypeColor(code) {
  return ORG_TYPE_COLORS[code] || 'info'
}

/**
 * 获取组织层级名称
 */
export function getOrgLevelName(code) {
  return ORG_LEVEL_LABELS[code] || '未知'
}

/**
 * 获取组织层级描述
 */
export function getOrgLevelDescription(code) {
  return ORG_LEVEL_DESCRIPTIONS[code] || '未知'
}


// ==================== 通用枚举工具函数 ====================

/**
 * 获取枚举名称（通用）
 * @param {number} value - 枚举值
 * @param {object} labelMap - 名称映射对象
 * @param {string} defaultLabel - 默认名称
 * @returns {string}
 */
export function getEnumLabel(value, labelMap, defaultLabel = '未知') {
  return labelMap[value] || defaultLabel
}

/**
 * 获取枚举颜色（通用）
 * @param {number} value - 枚举值
 * @param {object} typeMap - 颜色映射对象
 * @param {string} defaultType - 默认颜色
 * @returns {string}
 */
export function getEnumType(value, typeMap, defaultType = 'info') {
  return typeMap[value] || defaultType
}

/**
 * 将枚举映射对象转换为选项数组
 * @param {object} labelMap - 名称映射对象 { 1: '选项1', 2: '选项2' }
 * @returns {Array} [{value: 1, label: '选项1'}, {value: 2, label: '选项2'}]
 */
export function getEnumOptions(labelMap) {
  return Object.entries(labelMap).map(([value, label]) => ({
    value: Number(value),
    label
  }))
}

/**
 * 将枚举常量对象转换为选项数组
 * @param {object} enumObj - 枚举常量对象 { OPTION1: 1, OPTION2: 2 }
 * @param {object} labelMap - 名称映射对象 { 1: '选项1', 2: '选项2' }
 * @returns {Array} [{value: 1, label: '选项1', key: 'OPTION1'}, ...]
 */
export function enumToOptions(enumObj, labelMap) {
  return Object.entries(enumObj).map(([key, value]) => ({
    value,
    label: labelMap[value] || key,
    key
  }))
}

/**
 * 验证枚举值是否有效
 * @param {number} value - 待验证的值
 * @param {object} enumObj - 枚举常量对象
 * @returns {boolean}
 */
export function isValidEnumValue(value, enumObj) {
  return Object.values(enumObj).includes(value)
}

/**
 * 根据枚举名称获取枚举值
 * @param {string} name - 枚举名称（如 'SINGLE_CHOICE'）
 * @param {object} enumObj - 枚举常量对象
 * @returns {number|undefined}
 */
export function getEnumValue(name, enumObj) {
  return enumObj[name]
}

/**
 * 根据枚举值获取枚举名称
 * @param {number} value - 枚举值
 * @param {object} enumObj - 枚举常量对象
 * @returns {string|undefined}
 */
export function getEnumName(value, enumObj) {
  return Object.entries(enumObj).find(([, v]) => v === value)?.[0]
}

/**
 * 批量获取枚举名称
 * @param {Array<number>} values - 枚举值数组
 * @param {object} labelMap - 名称映射对象
 * @param {string} separator - 分隔符
 * @returns {string}
 */
export function getEnumLabels(values, labelMap, separator = '、') {
  if (!values || !Array.isArray(values)) {
    return ''
  }
  return values.map(v => labelMap[v] || '未知').join(separator)
}

/**
 * 创建枚举过滤器（用于表格列筛选）
 * @param {object} labelMap - 名称映射对象
 * @returns {Array} Element Plus table column filters 格式
 */
export function createEnumFilters(labelMap) {
  return Object.entries(labelMap).map(([value, label]) => ({
    text: label,
    value: Number(value)
  }))
}
