# ascii-fix2.ps1 — pure ASCII. Maps known glyphs, deletes any other non-ASCII in gen scripts.
$files = @("tools/gen-common.ps1","tools/gen-hubs.ps1","tools/gen-cats.ps1","tools/gen-pkgs.ps1","tools/gen-pkgs-data1.ps1","tools/gen-pkgs-data2.ps1","tools/gen-info.ps1")
$map = @{}
$map[[char]0x2013] = '-'; $map[[char]0x2014] = '-'; $map[[char]0x2012] = '-'; $map[[char]0x2010] = '-'; $map[[char]0x2011] = '-'
$map[[char]0x2018] = "'"; $map[[char]0x2019] = "'"; $map[[char]0x201C] = '"'; $map[[char]0x201D] = '"'
$map[[char]0x2026] = '...'; $map[[char]0x00A0] = ' '; $map[[char]0x00B7] = ' | '; $map[[char]0x203A] = '>'
$map[[char]0x2190] = '<-'; $map[[char]0x2192] = '->'; $map[[char]0x2713] = 'yes'
foreach($f in $files){
  $t=[IO.File]::ReadAllText($f)
  foreach($k in $map.Keys){ $a=[string]$k; $b=$map[$k]; $t=$t.Replace($a,$b) }
  $t=[regex]::Replace($t,'[^\x00-\x7F]','')
  [IO.File]::WriteAllText($f,$t)
  $left=[regex]::Matches($t,'[^\x00-\x7F]').Count
  Write-Output "$f non-ascii-left: $left"
}
"done"
