# finalboost-b.ps1 — accommodation, guides, ngorongoro, ethiopia pkgs. ASCII.
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
$AP=Faq-Pick 41 4
$ACCS=@(
 @("accommodation/index.html"," stays across Africa",@(@{"q"="Lodge or tented camp?";"a"="Lodges for pools, family rooms and solid walls; tented camps for atmosphere, sounds and Migration mobility. Same game drives either way."},@{"q"="How much do safari stays cost?";"a"="Mid-range 200-350 dollars per night full-board; luxury 700-1,500 plus. Location beats thread count in Migration season."})),
 @("accommodation/tanzania/index.html","Tanzania",@(@{"q"="Where should we stay in the Serengeti?";"a"="Inside the herd zone of your month: Ndutu Jan-Mar, central year-round, north Jul-Oct. Mobile camps move with herds; lodges anchor the center."},@{"q"="Crater rim or Karatu?";"a"="Rim lodges for gate-open descents; Karatu for value with a 30-minute earlier start. Honeymoons choose rim."})),
 @("accommodation/kenya/index.html","Kenya",@(@{"q"="Reserve or conservancy camps?";"a"="Reserve camps cost less with more vehicles; conservancies (Mara North, Naboisho) buy off-road, night drives and empty sightings."},@{"q"="Where to stay in Amboseli?";"a"="Lodges facing Kilimanjaro for dawn views; swamp-side camps for elephant proximity. Two nights suffices."})),
 @("accommodation/uganda/index.html","Uganda",@(@{"q"="Where to stay for gorillas?";"a"="At your allocated trailhead sector: Buhoma, Ruhija, Rushaga or Nkuringo. Cross-sector transfers waste trek mornings."},@{"q"="Forest lodge tiers?";"a"="Mid-range forest lodges to Clouds Mountain suites. The gorilla hour is identical at every budget."})),
 @("accommodation/botswana/index.html","Botswana",@(@{"q"="Water or land camp?";"a"="Water camps for mokoro and walks; land camps for predators and night drives. Both if budget allows."},@{"q"="How far ahead to book?";"a"="Delta water camps 9-12 months in flood season. Availability, not price, is the constraint."})),
 @("accommodation/namibia/index.html","Namibia",@(@{"q"="Dune lodges with gate access?";"a"="Yes and worth it: inside-gate lodges beat sunrise queues at Sossusvlei. Book early, few beds."},@{"q"="Etosha: inside or outside?";"a"="Inside waterhole camps (Okaukuejo floodlit hole) for nights; Ongava concession for luxury plus night drives."})),
 @("accommodation/south-africa/index.html","South Africa",@(@{"q"="Sabi Sand or Kruger rest camp?";"a"="Sabi suites for leopards, night drives and walks; rest camps for self-drive value. Many trips blend both."},@{"q"="Cape Town base?";"a"="V&A Waterfront for first-timers; Camps Bay for beach; winelands estates for food lovers. Three to four nights minimum."}))
)
foreach($a in $ACCS){ Add-Faqs $a[0] ($a[2]+$AP) }
Add-Faqs "travel-guide/best-time-for-african-safari/index.html" (@(@{"q"="If we can travel only one month, which?";"a"="August for peak Migration drama plus dry-season game viewing everywhere. February for calving action and value. Both need early booking."},@{"q"="Is green season actually good?";"a"="Yes: babies, birds, dramatic skies, empty sightings, 20-35 percent lower rates. Only April-May long rains genuinely limit."},@{"q"="How do school holidays align?";"a"="June-August and December-January match dry and calving seasons well. Book family rooms 9-12 months ahead."})+(Faq-Pick 77 6))
Add-Faqs "travel-guide/safari-safety/index.html" (@(@{"q"="What is the biggest real risk?";"a"="Road transfers statistically, then malaria - both managed by professional drivers, prophylaxis and evacuation cover. Animal incidents follow rule-breaking."},@{"q"="Is walking safe?";"a"="With armed professional guides, yes: briefings, wind awareness, single-file discipline. Never walk unguided in wildlife areas."},@{"q"="Solo female travel?";"a"="Guided safaris are among the safest solo travel: door-to-door handling, camp staff presence, communal dinners. Cities need standard sense."})+(Faq-Pick 78 6))
Add-Faqs "travel-guide/what-to-pack-for-safari/index.html" (@(@{"q"="Hard case or duffel?";"a"="Both: hard case for international, lodges store it free; 15-20kg soft duffel for bush-flight sectors."},@{"q"="Do we need safari shops?";"a"="No - high-street synthetics in khaki/olive work. Spend on boots and binoculars instead."},@{"q"="Laundry reality?";"a"="Overnight return almost everywhere. Pack 3-4 days of clothes for any trip length."})+(Faq-Pick 79 6))
Add-Faqs "national-parks/ngorongoro/index.html" (@(@{"q"="How long on the crater floor?";"a"="A full day: descend at 6am gate-open, picnic at the hippo pool, ascend by 4pm. Mornings belong to predators before minibuses arrive."},@{"q"="Will we see rhino?";"a"="Black rhino graze the open floor most mornings - the crater is Tanzania's most reliable rhino viewing."},@{"q"="Crater plus Serengeti in one trip?";"a"="Always paired: the crater is a day, the Serengeti needs three nights. Every northern itinerary links them."})+(Faq-Pick 80 6))
Add-Faqs "national-parks/savanna-parks/index.html" (@(@{"q"="Which park for first-timers?";"a"="Serengeti or Mara for density; Kruger for ease; Etosha for simplicity. Match park to travel month first."},@{"q"="How many parks per trip?";"a"="Two to three with two-night stays. Transit days cost wildlife days."})+(Faq-Pick 81 6))
"finalboost-b done"
