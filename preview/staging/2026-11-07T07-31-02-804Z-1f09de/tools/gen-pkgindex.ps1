# gen-pkgindex.ps1 — full country package indexes. Pure ASCII, heredoc-based.
. "$PSScriptRoot/gen-common.ps1"
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
function Money($n){ return "$" + ('{0:N0}' -f $n) }
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
  $dir=$c[0]; $label=$c[1]; $hub=$c[2]; $lede=$c[3]
  $pkgs = @($DB | Where-Object { $_.country -eq $label } | Sort-Object duration_days)
  $cards=""
  foreach($p in $pkgs){
    $u="/"+$p.slug+"/"
    $ik=$p.imgkey
    if(-not $ik){$ik="TZ"}
    $im=$IMG[$ik]
    $thumb=$im[0] -replace "w=1800","w=800"
    $meta=$p.duration_days.ToString()+" days | "+$p.country
    $pr=Money $p.price_from
    $cards+="<article class="+[char]34+"card"+[char]34+"><img loading="+[char]34+"lazy"+[char]34+" src="+[char]34+$thumb+[char]34+" alt="+[char]34+$p.name+[char]34+"><div class="+[char]34+"pad"+[char]34+"><p class="+[char]34+"meta"+[char]34+">"+$meta+"</p><h3><a href="+[char]34+$u+[char]34+">"+$p.name+"</a></h3><p>"+$p.excerpt+"</p><p><span class="+[char]34+"price"+[char]34+">From "+$pr+"</span></p><p><a class="+[char]34+"btn btn-o btn-sm"+[char]34+" href="+[char]34+$u+[char]34+">View safari</a> <a class="+[char]34+"btn btn-p btn-sm"+[char]34+" href="+[char]34+"/request-proposal/"+[char]34+">Customize</a> <a class="+[char]34+"btn btn-wa btn-sm"+[char]34+" data-wa data-wa-pkg="+[char]34+$p.name+[char]34+" href="+[char]34+"#"+[char]34+">WhatsApp</a></p></div></article>"
  }
  $n=$pkgs.Count
  $f1="How many "+$label+" packages do you offer?"
  $a1="This index lists all "+$n+" current "+$label+" itineraries, from short expresses to grand tours. Every one is private and customizable."
  $f2="What does a "+$label+" safari cost?"
  $a2="See per-package from-prices on the cards above (green-season baselines, park fees included). Final quotes depend on season, camp tier and group size - always line-itemed."
  $f3="How far ahead should we book "+$label+"?"
  $a3="Migration and permit seasons 6-12 months ahead; green-season value trips 2-4 months. Camp and flight availability - not price - is the real constraint."
  $f4="Can we combine "+$label+" with other countries?"
  $a4="Routinely: Kenya plus Tanzania, safari plus Zanzibar or Diani, Uganda plus Kenya. Ask for multi-country routings in one proposal."
  $f5="Are these trips private?"
  $a5="Yes - every package runs with your own vehicle and guide on your dates. Group departures are listed separately where available."
  $faqs=@(@{"q"=$f1;"a"=$a1},@{"q"=$f2;"a"=$a2},@{"q"=$f3;"a"=$a3},@{"q"=$f4;"a"=$a4},@{"q"=$f5;"a"=$a5})
  $crumbs='<main id="main"><nav class="wrap crumbs"><a href="/">Home</a> > <a href="/'+$dir+'/">'+$hub+'</a> > Packages</nav>'
  $schema=Faq-Schema $faqs
  $faqlist=Faq-List $faqs
  $body=$crumbs+"<section class="+[char]34+"block"+[char]34+"><div class="+[char]34+"wrap"+[char]34+"><p class="+[char]34+"eyebrow"+[char]34+">Compare packages</p><h1>"+$label+" safari packages</h1><p class="+[char]34+"lead"+[char]34+">"+$lede+"</p>"
  $body+="<div class="+[char]34+"grid g3"+[char]34+">"+$cards+"</div>"
  $body+=$faqlist+"<p><a href="+[char]34+"/"+$dir+"/"+[char]34+">Back to "+$hub+" hub</a> | <a href="+[char]34+"/request-proposal/"+[char]34+">Custom proposal</a> | <a href="+[char]34+"/safari-quiz/"+[char]34+">Safari quiz</a></p>"
  $body+=(CTA-Band "Want it tailored?" "Mix durations, camps and extensions in one proposal." ($label+" packages"))+"</div></section></main>"
  $canon="https://www.adventuresafariafrica.com/"+$dir+"/packages/"
  $html=Shell ($label+" Safari Packages") ("Compare "+$label+" safari packages with honest from-prices.") $canon $body $schema
  $html | Out-File -FilePath "$dir/packages/index.html" -Encoding utf8
  "pkgindex: $dir ($n pkgs)"
}
