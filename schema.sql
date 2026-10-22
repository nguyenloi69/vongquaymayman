-- Chạy toàn bộ file này trong Supabase > SQL Editor
create table games (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  status text not null default 'lobby',   -- lobby | question | leaderboard | finished
  current_q int not null default 0,
  questions jsonb not null,
  time_limit int not null default 20,
  created_at timestamptz default now()
);
create table players (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references games(id) on delete cascade,
  name text not null,
  created_at timestamptz default now(),
  unique (game_id, name)
);
create table answers (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references games(id) on delete cascade,
  player_id uuid not null references players(id) on delete cascade,
  q_index int not null,
  choice int not null,
  points int not null default 0,
  unique (player_id, q_index)
);

alter table games enable row level security;
alter table players enable row level security;
alter table answers enable row level security;

-- Phiên bản đơn giản cho lớp học: ai có khóa anon đều đọc/ghi được các thao tác dưới đây
create policy "games_select" on games for select using (true);
create policy "games_insert" on games for insert with check (true);
create policy "games_update" on games for update using (true) with check (true);
create policy "players_select" on players for select using (true);
create policy "players_insert" on players for insert with check (true);
create policy "answers_select" on answers for select using (true);
create policy "answers_insert" on answers for insert with check (true);

-- Bật realtime cho 3 bảng
alter publication supabase_realtime add table games, players, answers;
