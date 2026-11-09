# jsonbisect.ps1 ASCII — find broken country block in hub JSONs
$base = "C:\Users\HP\OneDrive\Documents\Default Project\data\i18n\"
foreach ($f in @("it-hubs","fr-hubs","de-hubs","es-hubs")) {
  Write-Output ("== " + $f)
  $t = [IO.File]::ReadAllText($base + $f + ".json")
  foreach ($cc in @("tanzania","kenya","uganda","botswana","namibia","south-africa","ethiopia")) {
    $start = $t.IndexOf([char]34 + $cc + [char]34 + ":")
    if ($start -lt 0) { Write-Output ("  " + $cc + " KEY-MISSING"); continue }
    $depth = 0; $instr = $false; $esc = $false; $i = $start; $end = -1
    while ($i -lt $t.Length) {
      $ch = $t[$i]
      if ($instr) {
        if ($esc) { $esc = $false }
        elseif ($ch -eq "\") { $esc = $true }
        elseif ($ch -eq [char]34) { $instr = $false }
      } else {
        if ($ch -eq [char]34) { $instr = $true }
        elseif ($ch -eq "{") { $depth++ }
        elseif ($ch -eq "}") { $depth--; if ($depth -eq 0) { $end = $i; break } }
      }
      $i++
    }
    if ($end -lt 0) { Write-Output ("  " + $cc + " UNBALANCED"); continue }
    $block = "{" + $t.Substring($start, $end - $start + 1) + "}"
    try { $block | ConvertFrom-Json | Out-Null; Write-Output ("  " + $cc + " ok") }
    catch { Write-Output ("  " + $cc + " BROKEN: " + $_.Exception.Message.Substring(0, [Math]::Min(100, $_.Exception.Message.Length))) }
  }
}
