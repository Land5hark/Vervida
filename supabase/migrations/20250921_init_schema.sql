-- VerVida Complete Schema v2.0
-- Includes all PRD requirements, ADHD features, AI support, and security fixes

-- ========================================
-- EXTENSIONS
-- ========================================
create extension if not exists "uuid-ossp";
create extension if not exists "pg_cron"; -- For scheduled tasks
create extension if not exists "vector"; -- For AI embeddings

-- ========================================
-- CORE TABLES
-- ========================================

-- Users (linked to Supabase Auth)
create table users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  display_name text,
  avatar_url text,
  onboarding_completed boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- User Preferences (ADHD-specific settings)
create table user_preferences (
  user_id uuid primary key references users(id) on delete cascade,
  -- ADHD Support
  time_blindness_alerts boolean default true,
  hyperfocus_break_interval interval default '45 minutes',
  hyperfocus_detection boolean default true,
  task_breakdown_automation boolean default true,
  decision_fatigue_protection boolean default true,
  
  -- Sensory Preferences
  theme text check (theme in ('light','dark','system','high_contrast')) default 'system',
  reduced_animations boolean default false,
  notification_style text check (notification_style in ('gentle','standard','urgent','visual_only')) default 'gentle',
  notification_sound text default 'soft_chime',
  
  -- Energy & Focus
  daily_energy_pattern jsonb default '{"morning": "low", "afternoon": "medium", "evening": "high"}',
  focus_hours jsonb default '{"start": "09:00", "end": "17:00"}',
  low_energy_task_suggestions boolean default true,
  
  -- AI Settings
  ai_aggressiveness text check (ai_aggressiveness in ('conservative','balanced','aggressive')) default 'balanced',
  ai_model_preference text check (ai_model_preference in ('fast','balanced','powerful')) default 'balanced',
  ai_explanations boolean default true,
  
  -- Collaboration
  default_task_visibility text check (default_task_visibility in ('private','team','public')) default 'private',
  allow_task_reassignment boolean default true,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Goals (Short and long-term alignment)
create table goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  title text not null,
  description text,
  goal_type text check (goal_type in ('daily','weekly','monthly','quarterly','annual','custom')) not null,
  target_date date,
  status text check (status in ('active','completed','abandoned','paused')) default 'active',
  progress_percentage int default 0 check (progress_percentage between 0 and 100),
  parent_goal_id uuid references goals(id) on delete cascade,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Projects (Team collaboration)
create table projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  created_by uuid references users(id) not null,
  status text check (status in ('active','archived','completed')) default 'active',
  color text default '#3B82F6',
  icon text,
  is_private boolean default false,
  settings jsonb default '{}',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Project Members
create table project_members (
  project_id uuid references projects(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  role text check (role in ('owner','admin','editor','viewer')) default 'editor',
  joined_at timestamp with time zone default now(),
  primary key (project_id, user_id)
);

-- Tasks (Enhanced with AI and ADHD features)
create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  assigned_to uuid references users(id) on delete set null,
  project_id uuid references projects(id) on delete cascade,
  parent_task_id uuid references tasks(id) on delete cascade,
  
  -- Core fields
  title text not null,
  description text,
  status text check (status in ('pending','in_progress','done','cancelled','blocked')) default 'pending',
  
  -- Priority & Scheduling
  priority int default 0 check (priority between 0 and 4),
  urgency text check (urgency in ('low','medium','high','critical')) default 'medium',
  importance text check (importance in ('low','medium','high','critical')) default 'medium',
  due_date timestamp with time zone,
  scheduled_date date,
  
  -- AI Fields
  ai_priority int,
  ai_reasoning text,
  ai_suggested_date date,
  ai_confidence_score float check (ai_confidence_score between 0 and 1),
  ai_embeddings vector(1536), -- For semantic search
  last_ai_update timestamp with time zone,
  
  -- ADHD Support
  energy_level text check (energy_level in ('low','medium','high','variable')),
  focus_type text check (focus_type in ('deep','shallow','creative','administrative','social')),
  estimated_duration interval,
  actual_duration interval,
  break_reminder boolean default false,
  is_routine boolean default false,
  
  -- Task breakdown
  is_atomic boolean default false, -- Cannot be broken down further
  auto_generated boolean default false, -- Created by AI task breakdown
  
  -- External Integration
  external_id text,
  external_source text check (external_source in ('github','slack','google_calendar','email','manual')),
  external_url text,
  sync_status text check (sync_status in ('pending','synced','failed','disabled')) default 'pending',
  last_sync_at timestamp with time zone,
  
  -- Metadata
  tags text[],
  attachments jsonb default '[]',
  custom_fields jsonb default '{}',
  position int, -- For manual ordering
  completed_at timestamp with time zone,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  
  -- Constraints
  constraint check_assigned_user_is_member check (
    assigned_to is null or 
    project_id is null or
    exists (
      select 1 from project_members pm 
      where pm.project_id = tasks.project_id 
      and pm.user_id = tasks.assigned_to
    )
  )
);

-- Task-Goal Relationships
create table task_goals (
  task_id uuid references tasks(id) on delete cascade,
  goal_id uuid references goals(id) on delete cascade,
  contribution_weight float default 1.0 check (contribution_weight between 0 and 1),
  primary key (task_id, goal_id)
);

-- Notes (Enhanced for knowledge management)
create table notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  project_id uuid references projects(id) on delete cascade,
  task_id uuid references tasks(id) on delete cascade,
  
  title text,
  content text not null,
  content_type text check (content_type in ('markdown','plain','rich_text')) default 'markdown',
  
  -- AI & Search
  ai_summary text,
  ai_embeddings vector(1536),
  search_vector tsvector,
  
  tags text[],
  is_pinned boolean default false,
  is_archived boolean default false,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Events (Calendar integration)
create table events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  project_id uuid references projects(id) on delete cascade,
  
  title text not null,
  description text,
  location text,
  
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  all_day boolean default false,
  
  -- Recurrence
  recurrence_rule text, -- RFC 5545 RRULE
  recurrence_id uuid, -- Parent recurring event
  
  -- Integration
  external_id text,
  external_source text check (external_source in ('google_calendar','outlook','apple','manual')),
  
  -- Event metadata
  event_type text check (event_type in ('meeting','focus_time','break','deadline','reminder')),
  attendees jsonb default '[]',
  reminder_minutes int[],
  color text,
  
  status text check (status in ('confirmed','tentative','cancelled')) default 'confirmed',
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- ========================================
-- COLLABORATION TABLES
-- ========================================

-- Task Comments
create table task_comments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references tasks(id) on delete cascade not null,
  user_id uuid references users(id) on delete cascade not null,
  parent_comment_id uuid references task_comments(id) on delete cascade,
  
  content text not null,
  mentions uuid[], -- Array of user IDs mentioned
  is_edited boolean default false,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Task Activity Log
create table task_activities (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references tasks(id) on delete cascade not null,
  user_id uuid references users(id) on delete cascade not null,
  
  activity_type text not null check (activity_type in (
    'created','updated','completed','reopened','assigned','unassigned',
    'priority_changed','status_changed','moved_project','comment_added',
    'attachment_added','due_date_changed'
  )),
  
  old_value jsonb,
  new_value jsonb,
  
  created_at timestamp with time zone default now()
);

-- ========================================
-- ANALYTICS TABLES
-- ========================================

-- Analytics Events (for tracking all user actions)
create table analytics_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  session_id uuid,
  
  event_type text not null,
  event_category text,
  event_label text,
  event_value float,
  
  -- Context
  task_id uuid references tasks(id) on delete cascade,
  project_id uuid references projects(id) on delete cascade,
  
  metadata jsonb default '{}',
  user_agent text,
  ip_address inet,
  
  created_at timestamp with time zone default now()
);

