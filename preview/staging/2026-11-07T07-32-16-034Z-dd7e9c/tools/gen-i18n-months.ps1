# gen-i18n-months.ps1 — localized TZ migration month pages. Pure ASCII.
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
    mig = ([IO.File]::ReadAllText("data/i18n/"+$g+"-mig.json") | ConvertFrom-Json)
  }
}
$MKEY = @{"january"=0;"february"=1;"march"=2;"june"=5;"july"=6;"august"=7;"september"=8;"october"=9}
$DECTOK = @{"Tanzania"="Tansania";"Kenya"="Kenia";"Uganda"="Uganda";"Botswana"="Botsuana";"Namibia"="Namibia";"South Africa"="Suedafrika";"Ethiopia"="Aethiopien";"Kenya & Tanzania"="Kenia-Tansania"}
function Cap1($s){ if(-not $s){return ""}; return $s.Substring(0,1).ToUpper()+$s.Substring(1) }
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
foreach ($mp in @("january","february","march","june","july","august","september","october")) {
  $en="/tanzania-migration-safari/"+$mp+"-migration-safari/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $M=$D[$lang].mig
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $parentUrl=$UM."/tanzania-migration-safari/".($lang)
    $parentName=$B.hubnames."tanzania-migration-safari"
    $monthName=$T.months[$MKEY[$mp]]
    $lead=$M.months.$mp
    $title=$monthName+" "+$parentName
    $desc=$lead
    $im=$IMG["MIG"]
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$parentUrl+'">'+$parentName+'</a> > '+$monthName+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$parentName+'</p><h1>'+$title+'</h1><p class="sub">'+$lead+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap"><p class="lead">'+$lead+'</p>'
    $pcards=""
    foreach($pslug in @("tanzania-migration-safari/7-day-migration-safari","tanzania-migration-safari/5-day-migration-safari")){
      $prec=@($DB | Where-Object { $_.slug -eq $pslug })[0]
      $su=$UM.("/"+$prec.slug+"/").$lang
      $sthumb=$im[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
      $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$prec.duration_days.ToString()+' '+$T.pkg.daysWord+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a></p></div></article>'
    }
    $body+='<h2>'+$T.hub.timedSafarisTitle+'</h2><div class="grid g3">'+$pcards+'</div>'
    $faqs=@()
    $seed=$mp.Length*17
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.hub.beWithHerds+'</h2><p>'+$T.hub.herdLogic+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $headExtra='<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$fqSchema
    $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
    $tzhub=$HUB["tanzania-migration-safari"][$lang]
    $outdir=$loc.Trim("/")
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized months: $n"
