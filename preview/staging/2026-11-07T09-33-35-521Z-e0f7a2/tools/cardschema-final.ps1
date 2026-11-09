# cardschema-final.ps1 — dedupe legacy imageless package cards + add missing schema. ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$files = @("tanzania-safari/index.html","kenya-safari/index.html","uganda-safari/index.html","botswana-safari/index.html","namibia-safari/index.html","south-africa-safari/index.html","ethiopia-safari/index.html","index.html")
foreach ($rel in $files) {
  $t=[IO.File]::ReadAllText((Join-Path $root $rel))
  $imgHrefs=@()
  foreach ($m in [regex]::Matches($t, '<(?:article|a|div) class="card"[^>]*><img[^>]*>[\s\S]*?href="(/[^"]+)"')) { $imgHrefs+=$m.Groups[1].Value }
  foreach ($m in [regex]::Matches($t, '<article class="card"><div class="pad">([\s\S]*?)</div></article>')) {
    $hm=[regex]::Match($m.Groups[1].Value, 'href="(/[^"]+)"')
    if ($hm.Success -and ($imgHrefs -contains $hm.Groups[1].Value)) {
      $t=$t.Replace($m.Value, '')
    }
  }
  [IO.File]::WriteAllText((Join-Path $root $rel), $t)
  "deduped: $rel"
}
function Add-Schema($file,$type,$name){
  $t=[IO.File]::ReadAllText($file)
  if($t -match '"@type"'){ "skip-schema: $file"; return }
  $sch='<script type="application/ld+json">{"@context":"https://schema.org","@type":"'+$type+'","name":"'+$name+'"}</script>'
  $t=$t -replace '</body>', ($sch+'</body>')
  [IO.File]::WriteAllText($file,$t)
  "schema: $file"
}
foreach ($c in @("gorilla-trekking","great-migration","kenya-safari","kilimanjaro","safari-planning","tanzania-safari","travel-tips")) {
  Add-Schema ("blog/category/"+$c+"/index.html") "CollectionPage" ($c+" articles")
}
foreach ($l in @("it/index.html","it/safari-tanzania/index.html","fr/index.html","fr/safari-tanzanie/index.html","de/index.html","de/tansania-safari/index.html","es/index.html","es/safari-tanzania/index.html")) {
  Add-Schema $l "WebPage" "Adventure Safari Africa"
}
Add-Schema "kilimanjaro/success-calculator/index.html" "WebPage" "Kilimanjaro success estimator"
Add-Schema "great-migration-safari/index.html" "WebPage" "Great Migration Safari"
Add-Schema "request-proposal/index.html" "WebPage" "Request a proposal"
Add-Schema "safari-quiz/index.html" "WebPage" "Safari quiz"
"final done"
