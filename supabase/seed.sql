-- VerVida Enhanced Seed Data
-- Includes realistic ADHD-related data, AI suggestions, and analytics

-- Clean existing data
truncate table daily_summaries cascade;
truncate table focus_sessions cascade;
truncate table task_actions cascade;
truncate table analytics_events cascade;
truncate table task_activities cascade;
truncate table task_comments cascade;
truncate table events cascade;
truncate table notes cascade;
truncate table task_goals cascade;
truncate table tasks cascade;
truncate table project_members cascade;
truncate table projects cascade;
truncate table goals cascade;
truncate table user_preferences cascade;
truncate table users cascade;

-- Create test users (these would normally come from Supabase Auth)
-- In production, these IDs would match auth.users table
insert into users (id, email, display_name, onboarding_completed) values
  ('11111111-1111-1111-1111-111111111111', 'alex@vervida.app', 'Alex Chen', true),
  ('22222222-2222-2222-2222-222222222222', 'jordan@vervida.app', 'Jordan Smith', true),
  ('33333333-3333-3333-3333-333333333333', 'sam@vervida.app', 'Sam Johnson', true),
  ('44444444-4444-4444-4444-444444444444', 'taylor@vervida.app', 'Taylor Davis', false);

-- Set up user preferences with ADHD-friendly settings
insert into user_preferences (user_id, time_blindness_alerts, hyperfocus_break_interval, theme, reduced_animations, daily_energy_pattern, ai_aggressiveness) values
  ('11111111-1111-1111-1111-111111111111', true, '30 minutes', 'dark', true, 
   '{"morning": "low", "afternoon": "high", "evening": "medium"}', 'aggressive'),
  ('22222222-2222-2222-2222-222222222222', true, '45 minutes', 'system', false,
   '{"morning": "high", "afternoon": "medium", "evening": "low"}', 'balanced'),
  ('33333333-3333-3333-3333-333333333333', false, '60 minutes', 'light', false,
   '{"morning": "medium", "afternoon": "high", "evening": "high"}', 'conservative'),
  ('44444444-4444-4444-4444-444444444444', true, '25 minutes', 'dark', true,
   '{"morning": "variable", "afternoon": "low", "evening": "medium"}', 'balanced');

-- Create goals for Alex
insert into goals (id, user_id, title, description, goal_type, target_date, status, progress_percentage) values
  ('g1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
   'Complete Q1 Product Launch', 'Ship new ADHD productivity features', 'quarterly', 
   current_date + interval '2 months', 'active', 35),
  ('g1111111-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
   'Establish Morning Routine', 'Create consistent wake-up and work start routine', 'monthly',
   current_date + interval '3 weeks', 'active', 60),
  ('g1111111-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
   'Daily Focus Sessions', 'Complete at least 3 focused work sessions', 'daily',
   current_date, 'active', 33);

