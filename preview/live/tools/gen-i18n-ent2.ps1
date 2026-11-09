# gen-i18n-ent2.ps1 — localized guides, accommodation, migration. Pure ASCII.
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
    guides = ([IO.File]::ReadAllText("data/i18n/"+$g+"-guides.json") | ConvertFrom-Json);
    accomm = ([IO.File]::ReadAllText("data/i18n/"+$g+"-accomm.json") | ConvertFrom-Json);
    mig = ([IO.File]::ReadAllText("data/i18n/"+$g+"-mig.json") | ConvertFrom-Json)
  }
}
function Mk-Faq($faqs){
  $h='<div class="faq"><h2>FAQs</h2>'
  $fi=0
  foreach($x in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $h+="<details$oo><summary>"+$x.q+"</summary><p>"+$x.a+"</p></details>"; $fi++ }
  $h+="</div>"
  $ents=@(); foreach($x in $faqs){ $qq=$x.q -replace '"',"'"; $aa=$x.a -replace '"',"'"; $ents+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
  $sch='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($ents -join ",")+"]}</script>"
  return @{"html"=$h;"schema"=$sch}
}
function Mk-Hre($en,$loc,$UM){
  $enUrl="https://www.adventuresafariafrica.com"+$en
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  return @{"tags"=$hre;"enUrl"=$enUrl}
}
function Mk-Head($title,$desc,$canon,$imUrl){
  return '<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$imUrl+'"><meta name="twitter:card" content="summary_large_image">'
}
function Mk-Page($lang,$canon,$title,$desc,$body,$extra){
  $h='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$extra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  return $h
}
function Mk-Cta($prop,$cons,$B,$T){
  return '<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
}
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
$n=0
$GUIDES = @("african-safari-cost","best-time-for-african-safari","what-to-pack-for-safari","safari-safety","safari-tipping","safari-visas","family-safari-guide","first-safari","photography","solo-safari","luxury-safari-guide")
$THUBNAME = @{"it"="Guida";"fr"="Guide";"de"="Reisefuehrer";"es"="Guia"}
foreach ($gslug in $GUIDES) {
  $en="/travel-guide/"+$gslug+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $G=$D[$lang].guides.$gslug
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $gdir=$HUB["travel-guide"][$lang]
    $title=$G.title
    $desc=$G.lead
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="/'+$lang+'/'+$gdir+'/">'+$THUBNAME[$lang]+'</a> > '+$title+'</nav>'
    $body+='<section class="block"><div class="wrap" style="max-width:840px"><p class="eyebrow">'+$T.nav.learn+'</p><h1>'+$title+'</h1><p class="lead">'+$G.lead+'</p>'
    $body+='<h2>'+$G.s1t+'</h2><p>'+$G.s1+'</p><h2>'+$G.s2t+'</h2><p>'+$G.s2+'</p><h2>'+$G.s3t+'</h2><p>'+$G.s3+'</p>'
    $faqs=@()
    $seed=$gslug.Length*5
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fb=Mk-Faq $faqs
    $body+=$fb.html
    $tgh=$UM."/travel-guide/".($lang)
    $body+='<h2>'+$T.hub.moreAnswers+'</h2><p><a href="'+$tgh+'">'+$T.nav.learn+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
    $body+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'
    $hr=Mk-Hre $en $loc $UM
    $art='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article","headline":"'+$title+'"}</script>'
    $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon "")+$hr.tags+$art+$fb.schema)
    $outdir=$lang+"/"+$gdir+"/"+$GUIDESLUG[$gslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized guides: $n"
$ACCIMG = @{"tanzania"="TZ";"kenya"="KE";"uganda"="UG";"botswana"="BW";"namibia"="NA";"south-africa"="SA"}
$ACCTITLE = @{
 "it"=@{"tanzania"="Dove dormire in Tanzania";"kenya"="Dove dormire in Kenya";"uganda"="Dove dormire in Uganda";"botswana"="Dove dormire in Botswana";"namibia"="Dove dormire in Namibia";"south-africa"="Dove dormire in Sudafrica"};
 "fr"=@{"tanzania"="Ou dormir en Tanzanie";"kenya"="Ou dormir au Kenya";"uganda"="Ou dormir en Ouganda";"botswana"="Ou dormir au Botswana";"namibia"="Ou dormir en Namibie";"south-africa"="Ou dormir en Afrique du Sud"};
 "de"=@{"tanzania"="Uebernachten in Tansania";"kenya"="Uebernachten in Kenia";"uganda"="Uebernachten in Uganda";"botswana"="Uebernachten in Botsuana";"namibia"="Uebernachten in Namibia";"south-africa"="Uebernachten in Suedafrika"};
 "es"=@{"tanzania"="Donde dormir en Tanzania";"kenya"="Donde dormir en Kenia";"uganda"="Donde dormir en Uganda";"botswana"="Donde dormir en Botsuana";"namibia"="Donde dormir en Namibia";"south-africa"="Donde dormir en Sudafrica"}
}
$AHUBT = @{"it"="Dove dormire";"fr"="Hebergements";"de"="Unterkuenfte";"es"="Alojamientos"}
$m=0
foreach ($aslug in @("tanzania","kenya","uganda","botswana","namibia","south-africa")) {
  $en="/accommodation/"+$aslug+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $A=$D[$lang].accomm
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $title=$ACCTITLE[$lang][$aslug]
    $desc=$A.countries.$aslug
    $im=$IMG[$ACCIMG[$aslug]]
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$UM."/accommodation/".($lang)+'">'+$AHUBT[$lang]+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$AHUBT[$lang]+'</p><h1>'+$title+'</h1><p class="sub">'+$desc+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap"><p class="lead">'+$desc+'</p>'
    $body+='<h2>'+$T.hub.accommTitle+'</h2><p>'+$A.hubIntro+'</p>'
    $faqs=@()
    $seed=$aslug.Length*11
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fb=Mk-Faq $faqs
    $body+=$fb.html
    $body+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'
    $hr=Mk-Hre $en $loc $UM
    $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon $im[0])+$hr.tags+$fb.schema)
    $outdir=$lang+"/"+$HUB["accommodation"][$lang]+"/"+$ACCSLUG[$aslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $m++
  }
}
"localized accommodation: $m"
$MSUBS = @("month-by-month","mara-river-crossing","calving-season","serengeti","masai-mara","safari-packages","best-time","grumeti-crossing")
$k=0
foreach ($mslug in $MSUBS) {
  $en="/great-migration/"+$mslug+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $M=$D[$lang].mig
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $S=$M.subs.$mslug
    $title=$S.title
    $desc=$S.lead
    $im=$IMG["MIG"]
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$UM."/great-migration/".($lang)+'">'+$T.nav.migration+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$T.nav.migration+'</p><h1>'+$title+'</h1><p class="sub">'+$desc+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap"><p class="lead">'+$desc+'</p>'
    $pkcards=""
    foreach($pslug in @("tanzania-migration-safari/7-day-migration-safari","tanzania-migration-safari/5-day-migration-safari","kenya-safari/7-day-kenya-safari")){
      $prec=@($DB | Where-Object { $_.slug -eq $pslug })[0]
      if(-not $prec){ continue }
      $su=$UM.("/"+$prec.slug+"/").$lang
      $simg=$IMG["MIG"]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
      $pkcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$prec.duration_days.ToString()+' '+$T.pkg.daysWord+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a></p></div></article>'
    }
    $body+='<h2>'+$T.hub.timedSafarisTitle+'</h2><div class="grid g3">'+$pkcards+'</div>'
    $faqs=@()
    $seed=$mslug.Length*13
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fb=Mk-Faq $faqs
    $body+=$fb.html
    $body+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'
    $hr=Mk-Hre $en $loc $UM
    $art='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article","headline":"'+$title+'"}</script>'
    $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon $im[0])+$hr.tags+$art+$fb.schema)
    $outdir=$lang+"/"+$HUB["great-migration"][$lang]+"/"+$MIGSLUG[$mslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $k++
  }
}
"localized migration subs: $k"
