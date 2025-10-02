# fix-iframe-refs.ps1
# Replaces <iframe ... frameRef=...> with <IframeAdapter ...> and fixes closing tags.
# Adds import IframeAdapter if missing. Creates .bak backups of modified files.

param(
  [switch]$DryRun
)

$root = Get-Location
Write-Host "[info] Scanning from $root" -ForegroundColor Cyan

# Helper: insert import after last import line block
function Add-Import-If-Missing {
  param(
    [string]$Content,
    [string]$ImportLine
  )

  if ($Content -match [regex]::Escape($ImportLine)) {
    return $Content
  }

  $lines = $Content -split "`r?`n"

  # find the last contiguous import line at top
  $lastImportIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*import\s.+;?\s*$') {
      $lastImportIndex = $i
      continue
    }
    # stop scanning once we hit the first non-import after seeing imports
    if ($lastImportIndex -ge 0 -and $lines[$i] -notmatch '^\s*import\s') {
      break
    }
  }

  if ($lastImportIndex -ge 0) {
    $before = $lines[0..$lastImportIndex] -join "`n"
    $after  = $lines[($lastImportIndex+1)..($lines.Count-1)] -join "`n"
    return ($before + "`n" + $ImportLine + "`n" + $after)
  } else {
    # no imports at top — prepend
    return ($ImportLine + "`n" + $Content)
  }
}

# Regex options
$singleline = [System.Text.RegularExpressions.RegexOptions]::Singleline
$multiline  = [System.Text.RegularExpressions.RegexOptions]::Multiline

# Only scan TSX files under app/ and components/ (skip node_modules/.next)
$files = Get-ChildItem -Recurse -File -Include *.tsx |
  Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\\.next\\' }

if ($files.Count -eq 0) {
  Write-Host "[warn] No .tsx files found. Are you in the web/ folder?" -ForegroundColor Yellow
  exit 0
}

$changed = @()
foreach ($f in $files) {
  $text = Get-Content $f.FullName -Raw

  # 1) Replace opening tags that have a frameRef prop:
  # Change ONLY <iframe ...> that contain frameRef= somewhere inside the same tag.
  $openPattern = '<iframe(?=[^>]*\bframeRef=)'
  $new = [regex]::Replace($text, $openPattern, '<IframeAdapter')

  $modified = $false
  if ($new -ne $text) {
    $modified = $true
    # 2) For any replaced opening tag, fix the matching closing tag(s).
    # Change </iframe> that closes those sections into </IframeAdapter>.
    # This broad replace is safe because only files that had an opening replacement get here.
    $new = [regex]::Replace($new, '</iframe\s*>', '</IframeAdapter>', $singleline)
    # 2b) Also handle the case of a non-self-closing opening pair in one pass:
    $new = [regex]::Replace($new, '<IframeAdapter\b([^>]*)>(.*?)</iframe\s*>', '<IframeAdapter$1>$2</IframeAdapter>', $singleline)

    # 3) Ensure the import exists
    $importLine = 'import IframeAdapter from "@/components/ui/ui-builder/components/iframe-adapter";'
    $new = Add-Import-If-Missing -Content $new -ImportLine $importLine
  }

  if ($modified) {
    if ($DryRun) {
      Write-Host "[dry-run] Would fix: $($f.FullName)" -ForegroundColor Yellow
      $changed += $f.FullName
    } else {
      Copy-Item $f.FullName ($f.FullName + ".bak") -Force
      Set-Content $f.FullName $new -Encoding UTF8
      Write-Host "[fixed] $($f.FullName)" -ForegroundColor Green
      $changed += $f.FullName
    }
  }
}

if ($changed.Count -eq 0) {
  Write-Host "[info] No files needed changes (no <iframe ... frameRef=...> found)." -ForegroundColor Cyan
} else {
  Write-Host "`n[summary] Updated $($changed.Count) file(s):" -ForegroundColor Cyan
  $changed | ForEach-Object { Write-Host " - $_" }
  Write-Host "`nBackups saved as *.bak next to each file." -ForegroundColor DarkGray
}

Write-Host "`nDone."
