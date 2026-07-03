# 赞链 (ZanLian)

> LOFTER 点赞互助平台 — 先付后得，公平排队

赞链是一个基于 LOFTER 平台的点赞互助工具。用户通过"马甲号"为他人点赞，自己的"创作号"则排队等待回赞。双账号隔离设计，保护隐私，公平透明。

## 核心机制

- **双账号隔离** — 马甲号负责点赞，创作号负责收赞，互不暴露
- **先付后得** — 必须先给他人点赞，自己的创作号才能进入排队队列
- **先来后到** — 排队按加入顺序，位置透明可查
- **溯源日志** — 只记录马甲号之间的互动，不暴露任何创作号信息
- **每日上限** — 每天 20 次点赞上限，防止滥用

## 技术栈

| 层 | 技术 | 说明 |
|---|---|---|
| 前端 | Vue 3 (CDN) | 单页应用，无需构建工具 |
| 后端 | Supabase | PostgreSQL 数据库 + Auth 认证 + REST API |
| 部署 | Vercel | 自动部署，0 费用 |
| 代码托管 | GitHub | 开源管理 |

## 快速开始

### 在线使用

访问 [zanlian.vercel.app](https://zanlian.vercel.app) 即可使用。

### 本地开发

```bash
git clone https://github.com/makeloftergreat/zanlian.git
cd zanlian
# 用任意静态服务器打开 index.html，例如：
npx serve .
# 或
python -m http.server 8080
```

### 环境配置

本项目使用 Supabase 作为后端，配置信息已内联在 `index.html` 中。如需自行部署，请替换以下配置：

```javascript
const SUPABASE_URL = 'your-supabase-url';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

## 数据库结构

```sql
-- 用户表：存储马甲号与创作号的映射关系
CREATE TABLE users (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  username text NOT NULL UNIQUE,
  main_account text NOT NULL,
  given_count int NOT NULL DEFAULT 0,
  received_count int NOT NULL DEFAULT 0,
  today_given int NOT NULL DEFAULT 0,
  last_given_date date DEFAULT current_date
);

-- 任务表：记录每次点赞任务
CREATE TABLE tasks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  giver_id bigint NOT NULL REFERENCES users(id),
  receiver_main text NOT NULL,
  receiver_name text NOT NULL,
  article_url text NOT NULL,
  status text NOT NULL DEFAULT 'pending'
);

-- 排队队列表：创作号等待回赞的队列
CREATE TABLE queue (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  user_id bigint NOT NULL REFERENCES users(id),
  article_url text NOT NULL,
  status text NOT NULL DEFAULT 'waiting',
  position int NOT NULL
);
```

完整 SQL 见 [`docs/database.sql`](docs/database.sql)。

## 项目结构

```
zanlian/
├── index.html              # 主应用（官网 + 仪表盘）
├── docs/                   # 项目文档
│   ├── database.sql        # 数据库建表语句
│   ├── architecture.md     # 架构设计说明
│   └── api.md              # API 接口说明
├── .github/                # GitHub 配置
│   └── workflows/          # CI/CD 工作流
├── .gitignore
├── LICENSE                 # MIT 许可证
├── CONTRIBUTING.md         # 贡献指南
├── CHANGELOG.md            # 版本更新日志
└── README.md               # 项目说明（本文件）
```

## 开发路线

- [x] 产品官网与演示
- [x] 用户注册/登录（Supabase Auth）
- [x] 任务分配与执行
- [x] 排队队列管理
- [x] 溯源日志
- [ ] 浏览器扩展（自动点赞）
- [ ] VIP 配额系统（每日 3 次插队权）
- [ ] 数据统计面板
- [ ] 移动端优化

## 贡献

欢迎提交 Issue 和 Pull Request。请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT License](LICENSE)
