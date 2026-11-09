# faqboost2.ps1 — FAQs for subs/hubs + style rewrites. Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"
function Add-Faqs($file,$faqs,$afterH2){
  $t=[IO.File]::ReadAllText($file)
  if($t -match '<div class="faq">'){ "skip-faq-exists: $file"; return }
  $sec=Faq-List $faqs
  $sch=Faq-Schema $faqs
  $anchor="</div></section></main>"
  if($t.Contains($anchor)){ $t=$t.Replace($anchor, $sec+"</div></section></main>") }
  $t=$t -replace '</body>', ($sch+'</body>')
  [IO.File]::WriteAllText($file,$t)
  "faqs-added: $file ($($faqs.Count))"
}
$POOL6=Faq-Pick 11 6
Add-Faqs "great-migration/best-time/index.html" (@(@{"q"="Which single month suits a first Migration trip?";"a"="August: peak Mara crossings, dry-season game viewing, all camps open. Book Kogatende and Mara lodges 9-12 months ahead."},@{"q"="Is there a bad month for the Migration?";"a"="April-May long rains challenge roads, not wildlife - herds still move and rates crater. November short rains rarely disrupt trips."},@{"q"="How do we time both calving and crossings?";"a"="You cannot in one short trip - they are opposite seasons. Ten-plus-day February-to... no: choose one spectacle, or book two trips."})+$POOL6) ""
Add-Faqs "great-migration/grumeti-crossing/index.html" (@(@{"q"="When do Grumeti crossings happen?";"a"="June typically, as herds push through the Western Corridor. Remote west camps position best with few vehicles."},@{"q"="Grumeti or Mara crossings?";"a"="Grumeti for exclusivity and value; Mara for scale and peak drama. Photographers avoiding crowds choose Grumeti."},@{"q"="Which camps work?";"a"="Kirawira and remote western mobile camps. Central lodges sit 3-plus hours away - too far for dawn crossings."})+$POOL6) ""
Add-Faqs "kilimanjaro/how-long/index.html" (@(@{"q"="How many days on the mountain?";"a"="5 to 9 depending on route; 8 is the sweet spot for success. Add 2 buffer days plus safari after."},@{"q"="Why not rush it?";"a"="Altitude needs time, not fitness. Each extra acclimatization day measurably raises summit odds - days are the cheapest insurance."},@{"q"="Total trip length?";"a"="10-14 days door to door: 2 travel, 2 buffer, 5-9 climbing, 4-7 optional safari."})+$POOL6) ""
Add-Faqs "kilimanjaro/trekking/index.html" (@(@{"q"="Do we need technical skills?";"a"="No - Kilimanjaro is a trek, not a climb. Barranco Wall is the only scramble, guided throughout."},@{"q"="What fitness is required?";"a"="Hill-walking fitness: 4-6 hour days with a pack. Train stairs and hills 8-12 weeks out."},@{"q"="How cold is summit night?";"a"="Minus 10 to minus 20C with wind. Four-layer system,balaclava, and chemical hand warmers - see the packing list."})+$POOL6) ""
Add-Faqs "activities/index.html" (@(@{"q"="Which activities suit families?";"a"="Boat safaris, easy walks, cultural visits and balloon flights (age 7-plus). Walking safaris and treks carry age minimums."},@{"q"="What costs extra?";"a"="Balloon flights, night drives where not included, walking fees and hide sessions. Game drives are always included."},@{"q"="Can we mix activities?";"a"="Yes - drives plus boats plus walks plus culture is the classic rich week. Tell us interests and we place each where legal and best."})+$POOL6) ""
Add-Faqs "national-parks/index.html" (@(@{"q"="How many parks per trip?";"a"="Two to three with two-night stays beats four rushed. Transit days cost wildlife days."},@{"q"="Parks or private concessions?";"a"="Parks for icons and value; concessions for off-road, night drives and walking. Luxury trips blend both."},@{"q"="Which park for first-timers?";"a"="Serengeti or Mara for game density; Kruger for ease; Etosha for simplicity. Match park to month first."})+$POOL6) ""
Add-Faqs "travel-guide/index.html" (@(@{"q"="Where do first-time planners start?";"a"="Cost guide, best-time guide, then the safari quiz. Three steps replace weeks of forums."},@{"q"="How current is this information?";"a"="Maintained by planners booking these trips weekly - fees, seasons and logistics updated continuously."},@{"q"="Can we ask follow-ups?";"a"="Yes - every guide ends at a proposal form, WhatsApp and consultation. Real specialists answer."})+$POOL6) ""
Add-Faqs "blog/index.html" (@(@{"q"="Who writes these guides?";"a"="Our destination specialists - the same people who plan the trips. Updated seasonally, linked to real itineraries."},@{"q"="How do we use the blog to plan?";"a"="Start with comparisons and timing pieces, then follow internal links to hubs, parks and packages. Or take the quiz."})+$POOL6) ""
Add-Faqs "kilimanjaro/index.html" (@(@{"q"="Which route should beginners pick?";"a"="Eight-day Lemosho: best scenery, best success, moderate traffic. See route guides with day-by-day tabs."},@{"q"="How much does it really cost?";"a"="Quality climbs 2,800-5,500 dollars. Below 2,500 means cut crew wages or days - verify breakdowns."},@{"q"="Can we add safari after?";"a"="Yes - most climbers add 4-7 days. Legs recover on game drives."})+$POOL6) ""
Add-Faqs "great-migration/index.html" (@(@{"q"="Where are the herds right now?";"a"="Calving Ndutu Jan-Mar; west and Grumeti Apr-Jun; north and Mara Jul-Oct; returning south Nov-Dec. See month-by-month."},@{"q"="Are crossings guaranteed?";"a"="Never on a given day. Three-plus nights near the river converts odds to probability."},@{"q"="Tanzania or Kenya side?";"a"="Same herds: Tanzania holds them longer with more variety; Kenya concentrates them with easier logistics in season."})+$POOL6) ""
$STYLES=@(
 @("luxury","Luxury Safaris: Private Concessions, Flying and Suites","Off-road traversing, night drives, walking, fly-in camps and 1-to-4 staff ratios - plus which luxuries actually change sightings.","/tanzania-luxury-safari/7-day-luxury-serengeti/"),
 @("family","Family Safaris: Ages, Parks and Pacing","Malaria-free reserves, pools at every stop, private vehicles, walking and boating breaks - best ages 6-plus.","/tanzania-family-safari/6-day-tanzania-family/"),
 @("honeymoon","Honeymoon Safaris: Bush Dinners, Plunge Pools and Beach","Private concession suites, Migration or leopard backdrops, Zanzibar, Diani or island finishes.","/tanzania-honeymoon-safari/7-day-tanzania-honeymoon/"),
 @("private","Private Safaris: Your Vehicle, Guide and Pace","Own 4x4, own guide, own schedule on every itinerary - why it doubles sightings and halves stress.","/tanzania-safari/7-day-tanzania-safari/"),
 @("tailor-made","Tailor-Made Safaris: How Planning Works","Dates, budget, wildlife goals: one specialist, line-item quote in 24 hours, unlimited revisions.","/kenya-tanzania-safari/10-day-kenya-tanzania/")
)
foreach($s in $STYLES){
  $slug=$s[0]; $title=$s[1]; $lead=$s[2]; $ex=$s[3]
  $f="safaris/"+$slug+"/index.html"
  if(-not (Test-Path $f)){ $f="safaris/"+$slug+".html" }
  if(-not (Test-Path $f)){ "missing-style: $slug"; continue }
  $t=[IO.File]::ReadAllText($f)
  $body="<h2>What it means</h2><p class="+[char]34+"lead"+[char]34+">"+$lead+"</p>"
  $body+="<h2>Example itinerary</h2><p><a class="+[char]34+"btn btn-o"+[char]34+" href="+[char]34+$ex+[char]34+">View example safari</a> <a class="+[char]34+"btn btn-p"+[char]34+" href="+[char]34+"/request-proposal/"+[char]34+">Design mine</a></p>"
  $body+="<h2>Related hubs</h2><p><a href="+[char]34+"/africa-safaris/"+[char]34+">Africa safaris</a> | <a href="+[char]34+"/africa-safari-packages/"+[char]34+">All packages</a> | <a href="+[char]34+"/safari-quiz/"+[char]34+">Safari quiz</a></p>"
  $faqs=Faq-Pick ($slug.Length*13) 6
  $sec=$body+(Faq-List $faqs)
  $anchor="</div></section></main>"
  if($t.Contains($anchor)){ $t=$t.Replace($anchor, $sec+$anchor) }
  $t=$t -replace '</body>', ((Faq-Schema $faqs)+'</body>')
  [IO.File]::WriteAllText($f,$t)
  "style-boosted: $slug"
}
"faqboost2 done"
