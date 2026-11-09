# diag.ps1 — tests HttpListener on localhost:8080, writes result to diag-out.txt
$out = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "diag-out.txt"
try {
  $l = New-Object Net.HttpListener
  $l.Prefixes.Add("http://localhost:8080/")
  $l.Start()
  "LISTEN-OK" | Out-File $out -Encoding ascii
  $l.Stop()
} catch {
  ("FAIL: " + $_.Exception.Message) | Out-File $out -Encoding ascii
}
