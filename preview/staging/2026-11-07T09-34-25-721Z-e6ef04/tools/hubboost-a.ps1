# hubboost-a.ps1 — TZ/KE/UG hub depth: cards + planning + 9 FAQs. Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"
$DB = Get-Content "data/packages.json" -Raw | ConvertFrom-Json
function Money($n){ return "$" + ('{0:N0}' -f $n) }
function PCard($p){
  $u="/"+$p.slug+"/"; $ik=$p.imgkey; if(-not $ik){$ik="TZ"}
  $im=$IMG[$ik]; $thumb=$im[0] -replace "w=1800","w=800"
  $meta=$p.duration_days.ToString()+" days | "+$p.country
  return "<article class=`"card`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$thumb`" alt=`"$($p.name)`"><div class=`"pad`"><p class=`"meta`">$meta</p><h3><a href=`"$u`">$($p.name)</a></h3><p>$($p.excerpt)</p><p><span class=`"price`">From $(Money $p.price_from)</span></p><p><a class=`"btn btn-o btn-sm`" href=`"$u`">View safari</a> <a class=`"btn btn-p btn-sm`" href=`"/request-proposal/`">Customize</a> <a class=`"btn btn-wa btn-sm`" data-wa data-wa-pkg=`"$($p.name)`" href=`"#`">WhatsApp</a></p></div></article>"
}
function Boost-Hub($dir,$label,$parks,$plan,$faqs){
  $f = Join-Path $dir "index.html"
  $t = [IO.File]::ReadAllText($f)
  $pcards=""; foreach($p in ($DB | Where-Object { $_.country -eq $label })){ $pcards += PCard $p }
  $pgrid=""; foreach($pk in $parks){ $pgrid += Card-Dest $pk[1] $pk[0] $pk[2] $pk[3] }
  $sec="<h2>National parks of "+$label+"</h2><div class=`"grid g3`">$pgrid</div>"
  $sec+="<h2>All "+$label+" safari packages</h2><div class=`"grid g3`">$pcards</div>"
  $sec+="<h2>Planning essentials</h2><p>$plan</p>"
  $sec+=Faq-List $faqs
  $i1=$t.IndexOf('<div class="faq">'); $i2=$t.IndexOf('<div class="cta-band"')
  if($i1 -gt 0 -and $i2 -gt $i1){ $t=$t.Substring(0,$i1)+$sec+$t.Substring($i2) }
  $t=$t -replace '(<script type="application/ld\+json">\{"@context":"https://schema.org","@type":"FAQPage"[^<]*</script>)', ''
  $t=$t -replace '</body>', ((Faq-Schema $faqs)+'</body>')
  [IO.File]::WriteAllText($f,$t)
  "boosted: $dir faqs=$($faqs.Count)"
}
# ===== TANZANIA =====
Boost-Hub "tanzania-safari" "Tanzania" @(
 @("Serengeti","/national-parks/serengeti/","Migration heartland and big cats. 3-4 days.","TZ"),
 @("Ngorongoro Crater","/national-parks/ngorongoro/","Big Five in a day. Gate-open descents.","TZ"),
 @("Tarangire","/national-parks/tarangire/","Elephants and baobabs. 1-2 days.","TZ"),
 @("Lake Manyara","/national-parks/lake-manyara/","Tree lions and flamingos. Half-1 day.","TZ"),
 @("Ruaha","/national-parks/ruaha/","Wild south, dogs and prides. Fly-in.","TZ"),
 @("Nyerere","/national-parks/nyerere/","Boats, walks and wild dogs.","TZ")) "Mid-range private safaris run 350 to 600 dollars per person per day; park fees of 70 to 80 dollars daily are included in our quotes. Fly into Kilimanjaro (JRO) for the north or Dar es Salaam for the south; most travelers need 5 to 7 days for the northern circuit, 10-plus with Zanzibar. Start: <a href=""/tanzania-safari/packages/"">packages by duration</a> | <a href=""/tanzania-safari-from-zanzibar/"">from Zanzibar</a> | <a href=""/tanzania-migration-safari/"">Migration</a> | <a href=""/southern-tanzania-safari/"">southern circuit</a>." @(
 @{"q"="When is the best time for a Tanzania safari?";"a"="June to October for dry-season game viewing and Mara River crossings; January to March for Ndutu calving with peak predator action. November to December offers green-season value with few vehicles. April to May long rains can limit murram roads - we route around the worst of it or shift dates."},
 @{"q"="How many days do we need in Tanzania?";"a"="Five days covers the classic northern circuit; seven lets you position for the Migration properly; ten to twelve adds Zanzibar or the wild south. Four days works as a tight taste with one long transit day. Tell us your window and we build up, never squeeze in."},
 @{"q"="What does a Tanzania safari cost?";"a"="Mid-range private safaris typically cost 350 to 600 dollars per person per day; luxury 800 to 1,400 plus. Park and concession fees alone run 70 to 80 dollars daily. Our quotes line-item every fee so the total you compare is the total you pay."},
 @{"q"="Northern circuit or southern Tanzania?";"a"="North for Migration, crater icons and infrastructure; south (Ruaha, Nyerere) for wilderness, wild dogs and solitude at similar or lower nightly cost plus fly-in transfers. First-timers choose north; second-timers overwhelmingly choose south."},
 @{"q"="Should we start from Arusha or Zanzibar?";"a"="Arusha (via Kilimanjaro airport) for mainland-first itineraries; Zanzibar works when beach comes first - scheduled flights reach Mikumi and Nyerere in 30 minutes, the north in 80. Safari before beach remains the better order."},
 @{"q"="Is Tanzania good for family safaris?";"a"="Very from age six up: private vehicles, pools at most stops, and Tarangire-crater-Serengeti routing that avoids the longest transits. Under-fives face some lodge limits - ask for the honest property list."},
 @{"q"="How do we add Zanzibar?";"a"="Fly Serengeti or Arusha to Zanzibar (1-2 hours); three beach nights minimum, four to five ideal. Ten to twelve days total covers safari plus sand without rushing."},
 @{"q"="Where is the Migration in our month?";"a"="Ndutu and the south January to March; western corridor June; Kogatende and the Mara River July to October; returning south November to December. Camp zone matters more than luck - see the month-by-month calendar."},
 @{"q"="Visas, health and money practicalities?";"a"="Visa on arrival for most nationalities (50 dollars, US 100); yellow fever certificate if arriving from endemic zones; malaria prophylaxis per your doctor. ATMs in Arusha dispense shillings; lodges accept cards and dollars."})
