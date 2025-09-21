-- Demo seed data for VerVida (with users, projects, tasks, notes, events)

truncate table task_actions cascade;
truncate table tasks cascade;
truncate table project_members cascade;
truncate table projects cascade;
truncate table notes cascade;
truncate table events cascade;
truncate table users cascade;

insert into users (id, email, display_name)
values
  (gen_random_uuid(), 'alice@example.com', 'Alice'),
  (gen_random_uuid(), 'bob@example.com', 'Bob'),
  (gen_random_uuid(), 'charlie@example.com', 'Charlie');

insert into projects (id, name, created_by)
values
  (gen_random_uuid(), 'ADHD Morning Routine', (select id from users where email = 'alice@example.com')),
  (gen_random_uuid(), 'Client Design Sprint', (select id from users where email = 'bob@example.com'));

insert into project_members (project_id, user_id, role)
select p.id, u.id, 'owner'
from projects p
join users u on p.created_by = u.id;

insert into project_members (project_id, user_id, role)
select (select id from projects where name = 'Client Design Sprint'),
       (select id from users where email = 'charlie@example.com'),
       'editor';

insert into tasks (id, user_id, project_id, title, description, status, priority, due_date)
values
  (gen_random_uuid(),
   (select id from users where email = 'alice@example.com'),
   (select id from projects where name = 'ADHD Morning Routine'),
   'Morning checklist',
   'Review notes and plan day',
   'pending',
   1,
   current_date + interval '1 day'),

  (gen_random_uuid(),
   (select id from users where email = 'bob@example.com'),
   (select id from projects where name = 'Client Design Sprint'),
   'Draft wireframes',
   'Initial wireframes for sprint planning',
   'in_progress',
   2,
   current_date + interval '3 days');

insert into notes (id, user_id, content)
values
  (gen_random_uuid(), (select id from users where email = 'alice@example.com'), 'Reminder: ADHD-friendly routines help reduce overwhelm.'),
  (gen_random_uuid(), (select id from users where email = 'charlie@example.com'), 'Client feedback: add accessibility features.');

insert into events (id, user_id, title, start_time, end_time)
values
  (gen_random_uuid(),
   (select id from users where email = 'bob@example.com'),
   'Design Sprint Kickoff',
   now() + interval '2 days',
   now() + interval '2 days' + interval '2 hours');

insert into task_actions (id, task_id, user_id, action_type)
values
  (gen_random_uuid(),
   (select id from tasks where title = 'Morning checklist'),
   (select id from users where email = 'alice@example.com'),
   'override_priority'),

  (gen_random_uuid(),
   (select id from tasks where title = 'Draft wireframes'),
   (select id from users where email = 'bob@example.com'),
   'reorder');
