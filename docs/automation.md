# Automation

## Dashboard Flow

Projects, skills, and site config now support two deployment paths:

- `Save + Deploy`: saves the CMS row, then triggers the public GitHub Pages rebuild.
- `Deploy after save`: keeps the next normal save on the same path.

Draft-only project and skill edits do not enable deployment because the static public site only reads published rows. Editing a previously published row still enables deployment, including when it is changed back to draft.

## Deployment Log

Every automated deploy uses the same deployment coordinator as the manual Deploy screen:

- create a pending `publish_log` row
- trigger the GitHub Actions workflow through GitHub CLI
- poll the workflow run
- update `publish_log` as success or failed

## Monthly Rebuild

`.github/workflows/deploy.yml` runs automatically at `03:00 UTC` on the first day of every month.

This is a safety rebuild only. Normal content publishing should still use `Save + Deploy` from the dashboard when a public change needs to go live immediately.
