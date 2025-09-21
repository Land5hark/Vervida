# VerVida Starter Repo

This repo contains the schema, seed data, and PRD for VerVida.

## Getting Started

### 1. Install Supabase CLI
```bash
npm install -g supabase
```

### 2. Log in
```bash
supabase login
```

### 3. Initialize project
```bash
supabase init
```

### 4. Push schema
```bash
supabase db push
```

### 5. Seed database
```bash
supabase db seed --file supabase/seed.sql
```

After this, your local Supabase project will have demo users, projects, tasks, notes, and events — all RLS-protected and ready to query.

See `PRD.md` for the full product requirements.
