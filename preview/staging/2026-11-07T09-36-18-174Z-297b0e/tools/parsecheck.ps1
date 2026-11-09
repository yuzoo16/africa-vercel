# parsecheck.ps1 — parses serve.ps1, writes errors to parse-out.txt (ASCII only)
$me = $PID
$t = [IO.File]::ReadAllText("C:\Users\HP\OneDrive\Documents\Default Project\tools\serve.ps1")
$errs = $null
[void][System.Management.Automation.PSParser]::Tokenize($t, [ref]$errs)
if ($errs -eq $null -or $errs.Count -eq 0) { "PARSE-OK" | Out-File "C:\Users\HP\OneDrive\Documents\Default Project\tools\parse-out.txt" -Encoding ascii }
else { ($errs | ForEach-Object { "L" + $_.Token.StartLine + ": " + $_.Message }) | Out-File "C:\Users\HP\OneDrive\Documents\Default Project\tools\parse-out.txt" -Encoding ascii }
