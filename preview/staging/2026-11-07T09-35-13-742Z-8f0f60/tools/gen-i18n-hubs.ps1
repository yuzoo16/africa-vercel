# gen-i18n-hubs.ps1 — localized global/cat hubs + package indexes. Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"
. "$PSScriptRoot/i18n-slugs.ps1"
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
$UM = Get-Content "data/i18n-urlmap.json" -Raw | ConvertFrom-Json
$LANGS = @("it","fr","de","es")
$D = @{}
foreach ($g in $LANGS) {
  $D[$g] = @{
    base = ([IO.File]::ReadAllText("data/i18n/"+$g+"-base.json") | ConvertFrom-Json);
    tpl = ([IO.File]::ReadAllText("data/i18n/"+$g+"-tpl.json") | ConvertFrom-Json);
    content = ([IO.File]::ReadAllText("data/i18n/"+$g+"-content.json") | ConvertFrom-Json);
    hubs = ([IO.File]::ReadAllText("data/i18n/"+$g+"-hubs.json") | ConvertFrom-Json);
    globals = ([IO.File]::ReadAllText("data/i18n/"+$g+"-globals.json") | ConvertFrom-Json)
  }
}
$CIMG2 = @{"tanzania-safari"="TZ";"kenya-safari"="KE";"uganda-safari"="UG";"botswana-safari"="BW";"namibia-safari"="NA";"south-africa-safari"="SA";"ethiopia-safari"="ET"}
function Cap1($s){ if(-not $s){return ""}; return $s.Substring(0,1).ToUpper()+$s.Substring(1) }
$DECTOK = @{"Tanzania"="Tansania";"Kenya"="Kenia";"Uganda"="Uganda";"Botswana"="Botsuana";"Namibia"="Namibia";"South Africa"="Suedafrika";"Ethiopia"="Aethiopien";"Kenya & Tanzania"="Kenia-Tansania"}
function Title-For($lang,$country,$days,$style,$B){
  $C=$B.countries.$country
  if($lang -eq "it"){ $t="Safari "+$C+" di "+$days+" giorni" }
  elseif($lang -eq "fr"){ $t="Safari "+$C+" de "+$days+" jours" }
  elseif($lang -eq "de"){ $t=[string]$days+"-Tage-"+$DECTOK[$country]+"-Safari" }
  else { $t="Safari de "+$days+" d"+[char]0xED+"as en "+$C }
  if($style -notin @("classic","private")){ $t+=" - "+(Cap1 $B.cats.$style) }
  return $t
}
function Hub-Img($endir){
  if($endir -match "^tanzania"){ return "TZ" }
  if($endir -match "^kenya|^masai"){ return "KE" }
  if($endir -match "^uganda"){ return "UG" }
  if($endir -match "^botswana"){ return "BW" }
  if($endir -match "^namibia"){ return "NA" }
  if($endir -match "^south"){ return "SA" }
  if($endir -match "^ethiopia"){ return "ET" }
  if($endir -match "honeymoon|beach|zanzibar"){ return "BEACH" }
  if($endir -match "migration|photographic"){ return "MIG" }
  if($endir -match "gorilla"){ return "UG" }
  if($endir -match "budget|namibia"){ return "NA" }
  return "TZ"
}
function Head-Tags($title,$desc,$canon,$enUrl,$UM,$en,$imUrl){
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  return '<meta property="og:type" content="website"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$imUrl+'"><meta name="twitter:card" content="summary_large_image">'+$hre
}
function Fq-Block($faqs){
  $h='<div class="faq"><h2>FAQs</h2>'
  $fi=0
  foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $h+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
  $h+="</div>"
  $ents=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $ents+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
  $sch='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($ents -join ",")+"]}</script>"
  return @{"html"=$h;"schema"=$sch}
}
function Pkg-CardLoc($p,$lang,$B,$T,$UM){
  $su=$UM.("/"+$p.slug+"/").$lang
  $sik=$p.imgkey; if(-not $sik){$sik="TZ"}
  $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
  $stitle=Title-For $lang $p.country $p.duration_days $p.safariType $B
  $smeta=$p.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($p.country)
  if($lang -eq "es"){ $smeta=$p.duration_days.ToString()+" d"+[char]0xED+"as | "+$B.countries.($p.country) }
  if($lang -eq "de"){ $smeta=$p.duration_days.ToString()+" Tage | "+$B.countries.($p.country) }
  $spr="$" + ('{0:N0}' -f $p.price_from)
  $prop=$UM."/request-proposal/".$lang
  return '<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$p.excerpt+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
}
$GCOUNTRIES = @{
 "africa-safaris"=@("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari","ethiopia-safari");
 "africa-honeymoon-safaris"=@("tanzania-safari","kenya-safari","botswana-safari","south-africa-safari","namibia-safari","uganda-safari");
 "africa-family-safaris"=@("tanzania-safari","kenya-safari","botswana-safari","south-africa-safari","namibia-safari","uganda-safari");
 "africa-luxury-safaris"=@("tanzania-safari","kenya-safari","botswana-safari","south-africa-safari","namibia-safari","uganda-safari");
 "africa-migration-safaris"=@("tanzania-safari","kenya-safari");
 "private-african-safaris"=@("tanzania-safari","kenya-safari","botswana-safari","namibia-safari");
 "tailor-made-african-safaris"=@("tanzania-safari","kenya-safari","uganda-safari");
 "africa-safari-packages"=@("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari");
 "kenya-tanzania-safari"=@("kenya-safari","tanzania-safari");
 "africa-safari-from-zanzibar"=@("tanzania-safari","kenya-safari");
 "africa-gorilla-safaris"=@("uganda-safari");
 "africa-photographic-safaris"=@("tanzania-safari","kenya-safari","botswana-safari");
 "africa-budget-safaris"=@("tanzania-safari","namibia-safari","south-africa-safari");
 "east-africa-safari"=@("tanzania-safari","kenya-safari","uganda-safari","ethiopia-safari");
 "southern-africa-safari"=@("botswana-safari","namibia-safari","south-africa-safari");
 "group-african-safaris"=@("tanzania-safari","kenya-safari")
}
$GPKGS = @{
 "africa-safaris"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari","uganda-safari/3-day-gorilla-trekking");
 "africa-honeymoon-safaris"=@("tanzania-honeymoon-safari/7-day-tanzania-honeymoon","kenya-honeymoon-safari/10-day-kenya-honeymoon","south-africa-safari/9-day-south-africa");
 "africa-family-safaris"=@("tanzania-family-safari/6-day-tanzania-family","south-africa-safari/5-day-kruger-safari","kenya-family-safari/7-day-kenya-family");
 "africa-luxury-safaris"=@("tanzania-luxury-safari/7-day-luxury-serengeti","botswana-safari/8-day-botswana-safari","south-africa-safari/9-day-south-africa");
 "africa-migration-safaris"=@("tanzania-migration-safari/7-day-migration-safari","tanzania-migration-safari/5-day-migration-safari","kenya-safari/7-day-kenya-safari");
 "private-african-safaris"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari","botswana-safari/5-day-botswana-safari");
 "tailor-made-african-safaris"=@("tanzania-safari/7-day-tanzania-safari","kenya-tanzania-safari/10-day-kenya-tanzania","uganda-safari/7-day-uganda-safari");
 "africa-safari-packages"=@("tanzania-safari/5-day-tanzania-safari","kenya-safari/3-day-masai-mara-safari","uganda-safari/3-day-gorilla-trekking");
 "kenya-tanzania-safari"=@("kenya-tanzania-safari/7-day-kenya-tanzania","kenya-tanzania-safari/10-day-kenya-tanzania","kenya-tanzania-safari/12-day-kenya-tanzania");
 "africa-safari-from-zanzibar"=@("tanzania-safari-from-zanzibar/2-day-safari-from-zanzibar","tanzania-safari-from-zanzibar/5-day-safari-from-zanzibar","tanzania-safari-from-zanzibar/1-day-safari-from-zanzibar");
 "africa-gorilla-safaris"=@("uganda-safari/3-day-gorilla-trekking","uganda-safari/7-day-uganda-safari","uganda-safari/10-day-uganda-safari");
 "africa-photographic-safaris"=@("tanzania-photographic-safari/8-day-photographic-serengeti","botswana-safari/8-day-botswana-safari","kenya-safari/7-day-kenya-safari");
 "africa-budget-safaris"=@("tanzania-budget-safari/6-day-budget-camping","namibia-safari/7-day-namibia-safari","tanzania-safari/4-day-tanzania-safari");
 "east-africa-safari"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari","uganda-safari/7-day-uganda-safari");
 "southern-africa-safari"=@("botswana-safari/8-day-botswana-safari","namibia-safari/10-day-namibia-safari","south-africa-safari/9-day-south-africa");
 "group-african-safaris"=@("tanzania-group-safari/7-day-tanzania-group","tanzania-group-safari/5-day-tanzania-group","tanzania-safari/7-day-tanzania-safari")
}
$n=0
foreach ($endir in $GCOUNTRIES.Keys) {
  $en="/"+$endir+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $G=$D[$lang].globals
    $hubname=$B.hubnames.$endir
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $im=$IMG[(Hub-Img $endir)]
    $g=$G.globals.$endir
    $title=$hubname+" "+$B.meta.pkgTail
    $desc=$hubname+". "+$g.intro
    $waGen=$T.waGeneral
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$hubname+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$hubname+'"><div class="hero-in"><p class="eyebrow">'+$hubname+'</p><h1>'+$hubname+'</h1><p class="sub">'+$g.intro+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-msg="'+$waGen+'" href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap">'
    $cards=""
    foreach($cd in $GCOUNTRIES[$endir]){
      $cu=$UM.("/"+$cd+"/").$lang
      $cim=$IMG[$CIMG2[$cd]]
      $cthumb=$cim[0] -replace "w=1800","w=800"
      $cards+='<a class="card" href="'+$cu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$cthumb+'" alt="'+$B.hubnames.$cd+'"><div class="pad"><h3>'+$B.hubnames.$cd+'</h3><p>'+$G.countryShort.$cd+'</p></div></a>'
    }
    $body+='<h2>'+$T.hub.bestCountries+'</h2><div class="grid g3">'+$cards+'</div>'
    $pcards=""
    $cmprows=""
    foreach($pslug in $GPKGS[$endir]){
      $prec=@($DB | Where-Object { $_.slug -eq $pslug })[0]
      if(-not $prec){ continue }
      $pcards+=Pkg-CardLoc $prec $lang $B $T $UM
      $ptitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
      $ppr="$" + ('{0:N0}' -f $prec.price_from)
      $cmprows+="<tr><td>"+$ptitle+"</td><td>"+$prec.duration_days.ToString()+" "+$T.pkg.daysWord+"</td><td>"+$B.ui.fromPrice+" "+$ppr+"</td></tr>"
    }
    $body+='<h2>'+$T.hub.featuredPkgs+'</h2><div class="grid g3">'+$pcards+'</div>'
    $body+='<h2>'+$T.hub.compareTitle+'</h2><table class="cmp"><tr><th>'+$T.hub.packagesWord+'</th><th>'+$T.facts.duration+'</th><th>'+$T.pkg.tablePrice+'</th></tr>'+$cmprows+'</table>'
    $faqs=@()
    foreach($fq in $g.faqs){ $faqs+=$fq }
    $seed=$hubname.Length*3
    for($i=0;$i -lt 7;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fb=Fq-Block $faqs
    $body+=$fb.html
    $afUrl=$UM."/africa-safaris/".$lang
    $body+='<h2>'+$T.hub.relGuidesTitle+'</h2><p><a href="'+$afUrl+'">'+$B.hubnames."africa-safaris"+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-msg="'+$waGen+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $headExtra=Head-Tags $title $desc $canon $enUrl $UM $en $im[0]
    $crumbSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"'+$B.crumbHome+'","item":"https://www.adventuresafariafrica.com/'+$lang+'/"},{"@type":"ListItem","position":2,"name":"'+$hubname+'","item":"'+$canon+'"}]}</script>'
    $html=Shell $title $desc $canon $body ($headExtra+$fb.schema+$crumbSchema)
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$HUB[$endir][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized global hubs: $n"
