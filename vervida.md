## Product Requirements Document: VerVida Productivity Platform (ADHD Solopreneur Edition)

### Product Overview

**Product Name:** VerVida  
**Vision:** To empower ADHD solopreneurs with a “second brain” that captures their ideas, prioritizes their tasks, and guides them through execution with clarity, structure, and focus.  
**Purpose:** Eliminate overwhelm, reduce time blindness, improve task estimation, and help individuals with endless genius ideas actually bring them to life.  

**Target Audience:**  
- ADHD solopreneurs juggling multiple ventures and life roles  
- Independent creators who thrive on ideas but struggle with execution  
- Freelancers and side hustlers trying to scale without a team  

**Stakeholders:**  
- End users (individuals, not teams or managers)  

---

### Objectives and Goals

- Provide a unified system that captures every idea before it vanishes.  
- Combat time blindness with visual, structured timelines and gentle nudges.  
- Sequence tasks so users always know the “next best step.”  
- Transform vague ideas into actionable roadmaps that integrate with existing priorities.  
- Balance personal and business life using color-coded categories and smart scheduling.  
- Help users realistically estimate task durations and adjust schedules accordingly.  
- Create corporate-scale leverage for a team of one.  
- Enable chat-based task management through built-in conversational agents.  

---

### Features and Functional Requirements

| User Story | Acceptance Criteria |  
|------------|--------------------|  
| As an ADHD solopreneur, I want tasks broken into bite-sized steps so I don’t avoid them due to overwhelm. | AI auto-chunks big tasks into subtasks with progress tracking. |  
| As a user, I want a color-coded calendar that integrates personal and business life, so I can see balance at a glance. | Unified calendar with customizable categories and AI balance suggestions. |  
| As an ADHD user, I want voice capture for ideas so I don’t lose them mid-thought. | Voice-to-text capture that auto-tags and files into inbox, roadmap, or backlog. |  
| As a solopreneur, I want my ideas transformed into roadmaps so I can execute instead of stall. | System generates subtasks, timelines, and dependencies automatically. |  
| As an ADHD user, I want sequencing help so I don’t waste time deciding what to do next. | “Autopilot mode” recommends next step based on context, priority, and energy. |  
| As a user who struggles with estimating time frames, I want AI to suggest realistic task durations based on past behavior and comparable tasks so I can plan accurately. | Task creation includes an estimated duration field auto-filled by AI; system highlights if user’s estimate differs significantly from historical data; schedule auto-adjusts if tasks overrun. |  
| As a user with time blindness, I want a visual time map of my day so I don’t lose hours. | Day view with blocks of time, alarms, and nudges to switch. |  
| As a solopreneur, I want to see my top 3 priorities each day so I stay focused on what matters. | Daily focus view highlights 3 must-do tasks. |  
| As a user, I want analytics to show how I spend time so I can adjust for balance. | Reports on time distribution across life domains (biz, personal, admin, health). |  
| As a user, I want to chat directly with my tasks and projects so I can clarify, reprioritize, and brainstorm through conversation. | Built-in chat interface with **Agent Taskmaster** that understands context and provides actionable responses. |  

---

### Workflow

1. **Capture**: Ideas, tasks, and notes entered via voice, text, quick capture, or chat.  
2. **Classify**: AI sorts inputs into categories: today, inbox, roadmap, backlog.  
3. **Breakdown**: Large goals/ideas auto-chunked into subtasks with dependencies.  
4. **Estimate**: AI suggests realistic durations; warns when estimates differ from history.  
5. **Schedule**: Tasks slotted into a color-coded timeline; AI checks for overstuffing and adjusts automatically.  
6. **Prioritize**: Daily top 3 must-dos surfaced, with sequencing engine for “next step” prompts.  
7. **Execute**: Focus mode displays only current task, with progress bar and nudges.  
8. **Chat**: User converses with **Agent Taskmaster** to refine, reprioritize, or brainstorm tasks in natural language.  
9. **Reflect**: Weekly AI review of progress, time balance, and backlog health.  