-- Task Actions (specific tracking for prioritization)
create table task_actions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references tasks(id) on delete cascade not null,
  user_id uuid references users(id) on delete cascade not null,
  
  action_type text not null check (action_type in (
    'reorder','override_priority','accept_ai','reject_ai',
    'manual_schedule','defer','delegate','break_down'
  )),
  
  -- For measuring AI effectiveness
  ai_suggestion jsonb,
  user_choice jsonb,
  feedback text,
  
  created_at timestamp with time zone default now()
);

-- Focus Sessions (ADHD tracking)
create table focus_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  task_id uuid references tasks(id) on delete cascade,
  
  session_type text check (session_type in ('pomodoro','flow','deep_work','break')),
  planned_duration interval,
  actual_duration interval,
  
  started_at timestamp with time zone not null,
  ended_at timestamp with time zone,
  
  -- Interruption tracking
  interruptions int default 0,
  interruption_reasons text[],
  
  -- Productivity metrics
  productivity_rating int check (productivity_rating between 1 and 5),
  energy_level_start text,
  energy_level_end text,
  notes text,
  
  completed_successfully boolean,
  
  created_at timestamp with time zone default now()
);

-- Daily Summaries (for retention metrics)
create table daily_summaries (
  user_id uuid references users(id) on delete cascade,
  date date not null,
  
  tasks_created int default 0,
  tasks_completed int default 0,
  tasks_overdue int default 0,
  
  focus_time_minutes int default 0,
  break_time_minutes int default 0,
  
  ai_suggestions_accepted int default 0,
  ai_suggestions_rejected int default 0,
  manual_overrides int default 0,
  
  average_task_completion_time interval,
  productivity_score float,
  
  primary key (user_id, date)
);

