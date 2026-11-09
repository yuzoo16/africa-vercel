# gen-pkgindex.ps1 — full country package indexes with image cards + FAQs. ASCII.
. "$PSScriptRoot/gen-common.ps1"
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
function Money($n){ return "$" + ('{0:N0}' -f $n) }
function PCard($p){
  $u="/"+$p.slug+"/"; $ik=$p.imgkey; if(-not $ik){$ik="TZ"}
  $im=$IMG[$ik]; $thumb=$im[0] -replace "w=1800","w=800"
  $meta=$p.duration_days.ToString()+" days | "+$p.country
  return "<article class=`"card`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$thumb`" alt=`"$($p.name)`"><div class=`"pad`"><p class=`"meta`">$meta</p><h3><a href=`"$u`">$($p.name)</a></h3><p>$($p.excerpt)</p><p><span class=`"price`">From $(Money $p.price_from)</span></p><p><a class=`"btn btn-o btn-sm`" href=`"$u`">View safari</a> <a class=`"btn btn-p btn-sm`" href=`"/request-proposal/`">Customize</a> <a class=`"btn btn-wa btn-sm`" data-wa data-wa-pkg=`"$($p.name)`" href=`"#`">WhatsApp</a></p></div></article>"
}
$COUNTRIES = @(
 @("tanzania-safari","Tanzania","Tanzania Safari","Northern circuit, Migration, southern parks and Zanzibar combinations - every duration from 2 to 14 days."),
 @("kenya-safari","Kenya","Kenya Safari","Mara fly-ins, Nairobi loops, Amboseli and bush-to-beach - 2 to 12 days."),
 @("uganda-safari","Uganda","Uganda Safari","Gorilla treks, primate circuits and grand wildlife tours - permits handled."),
 @("botswana-safari","Botswana","Botswana Safari","Delta water camps, Chobe herds and predator concessions - fly-in journeys."),
 @("namibia-safari","Namibia","Namibia Safari","Dunes, coast, Damaraland and Etosha - guided or self-drive loops."),
 @("south-africa-safari","South Africa","South Africa Safari","Kruger concessions plus Cape Town, winelands and Garden Route."),
 @("ethiopia-safari","Ethiopia","Ethiopia Tours","Historic north, Simien trekking and Omo Valley cultures.")
)
foreach ($c in $COUNTRIES) {
"PART1-OK"