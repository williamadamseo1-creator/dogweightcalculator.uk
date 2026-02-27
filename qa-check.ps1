$ErrorActionPreference = "Stop"

function Assert-Contains {
  param(
    [string]$Path,
    [string]$Pattern,
    [string]$Message
  )

  $raw = Get-Content -Raw $Path
  if ($raw -notmatch $Pattern) {
    throw "$Message ($Path)"
  }
}

Write-Host "Running QA checks..."

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlFiles = Get-ChildItem -Path $root -Recurse -Filter *.html |
  Where-Object { $_.FullName -notmatch "\\.git\\" }

if ($htmlFiles.Count -eq 0) {
  throw "No HTML files found."
}

foreach ($file in $htmlFiles) {
  Assert-Contains -Path $file.FullName -Pattern '<meta\s+name="viewport"' -Message 'Missing viewport meta'
  Assert-Contains -Path $file.FullName -Pattern '<link\s+rel="canonical"' -Message 'Missing canonical link'
}

Assert-Contains -Path (Join-Path $root 'index.html') -Pattern 'href="/blog/"' -Message 'Homepage missing link to blog'
Assert-Contains -Path (Join-Path $root 'blog\index.html') -Pattern '/blog/puppy-weight-calculator-guide/' -Message 'Blog archive missing expected post link'

$badChars = @([char]0xFFFD, [char]0x00C2)
foreach ($file in $htmlFiles) {
  $raw = Get-Content -Raw $file.FullName
  foreach ($ch in $badChars) {
    if ($raw.Contains([string]$ch)) {
      throw "Potential encoding corruption found in $($file.FullName)"
    }
  }
}

$homeRaw = Get-Content -Raw (Join-Path $root 'index.html')
$ids = [regex]::Matches($homeRaw, 'id="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
$dupes = $ids | Group-Object | Where-Object { $_.Count -gt 1 }
if ($dupes) {
  $list = ($dupes | ForEach-Object { $_.Name }) -join ', '
  throw "Duplicate id attributes found in index.html: $list"
}

Write-Host "QA checks passed."
