# serve.ps1 — zero-dependency static server (HttpListener). Run: powershell -File tools/serve.ps1
$root = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
$port = 8080
$types = @{}
$types[".html"] = "text/html; charset=utf-8"; $types[".css"] = "text/css"
$types[".js"] = "application/javascript"; $types[".json"] = "application/json"
$types[".xml"] = "application/xml"; $types[".txt"] = "text/plain"
$types[".svg"] = "image/svg+xml"; $types[".png"] = "image/png"
$types[".jpg"] = "image/jpeg"; $types[".jpeg"] = "image/jpeg"
$types[".webp"] = "image/webp"; $types[".ico"] = "image/x-icon"
$log = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "server.log"
"starting, root=$root" | Out-File $log -Encoding ascii
try {
$l = New-Object Net.HttpListener
$l.Prefixes.Add("http://localhost:$port/")
$l.Start()
} catch {
  ("START-FAILED: " + $_.Exception.Message) | Out-File $log -Append -Encoding ascii
  Write-Output ("START-FAILED: " + $_.Exception.Message)
  Write-Output "Try: right-click LOCALHOST.bat -> Run as administrator (first run only)."
  pause
  exit 1
}
"listening on http://localhost:$port/" | Out-File $log -Append -Encoding ascii
Write-Output ""
Write-Output "  Adventure Safari Africa is live at:  http://localhost:$port/"
Write-Output "  Serving folder: $root"
Write-Output "  Close this window (or Ctrl+C) to stop the server."
Write-Output ""
while ($l.IsListening) {
  $ctx = $l.GetContext()
  try {
    $p = $ctx.Request.Url.LocalPath
    if ($p -match "\.\.") { $p = "/" }
    $rel = $p.TrimStart("/").Replace("/", "\")
    if ($rel -eq "") { $rel = "index.html" }
    $fs = Join-Path $root $rel
    if ((Test-Path $fs -PathType Container)) { $fs = Join-Path $fs "index.html" }
    if (-not (Test-Path $fs -PathType Leaf)) {
      $alt = Join-Path $root ($rel + ".html")
      if (Test-Path $alt -PathType Leaf) { $fs = $alt }
    }
    $res = $ctx.Response
    if (Test-Path $fs -PathType Leaf) {
      $ext = [IO.Path]::GetExtension($fs).ToLower()
      $ct = $types[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
      $bytes = [IO.File]::ReadAllBytes($fs)
      $res.ContentType = $ct; $res.ContentLength64 = $bytes.Length; $res.StatusCode = 200
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $nf = Join-Path $root "404.html"
      $bytes = [IO.File]::ReadAllBytes($nf)
      $res.ContentType = "text/html; charset=utf-8"; $res.ContentLength64 = $bytes.Length; $res.StatusCode = 404
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $res.OutputStream.Close()
    ("[{0}] {1} -> {2}" -f (Get-Date -Format "HH:mm:ss"), $p, $res.StatusCode) | Out-File $log -Append -Encoding ascii
  } catch { try { $ctx.Response.Close() } catch {} }
}
