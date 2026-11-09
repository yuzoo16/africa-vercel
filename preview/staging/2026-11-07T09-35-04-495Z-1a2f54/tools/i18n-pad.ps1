# i18n-pad.ps1 ??? FAQ padding + schema rebuild. Pure ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$LANGS = @("it","fr","de","es")
$ACCQ = @{
 "it"=@(@{"q"="Posizione o lusso: cosa conta di piu?";"a"="Posizione: un campo mobile dentro i branchi batte un lodge cinque stelle a due ore. Spendi per zona e stagione, non per filati."},@{"q"="Tenda o lodge?";"a"="Tende per atmosfera e mobilita Migrazione; lodge per piscine, camere famiglia e muri solidi. Stessi game drive in entrambi."},@{"q"="Con quanto anticipo prenotare i campi migliori?";"a"="Delta e crater-rim 9-12 mesi in stagione; Serengeti mobili 6-9. La disponibilita, non il prezzo, e il vincolo."});
 "fr"=@(@{"q"="Emplacement ou luxe : quoi privilegier ?";"a"="Emplacement : un camp mobile dans les troupeaux bat un lodge cinq etoiles a deux heures. Depensez par zone et saison."},@{"q"="Tente ou lodge ?";"a"="Tentes pour ambiance et mobilite Migration ; lodges pour piscines, chambres famille et murs solides."},@{"q"="A quelle avance reserver les meilleurs camps ?";"a"="Delta et crater-rim 9-12 mois en saison ; Serengeti mobiles 6-9. La disponibilite, pas le prix, est la contrainte."});
 "de"=@(@{"q"="Lage oder Luxus: was zaehlt mehr?";"a"="Lage: mobiles Camp in den Herden schlaegt Fuenf-Sterne-Lodge zwei Stunden entfernt. Ausgeben nach Zone und Saison."},@{"q"="Zelt oder Lodge?";"a"="Zelte fuer Atmosphaere und Migrations-Mobilitaet; Lodges fuer Pools, Familienzimmer, massive Waende."},@{"q"="Wie frueh beste Camps buchen?";"a"="Delta und Kraterrand 9-12 Monate in Saison; Serengeti-Mobile 6-9. Verfuegbarkeit, nicht Preis, ist Engpass."});
 "es"=@(@{"q"="Ubicacion o lujo: que importa mas?";"a"="Ubicacion: un campamento movil dentro de manadas supera un lodge cinco estrellas a dos horas. Gaste por zona y temporada."},@{"q"="Tienda o lodge?";"a"="Tiendas por ambiente y movilidad migracion; lodges por piscinas, habitaciones familia y muros solidos."},@{"q"="Con cuanta antelacion reservar los mejores?";"a"="Delta y crater-rim 9-12 meses en temporada; Serengeti moviles 6-9. La disponibilidad, no el precio, es la restriccion."})
}
function Pad-File($file,$extra,$target){
  $t=[IO.File]::ReadAllText($file)
  if($t -notmatch '<div class="faq">'){ return "no-faqdiv" }
  $cur=([regex]::Matches($t,"<details[ >]").Count)
  if($cur -ge $target){ return "ok-" + $cur }
  $need=$target-$cur
  $add=@()
  for($i=0;$i -lt $need;$i++){ $add+=$extra[$i % $extra.Count] }
  $html=""
  foreach($fq in $add){ $html+="<details><summary>"+$fq.q+"</summary><p>"+$fq.a+"</p></details>" }
  $fi = $t.IndexOf('<div class="faq">')
  if ($fi -ge 0) {
    $sub = $t.Substring($fi)
    $lastDet = -1
    $m2 = [regex]::Matches($sub, "</details>")
    if ($m2.Count -gt 0) { $lastDet = $m2[$m2.Count-1].Index + $m2[$m2.Count-1].Length }
    if ($lastDet -gt 0) {
      $closeDiv = $sub.IndexOf("</div>", $lastDet)
      if ($closeDiv -gt 0) {
        $t = $t.Substring(0, $fi) + $sub.Substring(0, $closeDiv) + $html + $sub.Substring($closeDiv)
      }
    }
  }
  $faqs=@()
  foreach($m in [regex]::Matches($t,'<details[^>]*><summary>(.*?)</summary>([\s\S]*?)</details>')){
    $qq=$m.Groups[1].Value -replace "<[^>]+>",""
    $aa=$m.Groups[2].Value -replace "<[^>]+>"," " -replace "\s+"," "
    $faqs+=@{"q"=$qq.Trim();"a"=$aa.Trim()}
  }
  $ents=@()
  foreach($fq in $faqs){
    $qq=$fq.q -replace '"',"'"
    $aa=$fq.a -replace '"',"'"
    $ents+='{"@type":"Question","name":"'+$qq+'","acceptedAnswer":{"@type":"Answer","text":"'+$aa+'"}}'
  }
  $sch='<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($ents -join ",")+"]}</script>"
  $t=$t -replace '(<script type="application/ld\+json">\{"@context":"https://schema.org","@type":"FAQPage"[^<]*</script>)', ''
  $t=$t -replace '</body>', ($sch+'</body>')
  [IO.File]::WriteAllText($file,$t)
  return "padded-to-" + $faqs.Count
}
foreach ($lang in $LANGS) {
  $C = ([IO.File]::ReadAllText("data/i18n/"+$lang+"-content.json") | ConvertFrom-Json)
  $pool=@()
  for($i=0;$i -lt 9;$i++){ $pool+=$C.faq[(($lang.Length*31+$i*5)%$C.faq.Count)] }
  foreach ($a in @("tanzania","kenya","uganda","botswana","namibia","south-africa")) {
    # the accommodation hub keeps its English slug on every tree (/it/accommodation/)
    $hubd="accommodation"
    $accd=@{"tanzania"="tanzania";"kenya"="kenya";"uganda"="uganda";"botswana"="botswana";"namibia"="namibia";"south-africa"="south-africa"}[$a]
    $f=Join-Path $root ($lang+"\"+$hubd+"\"+$accd+"\index.html")
    if(Test-Path $f){
      $mine=@($ACCQ[$lang]) + $pool
      Write-Output ($lang+"/"+$accd+": "+(Pad-File $f $mine 9))
    }
  }
  # the consultation page keeps its English slug on every tree
  # (/it/safari-consultation/, not /it/consulenza/ or /it/consult/)
  $cdir="safari-consultation"
  $cf=Join-Path $root ($lang+"\"+$cdir+"\index.html")
  if(Test-Path $cf){ Write-Output ($lang+"/consult: "+(Pad-File $cf $pool 9)) }
  $bdir="blog"
  $bf=Join-Path $root ($lang+"\"+$bdir)
  if(Test-Path $bf){
    # skip the category hub - it is a listing page, not an article
    foreach($pf in (Get-ChildItem $bf -Directory | Where-Object { $_.Name -notlike "category*" } | ForEach-Object { Join-Path $_.FullName "index.html" } | Where-Object { Test-Path $_ })){
      $r=Pad-File $pf $pool 9
      if($r -notlike "ok-*"){ Write-Output ($lang+"/blogpost: "+$r) }
    }
  }
}
"pad done"
