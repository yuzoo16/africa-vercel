# ascii-fix.ps1 — pure ASCII. Normalizes non-ASCII chars in generator scripts for PS 5.1.
$files = @("tools/gen-common.ps1","tools/gen-hubs.ps1","tools/gen-cats.ps1","tools/gen-pkgs.ps1","tools/gen-pkgs-data1.ps1","tools/gen-pkgs-data2.ps1","tools/gen-info.ps1")
$map = @{}
$map[[char]0x2013] = '-'; $map[[char]0x2014] = '-'; $map[[char]0x2012] = '-'; $map[[char]0x2010] = '-'; $map[[char]0x2011] = '-'
$map[[char]0x2018] = "'"; $map[[char]0x2019] = "'"; $map[[char]0x201C] = '"'; $map[[char]0x201D] = '"'
$map[[char]0x2026] = '...'; $map[[char]0x00A0] = ' '; $map[[char]0x00B7] = '|'
$map[[char]0x2190] = '<-'; $map[[char]0x2192] = '->'
$map[[char]0x00E9] = 'e'; $map[[char]0x00E8] = 'e'; $map[[char]0x00EA] = 'e'; $map[[char]0x00E0] = 'a'
$map[[char]0x00E2] = 'a'; $map[[char]0x00F4] = 'o'; $map[[char]0x00FB] = 'u'; $map[[char]0x00E7] = 'c'
foreach($f in $files){ $t=[IO.File]::ReadAllText($f); foreach($k in $map.Keys){ $t=$t.Replace($k,$map[$k]) }; [IO.File]::WriteAllText($f,$t) }
"ascii-normalized"
