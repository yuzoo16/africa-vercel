# scopetest.ps1 ASCII
$FOO = @{"a"=1}
$foo = "x"
$r1 = "FOO-after-foo-assign=" + $FOO.GetType().Name
$BAR = @{"a"=1}
$bar2 = $BAR["a"]
$r2 = "BAR-after-bar2-assign=" + $BAR.GetType().Name
function Test-FuncScope {
  $baz = $BAZ["k"]
  return $baz
}
$BAZ = @{"k"="v"}
$r3 = "func-result=" + (Test-FuncScope) + " BAZ-after=" + $BAZ.GetType().Name
($r1 + "`r`n" + $r2 + "`r`n" + $r3) | Out-File "$PSScriptRoot/scopetest-out.txt" -Encoding ascii
