# 在线考试系统 - Online Examination System

[![Version](https://img.shields.io/badge/version-2.0.0--SNAPSHOT-blue)](https://github.com/your-repo/exam-system)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.3-brightgreen)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue-3.4.21-success)](https://vuejs.org/)
[![Progress](https://img.shields.io/badge/progress-50%25-yellow)](docs/learn/MIGRATION_PROGRESS_REPORT.md)

> 一个功能完整的在线考试系统，支持8种题型、随机组卷、自动判分、防作弊等核心功能。

---

## 🎯 项目简介

本项目是从**问卷调查系统**改造为**在线考试系统**的完整解决方案，实现了从试卷创建到成绩分析的全流程管理。

### 核心特性

- ✅ **8种题型支持**：单选、多选、不定项、判断、匹配、排序、填空、主观题
- ✅ **智能组卷**：支持固定组卷和随机组卷
- ✅ **自动判分**：客观题自动判分，主观题人工批改
- ✅ **防作弊**：切屏检测、单设备登录、主观题防抄袭
- ✅ **成绩分析**：多维度成绩统计、数据可视化
- ✅ **权限管理**：RBAC三层权限模型（角色-资源-操作）
- ✅ **API文档**：集成Knife4j，在线调试所有接口

---

## 🚀 快速开始

### 前置要求

- **JDK**: 17+
- **Node.js**: 18.19.0 LTS
- **MySQL**: 8.0.35+
- **Redis**: 7.0.15+（可选）
- **Maven**: 3.9.6+

### 安装步骤

#### 1. 导入项目到IDEA

1. 打开IDEA
2. File → Open
3. 选择项目目录：`D:\Desktop\Examination-System`
4. 等待IDEA加载项目和下载Maven依赖

#### 2. 数据库初始化

在MySQL中执行初始化脚本：

```sql
-- 方式1：在MySQL命令行中
source D:\Desktop\Examination-System\database\exam_system_complete.sql

-- 方式2：在MySQL Workbench中
-- 打开并执行 exam_system_complete.sql 文件
```

#### 3. 配置数据库连接

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    username: root
    password: 你的数据库密码  # 修改这里
```

#### 4. 启动后端（在IDEA中）

1. 找到主类：`com.example.exam.ExamSystemApplication`
2. 右键 → Run 'ExamSystemApplication'
3. 等待启动完成（控制台显示"Started ExamSystemApplication"）
4. 访问：http://localhost:8080

#### 5. 访问API文档（推荐）

打开浏览器访问在线API文档：

```
Knife4j文档: http://localhost:8080/doc.html
Swagger UI: http://localhost:8080/swagger-ui.html
```

在线测试所有API接口，无需Postman！

#### 6. 测试API（可选）

使用IDEA的HTTP Client或Postman测试：

```http
### 查询题目列表
GET http://localhost:8080/api/question/page?current=1&size=10

### 查询题目详情
GET http://localhost:8080/api/question/1
```

#### 7. 启动前端（可选）

```bash
cd frontend
npm install
npm run dev
```

前端启动成功后访问：http://localhost:5173

#### 7. 默认管理员账号

- **用户名**：admin
- **密码**：Admin@123

> ⚠️ **注意**：首次运行需要确保MySQL和Redis已启动（Redis可选）

---

## 📁 项目结构

```
Examination-System/
├── backend/                          # 后端代码（Spring Boot）
│   ├── src/main/java/com/example/exam/
│   │   ├── common/                  # 公共模块
│   │   │   └── enums/              # 枚举类（4个）✅
│   │   ├── entity/                 # 实体类（19个）✅
│   │   │   ├── system/            # 系统模块（7个）
│   │   │   ├── question/          # 题库模块（5个）
│   │   │   ├── paper/             # 试卷模块（3个）
│   │   │   └── exam/              # 考试模块（4个）
│   │   ├── mapper/                 # Mapper接口（19个）✅
│   │   │   ├── system/
│   │   │   ├── question/
│   │   │   ├── paper/
│   │   │   └── exam/
│   │   ├── service/                # Service层（开发中）
│   │   ├── controller/             # Controller层（待开发）
│   │   ├── config/                 # 配置类（2个）✅
│   │   └── util/                   # 工具类
│   └── src/main/resources/
│       ├── application.yml         # 配置文件
│       └── mapper/                 # MyBatis XML（待创建）
├── frontend/                         # 前端代码（Vue 3）
│   ├── src/
│   │   ├── api/                    # API接口
│   │   ├── components/             # 组件
│   │   ├── views/                  # 页面
│   │   ├── routers/                # 路由
│   │   └── stores/                 # 状态管理
│   └── package.json
├── database/                         # 数据库脚本
│   ├── exam_system_complete.sql    # 完整数据库脚本 ✅
│   └── DATA_INTEGRITY_GUIDE.md     # 数据完整性指南
├── pom.xml                          # Maven配置 ✅
├── README.md                        # 本文件
└── docs/                            # 文档目录
    ├── EXAM_SYSTEM_MIGRATION_GUIDE.md     # 改造指南
    ├── MIGRATION_PROGRESS_REPORT.md       # 进度报告
    ├── QUICK_START.md                     # 快速开始指南
    └── DATA_LAYER_COMPLETE_SUMMARY.md     # 数据层完成总结
```

---

## 🎯 功能模块

### 1. 用户管理模块 ✅

- ✅ 用户注册、登录
- ✅ 角色权限管理（RBAC）
- ✅ 组织架构管理
- ✅ 审核流程

### 2. 题库管理模块 ✅

- ✅ 8种题型支持
- ✅ 知识点3级分类
- ✅ 题目批量导入/导出
- ✅ 题目审核流程
- ✅ 题库数据隔离

### 3. 试卷管理模块 ✅

- ✅ 固定组卷
- ⏳ 随机组卷（开发中）
- ✅ 试卷审核
- ✅ 试卷版本管理
- ✅ 补考设置

### 4. 考试管理模块 ✅

- ✅ 考试发布、定时发布
- ⏳ 防作弊功能（开发中）
  - 切屏检测
  - 单设备登录
  - 主观题防抄袭
- ✅ 考试监控
- ✅ 考试会话管理

### 5. 成绩管理模块 ⏳

- ⏳ 客观题自动判分（开发中）
- ⏳ 主观题人工批改（开发中）
- ⏳ 成绩统计分析（开发中）
- ⏳ 成绩导出

---

## 📊 开发进度

### 总体进度：50% 

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 数据库设计        100%
✅ 项目配置          100%
✅ 公共模块          100%
✅ 实体类层          100%
✅ Mapper层          100%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏳ Service层          0%
⏳ Controller层       0%
⏳ 前端改造           0%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 总进度            50%
```

### 已完成模块

- ✅ 数据库设计（19张表，1100行SQL）
- ✅ 枚举类（4个，370行代码）
- ✅ 实体类（19个，2315行代码）
- ✅ Mapper接口（19个，2100行代码）
- ✅ MyBatis配置（2个，100行代码）

**累计代码**: 44个文件，4,885行高质量代码

### 下一步计划

- [ ] 创建Mapper XML文件（4个核心XML）
- [ ] 开发Service层（19个Service）
- [ ] 实现自动判分功能
- [ ] 开发Controller层（19个Controller）

---

## 🛠️ 技术栈

### 后端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.2.3 | 核心框架 |
| Spring Security | 6.2.2 | 安全框架 |
| MyBatis Plus | 3.5.5 | ORM框架 |
| MySQL | 8.0.35+ | 数据库 |
| Redis | 7.0.15 | 缓存 |
| JWT | 0.12.3 | 认证 |
| Lombok | 1.18.30 | 简化代码 |
| Hutool | 5.8.25 | 工具库 |
| EasyExcel | 3.3.3 | Excel处理 |
| Quartz | 2.3.2 | 定时任务 |

### 前端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.4.21 | 核心框架 |
| Element Plus | 2.6.1 | UI组件库 |
| Vite | 5.1.4 | 构建工具 |
| Axios | 1.6.7 | HTTP请求 |
| Pinia | 2.1.7 | 状态管理 |
| ECharts | 5.5.0 | 图表库 |
| Quill | 2.0.0 | 富文本编辑器 |

---

## 📚 文档

- [📖 改造指南](docs/learn/EXAM_SYSTEM_MIGRATION_GUIDE.md) - 详细的改造方案和技术选型
- [📊 进度报告](docs/learn/MIGRATION_PROGRESS_REPORT.md) - 实时更新的改造进度
- [🚀 快速开始](docs/learn/QUICK_START.md) - 快速启动指南
- [💾 数据完整性指南](database/DATA_INTEGRITY_GUIDE.md) - 数据库设计说明
- [📝 需求文档](考试系统需求文档（V1.0%20-%20完整版）.md) - 完整业务需求

---

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

### 代码规范

- **Java**: 遵循阿里巴巴Java开发手册
- **JavaScript**: 遵循ESLint规范
- **Git提交**: 使用Conventional Commits规范

---

## 📝 更新日志

### [2.0.0-SNAPSHOT] - 2025-11-06

#### 新增
- ✅ 完整的数据库设计（19张表）
- ✅ 8种题型枚举类
- ✅ 19个实体类（支持逻辑删除、自动填充）
- ✅ 19个Mapper接口（支持复杂查询）
- ✅ MyBatis Plus配置（分页、乐观锁、防攻击）

#### 改进
- ✅ JWT版本升级至0.12.3
- ✅ 项目名称改为exam-system
- ✅ 添加EasyExcel、Quartz依赖

---

## 📞 联系方式

- **项目负责人**: Exam System Team
- **技术支持**: GitHub Issues
- **文档维护**: 实时更新

---

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证。

---

## 🙏 致谢

感谢所有为本项目做出贡献的开发者！

---

**最后更新**: 2025-11-06 | **版本**: V2.0.0-SNAPSHOT | **进度**: 50% | **状态**: 🟢 进行中

