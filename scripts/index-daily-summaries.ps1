Param(
  [string]$Root = ".",
  [string]$Folder = "docs/daily-summaries",
  [string]$Out = "docs/DAILY_SUMMARY_INDEX.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve base paths
$rootPath = Resolve-Path -Path $Root
$absFolder = Join-Path $rootPath $Folder
$absOut = Join-Path $rootPath $Out

# Ensure folder exists
New-Item -ItemType Directory -Path $absFolder -ErrorAction SilentlyContinue | Out-Null

# Collect files (if none, still write an index)
$files = Get-ChildItem -Path $absFolder -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending

# Build markdown
$lines = @()
$lines += "# Daily Summaries"
$lines += ""
$lines += "All daily logs are stored in \`$Folder\` and listed below (newest first)."
$lines += ""

foreach ($f in $files) {
  $rel = (Join-Path $Folder $f.Name).Replace("\","/")
  $title = $f.BaseName
  $lines += "* [$title]($rel)"
}

# Write with UTF8 (no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($absOut, $lines, $utf8NoBom)

Write-Host "[ok] Wrote $Out"
