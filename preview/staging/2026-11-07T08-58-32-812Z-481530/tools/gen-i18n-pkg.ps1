# gen-i18n-pkg.ps1 — localized package pages (full parity). Pure ASCII.
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
    content = ([IO.File]::ReadAllText("data/i18n/"+$g+"-content.json") | ConvertFrom-Json)
  }
}
$CGATE = @{"Tanzania"="Arusha";"Kenya"="Nairobi";"Uganda"="Entebbe";"Botswana"="Maun";"Namibia"="Windhoek";"South Africa"="Johannesburg";"Ethiopia"="Addis Ababa";"Kenya & Tanzania"="Nairobi"}
$CBASEMULT = @{}
$TREKPARKS = @("Bwindi","Kibale","Simien Mountains","Omo Valley","Udzungwa")
$STYLEHUB = @{"honeymoon"="africa-honeymoon-safaris";"family"="africa-family-safaris";"luxury"="africa-luxury-safaris";"migration"="africa-migration-safaris";"photographic"="africa-photographic-safaris";"private"="private-african-safaris";"tailor-made"="tailor-made-african-safaris";"budget"="africa-budget-safaris";"gorilla"="africa-gorilla-safaris";"trekking"="africa-gorilla-safaris";"beach"="africa-safari-from-zanzibar";"combo"="kenya-tanzania-safari";"classic"="africa-safari-packages";"group"="group-african-safaris"}
$DECTOK = @{"Tanzania"="Tansania";"Kenya"="Kenia";"Uganda"="Uganda";"Botswana"="Botsuana";"Namibia"="Namibia";"South Africa"="Suedafrika";"Ethiopia"="Aethiopien";"Kenya & Tanzania"="Kenia-Tansania"}
function Cap1($s){ if(-not $s){return ""}; return $s.Substring(0,1).ToUpper()+$s.Substring(1) }
function Unaccent($s){
  $r=$s
  $pairs=@(@("á","a"),@("é","e"),@("í","i"),@("ó","o"),@("ú","u"),@("ñ","n"),@("ü","u"),@("à","a"),@("è","e"),@("ì","i"),@("ò","o"),@("ù","u"),@("â","a"),@("ê","e"),@("î","i"),@("ô","o"),@("û","u"),@("ä","a"),@("ö","o"),@("ç","c"))
  foreach($p in $pairs){ $r=$r.Replace($p[0],$p[1]) }
  return $r
}
function Angle-For($dir,$slug){
  if($dir -eq "tanzania-safari"){ return "tz-general" }
  if($dir -eq "tanzania-safari-from-zanzibar"){
    if($slug -match "zanzibar-to-(tarangire|serengeti|ngorongoro|nyerere|mikumi)"){ return "znz-"+$Matches[1] }
    return "znz"
  }
  if($dir -eq "tanzania-migration-safari"){ return "mig-tz" }
  if($dir -eq "southern-tanzania-safari"){
    if($slug -match "mikumi"){ return "south-mikumi" }
    if($slug -match "nyerere"){ return "south-nyerere" }
    if($slug -match "ruaha"){ return "south-ruaha" }
    return "south-grand"
  }
  if($dir -match "^tanzania-(honeymoon|luxury|family|photographic|budget|beach|group)"){ return "tz-"+$Matches[1] }
  if($dir -eq "kenya-safari-from-nairobi"){ return "ke-nairobi" }
  if($dir -eq "masai-mara-safari"){ return "mara" }
  if($dir -eq "kenya-safari"){ if($slug -match "amboseli"){ return "ke-amboseli" }; return "ke-nairobi" }
  if($dir -match "^kenya-(honeymoon|luxury|family|beach)"){ return "ke-"+$Matches[1] }
  if($dir -eq "kenya-tanzania-safari"){ return "ketz" }
  if($dir -eq "uganda-gorilla-trekking"){ return "ug-gorilla" }
  if($dir -eq "uganda-wildlife-safari"){ return "ug-wild" }
  if($dir -eq "uganda-safari"){ return "ug-gorilla" }
  if($dir -eq "botswana-safari"){ return "bw" }
  if($dir -eq "namibia-safari"){ return "na" }
  if($dir -eq "south-africa-safari"){ return "sa" }
  if($dir -eq "ethiopia-safari"){ return "et" }
  return "tz-general"
}
function Dur-Idx($days){
  if($days -le 1){ return 0 }
  if($days -eq 2){ return 1 }
  if($days -le 4){ return 2 }
  if($days -le 6){ return 3 }
  if($days -le 8){ return 4 }
  if($days -le 11){ return 5 }
  return 6
}
function Title-For($lang,$country,$days,$style,$B,$T){
  $C=$B.countries.$country
  if($lang -eq "it"){ $t="Safari "+$C+" di "+$days+" giorni" }
  elseif($lang -eq "fr"){ $t="Safari "+$C+" de "+$days+" jours" }
  elseif($lang -eq "de"){ $t=[string]$days+"-Tage-"+$DECTOK[$country]+"-Safari" }
  else { $t="Safari de "+$days+" d"+[char]0xED+"as en "+$C }
  if($style -notin @("classic","private")){ $t+=" - "+(Cap1 $B.cats.$style) }
  return $t
}
function Faq-Loc($faqs){
  $s='<div class="faq"><h2>PLACEHOLDER</h2>'
  return $s
}
$n=0
foreach ($rec in $DB) {
  $dir=$rec.slug.Split("/")[0]
  $en="/"+$rec.slug+"/"
  $days=$rec.duration_days
  $country=$rec.country
  $style=$rec.safariType
  $gate=$CGATE[$country]
  $parks=@($rec.parks)
  $isZnz = ($dir -match "zanzibar")
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content
    $loc=$UM.$en.$lang
    $hubdir=$HUB[$dir][$lang]
    $hubname=$B.hubnames.$dir
    $title=Title-For $lang $country $days $style $B $T
    $dayOne=$B.dayOne
    if($lang -eq "es"){ $dayOne="D"+[char]0xCD+"A" }
    $angle=Angle-For $dir $rec.slug.Split("/")[1]
    $durline=$C.dur[(Dur-Idx $days)]
    $routeNote=$T.pkg.routeWord+": "+(($parks | ForEach-Object { if($B.parknames.$_) { $B.parknames.$_ } else { $_ } }) -join " - ")
    if($lang -eq "it"){ $routeNote+=" in "+$days+" giorni." }
    elseif($lang -eq "fr"){ $routeNote+=" en "+$days+" jours." }
    elseif($lang -eq "de"){ $routeNote+=" in "+$days+" Tagen." }
    else { $routeNote+=" en "+$days+" d"+[char]0xED+"as." }
    $overview=$C.angles.$angle+" "+$durline+" "+$routeNote+" "+$T.pkg.seasonLogic+": "+$C.seasons.$country
    $tag=$C.angles.$angle+" "+$durline
    $gstr="$" + ('{0:N0}' -f $rec.price_from)
    $peak=[math]::Round(($rec.price_from/0.92*1.12)/50)*50
    $pstr="$" + ('{0:N0}' -f $peak)
    $im=$IMG[$rec.imgkey]; if(-not $im){$im=$IMG["TZ"]}
    $canon="https://www.adventuresafariafrica.com"+$loc
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $parentUrl=$UM.("/"+$dir+"/").$lang
    $shdir=$STYLEHUB[$style]; if(-not $shdir){$shdir="africa-safari-packages"}
    $shUrl=$UM.("/"+$shdir+"/").$lang
    $shName=$B.hubnames.$shdir
    $st=$style
    $best=$C.bestfor.$style; if(-not $best){$best=$C.bestfor.classic}
    $routeHtml=""
    $dayList=@()
    if($days -eq 1){
      $p=$parks[0]
      $dayList+=@{"park"=$p;"title"="one"}
    } else {
      $midN=$days-2
      $seq=@()
      if($midN -ge 1){
        if($midN -le $parks.Count){ $seq=$parks[0..($midN-1)] }
        else { $seq=@()+$parks; for($i=$parks.Count;$i -lt $midN;$i++){ $seq+=$parks[-1] } }
      }
      $dayList+=@{"park"=$parks[0];"title"="d1"}
      foreach($sp in $seq){ $dayList+=@{"park"=$sp;"title"="mid"} }
      $dayList+=@{"park"="";"title"="dn"}
    }
    $dn=0; $prev=$null; $prevEn=$null; $open=" open"
    $RT=$B.routeT
    foreach($dd in $dayList){
      $dn++
      $pk=$dd.park
      $pkLoc=$pk
      if($pk -ne "" -and $B.parknames.$pk){ $pkLoc=$B.parknames.$pk }
      $bl=""
      if($pk -ne "" -and $C.parks.$pk){ $bl=$C.parks.$pk }
      $isT=$TREKPARKS -contains $pk
      $pimg=$im
      if($pk -ne "" -and $PIMG[$pk] -and $IMG[$PIMG[$pk]]){ $pimg=$IMG[$PIMG[$pk]] }
      $thumb=$pimg[0] -replace "w=1800","w=900"
      $segs=""
      if($dd.title -eq "one"){
        $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+$RT.oneDayM+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+$RT.oneDayMid+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+$bl+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+$RT.oneDayEve+"</p>"
        $dt=$dayOne+" 1 - "+$pkLoc
      } elseif($dd.title -eq "d1"){
        $prevEn=$parks[0]
        $p0loc=$parks[0]; if($B.parknames.($parks[0])){$p0loc=$B.parknames.($parks[0])}
        $prev=$p0loc
        if($isZnz){
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+($RT.d1znzM -replace "GATE",$gate)+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+$RT.d1znzMid+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+($RT.d1znzA -replace "PARK",$pkLoc)+" "+$bl+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+$RT.d1znzE+"</p>"
          $dt=$dayOne+" 1 - "+$RT.flyTo+" "+$gate
        } else {
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+($RT.d1arrM -replace "GATE",$gate)+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+$RT.d1arrMid+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+($RT.d1arrA -replace "PARK",$pkLoc)+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+($RT.d1arrE -replace "GATE",$gate)+"</p>"
          $dt=$dayOne+" 1 - "+$RT.arrive+" "+$gate
        }
      } elseif($dd.title -eq "dn"){
        if($isZnz){
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+($RT.depzM -replace "PARK",$prev)+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+$RT.depzMid+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+$RT.depzAft+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+$RT.depzEve+"</p>"
        } else {
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+($RT.depM -replace "PARK",$prev)+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+($RT.depMid -replace "GATE",$gate)+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+$RT.depAft+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+($RT.depEve -replace "GATE",$gate)+"</p>"
        }
        $dt=$dayOne+" "+$days+" - "+$B.facts.ends
      } else {
        $tr=""
        if($prevEn -and $prevEn -ne $pk){
          $tk=$prevEn+"|"+$pk
          $tt=$C.transfers.$tk
          if(-not $tt){$tt=$RT.scenicTransfer}
          $pPrev=$prevEn; if($B.parknames.$prevEn){$pPrev=$B.parknames.$prevEn}
          $tr=" "+$RT.transferWord+" "+$pPrev+" ("+$tt+")."
        }
        if($isT){
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+$RT.trekM+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+$RT.trekMid+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+$RT.trekA+" "+$bl+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+$RT.trekE+"</p>"
        } else {
          $morn=$RT.fullM
          if($prev -eq $null -or $prev -eq ""){ $morn=$RT.firstM }
          $segs="<p><strong>"+$B.dayparts.morning+":</strong> "+$morn+"</p><p><strong>"+$B.dayparts.midday+":</strong> "+($RT.midMid)+"</p><p><strong>"+$B.dayparts.afternoon+":</strong> "+($RT.midAft -replace "PARK",$pkLoc)+" "+$bl+"</p><p><strong>"+$B.dayparts.evening+":</strong> "+$RT.midEve+"</p>"
        }
        if($tr -ne ""){ $segs="<p><em>"+$tr+"</em></p>"+$segs }
        $dt=$dayOne+" "+$dn+" - "+$pkLoc
      }
      $routeHtml+="<details$open><summary>$dt</summary><img loading=`"lazy`" decoding=`"async`" width=`"900`" height=`"560`" src=`"$thumb`" alt=`"$pkLoc`" style=`"border-radius:10px;margin:10px 0`">$segs</details>"
      $open=""
      if($pk -ne ""){ $prev=$pkLoc; $prevEn=$pk }
    }
    $hl="<li><strong>"+$T.pkg.privLine+"</strong></li><li><strong>"+$T.pkg.parksLine+":</strong> "+(($parks | ForEach-Object { if($B.parknames.$_) { $B.parknames.$_ } else { $_ } }) -join ", ")+".</li><li><strong>"+$T.pkg.seasonLine+"</strong></li><li><strong>"+$T.pkg.priceLine+"</strong></li>"
    $seed=$days*7+$dir.Length
    $faqs=@()
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $sibs=@($DB | Where-Object { ($_.slug.Split("/")[0] -eq $dir) -and ($_.slug -ne $rec.slug) } | Select-Object -First 3)
    if($sibs.Count -eq 0){ $sibs=@($DB | Where-Object { ($_.country -eq $country) -and ($_.slug -ne $rec.slug) } | Select-Object -First 3) }
    $relHtml=""
    foreach($sb in $sibs){
      $su=$UM.("/"+$sb.slug+"/").$lang
      $sik=$sb.imgkey; if(-not $sik){$sik="TZ"}
      $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $sb.country $sb.duration_days $sb.safariType $B $T
      $smeta=$sb.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($sb.country)
      if($lang -eq "es"){ $smeta=$sb.duration_days.ToString()+" d"+[char]0xED+"as | "+$B.countries.($sb.country) }
      if($lang -eq "de"){ $smeta=$sb.duration_days.ToString()+" Tage | "+$B.countries.($sb.country) }
      $spr="$" + ('{0:N0}' -f $sb.price_from)
      $relHtml+="<article class=`"card`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$sthumb`" alt=`"$stitle`"><div class=`"pad`"><p class=`"meta`">$smeta</p><h3><a href=`"$su`">$stitle</a></h3><p>$($C.angles.(Angle-For ($sb.slug.Split('/')[0]) ($sb.slug.Split('/')[1])))</p><p><span class=`"price`">"+$B.ui.fromPrice+" "+$spr+"</span></p><p><a class=`"btn btn-o btn-sm`" href=`"$su`">"+$B.ui.viewSafari+"</a> <a class=`"btn btn-p btn-sm`" href=`"$prop`">"+$B.ui.customize+"</a> <a class=`"btn btn-wa btn-sm`" data-wa data-wa-pkg=`"$stitle`" href=`"#`">WhatsApp</a></p></div></article>"
    }
    $parklinks=@()
    foreach($pk in $parks){ if($PNPARK[$pk]){ $pu=$UM.($PNPARK[$pk]).$lang; $pn=$pk; if($B.parknames.$pk){$pn=$B.parknames.$pk}; $parklinks+="<a href=`"$pu`">$pn</a>" } }
    $crumbHome=$B.crumbHome
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $desc=$title+". "+$routeNote+" "+$B.ui.fromPrice+" "+$gstr+" "+$B.ui.perPerson+"."
    $waMsg=$T.waPkg+" "+$title+"."
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$crumbHome+'</a> > <a href="'+$parentUrl+'">'+$hubname+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'" fetchpriority="high"><div class="hero-in"><p class="eyebrow">'+$B.countries.$country+' | '+$days+' '+$T.pkg.daysWord+' | '+$st+'</p><h1>'+$title+'</h1><p class="sub">'+$tag+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestThis+'</a><a class="btn btn-wa" data-wa data-wa-pkg="'+$title+'" data-wa-msg="'+$waMsg+'" href="#">WhatsApp</a><a class="btn btn-o" style="border-color:#fff;color:#fff" href="'+$prop+'">'+$B.ui.customizeThis+'</a></div><div class="hero-meta"><span class="pill">'+$days+' '+$T.pkg.daysWord+'</span><span class="pill">'+$B.ui.fromPrice+' '+$gstr+' '+$B.ui.perPerson+'</span><span class="pill">'+$T.pkg.privateWord+'</span><span class="pill">'+$T.pkg.startEndWord+': '+$gate+'</span></div></div></div>'
    $body+='<section class="block"><div class="wrap"><div class="facts"><div><b>'+$B.facts.duration+'</b>'+$days+' '+$T.pkg.daysWord+'</div><div><b>'+$B.facts.style+'</b>'+$st+'</div><div><b>'+$B.facts.starts+'</b>'+$gate+'</div><div><b>'+$B.facts.ends+'</b>'+$gate+'</div><div><b>'+$T.pkg.greenSeason+' '+$B.ui.fromPrice.ToLower()+'</b>'+$gstr+' '+$B.ui.perPerson+'</div><div><b>'+$T.pkg.peakSeason+' '+$B.ui.fromPrice.ToLower()+'</b>'+$pstr+' '+$B.ui.perPerson+'</div></div>'
    $body+='<h2>'+$B.sec.overview+'</h2><p class="lead">'+$overview+'</p>'
    $body+='<h2>'+$T.pkg.highlightsT+'</h2><ul>'+$hl+'</ul>'
    $body+='<h2>'+$B.sec.itinerary+'</h2><div class="itin">'+$routeHtml+'</div>'
    $body+='<h2>'+$B.sec.accommodation+'</h2><p>'+$T.pkg.accomm+'</p>'
    $body+='<h2>'+$B.sec.vehicle+'</h2><p>'+$T.pkg.vehicle+'</p>'
    $body+='<h2>'+$B.sec.bestFor+'</h2><p>'+$best+'</p>'
    $body+='<h2>'+$T.pkg.pricing+'</h2><table class="cmp"><tr><th>'+$T.pkg.tableSeason+'</th><th>'+$T.pkg.tablePrice+'</th></tr><tr><td>'+$T.pkg.greenSeason+'</td><td>'+$B.ui.fromPrice+' '+$gstr+'</td></tr><tr><td>'+$T.pkg.peakSeason+'</td><td>'+$B.ui.fromPrice+' '+$pstr+'</td></tr></table>'
    $body+='<h2>'+$T.pkg.incTitle+'</h2><p>'+$T.pkg.included+'</p><p>'+$T.pkg.excluded+'</p><p><strong>'+$T.hub.electiveTitle+':</strong> '+$T.pkg.upgrades+'</p>'
    if($parklinks.Count -gt 0){ $body+='<h2>'+$B.sec.parks+'</h2><p>'+($parklinks -join " | ")+'</p>' }
    $body+='<h2>'+$T.pkg.relSafariTitle+'</h2><div class="grid g3">'+$relHtml+'</div><p><a href="'+$parentUrl+'">'+$T.pkg.backHub+'</a> | <a href="'+$shUrl+'">'+$shName+'</a> | <a href="'+$prop+'">'+$T.pkg.customAny+'</a></p>'
    $body+=$fqHtml+'<div class="cta-band" style="margin-top:28px"><div><h2>'+$B.ctaBand.planTitle+'</h2><p>'+$B.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-pkg="'+$title+'" data-wa-msg="'+$waMsg+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $tripSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"TouristTrip","name":"'+$title+'"}</script>'
    $crumbSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"'+$crumbHome+'","item":"https://www.adventuresafariafrica.com/'+$lang+'/"},{"@type":"ListItem","position":2,"name":"'+$hubname+'","item":"https://www.adventuresafariafrica.com'+$parentUrl+'"},{"@type":"ListItem","position":3,"name":"'+$title+'","item":"'+$canon+'"}]}</script>'
    $headExtra='<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="'+$title+'"><meta name="twitter:description" content="'+$desc+'">'+$hre+$tripSchema+$crumbSchema+$fqSchema
    $html=Shell $title $desc $canon $body $headExtra
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$hubdir+"/"+($loc.Split("/")[3])
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized packages rendered: $n (expect 472)"
