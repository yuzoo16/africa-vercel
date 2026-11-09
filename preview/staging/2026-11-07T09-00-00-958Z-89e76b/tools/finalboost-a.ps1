# finalboost-a.ps1 — migration/kili subs, month pages, hub cross-links. ASCII.
. "$PSScriptRoot/gen-common.ps1"
function Add-Faqs($file,$faqs){
  $t=[IO.File]::ReadAllText($file)
  if($t -match '<div class="faq">'){ "skip: $file"; return }
  $sec=Faq-List $faqs
  $sch=Faq-Schema $faqs
  $anchor="</div></section></main>"
  if($t.Contains($anchor)){ $t=$t.Replace($anchor, $sec+"</div></section></main>") }
  $t=$t -replace '</body>', ($sch+'</body>')
  [IO.File]::WriteAllText($file,$t)
  "faqs: $file"
}
function Add-Links($file,$linksHtml){
  $t=[IO.File]::ReadAllText($file)
  if($t.Contains($linksHtml.Substring(0,40))){ "skip-links: $file"; return }
  $anchor="</div></section></main>"
  if($t.Contains($anchor)){ $t=$t.Replace($anchor, "<h2>Keep exploring</h2><p>"+$linksHtml+"</p></div></section></main>") }
  [IO.File]::WriteAllText($file,$t)
  "links: $file"
}
$P6=Faq-Pick 31 6
Add-Faqs "great-migration/month-by-month/index.html" (@(@{"q"="How accurate are herd predictions?";"a"="Broadly reliable by zone and month, never exact by day: rain shifts everything by weeks. Two-zone itineraries insure against timing misses."},@{"q"="Which month has fewest crowds?";"a"="March to May and November: green season emptiness with calving tail or returning herds. Crossings months draw the most vehicles."},@{"q"="Can we see Migration outside Jul-Oct?";"a"="Yes in Tanzania: calving Jan-Mar, Grumeti Jun, southern herds Nov-Dec. Only the Mara River spectacle is Jul-Oct."})+$P6)
Add-Faqs "great-migration/mara-river-crossing/index.html" (@(@{"q"="How long do crossings last?";"a"="Minutes of chaos after hours or days of bunching. Full-day picnic waits with radio-network guides maximize odds."},@{"q"="Grumeti or Mara river?";"a"="Mara for scale and frequency in season; Grumeti for exclusivity. Both kill - crocodiles take a toll every season."},@{"q"="Best viewing points?";"a"="Kogatende crossings 1-8 in the north; Paradise and Lookout in the Mara. Guides rotate by recent activity, not habit."})+$P6)
Add-Faqs "great-migration/calving-season/index.html" (@(@{"q"="How many calves daily?";"a"="Around 8,000 wildebeest calves per day at the February peak on the Ndutu short-grass plains."},@{"q"="Is calving good for first-timers?";"a"="Superb: constant predator action, fewer vehicles, lower rates, extraordinary light. Many guides rate it above crossings."},@{"q"="Where exactly?";"a"="Ndutu area straddling Serengeti and Ngorongoro Conservation Area, January to March. Mobile camps sit inside the herds."})+$P6)
Add-Faqs "great-migration/serengeti/index.html" (@(@{"q"="Which Serengeti zone for our month?";"a"="Ndutu Jan-Mar; Seronera year-round cats; Western Corridor Jun; Kogatende Jul-Oct. Zone beats luck every time."},@{"q"="How many Serengeti nights?";"a"="Three minimum across two zones. Single-base stays waste the park's scale."},@{"q"="Balloon over the herds?";"a"="Yes from central and northern strips in season - book at proposal stage, 550-600 dollars."})+$P6)
Add-Faqs "great-migration/masai-mara/index.html" (@(@{"q"="When do herds reach the Mara?";"a"="July typically, massing August-September, departing October. Resident cats and game carry shoulder months."},@{"q"="Reserve or conservancy for Migration?";"a"="Conservancies for off-road positioning away from crossing crowds; reserve for budget and sheer herd access."},@{"q"="How long in the Mara for crossings?";"a"="Four-plus nights in August-September. Crossings reward the patient and punish day-trippers."})+$P6)
Add-Faqs "great-migration/safari-packages/index.html" (@(@{"q"="Calving or crossing package?";"a"="Calving (Jan-Mar Ndutu) for action and value; crossings (Jul-Oct north/Mara) for peak drama. Grumeti (Jun) for exclusivity."},@{"q"="Kenya, Tanzania or both?";"a"="Tanzania holds herds longest; Kenya concentrates them; combos follow the border. Ten-plus days does both justice."},@{"q"="How far ahead to book?";"a"="Crossing-season camps 9-12 months; calving 6-9. Mobile Migration camps sell by position, not price."})+$P6)
Add-Faqs "kilimanjaro/best-time/index.html" (@(@{"q"="Which months are driest?";"a"="January-March and June-October. Shoulder rains (Apr-May, November) hit southern routes hardest; Rongai stays drier."},@{"q"="Full moon summits - worth it?";"a"="Summit crowds peak around full moon for lit night climbing. Book 4-6 months ahead for those weeks."},@{"q"="Christmas and New Year?";"a"="Popular, festive, busy - and short-rains gamble. Fine with flexible expectations."})+$P6)
Add-Faqs "kilimanjaro/cost/index.html" (@(@{"q"="Why do prices vary so much?";"a"="Park, conservation and camping fees exceed 1,000 dollars; crew wages, food, equipment and safety fill the rest. Below 2,500 dollars means cut corners."},@{"q"="What is typically excluded?";"a"="Gear rental, visas, tips (250-350 per climber weekly), hotels before/after. Demand written inclusions."},@{"q"="Are budget operators safe?";"a"="Price pressure lands on crew wages and safety kit first. Verify KPAP-standard wages and oxygen availability."})+$P6)
Add-Faqs "kilimanjaro/packing-list/index.html" (@(@{"q"="Rent or buy gear?";"a"="Rent bags, poles and duffels in Arusha; buy boots (broken in) and layers. Never debut boots on the mountain."},@{"q"="How cold really?";"a"="Minus 10 to minus 20C summit night with wind. Four layers, balaclava, chemical warmers."},@{"q"="Duffel weight limit?";"a"="15kg for porters, weighed at gates. Wear the heavy stuff; hotels store the rest."})+$P6)
Add-Faqs "kilimanjaro/umbwe-route/index.html" (@(@{"q"="Who should attempt Umbwe?";"a"="Very fit, pre-acclimatized climbers only - it is the steepest, fastest ascent with the lowest success rate."},@{"q"="Why does anyone choose it?";"a"="Speed and solitude: quietest trail, shortest itinerary. Pair with a Meru acclimatization climb first."},@{"q"="What is a safer alternative?";"a"="Seven-day Machame for similar character with survivable pacing, or Lemosho for the best odds."})+$P6)
Add-Faqs "kilimanjaro/northern-circuit/index.html" (@(@{"q"="Is 9 days worth it?";"a"="For the highest success and quietest camps, yes. Gentlest profile, full circumnavigation, premium cost."},@{"q"="Who books Northern Circuit?";"a"="Trekkers prioritizing odds and solitude over budget - often second attempts after a rushed failure elsewhere."},@{"q"="How remote is it?";"a"="The quietest side for days: northern slopes see a fraction of Machame traffic."})+$P6)
$MONTHS=@(
 @("january","January: herds mass on Ndutu plains; first calves drop late month. Predators shadow every birth."),
 @("february","February: peak calving - 8,000 calves daily. Unmatched predator action, few vehicles."),
 @("march","March: calving tail; herds fatten calves and drift toward Moru. Green value, fewer crowds."),
 @("june","June: herds hit the Grumeti River. Dramatic crossings, fraction of Mara crowds."),
 @("july","July: herds pour north; first Mara crossings late month. Kogatende camps fill fast."),
 @("august","August: peak Mara River drama. Three-plus nights with picnic lunches."),
 @("september","September: Mara masses continue; first herds turn south late month. Two-zone trips shine."),
 @("october","October: short rains push herds south via Seronera. Transition value, trailing herds."))
