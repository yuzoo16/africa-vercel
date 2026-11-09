# gen-i18n-ent1.ps1 — localized parks + activities. Pure ASCII.
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
    acts = ([IO.File]::ReadAllText("data/i18n/"+$g+"-acts.json") | ConvertFrom-Json)
  }
}
$PARKMETA = @{
 "serengeti"=@("Central Serengeti","Tanzania","3-4");"ngorongoro"=@("Ngorongoro Crater","Tanzania","1");
 "tarangire"=@("Tarangire","Tanzania","1-2");"lake-manyara"=@("Lake Manyara","Tanzania","0.5-1");
 "ruaha"=@("Ruaha","Tanzania","3+");"nyerere"=@("Nyerere","Tanzania","2-3");
 "masai-mara"=@("Masai Mara","Kenya","3-4");"amboseli"=@("Amboseli","Kenya","2");
 "samburu"=@("Samburu","Kenya","2-3");"lake-naivasha"=@("Lake Naivasha","Kenya","1-2");
 "kruger"=@("Kruger","South Africa","3-5");"etosha"=@("Etosha","Namibia","2-3");
 "sossusvlei"=@("Sossusvlei","Namibia","1-2");"chobe"=@("Chobe","Botswana","2");
 "okavango-delta"=@("Okavango Delta","Botswana","2-3");"bwindi"=@("Bwindi","Uganda","2-3");
 "kibale"=@("Kibale","Uganda","1-2")
}
$PARKNAME = @{
 "serengeti"=@{"it"="Serengeti";"fr"="Serengeti";"de"="Serengeti";"es"="Serengeti"};
 "ngorongoro"=@{"it"="Ngorongoro";"fr"="Ngorongoro";"de"="Ngorongoro";"es"="Ngorongoro"};
 "tarangire"=@{"it"="Tarangire";"fr"="Tarangire";"de"="Tarangire";"es"="Tarangire"};
 "lake-manyara"=@{"it"="Lago Manyara";"fr"="Lac Manyara";"de"="Manyara-See";"es"="Lago Manyara"};
 "ruaha"=@{"it"="Ruaha";"fr"="Ruaha";"de"="Ruaha";"es"="Ruaha"};
 "nyerere"=@{"it"="Nyerere";"fr"="Nyerere";"de"="Nyerere";"es"="Nyerere"};
 "masai-mara"=@{"it"="Masai Mara";"fr"="Masai Mara";"de"="Masai Mara";"es"="Masai Mara"};
 "amboseli"=@{"it"="Amboseli";"fr"="Amboseli";"de"="Amboseli";"es"="Amboseli"};
 "samburu"=@{"it"="Samburu";"fr"="Samburu";"de"="Samburu";"es"="Samburu"};
 "lake-naivasha"=@{"it"="Lago Naivasha";"fr"="Lac Naivasha";"de"="Naivasha-See";"es"="Lago Naivasha"};
 "kruger"=@{"it"="Kruger";"fr"="Kruger";"de"="Kruger";"es"="Kruger"};
 "etosha"=@{"it"="Etosha";"fr"="Etosha";"de"="Etosha";"es"="Etosha"};
 "sossusvlei"=@{"it"="Sossusvlei";"fr"="Sossusvlei";"de"="Sossusvlei";"es"="Sossusvlei"};
 "chobe"=@{"it"="Chobe";"fr"="Chobe";"de"="Chobe";"es"="Chobe"};
 "okavango-delta"=@{"it"="Delta Okavango";"fr"="Delta Okavango";"de"="Okavango-Delta";"es"="Delta Okavango"};
 "bwindi"=@{"it"="Bwindi";"fr"="Bwindi";"de"="Bwindi";"es"="Bwindi"};
 "kibale"=@{"it"="Kibale";"fr"="Kibale";"de"="Kibale";"es"="Kibale"}
}
$PARKIMG = @{"serengeti"="TZ";"ngorongoro"="TZ";"tarangire"="TZ";"lake-manyara"="TZ";"ruaha"="TZ";"nyerere"="TZ";"masai-mara"="KE";"amboseli"="KE";"samburu"="KE";"lake-naivasha"="KE";"kruger"="SA";"etosha"="NA";"sossusvlei"="NA";"chobe"="BW";"okavango-delta"="BW";"bwindi"="UG";"kibale"="UG"}
$ACCESS = @{"it"="Voli di linea e stradali dal gateway del paese, con transfer privati porta a porta organizzati.";"fr"="Vols reguliers et routiers depuis la porte du pays, avec transferts prives organises.";"de"="Linien- und Strassenanreise ab Gateway des Landes, mit organisierten Privattransfers.";"es"="Vuelos regulares y carretera desde la puerta del pais, con traslados privados organizados."}
$STAYS = @{"it"="Lodge e campi tendati dentro e intorno al parco, scelti per fascia, stagione e tempi di drive.";"fr"="Lodges et camps tentes dans et autour du parc, choisis selon gamme, saison et temps de route.";"de"="Lodges und Zeltcamps in und um den Park, nach Kategorie, Saison, Fahrzeiten gewaehlt.";"es"="Lodges y campamentos dentro y alrededor del parque, elegidos por categoria, temporada y tiempos."}
$PARKQ = @{
 "it"=@("Quanti giorni servono in PARK?","Qual e il periodo migliore per PARK?","Cosa abbinare a PARK?");
 "fr"=@("Combien de jours faut-il a PARK ?","Quelle est la meilleure periode pour PARK ?","Que combiner avec PARK ?");
 "de"=@{"0"="Wie viele Tage PARK?";"1"="Beste Zeit PARK?";"2"="Was mit PARK kombinieren?"};
 "es"=@("Cuantos dias se necesitan en PARK?","Cual es la mejor epoca para PARK?","Que combinar con PARK?")
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
foreach ($pslug in $PARKMETA.Keys) {
  $en="/national-parks/"+$pslug+"/"
  $disp=$PARKMETA[$pslug][0]; $country=$PARKMETA[$pslug][1]; $daysneed=$PARKMETA[$pslug][2]
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content
    $pname=$PARKNAME[$pslug][$lang]
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $im=$IMG[$PARKIMG[$pslug]]
    $blurb=$C.parks.$disp
    $title=$pname+" | "+$B.countries.$country
    $desc=$blurb
    $waDest=$T.waDest+$pname+"."
    $cdir=@{"Tanzania"="tanzania-safari";"Kenya"="kenya-safari";"Uganda"="uganda-safari";"Botswana"="botswana-safari";"Namibia"="namibia-safari";"South Africa"="south-africa-safari"}[$country]
    $cUrl=$UM.("/"+$cdir+"/").$lang
    $cName=$B.hubnames.$cdir
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$UM."/national-parks/".($lang)+'">'+$T.nav.parks+'</a> > '+$pname+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$pname+'"><div class="hero-in"><p class="eyebrow">'+$B.countries.$country+' | '+$T.hub.parksGuidesTitle+'</p><h1>'+$pname+'</h1><p class="sub">'+$blurb+'</p><div class="hero-meta"><span class="pill">'+$daysneed+' '+$T.pkg.daysWord+'</span></div><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$pname+'" data-wa-msg="'+$waDest+'" href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap">'
    $body+='<h2>'+$T.hub.wildlifeTitle+'</h2><p class="lead">'+$blurb+'</p>'
    $body+='<h2>'+$T.hub.seasonsTitle+'</h2><p>'+$C.seasons.$country+'</p>'
    $body+='<h2>'+$T.hub.gettingThere+'</h2><p>'+$ACCESS[$lang]+'</p>'
    $body+='<h2>'+$T.hub.whereToStay+'</h2><p>'+$STAYS[$lang]+'</p>'
    $pcards=""
    foreach($p in ($DB | Where-Object { $_.parks -contains $disp } | Select-Object -First 3)){
      $su=$UM.("/"+$p.slug+"/").$lang
      $sik=$p.imgkey; if(-not $sik){$sik="TZ"}
      $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $p.country $p.duration_days $p.safariType $B
      $smeta=$p.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($p.country)
      $spr="$" + ('{0:N0}' -f $p.price_from)
      $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$p.excerpt+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
    }
    if($pcards -ne ""){ $body+='<h2>'+$T.hub.safarisVisitingTitle+'</h2><div class="grid g3">'+$pcards+'</div>' }
    $faqs=@()
    $qq=$PARKQ[$lang]
    if($lang -eq "de"){ $faqs+=@{"q"=($qq."0" -replace "PARK",$pname);"a"=($daysneed+" "+$T.pkg.daysWord+".")}; $faqs+=@{"q"=($qq."1" -replace "PARK",$pname);"a"=$C.seasons.$country}; $faqs+=@{"q"=($qq."2" -replace "PARK",$pname);"a"=($T.hub.relGuidesTitle+": "+$cName+".")} }
    else { $faqs+=@{"q"=($qq[0] -replace "PARK",$pname);"a"=($daysneed+" "+$T.pkg.daysWord+".")}; $faqs+=@{"q"=($qq[1] -replace "PARK",$pname);"a"=$C.seasons.$country}; $faqs+=@{"q"=($qq[2] -replace "PARK",$pname);"a"=($T.hub.relGuidesTitle+": "+$cName+".")} }
    $seed=$pname.Length*3
    for($i=0;$i -lt 6;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fqi in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fqi.q+"</summary><p>"+$fqi.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $body+='<h2>'+$T.hub.relTitle+'</h2><p><a href="'+$cUrl+'">'+$cName+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$pname+'" data-wa-msg="'+$waDest+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fqi in $faqs){ $qq2=$fqi.q -replace '"',"'"; $aa=$fqi.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq2`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $artSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article","headline":"'+$title+'"}</script>'
    $headExtra='<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$artSchema+$fqSchema
    $html=Shell $title $desc $canon $body $headExtra
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$HUB["national-parks"][$lang]+"/"+$PARKSLUG[$pslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized parks: $n"
$ACTS = @("game-drives","walking-safaris","night-safaris","hot-air-balloon-safari","gorilla-trekking","chimpanzee-trekking","boat-safaris","photographic-safaris","cultural-tours","bird-watching","kilimanjaro-trekking")
$ACTPKG = @{
 "game-drives"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari");
 "walking-safaris"=@("southern-tanzania-safari/4-day-nyerere-safari","botswana-safari/8-day-botswana-safari");
 "night-safaris"=@("south-africa-safari/5-day-kruger-safari","botswana-safari/8-day-botswana-safari");
 "hot-air-balloon-safari"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari");
 "gorilla-trekking"=@("uganda-safari/3-day-gorilla-trekking","uganda-safari/7-day-uganda-safari");
 "chimpanzee-trekking"=@("uganda-safari/7-day-uganda-safari","uganda-gorilla-trekking/5-day-uganda-gorilla");
 "boat-safaris"=@("botswana-safari/5-day-botswana-safari","uganda-safari/7-day-uganda-safari");
 "photographic-safaris"=@("tanzania-photographic-safari/8-day-photographic-serengeti","botswana-safari/8-day-botswana-safari");
 "cultural-tours"=@("namibia-safari/7-day-namibia-safari","ethiopia-safari/8-day-ethiopia-historic");
 "bird-watching"=@("tanzania-safari/6-day-tanzania-safari","kenya-safari-from-nairobi/5-day-kenya-from-nairobi");
 "kilimanjaro-trekking"=@()
}
$ACTIMG = @{"game-drives"="KE";"walking-safaris"="TZ";"night-safaris"="SA";"hot-air-balloon-safari"="MIG";"gorilla-trekking"="UG";"chimpanzee-trekking"="UG";"boat-safaris"="BW";"photographic-safaris"="MIG";"cultural-tours"="NA";"bird-watching"="TZ";"kilimanjaro-trekking"="KILI"}
$m=0
foreach ($aslug in $ACTS) {
  $en="/activities/"+$aslug+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $A=$D[$lang].acts.$aslug
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $im=$IMG[$ACTIMG[$aslug]]
    $title=$A.title
    $desc=$A.lead
    $waPkg=$T.waPkg+" "+$title+"."
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$UM."/activities/".($lang)+'">'+$T.nav.activities+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$T.nav.activities+'</p><h1>'+$title+'</h1><p class="sub">'+$A.lead+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-pkg="'+$title+'" data-wa-msg="'+$waPkg+'" href="#">WhatsApp</a></div></div></div>'
    $body+='<section class="block"><div class="wrap">'
    $body+='<h2>'+$T.hub.whatItIs+'</h2><p class="lead">'+$A.what+'</p>'
    $body+='<h2>'+$T.hub.whereTitle+'</h2><p>'+$A.where+'</p>'
    $body+='<h2>'+$T.hub.bestTime+'</h2><p>'+$A.time+'</p>'
    $body+='<h2>'+$T.hub.cost+'</h2><p>'+$A.cost+'</p>'
    $body+='<h2>'+$T.hub.whoSuits+'</h2><p>'+$A.fit+'</p>'
    $pcards=""
    foreach($pslug in $ACTPKG[$aslug]){
      $prec=@($DB | Where-Object { $_.slug -eq $pslug })[0]
      if(-not $prec){ continue }
      $su=$UM.("/"+$prec.slug+"/").$lang
      $sik=$prec.imgkey; if(-not $sik){$sik="TZ"}
      $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
      $smeta=$prec.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($prec.country)
      $spr="$" + ('{0:N0}' -f $prec.price_from)
      $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$prec.excerpt+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
    }
    if($aslug -eq "kilimanjaro-trekking"){
      $kiliUrl=$UM."/kilimanjaro/".$lang
      $kiliRoutes=@("lemosho-route","machame-route","marangu-route")
      foreach($kr in $kiliRoutes){
        $ku=$UM.("/kilimanjaro/"+$kr+"/").$lang
        $pcards+='<a class="card" href="'+$ku+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$IMG["KILI"][0]+'" alt="'+$kr+'"><div class="pad"><h3>'+$kr+'</h3></div></a>'
      }
      $pcards+='<p><a href="'+$kiliUrl+'">'+$T.nav.kilimanjaro+'</a></p>'
    }
    if($pcards -ne ""){ $body+='<h2>'+$T.hub.tripsFeaturing+'</h2><div class="grid g3">'+$pcards+'</div>' }
    $faqs=Faq-Activity $title $A.where $A.cost $A.fit
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fqi in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fqi.q+"</summary><p>"+$fqi.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $actHub=$UM."/activities/".($lang)
    $body+='<h2>'+$T.hub.relTitle+'</h2><p><a href="'+$actHub+'">'+$T.nav.activities+'</a> | <a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.hub.addSafariTitle+'</h2><p>'+$T.hub.oneProposal+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-pkg="'+$title+'" data-wa-msg="'+$waPkg+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fqi in $faqs){ $qq2=$fqi.q -replace '"',"'"; $aa=$fqi.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq2`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $artSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article","headline":"'+$title+'"}</script>'
    $headExtra='<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$artSchema+$fqSchema
    $html=Shell $title $desc $canon $body $headExtra
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$HUB["activities"][$lang]+"/"+$ACTSLUG[$aslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $m++
  }
}
"localized activities: $m"