-- Create goals for Jordan
insert into goals (id, user_id, title, goal_type, target_date, status) values
  ('g2222222-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   'Client Project Delivery', 'weekly', current_date + interval '5 days', 'active'),
  ('g2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
   'Reduce Context Switching', 'daily', current_date, 'active');

-- Create projects
insert into projects (id, name, description, created_by, color, icon) values
  ('p1111111-1111-1111-1111-111111111111', 'Morning Routine Optimization',
   'Personal project to establish ADHD-friendly morning habits', 
   '11111111-1111-1111-1111-111111111111', '#10B981', '🌅'),
  ('p2222222-2222-2222-2222-222222222222', 'Q1 Product Sprint',
   'Team sprint for new AI-driven features',
   '22222222-2222-2222-2222-222222222222', '#3B82F6', '🚀'),
  ('p3333333-3333-3333-3333-333333333333', 'Client: Acme Corp Redesign',
   'Website redesign project with accessibility focus',
   '22222222-2222-2222-2222-222222222222', '#F59E0B', '🎨');

-- Set up project memberships
insert into project_members (project_id, user_id, role) values
  -- Alex's personal project
  ('p1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'owner'),
  -- Team sprint project
  ('p2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'owner'),
  ('p2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'editor'),
  ('p2222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'editor'),
  -- Client project
  ('p3333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'owner'),
  ('p3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'admin'),
  ('p3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'viewer');

-- Create tasks with AI suggestions and ADHD metadata
insert into tasks (
  id, user_id, assigned_to, project_id, title, description, status, priority, 
  urgency, importance, due_date, scheduled_date,
  ai_priority, ai_reasoning, ai_suggested_date, ai_confidence_score,
  energy_level, focus_type, estimated_duration, is_routine, tags
) values
  -- Alex's morning routine tasks
  ('t1111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111', 
   '11111111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111',
   'Review daily priorities', 'Check calendar, emails, and set top 3 tasks for the day',
   'pending', 1, 'medium', 'high', current_date + interval '1 day', current_date + interval '1 day',
   3, 'High importance for ADHD management, helps reduce decision fatigue throughout the day',
   current_date + interval '1 day', 0.92,
   'low', 'administrative', '15 minutes', true, ARRAY['routine', 'morning', 'planning']),
   
  ('t1111111-0002-0002-0002-000000000002', '11111111-1111-1111-1111-111111111111',
   '11111111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111',
   'Morning meditation', '10-minute guided meditation for focus',
   'done', 2, 'low', 'high', current_date, current_date,
   3, 'Helps with ADHD symptom management and improves focus for the day',
   current_date, 0.88,
   'low', 'deep', '10 minutes', true, ARRAY['routine', 'morning', 'wellness']),
   
  -- Team sprint tasks
  ('t2222222-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   '11111111-1111-1111-1111-111111111111', 'p2222222-2222-2222-2222-222222222222',
   'Implement AI task prioritization algorithm', 'Core algorithm for automatic task sorting based on user context',
   'in_progress', 4, 'high', 'high', current_date + interval '3 days', current_date + interval '1 day',
   4, 'Critical path item for MVP, blocks other features',
   current_date + interval '1 day', 0.95,
   'high', 'deep', '4 hours', false, ARRAY['ai', 'backend', 'critical']),
   
  ('t2222222-0002-0002-0002-000000000002', '22222222-2222-2222-2222-222222222222',
   '33333333-3333-3333-3333-333333333333', 'p2222222-2222-2222-2222-222222222222',
   'Design ADHD-friendly UI components', 'Create component library with reduced cognitive load',
   'in_progress', 3, 'high', 'high', current_date + interval '2 days', current_date,
   4, 'Essential for target audience, impacts user retention',
   current_date, 0.91,
   'medium', 'creative', '3 hours', false, ARRAY['design', 'ui', 'accessibility']),
   
  ('t2222222-0003-0003-0003-000000000003', '22222222-2222-2222-2222-222222222222',
   '22222222-2222-2222-2222-222222222222', 'p2222222-2222-2222-2222-222222222222',
   'Set up analytics tracking', 'Implement Mixpanel for user behavior tracking',
   'pending', 2, 'medium', 'medium', current_date + interval '5 days', current_date + interval '3 days',
   2, 'Important for measuring success metrics but not blocking',
   current_date + interval '4 days', 0.78,
   'medium', 'administrative', '2 hours', false, ARRAY['analytics', 'setup']),
   
  -- Client project tasks
  ('t3333333-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   '33333333-3333-3333-3333-333333333333', 'p3333333-3333-3333-3333-333333333333',
   'Accessibility audit', 'Complete WCAG 2.1 AA compliance audit',
   'pending', 4, 'high', 'high', current_date + interval '2 days', current_date + interval '1 day',
   4, 'Client requirement, must be done before design work',
   current_date + interval '1 day', 0.94,
   'high', 'deep', '3 hours', false, ARRAY['accessibility', 'audit', 'client']),
   
  -- Subtasks (broken down by AI)
  ('t1111111-0003-0003-0003-000000000003', '11111111-1111-1111-1111-111111111111',
   '11111111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111',
   'Set up morning alarm routine', 'Configure gradual wake-up alarms',
   'done', 1, 'low', 'medium', current_date - interval '1 day', current_date - interval '1 day',
   2, 'Subtask of morning routine - foundational step',
   current_date - interval '1 day', 0.85,
   'low', 'administrative', '5 minutes', false, ARRAY['setup', 'routine']),
   
  -- Personal tasks without project
  ('t4444444-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   '11111111-1111-1111-1111-111111111111', null,
   'Doctor appointment', 'ADHD medication follow-up',
   'pending', 4, 'high', 'high', current_date + interval '7 days', current_date + interval '7 days',
   4, 'Health-related, time-sensitive appointment',
   current_date + interval '7 days', 0.99,
   'medium', 'administrative', '1 hour', false, ARRAY['health', 'appointment']);

-- Set parent-child relationships for subtasks
update tasks set parent_task_id = 't1111111-0001-0001-0001-000000000001' 
where id = 't1111111-0003-0003-0003-000000000003';

-- Link tasks to goals
insert into task_goals (task_id, goal_id, contribution_weight) values
  ('t1111111-0001-0001-0001-000000000001', 'g1111111-2222-2222-2222-222222222222', 1.0),
  ('t1111111-0001-0001-0001-000000000001', 'g1111111-3333-3333-3333-333333333333', 0.3),
  ('t1111111-0002-0002-0002-000000000002', 'g1111111-2222-2222-2222-222222222222', 0.8),
  ('t1111111-0002-0002-0002-000000000002', 'g1111111-3333-3333-3333-333333333333', 0.2),
  ('t2222222-0001-0001-0001-000000000001', 'g1111111-1111-1111-1111-111111111111', 0.5),
  ('t2222222-0002-0002-0002-000000000002', 'g1111111-1111-1111-1111-111111111111', 0.3),
  ('t3333333-0001-0001-0001-000000000001', 'g2222222-1111-1111-1111-111111111111', 0.7);

-- Create notes
insert into notes (id, user_id, project_id, task_id, title, content, tags, is_pinned) values
  ('n1111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   'p1111111-1111-1111-1111-111111111111', null,
   'Morning Routine Research', 
   '# ADHD Morning Routine Best Practices\n\n## Key Points\n- Start with easiest task to build momentum\n- Use visual timers for time blindness\n- Prepare night before to reduce decisions\n- Keep routine consistent but flexible\n\n## Resources\n- [How to ADHD YouTube Channel](https://youtube.com/@HowtoADHD)\n- Book: "Atomic Habits" by James Clear',
   ARRAY['adhd', 'research', 'routine'], true),
   
  ('n2222222-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   'p2222222-2222-2222-2222-222222222222', 't2222222-0001-0001-0001-000000000001',
   'AI Prioritization Algorithm Notes',
   '## Algorithm Design\n\n1. Factors to consider:\n   - Due date proximity\n   - User energy levels\n   - Task dependencies\n   - Goal alignment\n   - Historical completion patterns\n\n2. ML Model: Using GPT-4 for reasoning, O1-mini for quick scoring',
   ARRAY['technical', 'ai', 'algorithm'], false),
   
  ('n3333333-0001-0001-0001-000000000001', '33333333-3333-3333-3333-333333333333',
   'p3333333-3333-3333-3333-333333333333', null,
   'Client Meeting Notes',
   'Met with Acme Corp team:\n- Priority: Accessibility for neurodiverse users\n- Timeline: 6 weeks\n- Budget approved for additional a11y testing\n- Weekly check-ins on Thursdays',
   ARRAY['client', 'meeting', 'requirements'], false);

-- Create events
insert into events (id, user_id, project_id, title, description, start_time, end_time, event_type, reminder_minutes, all_day) values
  ('e1111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   'p2222222-2222-2222-2222-222222222222',
   'Sprint Planning', 'Q1 Sprint planning session with team',
   current_date + interval '2 days' + interval '10 hours',
   current_date + interval '2 days' + interval '11 hours 30 minutes',
   'meeting', ARRAY[15, 60], false),
   
  ('e1111111-0002-0002-0002-000000000002', '11111111-1111-1111-1111-111111111111',
   null, 'Focus Block', 'Deep work on AI algorithm',
   current_date + interval '1 day' + interval '14 hours',
   current_date + interval '1 day' + interval '16 hours',
   'focus_time', ARRAY[5], false),
   
  ('e2222222-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   'p3333333-3333-3333-3333-333333333333',
   'Client Check-in', 'Weekly Acme Corp status update',
   current_date + interval '3 days' + interval '15 hours',
   current_date + interval '3 days' + interval '15 hours 30 minutes',
   'meeting', ARRAY[10], false),
   
  ('e1111111-0003-0003-0003-000000000003', '11111111-1111-1111-1111-111111111111',
   null, 'Medication Reminder', 'Take afternoon ADHD medication',
   current_date + interval '13 hours',
   current_date + interval '13 hours 5 minutes',
   'reminder', ARRAY[0], false);

-- Create task comments for collaboration
insert into task_comments (id, task_id, user_id, content, mentions) values
  ('c1111111-0001-0001-0001-000000000001', 't2222222-0001-0001-0001-000000000001',
   '22222222-2222-2222-2222-222222222222',
   'Hey @Alex, I''ve started the basic framework. Can you review the scoring algorithm when you get a chance?',
   ARRAY['11111111-1111-1111-1111-111111111111']),
   
  ('c1111111-0002-0002-0002-000000000002', 't2222222-0001-0001-0001-000000000001',
   '11111111-1111-1111-1111-111111111111',
   'Looks good! I think we should add energy level matching. ADHD users often struggle with high-cognitive tasks during low energy.',
   null),
   
  ('c2222222-0001-0001-0001-000000000001', 't2222222-0002-0002-0002-000000000002',
   '33333333-3333-3333-3333-333333333333',
   'I''ve created some initial mockups. Key principles: reduce visual clutter, clear hierarchy, progress indicators everywhere.',
   null);

-- Create task actions (for analytics)
insert into task_actions (id, task_id, user_id, action_type, ai_suggestion, user_choice) values
  ('ta111111-0001-0001-0001-000000000001', 't1111111-0001-0001-0001-000000000001',
   '11111111-1111-1111-1111-111111111111', 'accept_ai',
   '{"priority": 3, "scheduled_date": "' || to_char(current_date + interval '1 day', 'YYYY-MM-DD') || '"}',
   '{"accepted": true}'),
   
  ('ta111111-0002-0002-0002-000000000002', 't2222222-0003-0003-0003-000000000003',
   '22222222-2222-2222-2222-222222222222', 'override_priority',
   '{"priority": 3}',
   '{"priority": 2, "reason": "Needed for investor demo"}'),
   
  ('ta111111-0003-0003-0003-000000000003', 't1111111-0002-0002-0002-000000000002',
   '11111111-1111-1111-1111-111111111111', 'reorder',
   null,
   '{"moved_from": 3, "moved_to": 1}');

-- Create focus sessions
insert into focus_sessions (
  id, user_id, task_id, session_type, planned_duration, actual_duration,
  started_at, ended_at, interruptions, productivity_rating, energy_level_start,
  energy_level_end, completed_successfully, notes
) values
  ('fs111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   't1111111-0002-0002-0002-000000000002', 'pomodoro', '25 minutes', '25 minutes',
   current_date - interval '1 day' + interval '9 hours',
   current_date - interval '1 day' + interval '9 hours 25 minutes',
   0, 5, 'low', 'medium', true, 'Great session, meditation really helped'),
   
  ('fs111111-0002-0002-0002-000000000002', '11111111-1111-1111-1111-111111111111',
   't2222222-0001-0001-0001-000000000001', 'deep_work', '2 hours', '1 hour 45 minutes',
   current_date - interval '8 hours',
   current_date - interval '6 hours 15 minutes',
   2, 3, 'high', 'medium', false, 'Got interrupted by Slack, lost focus'),
   
  ('fs222222-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   't2222222-0003-0003-0003-000000000003', 'flow', '3 hours', '3 hours 30 minutes',
   current_date - interval '5 hours',
   current_date - interval '1 hour 30 minutes',
   0, 5, 'high', 'high', true, 'In the zone! Completed more than expected');

-- Create analytics events
insert into analytics_events (
  user_id, event_type, event_category, event_label, event_value, task_id, project_id, metadata
) values
  ('11111111-1111-1111-1111-111111111111', 'task_completed', 'task', 'morning_routine', 1,
   't1111111-0002-0002-0002-000000000002', 'p1111111-1111-1111-1111-111111111111',
   '{"time_to_complete": "10 minutes", "energy_level": "low"}'),
   
  ('11111111-1111-1111-1111-111111111111', 'session_started', 'focus', 'pomodoro', 25,
   null, null, '{"scheduled": true}'),
   
  ('22222222-2222-2222-2222-222222222222', 'priority_override', 'task', 'manual_change', 1,
   't2222222-0003-0003-0003-000000000003', 'p2222222-2222-2222-2222-222222222222',
   '{"from": 3, "to": 2, "reason": "demo"}'),
   
  ('33333333-3333-3333-3333-333333333333', 'page_view', 'navigation', 'dashboard', null,
   null, null, '{"referrer": "login", "time_on_page": 45}');

-- Create daily summaries for the last week
insert into daily_summaries (
  user_id, date, tasks_created, tasks_completed, tasks_overdue,
  focus_time_minutes, break_time_minutes, ai_suggestions_accepted,
  ai_suggestions_rejected, manual_overrides, productivity_score
)
select 
  '11111111-1111-1111-1111-111111111111',
  current_date - (n || ' days')::interval,
  2 + (random() * 3)::int,
  1 + (random() * 2)::int,
  (random() * 2)::int,
  30 + (random() * 120)::int,
  10 + (random() * 30)::int,
  2 + (random() * 3)::int,
  (random() * 2)::int,
  (random() * 2)::int,
  60 + (random() * 40)::int
from generate_series(1, 7) as n;

-- Create AI conversation history
insert into ai_conversations (id, user_id, messages, model_used, total_tokens) values
  ('ai111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   '[
     {"role": "user", "content": "I''m feeling overwhelmed with all my tasks today"},
     {"role": "assistant", "content": "I understand. Let''s break this down. Based on your energy pattern, you''re in a low energy morning. I suggest starting with these 3 simple tasks to build momentum..."},
     {"role": "user", "content": "That helps, can you schedule my deep work for this afternoon?"},
     {"role": "assistant", "content": "I''ve rescheduled your deep work tasks to 2-4 PM when your energy is typically highest. I''ve also added a 15-minute break between them to prevent hyperfocus fatigue."}
   ]',
   'gpt-4', 523);

-- Create workflow templates
insert into workflow_templates (id, created_by, name, description, template_type, trigger_conditions, actions, is_public) values
  ('wt111111-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111',
   'ADHD Morning Routine', 'Automated morning task creation and scheduling',
   'personal',
   '{"type": "time", "value": "07:00", "days": ["mon","tue","wed","thu","fri"]}',
   '[
     {"type": "create_task", "title": "Review priorities", "duration": "15min"},
     {"type": "create_task", "title": "Morning meditation", "duration": "10min"},
     {"type": "send_notification", "message": "Good morning! Your routine is ready"}
   ]',
   true),
   
  ('wt222222-0001-0001-0001-000000000001', '22222222-2222-2222-2222-222222222222',
   'Sprint Task Breakdown', 'Automatically break down large tasks',
   'team',
   '{"type": "task_created", "condition": {"estimated_duration": ">4hours"}}',
   '[
     {"type": "ai_breakdown", "model": "gpt-4"},
     {"type": "create_subtasks"},
     {"type": "notify_assignee"}
   ]',
   false);

-- Create active user workflows
insert into user_workflows (user_id, template_id, name, is_active, last_triggered_at, trigger_count) values
  ('11111111-1111-1111-1111-111111111111', 'wt111111-0001-0001-0001-000000000001',
   'My Morning Routine', true, current_date + interval '7 hours', 15),
  ('22222222-2222-2222-2222-222222222222', 'wt222222-0001-0001-0001-000000000001',
   'Auto Task Breakdown', true, current_date - interval '2 hours', 8);

-- Update completed_at for done tasks
update tasks set completed_at = current_date - interval '2 hours' where status = 'done';

-- Generate realistic external integration data
update tasks set 
  external_id = 'issue-' || substring(id::text from 1 for 8),
  external_source = 'github',
  external_url = 'https://github.com/vervida/app/issues/' || substring(id::text from 1 for 4),
  sync_status = 'synced',
  last_sync_at = current_date - interval '1 hour'
where project_id = 'p2222222-2222-2222-2222-222222222222'
  and random() > 0.5;

-- Add some recurring events
update events set
  recurrence_rule = 'FREQ=DAILY;BYHOUR=13;BYMINUTE=0',
  recurrence_id = 'e1111111-0003-0003-0003-000000000003'
where id = 'e1111111-0003-0003-0003-000000000003';

-- Create completed tasks for analytics history
insert into tasks (
  user_id, title, status, priority, completed_at, created_at,
  energy_level, focus_type, estimated_duration, actual_duration
)
select
  '11111111-1111-1111-1111-111111111111',
  'Historical task ' || n,
  'done',
  1 + (random() * 3)::int,
  current_date - (n || ' days')::interval + (random() * 8 || ' hours')::interval,
  current_date - ((n + 1) || ' days')::interval,
  (ARRAY['low','medium','high'])[1 + (random() * 2)::int],
  (ARRAY['deep','shallow','creative','administrative'])[1 + (random() * 3)::int],
  ((15 + random() * 180)::int || ' minutes')::interval,
  ((10 + random() * 200)::int || ' minutes')::interval
from generate_series(1, 30) as n;

-- Add task actions for historical tasks to show AI effectiveness trending
insert into task_actions (task_id, user_id, action_type, created_at)
select 
  t.id,
  t.user_id,
  (ARRAY['accept_ai','reject_ai','override_priority','reorder'])[1 + (random() * 3)::int],
  t.created_at + interval '1 hour'
from tasks t
where t.status = 'done' 
  and t.title like 'Historical task%'
  and random() > 0.3;

-- Print summary
select 
  'Data seeded successfully!' as message,
  count(distinct u.id) as users,
  count(distinct p.id) as projects,
  count(distinct t.id) as tasks,
  count(distinct g.id) as goals,
  count(distinct n.id) as notes,
  count(distinct e.id) as events,
  count(distinct fs.id) as focus_sessions
from users u
cross join projects p
cross join tasks t
cross join goals g
cross join notes n
cross join events e
cross join focus_sessions fs;