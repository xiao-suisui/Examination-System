/**
 * 路由验证脚本
 * 用于检查所有router.push调用是否使用了正确的路由
 */

// 定义所有有效的路由名称
const VALID_ROUTES = [
  // 认证相关
  'Login',
  'Register',

  // 主页
  'Home',

  // 题库管理
  'QuestionBankManage',
  'QuestionBankDetail',

  // 题目管理
  'QuestionManage',
  'QuestionDetail',

  // 试卷管理
  'PaperManage',
  'PaperDetail',
  'PaperPreview',
  'PaperEdit',
  'PaperList',
  'AutoGenerate',

  // 考试管理
  'Exam',
  'ExamList',
  'ExamEdit',
  'ExamMonitor',
  'ExamDetail',

  // 考试会话
  'ExamStart',
  'ExamResult',
  'MyExamList',

  // 用户管理
  'UserManage',
  'UserProfile',

  // 组织管理
  'OrganizationManage',

  // 知识点管理
  'KnowledgePoint',

  // 错误页面
  'NotFound'
]

// 路由跳转检查规则
const ROUTER_PUSH_PATTERNS = {
  // ✅ 推荐模式
  GOOD: [
    /router\.push\(\s*{\s*name:\s*['"][^'"]+['"]/g,  // name方式
  ],

  // ⚠️ 需要检查的模式
  WARNING: [
    /router\.push\(\s*['"]\/[^'"]+['"]\s*\)/g,  // 字符串路径
    /router\.push\(\s*`\/[^`]+`\s*\)/g,  // 模板字符串路径
  ],

  // ❌ 错误模式
  ERROR: [
    /router\.push\([^)]*edit[^)]*\)/gi,  // 包含edit的路由（可能是不存在的编辑路由）
  ]
}

// 检查函数
function checkRouterUsage(fileContent, filename) {
  const issues = []

  // 检查警告模式
  ROUTER_PUSH_PATTERNS.WARNING.forEach(pattern => {
    const matches = fileContent.match(pattern)
    if (matches) {
      matches.forEach(match => {
        issues.push({
          level: 'WARNING',
          file: filename,
          code: match,
          message: '建议使用name方式而不是路径字符串'
        })
      })
    }
  })

  // 检查错误模式
  ROUTER_PUSH_PATTERNS.ERROR.forEach(pattern => {
    const matches = fileContent.match(pattern)
    if (matches) {
      matches.forEach(match => {
        if (match.includes('/edit/') || match.includes('edit:')) {
          issues.push({
            level: 'ERROR',
            file: filename,
            code: match,
            message: '可能使用了不存在的编辑路由'
          })
        }
      })
    }
  })

  return issues
}

// 验证路由名称是否存在
function validateRouteName(name) {
  return VALID_ROUTES.includes(name)
}

// 输出验证报告
function generateReport(issues) {
  console.log('='.repeat(60))
  console.log('路由使用验证报告')
  console.log('='.repeat(60))
  console.log('')

  if (issues.length === 0) {
    console.log('✅ 所有路由跳转都符合规范！')
    return
  }

  // 按级别分组
  const errorIssues = issues.filter(i => i.level === 'ERROR')
  const warningIssues = issues.filter(i => i.level === 'WARNING')

  if (errorIssues.length > 0) {
    console.log('❌ 错误（必须修复）:')
    console.log('-'.repeat(60))
    errorIssues.forEach((issue, index) => {
      console.log(`${index + 1}. ${issue.file}`)
      console.log(`   代码: ${issue.code}`)
      console.log(`   问题: ${issue.message}`)
      console.log('')
    })
  }

  if (warningIssues.length > 0) {
    console.log('⚠️  警告（建议修复）:')
    console.log('-'.repeat(60))
    warningIssues.forEach((issue, index) => {
      console.log(`${index + 1}. ${issue.file}`)
      console.log(`   代码: ${issue.code}`)
      console.log(`   建议: ${issue.message}`)
      console.log('')
    })
  }

  console.log('='.repeat(60))
  console.log(`总计: ${errorIssues.length} 个错误, ${warningIssues.length} 个警告`)
  console.log('='.repeat(60))
}

// 导出验证函数
export {
  checkRouterUsage,
  validateRouteName,
  generateReport,
  VALID_ROUTES
}

