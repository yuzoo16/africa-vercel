# i18n-urlmap.ps1 — computes localized URL for every entity. Pure ASCII.
. "$PSScriptRoot/i18n-slugs.ps1"
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
$LANGS = @("it","fr","de","es")
$SLUGTOK = @{
 "migration"=@{"it"="migrazione";"fr"="migration";"de"="migration";"es"="migracion"};
 "luxury"=@{"it"="lusso";"fr"="luxe";"de"="luxus";"es"="lujo"};
 "honeymoon"=@{"it"="luna-di-miele";"fr"="lune-de-miel";"de"="flitterwochen";"es"="luna-de-miel"};
 "family"=@{"it"="famiglia";"fr"="famille";"de"="familie";"es"="familia"};
 "photographic"=@{"it"="foto";"fr"="photo";"de"="foto";"es"="foto"};
 "budget"=@{"it"="budget";"fr"="budget";"de"="budget";"es"="economico"};
 "camping"=@{"it"="camping";"fr"="camping";"de"="camping";"es"="camping"};
 "group"=@{"it"="gruppo";"fr"="groupe";"de"="gruppe";"es"="grupo"};
 "private"=@{"it"="privato";"fr"="prive";"de"="privat";"es"="privado"};
 "wildlife"=@{"it"="fauna";"fr"="faune";"de"="tierwelt";"es"="fauna"};
 "trekking"=@{"it"="trekking";"fr"="trekking";"de"="trekking";"es"="trekking"};
 "gorilla"=@{"it"="gorilla";"fr"="gorilles";"de"="gorilla";"es"="gorilas"};
 "beach"=@{"it"="spiaggia";"fr"="plage";"de"="strand";"es"="playa"};
 "dunes"=@{"it"="dune";"fr"="dunes";"de"="duenen";"es"="dunas"};
 "coast"=@{"it"="costa";"fr"="cote";"de"="kueste";"es"="costa"};
 "desert"=@{"it"="deserto";"fr"="desert";"de"="wueste";"es"="desierto"};
 "falls"=@{"it"="cascate";"fr"="chutes";"de"="faelle";"es"="cataratas"};
 "valley"=@{"it"="valle";"fr"="vallee";"de"="tal";"es"="valle"};
 "loop"=@{"it"="loop";"fr"="boucle";"de"="runde";"es"="loop"};
 "highlights"=@{"it"="highlight";"fr"="points-forts";"de"="highlights";"es"="destacados"};
 "express"=@{"it"="express";"fr"="express";"de"="express";"es"="expreso"};
 "explorer"=@{"it"="explorer";"fr"="explorateur";"de"="entdecker";"es"="explorador"};
 "complete"=@{"it"="completo";"fr"="complete";"de"="komplett";"es"="completo"};
 "ultimate"=@{"it"="ultimate";"fr"="ultime";"de"="ultimativ";"es"="definitivo"};
 "grand"=@{"it"="grande";"fr"="grande";"de"="grosse";"es"="gran"};
 "historic"=@{"it"="storico";"fr"="historique";"de"="historisch";"es"="historico"};
 "tour"=@{"it"="tour";"fr"="tour";"de"="tour";"es"="tour"};
 "from"=@{"it"="da";"fr"="depuis";"de"="ab";"es"="desde"};
 "to"=@{"it"="a";"fr"="a";"de"="nach";"es"="a"};
 "and"=@{"it"="e";"fr"="et";"de"="und";"es"="y"};
 "with"=@{"it"="con";"fr"="avec";"de"="mit";"es"="con"};
 "crater"=@{"it"="cratere";"fr"="cratere";"de"="krater";"es"="crater"};
 "lake"=@{"it"="lago";"fr"="lac";"de"="see";"es"="lago"};
 "cape"=@{"it"="capo";"fr"="cap";"de"="kap";"es"="cabo"};
 "garden"=@{"it"="garden";"fr"="jardin";"de"="garten";"es"="jardin"};
 "city"=@{"it"="citta";"fr"="ville";"de"="stadt";"es"="ciudad"};
 "winelands"=@{"it"="winelands";"fr"="vignobles";"de"="weinlaender";"es"="vinedos"};
 "northern"=@{"it"="nord";"fr"="nord";"de"="nord";"es"="norte"};
 "southern"=@{"it"="sud";"fr"="sud";"de"="sued";"es"="sur"};
 "central"=@{"it"="centrale";"fr"="central";"de"="zentral";"es"="central"};
 "western"=@{"it"="ovest";"fr"="ouest";"de"="west";"es"="oeste"}
}
$MONTHSLUG = @{
 "january"=@{"it"="gennaio";"fr"="janvier";"de"="januar";"es"="enero"};
 "february"=@{"it"="febbraio";"fr"="fevrier";"de"="februar";"es"="febrero"};
 "march"=@{"it"="marzo";"fr"="mars";"de"="maerz";"es"="marzo"};
 "june"=@{"it"="giugno";"fr"="juin";"de"="juni";"es"="junio"};
 "july"=@{"it"="luglio";"fr"="juillet";"de"="juli";"es"="julio"};
 "august"=@{"it"="agosto";"fr"="aout";"de"="august";"es"="agosto"};
 "september"=@{"it"="settembre";"fr"="septembre";"de"="september";"es"="septiembre"};
 "october"=@{"it"="ottobre";"fr"="octobre";"de"="oktober";"es"="octubre"}
}
$SKIPTOK = @("tanzania","kenya","uganda","botswana","namibia","south","africa","ethiopia","safari","safaris","day","days","masai","mara","serengeti","ngorongoro","tarangire","kilimanjaro","zanzibar","nairobi","bwindi","kibale","okavango","chobe","etosha","kruger","amboseli","samburu","ruaha","nyerere","mikumi","simien","lalibela","omo","diani","lake","manyara","naivasha","nakuru","murchison","queen","elizabeth","katavi","mahale","arusha","crater","delta","falls")
function Pkg-Slug($rec,$lang,$used){
  $dir=$rec.slug.Split("/")[0]; $hub=$HUB[$dir][$lang]
  $dw=$DAYW[$lang]; $days=$rec.duration_days
  $base=$hub+"-"+$days+"-"+$dw
  $slug=$rec.slug.Split("/")[1]
  $cand=$base
  if($used -contains ($hub+"/"+$cand)){
    $toks=@()
    if($slug -match "zanzibar-to-([a-z]+)"){
      $toks+=@($Matches[1])
    } else {
      foreach($tk in ($slug -split "-")){
        if($tk -match "^\d+$"){ continue }
        if($SKIPTOK -contains $tk){ continue }
        if($tk -eq "day" -or $tk -eq "days"){ continue }
        if($SLUGTOK.ContainsKey($tk)){ $toks+=$SLUGTOK[$tk][$lang] } else { $toks+=$tk }
      }
    }
    if($toks.Count -eq 0){ $toks+=@("safari") }
    $cand=$base+"-"+($toks -join "-")
    $k=2
    while($used -contains ($hub+"/"+$cand)){ $cand=$base+"-"+($toks -join "-")+"-"+$k; $k++ }
  }
  return $cand
}
$MAP = @{}
function Put-Map($en,$locs){ $MAP[$en]=$locs }
# A route is the English slug with only the language prefix added, so an entry
# that must be spelled out takes four identical values, not four translations
function Put-Map-Plain($en){ $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+$en }; Put-Map $en $l }
Put-Map "/" @{"it"="/it/";"fr"="/fr/";"de"="/de/";"es"="/es/"}
foreach ($d in $HUB.Keys) {
  $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+"/"+$HUB[$d][$g]+"/" }
  Put-Map ("/"+$d+"/") $l
}
foreach ($p in $PARKSLUG.Keys) {
  $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+"/"+$HUB["national-parks"][$g]+"/"+$PARKSLUG[$p][$g]+"/" }
  Put-Map ("/national-parks/"+$p+"/") $l
}
foreach ($a in $ACTSLUG.Keys) {
  $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+"/"+$HUB["activities"][$g]+"/"+$ACTSLUG[$a][$g]+"/" }
  Put-Map ("/activities/"+$a+"/") $l
}
foreach ($k in $KILISLUG.Keys) {
  $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+"/"+$HUB["kilimanjaro"][$g]+"/"+$KILISLUG[$k][$g]+"/" }
  Put-Map ("/kilimanjaro/"+$k+"/") $l
}
foreach ($m in $MIGSLUG.Keys) {
  $l=@{}; foreach($g in $LANGS){ $l[$g]="/"+$g+"/"+$HUB["great-migration"][$g]+"/"+$MIGSLUG[$m][$g]+"/" }
  Put-Map ("/great-migration/"+$m+"/") $l
}
Put-Map-Plain "/great-migration-safari/"
foreach ($g in $GUIDESLUG.Keys) {
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB["travel-guide"][$gg]+"/"+$GUIDESLUG[$g][$gg]+"/" }
  Put-Map ("/travel-guide/"+$g+"/") $l
}
Put-Map-Plain "/travel-guide/"
Put-Map-Plain "/national-parks/"
Put-Map-Plain "/activities/"
Put-Map-Plain "/kilimanjaro/"
Put-Map-Plain "/great-migration/"
Put-Map-Plain "/accommodation/"
foreach ($a in $ACCSLUG.Keys) {
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB["accommodation"][$gg]+"/"+$ACCSLUG[$a][$gg]+"/" }
  Put-Map ("/accommodation/"+$a+"/") $l
}
Put-Map "/blog/" @{"it"="/it/blog/";"fr"="/fr/blog/";"de"="/de/blog/";"es"="/es/blog/"}
foreach ($b in $BLOGSLUG.Keys) {
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB["blog"][$gg]+"/"+$BLOGSLUG[$b][$gg]+"/" }
  Put-Map ("/blog/"+$b+"/") $l
}
foreach ($c in $BLOGCAT.Keys) {
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB["blog"][$gg]+"/category-"+$BLOGCAT[$c][$gg]+"/" }
  Put-Map ("/blog/category/"+$c+"/") $l
}
foreach ($s in @("about","request-proposal","safari-consultation","safari-quiz","search")) {
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB[$s][$gg]+"/" }
  Put-Map ("/"+$s+"/") $l
}
$MIGWORD=@{"it"="migrazione";"fr"="migration";"de"="migration";"es"="migracion"}
foreach ($mp in @("january","february","march","june","july","august","september","october")) {
  $en="/tanzania-migration-safari/"+$mp+"-migration-safari/"
  $l=@{}; foreach($gg in $LANGS){ $l[$gg]="/"+$gg+"/"+$HUB["tanzania-migration-safari"][$gg]+"/"+$MONTHSLUG[$mp][$gg]+"-"+$MIGWORD[$gg]+"/" }
  Put-Map $en $l
}
$used=@{}
foreach ($lang in $LANGS) { $used[$lang]=@() }
foreach ($rec in ($DB | Sort-Object { $_.slug })) {
  $en="/"+$rec.slug+"/"
  $rdir=$rec.slug.Split("/")[0]
  $l=@{}
  foreach($lang in $LANGS){
    $hdir=$HUB[$rdir][$lang]
    $s=Pkg-Slug $rec $lang $used[$lang]
    $used[$lang]+=$hdir+"/"+$s
    $l[$lang]="/"+$lang+"/"+$hdir+"/"+$s+"/"
  }
  Put-Map $en $l
}
# --- URL SLUG NORMALIZATION ---------------------------------------------------
# $MAP is keyed by the ENGLISH slug, and that key must be the route in every
# language: only the language prefix may differ (/tanzania-safari -> /de/tanzania-safari).
# Normalising here, once, at the single point all 19 gen-i18n-*.ps1 scripts and
# i18n-hreflang.ps1 read via $UM, is what stops a translated slug reaching a
# canonical, an hreflang cluster or a language switcher entry again.
# This cannot be done at the construction sites instead: none of them reproduces
# the English slug even with identity dictionaries - the month rows emit
# "january-migration" while the real slug is "january-migration-safari".
$FIXED = @{}
foreach ($k in $MAP.Keys) {
  $f = @{}
  foreach ($g in $LANGS) {
    if ($k -eq "/") { $f[$g] = "/"+$g+"/" } else { $f[$g] = "/"+$g+$k }
  }
  $FIXED[$k] = $f
}
$MAP = $FIXED
$MAP | ConvertTo-Json -Depth 5 | Out-File -FilePath "data/i18n-urlmap.json" -Encoding utf8
"mapped EN urls: " + $MAP.Count
