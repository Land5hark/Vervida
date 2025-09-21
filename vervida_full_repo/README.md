# VerVida Starter Repo (Full)

This repo contains:
- PRD.md (full requirements)
- supabase/migrations/20250921_init_schema.sql (schema + RLS policies)
- supabase/seed.sql (demo data)

## Setup

```bash
npm install -g supabase
supabase login
supabase init
supabase db push
supabase db seed --file supabase/seed.sql
```