# ===== KENYA =====
Boost-Hub "kenya-safari" "Kenya" @(
 @("Masai Mara","/national-parks/masai-mara/","Big cats and crossings. 3-4 days.","KE"),
 @("Amboseli","/national-parks/amboseli/","Tuskers and Kilimanjaro views. 2 days.","KE"),
 @("Samburu","/national-parks/samburu/","Special Five northern species. 2-3 days.","KE"),
 @("Naivasha and Nakuru","/national-parks/lake-naivasha/","Rhinos, boats and walks. 1-2 days.","KE")) "Mid-range private loops run 350 to 600 dollars per person per day. Apply for the eTA online before travel; fly into Nairobi (NBO), safari from Wilson Airport strips or road loops. Five to seven days covers Amboseli, lakes and Mara; ten with Samburu or Diani. Start: <a href=""/kenya-safari/packages/"">packages</a> | <a href=""/kenya-safari-from-nairobi/"">from Nairobi</a> | <a href=""/masai-mara-safari/"">Mara only</a> | <a href=""/kenya-tanzania-safari/"">Kenya plus Tanzania</a>." @(
 @{"q"="When is the best time for a Kenya safari?";"a"="July to October for Mara crossings and dry-season viewing; January to March for resident cats, clear Kilimanjaro views and lower rates. April to May long rains are the one window to avoid or discount-hunt."},
 @{"q"="Masai Mara or Serengeti?";"a"="Same ecosystem, different staging: the Mara concentrates wildlife and crossings July to October in a compact area; the Serengeti holds herds ten months with calving and Grumeti exclusives. Read the full comparison, then choose by month."},
 @{"q"="How many days do we need in Kenya?";"a"="Three for the Mara alone (fly-in); five to seven for Amboseli, lakes and Mara; ten for Samburu or Diani beach. Three Mara nights minimum - cats and crossings reward patience."},
 @{"q"="Reserve or conservancy in the Mara?";"a"="The national reserve costs less with more vehicles at sightings; private conservancies (Mara North, Naboisho) limit beds and allow off-road, night drives and walking. Photographers and honeymoons should choose conservancy."},
 @{"q"="Is Amboseli worth two days?";"a"="Yes for elephant lovers and photographers: 400-plus elephants including great tuskers, with Kilimanjaro clearest at dawn January to March. Pairs perfectly before the Mara."},
 @{"q"="How do Nairobi logistics work?";"a"="International arrivals at Jomo Kenyatta; safaris depart from Wilson Airport (45-minute Mara hop) or by road. Overnight in Nairobi on arrival day; the Sheldrick elephant orphanage fills layovers beautifully."},
 @{"q"="Is Kenya good for families?";"a"="Excellent: Naivasha boats and Crescent Island walks break up drive days, Mara fly-ins skip long roads, and lodges run strong kids programs. Under-fives do best with private vehicles and pool stops."},
 @{"q"="How do we add Diani Beach?";"a"="Fly Mara to Diani via Wilson/Ukunda - no Nairobi backtrack. Three beach nights minimum with Wasini dhow trips and Colobus walks. Seven safari days plus three beach is the formula."},
 @{"q"="What does a Kenya safari cost?";"a"="Mid-range private loops 350 to 600 dollars per person per day; Mara conservancy luxury 800-plus. Park and conservancy fees are included in our line-item quotes - always confirm this when comparing operators."})
