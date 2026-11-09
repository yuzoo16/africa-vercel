# scopetest3.ps1 ASCII - side by side
$HUB = @{"a"="x";"b"="y"}
$hub=$HUB["a"]
$r1 = "HUB-after-hub-assign=" + $HUB.GetType().Name
$IMG = @{"TZ"=@("u1","a1");"KE"=@("u2","a2")}
$im=$IMG["KE"]
$r2 = "IMG-after-im-assign=" + $IMG.GetType().Name
function F { $hub2=$HUB["b"]; return $hub2 }
$r3 = "func-read=" + (F) + " HUB-after-func=" + $HUB.GetType().Name
($r1 + "`r`n" + $r2 + "`r`n" + $r3) | Out-File "$PSScriptRoot/scopetest3-out.txt" -Encoding ascii
