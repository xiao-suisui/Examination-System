/**
 * 通用表单验证规则
 *
 * @example
 * import { required, phone, email, username, password } from '@/utils/validate'
 *
 * const rules = {
 *   username: [required('请输入用户名'), username()],
 *   password: [required('请输入密码'), password()],
 *   phone: [phone()],
 *   email: [email()]
 * }
 */

/**
 * 必填验证
 */
export const required = (message = '此项为必填项', trigger = 'blur') => ({
  required: true,
  message,
  trigger
})

/**
 * 手机号验证
 */
export const phone = (required = false) => {
  const rule = {
    pattern: /^1[3-9]\d{9}$/,
    message: '请输入正确的手机号',
    trigger: 'blur'
  }
  return required ? [{ required: true, message: '请输入手机号', trigger: 'blur' }, rule] : rule
}

/**
 * 邮箱验证
 */
export const email = (required = false) => {
  const rule = {
    type: 'email',
    message: '请输入正确的邮箱地址',
    trigger: 'blur'
  }
  return required ? [{ required: true, message: '请输入邮箱', trigger: 'blur' }, rule] : rule
}

/**
 * 用户名验证（4-20位字母数字下划线）
 */
export const username = () => ({
  pattern: /^[a-zA-Z0-9_]{4,20}$/,
  message: '用户名为4-20位字母、数字或下划线',
  trigger: 'blur'
})

/**
 * 密码验证（6-20位）
 */
export const password = () => ({
  pattern: /^.{6,20}$/,
  message: '密码长度为6-20位',
  trigger: 'blur'
})

/**
 * 强密码验证（至少包含大小写字母、数字和特殊字符中的三种）
 */
export const strongPassword = () => ({
  validator: (rule, value, callback) => {
    if (!value) {
      callback()
      return
    }

    const patterns = [
      /[a-z]/,  // 小写字母
      /[A-Z]/,  // 大写字母
      /\d/,     // 数字
      /[!@#$%^&*(),.?":{}|<>]/  // 特殊字符
    ]

    const matches = patterns.filter(pattern => pattern.test(value)).length

    if (value.length < 8) {
      callback(new Error('密码长度不能少于8位'))
    } else if (matches < 3) {
      callback(new Error('密码必须包含大小写字母、数字和特殊字符中的至少三种'))
    } else {
      callback()
    }
  },
  trigger: 'blur'
})

/**
 * 长度验证
 */
export const length = (min, max, message) => ({
  min,
  max,
  message: message || `长度在 ${min} 到 ${max} 个字符`,
  trigger: 'blur'
})

/**
 * 最小长度验证
 */
export const minLength = (min, message) => ({
  min,
  message: message || `长度不能少于 ${min} 个字符`,
  trigger: 'blur'
})

/**
 * 最大长度验证
 */
export const maxLength = (max, message) => ({
  max,
  message: message || `长度不能超过 ${max} 个字符`,
  trigger: 'blur'
})

/**
 * 数字范围验证
 */
export const range = (min, max, message) => ({
  type: 'number',
  min,
  max,
  message: message || `请输入 ${min} 到 ${max} 之间的数字`,
  trigger: 'blur'
})

/**
 * 最小值验证
 */
export const min = (minValue, message) => ({
  type: 'number',
  min: minValue,
  message: message || `数值不能小于 ${minValue}`,
  trigger: 'blur'
})

/**
 * 最大值验证
 */
export const max = (maxValue, message) => ({
  type: 'number',
  max: maxValue,
  message: message || `数值不能大于 ${maxValue}`,
  trigger: 'blur'
})

/**
 * URL验证
 */
export const url = () => ({
  type: 'url',
  message: '请输入正确的URL地址',
  trigger: 'blur'
})

/**
 * IP地址验证
 */
export const ip = () => ({
  pattern: /^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$/,
  message: '请输入正确的IP地址',
  trigger: 'blur'
})

/**
 * 身份证号验证
 */
export const idCard = () => ({
  pattern: /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/,
  message: '请输入正确的身份证号',
  trigger: 'blur'
})

/**
 * 中文验证
 */
export const chinese = () => ({
  pattern: /^[\u4e00-\u9fa5]+$/,
  message: '请输入中文',
  trigger: 'blur'
})

/**
 * 英文验证
 */
export const english = () => ({
  pattern: /^[a-zA-Z]+$/,
  message: '请输入英文',
  trigger: 'blur'
})

/**
 * 数字验证
 */
export const number = () => ({
  pattern: /^\d+$/,
  message: '请输入数字',
  trigger: 'blur'
})

/**
 * 正整数验证
 */
export const positiveInteger = () => ({
  pattern: /^[1-9]\d*$/,
  message: '请输入正整数',
  trigger: 'blur'
})

/**
 * 正数验证（包含小数）
 */
export const positiveNumber = () => ({
  pattern: /^(([1-9]\d*)|\d)(\.\d+)?$/,
  message: '请输入正数',
  trigger: 'blur'
})

/**
 * 自定义正则验证
 */
export const pattern = (regex, message) => ({
  pattern: regex,
  message,
  trigger: 'blur'
})

/**
 * 自定义验证器
 */
export const validator = (validateFn, trigger = 'blur') => ({
  validator: validateFn,
  trigger
})

/**
 * 验证两次输入是否一致（如确认密码）
 */
export const sameAs = (fieldName, getFieldValue, message) => ({
  validator: (rule, value, callback) => {
    if (!value) {
      callback()
      return
    }

    const targetValue = getFieldValue()
    if (value !== targetValue) {
      callback(new Error(message || `两次输入的${fieldName}不一致`))
    } else {
      callback()
    }
  },
  trigger: 'blur'
})

// ==================== 预定义表单验证规则 ====================

/**
 * 登录表单验证规则
 */
export const loginRules = {
  username: [
    required('请输入用户名'),
    { min: 4, max: 20, message: '用户名长度为4-20位', trigger: 'blur' }
  ],
  password: [
    required('请输入密码'),
    { min: 6, max: 20, message: '密码长度为6-20位', trigger: 'blur' }
  ]
}

/**
 * 注册表单验证规则
 */
export const registerRules = {
  username: [
    required('请输入用户名'),
    username()
  ],
  password: [
    required('请输入密码'),
    password()
  ],
  confirmPassword: [
    required('请再次输入密码')
  ],
  realName: [
    required('请输入真实姓名'),
    { min: 2, max: 20, message: '姓名长度为2-20位', trigger: 'blur' }
  ],
  phone: [
    required('请输入手机号'),
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

/**
 * 修改密码表单验证规则
 */
export const changePasswordRules = {
  oldPassword: [
    required('请输入原密码'),
    password()
  ],
  newPassword: [
    required('请输入新密码'),
    password()
  ],
  confirmPassword: [
    required('请再次输入新密码')
  ]
}
