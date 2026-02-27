function Convert-Inline([string]$text) {
  $encoded = [System.Net.WebUtility]::HtmlEncode($text)
  $encoded = $encoded -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
  $encoded = $encoded -replace '\*(.+?)\*', '<em>$1</em>'
  return $encoded
}

function Convert-MarkdownLite([string]$md) {
  $lines = $md -split "`r?`n"
  $html = New-Object System.Collections.Generic.List[string]
  $inUl = $false
  $inOl = $false
  $paragraph = New-Object System.Collections.Generic.List[string]

  function Flush-Paragraph(
    [System.Collections.Generic.List[string]]$p,
    [System.Collections.Generic.List[string]]$out
  ) {
    if ($p.Count -gt 0) {
      $joined = ($p -join ' ').Trim()
      if ($joined.Length -gt 0) {
        $out.Add("<p>$joined</p>")
      }
      $p.Clear()
    }
  }

  foreach ($rawLine in $lines) {
    $line = $rawLine.Trim()

    if ($line -eq '') {
      Flush-Paragraph $paragraph $html
      if ($inUl) { $html.Add('</ul>'); $inUl = $false }
      if ($inOl) { $html.Add('</ol>'); $inOl = $false }
      continue
    }

    if ($line -match '^#\s+(.+)$') {
      Flush-Paragraph $paragraph $html
      if ($inUl) { $html.Add('</ul>'); $inUl = $false }
      if ($inOl) { $html.Add('</ol>'); $inOl = $false }
      $html.Add("<h1>$(Convert-Inline $matches[1])</h1>")
      continue
    }

    if ($line -match '^##\s+(.+)$') {
      Flush-Paragraph $paragraph $html
      if ($inUl) { $html.Add('</ul>'); $inUl = $false }
      if ($inOl) { $html.Add('</ol>'); $inOl = $false }
      $html.Add("<h2>$(Convert-Inline $matches[1])</h2>")
      continue
    }

    if ($line -match '^###\s+(.+)$') {
      Flush-Paragraph $paragraph $html
      if ($inUl) { $html.Add('</ul>'); $inUl = $false }
      if ($inOl) { $html.Add('</ol>'); $inOl = $false }
      $html.Add("<h3>$(Convert-Inline $matches[1])</h3>")
      continue
    }

    if ($line -match '^-+\s+(.+)$') {
      Flush-Paragraph $paragraph $html
      if ($inOl) { $html.Add('</ol>'); $inOl = $false }
      if (-not $inUl) { $html.Add('<ul>'); $inUl = $true }
      $html.Add("<li>$(Convert-Inline $matches[1])</li>")
      continue
    }

    if ($line -match '^\d+\.\s+(.+)$') {
      Flush-Paragraph $paragraph $html
      if ($inUl) { $html.Add('</ul>'); $inUl = $false }
      if (-not $inOl) { $html.Add('<ol>'); $inOl = $true }
      $html.Add("<li>$(Convert-Inline $matches[1])</li>")
      continue
    }

    $paragraph.Add((Convert-Inline $line))
  }

  Flush-Paragraph $paragraph $html
  if ($inUl) { $html.Add('</ul>') }
  if ($inOl) { $html.Add('</ol>') }
  return ($html -join "`n")
}

$root = Split-Path -Parent $PSScriptRoot
$posts = @(
  @{ Md='blog\posts\01-puppy-weight-calculator-guide.md'; Slug='puppy-weight-calculator-guide'; MainKw='puppy weight calculator' },
  @{ Md='blog\posts\02-dog-weight-calculator-guide.md'; Slug='dog-weight-calculator-guide'; MainKw='dog weight calculator' },
  @{ Md='blog\posts\03-how-big-will-my-puppy-get-guide.md'; Slug='how-big-will-my-puppy-get-guide'; MainKw='how big will my puppy get' },
  @{ Md='blog\posts\04-puppy-growth-calculator-explained.md'; Slug='puppy-growth-calculator-explained'; MainKw='puppy growth calculator' },
  @{ Md='blog\posts\05-puppy-size-calculator-guide.md'; Slug='puppy-size-calculator-guide'; MainKw='puppy size calculator' }
)