# ===== UGANDA =====
Boost-Hub "uganda-safari" "Uganda" @(
 @("Bwindi","/national-parks/bwindi/","Mountain gorillas. Permits 800 dollars.","UG"),
 @("Kibale","/national-parks/kibale/","Chimpanzees, 98 percent success.","UG")) "Gorilla permits (800 dollars) lead all planning - we check availability before quoting lodges. Fly into Entebbe; three days covers a fly-in trek, seven adds chimps and savanna, ten-plus the full grand tour. Start: <a href=""/uganda-safari/packages/"">packages</a> | <a href=""/uganda-gorilla-trekking/"">gorilla trekking</a> | <a href=""/uganda-wildlife-safari/"">wildlife combos</a>." @(
 @{"q"="How much is a Uganda gorilla permit?";"a"="800 dollars per person, booked through Uganda Wildlife Authority allocation. Peak months (July-September, December-February) sell out 6 to 12 months ahead - send dates first, everything follows permits."},
 @{"q"="Uganda or Rwanda for gorillas?";"a"="Same species. Uganda permits cost 800 versus Rwanda's 1,500, and Uganda adds chimps plus savanna in one trip. Rwanda wins on transfer time (2.5 hours from Kigali) and luxury lodge depth."},
 @{"q"="How fit must we be for gorilla trekking?";"a"="Moderate fitness for 1 to 5 hours on steep, sometimes muddy slopes at 2,000-3,000m. Porters (20-30 dollars) carry your pack and steady you - take one. Train hill stairs 4 to 6 weeks out."},
 @{"q"="What is the minimum age?";"a"="Fifteen, strictly enforced for gorillas. Under-15s get chimpanzees (Kibale has no such limit in practice for older kids), savanna game drives and forest walks instead."},
 @{"q"="Should we add chimpanzees?";"a"="Yes - Kibale tracking runs 98-percent success at a fraction of a second gorilla permit, and chimps behave utterly differently: fast, noisy, arboreal. The primate double is Uganda's signature."},
 @{"q"="How many days does Uganda need?";"a"="Three for gorillas alone (fly-in); five for gorillas plus Queen Elizabeth lions; seven for chimps, lions and gorillas; ten-plus with Murchison Falls. Distances are long - fly-in legs save full days."},
 @{"q"="Road or fly between parks?";"a"="Road for scenery and cost (Entebbe-Kibale 5-6 hours); fly Bwindi-Entebbe legs on tight schedules. Hybrids work well: drive west, fly back."},
 @{"q"="Is Uganda safe for tourists?";"a"="Yes on standard circuits: parks are well managed, lodges established, guides professional. Follow the same big-city sense in Kampala as anywhere, and check current advisories for border regions."},
 @{"q"="When should we trek?";"a"="Dry June to September and December to February for firm trails. Wet months mean slippery slopes but real availability and green light - porters earn their fee either way."})
