# gen-i18n-hubcountry.ps1 — localized country hubs. Pure ASCII.
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
    hubs = ([IO.File]::ReadAllText("data/i18n/"+$g+"-hubs.json") | ConvertFrom-Json)
  }
}
$CDIR = @{"Tanzania"="tanzania-safari";"Kenya"="kenya-safari";"Uganda"="uganda-safari";"Botswana"="botswana-safari";"Namibia"="namibia-safari";"South Africa"="south-africa-safari";"Ethiopia"="ethiopia-safari"}
$CPARKS = @{
 "tanzania-safari"=@("serengeti","ngorongoro","tarangire","lake-manyara","ruaha","nyerere");
 "kenya-safari"=@("masai-mara","amboseli","samburu","lake-naivasha");
 "uganda-safari"=@("bwindi","kibale");
 "botswana-safari"=@("chobe","okavango-delta");
 "namibia-safari"=@("etosha","sossusvlei");
 "south-africa-safari"=@("kruger");
 "ethiopia-safari"=@()
}
$NEIGH = @{
 "tanzania-safari"=@("kenya-safari","uganda-safari");
 "kenya-safari"=@("tanzania-safari","uganda-safari");
 "uganda-safari"=@("tanzania-safari","kenya-safari");
 "botswana-safari"=@("namibia-safari","south-africa-safari");
 "namibia-safari"=@("botswana-safari","south-africa-safari");
 "south-africa-safari"=@("botswana-safari","namibia-safari");
 "ethiopia-safari"=@("tanzania-safari","kenya-safari")
}
$PIMGKEY = @{"serengeti"="Central Serengeti";"ngorongoro"="Ngorongoro Crater";"tarangire"="Tarangire";"lake-manyara"="Lake Manyara";"ruaha"="Ruaha";"nyerere"="Nyerere";"masai-mara"="Masai Mara";"amboseli"="Amboseli";"samburu"="Samburu";"lake-naivasha"="Lake Naivasha";"kruger"="Sabi Sand";"etosha"="Etosha";"sossusvlei"="Sossusvlei";"chobe"="Chobe";"okavango-delta"="Okavango Delta";"bwindi"="Bwindi";"kibale"="Kibale"}
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
foreach ($country in $CDIR.Keys) {
  $dir=$CDIR[$country]
  $enHub="/"+$dir+"/"
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $H=$D[$lang].hubs.$country
    $loc=$UM.$enHub.$lang
    $hubname=$B.hubnames.$dir
    $canon="https://www.adventuresafariafrica.com"+$loc
    $prop=$UM."/request-proposal/".$lang
    $cons=$UM."/safari-consultation/".$lang
    $heroImg="/assets/hero-"+$dir+".jpg"
    $im=$IMG[$CIMG[$country]]
    $waDest=$T.waDest+$hubname+"."
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$hubname+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$hubname+'"><div class="hero-in"><p class="eyebrow">'+$hubname+'</p><h1>'+$hubname+'</h1><p class="sub">'+$H.lead+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$hubname+'" data-wa-msg="'+$waDest+'" href="#">WhatsApp</a><a class="btn btn-o" style="border-color:#fff;color:#fff" href="'+$loc+'packages/">'+$T.hub.allPkgs+'</a></div><div class="hero-meta"><span class="pill">'+$hubname+'</span><span class="pill">'+$B.ui.private+'</span></div></div></div>'
    $body+='<section class="block"><div class="wrap">'
    $body+='<h2>'+$T.hub.essentialsTitle+'</h2><p class="lead">'+$H.why+'</p>'
    $expHtml=""
    foreach($e in $H.experiences){ $expHtml+='<div class="card"><div class="pad"><h3>'+$e.t+'</h3><p>'+$e.d+'</p></div></div>' }
    $body+='<h2>'+$T.hub.experiencesTitle+'</h2><div class="grid g3">'+$expHtml+'</div>'
    $pcards=""
    foreach($p in ($DB | Where-Object { $_.country -eq $country })){
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
    }
    $body+='<h2>'+$T.hub.pkgsTitle+'</h2><div class="grid g3">'+$pcards+'</div>'
    $plist=$CPARKS[$dir]
    if($plist.Count -gt 0){
      $pgrid=""
      foreach($ps in $plist){
        $pu=$UM.("/national-parks/"+$ps+"/").$lang
        $pimg=$IMG[$PIMGKEY[$ps]]; if(-not $pimg){$pimg=$im}
        $pthumb=$pimg[0] -replace "w=1800","w=800"
        $pgrid+='<a class="card" href="'+$pu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$PARKNAME[$ps][$lang]+'"><div class="pad"><h3>'+$PARKNAME[$ps][$lang]+'</h3></div></a>'
      }
      $body+='<h2>'+$T.hub.parksTitle+'</h2><div class="grid g3">'+$pgrid+'</div>'
    }
    $body+='<h2>'+$T.hub.seasonsTitle+'</h2><p>'+$H.seasons+'</p>'
    $body+='<h2>'+$T.hub.wildlifeTitle+'</h2><p>'+$H.wildlife+'</p>'
    $styHtml=""
    foreach($sy in $H.styles){ $styHtml+='<div class="card"><div class="pad"><h3>'+$sy.t+'</h3><p>'+$sy.d+'</p></div></div>' }
    $body+='<h2>'+$T.hub.stylesTitle+'</h2><div class="grid g2">'+$styHtml+'</div>'
    $body+='<h2>'+$T.hub.durationsTitle+'</h2><p>'+$H.durations+'</p>'
    $body+='<h2>'+$T.hub.accommTitle+'</h2><p>'+$H.accomm+'</p>'
    $itHtml="<ol>"
    foreach($it in $H.itins){ $itHtml+="<li>"+$it+"</li>" }
    $itHtml+="</ol>"
    $body+='<h2>'+$T.hub.itinsTitle+'</h2>'+$itHtml
    $relHtml=""
    foreach($nd in $NEIGH[$dir]){ $nu=$UM.("/"+$nd+"/").$lang; $relHtml+='<a href="'+$nu+'">'+$B.hubnames.$nd+'</a> | ' }
    $afUrl=$UM."/africa-safaris/".$lang
    $relHtml+='<a href="'+$afUrl+'">'+$B.hubnames."africa-safaris"+'</a>'
    $body+='<h2>'+$T.hub.relatedDestTitle+'</h2><p>'+$relHtml+'</p>'
    $body+='<h2>'+$T.hub.travelInfoTitle+'</h2><p>'+$H.travel+'</p>'
    $faqs=@()
    foreach($fq in $H.faqs){ $faqs+=$fq }
    $seed=$hubname.Length
    for($i=0;$i -lt 6;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.hub.planTitle+'</h2><p>'+$T.hub.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-dest="'+$hubname+'" data-wa-msg="'+$waDest+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $desc=$hubname+". "+$H.lead
    $enUrl="https://www.adventuresafariafrica.com"+$enHub
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$enHub.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $crumbSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"'+$B.crumbHome+'","item":"https://www.adventuresafariafrica.com/'+$lang+'/"},{"@type":"ListItem","position":2,"name":"'+$hubname+'","item":"'+$canon+'"}]}</script>'
    $headExtra='<meta property="og:type" content="website"><meta property="og:title" content="'+$hubname+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$fqSchema+$crumbSchema
    $html=Shell ($hubname+" "+$B.meta.pkgTail) $desc $canon $body $headExtra
    $html=$html -replace '<html lang="en">',('<html lang="'+$lang+'">')
    $html=$html.Replace('<link rel="alternate" hreflang="en" href="'+$canon+'"><link rel="alternate" hreflang="x-default" href="'+$canon+'">', '')
    $outdir=$lang+"/"+$HUB[$dir][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized country hubs: $n (expect 28)"
