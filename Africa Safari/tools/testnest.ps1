# testnest.ps1 ASCII
$r1 = @(@("a","b","c"))
$r2 = @(@("a","b"),@("c","d"))
$r3 = @(@{"q"="A";"a"="B"},@{"q"="C";"a"="D"})
$r4 = @(,(@("a","b","c")))
$out = "single-nested-strings=" + $r1.Count + " multi-nested-strings=" + $r2.Count + " nested-hash=" + $r3.Count + " comma-nested=" + $r4.Count
$out | Out-File "$PSScriptRoot/testnest-out.txt" -Encoding ascii
