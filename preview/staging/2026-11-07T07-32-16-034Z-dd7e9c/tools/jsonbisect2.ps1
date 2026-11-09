# jsonbisect2.ps1 ASCII — validate top-level blocks of globals files
$base = "C:\Users\HP\OneDrive\Documents\Default Project\data\i18n\"
foreach ($f in @("it-globals","fr-globals","de-globals","es-globals")) {
  Write-Output ("== " + $f)
  $t = [IO.File]::ReadAllText($base + $f + ".json")
  foreach ($kk in @("countryShort","styleBlurb","globals")) {
    $start = $t.IndexOf([char]34 + $kk + [char]34 + ":")
    if ($start -lt 0) { Write-Output ("  " + $kk + " KEY-MISSING"); continue }
    $depth = 0; $instr = $false; $i = $start; $end = -1
    while ($i -lt $t.Length) {
      $ch = $t[$i]
      if ($instr) {
        if ($ch -eq [char]34) { $instr = $false }
      } else {
        if ($ch -eq [char]34) { $instr = $true }
        elseif ($ch -eq "{") { $depth++ }
        elseif ($ch -eq "}") { $depth--; if ($depth -eq 0) { $end = $i; break } }
      }
      $i++
    }
    if ($end -lt 0) { Write-Output ("  " + $kk + " UNBALANCED"); continue }
    $block = "{" + $t.Substring($start, $end - $start + 1) + "}"
    try { $block | ConvertFrom-Json | Out-Null; Write-Output ("  " + $kk + " ok") }
    catch { Write-Output ("  " + $kk + " BROKEN") }
  }
}
