# API 接口说明

赞链使用 Supabase 的 REST API（PostgREST），所有数据操作通过 Supabase JS SDK 完成。

## 配置

```javascript
const SUPABASE_URL = 'https://zrxvibalglblsjbzlzut.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

## 数据表

### users — 用户表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 主键，自增 |
| created_at | timestamptz | 创建时间 |
| username | text | 马甲号用户名（唯一） |
| main_account | text | 创作号用户名 |
| given_count | int | 累计付出赞数 |
| received_count | int | 累计收获赞数 |
| today_given | int | 今日付出赞数 |
| last_given_date | date | 最后点赞日期 |

### tasks — 点赞任务表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 主键，自增 |
| created_at | timestamptz | 创建时间 |
| giver_id | bigint | 执行点赞的用户ID（FK→users.id） |
| receiver_main | text | 被点赞的创作号 |
| receiver_name | text | 被点赞的马甲号 |
| article_url | text | 被点赞的文章URL |
| status | text | 任务状态：pending / completed |

### queue — 排队队列表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 主键，自增 |
| created_at | timestamptz | 创建时间 |
| user_id | bigint | 排队的用户ID（FK→users.id） |
| article_url | text | 创作号的文章URL |
| status | text | 排队状态：waiting / done |
| position | int | 排队位置 |

## 常用操作

### 注册用户

```javascript
// 1. Supabase Auth 注册
const { data, error } = await supabase.auth.signUp({
  email, password
});

// 2. 写入 users 表
const { error } = await supabase.from('users').insert({
  username:马甲号,
  main_account: 创作号,
  given_count: 0,
  received_count: 0,
  today_given: 0,
  last_given_date: new Date().toISOString().split('T')[0]
});
```

### 获取待办任务

```javascript
const { data } = await supabase.from('queue')
  .select('*, users!inner(username, main_account)')
  .eq('status', 'waiting')
  .neq('user_id', currentUserId)
  .order('position', { ascending: true })
  .limit(1)
  .maybeSingle();
```

### 完成点赞

```javascript
// 1. 记录任务
await supabase.from('tasks').insert({
  giver_id: currentUserId,
  receiver_main: queueEntry.users.main_account,
  receiver_name: queueEntry.users.username,
  article_url: queueEntry.article_url,
  status: 'completed'
});

// 2. 更新用户统计
await supabase.from('users')
  .update({ today_given: newTodayGiven, given_count: newGivenCount })
  .eq('id', currentUserId);

// 3. 自己排入队列
const maxPos = await getMaxPosition();
await supabase.from('queue').insert({
  user_id: currentUserId,
  article_url: myArticleUrl,
  status: 'waiting',
  position: maxPos + 1
});

// 4. 标记被点赞的队列记录为 done
await supabase.from('queue')
  .update({ status: 'done' })
  .eq('id', queueEntry.id);
```

### 查看排队队列

```javascript
const { data } = await supabase.from('queue')
  .select('*, users!inner(username)')
  .order('position', { ascending: true });
```

### 查看溯源日志

```javascript
// 我给别人的赞
const { data: given } = await supabase.from('tasks')
  .select('id, receiver_name, created_at, status')
  .eq('giver_id', currentUserId)
  .eq('status', 'completed')
  .order('created_at', { ascending: false });

// 别人给我的赞
const { data: received } = await supabase.from('tasks')
  .select('id, giver_id, users!inner(username), created_at')
  .eq('receiver_main', myMainAccount)
  .eq('status', 'completed')
  .order('created_at', { ascending: false });
```

---

## Serverless API

### POST /api/verify-like — 点赞验证

验证用户是否真的在 LOFTER 文章页点了赞。

**请求：**

```json
POST /api/verify-like
Content-Type: application/json

{
  "article_url": "https://xxx.lofter.com/post/ade72416_34df7d930",
  "liker_blog": "https://yyy.lofter.com/"
}
```

**响应：**

```json
{
  "verified": true,
  "liker_count": 30,
  "likers": ["乒乓大国手", "蓼运の欢🍀", "墨然", "..."],
  "liker_domain": "yyy.lofter.com"
}
```

**原理：**
1. 用 LOFTER 服务号 Cookie 抓取文章页 HTML（需登录态才有 SSR 点赞列表）
2. 解析 `<ol class="notes">` 中的 `<a href="//username.lofter.com/">` 提取点赞者域名
3. 比对 `liker_blog` 的域名是否在列表中

**错误码：**
- `400` — 缺少参数
- `502` — Cookie 过期（HTML < 10KB，未拿到 SSR 内容）
- `500` — 服务器异常
