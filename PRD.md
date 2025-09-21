# VerVida Product Requirements Document (Final)

## Product Overview

**Product Name:** VerVida  
**Vision:** Empower ADHD professionals and creatives with AI-driven productivity that reduces cognitive overload, supports time management, and enhances collaboration.  
**Purpose:** Deliver adaptive, ADHD-optimized productivity features that unify tasks, notes, events, and goals with AI prioritization and contextual nudges.  

**Target Audience:**  
- Adults with ADHD who need supportive, low-friction tools  
- Creative professionals juggling multiple projects  
- Teams requiring collaborative workflows with intelligent prioritization  
- Productivity enthusiasts exploring adaptive AI tools  

**Stakeholders:** End users, product managers, engineering team, investors, ADHD coaches/consultants  

---

## Objectives & Goals

- Automate prioritization and reduce manual reordering by 60%  
- Support ADHD-specific challenges (time blindness, hyperfocus, decision fatigue)  
- Provide explainable AI to build user trust and learning  
- Enable collaboration through shared projects with role-based permissions  
- Design with accessibility, neurodivergent-friendly defaults, and GDPR compliance  

---

## Features & Functional Requirements

| Feature | MVP | Phase 2 | Phase 3 |
|---------|-----|---------|---------|
| Tasks, notes, events unified dashboard | ✅ |  |  |
| AI auto-sorting + explainable reasoning | ✅ |  |  |
| Time blindness support (visual timers) | ✅ |  |  |
| Hyperfocus detection alerts | ✅ |  |  |
| Executive function aids (task breakdowns, decision helpers) | ✅ |  |  |
| Project collaboration (roles, last-save-wins) |  | ✅ |  |
| Real-time AI chat assistant |  | ✅ |  |
| PWA + push notifications |  | ✅ |  |
| Native app (Play Store, App Store) |  |  | ✅ |
| Gamification (streaks, dopamine design) |  |  | ✅ |
| Focus mode |  |  | ✅ |
| Energy-level tracking |  |  | ✅ |
| Monetization tiers |  |  | ✅ |

---

## Technical & AI Requirements

- **Architecture:** MVP as Supabase monolith (DB, Auth, Storage, Functions). Phase 2 may modularize AI services.  
- **AI providers:** Users bring keys (OpenAI, Anthropic, local, OpenRouter).  
- **Fallback behavior:** If AI fails, manual entry is default.  
- **Explainability:** AI always shows plain-language reasons for decisions.  
- **Aggressiveness:** MVP fixed; user-tunable later.  
- **Performance Targets:**  
  - Task CRUD < 200ms  
  - Dashboard load < 1s (≤1k items)  
  - AI responses < 3s short, < 10s long  
  - 500 concurrent users MVP, 5k Phase 2, 50k Phase 3  
  - 10k tasks, 50k notes, 20k events per user  

---

## Compliance & Security

- **MVP:** GDPR compliance, WCAG AA accessibility, daily backups with 30-day retention  
- **Phase 2+:** HIPAA readiness for potential healthcare partnerships  
- **Security:** RLS on all tables, role-based collaboration (owner/admin/editor/viewer), Supabase Auth integration  

---

## Roadmap & Timeline

- **MVP (Weeks 0–3):** Tasks/notes/events dashboard, AI prioritization + explanations, ADHD aids (time blindness, hyperfocus detection, exec function helpers), unified onboarding wizard, browser + PWA delivery  
- **Beta (Weeks 4–5):** Closed ADHD-community testing, feedback loop  
- **Phase 2 (Weeks 5–8):** Project collaboration (roles, comments), real-time AI chat, push notifications, analytics expansion, onboarding polish  
- **Phase 3 (Weeks 9–12):** Gamification, Focus mode, Energy tracking, monetization, mobile app packaging (Google Play/App Store), HIPAA readiness exploration  

---

## Analytics & Measurement

**Tools:** Mixpanel/PostHog, Supabase logs, dashboards  
**Events Tracked:** task CRUD, notes/events, AI suggestions (accept/reject), prioritization overrides, focus sessions, onboarding completion  
**Key Metrics:**  
- Task completion ≥90%  
- Manual prioritization overrides ≤40%  
- AI suggestion acceptance ≥75%  
- Retention (D1, D7, D30)  
- Focus session productivity ratings  
- CSAT ≥75%  

---

## Monetization & GTM

- **Freemium:** Core free, ADHD features included  
- **Pro ($10/mo):** Unlimited AI + integrations  
- **Team ($20/user/mo):** Collaboration, analytics, permissions  
- **GTM:** ADHD forums, YouTube collabs, referral-based beta invites  

---

## Operational & Support

- **Onboarding:** Guided setup wizard (profile, calendar, first task)  
- **Support:** Email-only at MVP, docs + chat widget in Phase 2  
- **Beta Testing:** Closed group of ADHD users with structured feedback surveys  
- **Backups:** Daily automated, 30-day retention  

---

## Risks

- AI hallucinations → mitigated with explainability + manual overrides  
- User overwhelm → solved with ADHD-first design (low friction, simple defaults)  
- Performance scaling → solved with indexes, materialized views, and later caching  

---

## Appendix: Database Schema

See `/supabase/migrations/20250921_init_schema.sql` (complete v2 schema).  

---
