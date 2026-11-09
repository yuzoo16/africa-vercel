# tokcheck.ps1 ASCII - tokenize okavango line, report errors
$src = [IO.File]::ReadAllText("C:\Users\HP\OneDrive\Documents\Default Project\tools\gen-parks2.ps1")
$ok = ($src.Split("`n") | Where-Object { $_ -match 'New-Park "okavango' })
$errs = $null; $toks = $null
$toks = [System.Management.Automation.PSParser]::Tokenize($ok, [ref]$errs)
("tokens=" + $toks.Count) | Out-File "$PSScriptRoot/tokcheck-out.txt" -Encoding ascii
foreach ($e in $errs) { ("ERR L" + $e.Token.StartLine + " C" + $e.Token.StartColumn + ": " + $e.Message) | Out-File "$PSScriptRoot/tokcheck-out.txt" -Encoding ascii -Append }
foreach ($t in $toks) {
  if ($t.StartColumn -gt 1000 -and $t.StartColumn -lt 1120) {
    ("COL " + $t.StartColumn + " TYPE=" + $t.Type + " TEXT=[" + $t.Content + "]") | Out-File "$PSScriptRoot/tokcheck-out.txt" -Encoding ascii -Append
  }
}
"TOK-DONE" | Out-File "$PSScriptRoot/tokcheck-out.txt" -Encoding ascii -Append
