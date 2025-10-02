Param(
  [string]$Root = ".",
  [string]$Folder = "docs/daily-summaries",
  [string]$Prefix = "TODAY_SUMMARY_"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Use script dir to find the index script reliably
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexScript = Join-Path $here "index-daily-summaries.ps1"

$rootPath = Resolve-Path -Path $Root
$absFolder = Join-Path $rootPath $Folder
New-Item -ItemType Directory -Path $absFolder -ErrorAction SilentlyContinue | Out-Null

$today = (Get-Date).ToString("yyyy-MM-dd")
$fname = "${Prefix}${today}.md"
$absPath = Join-Path $absFolder $fname

if (-not (Test-Path $absPath)) {
  $content = @"
# Daily Summary — $today

**Focus**
- (what did we work on)

## Highlights
- …

## Decisions
- …

## Open Items → Next Steps
- …

"@
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($absPath, $content, $utf8NoBom)
  Write-Host "[ok] Created $($absPath)"
} else {
  Write-Host "[info] File already exists: $($absPath)"
}

# Rebuild the index
& $indexScript -Root $Root -Folder $Folder -Out "docs/DAILY_SUMMARY_INDEX.md"
