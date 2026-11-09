# gen-i18n-misc2.ps1 — about, proposal, consultation, quiz, search, pkgindex. Pure ASCII.
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
function Mk-Head($title,$desc,$canon,$imUrl){
  return '<meta property="og:type" content="website"><meta property="og:title" content="'+$title+'"><meta property="og:description" content="'+$desc+'"><meta property="og:url" content="'+$canon+'"><meta property="og:image" content="'+$imUrl+'"><meta name="twitter:card" content="summary_large_image">'
}
$BADGE = @{"it"="Profilo in arrivo";"fr"="Profil a venir";"de"="Profil folgt";"es"="Perfil proximamente"}
$AH = @{
"mission"=@{"it"="Missione";"fr"="Mission";"de"="Mission";"es"="Mision"};
"why"=@{"it"="Perche esistiamo";"fr"="Pourquoi nous existons";"de"="Warum wir existieren";"es"="Por que existimos"};
"philosophy"=@{"it"="Filosofia safari";"fr"="Philosophie safari";"de"="Safari-Philosophie";"es"="Filosofia safari"};
"team"=@{"it"="Il team";"fr"="Equipe";"de"="Team";"es"="Equipo"};
"local"=@{"it"="Esperienza locale";"fr"="Expertise locale";"de"="Lokale Expertise";"es"="Experiencia local"};
"responsible"=@{"it"="Turismo responsabile";"fr"="Tourisme responsable";"de"="Verantwortlicher Tourismus";"es"="Turismo responsable"};
"community"=@{"it"="Impatto comunita";"fr"="Impact communaute";"de"="Community-Impact";"es"="Impacto comunitario"};
"how"=@{"it"="Come il turismo sostiene";"fr"="Comment le tourisme soutient";"de"="Wie Tourismus foerdert";"es"="Como el turismo apoya"};
"destinations"=@{"it"="Destinazioni";"fr"="Destinations";"de"="Ziele";"es"="Destinos"};
"whyus"=@{"it"="Perche noi";"fr"="Pourquoi nous";"de"="Warum wir";"es"="Por que nosotros"};
"reviews"=@{"it"="Recensioni";"fr"="Avis";"de"="Bewertungen";"es"="Resenas"}
}
$EXPERTW = @{"it"="Esperto";"fr"="Expert";"de"="Experte";"es"="Experto"}
$DIRROLE = @{"it"="Direttore";"fr"="Directeur";"de"="Direktor";"es"="Director"}
$n=0
foreach ($lang in $LANGS) {
  $B=$D[$lang].base; $T=$D[$lang].tpl; $C=$D[$lang].content; $M=$D[$lang].misc
  $prop=$UM."/request-proposal/".$lang
  $cons=$UM."/safari-consultation/".$lang
  $A=$M.about
  $en="/about/"
  $loc=$UM.$en.$lang
  $canon="https://www.adventuresafariafrica.com"+$loc
  $title=$B.nav.about+" | Adventure Safari Africa"
  $desc=$A.storyLead
  $body='<main id="main"><nav class="wrap crumbs"><a href="/'+$lang+'/">'+$B.crumbHome+'</a> > '+$B.nav.about+'</nav>'
  $body+='<div class="hero"><img class="bg" src="https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1800&q=70&auto=format&fit=crop" alt="Africa safari"><div class="hero-in"><p class="eyebrow">'+$B.nav.about+'</p><h1>'+$B.nav.about+'</h1><p class="sub">'+$A.sub+'</p><div class="hero-ctas"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.planMySafari+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a></div></div></div>'
  $body+='<section class="block"><div class="wrap" style="max-width:860px">'
  $body+='<h2>'+$A.storyLead+'</h2><p class="lead">'+$A.story+'</p>'
  $body+='<h2>'+$AH.mission[$lang]+'</h2><p>'+$A.mission+'</p><h2>'+$AH.why[$lang]+'</h2><p>'+$A.whyExist+'</p><h2>'+$AH.philosophy[$lang]+'</h2><ul>'
  foreach($ph in $A.philosophy){ $body+='<li>'+$ph+'</li>' }
  $body+='</ul><h2>Leandry Diamay</h2><div class="card"><div class="pad" style="display:flex;gap:14px"><div class="avatar">LD</div><div><h3>Leandry Diamay - '+$DIRROLE[$lang]+'</h3><p>'+$A.directorBio+'</p></div></div></div>'
  $body+='<p>'+$A.teamNote+'</p>'
  $exs=@("Tanzania|TZ","Kenya|KE","Uganda|UG","Botswana|BW","Namibia|NA","South Africa|SA","Ethiopia|ET")
  $body+='<div class="grid g2">'
  foreach($ex in $exs){
    $cc=$ex.Split("|")[0]; $ii=$ex.Split("|")[1]
    $body+='<div class="card"><div class="pad" style="display:flex;gap:14px"><div class="avatar">'+$ii+'</div><div><h3>'+$B.countries.$cc+' '+$EXPERTW[$lang]+'</h3><p>'+$BADGE[$lang]+'</p></div></div></div>'
  }
  $body+='</div>'
  $body+='<h2>'+$AH.local[$lang]+'</h2><p>'+$A.localExp+'</p><h2>'+$AH.responsible[$lang]+'</h2><p>'+$A.responsible+'</p><h2>'+$AH.community[$lang]+'</h2><p>'+$A.community+'</p><h2>Shujaa wa Upendo</h2><p>'+$A.shujaa+'</p><h2>MAF</h2><p>'+$A.maf+'</p><h2>'+$AH.how[$lang]+'</h2><ol>'
  foreach($hw in $A.howTourism){ $body+='<li>'+$hw+'</li>' }
  $body+='</ol><h2>'+$AH.destinations[$lang]+'</h2><p>'
  foreach($dd in @("tanzania-safari","kenya-safari","uganda-safari","botswana-safari","namibia-safari","south-africa-safari")){ $body+='<a href="'+$UM.("/"+$dd+"/").$lang+'">'+$B.hubnames.$dd+'</a> | ' }
  $body+='</p><h2>'+$AH.whyus[$lang]+'</h2><ul>'
  foreach($w in $A.whyChoose){ $body+='<li>'+$w+'</li>' }
  $body+='</ul><h2>'+$AH.reviews[$lang]+'</h2><p>'+$A.reviewsNote+'</p><div class="grid g3">'
  $body+='<blockquote class="card"><div class="pad"><p>5 stars</p><p>"Our guide repositioned us ahead of a river crossing."</p><p class="meta">Hannah & Tom, UK</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='<blockquote class="card"><div class="pad"><p>5 stars</p><p>"The gorilla trek briefing was honest about difficulty."</p><p class="meta">Marco, Italy</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='<blockquote class="card"><div class="pad"><p>5 stars</p><p>"Kids still talk about the Maasai guide."</p><p class="meta">Dupont family, France</p><p><span class="srcbadge">Direct guest feedback</span></p></div></blockquote>'
  $body+='</div>'
  $body+='<div class="cta-band" style="margin-top:28px"><div><h2>'+$T.ctaBand.planTitle+'</h2><p>'+$T.ctaBand.planText+'</p></div><div style="display:grid;gap:10px"><a class="btn btn-g" href="'+$prop+'">'+$B.ui.requestProposal+'</a><a class="btn btn-wa" data-wa href="#">WhatsApp</a><a href="'+$cons+'" style="color:#fff">'+$B.ui.bookConsultation+'</a></div></div>'
  $body+='</div></section></main>'
  $html=Mk-Page $lang $canon $title $desc $body ((Mk-Head $title $desc $canon "")+(Mk-Hre $en $UM)+'<script type="application/ld+json">{"@context":"https://schema.org","@type":"AboutPage"}</script>')
  $outdir=$lang+"/"+$HUB["about"][$lang]
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
  $html | Out-File -FilePath ($outdir+"/index.html") -Encoding utf8
  $n++
}
"localized about: $n"
