# testone.ps1 — run okavango call only, log all output to file. ASCII.
. "$PSScriptRoot/gen-common.ps1"
function New-Park($slug,$name,$country,$imgk,$lead,$wild,$time,$access,$stays,$days,$safaris,$combo,$fu){
  ("STUB-OK slug=" + $slug + " safaris=" + $safaris.Count + " faqs=" + $fu.Count) | Out-File "$PSScriptRoot/testone-out.txt" -Encoding ascii
}
try {
New-Park "okavango-delta" "Okavango Delta" "Botswana" "BW" "A UNESCO water wilderness: mokoro canoes, island walks and predators." "Glide test." "Time test." "Access test." "Stays test." "2 to 3 days." @(@("/x/","Y","8 days","From $7,400","Blurb.")) "Combo test." @(@{"q"="Q1?";"a"="A1."})
"CALL-OK" | Out-File "$PSScriptRoot/testone-out.txt" -Append -Encoding ascii
} catch {
("CALL-FAIL: " + $_.Exception.Message) | Out-File "$PSScriptRoot/testone-out.txt" -Append -Encoding ascii
}
