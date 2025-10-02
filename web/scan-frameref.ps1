# scan-frameref.ps1
param(
  [switch]$IncludeNodeModules
)

$here = Get-Location
Write-Host "[scan] Root: $here" -ForegroundColor Cyan

# Build include globs
$globs = @("*.ts","*.tsx","*.js","*.jsx")
$dirs  = @("app","components","lib","hooks","pages")

if ($IncludeNodeModules) {
  $dirs += "node_modules"
}

function Find-In {
  param([string]$pattern)
  $files = @()
  foreach ($d in $dirs) {
    if (Test-Path $d) {
      $files += Get-ChildItem -Recurse -File -Path $d -Include $globs -ErrorAction SilentlyContinue
    }
  }
  if ($files.Count -eq 0) { return @() }
  try {
    $matches = $files | Select-String -Pattern $pattern -CaseSensitive -SimpleMatch
  } catch {
    $matches = @()
  }
  return $matches
}

# 1) Any text "frameRef"
$hits1 = Find-In "frameRef"

# 2) Any DOM iframes (<iframe)
#   Use regex so we don’t match <IframeAdapter>.
$hits2 = @()
foreach ($d in $dirs) {
  if (Test-Path $d) {
    $hits2 += Get-ChildItem -Recurse -File -Path $d -Include $globs `
      | Select-String -Pattern '<\s*iframe\b' -CaseSensitive
  }
}

Write-Host "`n=== frameRef matches ===" -ForegroundColor Yellow
if ($hits1.Count -eq 0) {
  Write-Host "(none)"
} else {
  $hits1 | Sort-Object Path, LineNumber `
    | ForEach-Object { "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim() } `
    | ForEach-Object { Write-Host $_ }
}

Write-Host "`n=== <iframe> occurrences ===" -ForegroundColor Yellow
if ($hits2.Count -eq 0) {
  Write-Host "(none)"
} else {
  $hits2 | Sort-Object Path, LineNumber `
    | ForEach-Object { "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim() } `
    | ForEach-Object { Write-Host $_ }
}

Write-Host "`nTip: To include node_modules, run: powershell -ExecutionPolicy Bypass -File .\scan-frameref.ps1 -IncludeNodeModules" -ForegroundColor DarkGray
