# jsonbisect4.ps1 ASCII
$base = "C:\Users\HP\OneDrive\Documents\Default Project\data\i18n\"
foreach ($f in @("fr-kili")) {
  Write-Output ("== " + $f)
  $t = [IO.File]::ReadAllText($base + $f + ".json")
  $i = 0
  $keys = @()
  $instr = $false; $depth = 0
  $curlen = $t.Length
  $keystart = -1
  while ($i -lt $curlen) {
    $ch = $t[$i]
    if ($instr) { if ($ch -eq [char]34) { $instr = $false } }
    else {
      if ($ch -eq [char]34) {
        $j = $t.IndexOf([char]34, $i + 1)
        $k = $j + 1
        while ($k -lt $curlen -and ($t[$k] -eq " " -or $t[$k] -eq "`t" -or $t[$k] -eq "`r" -or $t[$k] -eq "`n")) { $k++ }
        if ($depth -eq 1 -and $k -lt $curlen -and $t[$k] -eq ":") {
          $keys += $t.Substring($i + 1, $j - $i - 1)
        }
        $instr = $true
        $i = $j
      }
      elseif ($ch -eq "{") { $depth++ }
      elseif ($ch -eq "}") { $depth-- }
      elseif ($ch -eq "[") { $depth++ }
      elseif ($ch -eq "]") { $depth-- }
    }
    $i++
  }
  Write-Output ("root keys: " + ($keys -join " | "))
  Write-Output ("final depth: " + $depth)
}
