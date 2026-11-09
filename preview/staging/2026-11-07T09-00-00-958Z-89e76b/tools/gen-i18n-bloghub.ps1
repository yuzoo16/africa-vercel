# gen-i18n-bloghub.ps1 — localized blog hub + categories. Pure ASCII.
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
    blog = ([IO.File]::ReadAllText("data/i18n/"+$g+"-blog.json") | ConvertFrom-Json)
  }
}
$CATNAMES = @{
 "migration"=@{"it"="Grande Migrazione";"fr"="Grande Migration";"de"="Grosse Migration";"es"="Gran Migracion"};
 "kili"=@{"it"="Kilimangiaro";"fr"="Kilimandjaro";"de"="Kilimandscharo";"es"="Kilimanjaro"};
 "gorilla"=@{"it"="Trekking gorilla";"fr"="Trekking gorilles";"de"="Gorilla-Trekking";"es"="Trekking gorilas"};
 "planning"=@{"it"="Pianificare";"fr"="Planification";"de"="Planung";"es"="Planificacion"};
 "tanzania"=@{"it"="Tanzania";"fr"="Tanzanie";"de"="Tansania";"es"="Tanzania"};
 "kenya"=@{"it"="Kenya";"fr"="Kenya";"de"="Kenia";"es"="Kenia"};
 "tips"=@{"it"="Consigli";"fr"="Conseils";"de"="Tipps";"es"="Consejos"}
}
$CATBLOG = @{"migration"="great-migration";"kili"="kilimanjaro";"gorilla"="gorilla-trekking";"planning"="safari-planning";"tanzania"="tanzania-safari";"kenya"="kenya-safari";"tips"="travel-tips"}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $BL=$D[$lang].blog
  $prop=$UM."/request-proposal/".$lang
  $blogdir=$HUB["blog"][$lang]
  $en="/blog/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $enUrl="https://www.adventuresafariafrica.com"+$en
  $im=$IMG["TZ"]
  $cards=""
  foreach($pslug in $BL.PSObject.Properties.Name){
    $P=$BL.$pslug
    $pu=$UM.("/blog/"+$pslug+"/").$lang
    $pimg=$IMG[$P.img]; if(-not $pimg){$pimg=$im}
    $pthumb=$pimg[0] -replace "w=1800","w=800"
    $cards+='<article class="card" data-c="'+$P.cat+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$P.title+'"><div class="pad"><p class="meta">'+$CATNAMES[$P.cat][$lang]+' | '+$P.date+'</p><h3><a href="'+$pu+'">'+$P.title+'</a></h3><p>'+$P.excerpt+'</p><p><a class="btn btn-o btn-sm" href="'+$pu+'">'+$B.ui.readArticle+'</a></p></div></article>'
  }
  $filtopts=""
  $seen=@()
  foreach($pslug in $BL.PSObject.Properties.Name){
    $cc=$BL.$pslug.cat
    if($seen -contains $cc){ continue }
    $seen+=$cc
    $filtopts+='<button class="opt" data-c="'+$cc+'">'+$CATNAMES[$cc][$lang]+'</button>'
  }
  $catlinks=""
  foreach($cc in $seen){ $cu=$UM.("/blog/category/"+$CATBLOG[$cc]+"/").$lang; $catlinks+='<a href="'+$cu+'">'+$CATNAMES[$cc][$lang]+'</a> | ' }
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$B.ui.blog+'</nav>'
  $body+='<section class="block"><div class="wrap"><p class="eyebrow">'+$B.ui.blog+'</p><h1>'+$B.ui.blog+'</h1>'
  $body+='<div class="quiz" style="margin-bottom:18px"><div class="opts" id="catfilter" style="display:flex;flex-wrap:wrap;gap:10px"><button class="opt sel" data-c="">All</button>'+$filtopts+'</div></div>'
  $body+='<div class="grid g3" id="postgrid">'+$cards+'</div>'
  $body+='<h2>'+$T.hub.relBlogs+'</h2><p>'+$catlinks+'<a href="'+$prop+'">'+$B.ui.requestProposal+'</a></p>'
  $body+='</div></section></main>'
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  $blschema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Blog"}</script>'
  $headExtra='<meta property="og:type" content="website"><meta property="og:title" content="'+$B.ui.blog+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$im[0]+'">'+$hre+$blschema
  $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$B.ui.blog+' | Adventure Safari Africa</title><meta name="description" content="'+$B.ui.blog+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body
  $html+='<script>document.addEventListener("DOMContentLoaded",function(){var f=document.getElementById("catfilter"),g=document.getElementById("postgrid");if(!f||!g)return;f.querySelectorAll(".opt").forEach(function(b){b.addEventListener("click",function(){f.querySelectorAll(".opt").forEach(function(x){x.classList.remove("sel")});b.classList.add("sel");var c=b.dataset.c;g.querySelectorAll(".card").forEach(function(cd){cd.style.display=(!c||cd.dataset.c===c)?"":"none";});});});});</script>'
  $html+='<div id="site-footer"></div></body></html>'
  $outdir=$lang+"/"+$blogdir
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
  foreach ($cc in $seen) {
    $cen="/blog/category/"+$CATBLOG[$cc]+"/"
    $cloc=$UM.$cen.$lang
    $ccanon="https://www.adventuresafariafrica.com"+$cloc
    $ccards=""
    foreach($pslug in $BL.PSObject.Properties.Name){
      $P=$BL.$pslug
      if($P.cat -ne $cc){ continue }
      $pu=$UM.("/blog/"+$pslug+"/").$lang
      $pimg=$IMG[$P.img]; if(-not $pimg){$pimg=$im}
      $pthumb=$pimg[0] -replace "w=1800","w=800"
      $ccards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$P.title+'"><div class="pad"><p class="meta">'+$P.date+'</p><h3><a href="'+$pu+'">'+$P.title+'</a></h3><p>'+$P.excerpt+'</p><p><a class="btn btn-o btn-sm" href="'+$pu+'">'+$B.ui.readArticle+'</a></p></div></article>'
    }
    $cbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="/'+$lang+'/'+$blogdir+'/">'+$B.ui.blog+'</a> > '+$CATNAMES[$cc][$lang]+'</nav>'
    $cbody+='<section class="block"><div class="wrap"><p class="eyebrow">'+$B.ui.blog+'</p><h1>'+$CATNAMES[$cc][$lang]+'</h1><div class="grid g3">'+$ccards+'</div><p><a href="/'+$lang+'/'+$blogdir+'/">'+$B.ui.viewAll+'</a></p></div></section></main>'
    $chre='<link rel="alternate" hreflang="en" href="https://www.adventuresafariafrica.com'+$cen+'">'
    foreach($g2 in @("it","fr","de","es")){ $chre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$cen.$g2)+'">' }
    $chre+='<link rel="alternate" hreflang="x-default" href="https://www.adventuresafariafrica.com'+$cen+'">'
    $chtml='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$CATNAMES[$cc][$lang]+' | Adventure Safari Africa Blog</title><meta name="description" content="'+$CATNAMES[$cc][$lang]+'"><link rel="canonical" href="'+$ccanon+'">'+$chre+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$cbody+'<div id="site-footer"></div></body></html>'
    # category hub lives at <lang>/blog/category/<english-slug>/ on every tree;
    # "categoria-" was a localized literal and produced a path that exists nowhere
    $coutdir=$lang+"/"+$blogdir+"/category-"+$BLOGCAT[$CATBLOG[$cc]][$lang]
    $check=$UM.$cen.$lang
    $coutdir=$check.Trim("/")
    New-Item -ItemType Directory -Path $coutdir -Force | Out-Null
    $chtml | Out-File -FilePath ($coutdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized blog hub+cats: $n"
