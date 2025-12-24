/**
 * 表单验证规则
 */

export const required = (message = '此项为必填项') => ({
  required: true,
  message,
  trigger: ['blur', 'change']
});

export const email = {
  type: 'email',
  message: '请输入正确的邮箱',
  trigger: 'blur'
};

export const phone = {
  pattern: /^1[3-9]\d{9}$/,
  message: '请输入正确的手机号',
  trigger: 'blur'
};

export const username = {
  pattern: /^[a-zA-Z0-9_]{4,20}$/,
  message: '用户名为4-20位字母数字下划线',
  trigger: 'blur'
};

export const password = {
  min: 6,
  max: 20,
  message: '密码长度6-20位',
  trigger: 'blur'
};

export const realName = {
  min: 2,
  max: 20,
  message: '真实姓名长度2-20位',
  trigger: 'blur'
};

export const loginRules = {
  username: [required('请输入用户名'), username],
  password: [required('请输入密码'), password]
};

export const registerRules = {
  username: [required('请输入用户名'), username],
  realName: [required('请输入真实姓名'), realName],
  password: [required('请输入密码'), password],
  email: [required('请输入邮箱'), email],
  phone: [required('请输入手机号'), phone]
};