-- ========================================
-- AI & AUTOMATION TABLES
-- ========================================

-- AI Chat History
create table ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  
  messages jsonb not null default '[]',
  context jsonb default '{}',
  model_used text,
  total_tokens int,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Workflow Templates
create table workflow_templates (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references users(id),
  
  name text not null,
  description text,
  template_type text check (template_type in ('personal','team','system')) default 'personal',
  
  trigger_conditions jsonb not null,
  actions jsonb not null,
  
  is_public boolean default false,
  usage_count int default 0,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- User Workflows (Active automations)
create table user_workflows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  template_id uuid references workflow_templates(id),
  
  name text not null,
  is_active boolean default true,
  configuration jsonb default '{}',
  
  last_triggered_at timestamp with time zone,
  trigger_count int default 0,
  
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================

-- Users
create index idx_users_email on users(email);
create index idx_users_created_at on users(created_at desc);

-- Tasks
create index idx_tasks_user_status on tasks(user_id, status) where status != 'done';
create index idx_tasks_assigned_status on tasks(assigned_to, status) where assigned_to is not null;
create index idx_tasks_project_priority on tasks(project_id, priority desc) where project_id is not null;
create index idx_tasks_due_date on tasks(due_date) where status not in ('done','cancelled');
create index idx_tasks_scheduled on tasks(scheduled_date, energy_level) where status = 'pending';
create index idx_tasks_external on tasks(external_source, external_id) where external_id is not null;
create index idx_tasks_parent on tasks(parent_task_id) where parent_task_id is not null;
create index idx_tasks_ai_update on tasks(last_ai_update) where ai_priority is not null;
create index idx_tasks_search on tasks using gin(to_tsvector('english', title || ' ' || coalesce(description, '')));

-- Notes
create index idx_notes_user on notes(user_id, created_at desc);
create index idx_notes_project on notes(project_id) where project_id is not null;
create index idx_notes_task on notes(task_id) where task_id is not null;
create index idx_notes_search on notes using gin(search_vector);

-- Events
create index idx_events_user_time on events(user_id, start_time);
create index idx_events_date on events(date(start_time));
create index idx_events_recurrence on events(recurrence_id) where recurrence_id is not null;

-- Analytics
create index idx_analytics_user_date on analytics_events(user_id, created_at desc);
create index idx_analytics_event_type on analytics_events(event_type, created_at desc);
create index idx_analytics_priority_overrides on analytics_events(event_type, created_at) 
  where event_type in ('reorder','override_priority','reject_ai');

-- Task Actions
create index idx_task_actions_task on task_actions(task_id, created_at desc);
create index idx_task_actions_user on task_actions(user_id, created_at desc);
create index idx_task_actions_type on task_actions(action_type, created_at desc);

-- Focus Sessions
create index idx_focus_sessions_user on focus_sessions(user_id, started_at desc);
create index idx_focus_sessions_task on focus_sessions(task_id) where task_id is not null;

-- Daily Summaries
create index idx_daily_summaries_user on daily_summaries(user_id, date desc);

-- Projects
create index idx_projects_created_by on projects(created_by);
create index idx_project_members_user on project_members(user_id);

-- Comments
create index idx_task_comments_task on task_comments(task_id, created_at);

-- ========================================
-- MATERIALIZED VIEWS FOR DASHBOARDS
-- ========================================

-- User Dashboard View
create materialized view user_dashboard as
select 
  u.id as user_id,
  u.display_name,
  
  -- Task metrics
  count(distinct t.id) filter (where t.status = 'pending') as pending_tasks,
  count(distinct t.id) filter (where t.status = 'in_progress') as in_progress_tasks,
  count(distinct t.id) filter (where date(t.due_date) = current_date and t.status != 'done') as due_today,
  count(distinct t.id) filter (where t.due_date < now() and t.status not in ('done','cancelled')) as overdue_tasks,
  
  -- Today's events
  count(distinct e.id) filter (where date(e.start_time) = current_date) as events_today,
  
  -- Weekly metrics
  count(distinct t.id) filter (where t.completed_at > now() - interval '7 days') as completed_this_week,
  
  -- AI metrics
  count(distinct ta.id) filter (where ta.action_type = 'accept_ai' and ta.created_at > now() - interval '7 days') as ai_accepted_week,
  count(distinct ta.id) filter (where ta.action_type = 'reject_ai' and ta.created_at > now() - interval '7 days') as ai_rejected_week,
  
  -- Focus metrics
  coalesce(sum(extract(epoch from fs.actual_duration)/60) filter (where date(fs.started_at) = current_date), 0)::int as focus_minutes_today,
  
  -- Productivity score (0-100)
  case 
    when count(distinct t.id) filter (where t.status = 'pending') = 0 then 100
    else round(100.0 * count(distinct t.id) filter (where t.status = 'done') / count(distinct t.id))
  end as productivity_score

from users u
left join tasks t on t.user_id = u.id
left join events e on e.user_id = u.id
left join task_actions ta on ta.user_id = u.id
left join focus_sessions fs on fs.user_id = u.id
group by u.id, u.display_name;

create unique index on user_dashboard(user_id);

-- Project Dashboard View
create materialized view project_dashboard as
select 
  p.id as project_id,
  p.name as project_name,
  p.created_by,
  
  count(distinct pm.user_id) as member_count,
  count(distinct t.id) as total_tasks,
  count(distinct t.id) filter (where t.status = 'done') as completed_tasks,
  count(distinct t.id) filter (where t.status = 'pending') as pending_tasks,
  count(distinct t.id) filter (where t.due_date < now() and t.status != 'done') as overdue_tasks,
  
  avg(extract(epoch from (t.completed_at - t.created_at))/3600) filter (where t.status = 'done') as avg_completion_hours,
  
  max(t.updated_at) as last_activity

from projects p
left join project_members pm on pm.project_id = p.id
left join tasks t on t.project_id = p.id
group by p.id, p.name, p.created_by;

create unique index on project_dashboard(project_id);

-- ========================================
-- ROW LEVEL SECURITY
-- ========================================

-- Enable RLS on all tables
alter table users enable row level security;
alter table user_preferences enable row level security;
alter table goals enable row level security;
alter table projects enable row level security;
alter table project_members enable row level security;
alter table tasks enable row level security;
alter table task_goals enable row level security;
alter table notes enable row level security;
alter table events enable row level security;
alter table task_comments enable row level security;
alter table task_activities enable row level security;
alter table analytics_events enable row level security;
alter table task_actions enable row level security;
alter table focus_sessions enable row level security;
alter table daily_summaries enable row level security;
alter table ai_conversations enable row level security;
alter table workflow_templates enable row level security;
alter table user_workflows enable row level security;

-- User Policies
create policy "Users can view their own profile"
  on users for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Service role can manage all users"
  on users for all
  using (auth.jwt() ->> 'role' = 'service_role');

-- User Preferences Policies
create policy "Users can manage their own preferences"
  on user_preferences for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Goals Policies
create policy "Users can manage their own goals"
  on goals for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Project Policies
create policy "Users can create projects"
  on projects for insert
  with check (auth.uid() = created_by);

create policy "Project members can view projects"
  on projects for select
  using (
    created_by = auth.uid()
    or exists (
      select 1 from project_members pm
      where pm.project_id = projects.id
      and pm.user_id = auth.uid()
    )
  );

create policy "Project owners and admins can update"
  on projects for update
  using (
    created_by = auth.uid()
    or exists (
      select 1 from project_members pm
      where pm.project_id = projects.id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','admin')
    )
  )
  with check (
    created_by = auth.uid()
    or exists (
      select 1 from project_members pm
      where pm.project_id = projects.id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','admin')
    )
  );

create policy "Only project owners can delete"
  on projects for delete
  using (created_by = auth.uid());

-- Project Members Policies
create policy "Members can view project membership"
  on project_members for select
  using (
    user_id = auth.uid()
    or exists (
      select 1 from project_members pm2
      where pm2.project_id = project_members.project_id
      and pm2.user_id = auth.uid()
    )
  );

create policy "Project owners and admins can manage members"
  on project_members for insert
  with check (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and (
        p.created_by = auth.uid()
        or exists (
          select 1 from project_members pm
          where pm.project_id = p.id
          and pm.user_id = auth.uid()
          and pm.role in ('owner','admin')
        )
      )
    )
  );

