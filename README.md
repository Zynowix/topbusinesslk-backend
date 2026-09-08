# TopBusiness.lk — Backend & Admin Tools

Backend services, database schema, integrations, and administrative tooling for **[TopBusiness.lk](https://topbusiness.lk)** — Sri Lanka's Verified Business Directory.

## Repository Contents

- **`supabase/schema.sql`**: Production-ready PostgreSQL schema, indexes, automated triggers, Row Level Security (RLS) policies, and seed data migration.
- **`admin.html`**: Standalone administrative console prototype & Google Sheets sync reference.
- **`.env.example`**: Template for environment variables.

---

## Supabase Database Setup Guide

### 1. Create a Supabase Project
1. Log in to [Supabase](https://supabase.com) and create a new project (e.g. `topbusinesslk`).
2. Choose your preferred region (e.g. Singapore `ap-southeast-1` or closest to Sri Lanka).

### 2. Run Database Schema Migration
1. Go to your Supabase project dashboard → **SQL Editor**.
2. Copy the entire contents of [`supabase/schema.sql`](./supabase/schema.sql).
3. Paste into the SQL query box and click **Run**.
4. All tables, triggers, indexes, RLS policies, and initial Sri Lankan businesses & review queue submissions will be created immediately!

### 3. Database Schema Overview

| Table | Purpose | RLS Policy |
| :--- | :--- | :--- |
| `public.businesses` | Live & verified directory listings | Public `SELECT`, Admin `ALL` |
| `public.submissions` | Review queue intake for Google Form applicants | Public `INSERT`, Admin `ALL` |
| `public.admin_settings` | Dynamic counter & platform configuration | Public `SELECT`, Admin `ALL` |

### 4. Connect to Frontend
Copy your project credentials from **Project Settings → API**:
- **Project URL** (`https://[ref].supabase.co`)
- **anon public key** (`eyJ...`)

In the frontend repository, add them to `frontend/.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1Ni...
```

*Note: The frontend has built-in graceful fallback. If the keys are unset, it operates safely in local sandbox memory mode without throwing runtime errors.*

---

## Repository Structure

```
├── .env.example
├── .gitignore
├── README.md
├── admin.html          # Prototype & Google Sheets integration reference
└── supabase/
    └── schema.sql      # PostgreSQL schema, RLS policies & initial seed data
```
