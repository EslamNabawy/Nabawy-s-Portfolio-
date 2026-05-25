[CmdletBinding()]
param(
  [string]$SupabaseUrl = $env:SUPABASE_URL,
  [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY,
  [string]$OutputPath = "build/portfolio_admin_windows_release.zip"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-NotBlank {
  param(
    [string]$Name,
    [string]$Value
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    throw "Missing $Name. Set it as an environment variable or pass it as a script parameter."
  }
}

function Invoke-CheckedCommand {
  param(
    [string]$Name,
    [scriptblock]$Command
  )

  Write-Host "==> $Name"
  & $Command

  if ($LASTEXITCODE -ne 0) {
    throw "$Name failed with exit code $LASTEXITCODE."
  }
}

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

Assert-NotBlank -Name "SUPABASE_URL" -Value $SupabaseUrl
Assert-NotBlank -Name "SUPABASE_ANON_KEY" -Value $SupabaseAnonKey

Invoke-CheckedCommand -Name "Install Flutter dependencies" -Command {
  flutter pub get
}

Invoke-CheckedCommand -Name "Analyze Flutter dashboard" -Command {
  flutter analyze
}

Invoke-CheckedCommand -Name "Run Flutter tests" -Command {
  flutter test
}

Invoke-CheckedCommand -Name "Build Windows dashboard" -Command {
  flutter build windows --release
}

& (Join-Path $PSScriptRoot "package_windows_release.ps1") `
  -SupabaseUrl $SupabaseUrl `
  -SupabaseAnonKey $SupabaseAnonKey `
  -OutputPath $OutputPath
