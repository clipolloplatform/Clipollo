Param(
  [string]$Root = ".",
  [string]$Folder = "docs/full-chat-summaries",
  [string]$Out = "docs/FULL_CHAT_INDEX.md"
)

$abs = Join-Path $Root $Folder
$files = Get-ChildItem -Path $abs -File -ErrorAction SilentlyContinue | Sort-Object Name

$lines = @()
$lines += "# Full Chat Index"
$lines += ""
$lines += "Below is an index of full chat transcripts stored in \`$Folder\`."
$lines += ""

foreach ($f in $files) {
  $rel = [IO.Path]::Combine($Folder, $f.Name).Replace("\","/")
  $lines += "* [$($f.Name)]($rel)"
}

Set-Content -Path (Join-Path $Root $Out) -Value $lines -Encoding UTF8
Write-Host "[ok] Wrote $Out"
