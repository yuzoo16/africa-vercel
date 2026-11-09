# consolidate.ps1 — move new flat full-pages over old stub dir/index, drop dupes. ASCII.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$pairs = @(
 "national-parks/tarangire","national-parks/lake-manyara","national-parks/ruaha","national-parks/nyerere",
 "national-parks/amboseli","national-parks/samburu","national-parks/lake-naivasha","national-parks/kruger",
 "national-parks/etosha","national-parks/sossusvlei","national-parks/chobe","national-parks/okavango-delta",
 "national-parks/bwindi","national-parks/kibale",
 "activities/game-drives","activities/walking-safaris","activities/night-safaris","activities/hot-air-balloon-safari",
 "activities/chimpanzee-trekking","activities/boat-safaris","activities/photographic-safaris","activities/cultural-tours",
 "activities/bird-watching","activities/kilimanjaro-trekking",
 "travel-guide/safari-tipping","travel-guide/safari-visas","travel-guide/family-safari-guide","travel-guide/first-safari",
 "travel-guide/photography","travel-guide/solo-safari","travel-guide/luxury-safari-guide"
)
$n = 0
foreach ($p in $pairs) {
  $flat = $p + ".html"; $dirf = $p + "/index.html"
  if ((Test-Path $flat) -and (Test-Path $dirf)) {
    Move-Item -Path $flat -Destination $dirf -Force
    $n++
  } elseif ((Test-Path $flat) -and (-not (Test-Path $dirf))) {
    New-Item -ItemType Directory -Path $p -Force | Out-Null
    Move-Item -Path $flat -Destination $dirf -Force
    $n++
  }
}
"consolidated: $n"
$left = Get-ChildItem -Recurse -Filter *.html | Where-Object { $_.Name -ne "index.html" -and $_.Name -ne "404.html" } | Select-Object -ExpandProperty FullName
"leftover flats: " + $left.Count
$left | ForEach-Object { $_.Replace($root + "\","") }
