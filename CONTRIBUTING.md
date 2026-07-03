# 贡献指南

感谢你对赞链项目的关注！以下是参与贡献的方式。

## 如何贡献

### 报告问题

1. 在 [Issues](https://github.com/makeloftergreat/zanlian/issues) 中搜索是否已有相同问题
2. 如果没有，点击 **New Issue** 创建新问题
3. 请描述清楚：问题现象、复现步骤、期望行为、实际行为

### 提交代码

1. Fork 本仓库
2. 创建分支：`git checkout -b feature/your-feature-name`
3. 提交更改：`git commit -m "feat: 简要描述"`
4. 推送分支：`git push origin feature/your-feature-name`
5. 创建 Pull Request

### 提交信息规范

| 前缀 | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加VIP配额系统` |
| `fix` | 修复Bug | `fix: 修复排队位置计算错误` |
| `docs` | 文档更新 | `docs: 更新README` |
| `style` | 代码格式 | `style: 统一缩进` |
| `refactor` | 重构 | `refactor: 拆分任务分配逻辑` |
| `test` | 测试 | `test: 添加队列排序测试` |
| `chore` | 构建/工具 | `chore: 添加CI工作流` |

### 代码规范

- 缩进：2 空格
- 命名：变量用 camelCase，CSS 类用 kebab-case
- 注释：复杂逻辑必须注释，简单代码不加注释
- 文件编码：UTF-8，换行符 LF

### 开发环境

```bash
git clone https://github.com/makeloftergreat/zanlian.git
cd zanlian
npx serve .
```

浏览器打开 `http://localhost:3000` 即可预览。

## 行为准则

- 保持友好和尊重
- 接受建设性批评
- 关注对社区最有利的事