create policy "Project owners and admins can update members"
  on project_members for update
  using (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and (
        p.created_by = auth.uid()
        or exists (
          select 1 from project_members pm
          where pm.project_id = p.id
          and pm.user_id = auth.uid()
          and pm.role in ('owner','admin')
        )
      )
    )
  );

create policy "Project owners and admins can remove members"
  on project_members for delete
  using (
    exists (
      select 1 from projects p
      where p.id = project_members.project_id
      and (
        p.created_by = auth.uid()
        or exists (
          select 1 from project_members pm
          where pm.project_id = p.id
          and pm.user_id = auth.uid()
          and pm.role in ('owner','admin')
        )
      )
    )
  );

-- Task Policies
create policy "Users can view their own tasks and project tasks"
  on tasks for select
  using (
    user_id = auth.uid()
    or assigned_to = auth.uid()
    or (project_id is not null and exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
    ))
  );

create policy "Users can create personal tasks"
  on tasks for insert
  with check (
    user_id = auth.uid()
    and (
      project_id is null
      or exists (
        select 1 from project_members pm
        where pm.project_id = tasks.project_id
        and pm.user_id = auth.uid()
        and pm.role in ('owner','admin','editor')
      )
    )
  );

create policy "Users and editors can update tasks"
  on tasks for update
  using (
    user_id = auth.uid()
    or assigned_to = auth.uid()
    or (project_id is not null and exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','admin','editor')
    ))
  );

