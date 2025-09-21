# VerVida - ADHD-Optimized Productivity Platform

## 🚀 Complete Database Implementation

This repository contains the full database schema and setup for VerVida, an AI-driven task management platform designed specifically for ADHD professionals and creatives.

## 📋 What's Included

### Core Features Implemented
- ✅ **Complete Authentication System** - Properly linked to Supabase Auth
- ✅ **ADHD-Specific Features** - Time blindness alerts, hyperfocus detection, energy tracking
- ✅ **AI Integration** - Task prioritization, reasoning, confidence scores, embeddings
- ✅ **Goal Alignment** - Short and long-term goal tracking with task relationships
- ✅ **Team Collaboration** - Projects, roles, comments, activity tracking
- ✅ **Analytics & Metrics** - Comprehensive event tracking, daily summaries, focus sessions
- ✅ **External Integrations** - Support for GitHub, Slack, Google Calendar
- ✅ **Workflow Automation** - Templates and user-specific automations
- ✅ **Performance Optimizations** - Indexes, materialized views, search vectors

### Files
1. **`20250921_init_schema.sql`** - Complete v2 schema with all features
2. **`seed.sql`** - Enhanced seed data with realistic ADHD scenarios
3. **`PRD.md`** - Product Requirements Document
4. **`README.md`** - This setup guide

## 🛠 Prerequisites

- Supabase CLI installed (`npm install -g supabase`)
- Supabase account and project created
- PostgreSQL 15+ (comes with Supabase)
- Node.js 18+ (for local development)

## 📦 Initial Setup

### 1. Clone and Initialize

```bash
# Clone the repository
git clone https://github.com/yourusername/vervida.git
cd vervida

# Login to Supabase
supabase login

# Initialize Supabase (if not already done)
supabase init

# Link to your remote project
supabase link --project-ref your-project-ref
```

### 2. Configure Environment

Create `.env.local` file:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# AI Keys (store in Supabase secrets for production)
OPENAI_API_KEY=your-openai-key
DEEPSEEK_API_KEY=your-deepseek-key
```

### 3. Deploy Database Schema

```bash
# Push the schema to your database
supabase db push --file supabase/migrations/20250921_init_schema.sql

# Verify the migration
supabase db status
```

### 4. Enable Required Extensions

```sql
-- Run in Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";
CREATE EXTENSION IF NOT EXISTS "pg_cron";
```

### 5. Set Up Authentication

In Supabase Dashboard:
1. Go to Authentication → Providers
2. Enable Email/Password authentication
3. Configure email templates for ADHD-friendly language
4. Set up OAuth providers (Google, GitHub) if desired

### 6. Configure Storage Buckets

```sql
-- Create storage buckets for attachments
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('task-attachments', 'task-attachments', false),
  ('user-avatars', 'user-avatars', true);
```

### 7. Load Seed Data (Development Only)

```bash
# Load demo data
supabase db seed --file supabase/seed.sql

# Or reset and reseed
supabase db reset
```

### 8. Deploy Edge Functions

```bash
# Create AI task sorting function
supabase functions new ai-task-sort
# Copy function code from /supabase/functions/ai-task-sort

# Deploy all functions
supabase functions deploy ai-task-sort --no-verify-jwt
supabase functions deploy task-recurrence --no-verify-jwt
supabase functions deploy analytics-aggregator --no-verify-jwt

# Set secrets
supabase secrets set OPENAI_API_KEY=your-key-here
supabase secrets set DEEPSEEK_API_KEY=your-key-here
```

### 9. Enable Realtime

```bash
# Enable realtime for specific tables
supabase realtime enable tasks
supabase realtime enable task_comments
supabase realtime enable focus_sessions
```

### 10. Set Up Scheduled Jobs

```sql
-- In Supabase SQL Editor, schedule the cron jobs
SELECT cron.schedule('daily-summary', '0 2 * * *', 
  'CALL aggregate_daily_summaries();');

