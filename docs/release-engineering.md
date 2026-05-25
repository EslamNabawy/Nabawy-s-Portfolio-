# Release Engineering

## Objective

Build the Flutter admin dashboard from source in GitHub Actions and ship a zipped Windows release artifact without relying on a local machine.

## Required Repository Secrets

Add these in GitHub under `Settings -> Secrets and variables -> Actions -> Repository secrets`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

The anon key is publishable client configuration. Do not put a Supabase service-role key, GitHub PAT, or any private backend secret in this workflow.

## GitHub Release Flow

1. Open the repository on GitHub.
2. Go to `Actions`.
3. Select `Build Dashboard Windows`.
4. Click `Run workflow`.
5. Download the `portfolio-admin-windows-<commit>` artifact after the run passes.

The artifact contains `portfolio_admin_windows_release.zip`. That zip includes:

- `portfolio_admin.exe`
- Flutter Windows runtime files
- `supabase_config.json`

## Local Release Flow

PowerShell:

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY = "your-anon-key"
.\scripts\build_windows_release.ps1
```

Output:

```text
build\portfolio_admin_windows_release.zip
```

## Failure Modes

- Missing secrets: workflow fails before packaging.
- Analyze/test failure: no zip is uploaded.
- Windows build failure: no zip is uploaded.
- Invalid Supabase config: the exe opens to the configuration error screen.