create policy "Users and project owners can delete tasks"
  on tasks for delete
  using (
    user_id = auth.uid()
    or (project_id is not null and exists (
      select 1 from project_members pm
      where pm.project_id = tasks.project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','admin')
    ))
  );

-- Task-Goal Policies
create policy "Users can manage task-goal relationships"
  on task_goals for all
  using (
    exists (
      select 1 from tasks t
      where t.id = task_goals.task_id
      and t.user_id = auth.uid()
    )
  );

-- Notes Policies
create policy "Users can manage their own notes"
  on notes for all
  using (
    user_id = auth.uid()
    or (project_id is not null and exists (
      select 1 from project_members pm
      where pm.project_id = notes.project_id
      and pm.user_id = auth.uid()
    ))
  )
  with check (
    user_id = auth.uid()
    or (project_id is not null and exists (
      select 1 from project_members pm
      where pm.project_id = notes.project_id
      and pm.user_id = auth.uid()
      and pm.role in ('owner','admin','editor')
    ))
  );

-- Events Policies
create policy "Users can manage their own events"
  on events for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Task Comments Policies
create policy "Project members can view comments"
  on task_comments for select
  using (
    exists (
      select 1 from tasks t
      left join project_members pm on pm.project_id = t.project_id
      where t.id = task_comments.task_id
      and (t.user_id = auth.uid() or pm.user_id = auth.uid())
    )
  );

