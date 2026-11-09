# gen-pkgs-data3.ps1 — group packages. Pure ASCII.
. "$PSScriptRoot/gen-pkgs.ps1"
$P=@()
$P+=@{dir="tanzania-group-safari";slug="7-day-tanzania-group";title="7-Day Tanzania Group Safari (Max 7)";h1="7-day Tanzania group safari";tag="The full northern circuit shared: Tarangire, crater, three Serengeti nights.";country="Tanzania";days=7;styles="group,classic";parks="Tarangire|Ngorongoro Crater|Central Serengeti|Northern Serengeti";angle="group";mult=0.85;flat=0;mode="safari";cousins="/tanzania-group-safari/5-day-tanzania-group/|5-Day Group;/tanzania-safari/7-day-tanzania-safari/|7-Day Private"}
$P+=@{dir="tanzania-group-safari";slug="5-day-tanzania-group";title="5-Day Tanzania Group Safari (Max 7)";h1="5-day Tanzania group safari";tag="Essential parks shared: Tarangire, crater and two Serengeti nights.";country="Tanzania";days=5;styles="group,classic";parks="Tarangire|Ngorongoro Crater|Central Serengeti";angle="group";mult=0.85;flat=0;mode="safari";cousins="/tanzania-group-safari/7-day-tanzania-group/|7-Day Group;/tanzania-safari/5-day-tanzania-safari/|5-Day Private"}
foreach($r in $P){ New-Package $r }
"group packages: $($P.Count)"
$all = @()
if(Test-Path "data/packages.json"){ try{ $prev = Get-Content "data/packages.json" -Raw | ConvertFrom-Json; $all = @($prev) }catch{} }
foreach($r in $DB){ $all += $r }
$all | ConvertTo-Json -Depth 6 | Out-File -FilePath "data/packages.json" -Encoding utf8
"packages.json records: $($all.Count)"
