# gen-i18n-blog.ps1 — localized blog (posts, hub, categories). Pure ASCII.
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
    blog = ([IO.File]::ReadAllText("data/i18n/"+$g+"-blog.json") | ConvertFrom-Json)
  }
}
$CATNAME = @{
 "migration"=@{"it"="Grande Migrazione";"fr"="Grande Migration";"de"="Grosse Migration";"es"="Gran Migracion"};
 "kili"=@{"it"="Kilimangiaro";"fr"="Kilimandjaro";"de"="Kilimandscharo";"es"="Kilimanjaro"};
 "gorilla"=@{"it"="Trekking gorilla";"fr"="Trekking gorilles";"de"="Gorilla-Trekking";"es"="Trekking gorilas"};
 "planning"=@{"it"="Pianificare";"fr"="Planification";"de"="Planung";"es"="Planificacion"};
 "tanzania"=@{"it"="Tanzania";"fr"="Tanzanie";"de"="Tansania";"es"="Tanzania"};
 "kenya"=@{"it"="Kenya";"fr"="Kenya";"de"="Kenia";"es"="Kenia"};
 "tips"=@{"it"="Consigli";"fr"="Conseils";"de"="Tipps";"es"="Consejos"}
}
$CATBLOGSLUG = @{"migration"="great-migration";"kili"="kilimanjaro";"gorilla"="gorilla-trekking";"planning"="safari-planning";"tanzania"="tanzania-safari";"kenya"="kenya-safari";"tips"="travel-tips"}
$CATPKG = @{
 "migration"=@("tanzania-migration-safari/7-day-migration-safari","kenya-safari/7-day-kenya-safari");
 "kili"=@("tanzania-safari/5-day-tanzania-safari","tanzania-safari/7-day-tanzania-safari");
 "gorilla"=@("uganda-safari/3-day-gorilla-trekking","uganda-safari/7-day-uganda-safari");
 "planning"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari");
 "tanzania"=@("tanzania-safari/7-day-tanzania-safari","tanzania-safari/5-day-tanzania-safari");
 "kenya"=@("kenya-safari/7-day-kenya-safari","kenya-safari/3-day-masai-mara-safari");
 "tips"=@("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari")
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
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $BL=$D[$lang].blog
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $blogdir=$HUB["blog"][$lang]
  $im=$IMG["TZ"]
  foreach ($pslug in $BL.PSObject.Properties.Name) {
    $P=$BL.$pslug
    $en="/blog/"+$pslug+"/"
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $enUrl="https://www.adventuresafariafrica.com"+$en
    $pimg=$IMG[$P.img]; if(-not $pimg){$pimg=$im}
    $title=$P.title
    $desc=$P.excerpt
    $catlabel=$CATNAME[$P.cat][$lang]
    $catUrl=$UM.("/blog/category/"+$CATBLOGSLUG[$P.cat]+"/").$lang
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="/'+$lang+'/'+$blogdir+'/">'+$B.ui.blog+'</a> > <a href="'+$catUrl+'">'+$catlabel+'</a> > '+$title+'</nav>'
    $body+='<div class="hero"><img class="bg" src="'+$pimg[0]+'" alt="'+$title+'"><div class="hero-in"><p class="eyebrow">'+$catlabel+' | '+$P.date+'</p><h1>'+$title+'</h1></div></div>'
    $body+='<section class="block"><div class="wrap" style="max-width:840px">'
    $body+='<p class="meta">By Safari Specialist Team | '+$P.date+' | <a href="'+$catUrl+'">'+$catlabel+'</a></p>'
    $body+='<div style="background:#f1ebda;border:1px solid var(--line);border-radius:12px;padding:16px 18px;margin:18px 0"><strong>Excerpt:</strong> '+$P.excerpt+'</div>'
    $body+=$P.body
    $pcards=""
    foreach($s in $CATPKG[$P.cat]){
      $prec=@($DB | Where-Object { $_.slug -eq $s })[0]
      if(-not $prec){ continue }
      $su=$UM.("/"+$prec.slug+"/").$lang
      $simg2=$IMG[$prec.imgkey]; if(-not $simg2){$simg2=$IMG["TZ"]}
      $sthumb=$simg2[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
      $spr="$" + ('{0:N0}' -f $prec.price_from)
      $pcards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$stitle+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a></p></div></article>'
    }
    if($pcards -ne ""){ $body+='<h2>'+$T.hub.relGuidesTitle+'</h2><div class="grid g3">'+$pcards+'</div>' }
    $acards=""
    foreach($op in $BL.PSObject.Properties.Name){
      if($op -eq $pslug){ continue }
      $op2=$BL.$op
      if($op2.cat -ne $P.cat){ continue }
      $ou=$UM.("/blog/"+$op+"/").$lang
      $oimg=$IMG[$op2.img]; if(-not $oimg){$oimg=$im}
      $othumb=$oimg[0] -replace "w=1800","w=800"
      $acards+='<a class="card" href="'+$ou+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$othumb+'" alt="'+$op2.title+'"><div class="pad"><h3>'+$op2.title+'</h3><p>'+$op2.excerpt+'</p></div></a>'
    }
    if($acards -ne ""){ $body+='<h2>'+$T.hub.relBlogs+'</h2><div class="grid g3">'+$acards+'</div>' }
    $faqs=@()
    foreach($fq in $P.faqs){ $faqs+=$fq }
    $seed=$pslug.Length*13
    for($i=0;$i -lt 3;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $body+=$fqHtml
    $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
    $body+='</div></section></main>'
    $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
    foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
    $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $artSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BlogPosting","headline":"'+$title+'","datePublished":"'+$P.date+'","author":{"@type":"Organization","name":"Adventure Safari Africa"}}</script>'
    $headExtra='<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$pimg[0]+'"><meta name="twitter:card" content="summary_large_image">'+$hre+$artSchema+$fqSchema
    $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
    $outdir=$lang+"/"+$blogdir+"/"+$BLOGSLUG[$pslug][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized posts: $n"
