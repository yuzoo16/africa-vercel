# jsonbisect3.ps1 ASCII — validate each globals hub entry
$base = "C:\Users\HP\OneDrive\Documents\Default Project\data\i18n\"
$hubs = @("africa-safaris","africa-honeymoon-safaris","africa-family-safaris","africa-luxury-safaris","africa-migration-safaris","private-african-safaris","tailor-made-african-safaris","africa-safari-packages","kenya-tanzania-safari","africa-safari-from-zanzibar","africa-gorilla-safaris","africa-photographic-safaris","africa-budget-safaris","east-africa-safari","southern-africa-safari","group-african-safaris")
foreach ($f in @("it-globals","fr-globals","de-globals","es-globals")) {
  Write-Output ("== " + $f)
  $t = [IO.File]::ReadAllText($base + $f + ".json")
  foreach ($hh in $hubs) {
    $start = $t.IndexOf([char]34 + $hh + [char]34 + ":")
    if ($start -lt 0) { Write-Output ("  " + $hh + " KEY-MISSING"); continue }
    $depth = 0; $instr = $false; $i = $start; $end = -1
    while ($i -lt $t.Length) {
      $ch = $t[$i]
      if ($instr) { if ($ch -eq [char]34) { $instr = $false } }
      else {
        if ($ch -eq [char]34) { $instr = $true }
        elseif ($ch -eq "{") { $depth++ }
        elseif ($ch -eq "}") { $depth--; if ($depth -eq 0) { $end = $i; break } }
      }
      $i++
    }
    if ($end -lt 0) { Write-Output ("  " + $hh + " UNBALANCED"); continue }
    $block = "{" + $t.Substring($start, $end - $start + 1) + "}"
    try { $block | ConvertFrom-Json | Out-Null }
    catch { Write-Output ("  " + $hh + " BROKEN") }
  }
  Write-Output "  (only broken listed above)"
}
