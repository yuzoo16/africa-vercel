# linkboost.ps1 — related-package cards + hub cluster completeness. Pure ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$IMGURL = @{
 TZ="https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800&q=60&auto=format&fit=crop";
 KE="https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800&q=60&auto=format&fit=crop";
 UG="https://images.unsplash.com/photo-1547721064-da6cfb341d50?w=800&q=60&auto=format&fit=crop";
 BW="https://images.unsplash.com/photo-1551009175-8a68da93d5f9?w=800&q=60&auto=format&fit=crop";
 NA="https://images.unsplash.com/photo-1547235001-d703406d3f17?w=800&q=60&auto=format&fit=crop";
 SA="https://images.unsplash.com/photo-1535941339077-2dd1c7963098?w=800&q=60&auto=format&fit=crop";
 ET="https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=800&q=60&auto=format&fit=crop";
 MIG="https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800&q=60&auto=format&fit=crop";
 BEACH="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=60&auto=format&fit=crop";
 CAPE="https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800&q=60&auto=format&fit=crop"
}
$LBL = @{
 "tanzania-safari"="Tanzania";"kenya-safari"="Kenya";"uganda-safari"="Uganda";"botswana-safari"="Botswana";
 "namibia-safari"="Namibia";"south-africa-safari"="South Africa";"ethiopia-safari"="Ethiopia";
 "tanzania-safari-from-zanzibar"="From Zanzibar";"tanzania-migration-safari"="Tanzania Migration";
 "southern-tanzania-safari"="Southern Tanzania";"tanzania-honeymoon-safari"="Tanzania Honeymoon";
 "tanzania-luxury-safari"="Tanzania Luxury";"tanzania-family-safari"="Tanzania Family";
 "tanzania-photographic-safari"="Tanzania Photo";"tanzania-budget-safari"="Tanzania Budget";
 "tanzania-beach-and-safari"="Tanzania Beach";"tanzania-group-safari"="Tanzania Group";
 "kenya-safari-from-nairobi"="From Nairobi";"masai-mara-safari"="Masai Mara";
 "kenya-honeymoon-safari"="Kenya Honeymoon";"kenya-luxury-safari"="Kenya Luxury";
 "kenya-family-safari"="Kenya Family";"kenya-beach-safari"="Kenya Beach";
 "kenya-tanzania-safari"="Kenya and Tanzania";"uganda-gorilla-trekking"="Uganda Gorilla";
 "uganda-wildlife-safari"="Uganda Wildlife"
}
function Money($n){ return "$" + ('{0:N0}' -f $n) }
function PCard($p){
  $u="/"+$p.slug+"/"; $img=$IMGURL[$p.imgkey]; if(-not $img){$img=$IMGURL["TZ"]}
  $meta=$p.duration_days.ToString()+" days | "+$p.country
  return "<article class=`"card`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$img`" alt=`"$($p.name)`"><div class=`"pad`"><p class=`"meta`">$meta</p><h3><a href=`"$u`">$($p.name)</a></h3><p>$($p.excerpt)</p><p><span class=`"price`">From $(Money $p.price_from)</span></p><p><a class=`"btn btn-o btn-sm`" href=`"$u`">View safari</a> <a class=`"btn btn-p btn-sm`" href=`"/request-proposal/`">Customize</a> <a class=`"btn btn-wa btn-sm`" data-wa data-wa-pkg=`"$($p.name)`" href=`"#`">WhatsApp</a></p></div></article>"
}
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
$relFixed = 0; $hubFixed = 0
foreach ($p in $DB) {
  $f = ($p.slug -replace "/","\") + "\index.html"
  if (-not (Test-Path $f)) { continue }
  $t = [IO.File]::ReadAllText((Join-Path $root $f))
  $m = [regex]::Match($t,'<h2>Related safaris</h2><p>.*?</p>')
  if ($m.Success) {
    $dir = $p.slug.Split("/")[0]
    $sibs = @($DB | Where-Object { $_.slug.StartsWith($dir+"/") -and $_.slug -ne $p.slug } | Select-Object -First 3)
    if ($sibs.Count -eq 0) { $sibs = @($DB | Where-Object { $_.country -eq $p.country -and $_.slug -ne $p.slug } | Select-Object -First 3) }
    $cards = ""; foreach ($s in $sibs) { $cards += PCard $s }
    $hub = $p.relatedHubs[0]; $sh = $p.relatedHubs[1]
    $rep = '<h2>Related safaris</h2><div class="grid g3">'+$cards+'</div><p><a href="'+$hub+'">Back to hub</a> | <a href="'+$sh+'">Style hub</a> | <a href="/request-proposal/">Customize any itinerary</a></p>'
    $t = $t.Replace($m.Value, $rep)
    [IO.File]::WriteAllText((Join-Path $root $f), $t)
    $relFixed++
  }
}
"related-cards injected: $relFixed"
foreach ($dir in $LBL.Keys) {
  $hf = Join-Path $root ($dir + "\index.html")
  if (-not (Test-Path $hf)) { continue }
  $t = [IO.File]::ReadAllText($hf)
  $pkgs = @($DB | Where-Object { $_.slug.StartsWith($dir+"/") })
  if ($pkgs.Count -eq 0) { continue }
  $missing = @()
  foreach ($p in $pkgs) { if ($t -notmatch [regex]::Escape("/"+$p.slug+"/")) { $missing += $p } }
  if ($missing.Count -gt 0) {
    $cards = ""; foreach ($m in $missing) { $cards += PCard $m }
    $sec = '<h2>All '+$LBL[$dir]+' packages</h2><div class="grid g3">'+$cards+'</div>'
    $anchor = '<div class="cta-band"'
    $i = $t.IndexOf($anchor)
    if ($i -gt 0) { $t = $t.Insert($i, $sec) } else { $t = $t -replace '</div></section></main>', ($sec+'</div></section></main>') }
    [IO.File]::WriteAllText($hf, $t)
    $hubFixed++
  }
}
"hubs completed with full cluster lists: $hubFixed"