---

### Technical/AI Requirements

- **Voice-first input** with speech-to-text and NLP classification.  
- **AI models** for task breakdown, prioritization, sequencing, roadmap generation, and time estimation.  
- **Chat interface with Agent Taskmaster** for direct conversational task management.  
- **Color-coded calendar** with category rules and auto-balancing.  
- **Data architecture (Supabase-first)**: hybrid local + cloud storage with secure sync.  
  - **Cloud**: Supabase (PostgreSQL) as the primary backend with Row Level Security (RLS) and policy-based access; Supabase Storage for attachments (audio, images, transcripts); Realtime for subscription-based updates; Edge Functions for server logic; Auth for OAuth/magic links/JWT.  
  - **Local**: SQLite/IndexedDB cache for offline-first capture and retrieval; queued writes with exponential backoff.  
  - **Sync**: bi-directional with conflict resolution (last-writer-wins + field-level merge for notes).  
  - **Security**: encryption in transit (TLS 1.2+) and at rest; optional client-side E2EE for notes, vault items, and voice transcripts.  
  - **Backups**: automated daily differential and weekly full backups via Supabase; export (JSON/CSV/ICS) endpoints.  
- **Secure logging & audit**: append-only event log capturing task edits, schedule changes, and agent actions.  
  - Structured logs (OpenTelemetry-compatible) with PII minimization; policy-gated access; redaction on sensitive fields; optional local-only logging mode.  
- **Compliance**: GDPR-ready data subject rights (export/delete), regional data residency options.  
- **Cross-device sync** with account-based auth (OIDC/OAuth2), device keys, and session management.  
- **Performance**: <2s p95 for most operations; realtime updates under 250ms median.  
- **Clients**: Browser-based dashboard plus mobile web app for capture, reminders, and chat.  

---

### Data Model & RLS Policies (Supabase)

Minimal schema for solopreneurs with optional light sharing. Includes projects, tasks, notes, roadmaps, events, attachments, tags, and agent events. RLS policies enforce owner-only access with optional share policies. Storage bucket policies lock down attachments per user. Indexes support fast daily planning and audit logging.

*(SQL schema and policies detailed in appendix of working draft — see developer notes.)*

---

### Success Metrics

- ≥75% of users report “less overwhelm” after 1 month.  
- ≥50% reduction in abandoned tasks/ideas.  
- ≥40% improvement in task execution consistency.  
- ≥70% daily active usage among core users.  
- ≥60% of captured ideas successfully converted into roadmaps.  
- ≥70% of users regularly engage with **Agent Taskmaster** for planning and prioritization.  
- ≥50% accuracy improvement in task duration estimates after 1 month of use.  

---

### Risks

- Overwhelming users with features instead of simplifying. Mitigation: ADHD-friendly onboarding and defaults.  
- Reminder fatigue. Mitigation: customizable nudge styles and intensity.  
- AI overpromising on timelines. Mitigation: reality checks based on past user performance.  
- User distrust of chat-driven suggestions. Mitigation: transparency in task reasoning from Agent Taskmaster.  

---

### Assumptions & Dependencies

- ADHD users require low-friction input and minimal setup.  
- Solopreneurs need both personal and business life integrated.  
- Mobile quick capture and chat are critical to adoption.  
- External calendar integrations (Google, Outlook) are stable.  

---

### Out of Scope

- Large team collaboration features.  
- Native offline apps at MVP stage.  
- Multilingual support (English only at launch).  

---

### Appendix

- Competitive analysis: traditional productivity tools (Todoist, Trello, Notion) lack ADHD-first design, integrated chat agents, and seamless idea-to-roadmap workflow.  
- Glossary: “Autopilot Mode” = task sequencing AI; “Backlog” = unscheduled ideas; “Focus Mode” = distraction-free single-task screen; **Agent Taskmaster** = conversational AI for direct chat-based task management.  
- Database schema: Supabase SQL with RLS policies for per-user isolation and optional sharing.  

