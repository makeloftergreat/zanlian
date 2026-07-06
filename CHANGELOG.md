# 更新日志

所有重要变更都记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [v0.5.0] - 2026-07-03

### 新增
- **队列高亮自己** — 所有人可见完整队列，自己的位置高亮显示并标注"(我)"，第一个标注"正在收赞"
- **溯源日志个性化** — 只显示与自己相关的记录，区分"我为X点赞"和"X为我点赞"，带完整日期时间
- **任务过期自动清理** — 被赞人已被别人完成时，旧任务自动标记 expired 并重新分配新任务

### 修复
- **点赞验证改为按名字匹配** — 之前按博客域名匹配，现在直接按 LOFTER 显示名字匹配
- **测试模式不入队列** — 测试模式确认完成后也写入 queue 和 logs 表
- **旧任务残留** — 测试模式任务不标记 done 导致每次登录都查到旧任务
- **RLS 策略阻止写入** — authenticated 角色被 RLS 拦截，禁用所有表的 RLS
- **外键约束报错** — users 表外键约束导致注册时插入失败，已删除外键
- **confirmTask 删除被赞人出队列** — 点完赞后被赞人从队列删除，自己排入队尾

### 变更
- verify-like.js 参数从 `liker_blog` 改为 `liker_name`，直接传显示名字
- loadTask 直接取队列第一个 waiting 用户（排除自己），不再有测试文章
- loadQueue 按入队时间排序，标注 is_me / is_first
- loadLogs 按 giver_id 或 receiver_id 筛选，只显示与自己相关的日志
- formatTime 改为完整日期时间格式（年-月-日 时:分）
- logs 表新增 receiver text 列和 giver_id uuid 列

---

## [v0.4.0] - 2026-07-03

### 新增
- **点赞验证功能**：用户点"确认完成"后，系统自动验证是否真的点了赞
  - 新增 `/api/verify-like` Vercel Serverless Function
  - 用 LOFTER 服务号 Cookie 抓取文章页 SSR HTML
  - 解析 `<ol class="notes">` 提取点赞者博客域名列表
  - 比对用户马甲号域名是否在点赞列表中
  - 验证通过 → 计数+1，入队列
  - 验证失败 → 提示"未检测到你的点赞，请先去文章页点红心后再确认"

### 变更
- `confirmTask` 函数增加验证逻辑：先验证再入队列
- "确认完成"按钮验证时显示"验证中..."并禁用
- 新增 `verifying` 响应式状态变量

### 已知限制
- LOFTER Cookie 内嵌在代码中，过期后需手动更新（通常 7-30 天）
- 后续计划迁移到 Supabase `settings` 表存储 Cookie

---

## [v0.3.0] - 2026-07-03

### 重构
- **UI 全面改版**：整体视觉风格重新设计，更现代、更紧凑
  - 全新配色方案：红色主色调（#ff5c5c）+ 金色辅色，取代旧的紫色主题
  - 卡片圆角（16px）+ 柔和过渡动画（cubic-bezier）
  - 顶部导航栏改为 sticky 定位 + 毛玻璃背景（backdrop-filter blur）
  - Logo 心形图标添加脉冲动画

### 新增
- **落地页改版**：Hero 区域 + 特性卡片网格 + 内联注册/登录表单（取代弹窗 Modal）
- **仪表盘欢迎栏**：显示头像、用户名、创作号、已点赞/已收赞统计
- **FAQ 折叠面板**：点击展开/收起，带箭头旋转动画
- **Loading 态**：任务/队列/日志三个 Tab 各自独立的加载动画
- **空状态优化**：每个 Tab 有专属图标和提示文案
- **Toast 通知**：从顶部移到底部，带边框颜色区分类型

### 变更
- 注册/登录从 Modal 弹窗改为页面内嵌表单，交互更流畅
- 任务卡片重新设计：标签徽章 + 文章链接框 + 双按钮（去点赞/确认完成）
- 队列项改为圆角序号 + 状态文字，不再使用表格行式布局
- 日志项简化为 `giver -> receiver + 时间` 单行布局
- 按钮体系统一：btn-primary / btn-secondary / btn-full / btn-confirm
- CSS 变量重命名：--bg / --bg-card / --bg-hover / --border / --border-light
- 移除 localStorage 存储 username 的逻辑，改用 Supabase session 恢复
- 移除 15 秒自动刷新队列的 setInterval，改为 Tab 切换时懒加载
- 页脚简化，添加版本号显示

### 修复
- 会话恢复逻辑简化：直接使用 Supabase session.user，不再需要 localStorage 中间层
- 注册时正确写入 user.id 到 users 表（之前只写 username，未关联 auth user）

---

## [v0.2.0] - 2026-07-03

### 修复
- **Vue 模板渲染失败**：页面显示 `{{ xxx }}` 原始模板文本，Vue 未正确渲染
  - 修复 `const supabase` 与 Supabase SDK 全局变量冲突（改为 `const sb`）
  - 修复使用了 `vue.global.prod.js` 不支持运行时模板编译（改为 `vue.global.js`）
  - 修复 Vue 解构遗漏 `watch`（补上 `watch` 到解构列表）
- **邮箱验证链接指向 localhost**：注册后验证邮件中的链接跳转到 `http://localhost:3000`
  - 在 Supabase Dashboard 将 Site URL 改为 `https://zanlian.vercel.app`

### 变更
- 数据库清空重建：users、tasks、queue 三张表数据清空，全新开始
- 确认使用 Vercel 子域名 `zanlian.vercel.app`，暂不绑定自定义域名
- GitHub 推送方式增加 REST API 备选方案（网络不稳定时使用）

---

## [v0.1.0] - 2026-07-02

### 新增
- 产品官网首页：Hero 区域、核心机制、双账号隔离、上手指南、安全保障、FAQ
- 用户系统：注册（马甲号+创作号+邮箱+密码）、登录、退出、状态持久化
- 任务面板：自动分配点赞任务、显示任务信息、确认完成按钮、每日 20 次上限
- 排队队列：按位置排序、状态显示、15 秒自动刷新
- 溯源日志：只显示马甲号、按时间倒序、相对时间显示
- 核心点赞流程：确认点赞 → 任务完成 → 用户计数 → 入队 → 自动分配下一个
- 深色主题 UI
- Supabase 后端：users、tasks、queue 三张表
- Vercel 自动部署：绑定 GitHub 仓库，push 自动部署

---

## 版本号规则

- **主版本号（Major）**：不兼容的 API 修改
- **次版本号（Minor）**：向下兼容的功能性新增
- **修订号（Patch）**：向下兼容的问题修正

当前处于 **0.x.x** 阶段，表示初始开发阶段，API 可能随时变化。
