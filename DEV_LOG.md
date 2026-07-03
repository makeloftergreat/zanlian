# 赞链 (ZanLian) 开发记录

> 本文件记录所有已讨论和已实现的功能需求，供跨设备、跨会话恢复上下文使用。
> 最后更新：2026-07-03

---

## 一、项目概述

**赞链** 是一个基于 LOFTER 平台的点赞互助工具。

核心思路：用户通过"马甲号"为他人点赞，自己的"创作号"排队等待回赞。双账号隔离，保护隐私，公平透明。

- **GitHub**: https://github.com/makeloftergreat/zanlian
- **Vercel**: https://zanlian.vercel.app
- **Supabase**: https://zrxvibalglblsjbzlzut.supabase.co
- **技术栈**: Vue 3 (CDN) + Supabase + Vercel
- **费用**: 0 费用上线（Vercel 免费版 + Supabase 免费版）

---

## 二、已实现功能

### 2.1 产品官网（index.html 未登录状态）
- [x] Hero 区域：产品名称、Slogan、CTA 按钮
- [x] 运作机制说明：先付后得、排队等待、收到回赞
- [x] 双账号隔离说明：马甲号点赞 vs 创作号收赞
- [x] 使用流程指引：注册→领任务→执行点赞→排入队列→收到回赞
- [x] 安全保障说明：密码不过服务器、点赞IP归属你、主号零风险、可随时撤销
- [x] FAQ 手风琴折叠
- [x] 深色主题 UI

### 2.2 用户系统
- [x] 注册：马甲号用户名 + 创作号用户名 + 邮箱 + 密码
- [x] 登录：邮箱 + 密码
- [x] 登录状态持久化（localStorage）
- [x] 退出登录

### 2.3 任务面板（登录后）
- [x] 自动从 queue 表分配第一个 waiting 状态的任务（排除自己）
- [x] 显示任务信息：对方马甲号、创作号、文章链接
- [x] 执行点赞步骤指引
- [x] "我已点赞，确认完成"按钮
- [x] 每日点赞上限 20 次，达到后禁用按钮
- [x] 顶栏统计：已点赞数、获得赞数、今日点赞/20

### 2.4 排队队列
- [x] 按 position 升序显示所有排队用户
- [x] 显示：马甲号、排队位置、状态（等待中/已完成/处理中）
- [x] 自己的创作号标记为"你的创作号(你)"
- [x] 每 15 秒自动刷新

### 2.5 溯源日志
- [x] 只显示马甲号，不暴露创作号
- [x] 格式：马甲A → 马乙
- [x] 按时间倒序排列
- [x] 显示相对时间（刚刚/X分钟前/X小时前）

### 2.6 核心点赞流程
- [x] 确认点赞后执行：
  1. tasks 表新增记录，status=completed
  2. 用户 today_given +1, given_count +1
  3. 自己的创作号排入 queue（position = max+1）
  4. 被点赞的 queue 记录 status=done
  5. 自动分配下一个任务

---

## 三、已讨论但尚未实现的功能

### 3.1 VIP 配额系统（暂缓）
- VIP 会员每日 3 次"插队权"，用完回到普通队列先来后到
- 多个 VIP 同时插队时，按"累计贡献赞数"排序
- 年度会员每日 5 次插队权，赞数权重 ×2
- VIP 之间按累计赞数排序，非 VIP 按加入顺序
- 演示站中已有 UI 设计（每日配额显示、队列标签），后端逻辑未实现
- **状态：用户明确表示"VIP 可以先不做"，当前为纯先来后到**

### 3.2 浏览器扩展
- 用于自动执行点赞操作
- 减少用户手动打开文章、点击红心的步骤
- **状态：尚未开始**

### 3.3 数据统计面板
- 可视化展示点赞趋势、回赞率等
- **状态：尚未开始**

### 3.4 移动端优化
- 当前已有基本响应式，但未专门优化移动端体验
- **状态：尚未开始**

---

## 四、数据库结构

### Supabase 项目信息
- **Project ID**: zrxvibalglblsjbzlzut
- **Project URL**: https://zrxvibalglblsjbzlzut.supabase.co
- **Region**: Asia-Pacific
- **Plan**: Free

### 表结构

#### users — 用户表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint PK | 自增主键 |
| created_at | timestamptz | 创建时间 |
| username | text UNIQUE | 马甲号用户名 |
| main_account | text | 创作号用户名 |
| given_count | int | 累计付出赞数（默认0） |
| received_count | int | 累计收获赞数（默认0） |
| today_given | int | 今日付出赞数（默认0） |
| last_given_date | date | 最后点赞日期 |

#### tasks — 点赞任务表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint PK | 自增主键 |
| created_at | timestamptz | 创建时间 |
| giver_id | bigint FK→users.id | 执行点赞的用户 |
| receiver_main | text | 被点赞的创作号 |
| receiver_name | text | 被点赞的马甲号 |
| article_url | text | 被点赞的文章URL |
| status | text | pending / completed |

#### queue — 排队队列表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint PK | 自增主键 |
| created_at | timestamptz | 创建时间 |
| user_id | bigint FK→users.id | 排队的用户 |
| article_url | text | 创作号的文章URL |
| status | text | waiting / done |
| position | int | 排队位置 |

### 索引（建议添加，当前未添加）
```sql
CREATE INDEX idx_queue_status ON queue(status);
CREATE INDEX idx_queue_position ON queue(position);
CREATE INDEX idx_tasks_giver ON tasks(giver_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_users_username ON users(username);
```

