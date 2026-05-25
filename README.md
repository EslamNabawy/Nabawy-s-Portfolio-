# Nabawy Portfolio CMS

Flutter admin dashboard plus Astro static portfolio for a Supabase-backed portfolio CMS.

## Structure

- `lib/`: Flutter admin dashboard.
- `supabase/migrations/`: database, RLS, and storage migrations.
- `portfolio_site/`: Astro public portfolio generated at build time.
- `.github/workflows/deploy.yml`: manual GitHub Pages deploy for the Astro site.
- `.github/workflows/build-dashboard-windows.yml`: manual Windows dashboard release build.

## Dashboard

Run locally:

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY = "your-anon-key"
flutter run -d windows
```

Build a Windows release zip:

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY = "your-anon-key"
.\scripts\build_windows_release.ps1
```

## Public Site

```powershell
cd portfolio_site
npm ci
npm run build
```

The public site fetches Supabase content only during the Astro build.
