$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$required = @(
  'README.md', 'ROADMAP.md', 'ARCHITECTURE.md', 'SECURITY.md',
  'CHANGELOG.md', '.gitignore', '.env.example', 'bootstrap/windows',
  'bootstrap/macos', 'bootstrap/linux', 'configs/ssh', 'configs/git',
  'configs/shell', 'scripts', 'tests', 'docs/setup', 'docs/operations',
  'docs/troubleshooting', 'docs/security', 'docs/decisions'
)

$missing = $required | Where-Object { -not (Test-Path (Join-Path $root $_)) }
if ($missing) { throw "Missing required paths: $($missing -join ', ')" }

$probe = Join-Path $root 'secrets/phase-1-probe.txt'
New-Item -ItemType Directory -Force (Split-Path $probe) | Out-Null
Set-Content -Path $probe -Value 'synthetic-test-only'
try {
  git -C $root check-ignore --quiet $probe
  if ($LASTEXITCODE -ne 0) { throw 'Secret probe is not ignored by Git.' }
} finally {
  Remove-Item -Force $probe
  Remove-Item -Force (Split-Path $probe) -ErrorAction SilentlyContinue
}

Write-Host 'Phase 1 repository verification passed.' -ForegroundColor Green
