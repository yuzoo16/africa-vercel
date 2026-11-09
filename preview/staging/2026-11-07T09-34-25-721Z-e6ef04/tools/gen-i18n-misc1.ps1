# gen-i18n-misc1.ps1 — localized home + about. Pure ASCII.
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
    globals = ([IO.File]::ReadAllText("data/i18n/"+$g+"-globals.json") | ConvertFrom-Json);
    hubs = ([IO.File]::ReadAllText("data/i18n/"+$g+"-hubs.json") | ConvertFrom-Json);
    misc = ([IO.File]::ReadAllText("data/i18n/"+$g+"-misc.json") | ConvertFrom-Json);
    blog = ([IO.File]::ReadAllText("data/i18n/"+$g+"-blog.json") | ConvertFrom-Json);
    guides = ([IO.File]::ReadAllText("data/i18n/"+$g+"-guides.json") | ConvertFrom-Json)
  }
}
$CIMG2 = @{"tanzania-safari"="TZ";"kenya-safari"="KE";"uganda-safari"="UG";"botswana-safari"="BW";"namibia-safari"="NA";"south-africa-safari"="SA";"ethiopia-safari"="ET"}
$DECTOK = @{"Tanzania"="Tansania";"Kenya"="Kenia";"Uganda"="Uganda";"Botswana"="Botsuana";"Namibia"="Namibia";"South Africa"="Suedafrika";"Ethiopia"="Aethiopien";"Kenya & Tanzania"="Kenia-Tansania"}
$BADGE = @{"it"="Profilo in arrivo";"fr"="Profil a venir";"de"="Profil folgt";"es"="Perfil proximamente"}
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
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $M=$D[$lang].misc
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $quizUrl=$UM."/safari-quiz/".($lang)
  $canon="https://www.adventuresafariafrica.com/"+$lang+"/"
  $title=$B.meta.homeTitle
  $desc=$B.meta.homeDesc
  $waGen=$T.waGeneral
  $body='<main id="main">'
  $body+='<div class="hero"><img class="bg" src="https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1800&q=70&auto=format&fit=crop" alt="Africa safari"><div class="hero-in"><p class="eyebrow">'+$B.meta.siteName+'</p><h1>'+$title.Split(":")[0]+'</h1><p class="sub">'+$M.home.heroSub+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-o" style="border-color:#fff;color:#fff" href="'+$UM."/africa-safaris/".($lang)+'">'+$B.ui.exploreAfrica+'</a><a class="btn btn-wa" data-wa data-wa-msg="'+$waGen+'" href="#">WhatsApp</a></div></div></div>'
  $body+='<section class="block"><div class="wrap"><p class="lead">'+$M.home.destLead+'</p><div class="grid g3">'
  foreach($cd in @("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari")){
    $cu=$UM.("/"+$cd+"/").$lang
    $cim=$IMG[$CIMG2[$cd]]; $cthumb=$cim[0] -replace "w=1800","w=800"
    $body+='<a class="card" href="'+$cu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$cthumb+'" alt="'+$B.hubnames.$cd+'"><div class="pad"><h3>'+$B.hubnames.$cd+'</h3><p>'+$D[$lang].globals.countryShort.$cd+'</p></div></a>'
  }
  $body+='</div></section>'
  $BLOGIMG = @{"migration"="MIG";"kili"="KILI";"gorilla"="UG";"planning"="TZ";"tanzania"="TZ";"kenya"="KE";"tips"="TZ"}
  $body+='<section class="block"><div class="wrap"><p class="lead">'+$M.home.journalLead+'</p><div class="grid g3">'
  $bpicks=@("serengeti-vs-masai-mara","best-time-great-migration","how-many-days-safari")
  $blist=$D[$lang].blog
  foreach($bp in $bpicks){
    $P=$blist.$bp
    $pu=$UM.("/blog/"+$bp+"/").$lang
    $pimg=$IMG[$BLOGIMG[$P.cat]]; $pthumb=$pimg[0] -replace "w=1800","w=800"
    $body+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$pthumb+'" alt="'+$P.title+'"><div class="pad"><p class="meta">'+$P.date+'</p><h3><a href="'+$pu+'">'+$P.title+'</a></h3><p>'+$P.excerpt+'</p><p><a class="btn btn-o btn-sm" href="'+$pu+'">'+$B.ui.readArticle+'</a></p></div></article>'
  }
  $body+='</div><p><a class="btn btn-o" href="'+$UM."/blog/".($lang)+'">'+$B.ui.viewAll+'</a></p></div></section>'
  $body+='<section class="block alt"><div class="wrap"><p class="lead">'+$M.home.planLead+'</p><div class="grid g3">'
  $GD=$D[$lang].guides
  foreach($gk in @("african-safari-cost","best-time-for-african-safari","what-to-pack-for-safari")){
    $gu=$UM.("/travel-guide/"+$gk+"/").$lang
    $gt=$GD.$gk.title
    $gl=$GD.$gk.lead
    $gthumb=$IMG["TZ"][0] -replace "w=1800","w=800"
    $body+='<a class="card" href="'+$gu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$gthumb+'" alt="'+$gt+'"><div class="pad"><h3>'+$gt+'</h3><p>'+$gl+'</p></div></a>'
  }
  $body+='</div></div></section>'
  $body+='<section class="block alt"><div class="wrap"><p class="lead">'+$M.home.journLead+'</p><div class="grid g3">'
  foreach($pslug in @("tanzania-safari/7-day-tanzania-safari","kenya-safari/7-day-kenya-safari","uganda-safari/3-day-gorilla-trekking")){
    $prec=@($DB | Where-Object { $_.slug -eq $pslug })[0]
    $su=$UM.("/"+$prec.slug+"/").$lang
    $simg=$IMG[$prec.imgkey]; $sthumb=$simg[0] -replace "w=1800","w=800"
    $stitle=Title-For $lang $prec.country $prec.duration_days $prec.safariType $B
    $spr="$" + ('{0:N0}' -f $prec.price_from)
    $body+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><h3><a href="'+$su+'">'+$stitle+'</a></h3><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a></p></div></article>'
  }
  $body+='</div><p><a class="btn btn-o" href="'+$UM."/africa-safari-packages/".($lang)+'">'+$B.ui.viewAll+'</a> <a class="btn btn-p" href="'+$quizUrl+'" style="margin-left:8px">'+$B.ui.takeQuiz+'</a></p></div></section>'
  $body+='<section class="block"><div class="wrap"><p class="lead">'+$M.home.expLead+'</p><div class="grid g4">'
  foreach($ex in @(@("great-migration","MIG"),@("gorilla-trekking","UG"),@("kilimanjaro","KILI"),@("luxury","TZ"))){
    $eu=$UM.("/"+$ex[0]+"/").$lang
    if(-not $eu){ $eu=$UM.("/activities/"+$ex[0]+"/").$lang }
    if(-not $eu){ $eu=$UM."/africa-luxury-safaris/".($lang) }
    $eim=$IMG[$ex[1]]; $ethumb=$eim[0] -replace "w=1800","w=800"
    $body+='<a class="card" href="'+$eu+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$ethumb+'" alt="'+$ex[0]+'"><div class="pad"><h3>'+$ex[0]+'</h3></div></a>'
  }
  $body+='</div></div></section>'
  $body+='<section class="block alt"><div class="wrap"><p class="lead">'+$M.home.whyLead+'</p>'
  $body+='<h2>Reviews</h2><p>'+$M.home.reviewsNote+'</p><div class="grid g3">'
  $body+='<blockquote class="card"><div class="pad"><p>★★★★★</p><p>"Our guide repositioned us ahead of a river crossing - we watched it with three vehicles, not thirty."</p><p class="meta">Hannah & Tom, UK</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='<blockquote class="card"><div class="pad"><p>★★★★★</p><p>"The gorilla trek briefing was honest about difficulty. Unforgettable."</p><p class="meta">Marco, Italy</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='<blockquote class="card"><div class="pad"><p>★★★★★</p><p>"Kids still talk about the Maasai guide and the night skies."</p><p class="meta">Dupont family, France</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='</div></div></section>'
  $body+='<section class="block"><div class="wrap"><p class="lead">'+$M.home.planLead+'</p>'
  $body+='<div class="cta-band"><div><h2>'+$M.home.ctaTitle+'</h2><p>'+$M.home.ctaText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa data-wa-msg="'+$waGen+'" href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
  $body+='</div></section></main>'
  $headExtra='<meta property="og:type" content="website"><meta property="og:site_name" content="Adventure Safari Africa"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta name="twitter:card" content="summary_large_image">'+(Mk-Hre "/" $UM)
  $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$headExtra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  $html | Out-File -FilePath ($lang+"/index.html") -Encoding utf8
  $n++
}
"localized homes: $n"
