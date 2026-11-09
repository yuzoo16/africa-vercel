# testoka.ps1 ASCII - bisect okavango args
. "$PSScriptRoot/gen-common.ps1"
function New-Park($slug,$name,$country,$imgk,$lead,$wild,$time,$access,$stays,$days,$safaris,$combo,$fu){
  ("STUB slug=" + $slug + " safT=" + $safaris.GetType().Name + " safC=" + $safaris.Count + " fuC=" + $fu.Count) | Out-File "$PSScriptRoot/testoka-out.txt" -Encoding ascii -Append
}
"assign-only" | Out-File "$PSScriptRoot/testoka-out.txt" -Encoding ascii
$saf = @(@("/botswana-safari/8-day-botswana-safari/","8-Day Okavango and Chobe","8 days","From $7,400","Delta, Moremi, Chobe."),@("/botswana-safari/5-day-botswana-safari/","5-Day Explorer","5 days","From $3,900","Delta taste plus Chobe."))
("SAF-OK count=" + $saf.Count + " e0type=" + $saf[0].GetType().Name) | Out-File "$PSScriptRoot/testoka-out.txt" -Encoding ascii -Append
$fu = @(@{"q"="What is a mokoro safari like?";"a"="A silent poled canoe gliding reed channels past hippos and elephants - no engine, no rush, often the trip highlight."},@{"q"="Why is the flood in dry season?";"a"="Angolan rains take months to arrive: peak water June to August, long after local rains ended. Plan mokoro trips accordingly."},@{"q"="Land or water camp?";"a"="Both if budget allows: water camps for mokoro and walks, land camps for predators and night drives."})
("FU-OK count=" + $fu.Count) | Out-File "$PSScriptRoot/testoka-out.txt" -Encoding ascii -Append
New-Park "okavango-delta" "Okavango Delta" "Botswana" "BW" "Lead." "Wild." "Time." "Access." "Stays." "2 to 3 days." $saf "Combo." $fu
"CALL-OK" | Out-File "$PSScriptRoot/testoka-out.txt" -Encoding ascii -Append