create policy "Project members can create comments"
  on task_comments for insert
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from tasks t
      left join project_members pm on pm.project_id = t.project_id
      where t.id = task_comments.task_id
      and (t.user_id = auth.uid() or pm.user_id = auth.uid())
    )
  );

create policy "Users can update their own comments"
  on task_comments for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can delete their own comments"
  on task_comments for delete
  using (user_id = auth.uid());

-- Task Activities Policies
create policy "Project members can view task activities"
  on task_activities for select
  using (
    exists (
      select 1 from tasks t
      left join project_members pm on pm.project_id = t.project_id
      where t.id = task_activities.task_id
      and (t.user_id = auth.uid() or pm.user_id = auth.uid())
    )
  );

create policy "System can create task activities"
  on task_activities for insert
  with check (user_id = auth.uid());

-- Analytics Events Policies
create policy "Users can view their own analytics"
  on analytics_events for select
  using (user_id = auth.uid());

create policy "System can write analytics"
  on analytics_events for insert
  with check (true);

-- Task Actions Policies
create policy "Users can view their own task actions"
  on task_actions for select
  using (user_id = auth.uid());

create policy "Users can create their own task actions"
  on task_actions for insert
  with check (user_id = auth.uid());

-- Focus Sessions Policies
create policy "Users can manage their own focus sessions"
  on focus_sessions for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Daily Summaries Policies
create policy "Users can view their own summaries"
  on daily_summaries for select
  using (user_id = auth.uid());

create policy "System can manage daily summaries"
  on daily_summaries for all
  using (auth.jwt() ->> 'role' = 'service_role');

-- AI Conversations Policies
create policy "Users can manage their own AI conversations"
  on ai_conversations for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Workflow Templates Policies
create policy "Users can view public and own templates"
  on workflow_templates for select
  using (
    is_public = true
    or created_by = auth.uid()
  );

create policy "Users can create templates"
  on workflow_templates for insert
  with check (created_by = auth.uid());

create policy "Users can update own templates"
  on workflow_templates for update
  using (created_by = auth.uid())
  with check (created_by = auth.uid());

create policy "Users can delete own templates"
  on workflow_templates for delete
  using (created_by = auth.uid());

-- User Workflows Policies
create policy "Users can manage their own workflows"
  on user_workflows for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ========================================
-- FUNCTIONS & TRIGGERS
-- ========================================

-- Update timestamp trigger
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply to relevant tables
create trigger update_users_timestamp before update on users
  for each row execute function update_updated_at();
create trigger update_user_preferences_timestamp before update on user_preferences
  for each row execute function update_updated_at();
create trigger update_goals_timestamp before update on goals
  for each row execute function update_updated_at();
create trigger update_projects_timestamp before update on projects
  for each row execute function update_updated_at();
create trigger update_tasks_timestamp before update on tasks
  for each row execute function update_updated_at();
create trigger update_notes_timestamp before update on notes
  for each row execute function update_updated_at();
create trigger update_events_timestamp before update on events
  for each row execute function update_updated_at();
create trigger update_task_comments_timestamp before update on task_comments
  for each row execute function update_updated_at();
create trigger update_ai_conversations_timestamp before update on ai_conversations
  for each row execute function update_updated_at();
create trigger update_workflow_templates_timestamp before update on workflow_templates
  for each row execute function update_updated_at();
create trigger update_user_workflows_timestamp before update on user_workflows
  for each row execute function update_updated_at();

-- Auto-create user preferences on signup
create or replace function create_user_preferences()
returns trigger as $$
begin
  insert into user_preferences (user_id)
  values (new.id)
  on conflict do nothing;
  return new;
end;
$$ language plpgsql;

