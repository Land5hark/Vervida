-- Core schema with secure RLS policies (CRUD + role-aware, WITH CHECK added)

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

-- Task actions
create table task_actions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references tasks(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  action_type text check (action_type in ('reorder','override_priority','accept_ai','reject_ai')),
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table projects enable row level security;
alter table project_members enable row level security;
alter table tasks enable row level security;
alter table notes enable row level security;
alter table events enable row level security;
alter table task_actions enable row level security;

-- Project policies
create policy "Users can create their own projects"
  on projects for insert
  with check (auth.uid() = created_by);

create policy "Owners can update projects"
  on projects for update
  using (auth.uid() = created_by)
  with check (auth.uid() = created_by);

create policy "Owners can delete projects"
  on projects for delete
  using (auth.uid() = created_by);

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
create policy "Members can view membership of their projects"
  on project_members for select
  using (
    exists (
      select 1 from project_members pm
      where pm.project_id = project_members.project_id
      and pm.user_id = auth.uid()
    )
  );

create policy "Owners can invite members"
  on project_members for insert
  with check (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and p.created_by = auth.uid()
    )
  );

create policy "Owners can update membership"
  on project_members for update
  using (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and p.created_by = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and p.created_by = auth.uid()
    )
  );

create policy "Owners can remove members"
  on project_members for delete
  using (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and p.created_by = auth.uid()
    )
  );

-- Tasks policies with role enforcement
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

create policy "Editors and owners can insert tasks"
  on tasks for insert
  with check (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','editor')
    )
  );

create policy "Editors and owners can update tasks"
  on tasks for update
  using (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','editor')
    )
  )
  with check (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','editor')
    )
  );

create policy "Owners can delete tasks"
  on tasks for delete
  using (
    auth.uid() = user_id
    or exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
      and pm.role = 'owner'
    )
  );

-- Notes policies
create policy "Users can manage own notes"
  on notes for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Events policies
create policy "Users can manage own events"
  on events for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Task actions policies
create policy "Users can manage own task actions"
  on task_actions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
