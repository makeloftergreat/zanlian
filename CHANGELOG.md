# 更新日志

所有重要变更都记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

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
