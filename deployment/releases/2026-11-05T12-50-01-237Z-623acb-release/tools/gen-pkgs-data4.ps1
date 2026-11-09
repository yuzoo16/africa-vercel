# gen-pkgs-data4.ps1 — Kenya 12-day grand. Pure ASCII.
. "$PSScriptRoot/gen-pkgs.ps1"
$P=@()
$P+=@{dir="kenya-safari-from-nairobi";slug="12-day-kenya-from-nairobi";title="12-Day Kenya Grand Safari + Diani Beach";h1="12-day Kenya grand safari + Diani";tag="Samburu, Amboseli, lakes, four Mara nights, then Diani sand - Kenya entire.";country="Kenya";days=12;styles="classic,beach";parks="Samburu|Amboseli|Lake Naivasha|Masai Mara|Diani Beach";angle="ke-nairobi";mult=1.1;flat=300;mode="safari";cousins="/kenya-safari-from-nairobi/10-day-kenya-from-nairobi/|10-Day Grand;/kenya-safari/10-day-kenya-safari-beach/|10-Day + Beach"}
foreach($r in $P){ New-Package $r }
"kenya12: $($P.Count)"
$all = @()
if(Test-Path "data/packages.json"){ try{ $prev = Get-Content "data/packages.json" -Raw | ConvertFrom-Json; $all = @($prev) }catch{} }
foreach($r in $DB){ $all += $r }
$all | ConvertTo-Json -Depth 6 | Out-File -FilePath "data/packages.json" -Encoding utf8
"packages.json records: $($all.Count)"
