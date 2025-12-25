/**
 * 路由配置（重构后）
 * @description 按角色划分的路由结构
 * @version 2.0
 * @date 2025-11-25
 */

export default [
  // ==================== 公共路由（无需认证） ====================
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/shared/Auth/Login.vue'),
    meta: {
      title: '登录',
      requiresAuth: false
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/shared/Auth/Register.vue'),
    meta: {
      title: '注册',
      requiresAuth: false
    }
  },

  // ==================== 主布局路由 ====================
  {
    path: '/',
    component: () => import('@/layouts/DefaultLayout.vue'),
    redirect: '/home',
    meta: {
      requiresAuth: true
    },
    children: [
      // ========== 共享页面（所有角色） ==========
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/views/shared/Home/Index.vue'),
        meta: {
          title: '首页',
          icon: 'HomeFilled'
        }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/shared/User/Profile.vue'),
        meta: {
          title: '个人资料',
          icon: 'User',
          hidden: true
        }
      },

      // ========== 题库管理（教师+管理员共享） ==========
      {
        path: 'question-bank',
        name: 'QuestionBank',
        component: () => import('@/views/QuestionBank/Index.vue'),
        meta: {
          title: '题库管理',
          icon: 'Collection',
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'question-bank/:id',
        name: 'QuestionBankDetail',
        component: () => import('@/views/QuestionBank/Detail.vue'),
        meta: {
          title: '题库详情',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },

      // ========== 题目管理（教师+管理员共享） ==========
      {
        path: 'question',
        name: 'Question',
        component: () => import('@/views/Question/Index.vue'),
        meta: {
          title: '题目管理',
          icon: 'EditPen',
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'question/:id',
        name: 'QuestionDetail',
        component: () => import('@/views/Question/Detail.vue'),
        meta: {
          title: '题目详情',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },

      // ========== 试卷管理（教师+管理员共享） ==========
      {
        path: 'paper',
        name: 'Paper',
        component: () => import('@/views/Paper/Index.vue'),
        meta: {
          title: '试卷管理',
          icon: 'Document',
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'paper/:id',
        name: 'PaperDetail',
        component: () => import('@/views/Paper/Detail.vue'),
        meta: {
          title: '试卷详情',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'paper/preview/:id',
        name: 'PaperPreview',
        component: () => import('@/views/Paper/Preview.vue'),
        meta: {
          title: '预览试卷',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },

      // ========== 考试管理（教师+管理员共享） ==========
      {
        path: 'exam',
        name: 'Exam',
        component: () => import('@/views/Exam/Index.vue'),
        meta: {
          title: '考试管理',
          icon: 'Files',
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'exam/create',
        name: 'ExamCreate',
        component: () => import('@/views/Exam/Create.vue'),
        meta: {
          title: '创建考试',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'exam/edit/:id',
        name: 'ExamEdit',
        component: () => import('@/views/Exam/Create.vue'),
        meta: {
          title: '编辑考试',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'exam/monitor',
        name: 'ExamMonitor',
        component: () => import('@/views/Exam/Monitor.vue'),
        meta: {
          title: '考试监控',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },
      {
        path: 'exam/:id',
        name: 'ExamDetail',
        component: () => import('@/views/Exam/Detail.vue'),
        meta: {
          title: '考试详情',
          hidden: true,
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },

      // ========== 统计分析（教师+管理员共享） ==========
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/Statistics/Dashboard.vue'),
        meta: {
          title: '统计分析',
          icon: 'DataAnalysis',
          roles: ['TEACHER', 'ADMIN', 'ACADEMIC_ADMIN']
        }
      },

      // ========== 科目管理模块 ==========
      {
        path: 'subject',
        name: 'Subject',
        component: () => import('@/views/Subject/Index.vue'),
        meta: {
          title: '科目管理',
          icon: 'School',
          roles: ['ADMIN', 'ACADEMIC_ADMIN', 'TEACHER']
        }
      },
      {
        path: 'subject/:id',
        name: 'SubjectDetail',
        component: () => import('@/views/Subject/Detail.vue'),
        meta: {
          title: '科目详情',
          hidden: true,
          roles: ['ADMIN', 'ACADEMIC_ADMIN', 'TEACHER']
        }
      },

      // ========== 用户管理（仅管理员） ==========
      {
        path: 'user',
        name: 'User',
        component: () => import('@/views/User/Index.vue'),
        meta: {
          title: '用户管理',
          icon: 'User',
          roles: ['ADMIN']
        }
      },

      // ========== 组织管理（仅管理员） ==========
      {
        path: 'organization',
        name: 'Organization',
        component: () => import('@/views/Organization/Index.vue'),
        meta: {
          title: '组织管理',
          icon: 'OfficeBuilding',
          roles: ['ADMIN']
        }
      },


      // ========== 系统管理（超级管理员专属功能） ==========
      {
        path: 'admin',
        redirect: '/user',
        meta: { hidden: true }
      }
    ]
  },

  // ==================== 学生端布局路由（独立布局，无侧边栏） ====================
  {
    path: '/student',
    component: () => import('@/layouts/StudentLayout.vue'),
    redirect: '/student/exam',
    meta: {
      requiresAuth: true,
      roles: ['STUDENT']  // 只允许学生访问
    },
    children: [
      // 我的考试
      {
        path: 'exam',
        name: 'StudentExam',
        component: () => import('@/views/Student/exam/Index.vue'),
        meta: {
          title: '我的考试',
          icon: 'Tickets'
        }
      },
      {
        path: 'exam/start/:examId',
        name: 'StudentExamStart',
        component: () => import('@/views/Student/exam/Start.vue'),
        meta: {
          title: '开始考试',
          hidden: true
        }
      },
      {
        path: 'exam/paper/:sessionId',
        name: 'StudentExamPaper',
        component: () => import('@/views/Student/exam/Paper.vue'),
        meta: {
          title: '答题中',
          hidden: true
        }
      },
      {
        path: 'exam/result/:sessionId',
        name: 'StudentExamResult',
        component: () => import('@/views/Student/exam/Result.vue'),
        meta: {
          title: '考试结果',
          hidden: true
        }
      },

      // 成绩查询
      {
        path: 'score',
        name: 'StudentScore',
        component: () => import('@/views/Student/score/Index.vue'),
        meta: {
          title: '成绩查询',
          icon: 'Medal'
        }
      },

      // 错题集
      {
        path: 'wrong-questions',
        name: 'StudentWrongQuestions',
        component: () => import('@/views/Student/wrong-questions/Index.vue'),
        meta: {
          title: '错题集',
          icon: 'Warning'
        }
      }
    ]
  },


  // ==================== 错误页面 ====================
  {
    path: '/403',
    name: 'Forbidden',
    component: () => import('@/views/shared/Error/403.vue'),
    meta: {
      title: '无权访问',
      requiresAuth: false
    }
  },
  {
    path: '/404',
    name: 'NotFound',
    component: () => import('@/views/shared/Error/404.vue'),
    meta: {
      title: '页面不找到',
      requiresAuth: false
    }
  },
  // {
  //   path: '/500',
  //   name: 'ServerError',
  //   component: () => import('@/views/shared/Error/500.vue'),
  //   meta: {
  //     title: '服务器错误',
  //     requiresAuth: false
  //   }
  // },

  // 匹配所有未定义的路由，重定向到 404
  {
    path: '/:pathMatch(.*)*',
    redirect: '/404'
  }
]

