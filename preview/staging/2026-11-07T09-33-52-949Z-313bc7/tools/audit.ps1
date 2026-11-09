# audit.ps1 — site-wide audit. Pure ASCII. Writes data/audit.json + prints gap summary.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$files = Get-ChildItem -Recurse -Filter *.html | Where-Object { $_.Name -ne "404.html" }
$recs = @()
$inbound = @{}
foreach ($f in $files) {
  $rel = $f.FullName.Replace($root + [IO.Path]::DirectorySeparatorChar, "").Replace("\","/")
  $u = "/" + ($rel -replace "index\.html$","")
  $c = [IO.File]::ReadAllText($f.FullName)
  $title = ([regex]::Match($c,"<title>([^<]+)</title>").Groups[1].Value)
  $desc = ([regex]::Match($c,'meta name="description" content="([^"]*)"').Groups[1].Value)
  $h1 = ([regex]::Matches($c,"<h1[ >]").Count)
  $faq = ([regex]::Matches($c,"<details>").Count) + ([regex]::Matches($c,"<details ").Count)
  $img = ([regex]::Matches($c,"<img ").Count)
  $cardImg = ([regex]::Matches($c,'class="card"><img').Count) + ([regex]::Matches($c,'class="card"><div class="pad"').Count)
  $cardNoImg = ([regex]::Matches($c,'class="card"><div class="pad"').Count)
  $schemas = @()
  foreach ($m in [regex]::Matches($c,'"@type":\s*"([A-Za-z]+)"')) { if ($schemas -notcontains $m.Groups[1].Value) { $schemas += $m.Groups[1].Value } }
  $canon = ([regex]::Match($c,'rel="canonical" href="([^"]+)"').Groups[1].Value)
  $hre = ([regex]::Matches($c,'rel="alternate" hreflang').Count)
  $links = ([regex]::Matches($c,'href="(/[^"#?]*)"').Count)
  $cta = ($c -match "request-proposal")
  $crumb = ($c -match "crumbs")
  $words = ($c -replace "<[^>]+>"," " -replace "\s+"," ").Trim().Split(" ").Count
  $recs += [pscustomobject]@{url=$u;title=$title;descLen=$desc.Length;h1=$h1;faqs=$faq;imgs=$img;cardsNoImg=$cardNoImg;schemas=($schemas -join ",");canon=$canon;hreflang=$hre;links=$links;cta=$cta;crumb=$crumb;words=$words}
  foreach ($m in [regex]::Matches($c,'href="(/[^"#?]*)"')) {
    $t = $m.Groups[1].Value
    if (-not $inbound.ContainsKey($t)) { $inbound[$t] = 0 }
    $inbound[$t]++
  }
}
foreach ($r in $recs) {
  $k1 = $r.url; $k2 = $r.url.TrimEnd("/")
  $r | Add-Member -NotePropertyName inbound -NotePropertyValue (($inbound[$k1] + $inbound[$k2]) | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
}
$recs | ConvertTo-Json -Depth 4 | Out-File -FilePath "data/audit.json" -Encoding utf8
"pages audited: " + $recs.Count
"--- GAPS ---"
"no-faq: " + ($recs | Where-Object { $_.faqs -eq 0 }).Count
"few-faq(<9): " + ($recs | Where-Object { $_.faqs -gt 0 -and $_.faqs -lt 9 }).Count
"cards-without-images(total): " + ($recs | Measure-Object -Property cardsNoImg -Sum | Select-Object -ExpandProperty Sum)
"no-schema: " + ($recs | Where-Object { $_.schemas -eq "" }).Count
"no-canonical: " + ($recs | Where-Object { $_.canon -eq "" }).Count
"orphans(inbound<=1, excl /): " + ($recs | Where-Object { $_.url -ne "/" -and $_.inbound -le 1 }).Count
"thin(<400 words): " + ($recs | Where-Object { $_.words -lt 400 }).Count
"missing-h1-or-multi: " + ($recs | Where-Object { $_.h1 -ne 1 }).Count
"--- TOP ORPHAN RISKS ---"
$recs | Where-Object { $_.url -ne "/" -and $_.inbound -le 1 } | Select-Object -First 15 url,inbound
"--- THINNEST COMMERCIAL (words) ---"
$recs | Where-Object { $_.url -match "safari|migration|kilimanjaro|gorilla" } | Sort-Object words | Select-Object -First 12 url,words,faqs
