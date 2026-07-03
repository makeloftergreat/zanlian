-- ============================================
-- 赞链 · LOFTER 点赞互助平台 数据库 Schema
-- 版本: v0.3.0
-- 日期: 2026-07-03
-- ============================================

-- 1. users 表 (id 为 uuid，关联 auth.users)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text DEFAULT '',          -- 点赞号（马甲号）
  main_account text DEFAULT '',      -- 收赞号（创作号）
  article_url text DEFAULT '',       -- 收赞文章链接（别人去点赞的地址）
  given_count int DEFAULT 0,         -- 累计点赞数
  received_count int DEFAULT 0,      -- 累计收赞数
  today_given int DEFAULT 0,         -- 今日已点赞数
  last_given_date text DEFAULT '',   -- 上次点赞日期
  created_at timestamptz DEFAULT now()
);

-- 2. queue 表 (排队等收赞)
CREATE TABLE IF NOT EXISTS queue (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  position int DEFAULT 0,
  status text DEFAULT 'waiting',     -- waiting / done
  created_at timestamptz DEFAULT now()
);

-- 3. articles 表 (用户提交的文章)
CREATE TABLE IF NOT EXISTS articles (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- 4. tasks 表 (点赞任务)
CREATE TABLE IF NOT EXISTS tasks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  giver_id uuid REFERENCES users(id) ON DELETE CASCADE,
  receiver_id uuid REFERENCES users(id) ON DELETE CASCADE,
  article_url text,
  status text DEFAULT 'pending',     -- pending / done / expired
  created_at timestamptz DEFAULT now(),
  done_at timestamptz
);

-- 5. logs 表 (操作日志)
CREATE TABLE IF NOT EXISTS logs (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  giver text,
  receiver_id text,
  created_at timestamptz DEFAULT now()
);

-- ============================================
-- RLS (Row Level Security)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- users: 用户只能读写自己的记录
CREATE POLICY "users_select_own" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "users_insert_own" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- queue: 所有人可查看排队，只能插入自己的
CREATE POLICY "queue_select_all" ON queue FOR SELECT USING (true);
CREATE POLICY "queue_insert_own" ON queue FOR INSERT WITH CHECK (auth.uid() = user_id);

-- articles: 所有人可查看文章，只能插入自己的
CREATE POLICY "articles_select_all" ON articles FOR SELECT USING (true);
CREATE POLICY "articles_insert_own" ON articles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- tasks: 只能查看/插入/更新自己的任务
CREATE POLICY "tasks_select_own" ON tasks FOR SELECT USING (auth.uid() = giver_id);
CREATE POLICY "tasks_insert_own" ON tasks FOR INSERT WITH CHECK (auth.uid() = giver_id);
CREATE POLICY "tasks_update_own" ON tasks FOR UPDATE USING (auth.uid() = giver_id);

-- logs: 所有人可查看
CREATE POLICY "logs_select_all" ON logs FOR SELECT USING (true);
