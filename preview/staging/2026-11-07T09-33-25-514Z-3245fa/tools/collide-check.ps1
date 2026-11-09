# collide-check.ps1 ASCII — find case-variant variable collisions per script
$files = Get-ChildItem "C:\Users\HP\OneDrive\Documents\Default Project\tools\gen-*.ps1"
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f.FullName)
  $vars = @{}
  foreach ($m in [regex]::Matches($t, '\$([A-Za-z_][A-Za-z0-9_]*)')) {
    $v = $m.Groups[1].Value
    if ($v -match "^(true|false|null|args|PSItem|_|MyInvocation|PSScriptRoot|HOME|PROFILE|PSVersionTable|Error|LASTEXITCODE)$") { continue }
    $k = $v.ToLower()
    if (-not $vars.ContainsKey($k)) { $vars[$k] = @() }
    if ($vars[$k] -notcontains $v) { $vars[$k] += $v }
  }
  $bad = @()
  foreach ($k in $vars.Keys) { if ($vars[$k].Count -gt 1) { $bad += ($k + "=[" + ($vars[$k] -join ",") + "]") } }
  if ($bad.Count -gt 0) { Write-Output ($f.Name + " COLLISIONS: " + ($bad -join " ")) }
}
"collide check done"
