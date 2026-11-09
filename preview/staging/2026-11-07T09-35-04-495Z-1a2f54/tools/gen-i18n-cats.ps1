# gen-i18n-cats.ps1 — localized category hubs. Pure ASCII.
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
$CATDIRS = @("tanzania-safari-from-zanzibar","tanzania-migration-safari","southern-tanzania-safari","tanzania-honeymoon-safari","tanzania-luxury-safari","tanzania-family-safari","tanzania-private-safari","tanzania-photographic-safari","tanzania-budget-safari","tanzania-beach-and-safari","kenya-safari-from-nairobi","masai-mara-safari","kenya-honeymoon-safari","kenya-luxury-safari","kenya-family-safari","kenya-private-safari","kenya-photographic-safari","kenya-beach-safari","kenya-tanzania-safari","uganda-gorilla-trekking","uganda-wildlife-safari","uganda-honeymoon-safari","uganda-luxury-safari","botswana-luxury-safari","botswana-honeymoon-safari","botswana-family-safari","namibia-luxury-safari","namibia-honeymoon-safari","namibia-family-safari","namibia-self-drive","south-africa-luxury-safari","south-africa-honeymoon-safari","south-africa-family-safari")
function Cat-Country($dir){
  if($dir -match "^tanzania-" -or $dir -eq "southern-tanzania-safari"){ return @("Tanzania","tanzania-safari") }
  if($dir -match "^kenya-" -and $dir -ne "kenya-tanzania-safari"){ return @("Kenya","kenya-safari") }
  if($dir -eq "masai-mara-safari"){ return @("Kenya","kenya-safari") }
  if($dir -eq "kenya-tanzania-safari"){ return @("","") }
  if($dir -match "^uganda-"){ return @("Uganda","uganda-safari") }
  if($dir -match "^botswana-"){ return @("Botswana","botswana-safari") }
  if($dir -match "^namibia-"){ return @("Namibia","namibia-safari") }
  if($dir -match "^south-africa-"){ return @("South Africa","south-africa-safari") }
  return @("","")
}
function Cat-Style($dir){
  foreach($s in @("honeymoon","family","luxury","migration","private","photographic","budget","beach","gorilla","wildlife","group","self-drive")){
    if($dir -match $s){ return $s }
  }
  if($dir -match "zanzibar"){ return "znz" }
  if($dir -match "nairobi"){ return "nairobi" }
  if($dir -match "masai-mara"){ return "mara" }
  if($dir -match "kenya-tanzania"){ return "combo" }
  if($dir -match "southern"){ return "southern" }
  return "private"
}
$SEASONGEN = @{"it"="Varia per destinazione e mese.";"fr"="Varie selon destination et mois.";"de"="Je nach Ziel und Monat.";"es"="Varia por destino y mes."}
$STAYGEN = @{"it"="Lodge e campi tendati selezionati per fascia e stagione.";"fr"="Lodges et camps choisis selon gamme et saison.";"de"="Lodges und Camps nach Kategorie und Saison.";"es"="Lodges y campamentos segun categoria y temporada."}
$TELLDATES = @{"it"="Dicci le tue date esatte e verifichiamo.";"fr"="Dites-nous vos dates exactes.";"de"="Nennen Sie exakte Daten.";"es"="Diganos sus fechas exactas."}
$Q1 = @{"it"="Qual e il mese migliore per questo viaggio?";"fr"="Quel est le meilleur mois pour ce voyage ?";"de"="Bester Reisemonat?";"es"="Cual es el mejor mes para este viaje?"}
$Q2 = @{"it"="Quanti giorni servono?";"fr"="Combien de jours faut-il ?";"de"="Wie viele Tage?";"es"="Cuantos dias se necesitan?"}
$Q3 = @{"it"="Quanto costa?";"fr"="Combien ca coute ?";"de"="Was kostet es?";"es"="Cuanto cuesta?"}
$DECTOK = @{"Tanzania"="Tansania";"Kenya"="Kenia";"Uganda"="Uganda";"Botswana"="Botsuana";"Namibia"="Namibia";"South Africa"="Suedafrika";"Ethiopia"="Aethiopien";"Kenya & Tanzania"="Kenia-Tansania"}
function Cap1($s){ if(-not $s){return ""}; return $s.Substring(0,1).ToUpper()+$s.Substring(1) }
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
foreach ($endir in $CATDIRS) {
  $en="/"+$endir+"/"
  $cc=Cat-Country $endir
  $country=$cc[0]; $countrydir=$cc[1]
  $style=Cat-Style $endir
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $G=$D[$lang].globals
    $hubname=$B.hubnames.$endir
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $im=$IMG[(Hub-Img $endir)]
    $styleBlurb=$G.styleBlurb.$style
    $cShort=""
    if($countrydir -ne ""){ $cShort=$G.countryShort.$countrydir }
    $intro=$styleBlurb
    if($cShort -ne ""){ $intro+=" "+$cShort }
    $mine=@($DB | Where-Object { $_.slug.Split("/")[0] -eq $endir } | Sort-Object duration_days)
    $pcards=""
    $mind=9999; $maxd=0; $minp=99999999
    foreach($p in $mine){
      $su=$UM.("/"+$p.slug+"/").$lang
      $sik=$p.imgkey; if(-not $sik){$sik="TZ"}
      $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $p.country $p.duration_days $p.safariType $B
      $smeta=$p.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($p.country)
      if($lang -eq "es"){ $smeta=$p.duration_days.ToString()+" d"+[char]0xED+"as | "+$B.countries.($p.country) }
      if($lang -eq "de"){ $smeta=$p.duration_days.ToString()+" Tage | "+$B.countries.($p.country) }
      $spr="$" + ('{0:N0}' -f $p.price_from)
      $pblurb=$p.excerpt
      $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$pblurb+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
      if($p.duration_days -lt $mind){$mind=$p.duration_days}
      if($p.duration_days -gt $maxd){$maxd=$p.duration_days}
      if($p.price_from -lt $minp){$minp=$p.price_from}
    }
    $durLine=$mind.ToString()+"-"+$maxd.ToString()+" "+$T.pkg.daysWord
    $seasonLine=$SEASONGEN[$lang]
    if($country -ne "" -and $C.seasons.$country){ $seasonLine=$C.seasons.$country }
    $priceLine=$B.ui.fromPrice+" $" + ('{0:N0}' -f $minp)
    $faqs=@(
      @{"q"=$Q1[$lang];"a"=$seasonLine+" "+$TELLDATES[$lang]},
      @{"q"=$Q2[$lang];"a"=$durLine+"."},
      @{"q"=$Q3[$lang];"a"=$priceLine+"."}
    )
    $seed=$hubname.Length*5
    for($i=0;$i -lt 6;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $parentUrl=$UM."/africa-safaris/".$lang
    $parentName=$B.hubnames."africa-safaris"
    if($countrydir -ne ""){ $parentUrl=$UM.("/"+$countrydir+"/").$lang; $parentName=$B.hubnames.$countrydir }
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$parentUrl+'">'+$parentName+'</a> > '+$hubname+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$hubname+'"><div class="hero-in"><p class="eyebrow">'+$parentName+'</p><h1>'+$hubname+'</h1><p class="sub">'+$intro+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$hubname+'" href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap"><p class="lead">'+$intro+'</p>'
    $body+='<h2>'+$T.hub.pkgsTitle+'</h2><div class="grid g3">'+$pcards+'</div>'
    $body+='<h2>'+$T.hub.durationsTitle+'</h2><p>'+$durLine+'</p><p><strong>'+$T.hub.seasonsTitle+':</strong> '+$seasonLine+'</p><p><strong>'+$T.hub.accommTitle+':</strong> '+$STAYGEN[$lang]+'</p>'
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $body+='<h2>'+$T.hub.relGuidesTitle+'</h2><p><a href="'+$parentUrl+'">'+$parentName+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$hubname+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $title=$hubname+" "+$B.meta.pkgTail
    $desc=$hubname+". "+$intro
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $crumbSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"'+$B.crumbHome+'","item":"https://www.adventuresafariafrica.com/'+$lang+'/"},{"@type":"ListItem","position":2,"name":"'+$parentName+'","item":"https://www.adventuresafariafrica.com'+$parentUrl+'"},{"@type":"ListItem","position":3,"name":"'+$hubname+'","item":"'+$canon+'"}]}</script>'
    $headExtra='<meta property="og:type" content="website"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$fqSchema+$crumbSchema
    $html=Shell $title $desc $canon $body $headExtra
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$HUB[$endir][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized cat hubs: $n"