foreach($m in $MONTHS){
  $f="tanzania-migration-safari/"+$m[0]+"-migration-safari/index.html"
  if(-not (Test-Path $f)){ "missing-month: $f"; continue }
  Add-Faqs $f (@(@{"q"="Where are the herds this month?";"a"=$m[1]},@{"q"="How crowded is it?";"a"="Peak crossing and calving months draw most vehicles; shoulder weeks in this window offer the same herds with space."},@{"q"="What should we book?";"a"="A Migration-placed itinerary in this window: <a href=""/tanzania-migration-safari/7-day-migration-safari/"">7-day</a> or <a href=""/tanzania-migration-safari/5-day-migration-safari/"">5-day</a> formats, camp zone matched to the herds."})+(Faq-Pick ($m[0].Length*17) 3))
}
Add-Links "great-migration/index.html" '<a href="/great-migration/best-time/">Best time</a> | <a href="/great-migration/grumeti-crossing/">Grumeti crossings</a> | <a href="/great-migration-safari/">Migration safaris</a> | <a href="/africa-migration-safaris/">Africa Migration hub</a>'
Add-Links "kilimanjaro/index.html" '<a href="/kilimanjaro/how-long/">How long</a> | <a href="/kilimanjaro/trekking/">Trekking overview</a> | <a href="/kilimanjaro/success-calculator/">Success estimator</a> | <a href="/kilimanjaro/umbwe-route/">Umbwe</a> | <a href="/kilimanjaro/northern-circuit/">Northern Circuit</a>'
Add-Links "activities/index.html" '<a href="/activities/kilimanjaro-trekking/">Kilimanjaro trekking activity</a> | <a href="/kilimanjaro/">Kilimanjaro hub</a>'
Add-Links "travel-guide/index.html" '<a href="/travel-guide/luxury-safari-guide/">Luxury guide</a> | <a href="/travel-guide/solo-safari/">Solo guide</a>'
$mm="tanzania-migration-safari/month-by-month/index.html"
if(Test-Path "great-migration/month-by-month/index.html"){
  $ml=""
  foreach($m in $MONTHS){ $ml+='<a href="/tanzania-migration-safari/'+$m[0]+'-migration-safari/">'+$m[0]+'</a> | ' }
  Add-Links "great-migration/month-by-month/index.html" ($ml+'<a href="/tanzania-migration-safari/">Migration safari hub</a>')
  Add-Links "tanzania-migration-safari/index.html" ($ml+'<a href="/great-migration/month-by-month/">Full calendar</a>')
}
"finalboost-a done"
