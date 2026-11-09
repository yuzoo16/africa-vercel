# cardswap.ps1 — inject images into legacy text-only cards by link mapping. ASCII.
. "$PSScriptRoot/gen-common.ps1"
$RULES = @(
 @("gorilla|bwindi|kibale|queen|murchison|uganda", "UG"),
 @("zanzibar|diani|beach", "BEACH"),
 @("migration|mara-river|calving|grumeti|masai-mara|serengeti|migration", "MIG"),
 @("kilimanjaro|lemosho|machame|marangu|rongai|umbwe|trekking", "KILI"),
 @("botswana|okavango|chobe|moremi|makgadikgadi", "BW"),
 @("namibia|etosha|sossusvlei|damaraland|swakopmund|skeleton", "NA"),
 @("kruger|sabi|cape|garden|winelands|south-africa", "SA"),
 @("kenya|amboseli|samburu|nakuru|naivasha|tsavo", "KE"),
 @("ethiopia|lalibela|simien|omo", "ET"),
 @("tanzania|tarangire|ngorongoro|manyara|ruaha|nyerere|mikumi|arusha", "TZ"),
 @("balloon|photographic|boat|night-safari|walking|cultural|bird|game-drive|honeymoon|family|luxury|private|tailor|group|budget", "MIG"),
 @("cape", "CAPE")
)
function Img-ForHref($href){
  $h=$href.ToLower()
  foreach($r in $RULES){ if($h -match $r[0]){ return $r[1] } }
  return "TZ"
}
$files = Get-ChildItem -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch "\\about\\" }
$n=0
foreach ($f in $files) {
  $t=[IO.File]::ReadAllText($f.FullName)
  if($t -notmatch '<div class="card"><div class="pad">'){ continue }
  $changed=$false
  $out=[regex]::Replace($t, '<div class="card"><div class="pad">([\s\S]*?)</div>\s*</div>', {
    param($m)
    $inner=$m.Groups[1].Value
    if($inner -match '<img '){ return $m.Value }
    $hm=[regex]::Match($inner, 'href="(/[^"]+)"')
    $tm=[regex]::Match($inner, '<h3>(.*?)</h3>')
    $alt="Safari experience"
    if($tm.Success){ $alt=$tm.Groups[1].Value -replace "<[^>]+>","" }
    $key="TZ"
    if($hm.Success){ $key=Img-ForHref $hm.Groups[1].Value }
    $im=$IMG[$key]
    $thumb=$im[0] -replace "w=1800","w=800"
    $script:n++
    return '<div class="card"><img loading="lazy" decoding="async" width="800" height="500" src="'+$thumb+'" alt="'+$alt+'"><div class="pad">'+$inner+'</div></div>'
  })
  if($out -ne $t){ [IO.File]::WriteAllText($f.FullName,$out); $changed=$true }
  if($changed){ Write-Output ("cards-imaged: " + $f.FullName.Replace((Get-Location).Path+"\","")) }
}
"total cards imaged: $n"
