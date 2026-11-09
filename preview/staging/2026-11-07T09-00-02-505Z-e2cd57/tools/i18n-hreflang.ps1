# i18n-hreflang.ps1 — full 6-way hreflang on EN pages. Pure ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$UM = Get-Content "data/i18n-urlmap.json" -Raw | ConvertFrom-Json
$n=0
foreach ($f in (Get-ChildItem -Recurse -Filter *.html)) {
  $t=[IO.File]::ReadAllText($f.FullName)
  $m=[regex]::Match($t, '<html lang="en">')
  if(-not $m.Success){ continue }
  $rel=$f.FullName.Replace($root + [IO.Path]::DirectorySeparatorChar, "").Replace("\","/")
  $enu="/"+($rel -replace "index\.html$","")
  if(-not $UM.$enu){ continue }
  $enUrl="https://www.adventuresafariafrica.com"+$enu
  $cluster='<link rel="alternate" hreflang="en" href="'+$enUrl+'">'
  foreach($g in @("it","fr","de","es")){ $cluster+='<link rel="alternate" hreflang="'+$g+'" href="https://www.adventuresafariafrica.com'+($UM.$enu.$g)+'">' }
  $cluster+='<link rel="alternate" hreflang="x-default" href="'+$enUrl+'">'
  $t2=[regex]::Replace($t, '(<link rel="alternate" hreflang="[^"]+" href="[^"]+">)+', $cluster)
  if($t2 -ne $t){ [IO.File]::WriteAllText($f.FullName,$t2); $n++ }
}
"en hreflang updated: $n"
