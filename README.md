# TopBusiness.lk — Backend & Admin Tools

Backend services, integrations, and administrative tooling for **[TopBusiness.lk](https://topbusiness.lk)** — Sri Lanka's Verified Business Directory.

## Contents

- **`admin.html`**: Standalone administrative console prototype featuring:
  - **Passcode Gate**: Secured access (`topbiz2026`).
  - **Review Queue**: Pending business submission verification, approval, and rejection modal with auto-generated reasons.
  - **Listings Management**: Search, filter by district/category, toggle live/paused status, direct links to WhatsApp, Google Maps, and external sites.
  - **Ranking & Pitch Generator**: 1-click personalized WhatsApp sales pitches to help businesses claim or upgrade their rank #1–#5 listing.
  - **Google Sheets / Apps Script Sync**: Data importer and webhook synchronization settings.

*(Note: The production Admin Console is also natively built into the Next.js App Router at `/admin` within the [`topbusinesslk-frontend`](https://github.com/Zynowix/topbusinesslk-frontend) repository).*

## Repository Structure

```
├── README.md
├── .gitignore
└── admin.html      # Admin portal prototype & Sheets integration reference
```
