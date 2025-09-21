# VerVida Final Secure Repo

Includes:
- PRD.md (full requirements, no placeholders)
- supabase/migrations/20250921_init_schema.sql (schema + CRUD + role-aware RLS with WITH CHECK)
- supabase/seed.sql (demo data with roles)
- README.md (setup guide)

## Setup

```bash
npm install -g supabase
supabase login
supabase init
supabase db push
supabase db seed --file supabase/seed.sql
```
