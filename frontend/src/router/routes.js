/**
 * 路由配置
 * @description 定义所有路由规则，懒加载组件
 */

export default [
  // ==================== 无需认证的路由 ====================
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Auth/Login.vue'),
    meta: {
      title: '登录',
      requiresAuth: false
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Auth/Register.vue'),
    meta: {
      title: '注册',
      requiresAuth: false
    }
  },

  // ==================== 需要认证的路由 ====================
  {
    path: '/',
    component: () => import('@/layouts/DefaultLayout.vue'),
    redirect: '/home',
    meta: {
      requiresAuth: true
    },
    children: [
      // 首页/仪表盘
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/views/Dashboard/Index.vue'),
        meta: {
          title: '首页',
          icon: 'HomeFilled'
        }
      },

      // ==================== 题库管理 ====================
      {
        path: 'admin/question-bank',
        name: 'QuestionBankManage',
        component: () => import('@/views/admin/QuestionBank/Index.vue'),
        meta: {
          title: '题库管理',
          icon: 'Files'
        }
      },
      {
        path: 'admin/question-bank/:id',
        name: 'QuestionBankDetail',
        component: () => import('@/views/admin/QuestionBank/Detail.vue'),
        meta: {
          title: '题库详情',
          hidden: true
        }
      },

      // ==================== 题目管理 ====================
      {
        path: 'admin/question',
        name: 'QuestionManage',
        component: () => import('@/views/admin/Question/Index.vue'),
        meta: {
          title: '题目管理',
          icon: 'Edit'
        }
      },
      {
        path: 'admin/question/:id',
        name: 'QuestionDetail',
        component: () => import('@/views/admin/Question/Detail.vue'),
        meta: {
          title: '题目详情',
          hidden: true
        }
      },

      // ==================== 试卷管理 ====================
      {
        path: 'admin/paper',
        name: 'PaperManage',
        component: () => import('@/views/admin/Paper/Index.vue'),
        meta: {
          title: '试卷管理',
          icon: 'Document'
        }
      },
      {
        path: 'admin/paper/:id',
        name: 'PaperDetail',
        component: () => import('@/views/admin/Paper/Detail.vue'),
        meta: {
          title: '试卷详情',
          hidden: true
        }
      },

      {
        path: 'question-bank',
        meta: {
          title: '题库管理',
          icon: 'Collection'
        },
        children: [
          {
            path: 'list',
            name: 'QuestionBankList',
            component: () => import('@/views/QuestionBank/BankList.vue'),
            meta: {
              title: '题库列表',
              permission: 'question_bank:view'
            }
          },
          {
            path: 'detail/:id',
            name: 'QuestionBankDetail',
            component: () => import('@/views/QuestionBank/BankDetail.vue'),
            meta: {
              title: '题库详情',
              permission: 'question_bank:view',
              hidden: true
            }
          }
        ]
      },

      // ==================== 题目管理 ====================
      {
        path: 'question',
        name: 'Question',
        meta: {
          title: '题目管理',
          icon: 'EditPen'
        },
        children: [
          {
            path: 'list',
            name: 'QuestionList',
            component: () => import('@/views/Question/QuestionList.vue'),
            meta: {
              title: '题目列表',
              permission: 'question:view'
            }
          },
          {
            path: 'edit/:id?',
            name: 'QuestionEdit',
            component: () => import('@/views/Question/QuestionEdit.vue'),
            meta: {
              title: '编辑题目',
              permission: 'question:edit',
              hidden: true
            }
          },
          {
            path: 'audit',
            name: 'QuestionAudit',
            component: () => import('@/views/Question/QuestionAudit.vue'),
            meta: {
              title: '题目审核',
              permission: 'question:audit'
            }
          }
        ]
      },

      // ==================== 知识点管理 ====================
      {
        path: 'knowledge-point',
        name: 'KnowledgePoint',
        component: () => import('@/views/KnowledgePoint/KnowledgeTree.vue'),
        meta: {
          title: '知识点管理',
          icon: 'Share',
          permission: 'knowledge_point:view'
        }
      },

      // ==================== 试卷管理 ====================
      {
        path: 'paper',
        name: 'Paper',
        meta: {
          title: '试卷管理',
          icon: 'Document'
        },
        children: [
          {
            path: 'list',
            name: 'PaperList',
            component: () => import('@/views/Paper/PaperList.vue'),
            meta: {
              title: '试卷列表',
              permission: 'paper:view'
            }
          },
          {
            path: 'edit/:id?',
            name: 'PaperEdit',
            component: () => import('@/views/Paper/PaperEdit.vue'),
            meta: {
              title: '编辑试卷',
              permission: 'paper:edit',
              hidden: true
            }
          },
          {
            path: 'preview/:id',
            name: 'PaperPreview',
            component: () => import('@/views/Paper/PaperPreview.vue'),
            meta: {
              title: '预览试卷',
              permission: 'paper:view',
              hidden: true
            }
          },
          {
            path: 'auto-generate',
            name: 'AutoGenerate',
            component: () => import('@/views/Paper/AutoGenerate.vue'),
            meta: {
              title: '自动组卷',
              permission: 'paper:create'
            }
          }
        ]
      },

      // ==================== 考试管理 ====================
      {
        path: 'exam',
        name: 'Exam',
        meta: {
          title: '考试管理',
          icon: 'Files'
        },
        children: [
          {
            path: 'list',
            name: 'ExamList',
            component: () => import('@/views/Exam/ExamList.vue'),
            meta: {
              title: '考试列表',
              permission: 'exam:view'
            }
          },
          {
            path: 'edit/:id?',
            name: 'ExamEdit',
            component: () => import('@/views/Exam/ExamEdit.vue'),
            meta: {
              title: '编辑考试',
              permission: 'exam:edit',
              hidden: true
            }
          },
          {
            path: 'monitor/:id',
            name: 'ExamMonitor',
            component: () => import('@/views/Exam/ExamMonitor.vue'),
            meta: {
              title: '考试监控',
              permission: 'exam:monitor',
              hidden: true
            }
          },
          {
            path: 'detail/:id',
            name: 'ExamDetail',
            component: () => import('@/views/Exam/ExamDetail.vue'),
            meta: {
              title: '考试详情',
              permission: 'exam:view',
              hidden: true
            }
          }
        ]
      },

      // ==================== 考试会话（学生考试） ====================
      {
        path: 'exam-session',
        name: 'ExamSession',
        meta: {
          title: '我的考试',
          icon: 'Tickets',
          role: ['STUDENT']
        },
        children: [
          {
            path: 'list',
            name: 'MyExamList',
            component: () => import('@/views/ExamSession/MyExamList.vue'),
            meta: {
              title: '考试列表'
            }
          },
          {
            path: 'start/:examId',
            name: 'ExamStart',
            component: () => import('@/views/ExamSession/ExamStart.vue'),
            meta: {
              title: '开始考试',
              hidden: true
            }
          },
          {
            path: 'paper/:sessionId',
            name: 'ExamPaper',
            component: () => import('@/views/ExamSession/ExamPaper.vue'),
            meta: {
              title: '答题',
              hidden: true
            }
          },
          {
            path: 'result/:sessionId',
            name: 'ExamResult',
            component: () => import('@/views/ExamSession/ExamResult.vue'),
            meta: {
              title: '考试结果',
              hidden: true
            }
          }
        ]
      },

      // ==================== 阅卷管理 ====================
      {
        path: 'grading',
        name: 'Grading',
        meta: {
          title: '阅卷管理',
          icon: 'Checked',
          role: ['ADMIN', 'TEACHER']
        },
        children: [
          {
            path: 'list',
            name: 'GradingList',
            component: () => import('@/views/Grading/GradingList.vue'),
            meta: {
              title: '待阅卷列表',
              permission: 'grading:view'
            }
          },
          {
            path: 'task',
            name: 'GradingTask',
            component: () => import('@/views/Grading/GradingTask.vue'),
            meta: {
              title: '我的阅卷任务',
              permission: 'grading:grade'
            }
          },
          {
            path: 'review',
            name: 'ReviewManage',
            component: () => import('@/views/Grading/ReviewManage.vue'),
            meta: {
              title: '复核管理',
              permission: 'grading:review'
            }
          }
        ]
      },

      // ==================== 统计分析 ====================
      {
        path: 'statistics',
        name: 'Statistics',
        meta: {
          title: '统计分析',
          icon: 'DataAnalysis'
        },
        children: [
          {
            path: 'dashboard',
            name: 'Dashboard',
            component: () => import('@/views/Statistics/Dashboard.vue'),
            meta: {
              title: '数据看板',
              permission: 'statistics:view'
            }
          },
          {
            path: 'exam-stats',
            name: 'ExamStats',
            component: () => import('@/views/Statistics/ExamStats.vue'),
            meta: {
              title: '考试统计',
              permission: 'statistics:view'
            }
          },
          {
            path: 'student-stats',
            name: 'StudentStats',
            component: () => import('@/views/Statistics/StudentStats.vue'),
            meta: {
              title: '学生统计',
              permission: 'statistics:view'
            }
          }
        ]
      },

      // ==================== 用户管理 ====================
      {
        path: 'user',
        name: 'User',
        meta: {
          title: '用户管理',
          icon: 'User',
          role: ['ADMIN']
        },
        children: [
          {
            path: 'list',
            name: 'UserList',
            component: () => import('@/views/User/UserList.vue'),
            meta: {
              title: '用户列表',
              permission: 'user:view'
            }
          },
          {
            path: 'profile',
            name: 'UserProfile',
            component: () => import('@/views/User/UserProfile.vue'),
            meta: {
              title: '个人资料',
              hidden: true
            }
          }
        ]
      },

      // ==================== 组织管理 ====================
      {
        path: 'system/organization',
        name: 'Organization',
        component: () => import('@/views/system/Organization.vue'),
        meta: {
          title: '组织管理',
          icon: 'OfficeBuilding',
          permission: 'organization:view',
          role: ['ADMIN']
        }
      },

      // ==================== 角色管理 ====================
      {
        path: 'system/role',
        name: 'Role',
        component: () => import('@/views/system/Role.vue'),
        meta: {
          title: '角色管理',
          icon: 'UserFilled',
          permission: 'role:view',
          role: ['ADMIN']
        }
      },

      // ==================== 知识点管理 ====================
      {
        path: 'system/knowledge',
        name: 'Knowledge',
        component: () => import('@/views/system/Knowledge.vue'),
        meta: {
          title: '知识点管理',
          icon: 'Collection',
          permission: 'knowledge:view',
          role: ['ADMIN', 'TEACHER']
        }
      },

      // ==================== 权限管理 ====================
      {
        path: 'system/permission',
        name: 'Permission',
        component: () => import('@/views/system/Permission.vue'),
        meta: {
          title: '权限管理',
          icon: 'Lock',
          permission: 'permission:view',
          role: ['ADMIN']
        }
      }
    ]
  },

  // ==================== 错误页面 ====================
  {
    path: '/403',
    name: 'Forbidden',
    component: () => import('@/views/Error/403.vue'),
    meta: {
      title: '403 - 无权限',
      requiresAuth: false
    }
  },
  {
    path: '/404',
    name: 'NotFound',
    component: () => import('@/views/Error/404.vue'),
    meta: {
      title: '404 - 页面不存在',
      requiresAuth: false
    }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/404'
  }
]

