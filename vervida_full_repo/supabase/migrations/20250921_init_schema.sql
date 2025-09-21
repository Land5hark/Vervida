-- Core schema and RLS setup for VerVida

-- Users
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  display_name text,
  created_at timestamp with time zone default now()
);

-- Projects
create table projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid references users(id),
  created_at timestamp with time zone default now()
);

-- Project membership
create table project_members (
  project_id uuid references projects(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  role text check (role in ('owner','editor','viewer')) default 'editor',
  primary key (project_id, user_id)
);

-- Tasks
create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  project_id uuid references projects(id) on delete cascade,
  title text not null,
  description text,
  status text check (status in ('pending','in_progress','done')) default 'pending',
  priority int default 0,
  due_date date,
  created_at timestamp with time zone default now()
);

-- Notes
create table notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default now()
);

-- Events
create table events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  title text not null,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  created_at timestamp with time zone default now()
);

-- Task actions (manual prioritization instrumentation)
create table task_actions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references tasks(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  action_type text check (action_type in ('reorder','override_priority','accept_ai','reject_ai')),
  created_at timestamp with time zone default now()
);

-- Enable RLS for all tables
alter table tasks enable row level security;
alter table projects enable row level security;
alter table project_members enable row level security;
alter table notes enable row level security;
alter table events enable row level security;
alter table task_actions enable row level security;

-- Task policies (owner or project member)
create policy "Project members can view tasks"
  on tasks for select
  using (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
    )
  );

create policy "Project members can insert tasks"
  on tasks for insert
  with check (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = project_id
      and pm.user_id = auth.uid()
    )
  );

create policy "Project members can update tasks"
  on tasks for update
  using (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
    )
  );

create policy "Project members can delete tasks"
  on tasks for delete
  using (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
    )
  );

-- Projects policies
create policy "Members can view projects"
  on projects for select
  using (
    exists (
      select 1 from project_members pm
      where pm.project_id = projects.id
      and pm.user_id = auth.uid()
    )
  );

-- Project members policies
create policy "Members can view project membership"
  on project_members for select
  using (auth.uid() = user_id);

-- Notes policies (owner only)
create policy "Users can manage own notes"
  on notes for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Events policies (owner only)
create policy "Users can manage own events"
  on events for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Task actions policies (owner only)
create policy "Users can manage own task actions"
  on task_actions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
