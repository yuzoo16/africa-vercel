# i18n-audit.ps1 — translation completeness audit + status. Pure ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$UM = Get-Content "data/i18n-urlmap.json" -Raw | ConvertFrom-Json
function Stats($file){
  if(-not (Test-Path $file)){ return $null }
  $t=[IO.File]::ReadAllText($file)
  $words=(($t -replace "<script[\s\S]*?</script>"," " -replace "<style[\s\S]*?</style>"," " -replace "<[^>]+>"," " -replace "\s+"," ").Trim().Split(" ").Count)
  $canon=([regex]::Match($t,'rel="canonical" href="([^"]+)"').Groups[1].Value)
  return @{
    words=$words;
    title=([regex]::Match($t,"<title>([^<]+)</title>").Groups[1].Value);
    desc=([regex]::Match($t,'meta name="description" content="([^"]*)"').Groups[1].Value);
    h1=([regex]::Matches($t,"<h1[ >]").Count);
    h2=([regex]::Matches($t,"<h2>").Count);
    faqs=([regex]::Matches($t,"<details[ >]").Count);
    imgs=([regex]::Matches($t,"<img ").Count);
    cards=([regex]::Matches($t,'class="card"').Count);
    cta=(($t -match "request-proposal") -and ($t -match "data-wa"));
    hreflang=(@(foreach($hh in [regex]::Matches($t,'hreflang="([a-z-]+)"')){ $hh.Groups[1].Value }) | Sort-Object -Unique) -join ",";
    canon=$canon;
    schemas=(([regex]::Matches($t,'"@type":\s*"([A-Za-z]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique) -join ",")
  }
}
$recs=@()
foreach ($en in $UM.PSObject.Properties.Name) {
  $r=@{en=$en}
  $enfile=$root+"\index.html"
  if($en -ne "/"){ $enfile=$root+"\"+(($en.Trim("/")) -replace "/","\")+"\index.html" }
  $es=Stats $enfile
  $r["enWords"]=0
  if($es){ $r["enWords"]=$es.words }
  foreach ($lang in @("it","fr","de","es")) {
    $loc=$UM.$en.$lang
    $lf=$root+"\"+(($loc.Trim("/")) -replace "/","\")+"\index.html"
    $st=Stats $lf
    if(-not $st){ $r[$lang]="MISSING" }
    else {
      $t=[IO.File]::ReadAllText($lf)
      $enLinks=([regex]::Matches($t,'href="(/[^"#?]*)"') | Where-Object {
        $h=$_.Groups[1].Value
        ($h -notmatch "^/(it|fr|de|es|assets|sitemap.xml|privacy|terms|cookies|robots)") -and ($h -ne "/")
      }).Count
      $selfCanon=($st.canon -eq ("https://www.adventuresafariafrica.com"+$loc))
      $r[$lang]=@{"status"="Published";"words"=$st.words;"title"=($st.title.Length -gt 0);"desc"=($st.desc.Length -gt 0);"h1"=$st.h1;"h2"=$st.h2;"faqs"=$st.faqs;"imgs"=$st.imgs;"cards"=$st.cards;"cta"=$st.cta;"hreflang"=$st.hreflang;"selfCanon"=$selfCanon;"schemas"=$st.schemas;"enLinksLeft"=$enLinks}
    }
  }
  $recs+=$r
}
$recs | ConvertTo-Json -Depth 6 | Out-File -FilePath "data/i18n-status.json" -Encoding utf8
"audited entities: " + $recs.Count
foreach ($lang in @("it","fr","de","es")) {
  $pub=($recs | Where-Object { $_.$lang -ne "MISSING" }).Count
  Write-Output ($lang + " published: " + $pub + " / " + $recs.Count)
}
"--- pages missing per lang ---"
foreach ($lang in @("it","fr","de","es")) {
  $mm=$recs | Where-Object { $_.$lang -eq "MISSING" }
  Write-Output ($lang + " missing: " + $mm.Count)
  $mm | Select-Object -First 8 | ForEach-Object { Write-Output ("  " + $_.en) }
}
"--- thin translations (<50% EN words, both exist) ---"
foreach ($lang in @("it","fr","de","es")) {
  $thin=($recs | Where-Object { $_.$lang -ne "MISSING" -and $_.enWords -gt 200 -and $_.$lang.words -lt ($_.enWords * 0.5) }).Count
  Write-Output ($lang + " thin: " + $thin)
}
"--- EN links left inside localized pages (avg) ---"
foreach ($lang in @("it","fr","de","es")) {
  $vals=$recs | Where-Object { $_.$lang -ne "MISSING" } | ForEach-Object { $_.$lang.enLinksLeft }
  $avg=[math]::Round(($vals | Measure-Object -Average).Average, 1)
  Write-Output ($lang + " avg EN-links left: " + $avg)
}