SELECT cron.schedule('refresh-views', '0 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY user_dashboard;
   REFRESH MATERIALIZED VIEW CONCURRENTLY project_dashboard;');

SELECT cron.schedule('cleanup-old-analytics', '0 3 * * 0',
  'DELETE FROM analytics_events WHERE created_at < NOW() - INTERVAL ''90 days'';');
```

## 🏗 Development Workflow

### Local Development

```bash
# Start Supabase locally
supabase start

# View local dashboard
supabase status

# Access services:
# - Database: postgresql://postgres:postgres@localhost:54322/postgres
# - API: http://localhost:54321
# - Studio: http://localhost:54323
```

### Database Migrations

```bash
# Create a new migration
supabase migration new feature_name

# Apply migrations
supabase db push

# Generate TypeScript types
supabase gen types typescript --local > lib/database.types.ts
```

### Testing

```sql
-- Test RLS policies
SET SESSION ROLE authenticated;
SET request.jwt.claims TO '{"sub": "11111111-1111-1111-1111-111111111111"}';

-- Should only see own tasks
SELECT * FROM tasks;

-- Test team collaboration
SELECT * FROM tasks WHERE project_id IN (
  SELECT project_id FROM project_members WHERE user_id = current_user_id()
);
```

## 📊 Key Database Features

### ADHD-Specific Tables
- `user_preferences` - Sensory preferences, energy patterns, notification styles
- `focus_sessions` - Track hyperfocus, interruptions, productivity
- `daily_summaries` - Aggregate metrics for pattern recognition

### AI Integration
- `ai_conversations` - Chat history with context
- `task.ai_*` columns - Priority, reasoning, suggestions
- Vector embeddings for semantic search

### Analytics
- `analytics_events` - Comprehensive event tracking
- `task_actions` - Specific tracking for measuring AI effectiveness
- Materialized views for dashboard performance

### Performance Optimizations
- 25+ strategic indexes
- Materialized views for dashboards
- Full-text search on notes and tasks
- Efficient JSON storage for flexible data

## 🔒 Security Features

- Row Level Security (RLS) on all tables
- Role-based access (owner, admin, editor, viewer)
- Secure authentication via Supabase Auth
- Service role isolation for system operations
- GDPR-compliant data handling

## 📈 Monitoring & Analytics

### Key Metrics to Track
- Task completion rate (target: ≥90%)
- AI suggestion acceptance rate (target: ≥75%)
- Manual prioritization overrides (target: ≤40%)
- User retention (D1, D7, D30)
- Focus session productivity scores

### Dashboard Queries

```sql
-- User productivity overview
SELECT * FROM user_dashboard WHERE user_id = auth.uid();

-- Team velocity
SELECT * FROM project_dashboard WHERE project_id = 'your-project-id';

-- AI effectiveness
SELECT 
  date_trunc('week', created_at) as week,
  COUNT(*) FILTER (WHERE action_type = 'accept_ai') as accepted,
  COUNT(*) FILTER (WHERE action_type = 'reject_ai') as rejected,
  ROUND(100.0 * COUNT(*) FILTER (WHERE action_type = 'accept_ai') / COUNT(*), 2) as acceptance_rate
FROM task_actions
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY week
ORDER BY week DESC;
```

## 🚢 Production Deployment

### Pre-deployment Checklist
- [ ] All migrations applied successfully
- [ ] RLS policies tested and verified
- [ ] Backup strategy configured
- [ ] Monitoring and alerts set up
- [ ] Rate limiting configured
- [ ] API keys secured in Supabase Vault
- [ ] Performance testing completed
- [ ] GDPR compliance verified

### Deployment Steps

```bash
# Deploy to production
supabase link --project-ref prod-project-ref
supabase db push --linked
supabase functions deploy --linked

# Verify deployment
supabase db status --linked
```

## 🆘 Troubleshooting

### Common Issues

**RLS Policy Violations**
```sql
-- Debug RLS issues
SET log_statement = 'all';
SET log_error_verbosity = 'verbose';
```

**Performance Issues**
```sql
-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM your_query;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan;
```

**Migration Failures**
```bash
# Rollback migration
supabase db reset

# Check migration status
supabase migration list
```

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [ADHD Productivity Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6424886/)
- [WCAG Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)

## 📧 Support

For questions or issues:
- Create an issue in this repository
- Contact: support@vervida.app
- Discord: [VerVida Community](https://discord.gg/vervida)

## 📄 License

MIT License - See LICENSE file for details

---

**Built with ❤️ for the ADHD community**