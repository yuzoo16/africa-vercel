# i18n-hubs3-boost.ps1 — append FAQ sections to inherited hub indexes. Pure ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$LANGS = @("it","fr","de","es")
# The directory names this selects are the ENGLISH slugs every tree now shares.
# Listing the old translated names here matched nothing once slugs were unified,
# which would have silently skipped every hub.
$HUBS = @("national-parks","activities","travel-guide","great-migration","accommodation")
$n=0
foreach ($lang in $LANGS) {
  $C = ([IO.File]::ReadAllText("data/i18n/"+$lang+"-content.json") | ConvertFrom-Json)
  $dirs = Get-ChildItem $lang -Directory | Where-Object { $HUBS -contains $_.Name }
  foreach ($d in $dirs) {
    $f = Join-Path $d.FullName "index.html"
    $t = [IO.File]::ReadAllText($f)
    if ($t -match '<div class="faq">') { continue }
    $seed = $d.Name.Length * 29
    $faqs = @()
    for ($i=0; $i -lt 9; $i++) { $faqs += $C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml = '<div class="faq"><h2>FAQs</h2>'
    $fi = 0
    foreach ($fq in $faqs) {
      $oo = ""
      if ($fi -eq 0) { $oo = " open" }
      $fqHtml += "<details$oo><summary>" + $fq.q + "</summary><p>" + $fq.a + "</p></details>"
      $fi++
    }
    $fqHtml += "</div>"
    $ents = @()
    foreach ($fq in $faqs) {
      $qq = $fq.q -replace '"',"'"
      $aa = $fq.a -replace '"',"'"
      $ents += '{"@type":"Question","name":"' + $qq + '","acceptedAnswer":{"@type":"Answer","text":"' + $aa + '"}}'
    }
    $sch = '<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' + ($ents -join ",") + "]}</script>"
    $anchor = '<div class="cta-band"'
    $idx = $t.IndexOf($anchor)
    if ($idx -gt 0) { $t = $t.Substring(0,$idx) + $fqHtml + $t.Substring($idx) } else { $t = $t -replace "</div></section></main>", ($fqHtml + "</div></section></main>") }
    $t = $t -replace "</body>", ($sch + "</body>")
    [IO.File]::WriteAllText($f, $t)
    $n++
  }
}
"hub FAQ boosts: $n"
