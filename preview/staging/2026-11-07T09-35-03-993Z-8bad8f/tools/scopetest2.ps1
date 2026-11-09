# scopetest2.ps1 ASCII
$IMG = @{"TZ"=@("u1","a1");"KE"=@("u2","a2")}
$im=$IMG["TZ"]
$r1 = "first=" + $im[0] + " IMG-type=" + $IMG.GetType().Name
$im=$IMG["KE"]
$r2 = "second=" + $im[0]
($r1 + "`r`n" + $r2) | Out-File "$PSScriptRoot/scopetest2-out.txt" -Encoding ascii
