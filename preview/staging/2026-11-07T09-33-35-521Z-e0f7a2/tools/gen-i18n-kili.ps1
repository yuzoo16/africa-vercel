# gen-i18n-kili.ps1 — localized Kilimanjaro section. Pure ASCII.
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
    kili = ([IO.File]::ReadAllText("data/i18n/"+$g+"-kili.json") | ConvertFrom-Json)
  }
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
function Mk-Hre($en,$UM){
  $enUrl="https://www.adventuresafariafrica.com"+$en
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  return @{"tags"=$hre;"enUrl"=$enUrl}
}
function Mk-Page($lang,$canon,$title,$desc,$body,$extra){
  $h='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$extra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  return $h
}
function Mk-Head($title,$desc,$canon,$imUrl){
  return '<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$imUrl+'"><meta name="twitter:card" content="summary_large_image">'
}
function Mk-Cta($prop,$cons,$B,$T){
  return '<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
}
$n=0
$TABCSS='<style>.tabs{display:flex;gap:8px;flex-wrap:wrap;margin:14px 0}.tabbtn{border:1px solid var(--line);background:#fffdf7;border-radius:999px;padding:10px 20px;font-weight:700;cursor:pointer}.tabbtn.sel{background:var(--forest);color:#fff;border-color:var(--forest)}.tabpane{display:none}.tabpane.sel{display:block}</style>'
$TABJS='<script>document.addEventListener("DOMContentLoaded",function(){document.querySelectorAll(".tabbtn").forEach(function(b){b.addEventListener("click",function(){document.querySelectorAll(".tabbtn").forEach(function(x){x.classList.remove("sel")});document.querySelectorAll(".tabpane").forEach(function(x){x.classList.remove("sel")});b.classList.add("sel");document.getElementById(b.dataset.tab).classList.add("sel");});});});</script>'
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $K=$D[$lang].kili
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $kroot=$HUB["kilimanjaro"][$lang]
  $im=$IMG["KILI"]
  $en="/kilimanjaro/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $hubname=$B.nav.kilimanjaro
  $title=$hubname+" "+$B.meta.pkgTail
  $desc=$K.hubIntro
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$hubname+'</nav>'
  $body+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$hubname+'"><div class="hero-in"><p class="eyebrow">'+$hubname+'</p><h1>'+$hubname+'</h1><p class="sub">'+$desc+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
  $body+='<section class="block"><div class="wrap" style="max-width:860px">'
  $rows=""
  foreach($r in $K.routesTable){ $rows+="<tr><td>"+$r.r+"</td><td>"+$r.days+"</td><td>"+$r.success+"</td><td>"+$r.char+"</td></tr>" }
  $body+='<h2>'+$T.hub.routesCompared+'</h2><table class="cmp"><tr><th>Route</th><th>Days</th><th>Success</th><th>Character</th></tr>'+$rows+'</table>'
  $rcards=""
  foreach($rk in @("lemosho-route","machame-route","marangu-route","rongai-route","umbwe-route","northern-circuit")){
    $ru=$UM.("/kilimanjaro/"+$rk+"/").$lang
    $rn=$K.routes.$rk.name
    $rthumb=$im[0] -replace "w=1800","w=800"
    $rcards+='<a class="card" href="'+$ru+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$rthumb+'" alt="'+$rn+'"><div class="pad"><h3>'+$rn+'</h3></div></a>'
  }
  $body+='<div class="grid g3">'+$rcards+'</div>'
  $calcUrl=$UM."/kilimanjaro/success-calculator/".($lang)
  $body+='<p><a class="btn btn-o" href="'+$calcUrl+'">'+$T.calc.go+'</a></p>'
  $faqs=@()
  foreach($fq in $K.hubFaqs){ $faqs+=$fq }
  $seed=77
  for($i=0;$i -lt 7;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
  $fb=Mk-Faq $faqs
  $body+=$fb.html
  $body+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'
  $hr=Mk-Hre $en $loc $UM
  $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon $im[0])+$hr.tags+$fb.schema)
  $outdir=$lang+"/"+$kroot
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
  foreach ($rk in @("lemosho-route","machame-route","marangu-route","rongai-route","umbwe-route","northern-circuit")) {
    $R=$K.routes.$rk
    $ren="/kilimanjaro/"+$rk+"/"
    $rloc=$UM.$ren.$lang
    $rcanon="https://www.adventuresafariafrica.com"+$rloc
    $rtitle=$R.name+" "+$B.meta.pkgTail
    $rdesc=$R.intro
    $rbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$loc+'">'+$hubname+'</a> > '+$R.name+'</nav>'
    $rbody+='<div class="hero"><img class="bg" src="'+$im[0]+'" alt="'+$R.name+'"><div class="hero-in"><p class="eyebrow">'+$hubname+'</p><h1>'+$R.name+'</h1><p class="sub">'+$R.intro+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa data-wa-pkg="'+$R.name+'" href="#">WhatsApp</a></div></div></div>'
    $rbody+='<section class="block"><div class="wrap" style="max-width:860px">'
    $facts=""
    foreach($fk in $R.facts.PSObject.Properties){ $facts+="<div><b>"+$fk.Name+"</b>"+$fk.Value+"</div>" }
    $rbody+='<div class="facts">'+$facts+'</div>'
    $tabBtns=""
    $tabPanes=""
    $ti=0
    foreach($tk in $R.tabs.PSObject.Properties){
      $sel=""; if($ti -eq 0){$sel=" sel"}
      $tid="t"+$ti.ToString()+$rk.Substring(0,3)
      $tabBtns+='<button class="tabbtn'+$sel+'" data-tab="'+$tid+'">'+$tk.Name+'</button>'
      $pan='<div class="tabpane'+$sel+'" id="'+$tid+'"><h3>'+$tk.Name+'</h3><div class="itin">'
      $op=" open"
      foreach($dd in $tk.Value){ $pan+="<details$op><summary>"+$dd.t+"</summary><p>"+$dd.d+"</p></details>"; $op="" }
      $pan+='</div></div>'
      $tabPanes+=$pan
      $ti++
    }
    $rbody+='<div class="tabs">'+$tabBtns+'</div>'+$tabPanes
    $rfaqs=@()
    foreach($fq in $R.faqs){ $rfaqs+=$fq }
    $seed2=$rk.Length*9
    $need=9-$rfaqs.Count
    for($i=0;$i -lt $need;$i++){ $rfaqs+=$C.faq[(($seed2+$i*5)%$C.faq.Count)] }
    $rfb=Mk-Faq $rfaqs
    $rbody+=$rfb.html
    $rbody+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'+$TABCSS+$TABJS
    $rhr=Mk-Hre $ren $rloc $UM
    $art='<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article","headline":"'+$R.name+'"}</script>'
    $rhtml=Mk-Page $lang $rcanon $rtitle $rdesc $rbody ((Mk-Head $rtitle $rdesc $rcanon $im[0])+$rhr.tags+$art+$rfb.schema)
    $routdir=$lang+"/"+$kroot+"/"+$KILISLUG[$rk][$lang]
    New-Item -ItemType Directory -Path $routdir -Force | Out-Null
    $rhtml | Out-File -FilePath ($routdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized kili hub+routes: $n"
