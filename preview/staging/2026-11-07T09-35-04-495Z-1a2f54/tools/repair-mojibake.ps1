# repair-mojibake.ps1 — pure ASCII. Replaces double-encoded sequences with correct glyphs.
function S($codes){ $s=""; foreach($c in $codes){ $s+=[char]$c }; return $s }
$map = @{}
$map[(S @(226,8364,8220))] = [char]8211
$map[(S @(194,183))] = [char]183
$map[(S @(226,8224,8217))] = [char]8594
$map[(S @(226,8364,8221))] = [char]8221
$map[(S @(226,8364,8220))] = [char]8211
$map[(S @(226,339,8220))] = [char]10003
$map[(S @(226,8211,190))] = [char]9662
$map[(S @(226,8364,186))] = [char]8250
$map[(S @(226,732,176))] = [char]9776
$map[(S @(194,169))] = [char]169
$map[(S @(194,178))] = [char]178
$map[(S @(226,8364,8221))] = [char]8221
$exts = @("*.html","*.css","*.js","*.json","*.md","*.toml","*.txt","*.xml")
$n=0
foreach ($e in $exts) {
  foreach ($f in (Get-ChildItem -Recurse -Filter $e | Where-Object { $_.FullName -notlike "*\tools\*" })) {
    $t=[IO.File]::ReadAllText($f.FullName); $orig=$t
    foreach ($k in $map.Keys){ $t=$t.Replace($k,$map[$k]) }
    if ($t -ne $orig) { [IO.File]::WriteAllText($f.FullName,$t); $n++ }
  }
}
"repaired files: $n"
$left=@{}
foreach ($f in (Get-ChildItem -Recurse -Filter *.html)) {
  $t=[IO.File]::ReadAllText($f.FullName)
  foreach ($m in [regex]::Matches($t,'[^\x00-\x7F]{1,5}')) {
    $codes=($m.Value.ToCharArray()|ForEach-Object{[int]$_})-join ","
    if ($codes -match "^(226|194),") { $left[$codes]++ }
  }
}
"remaining mojibake signatures:"
$left.GetEnumerator() | ForEach-Object { $_.Key + " x" + $_.Value }
"scan done"