create trigger create_user_preferences_trigger
  after insert on users
  for each row execute function create_user_preferences();

-- Log task activities
create or replace function log_task_activity()
returns trigger as $$
begin
  if TG_OP = 'UPDATE' then
    -- Log significant changes
    if old.status is distinct from new.status then
      insert into task_activities (task_id, user_id, activity_type, old_value, new_value)
      values (new.id, auth.uid(), 'status_changed', 
              to_jsonb(old.status), to_jsonb(new.status));
    end if;
    
    if old.assigned_to is distinct from new.assigned_to then
      insert into task_activities (task_id, user_id, activity_type, old_value, new_value)
      values (new.id, auth.uid(), 
              case when new.assigned_to is null then 'unassigned' else 'assigned' end,
              to_jsonb(old.assigned_to), to_jsonb(new.assigned_to));
    end if;
    
    if old.priority is distinct from new.priority then
      insert into task_activities (task_id, user_id, activity_type, old_value, new_value)
      values (new.id, auth.uid(), 'priority_changed',
              to_jsonb(old.priority), to_jsonb(new.priority));
    end if;
    
    if old.due_date is distinct from new.due_date then
      insert into task_activities (task_id, user_id, activity_type, old_value, new_value)
      values (new.id, auth.uid(), 'due_date_changed',
              to_jsonb(old.due_date), to_jsonb(new.due_date));
    end if;
    
    if old.project_id is distinct from new.project_id then
      insert into task_activities (task_id, user_id, activity_type, old_value, new_value)
      values (new.id, auth.uid(), 'moved_project',
              to_jsonb(old.project_id), to_jsonb(new.project_id));
    end if;
  elsif TG_OP = 'INSERT' then
    insert into task_activities (task_id, user_id, activity_type, new_value)
    values (new.id, auth.uid(), 'created', row_to_json(new)::jsonb);
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger log_task_activity_trigger
  after insert or update on tasks
  for each row execute function log_task_activity();

-- Update search vector for notes
create or replace function update_note_search_vector()
returns trigger as $$
begin
  new.search_vector := to_tsvector('english', 
    coalesce(new.title, '') || ' ' || new.content);
  return new;
end;
$$ language plpgsql;

create trigger update_note_search_vector_trigger
  before insert or update of title, content on notes
  for each row execute function update_note_search_vector();

-- Track completed tasks
create or replace function track_task_completion()
returns trigger as $$
begin
  if new.status = 'done' and old.status != 'done' then
    new.completed_at := now();
  elsif new.status != 'done' and old.status = 'done' then
    new.completed_at := null;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger track_task_completion_trigger
  before update of status on tasks
  for each row execute function track_task_completion();

-- Calculate goal progress
create or replace function update_goal_progress()
returns trigger as $$
begin
  update goals
  set progress_percentage = (
    select round(100.0 * count(*) filter (where t.status = 'done') / nullif(count(*), 0))::int
    from task_goals tg
    join tasks t on t.id = tg.task_id
    where tg.goal_id = goals.id
  )
  where id in (
    select goal_id from task_goals where task_id = new.id
  );
  return new;
end;
$$ language plpgsql;

create trigger update_goal_progress_trigger
  after update of status on tasks
  for each row execute function update_goal_progress();

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Get user's energy level at a specific time
create or replace function get_user_energy_level(
  p_user_id uuid,
  p_time timestamp with time zone default now()
) returns text as $$
declare
  v_hour int;
  v_pattern jsonb;
begin
  v_hour := extract(hour from p_time);
  
  select daily_energy_pattern into v_pattern
  from user_preferences
  where user_id = p_user_id;
  
  if v_pattern is null then
    return 'medium';
  end if;
  
  case
    when v_hour between 6 and 11 then
      return v_pattern->>'morning';
    when v_hour between 12 and 17 then
      return v_pattern->>'afternoon';
    else
      return v_pattern->>'evening';
  end case;
end;
$$ language plpgsql;

