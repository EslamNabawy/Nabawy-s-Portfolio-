[CmdletBinding()]
param(
  [string]$ReleaseDir = "build/windows/x64/runner/Release",
  [string]$OutputPath = "build/portfolio_admin_windows_release.zip",
  [string]$SupabaseUrl = $env:SUPABASE_URL,
  [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY
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

function Resolve-ExistingDirectory {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Release directory does not exist: $Path. Run flutter build windows --release first."
  }

  return (Resolve-Path -LiteralPath $Path).Path
}

Assert-NotBlank -Name "SUPABASE_URL" -Value $SupabaseUrl
Assert-NotBlank -Name "SUPABASE_ANON_KEY" -Value $SupabaseAnonKey

$resolvedReleaseDir = Resolve-ExistingDirectory -Path $ReleaseDir
$resolvedOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
$outputDirectory = Split-Path -Parent $resolvedOutputPath

if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
  New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$runtimeConfig = [ordered]@{
  SUPABASE_URL = $SupabaseUrl.Trim()
  SUPABASE_ANON_KEY = $SupabaseAnonKey.Trim()
} | ConvertTo-Json

Set-Content `
  -Path (Join-Path $resolvedReleaseDir "supabase_config.json") `
  -Value $runtimeConfig `
  -Encoding UTF8

Compress-Archive `
  -Path (Join-Path $resolvedReleaseDir "*") `
  -DestinationPath $resolvedOutputPath `
  -Force

$artifact = Get-Item -LiteralPath $resolvedOutputPath
Write-Host "Created $($artifact.FullName) ($($artifact.Length) bytes)"
