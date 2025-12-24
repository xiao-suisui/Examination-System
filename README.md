# 🎓 在线考试系统 v1.0-MVP

> 基于 Spring Boot 3 + Vue 3 的在线考试系统
> 
> **周一交付版本** - 核心功能完整，权限系统完善

---

## 📋 项目简介

这是一个功能完善的在线考试系统，支持题库管理、试卷组卷、在线考试、自动阅卷等核心功能。系统采用前后端分离架构，实现了完整的RBAC权限控制。

### ✨ 核心特性

- 🔐 **完善的权限系统** - 前后端双重权限验证
- 📚 **灵活的题库管理** - 支持单选、多选、判断等题型
- 📝 **智能组卷** - 手动组卷（MVP版本）
- 🎯 **在线考试** - 实时答题，自动保存
- ⚡ **自动阅卷** - 客观题即时评分
- 👥 **多角色支持** - 管理员、教师、学生
- 🏢 **组织架构** - 支持多级组织管理
- 📊 **科目管理** - 支持多科目教学

---

## 🚀 快速开始

### 一键启动（推荐）

```bash
# 双击运行启动脚本
start-all.bat
```

等待30秒，访问：http://localhost:3000

### 分步启动

#### 1. 启动后端
```bash
start-backend.bat
```

#### 2. 启动前端
```bash
start-frontend.bat
```

---

## 🔑 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | admin123 | 全部权限 |
| 教师 | teacher | teacher123 | 题库、试卷、考试管理 |
| 学生 | student | student123 | 参加考试、查看成绩 |

---

## 🛠️ 技术栈

### 后端
- **框架**: Spring Boot 3.2.3
- **安全**: Spring Security + JWT
- **数据库**: MySQL 8.0 + MyBatis-Plus 3.5.5
- **缓存**: Redis 6.0+
- **文档**: Knife4j (Swagger)

### 前端
- **框架**: Vue 3.3 + Vite 5.0
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **UI框架**: Element Plus
- **HTTP**: Axios

---

## 📦 环境要求

- JDK 17+
- Maven 3.8+
- Node.js 16+
- MySQL 8.0
- Redis 6.0+

---

## 🎯 核心功能

### ✅ 已实现功能

#### 1. 用户管理
- 用户注册/登录
- 角色权限管理
- 组织架构管理

#### 2. 题库管理
- 创建/编辑/删除题库
- 题目分类管理
- 题目导入/导出

#### 3. 题目管理
- 单选题、多选题、判断题
- 题目编辑器
- 难度分级

#### 4. 试卷管理
- 手动组卷
- 试卷预览
- 试卷复制

#### 5. 考试管理
- 创建/发布考试
- 考试时间控制
- 考试监控

#### 6. 学生考试
- 在线答题
- 自动保存
- 即时评分
- 成绩查询

#### 7. 权限系统
- 前端路由权限
- 按钮级别权限
- 后端接口权限
- 数据权限框架

### 🔜 未来规划

- 自动组卷（按规则生成）
- 随机组卷（抽题模式）
- 主观题批改
- 成绩分析统计
- 错题本功能
- 知识点分析
- 考试监控
- 移动端支持

---

## 📊 数据库

### 初始化

```sql
-- 1. 创建数据库
CREATE DATABASE exam_system DEFAULT CHARACTER SET utf8mb4;

-- 2. 导入数据
USE exam_system;
SOURCE database/newsql.sql;
```

### 数据表

- `sys_user` - 用户表
- `sys_role` - 角色表
- `sys_permission` - 权限表
- `sys_organization` - 组织表
- `subject` - 科目表
- `question_bank` - 题库表
- `question` - 题目表
- `question_option` - 选项表
- `paper` - 试卷表
- `paper_question` - 试卷题目关联表
- `exam` - 考试表
- `exam_session` - 考试会话表
- `exam_answer` - 答题记录表

---

## 🔐 权限系统

### 后端权限

使用 `@RequirePermission` 注解：

```java
@RequirePermission(value = "question_bank:create", desc = "创建题库")
@PostMapping
public Result<Void> create(@RequestBody QuestionBank bank) {
    // ...
}
```

### 前端权限

#### 路由权限
```javascript
{
  path: '/question-bank',
  meta: {
    permission: 'question_bank:view'
  }
}
```

#### 按钮权限
```vue
<el-button v-permission="'question:create'">创建题目</el-button>
```

---

## 📁 项目结构

```
Examination-System/
├── backend/                 # 后端代码
│   └── src/main/java/
│       └── com/example/exam/
│           ├── controller/  # 控制器
│           ├── service/     # 服务层
│           ├── mapper/      # 数据访问层
│           ├── entity/      # 实体类
│           ├── dto/         # 数据传输对象
│           ├── config/      # 配置类
│           └── common/      # 公共模块
├── frontend/                # 前端代码
│   └── src/
│       ├── views/          # 页面
│       ├── components/     # 组件
│       ├── stores/         # 状态管理
│       ├── router/         # 路由
│       ├── api/           # API接口
│       └── utils/         # 工具函数
├── database/              # 数据库脚本
├── docs/                  # 文档
├── start-all.bat         # 一键启动
├── start-backend.bat     # 后端启动
├── start-frontend.bat    # 前端启动
└── MVP_QUICK_START.md    # 快速指南
```

---

## 📝 配置说明

### 后端配置

`backend/src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/exam_system
    username: root
    password: 你的密码
  
  data:
    redis:
      host: localhost
      port: 6379
```

### 前端配置

`frontend/.env.development`

```env
VITE_API_BASE_URL=http://localhost:8080
```

---

## 🎬 演示视频

[待添加]

---

## 📖 详细文档

- [快速启动指南](MVP_QUICK_START.md)
- [交付清单](docs/MVP_DELIVERY_CHECKLIST.md)
- [Day 1 后端权限报告](docs/DAY1_COMPLETION_SUMMARY.md)
- [Day 2 前端权限报告](docs/DAY2_FRONTEND_PERMISSION_REPORT.md)

---

## 🐛 问题反馈

如遇到问题，请检查：

1. 数据库是否正常运行
2. Redis是否正常运行
3. 端口是否被占用（8080, 3000）
4. 配置文件是否正确

---

## 📄 开源协议

MIT License

---

## 👥 开发团队

- 后端开发：[Your Name]
- 前端开发：[Your Name]
- 数据库设计：[Your Name]
- 权限系统：AI Agent

---

## 🎉 特别鸣谢

感谢所有开源项目的贡献者！

---

**准备就绪，周一交付！** 🚀

最后更新：2025-12-20

