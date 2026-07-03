-- 赞链 (ZanLian) 数据库表结构
-- Supabase 项目: zrxvibalglblsjbzlzut
-- 执行方式: 在 Supabase SQL Editor 中运行

-- 1. 用户表：存储马甲号与创作号的映射关系
CREATE TABLE IF NOT EXISTS users (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  username text NOT NULL UNIQUE,              -- 马甲号用户名
  main_account text NOT NULL,                 -- 创作号用户名
  given_count int NOT NULL DEFAULT 0,         -- 累计付出赞数
  received_count int NOT NULL DEFAULT 0,      -- 累计收获赞数
  today_given int NOT NULL DEFAULT 0,         -- 今日付出赞数
  last_given_date date DEFAULT current_date   -- 最后点赞日期
);

-- 2. 点赞任务表：记录每次点赞任务
CREATE TABLE IF NOT EXISTS tasks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  giver_id bigint NOT NULL REFERENCES users(id),   -- 执行点赞的用户
  receiver_main text NOT NULL,                      -- 被点赞的创作号
  receiver_name text NOT NULL,                      -- 被点赞的马甲号
  article_url text NOT NULL,                        -- 被点赞的文章URL
  status text NOT NULL DEFAULT 'pending'            -- pending / completed
);

-- 3. 排队队列表：创作号等待回赞的队列
CREATE TABLE IF NOT EXISTS queue (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  user_id bigint NOT NULL REFERENCES users(id),     -- 排队的用户
  article_url text NOT NULL,                        -- 创作号的文章URL
  status text NOT NULL DEFAULT 'waiting',           -- waiting / done
  position int NOT NULL                             -- 排队位置
);

-- 索引：加速常用查询
CREATE INDEX IF NOT EXISTS idx_queue_status ON queue(status);
CREATE INDEX IF NOT EXISTS idx_queue_position ON queue(position);
CREATE INDEX IF NOT EXISTS idx_tasks_giver ON tasks(giver_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- 注释
COMMENT ON TABLE users IS '赞链用户表';
COMMENT ON TABLE tasks IS '点赞任务表';
COMMENT ON TABLE queue IS '排队队列表';
