# gen-i18n-remainder.ps1 — group hub, savanna overview, migration alias. Pure ASCII.
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
    globals = ([IO.File]::ReadAllText("data/i18n/"+$g+"-globals.json") | ConvertFrom-Json)
  }
}
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
function Mk-Hre($en,$UM){
  $enUrl="https://www.adventuresafariafrica.com"+$en
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  return $hre
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
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $G=$D[$lang].globals
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $endir="tanzania-group-safari"
  $en="/"+$endir+"/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $hubname=$B.hubnames.$endir
  $im=$IMG["TZ"]
  $intro=$G.styleBlurb.group+" "+$G.countryShort."tanzania-safari"
  $pcards=""
  $mind=9999; $maxd=0
  foreach($p in ($DB | Where-Object { $_.slug.Split("/")[0] -eq $endir } | Sort-Object duration_days)){
    $su=$UM.("/"+$p.slug+"/").$lang
    $simg=$IMG[$p.imgkey]; $sthumb=$simg[0] -replace "w=1800","w=800"
    $stitle=Title-For $lang $p.country $p.duration_days $p.safariType $B
    $smeta=$p.duration_days.ToString()+" "+$T.pkg.daysWord
    $spr="$" + ('{0:N0}' -f $p.price_from)
    $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$p.excerpt+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
    if($p.duration_days -lt $mind){$mind=$p.duration_days}
    if($p.duration_days -gt $maxd){$maxd=$p.duration_days}
  }
  $faqs=@()
  $seed=$hubname.Length*5
  for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
  $fb=Mk-Faq $faqs
  $parentUrl=$UM."/tanzania-safari/".($lang)
  $parentName=$B.hubnames."tanzania-safari"
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$parentUrl+'">'+$parentName+'</a> > '+$hubname+'</nav>'
  $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$hubname+'"><div class="hero-in"><p class="eyebrow">'+$parentName+'</p><h1>'+$hubname+'</h1><p class="sub">'+$intro+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
  $body+='<section class="block"><div class="wrap"><p class="lead">'+$intro+'</p>'
  $body+='<h2>'+$T.hub.pkgsTitle+'</h2><div class="grid g3">'+$pcards+'</div>'
  $body+='<h2>'+$T.hub.durationsTitle+'</h2><p>'+$mind.ToString()+'-'+$maxd.ToString()+' '+$T.pkg.daysWord+'</p>'
  $body+=$fb.html
  $body+='<h2>'+$T.hub.relGuidesTitle+'</h2><p><a href="'+$parentUrl+'">'+$parentName+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
  $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
  $body+='</div></section></main>'
  $title=$hubname+" "+$B.meta.pkgTail
  $headExtra='<meta property="og:type" content="website"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$intro+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+(Mk-Hre $en $UM)+$fb.schema
  $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$intro+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/i18n-map.js" defer></script><script src="/assets/partials-'+$lang+'.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  $outdir=$lang+"/"+$HUB[$endir][$lang]
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
  $sen="/great-migration-safari/"
  $sloc=$UM.$sen.$lang
  $scanon="https://www.adventuresafariafrica.com"+$sloc
  $tzmig=$UM."/tanzania-migration-safari/".($lang)
  $atitle=$B.hubnames."tanzania-migration-safari"
  $abody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$atitle+'</nav>'
  $abody+='<section class="block"><div class="wrap"><p class="eyebrow">'+$atitle+'</p><h1>'+$atitle+'</h1><p class="lead"><a href="'+$tzmig+'">'+$atitle+'</a></p><p><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a></p></div></section></main>'
  $ahtml='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$atitle+' | Adventure Safari Africa</title><meta name="description" content="'+$atitle+'"><link rel="canonical" href="https://www.adventuresafariafrica.com'+$tzmig+'">'+(Mk-Hre $sen $UM)+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/i18n-map.js" defer></script><script src="/assets/partials-'+$lang+'.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$abody+'<div id="site-footer"></div></body></html>'
  $sout=$sloc.Trim("/")
  New-Item -ItemType Directory -Path $sout -Force | Out-Null
  $ahtml | Out-File -FilePath ($sout+"/index.html") -Encoding utf8
  $n++
  $ven="/national-parks/savanna-parks/"
  $vloc=$UM.$ven.$lang
  $vcanon="https://www.adventuresafariafrica.com"+$vloc
  $vtitle=$B.nav.parks
  $vbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$vtitle+'</nav>'
  $vbody+='<section class="block"><div class="wrap"><p class="eyebrow">'+$vtitle+'</p><h1>'+$vtitle+'</h1><p class="lead">'+$vtitle+'</p><div class="grid g3">'
  $PIMGV = @{"serengeti"="TZ";"ngorongoro"="TZ";"tarangire"="TZ";"masai-mara"="KE";"amboseli"="KE";"kruger"="SA";"etosha"="NA";"chobe"="BW";"okavango-delta"="BW";"bwindi"="UG"}
  $PBLURB = @{
   "serengeti"=@{"it"="Migrazione e grandi felini.";"fr"="Migration et grands felins.";"de"="Migration und Grosskatzen.";"es"="Migracion y grandes felinos."};
   "ngorongoro"=@{"it"="Big Five in un giorno.";"fr"="Big Five en un jour.";"de"="Big Five an einem Tag.";"es"="Big Five en un dia."};
   "tarangire"=@{"it"="Elefanti e baobab.";"fr"="Elephants et baobabs.";"de"="Elefanten und Baobabs.";"es"="Elefantes y baobabs."};
   "masai-mara"=@{"it"="Felini e attraversamenti.";"fr"="Felins et traversees.";"de"="Katzen und Querungen.";"es"="Felinos y cruces."};
   "amboseli"=@{"it"="Zanne e Kilimangiaro.";"fr"="Defenses et Kilimandjaro.";"de"="Stosszahntraeger und Kilimandscharo.";"es"="Colmillos y Kilimanjaro."};
   "kruger"=@{"it"="Leopardi e Big Five.";"fr"="Leopards et Big Five.";"de"="Leoparden und Big Five.";"es"="Leopardos y Big Five."};
   "etosha"=@{"it"="Pozze e rinoceronti.";"fr"="Points d eau et rhinos.";"de"="Wasserloecher und Nashoerner.";"es"="Pozas y rinocerontes."};
   "chobe"=@{"it"="Branchi fluviali.";"fr"="Troupeaux fluviaux.";"de"="Flussherden.";"es"="Manadas fluviales."};
   "okavango-delta"=@{"it"="Mokoro e predatori.";"fr"="Mokoro et predateurs.";"de"="Mokoro und Raubtiere.";"es"="Mokoro y depredadores."};
   "bwindi"=@{"it"="Gorilla di montagna.";"fr"="Gorilles de montagne.";"de"="Berggorillas.";"es"="Gorilas de montana."}
  }
  foreach($pk in @("serengeti","ngorongoro","tarangire","masai-mara","amboseli","kruger","etosha","chobe","okavango-delta","bwindi")){
    $pu=$UM.("/national-parks/"+$pk+"/").$lang
    $pim=$IMG[$PIMGV[$pk]]; $pthumb=$pim[0] -replace "w=1800","w=800"
    $vbody+='<a class="card" href="'+$pu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$pk+'"><div class="pad"><h3>'+$pk+'</h3><p>'+$PBLURB[$pk][$lang]+'</p></div></a>'
  }
  $vbody+='</div><p><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a></p></div></section></main>'
  $vhtml='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$vtitle+' | Adventure Safari Africa</title><meta name="description" content="'+$vtitle+'"><link rel="canonical" href="'+$vcanon+'">'+(Mk-Hre $ven $UM)+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/i18n-map.js" defer></script><script src="/assets/partials-'+$lang+'.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$vbody+'<div id="site-footer"></div></body></html>'
  $vout=$vloc.Trim("/")
  New-Item -ItemType Directory -Path $vout -Force | Out-Null
  $vhtml | Out-File -FilePath ($vout+"/index.html") -Encoding utf8
  $n++
}
"remainder pages: $n (expect 12)"