-- Get recommended tasks based on energy level
create or replace function get_recommended_tasks(
  p_user_id uuid,
  p_limit int default 5
) returns table (
  task_id uuid,
  title text,
  priority int,
  energy_level text,
  focus_type text,
  ai_reasoning text
) as $$
begin
  return query
  select 
    t.id,
    t.title,
    coalesce(t.ai_priority, t.priority) as priority,
    t.energy_level,
    t.focus_type,
    t.ai_reasoning
  from tasks t
  where t.user_id = p_user_id
    and t.status = 'pending'
    and (t.energy_level = get_user_energy_level(p_user_id) or t.energy_level is null)
  order by 
    coalesce(t.ai_priority, t.priority) desc,
    t.due_date asc nulls last
  limit p_limit;
end;
$$ language plpgsql;

-- Break down task into subtasks (stub for AI integration)
create or replace function break_down_task(
  p_task_id uuid
) returns setof tasks as $$
declare
  v_parent_task tasks%rowtype;
begin
  select * into v_parent_task from tasks where id = p_task_id;
  
  -- This is a stub - in production, this would call an AI service
  -- For now, return empty set
  return;
end;
$$ language plpgsql;

-- ========================================
-- SCHEDULED JOBS (using pg_cron)
-- ========================================

-- Daily summary aggregation (runs at 2 AM every day)
select cron.schedule('daily-summary', '0 2 * * *', $$
  insert into daily_summaries (
    user_id, date,
    tasks_created, tasks_completed, tasks_overdue,
    focus_time_minutes, break_time_minutes,
    ai_suggestions_accepted, ai_suggestions_rejected, manual_overrides,
    average_task_completion_time, productivity_score
  )
  select 
    u.id,
    current_date - interval '1 day',
    count(distinct t.id) filter (where date(t.created_at) = current_date - interval '1 day'),
    count(distinct t.id) filter (where date(t.completed_at) = current_date - interval '1 day'),
    count(distinct t.id) filter (where t.due_date < current_date and t.status != 'done'),
    coalesce(sum(extract(epoch from fs.actual_duration)/60) filter (where date(fs.started_at) = current_date - interval '1 day'), 0)::int,
    coalesce(sum(extract(epoch from fs.actual_duration)/60) filter (where fs.session_type = 'break' and date(fs.started_at) = current_date - interval '1 day'), 0)::int,
    count(distinct ta.id) filter (where ta.action_type = 'accept_ai' and date(ta.created_at) = current_date - interval '1 day'),
    count(distinct ta.id) filter (where ta.action_type = 'reject_ai' and date(ta.created_at) = current_date - interval '1 day'),
    count(distinct ta.id) filter (where ta.action_type in ('reorder','override_priority') and date(ta.created_at) = current_date - interval '1 day'),
    avg(t.completed_at - t.created_at) filter (where date(t.completed_at) = current_date - interval '1 day'),
    case 
      when count(distinct t.id) = 0 then 100
      else round(100.0 * count(distinct t.id) filter (where t.status = 'done') / count(distinct t.id))
    end
  from users u
  left join tasks t on t.user_id = u.id
  left join focus_sessions fs on fs.user_id = u.id
  left join task_actions ta on ta.user_id = u.id
  group by u.id
  on conflict (user_id, date) do update
  set 
    tasks_created = excluded.tasks_created,
    tasks_completed = excluded.tasks_completed,
    tasks_overdue = excluded.tasks_overdue,
    focus_time_minutes = excluded.focus_time_minutes,
    break_time_minutes = excluded.break_time_minutes,
    ai_suggestions_accepted = excluded.ai_suggestions_accepted,
    ai_suggestions_rejected = excluded.ai_suggestions_rejected,
    manual_overrides = excluded.manual_overrides,
    average_task_completion_time = excluded.average_task_completion_time,
    productivity_score = excluded.productivity_score;
$$);

-- Refresh materialized views (every hour)
select cron.schedule('refresh-views', '0 * * * *', $$
  refresh materialized view concurrently user_dashboard;
  refresh materialized view concurrently project_dashboard;
$$);

-- ========================================
-- INITIAL DATA & PERMISSIONS
-- ========================================

-- Grant permissions for service role
grant all on all tables in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant all on all functions in schema public to service_role;