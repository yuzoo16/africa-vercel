# testmini2.ps1 ASCII
try {
$a = @(@("a","b","c","d","e"))
$r1 = "NEST-STRINGS count=" + $a.Count
} catch { $r1 = "NEST-STRINGS FAIL: " + $_.Exception.Message }
try {
$b = @(@("a","b","From $7,400","d"))
$r2 = "NEST-DOLLAR count=" + $b.Count + " val3=" + $b[0][2]
} catch { $r2 = "NEST-DOLLAR FAIL: " + $_.Exception.Message }
($r1 + "`r`n" + $r2) | Out-File "$PSScriptRoot/testmini2-out.txt" -Encoding ascii
