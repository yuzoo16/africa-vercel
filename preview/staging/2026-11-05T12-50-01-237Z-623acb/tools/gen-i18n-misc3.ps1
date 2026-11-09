# gen-i18n-misc3.ps1 — proposal, consultation, quiz, search, pkgindex. Pure ASCII.
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
function Mk-Faq($faqs,$ttl){
  $h='<div class="faq"><h2>'+$ttl+'</h2>'
  $fi=0
  foreach($x in $faqs){ $oo=""; if($fi -eq 0){$oo=" open"}; $h+="<details$oo><summary>"+$x.q+"</summary><p>"+$x.a+"</p></details>"; $fi++ }
  $h+="</div>"
  $ents=@(); foreach($x in $faqs){ $qq=$x.q -replace '"',"'"; $aa=$x.a -replace '"',"'"; $ents+="{`"@type`":`"Question`",`"name`":`"$qq`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$aa`"}}" }
  $sch='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($ents -join ",")+"]}</script>"
  return @{"html"=$h;"schema"=$sch}
}
function Mk-Page($lang,$canon,$title,$desc,$body,$extra){
  $h='<!doctype html><html lang="'+$lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+$title+' | Adventure Safari Africa</title><meta name="description" content="'+$desc+'"><link rel="canonical" href="'+$canon+'">'+$extra+'<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>'+$body+'<div id="site-footer"></div></body></html>'
  return $h
}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $M=$D[$lang].misc
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $F=$B.form
  $en="/request-proposal/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $dopts=""
  foreach($cty in @("Tanzania","Kenya","Uganda","Botswana","Namibia","South Africa","Ethiopia")){ $dopts+='<option value="'+$cty+'">'+$B.countries.$cty+'</option>' }
  $dopts+='<option value="Kenya & Tanzania">Kenya & Tanzania</option><option value="Tanzania & Zanzibar">Tanzania & Zanzibar</option>'
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$F.title+'</nav>'
  $body+='<section class="block"><div class="wrap" style="max-width:820px"><p class="eyebrow">'+$F.title+'</p><h1>'+$F.title+'</h1><p class="lead">'+$M.proposal.lead+'</p>'
  $body+='<form class="lead-form" data-proposal novalidate><p data-form-err role="alert" style="color:#a33" hidden></p><p data-form-ok role="status" style="color:#1a6b3c;font-weight:700" hidden></p>'
  $body+='<div class="f2"><div><label for="name">'+$F.name+' *</label><input id="name" name="name" required></div><div><label for="email">'+$F.email+' *</label><input id="email" name="email" type="email" required></div></div>'
  $body+='<div class="f2"><div><label for="phone">'+$F.phone+'</label><input id="phone" name="phone"></div><div><label for="country">'+$F.country+'</label><input id="country" name="country"></div></div>'
  $body+='<div class="f2"><div><label for="contact">'+$F.contactMethod+'</label><select id="contact" name="contact"><option>Email</option><option>WhatsApp</option></select></div><div><label for="destination">'+$F.destination+'</label><select id="destination" name="destination">'+$dopts+'</select></div></div>'
  $body+='<div class="f2"><div><label for="dates">'+$F.dates+'</label><input id="dates" name="dates"></div><div><label for="flex">'+$F.flexible+' <input id="flex" name="flexible" type="checkbox" style="width:auto"></label></div></div>'
  $body+='<div class="f2"><div><label for="adults">'+$F.adults+'</label><select id="adults" name="adults"><option>1</option><option selected>2</option><option>3</option><option>4</option><option>5+</option></select></div><div><label for="children">'+$F.children+'</label><input id="children" name="children"></div></div>'
  $body+='<div class="f2"><div><label for="days">'+$F.days+'</label><select id="days" name="days"><option>3-5</option><option selected>6-8</option><option>9-12</option><option>13+</option></select></div><div><label for="style">'+$F.safariStyle+'</label><select id="style" name="style"><option>Private</option><option>Luxury</option><option>Family</option><option>Honeymoon</option></select></div></div>'
  $body+='<div class="f2"><div><label for="budget">'+$F.budget+'</label><select id="budget" name="budget"><option>Value</option><option selected>Mid-range</option><option>Luxury</option></select></div><div><label for="occasion">'+$F.occasion+'</label><input id="occasion" name="occasion"></div></div>'
  $body+='<div><label for="interests">'+$F.interests+'</label><input id="interests" name="interests"></div>'
  $body+='<div><label for="info">'+$F.info+'</label><textarea id="info" name="info" rows="4"></textarea></div>'
  $body+='<input type="hidden" name="language" value="'+$lang+'">'
  $body+='<div style="position:absolute;left:-9999px" aria-hidden="true"><label>Company<input name="company" tabindex="-1"></label></div>'
  $body+='<label style="font-weight:400;font-size:.9rem"><input type="checkbox" required style="width:auto"> '+$F.consent+' *</label>'
  $body+='<div><button class="btn btn-p" type="submit">'+$F.submit+'</button></div></form>'
  $body+='</div></section></main>'
  $html=Mk-Page $lang $canon $F.title $M.proposal.lead $body ((Mk-Hre $en $UM)+'<script type="application/ld+json">{"@context":"https://schema.org","@type":"WebPage"}</script>')
  $outdir=$lang+"/"+$HUB["request-proposal"][$lang]
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
  $MC=$M.consult
  $en2="/safari-consultation/"
  $loc2=$UM.$en2.$lang
  $canon2="https://www.adventuresafariafrica.com"+$loc2
  $cbody='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$B.ui.consultation+'</nav>'
  $cbody+='<section class="block"><div class="wrap" style="max-width:820px"><p class="eyebrow">'+$B.ui.consultation+'</p><h1>'+$B.ui.consultation+'</h1><p class="lead">'+$MC.lead+'</p><ul>'
  foreach($bl in $MC.bullets){ $cbody+='<li>'+$bl+'</li>' }
  $cbody+='</ul><div data-calendly style="margin:20px 0"></div>'
  $fb2=Mk-Faq $MC.faqs $B.ui.consultation
  $cbody+=$fb2.html
  $cbody+='<p><a href="'+$prop+'">'+$B.ui.requestProposal+'</a> | <a data-wa href="#">WhatsApp</a></p>'
  $cbody+='</div></section></main>'
  $chtml=Mk-Page $lang $canon2 $B.ui.consultation $MC.lead $cbody ((Mk-Hre $en2 $UM)+$fb2.schema)
  $coutdir=$lang+"/"+$HUB["safari-consultation"][$lang]
  New-Item -ItemType Directory -Path $coutdir -Force | Out-Null
  $chtml | Out-File -FilePath ($coutdir+"/index.html") -Encoding utf8
  $n++
}
"localized proposal+consultation: $n"
