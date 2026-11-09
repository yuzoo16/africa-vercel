# testmini.ps1 ASCII
try {
$x = @(@{"q"="A?";"a"="B."},@{"q"="C?";"a"="D."})
("MINI-OK count=" + $x.Count) | Out-File "$PSScriptRoot/testmini-out.txt" -Encoding ascii
} catch {
("MINI-FAIL: " + $_.Exception.Message) | Out-File "$PSScriptRoot/testmini-out.txt" -Encoding ascii
}