foreach ($p in $posts) {
  $mdPath = Join-Path $root $p.Md
  $mdRaw = Get-Content -Raw $mdPath
  $titleLine = ($mdRaw -split "`r?`n" | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1)
  $title = $titleLine -replace '^#\s+', ''

  $bodyMd = $mdRaw -replace '^#\s+.+\r?\n?', ''
  $body = Convert-MarkdownLite $bodyMd
  $plain = ($bodyMd -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 3) -join ' '
  $desc = if ($plain.Length -gt 155) { $plain.Substring(0, 155).TrimEnd() + '...' } else { $plain }
  $desc = [System.Net.WebUtility]::HtmlEncode($desc)

  $slugDir = Join-Path $root ("blog\{0}" -f $p.Slug)
  New-Item -ItemType Directory -Force -Path $slugDir | Out-Null

  $html = @"
<!doctype html>
<html lang="en-GB">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title | Dog Weight Calculator UK Blog</title>
  <meta name="description" content="$desc">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://dogweightcalculator.uk/blog/$($p.Slug)/">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$title">
  <meta property="og:description" content="$desc">
  <meta property="og:url" content="https://dogweightcalculator.uk/blog/$($p.Slug)/">
  <meta property="og:image" content="https://dogweightcalculator.uk/assets/blog-guide-cover.svg">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$title">
  <meta name="twitter:description" content="$desc">
  <meta name="twitter:image" content="https://dogweightcalculator.uk/assets/blog-guide-cover.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Fraunces:opsz,wght@9..144,600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/blog/styles.css">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    "headline": "$title",
    "datePublished": "2026-02-27",
    "dateModified": "2026-02-27",
    "mainEntityOfPage": "https://dogweightcalculator.uk/blog/$($p.Slug)/",
    "author": {
      "@type": "Organization",
      "name": "dogweightcalculator.uk"
    },
    "publisher": {
      "@type": "Organization",
      "name": "dogweightcalculator.uk"
    },
    "keywords": ["$($p.MainKw)", "dog growth guide", "puppy weight chart"]
  }
  </script>
</head>
<body>
  <div class="article-wrap">
    <header class="article-header">
      <p class="crumb"><a href="/">Home</a> / <a href="/blog/">Blog</a></p>
      <h1>$title</h1>
      <p class="meta">Published: 27 February 2026 - Main keyword: $($p.MainKw)</p>
    </header>

    <main class="article">
      <img class="article-cover" src="/assets/blog-guide-cover.svg" alt="Dog growth and puppy weight guide illustration">
      <section class="article-tools" aria-label="Quick tools">
        <h2>Quick Tools</h2>
        <div class="tool-links">
          <a href="/#calculator">Adult Weight Calculator</a>
          <a href="/#chart">Puppy Growth Chart</a>
          <a href="/#faq">FAQ and Accuracy Notes</a>
        </div>
      </section>
$body
      <div class="cta-box">
        <p><strong>Try the calculator:</strong> Use our <a href="/">Dog Weight Calculator UK</a> to estimate adult size in kg/lb.</p>
      </div>
      <section class="related" aria-label="Related guides">
        <h2>Related Guides</h2>
        <ul>
          <li><a href="/blog/puppy-weight-calculator-guide/">Puppy Weight Calculator Guide</a></li>
          <li><a href="/blog/dog-weight-calculator-guide/">Dog Weight Calculator Guide</a></li>
          <li><a href="/blog/how-big-will-my-puppy-get-guide/">How Big Will My Puppy Get?</a></li>
          <li><a href="/blog/puppy-growth-calculator-explained/">Puppy Growth Calculator Explained</a></li>
          <li><a href="/blog/puppy-size-calculator-guide/">Puppy Size Calculator Guide</a></li>
        </ul>
      </section>
    </main>

    <footer class="footer">
      <p><a href="/blog/">&lt;- Back to all blog posts</a></p>
    </footer>
  </div>
</body>
</html>
"@

  Set-Content -Path (Join-Path $slugDir 'index.html') -Value $html -Encoding UTF8
}
