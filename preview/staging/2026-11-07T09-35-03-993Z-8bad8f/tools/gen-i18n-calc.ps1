# gen-i18n-calc.ps1 — localized Kilimanjaro calculators. Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"
. "$PSScriptRoot/i18n-slugs.ps1"
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$UM = Get-Content "data/i18n-urlmap.json" -Raw | ConvertFrom-Json
$LANGS = @("it","fr","de","es")
$n=0
foreach ($lang in $LANGS) {
  $B=([IO.File]::ReadAllText("data/i18n/"+$lang+"-base.json") | ConvertFrom-Json)
  $T=([IO.File]::ReadAllText("data/i18n/"+$lang+"-tpl.json") | ConvertFrom-Json)
  $CL=$T.calc; $C2=$T.calc2
  $en="/kilimanjaro/success-calculator/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $enUrl="https://www.adventuresafariafrica.com"+$en
  $prop=$UM."/request-proposal/".$lang
  $khub=$UM."/kilimanjaro/".($lang)
  $fopts=""; for($i=0;$i -lt 4;$i++){ $fopts+='<option value="'+$i+'">'+$C2.fitOpts[$i]+'</option>' }
  $eopts=""; for($i=0;$i -lt 4;$i++){ $eopts+='<option value="'+$i+'">'+$C2.expOpts[$i]+'</option>' }
  $ropts=""
  $rvals=@("lemosho","machame","marangu","rongai","umbwe","northern")
  for($i=0;$i -lt 6;$i++){ $ropts+='<option value="'+$rvals[$i]+'">'+$C2.routeOpts[$i]+'</option>' }
  $tipsJs="["
  $ti=0
  foreach($tp in $C2.tips){ if($ti -gt 0){$tipsJs+=","}; $tipsJs+='"'+($tp -replace '"',"'")+'"'; $ti++ }
  $tipsJs+="]"
  $js='<script>document.addEventListener("DOMContentLoaded",function(){var TIPS='+$tipsJs+';document.getElementById("c-go").addEventListener("click",function(){var age=+document.getElementById("c-age").value,fit=+document.getElementById("c-fit").value,trek=+document.getElementById("c-trek").value,alt=+document.getElementById("c-alt").value,route=document.getElementById("c-route").value,days=+document.getElementById("c-days").value;var ra={lemosho:-1,machame:0,rongai:0,marangu:2,umbwe:3,northern:-2};var da={5:3,6:1,7:0,8:-1,9:-2};var score=age+fit+trek+alt+ra[route]+da[days];var level,diff;var L={well:"'+$CL.wellPrep+'",ad:"'+$CL.adequate+'",un:"'+$CL.underPrep+'",no:"'+$CL.notReady+'",mo:"'+$CL.moderate+'",mc:"'+$CL.modChallenging+'",ch:"'+$CL.challenging+'",vc:"'+$CL.veryChallenging+'"};if(score<=-2){level=L.well;diff=L.mo;}else if(score<=2){level=L.ad;diff=L.mc;}else if(score<=6){level=L.un;diff=L.ch;}else{level=L.no;diff=L.vc;}var el=document.getElementById("c-out");el.hidden=false;el.innerHTML="<h3>'+$CL.diffLabel+': "+diff+"</h3><p><strong>'+$CL.prepLabel+': "+level+"</strong> '+$CL.eduNote+'</p><ul><li>"+TIPS.join("</li><li>")+"</li></ul>";el.scrollIntoView({behavior:"smooth",block:"center"});if(window.track)track("kili_calc",{score:score});});});</script>'
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > <a href="'+$khub+'">'+$B.nav.kilimanjaro+'</a> > '+$CL.h1+'</nav>'
  $body+='<section class="block"><div class="wrap" style="max-width:800px"><p class="eyebrow">'+$CL.eyebrow+'</p><h1>'+$CL.h1+'</h1><p class="lead">'+$CL.lead+'</p>'
  $body+='<div class="quiz"><div class="f2"><div><label for="c-age">'+$CL.age+'</label><select id="c-age"><option value="0">-30</option><option value="1">30-44</option><option value="2">45-59</option><option value="3">60+</option></select></div>'
  $body+='<div><label for="c-fit">'+$CL.fit+'</label><select id="c-fit">'+$fopts+'</select></div></div>'
  $body+='<div class="f2"><div><label for="c-trek">'+$CL.trek+'</label><select id="c-trek">'+$eopts+'</select></div>'
  $body+='<div><label for="c-alt">'+$CL.alt+'</label><select id="c-alt">'+$eopts+'</select></div></div>'
  $body+='<div class="f2"><div><label for="c-route">'+$CL.route+'</label><select id="c-route">'+$ropts+'</select></div>'
  $body+='<div><label for="c-days">'+$CL.days+'</label><select id="c-days"><option value="5">5</option><option value="6">6</option><option value="7" selected>7</option><option value="8">8</option><option value="9">9</option></select></div></div>'
  $body+='<p><button class="btn btn-p" id="c-go">'+$CL.go+'</button></p><div id="c-out" hidden></div></div>'
  $body+='<h2>'+$CL.howRead+'</h2><p>'+$CL.readText+'</p>'
  $body+='<p><a class="btn btn-g" href="'+$prop+'">'+$CL.planWith+'</a></p>'
  $body+='</div></section></main>'
  $hre='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g2 in @("it","fr","de","es")){ $hre+='<link rel="alternate" hreflang="'+$g2+'" href="https://www.adventuresafariafrica.com'+($UM.$en.$g2)+'">' }
  $hre+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  $html='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$CL.h1+' | Adventure Safari Africa</title><meta name="description" content="'+$CL.lead+'"><link rel="canonical" href="'+$canon+'">'+$hre+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+$js+'<div id="site-footer"></div></body></html>'
  $outdir=$lang+"/"+$HUB["kilimanjaro"][$lang]+"/"+$KILISLUG["success-calculator"][$lang]
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
}
"localized calculators: $n"
