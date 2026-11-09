# pad9.ps1 — pad 1-8 FAQ pages to 9 + rebuild FAQ schema from visible FAQs. ASCII.
. "$PSScriptRoot/gen-common.ps1"
$skip = @("cookies","privacy","terms","search","404","safari-quiz","success-calculator","great-migration-safari","blog/category")
$files = Get-ChildItem -Recurse -Filter *.html | Where-Object {
  $p=$_.FullName; $k=$true
  foreach($s in $skip){ if($p -like "*\$s*" -or $p -like "*\$s.html"){ $k=$false; break } }
  $k -and ($p -notlike "*\it\*" -and $p -notlike "*\fr\*" -and $p -notlike "*\de\*" -and $p -notlike "*\es\*")
}
$n=0
foreach ($f in $files) {
  $t=[IO.File]::ReadAllText($f.FullName)
  if($t -notmatch '<div class="faq">'){ continue }
  $cur=([regex]::Matches($t,"<details[ >]").Count)
  if($cur -eq 0 -or $cur -ge 9){ continue }
  $need=9-$cur
  $add=Faq-Pick ($f.Name.Length*19+$cur) $need
  $html=""
  foreach($a in $add){ $html+="<details><summary>"+$a.q+"</summary><p>"+$a.a+"</p></details>" }
  $t=$t -replace '(</details>\s*</div>\s*)(<h2>Related|<div class="cta-band")', ('</details>'+$html+'</div>$2')
  if($t -notmatch [regex]::Escape($html.Substring(0,40))){
    $t=$t -replace '(</details>\s*</div>)', ('</details>'+$html+'</div>')
  }
  $faqs=@()
  foreach($m in [regex]::Matches($t,'<details[^>]*><summary>(.*?)</summary>([\s\S]*?)</details>')){
    $q=$m.Groups[1].Value -replace "<[^>]+>",""
    $a=$m.Groups[2].Value -replace "<[^>]+>"," " -replace "\s+"," "
    $faqs+=@{"q"=$q.Trim();"a"=$a.Trim()}
  }
  $t=$t -replace '(<script type="application/ld\+json">\{"@context":"https://schema.org","@type":"FAQPage"[^<]*</script>)', ''
  $t=$t -replace '</body>', ((Faq-Schema $faqs)+'</body>')
  [IO.File]::WriteAllText($f.FullName,$t)
  $n++
}
"padded pages: $n"
