# Portfolio CMS Phased Plan

## Phase 1: CMS Completion

Status: Complete.

Objective: Finish the dashboard as a real CMS, not only project CRUD.

Build:
- Skills editor
- Site config editor
- Publish log viewer
- Better project validation

Bottleneck: The admin surface is incomplete.

Mitigation: Implement one table at a time using the same repository, provider, and screen pattern already used by `projects`.

## Phase 2: Deploy System Upgrade

Status: Complete.

Objective: Make deployment visible and reliable from the dashboard.

Build:
- Deploy button status
- Latest GitHub Actions run fetch
- Success/failure display
- Deploy attempts stored in `publish_log`

Bottleneck: The current deploy flow only triggers the workflow.

Mitigation: After triggering deploy, query `gh run list/view` and persist the result to Supabase.

## Phase 3: Public Portfolio Content Model

Status: Complete.

Objective: Upgrade the data model so the portfolio can present real case studies.

Build:
- `short_description`
- `featured`
- `role`
- `impact`
- `architecture_notes`
- `case_study_markdown`
- Multiple images per project

Bottleneck: The current project schema is too shallow for serious portfolio storytelling.

Mitigation: Add a backward-compatible migration and keep existing Astro rendering working while the richer fields are introduced.

## Phase 4: Public Site Redesign

Status: Complete.

Objective: Make the Astro site recruiter-grade.

Build:
- Strong homepage
- Better project cards
- Full case-study detail pages
- Responsive polish
- Better typography and spacing

Bottleneck: The current site is structurally correct but visually basic.

Mitigation: Redesign inside `portfolio_site/src` while preserving build-time Supabase fetching only.

## Phase 5: Admin UX Upgrade

Status: Complete.

Objective: Make content editing fast and hard to break.

Build:
- Markdown preview
- Slug auto-generation
- Image preview/gallery
- Dirty form warning
- Save states
- Publish readiness checks

Bottleneck: Weak CMS input can break or weaken the public site.

Mitigation: Validate in both the dashboard and Astro build.

## Phase 6: Security Hardening

Status: Complete.

Objective: Lock CMS writes to only the admin identity.

Build:
- `admin_users` table or app metadata authorization
- Admin-only RLS policies
- Storage write restrictions
- Clearer dashboard login errors

Bottleneck: The current MVP policies allow any authenticated user to write CMS data.

Mitigation: Use `auth.uid()` against an allowlist table and update table/storage policies.

## Phase 7: Release Engineering

Status: Complete.

Objective: Make the dashboard reproducible and easy to ship.

Build:
- Commit Flutter admin source
- Windows build workflow
- Automatic release zip generation
- Optional installer

Bottleneck: The current `.exe` is manually built locally.

Mitigation: Create a GitHub Actions workflow for Windows release artifacts.

## Phase 8: Automation

Status: Complete.

Objective: Reduce manual work after edits.

Build:
- `Save + Deploy`
- Optional auto-deploy after published changes
- Monthly rebuild trigger
- Deploy notifications/status

Bottleneck: Manual deploy can be forgotten.

Mitigation: Make deployment a guided CMS workflow rather than a separate manual task.

## Phase 9: Observability

Status: Next.

Objective: Make failures obvious without opening every tool manually.

Build:
- Dashboard health checks
- Supabase content validation report
- Last public deploy summary
- Broken image/link scanner

Bottleneck: Static-site failures can hide until the next manual check.

Mitigation: Add lightweight validation commands and render their results in the admin dashboard.

## Recommended Next Sprint

1. Execute Phase 9: Observability.
2. Add a dashboard health panel for Supabase, GitHub Actions, and public site status.
3. Add content validation before deployment.
4. Add broken image/link checks for published projects.
