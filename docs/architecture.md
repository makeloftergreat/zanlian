# 架构设计

## 整体架构

```
用户浏览器 (Vue 3 SPA)
    │
    ├── CDN 加载 Vue 3 + Supabase JS SDK
    │
    ▼
Supabase (PostgreSQL + Auth + REST API)
    │
    ├── users 表 ── 用户数据
    ├── tasks 表 ── 点赞任务
    └── queue 表 ── 排队队列
```

## 核心流程

### 注册/登录流程

```
用户填写：马甲号 + 创作号 + 邮箱 + 密码
    │
    ▼
Supabase Auth 创建账号
    │
    ▼
写入 users 表（username=马甲号, main_account=创作号）
    │
    ▼
localStorage 缓存用户信息
    │
    ▼
跳转到任务面板
```

### 点赞流程（先付后得）

```
用户进入任务面板
    │
    ▼
从 queue 表取出第一个 waiting 状态的记录（排除自己）
    │
    ▼
显示任务：去给 XXX 的最新文章点赞
    │
    ▼
用户点击"执行点赞" → 跳转到文章页面
    │
    ▼
用户确认已完成点赞
    │
    ▼
1. tasks 表新增记录，status=completed
2. 用户 today_given +1, given_count +1
3. 自己的创作号排入 queue（position = max+1）
4. 被点赞的 queue 记录 status=done
5. 自动分配下一个任务
```

### 排队规则

```
排队队列按 position 升序排列
    │
    ├── position 小的优先被分配点赞
    ├── 自己不能给自己点赞
    └── 每日点赞上限 20 次
```

## 双账号隔离设计

| 概念 | 用途 | 可见性 |
|------|------|--------|
| 马甲号 | 给他人点赞 | 对其他用户可见 |
| 创作号 | 接收点赞 | 仅自己可见 |

- 其他用户看到的只是你的马甲号
- 溯源日志中只出现马甲号
- 创作号信息不出现在任何公开数据中

## 安全设计

- Supabase Auth 负责用户认证
- 数据库层面通过 RLS（Row Level Security）控制访问
- 前端不存储任何敏感密钥
- 每日点赞上限防止滥用
