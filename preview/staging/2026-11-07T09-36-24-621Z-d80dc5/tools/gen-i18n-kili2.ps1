# gen-i18n-kili2.ps1 — kili subs + calculator. Pure ASCII.
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
  return $hre
}
function Mk-Head($title,$desc,$canon,$imUrl){
  return '<meta property="og:type" content="article"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$imUrl+'"><meta name="twitter:card" content="summary_large_image">'
}
function Mk-Page($lang,$canon,$title,$desc,$body,$extra){
  $h='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$extra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  return $h
}
function Mk-Cta($prop,$cons,$B,$T){
  return '<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
}
$SUBT = @{
 "best-time"=@{"it"="Periodo migliore";"fr"="Meilleure periode";"de"="Beste Zeit";"es"="Mejor epoca"};
 "cost"=@{"it"="Costi";"fr"="Couts";"de"="Kosten";"es"="Costos"};
 "packing-list"=@{"it"="Cosa portare";"fr"="Equipement";"de"="Packliste";"es"="Equipaje"};
 "how-long"=@{"it"="Quanto dura";"fr"="Duree";"de"="Dauer";"es"="Duracion"};
 "trekking"=@{"it"="Trekking";"fr"="Trekking";"de"="Trekking";"es"="Senderismo"}
}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $K=$D[$lang].kili
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $kroot=$HUB["kilimanjaro"][$lang]
  $khub=$UM."/kilimanjaro/".($lang)
  $im=$IMG["KILI"]
  foreach ($ss in @("best-time","cost","packing-list","how-long","trekking")) {
    $en="/kilimanjaro/"+$ss+"/"
    $loc=$UM.$en.$lang
    $canon="https://www.adventuresafariafrica.com"+$loc
    $title=$SUBT[$ss][$lang]+" Kilimanjaro"
    $desc=$title+"."
    $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$khub+'">'+$B.nav.kilimanjaro+'</a> > '+$title+'</nav>'
    $body+='<section class="block"><div class="wrap" style="max-width:840px"><p class="eyebrow">'+$B.nav.kilimanjaro+'</p><h1>'+$title+'</h1>'
    if($ss -eq "best-time"){
      $rows=""
      foreach($mi in 0..11){
        $dry=(($mi -ge 0 -and $mi -le 2) -or ($mi -ge 5 -and $mi -le 9))
        $st="green"; if($dry){$st="dry"}
        $rows+="<tr><td>"+$T.months[$mi]+"</td><td>"+$st+"</td></tr>"
      }
      $body+='<p class="lead">'+$K.hubIntro+'</p><table class="cmp"><tr><th>Month</th><th>Season</th></tr>'+$rows+'</table>'
    } elseif($ss -eq "cost"){
      $rows=""
      foreach($rk in @("lemosho-route","machame-route","marangu-route","rongai-route","umbwe-route","northern-circuit")){
        $R=$K.routes.$rk
        $rows+="<tr><td>"+$R.name+"</td><td>"+$R.facts.Dauer+$R.facts.Durata+$R.facts.Duree+$R.facts.Duration+"</td></tr>"
      }
      $body+='<p class="lead">'+$K.hubIntro+'</p><table class="cmp">'+$rows+'</table>'
    } elseif($ss -eq "packing-list"){
      $body+='<p class="lead">'+$K.hubIntro+'</p>'
      foreach($ck in $K.packing.PSObject.Properties){
        $body+='<h2>'+$ck.Name+'</h2><ul>'
        foreach($it in $ck.Value){ $body+='<li>'+$it+'</li>' }
        $body+='</ul>'
      }
    } elseif($ss -eq "how-long"){
      $rows=""
      foreach($rk in @("lemosho-route","machame-route","marangu-route","rongai-route","umbwe-route","northern-circuit")){
        $R=$K.routes.$rk
        $ru=$UM.("/kilimanjaro/"+$rk+"/").$lang
        $rows+="<tr><td><a href=`""+$ru+"`">"+$R.name+"</a></td><td>"+$R.facts.Dauer+$R.facts.Durata+$R.facts.Duree+$R.facts.Duration+"</td></tr>"
      }
      $body+='<p class="lead">'+$K.hubIntro+'</p><table class="cmp">'+$rows+'</table>'
    } else {
      $body+='<p class="lead">'+$K.hubIntro+'</p>'
      $rcards=""
      foreach($rk in @("lemosho-route","machame-route","marangu-route","rongai-route")){
        $ru=$UM.("/kilimanjaro/"+$rk+"/").$lang
        $rn=$K.routes.$rk.name
        $rcards+='<a class="card" href="'+$ru+'"><img loading="lazy" decoding="async" width="800" height="500" src="'+$im[0]+'" alt="'+$rn+'"><div class="pad"><h3>'+$rn+'</h3></div></a>'
      }
      $body+='<div class="grid g3">'+$rcards+'</div>'
    }
    $faqs=@()
    $seed=$ss.Length*7
    for($i=0;$i -lt 9;$i++){ $faqs+=$C.faq[(($seed+$i*5)%$C.faq.Count)] }
    $fb=Mk-Faq $faqs
    $body+=$fb.html
    $body+=(Mk-Cta $prop $cons $B $T)+'</div></section></main>'
    $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon $im[0])+(Mk-Hre $en $loc $UM)+$fb.schema)
    $outdir=$lang+"/"+$kroot+"/"+$KILISLUG[$ss][$lang]
    New-Item -ItemType Directory -Path $outdir -Force | Out-Null
    $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
    $n++
  }
}
"localized kili subs: $n"