---

## 五、账号与密钥

> ⚠️ 敏感信息（Token、Key）不记录在此文件中，请从各自的平台控制台获取

| 项目 | 值 |
|------|-----|
| GitHub 用户名 | makeloftergreat |
| GitHub 仓库 | makeloftergreat/zanlian |
| GitHub Token | ⚠️ 不记录，从 https://github.com/settings/tokens 获取 |
| Supabase Project ID | zrxvibalglblsjbzlzut |
| Supabase URL | https://zrxvibalglblsjbzlzut.supabase.co |
| Supabase Anon Key | ⚠️ 不记录，从 Supabase Dashboard → Settings → API 获取 |
| Vercel 项目名 | zanlian |
| Vercel URL | https://zanlian.vercel.app |
| Vercel 团队 | haha |

### GitHub Token 权限说明
- 当前 Token 只有 `repo` 权限，**没有 `workflow` 权限**
- 因此无法推送 `.github/workflows/` 下的 CI 配置文件
- 如需 CI/CD，需重新生成 Token 并勾选 `workflow` 权限

---

## 六、已知问题

### 6.1 Vue 模板编译问题
- **现象**：页面显示 `{{ xxx }}` 原始模板文本，Vue 未正确渲染
- **原因**：使用了 `vue.global.prod.js`（生产版）不支持运行时模板编译
- **修复**：已改为 `vue.global.js`（完整版）
- **状态**：已修复，但 Vercel 部署可能需要等 1-2 分钟生效

### 6.2 Supabase API Key 获取困难
- **现象**：新版 Supabase 控制台界面与旧版不同，找不到 anon key
- **解决**：最终在 Project Settings → API 中找到
- **注意**：如果 Supabase 更新界面，参考 docs/api.md 中的连接信息

### 6.3 环境网络限制
- 当前开发环境无法直接访问外网（curl 超时）
- GitHub 推送偶尔会因网络问题失败，重试即可
- Vercel 部署状态需用户在浏览器中确认

---

## 七、本地开发环境

| 项目 | 路径/值 |
|------|---------|
| 工作目录 | C:\Users\slam\AppData\Roaming\hexagent-lite\sessions\session_1782961040267 |
| Git 路径 | C:\Program Files\Git\bin\git.exe |
| Git 用户名 | makeloftergreat |
| Git 邮箱 | makeloftergreat@users.noreply.github.com |
| Node.js | 未安装（当前用 CDN 方式无需构建） |
| Python | 已安装（用于本地预览） |

### 本地预览
```bash
cd C:\Users\slam\AppData\Roaming\hexagent-lite\sessions\session_1782961040267
python -m http.server 8080
# 浏览器打开 http://localhost:8080
```

### 推送到 GitHub
```bash
"C:\Program Files\Git\bin\git.exe" add -A
"C:\Program Files\Git\bin\git.exe" commit -m "描述信息"
"C:\Program Files\Git\bin\git.exe" push origin master
```

---

## 八、决策记录

| 日期 | 决策 | 原因 |
|------|------|------|
| 2026-07-02 | 使用 Vue 3 CDN 方式而非构建工具 | 简化部署，0 配置 |
| 2026-07-02 | 使用 Supabase 而非自建后端 | 0 费用、自带 Auth、REST API |
| 2026-07-02 | 使用 Vercel 部署 | 0 费用、自动部署、绑定 GitHub |
| 2026-07-02 | VIP 系统暂缓 | 用户决定先做核心功能 |
| 2026-07-02 | 双账号隔离设计 | 保护创作号隐私，马甲号可见，创作号不可见 |
| 2026-07-03 | 项目结构规范化 | 开源准备，方便跨设备协作 |
| 2026-07-03 | 单文件 HTML 架构 | 简化部署，后续可拆分 |

---

## 九、后续开发计划

按优先级排序：

1. **修复 Vercel 部署** — 确认线上版本 Vue 正常渲染
2. **测试注册登录流程** — 确认 Supabase Auth 正常工作
3. **测试点赞流程** — 确认任务分配、排队、回赞完整链路
4. **浏览器扩展** — 自动点赞，减少手动操作
5. **VIP 配额系统** — 每日 3 次插队权，按赞数排序
6. **数据统计面板** — 点赞趋势、回赞率
7. **移动端优化** — 专门适配手机端
8. **代码拆分** — 当 index.html 过大时拆分为多个文件

---

## 十、如何恢复开发

如果你换了电脑或中断了一段时间，按以下步骤恢复：

### 1. 拉取代码
```bash
git clone https://github.com/makeloftergreat/zanlian.git
cd zanlian
```

### 2. 检查 Supabase 后端
- 打开 https://supabase.com/dashboard/project/zrxvibalglblsjbzlzut
- 确认 users、tasks、queue 三个表存在
- 如需重建，执行 docs/database.sql

### 3. 检查 Vercel 部署
- 打开 https://zanlian.vercel.app 确认线上版本正常
- 如需重新部署，在 Vercel Dashboard 中 Redeploy

### 4. 本地开发
```bash
python -m http.server 8080
# 打开 http://localhost:8080
```

### 5. 需要的信息
- GitHub 账号：makeloftergreat
- Supabase 项目：zrxvibalglblsjbzlzut
- 本文件（DEV_LOG.md）包含所有上下文
