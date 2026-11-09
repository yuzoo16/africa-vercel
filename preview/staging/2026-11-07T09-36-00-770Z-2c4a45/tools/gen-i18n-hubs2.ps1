# gen-i18n-hubs2.ps1 — migration/travel-guide/parks/activities/accommodation hubs. ASCII.
. "$PSScriptRoot/gen-common.ps1"
. "$PSScriptRoot/i18n-slugs.ps1"
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$UM = Get-Content "data/i18n-urlmap.json" -Raw | ConvertFrom-Json
$LANGS = @("it","fr","de","es")
$D = @{}
foreach ($g in $LANGS) {
  $D[$g] = @{
    base = ([IO.File]::ReadAllText("data/i18n/"+$g+"-base.json") | ConvertFrom-Json);
    tpl = ([IO.File]::ReadAllText("data/i18n/"+$g+"-tpl.json") | ConvertFrom-Json);
    content = ([IO.File]::ReadAllText("data/i18n/"+$g+"-content.json") | ConvertFrom-Json);
    mig = ([IO.File]::ReadAllText("data/i18n/"+$g+"-mig.json") | ConvertFrom-Json);
    accomm = ([IO.File]::ReadAllText("data/i18n/"+$g+"-accomm.json") | ConvertFrom-Json)
  }
}
$HUBTITLE = @{
 "great-migration"=@{"it"="Grande Migrazione";"fr"="Grande Migration";"de"="Grosse Migration";"es"="Gran Migracion"};
 "travel-guide"=@{"it"="Guida safari";"fr"="Guide safari";"de"="Safari-Guide";"es"="Guia safari"};
 "national-parks"=@{"it"="Parchi nazionali africani";"fr"="Parcs nationaux africains";"de"="Afrikas Nationalparks";"es"="Parques nacionales africanos"};
 "activities"=@{"it"="Attivita safari";"fr"="Activites safari";"de"="Safari-Aktivitaeten";"es"="Actividades safari"};
 "accommodation"=@{"it"="Dove dormire in safari";"fr"="Hebergements safari";"de"="Safari-Unterkuenfte";"es"="Alojamientos safari"}
}
$HUBLEAD = @{
 "great-migration"=@{"it"="La guida completa alla Grande Migrazione: zone, mesi, attraversamenti e safari programmati.";"fr"="Le guide complet de la Grande Migration : zones, mois, traversees et safaris programmes.";"de"="Der komplette Guide Grosse Migration: Zonen, Monate, Querungen, terminierte Safaris.";"es"="La guia completa de la Gran Migracion: zonas, meses, cruces y safaris programados."};
 "travel-guide"=@{"it"="Risposte vere di pianificazione: costi, stagioni, valigie, sicurezza, visti e mance.";"fr"="Vraies reponses de planification : couts, saisons, bagages, securite, visas et pourboires.";"de"="Echte Planungsantworten: Kosten, Saisons, Gepaeck, Sicherheit, Visa, Trinkgeld.";"es"="Respuestas reales de planificacion: costos, temporadas, equipaje, seguridad, visados y propinas."};
 "national-parks"=@{"it"="Guide esperte ai migliori parchi africani: fauna, stagioni, accessi e dove dormire.";"fr"="Guides expertes des meilleurs parcs africains : faune, saisons, acces et ou dormir.";"de"="Expertenguides zu Afrikas besten Parks: Tierwelt, Saisons, Anreise, Uebernachten.";"es"="Guias expertas de los mejores parques africanos: fauna, temporadas, accesos y donde dormir."};
 "activities"=@{"it"="Ogni attivita spiegata: cosa e, dove si fa, quanto costa, quali viaggi la includono.";"fr"="Chaque activite expliquee : en quoi ca consiste, ou, combien, quels voyages l'incluent.";"de"="Jede Aktivitaet erklaert: was, wo, Kosten, welche Reisen enthalten.";"es"="Cada actividad explicada: en que consiste, donde, costos, que viajes la incluyen."};
 "accommodation"=@{"it"="Lodge, campi tendati, mobili e fly camp: dove dormire in safari paese per paese.";"fr"="Lodges, camps tentes, mobiles et fly camps : ou dormir en safari pays par pays.";"de"="Lodges, Zeltcamps, mobile Camps, Flycamps: Safari-Uebernachten Land fuer Land.";"es"="Lodges, campamentos lona, moviles y fly camps: donde dormir en safari pais por pais."}
}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $M=$D[$lang].mig; $A=$D[$lang].accomm
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $cardsFor = @{
   "great-migration"=@();
   "travel-guide"=@();
   "national-parks"=@();
   "activities"=@();
   "accommodation"=@()
  }
  foreach ($hk in @("great-migration","travel-guide","national-parks","activities","accommodation")) {
    $en="/"+$hk+"/"
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $title=$HUBTITLE[$hk][$lang]
    $desc=$HUBLEAD[$hk][$lang]
    $im=$IMG["MIG"]
    if($hk -eq "national-parks"){$im=$IMG["TZ"]}
    if($hk -eq "activities"){$im=$IMG["KE"]}
    if($hk -eq "accommodation"){$im=$IMG["BEACH"]}
    if($hk -eq "travel-guide"){$im=$IMG["TZ"]}
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$title+'</p><h1>'+$title+'</h1><p class="sub">'+$desc+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap"><p class="lead">'+$desc+'</p><div class="grid g3">'
    if($hk -eq "great-migration"){
      foreach($sk in @("month-by-month","mara-river-crossing","calving-season","serengeti","masai-mara","safari-packages","best-time","grumeti-crossing")){
        $su=$UM.("/great-migration/"+$sk+"/").$lang
        $sthumb=$im[0] -replace "w=1800","w=800"
        $st=$M.subs.$sk.title
        $sd=$M.subs.$sk.lead
        if(-not $sd){$sd=$M.subs.$sk.d}
        $body+='<a class="card" href="'+$su+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$st+'"><div class="pad"><h3>'+$st+'</h3><p>'+$sd+'</p></div></a>'
      }
    }
    if($hk -eq "travel-guide"){
      $G=$D[$lang]
      $guides=@{"african-safari-cost"="";"best-time-for-african-safari"="";"what-to-pack-for-safari"="";"safari-safety"="";"safari-tipping"="";"safari-visas"="";"family-safari-guide"="";"first-safari"="";"photography"="";"solo-safari"="";"luxury-safari-guide"=""}
      $GJ=$D[$lang]
      $gd=(Get-Content "data/i18n/$lang-guides.json" -Raw | ConvertFrom-Json)
      foreach($gk in @("african-safari-cost","best-time-for-african-safari","what-to-pack-for-safari","safari-safety","safari-tipping","safari-visas","family-safari-guide","first-safari","photography","solo-safari","luxury-safari-guide")){
        $gu=$UM.("/travel-guide/"+$gk+"/").$lang
        $gt=$gd.$gk.title
        $gl=$gd.$gk.lead
        $gthumb=$im[0] -replace "w=1800","w=800"
        $body+='<a class="card" href="'+$gu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$gthumb+'" alt="'+$gt+'"><div class="pad"><h3>'+$gt+'</h3><p>'+$gl+'</p></div></a>'
      }
    }
    if($hk -eq "national-parks"){
      foreach($pk in @("serengeti","ngorongoro","tarangire","lake-manyara","ruaha","nyerere","masai-mara","amboseli","samburu","lake-naivasha","kruger","etosha","sossusvlei","chobe","okavango-delta","bwindi","kibale")){
        $pu=$UM.("/national-parks/"+$pk+"/").$lang
        $pthumb=$im[0] -replace "w=1800","w=800"
        $body+='<a class="card" href="'+$pu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$pk+'"><div class="pad"><h3>'+$pk+'</h3></div></a>'
      }
    }
    if($hk -eq "activities"){
      $AD=(Get-Content "data/i18n/$lang-acts.json" -Raw | ConvertFrom-Json)
      foreach($ak in @("game-drives","walking-safaris","night-safaris","hot-air-balloon-safari","gorilla-trekking","chimpanzee-trekking","boat-safaris","photographic-safaris","cultural-tours","bird-watching","kilimanjaro-trekking")){
        $au=$UM.("/activities/"+$ak+"/").$lang
        $athumb=$im[0] -replace "w=1800","w=800"
        $body+='<a class="card" href="'+$au+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$athumb+'" alt="'+$AD.$ak.title+'"><div class="pad"><h3>'+$AD.$ak.title+'</h3><p>'+$AD.$ak.lead+'</p></div></a>'
      }
    }
    if($hk -eq "accommodation"){
      foreach($ak in @("tanzania","kenya","uganda","botswana","namibia","south-africa")){
        $au=$UM.("/accommodation/"+$ak+"/").$lang
        $athumb=$im[0] -replace "w=1800","w=800"
        $body+='<a class="card" href="'+$au+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$athumb+'" alt="'+$ak+'"><div class="pad"><h3>'+$ak+'</h3><p>'+$A.countries.$ak+'</p></div></a>'
      }
    }
    $body+='</div>'
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $col='<script type="application/ld+json">{"@context":"https://schema.org","@type":"CollectionPage"}</script>'
    $headExtra='<meta property="og:type" content="website"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$col
    $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
    $outdir=$lang+"/"+$HUB[$hk][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized hub indexes: $n"
