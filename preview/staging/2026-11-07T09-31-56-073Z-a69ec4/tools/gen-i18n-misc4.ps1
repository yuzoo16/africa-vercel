# gen-i18n-misc4.ps1 ??? quiz, search, package indexes. Pure ASCII.
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
    misc = ([IO.File]::ReadAllText("data/i18n/"+$g+"-misc.json") | ConvertFrom-Json)
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
function Mk-Page($lang,$canon,$title,$desc,$body,$extra){
  $h='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$extra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  return $h
}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $Q=$T.quiz; $M=$D[$lang].misc
  $prop=$UM."/request-proposal/".$lang
  $quizEn="/safari-quiz/"
  $quizLoc=$UM.$quizEn.$lang
  $quizCanon="https://www.adventuresafariafrica.com"+$quizLoc
  $d_tz=$UM."/tanzania-safari/".($lang)
  $p_tz7=$UM."/tanzania-safari/7-day-tanzania-safari/".($lang)
  $d_ke=$UM."/kenya-safari/".($lang)
  $p_ke7=$UM."/kenya-safari/7-day-kenya-safari/".($lang)
  $p_keb=$UM."/kenya-safari/10-day-kenya-safari-beach/".($lang)
  $d_ug=$UM."/uganda-safari/".($lang)
  $p_ug3=$UM."/uganda-safari/3-day-gorilla-trekking/".($lang)
  $p_ug7=$UM."/uganda-safari/7-day-uganda-safari/".($lang)
  $d_bw=$UM."/botswana-safari/".($lang)
  $p_bw8=$UM."/botswana-safari/8-day-botswana-safari/".($lang)
  $qbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$Q.h1+'</nav>'
  $qbody+='<section class="block"><div class="wrap" style="max-width:780px"><p class="eyebrow">'+$Q.eyebrow+'</p><h1>'+$Q.h1+'</h1><p class="lead">'+$Q.lead+'</p>'
  $qbody+='<div class="progress" aria-hidden="true"><i id="bar" style="width:0%"></i></div><div class="quiz" id="quiz" style="margin-top:14px">'
  $qs=@(
   @("dest",$Q.q1,@(@("tanzania",$Q.optTanzania),@("kenya",$Q.optKenya),@("uganda",$Q.optUganda),@("southern",$Q.optSouthern),@("unsure",$Q.optUnsure))),
   @("wild",$Q.q2,@(@("migration",$Q.optMigration),@("cats",$Q.optCats),@("gorilla",$Q.optGorilla),@("elephant",$Q.optElephant),@("all",$Q.optAll))),
   @("when",$Q.q3,@(@("jul-oct",$Q.optJulOct),@("jan-mar",$Q.optJanMar),@("nov-dec",$Q.optNovDec),@("flex",$Q.optFlex))),
   @("days",$Q.q4,@(@("short",$Q.optShort),@("week",$Q.optWeek),@("grand",$Q.optGrand))),
   @("who",$Q.q5,@(@("couple",$Q.optCouple),@("family",$Q.optFamily),@("friends",$Q.optFriends),@("solo",$Q.optSolo))),
   @("style",$Q.q6,@(@("luxury",$Q.optLuxury),@("mid",$Q.optMid),@("value",$Q.optValue))),
   @("beach",$Q.q7,@(@("yes",$Q.optYesBeach),@("no",$Q.optNoBeach))),
   @("exp",$Q.q8,@(@("first",$Q.optFirst),@("return",$Q.optReturn)))
  )
  foreach($qq in $qs){
    $qbody+='<div class="q" data-q="'+$qq[0]+'"><h3>'+$qq[1]+'</h3><div class="opts">'
    foreach($oo in $qq[2]){ $qbody+='<button class="opt" data-v="'+$oo[0]+'">'+$oo[1]+'</button>' }
    $qbody+='</div></div>'
  }
  $qbody+='<div id="result" hidden></div><p style="margin-top:14px"><button class="btn btn-p" id="quiz-go">'+$Q.go+'</button></p></div></div></section></main>'
  $qjsT ='<script>document.addEventListener("DOMContentLoaded",()=>{const quiz=document.getElementById("quiz"),bar=document.getElementById("bar"),res=document.getElementById("result");const ans={};quiz.querySelectorAll(".q").forEach(q=>{q.querySelectorAll(".opt").forEach(b=>b.addEventListener("click",()=>{q.querySelectorAll(".opt").forEach(x=>x.classList.remove("sel"));b.classList.add("sel");ans[q.dataset.q]=b.dataset.v;const n=Object.keys(ans).length;bar.style.width=(n/8*100)+"%";if(window.track)track("quiz_answer",{q:q.dataset.q});}));});document.getElementById("quiz-go").addEventListener("click",()=>{if(Object.keys(ans).length<8){res.hidden=false;res.innerHTML="<p><strong>%%NEED8%%</strong></p>";return;}let dest="%%D_TZ%%",pkg="%%P_TZ7%%",why="%%WHY_TZ%%";if(ans.dest==="kenya"){dest="%%D_KE%%";pkg=ans.beach==="yes"?"%%P_KEB%%":"%%P_KE7%%";why="%%WHY_KE%%"+(ans.beach==="yes"?"%%WHY_KEB%%":"")+".";}if(ans.dest==="uganda"||ans.wild==="gorilla"){dest="%%D_UG%%";pkg=ans.days==="short"?"%%P_UG3%%":"%%P_UG7%%";why="%%WHY_UG%%";}if(ans.dest==="southern"){dest="%%D_BW%%";pkg="%%P_BW8%%";why="%%WHY_S%%";}if(ans.wild==="migration"&&ans.when==="jan-mar"){pkg="%%P_TZ7%%";why="%%WHY_CALV%%";}if(ans.who==="family"&&ans.dest!=="uganda"){why+="%%WHY_FAM%%";}if(window.track)track("quiz_complete",ans);res.hidden=false;res.innerHTML="<h3>%%MATCH%%</h3><p><a class="btn btn-p" href=""+pkg+"">%%VIEWREC%%</a> <a class="btn btn-g" href="%%PROP%%">%%REQCU%%</a></p><p>"+why+"</p>";res.scrollIntoView({behavior:"smooth",block:"center"});});});</script>'
  $qjs=$qjsT
  $qjs=$qjs.Replace("%%NEED8%%",$Q.need8).Replace("%%D_TZ%%",$d_tz).Replace("%%P_TZ7%%",$p_tz7).Replace("%%WHY_TZ%%",$Q.whyTanzania)
  $qjs=$qjs.Replace("%%D_KE%%",$d_ke).Replace("%%P_KEB%%",$p_keb).Replace("%%P_KE7%%",$p_ke7).Replace("%%WHY_KE%%",$Q.whyKenya).Replace("%%WHY_KEB%%",$Q.whyKenyaBeach)
  $qjs=$qjs.Replace("%%D_UG%%",$d_ug).Replace("%%P_UG3%%",$p_ug3).Replace("%%P_UG7%%",$p_ug7).Replace("%%WHY_UG%%",$Q.whyUganda)
  $qjs=$qjs.Replace("%%D_BW%%",$d_bw).Replace("%%P_BW8%%",$p_bw8).Replace("%%WHY_S%%",$Q.whySouthern)
  $qjs=$qjs.Replace("%%WHY_CALV%%",$Q.whyCalving).Replace("%%WHY_FAM%%",$Q.whyFamily)
  $qjs=$qjs.Replace("%%MATCH%%",$Q.match).Replace("%%VIEWREC%%",$Q.viewRec).Replace("%%PROP%%",$prop).Replace("%%REQCU%%",$Q.requestCustom)
  $qhtml=Mk-Page $lang $quizCanon $Q.h1 $Q.lead $qbody ((Mk-Hre $quizEn $UM)+'<script type="application/ld+json">{"@context":"https://schema.org","@type":"WebPage"}</script>')
  $qhtml=$qhtml -replace "</body>", ($qjs+"</body>")
  $qout=$lang+"/"+$HUB["safari-quiz"][$lang]
  New-Item -ItemType Directory -Path $qout -Force | Out-Null
  $qhtml | Out-File -FilePath ($qout+"/index.html") -Encoding utf8
  $n++
}
"localized quiz: $n"
$IMX=@{"TZ"="https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=200&q=50&auto=format&fit=crop";"KE"="https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=200&q=50&auto=format&fit=crop";"UG"="https://images.unsplash.com/photo-1547721064-da6cfb341d50?w=200&q=50&auto=format&fit=crop";"BW"="https://images.unsplash.com/photo-1551009175-8a68da93d5f9?w=200&q=50&auto=format&fit=crop";"NA"="https://images.unsplash.com/photo-1547235001-d703406d3f17?w=200&q=50&auto=format&fit=crop";"SA"="https://images.unsplash.com/photo-1535941339077-2dd1c7963098?w=200&q=50&auto=format&fit=crop";"ET"="https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=200&q=50&auto=format&fit=crop";"MIG"="https://images.unsplash.com/photo-1516426122078-c23e76319801?w=200&q=50&auto=format&fit=crop";"BEACH"="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&q=50&auto=format&fit=crop";"KILI"="https://images.unsplash.com/photo-1551632811-561732d1e306?w=200&q=50&auto=format&fit=crop";"CAPE"="https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=200&q=50&auto=format&fit=crop"}
$sidx=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $M=$D[$lang].misc
  $prop=$UM."/request-proposal/".$lang
  $entries=@()
  foreach($p in $DB){
    $entries+=(,@((Title-For $lang $p.country $p.duration_days $p.safariType $B), "Safari", ($UM.("/"+$p.slug+"/").$lang), $p.imgkey))
  }
  foreach($dd in @("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari","ethiopia-safari")){
    $entries+=(,@($B.hubnames.$dd, $B.ui.home, ($UM.("/"+$dd+"/").$lang), "MIG"))
  }
  $entries+=(,@($B.ui.blog, $B.ui.blog, ($UM."/blog/".($lang)), "TZ"))
  $entries+=(,@($B.ui.takeQuiz, $B.ui.quiz, ($UM."/safari-quiz/".($lang)), "MIG"))
  $entries+=(,@($B.ui.requestProposal, $B.ui.proposal, $prop, "TZ"))
  $idxArr=@()
  foreach($e in $entries){
    $imk=$e[3]; if(-not $IMX[$imk]){$imk="TZ"}
    $idxArr+='["'+($e[0] -replace '"',"'")+'","'+($e[1] -replace '"',"'")+'","'+$e[2]+'","'+$imk+'"]'
  }
  $idx="["+($idxArr -join ",")+"]"
  $en="/search/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $sbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$M.search.title+'</nav>'
  $sbody+='<section class="block"><div class="wrap" style="max-width:780px"><p class="eyebrow">'+$M.search.title+'</p><h1>'+$M.search.title+'</h1><p class="lead">'+$M.search.lead+'</p>'
  $sbody+='<p><input id="q" type="search" placeholder="'+$M.search.placeholder+'" aria-label="search"></p><div class="searchres" id="res"><p class="meta">'+$M.search.typeTo+'</p></div>'
  $sbody+='</div></section></main>'
  $sjs='<script>const IM={'
  foreach($k in $IMX.Keys){ $sjs+='"'+$k+'":"'+$IMX[$k]+'",' }
  $sjs+='};const IDX='+$idx+';document.addEventListener("DOMContentLoaded",function(){var q=document.getElementById("q"),res=document.getElementById("res");var params=new URLSearchParams(location.search);if(params.get("q")){q.value=params.get("q");run(q.value);}q.addEventListener("input",function(){run(q.value);});'
  $sjs+='function run(v){v=v.trim().toLowerCase();if(!v){res.innerHTML="<p class=''meta''>'+$M.search.typeTo+'</p>";return;}var hits=IDX.filter(function(x){return (x[0]+" "+x[1]).toLowerCase().indexOf(v)>-1;}).slice(0,20);'
  $sjs+='res.innerHTML=hits.length?hits.map(function(h){return "<a href=''+h[2]+''><img loading=''lazy'' src=''+IM[h[3]]+'' alt=''''><span><strong>"+h[0]+"</strong><br><span class=''meta''>"+h[1]+"</span></span></a>";}).join(""):"<p>'+$M.search.noRes+'</p>";}});</script>'
  $shtml=Mk-Page $lang $canon $M.search.title $M.search.lead $sbody ((Mk-Hre $en $UM)+'<meta name="robots" content="noindex,follow">')
  $shtml=$shtml -replace "</body>", ($sjs+"</body>")
  $sout=$lang+"/"+$HUB["search"][$lang]
  New-Item -ItemType Directory -Path $sout -Force | Out-Null
  $shtml | Out-File -FilePath ($sout+"/index.html") -Encoding utf8
  $sidx++
}
"localized search: $sidx"
$CDIRS = @("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari","ethiopia-safari")
$CCN = @{"tanzania-safari"="Tanzania";"kenya-safari"="Kenya";"uganda-safari"="Uganda";"botswana-safari"="Botswana";"namibia-safari"="Namibia";"south-africa-safari"="South Africa";"ethiopia-safari"="Ethiopia"}
$k=0
foreach ($cdir in $CDIRS) {
  $country=$CCN[$cdir]
  foreach ($lang in $LANGS) {
    $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content
    $prop=$UM."/request-proposal/".$lang
    $hubUrl=$UM.("/"+$cdir+"/").$lang
    $hubname=$B.hubnames.$cdir
    $mine=@($DB | Where-Object { $_.slug.Split("/")[0] -eq $cdir } | Sort-Object duration_days)
    $cards=""
    foreach($p in $mine){
      $su=$UM.("/"+$p.slug+"/").$lang
      $sik=$p.imgkey; if(-not $sik){$sik="TZ"}
      $simg=$IMG[$sik]; $sthumb=$simg[0] -replace "w=1800","w=800"
      $stitle=Title-For $lang $p.country $p.duration_days $p.safariType $B
      $smeta=$p.duration_days.ToString()+" "+$T.pkg.daysWord+" | "+$B.countries.($p.country)
      if($lang -eq "es"){ $smeta=$p.duration_days.ToString()+" d"+[char]0xED+"as | "+$B.countries.($p.country) }
      if($lang -eq "de"){ $smeta=$p.duration_days.ToString()+" Tage | "+$B.countries.($p.country) }
      $spr="$" + ('{0:N0}' -f $p.price_from)
      $cards+='<article class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$sthumb+'" alt="'+$stitle+'"><div class="pad"><p class="meta">'+$smeta+'</p><h3><a href="'+$su+'">'+$stitle+'</a></h3><p>'+$p.excerpt+'</p><p><span class="price">'+$B.ui.fromPrice+' '+$spr+'</span></p><p><a class="btn btn-o btn-sm" href="'+$su+'">'+$B.ui.viewSafari+'</a> <a class="btn btn-p btn-sm" href="'+$prop+'">'+$B.ui.customize+'</a> <a class="btn btn-wa btn-sm" data-wa data-wa-pkg="'+$stitle+'" href="#">WhatsApp</a></p></div></article>'
    }
    $faqs=@()
    $seed=$cdir.Length*23
    for($i=0;$i -lt 5;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fqHtml='<div class="faq"><h2>'+$T.pkg.faqTitle+'</h2>'
    $fi=0
    foreach($fq in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $fqHtml+="<details$oo><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>"; $fi++ }
    $fqHtml+="</div>"
    $fqEnts=@(); foreach($fq in $faqs){ $qq=$fq.q -replace '"',"'"; $aa=$fq.a -replace '"',"'"; $fqEnts+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
    $fqSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($fqEnts -join ",")+"]}</script>"
    $en="/"+$cdir+"/packages/"
    $pidx=$hubUrl+"packages/"
    $canon="https://www.adventuresafariafrica.com"+$pidx
    $phre='<link rel="alternate" hreflang="en" href="https://www.adventuresafariafrica.com'+$en+'">'
    foreach($g2 in @("it","fr","de","es")){ $phre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com/'+$g2+'/'+$HUB[$cdir][$g2]+'/packages/">' }
    $phre+='<link rel="alternate" hreflang="x-default" href="https://www.adventuresafariafrica.com'+$en+'">'
    $ptitle=$hubname+" "+$T.hub.packagesWord
    $pdesc=$hubname+"."
    $pbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$hubUrl+'">'+$hubname+'</a> > '+$T.pkg.packagesWord+'</nav>'
    $pbody+='<section class="block"><div class="wrap"><p class="eyebrow">'+$hubname+'</p><h1>'+$ptitle+'</h1><div class="grid g3">'+$cards+'</div>'+$fqHtml+'</div></section></main>'
    $phtml=Mk-Page $lang $canon $ptitle $pdesc $pbody ($phre+$fqSchema)
    $pout=$lang+"/"+$HUB[$cdir][$lang]+"/packages"
    New-Item -ItemType Directory -Path $pout -Force | Out-Null
    $phtml | Out-File -FilePath ($pout+"/index.html") -Encoding utf8
    $k++
  }
}
"localized pkgindex: $k"
