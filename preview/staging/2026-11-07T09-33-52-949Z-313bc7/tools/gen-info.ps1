# gen-info.ps1 - Tanzania month-migration pages + great-migration-safari alias.
. "$PSScriptRoot/gen-common.ps1"
$months = @(
 @("january-migration-safari","January Migration Safari: Ndutu Calving Begins","Late January opens calving season: herds mass on Ndutu's short-grass plains, first calves drop, predators shadow every birth. Fewer vehicles, green light, superb photography. Camp Ndutu area; combine with central Serengeti cats."),
 @("february-migration-safari","February Migration Safari: Peak Calving","Peak calving - around 8,000 wildebeest calves daily on the southern plains. Lions, cheetahs and hyenas hunt in daylight; balloon flights drift over newborn herds. The single best wildlife-value month in Tanzania."),
 @("march-migration-safari","March Migration Safari: Calving Tail & Green Season","Calving tails off as herds fatten calves and drift toward Moru and Seronera. Lush landscapes, migratory birds, lowest crowds and rates of the calving window. Excellent for photographers who hate vehicles."),
 @("june-migration-safari","June Migration Safari: Grumeti Crossings","The herds hit the Grumeti River: dramatic crossings with a fraction of Mara-season vehicles. Western corridor camps position best; combine with central Seronera en route north."),
 @("july-migration-safari","July Migration Safari: Herds Reach the North","Herds pour into the northern Serengeti and first Mara crossings begin. Kogatende camps fill fast - book early. Combine with central Serengeti for cats between river waits."),
 @("august-migration-safari","August Migration Safari: Peak Mara Crossings","Peak crossing drama at the Mara River: herds bunch for days then cross in minutes. Three-plus nights near Kogatende with picnic lunches; patience is the entire strategy."),
 @("september-migration-safari","September Migration Safari: Mara Masses","Herds mass in the north and Mara with continued crossings. Slightly fewer visitors than August, same spectacle. Ideal month for a two-zone trip: Mara River plus central cats."),
 @("october-migration-safari","October Migration Safari: Herds Turn South","Short rains push herds south through Seronera toward Ndutu; last Mara stragglers early in the month. A superb transition month - resident game plus trailing herds, lower rates."))
foreach($m in $months){
  $slug=$m[0]; $title=$m[1]; $d=$m[2]
  $h1=$title.Split(":")[0]
  $body=Crumb @('<a href="/">Home</a>','<a href="/tanzania-migration-safari/">Tanzania Migration Safari</a>',$h1)
  $body+="<section class=`"block`"><div class=`"wrap`"><p class=`"eyebrow`">Tanzania Migration by month</p><h1>$h1</h1><p class=`"lead`">$d</p>"
  $body+="<h2>Safaris in this window</h2><p><a href=`"/tanzania-migration-safari/7-day-migration-safari/`">7-Day Migration Safari</a> | <a href=`"/tanzania-migration-safari/5-day-migration-safari/`">5-Day Migration</a> | <a href=`"/great-migration/month-by-month/`">Full month-by-month calendar</a></p>"
  $body+=(CTA-Band "Be with the herds this month" "Camp availability checked first." $title)+"</div></section></main>"
  $canon="https://www.adventuresafariafrica.com/tanzania-migration-safari/$slug/"
  $html=Shell $title "$d" $canon $body ""
  New-Item -ItemType Directory -Path "tanzania-migration-safari/$slug" -Force | Out-Null
  $html | Out-File -FilePath "tanzania-migration-safari/$slug/index.html" -Encoding utf8
  "month: $slug"
}
$alias = Shell "Great Migration Safari: Serengeti & Mara" "Great Migration safaris - see the Tanzania Migration hub for season-placed itineraries." "https://www.adventuresafariafrica.com/tanzania-migration-safari/" ('<main id="main"><section class="block"><div class="wrap"><h1>Great Migration Safari</h1><p class="lead">Our Migration itineraries live in the <a href="/tanzania-migration-safari/">Tanzania Migration Safari hub</a> (also see the <a href="/great-migration/">Great Migration guide hub</a>).</p></div></section></main>') ""
New-Item -ItemType Directory -Path "great-migration-safari" -Force | Out-Null
$alias | Out-File -FilePath "great-migration-safari/index.html" -Encoding utf8
"alias done"
