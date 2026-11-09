# hubboost-b.ps1 — BW/NA/SA/ET hub depth. Pure ASCII.
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
  if($t -match "National parks of"){ "skip (already boosted): $dir"; return }
  if($parks.Count -gt 0 -and $parks[0] -is [string]){ $parks = ,$parks }
  $pcards=""; foreach($p in ($DB | Where-Object { $_.country -eq $label })){ $pcards += PCard $p }
  $pgrid=""; foreach($pk in $parks){ $pgrid += Card-Dest $pk[1] $pk[0] $pk[2] $pk[3] }
  $sec=""
  if($parks.Count -gt 0){ $sec="<h2>National parks of "+$label+"</h2><div class=`"grid g3`">$pgrid</div>" }
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
Boost-Hub "botswana-safari" "Botswana" @(
 @("Okavango Delta","/national-parks/okavango-delta/","Mokoro waterways. Flood peaks Jun-Aug.","BW"),
 @("Chobe","/national-parks/chobe/","Riverfront herds by boat. 2 days.","BW")) "Fly-in logistics price Botswana higher - and buy empty concessions in return. Fly into Maun or Kasane; five days tastes Delta plus Chobe, eight is the classic, ten-plus adds Falls or pans. Start: <a href=""/botswana-safari/packages/"">packages</a> | <a href=""/botswana-luxury-safari/"">luxury</a> | <a href=""/botswana-honeymoon-safari/"">honeymoon</a>." @(
 @{"q"="Why is Botswana more expensive?";"a"="Remoteness plus deliberate low-volume policy: camps fly in supplies and staff and pay high concession fees for huge private areas. Mobile tented safaris and Shinde-footprint camps moderate the bill without cutting wildlife."},
 @{"q"="When is the Delta flooded?";"a"="Angolan rains arrive May to August - peak water and mokoro season is June to September, even though local rains ended months earlier. Game viewing runs May to October throughout."},
 @{"q"="What is a mokoro safari?";"a"="A silent poled dugout canoe gliding reed channels past hippos and elephants, with walks on palm islands after. No engine, no rush - most travelers call it their trip highlight."},
 @{"q"="Chobe or Moremi for a short trip?";"a"="Chobe for riverfront herd masses by boat; Moremi and Khwai for predators, wild dogs and concession freedoms (off-road, night drives). Five-day trips pair Delta edge with Chobe."},
 @{"q"="How many days does Botswana need?";"a"="Five for Delta plus Chobe; eight for three camps across Delta, Moremi and Chobe; ten to twelve with Victoria Falls or Makgadikgadi pans."},
 @{"q"="Can we combine Victoria Falls?";"a"="Easily: Kasane to the Falls is a 90-minute transfer. Two nights covers the Falls walk, Zambezi sunset cruise and optional helicopter."},
 @{"q"="Is Botswana a family destination?";"a"="For older children, superb: mokoro safaris and walks (minimum ages usually 12-plus), family tents, and guides who mentor teens. Malaria prophylaxis required - discuss with your doctor early."},
 @{"q"="What about green season?";"a"="November to April brings the zebra migration to the Boteti and Makgadikgadi, dramatic skies, babies and lower rates - a connoisseur's season, not a compromise."},
 @{"q"="How do internal flights work?";"a"="Light aircraft hop camp to camp (20-40 minutes) with strict 20kg soft-bag limits. Seats are limited - camp availability, not price, is the constraint. Send dates first."})
Boost-Hub "namibia-safari" "Namibia" @(
 @("Etosha","/national-parks/etosha/","Waterhole theatre. 2-3 days dry season.","NA"),
 @("Sossusvlei","/national-parks/sossusvlei/","Red dunes and Deadvlei. 1-2 days.","NA")) "Excellent tar and graded-gravel roads make Namibia the great road journey. Fly into Windhoek; seven days covers dunes, coast and Damaraland, ten adds Etosha properly. Guided, self-drive or hybrid - we quote both honestly. Start: <a href=""/namibia-safari/packages/"">itineraries</a> | <a href=""/namibia-self-drive/"">self-drive</a> | <a href=""/namibia-luxury-safari/"">luxury</a>." @(
 @{"q"="Self-drive or guided in Namibia?";"a"="Guided for wildlife depth and zero logistics; self-drive for freedom and budget on excellent roads. First-timers often hybrid: guided Etosha plus self-drive south. We brief distances, fuel, tires and supply vetted 4x4s with two spares."},
 @{"q"="How many days does Namibia need?";"a"="Seven for Sossusvlei, Swakopmund and Damaraland; ten adding Etosha; twelve-plus with the Skeleton Coast fly-in. Daily distances look short on maps - gravel halves your speed."},
 @{"q"="When is Etosha best?";"a"="May to October dry season, when game crowds waterholes and floodlit night holes deliver black rhino. Wet months scatter herds but bring birds, babies and green desert color."},
 @{"q"="Is Sossusvlei worth the drive?";"a"="Unreservedly: Big Daddy at dawn, Deadvlei's white pan, Sesriem Canyon - and dune lodges with gate access beat the sunrise queues. One to two nights suffices."},
 @{"q"="How bad is malaria?";"a"="Low in the south and center, moderate in Etosha and the Caprivi in wet months. Lighter prophylaxis burden than East Africa - confirm with your doctor."},
 @{"q"="Is Namibia good for families?";"a"="Superb: short activity bursts, pools and guest farms, German-bakery towns for picky eaters, low malaria in the south. Kids rate the dunes, seals and waterholes above almost any Big Five park."},
 @{"q"="What is desert rhino tracking?";"a"="On-foot tracking of desert-adapted black rhino with Save the Rhino community trackers in Damaraland - wild, ethical and unforgettable. Moderate fitness, minimum ages apply."},
 @{"q"="Skeleton Coast: day or overnight?";"a"="Fly-in day from Swakopmund covers shipwrecks and seal colonies; overnight adds remoteness and light. Budget two days with the flight for the full effect."},
 @{"q"="What does Namibia cost?";"a"="Guided loops from about 430 dollars per day mid-range; briefed self-drives from about 300. Dune lodges and Skeleton flights set the ceiling, not the floor."})
Boost-Hub "south-africa-safari" "South Africa" @(
 @("Kruger and Sabi Sand","/national-parks/kruger/","Leopards and Big Five. 3-5 days.","SA")) "No other safari country pairs Big Five viewing with a world-class city, winelands and coastal road trip. Fly into Johannesburg for bush or Cape Town for city-first routing; five days covers Kruger, nine adds the Cape, twelve the Garden Route. Start: <a href=""/south-africa-safari/packages/"">packages</a> | <a href=""/south-africa-luxury-safari/"">luxury</a> | <a href=""/south-africa-family-safari/"">family</a>." @(
 @{"q"="Kruger self-drive or private lodge?";"a"="Self-drive Kruger is cheap and fun on excellent roads; Sabi Sand and Timbavati concessions cost more but deliver off-road leopard sightings, night drives and walks you cannot get in the public park. We quote both - many trips blend them."},
 @{"q"="Where is malaria-free?";"a"="Madikwe, Pilanesberg and Eastern Cape reserves are considered malaria-free - ideal for under-fives and pregnancy travel. Kruger carries low-to-moderate risk; prophylaxis advised."},
 @{"q"="When should we go?";"a"="May to September dry winter for game viewing (freezing dawns, pack thermals); November to March for Cape Town beaches, winelands and whale season overlap. Shoulder months balance both."},
 @{"q"="How many days?";"a"="Five for Kruger alone; nine for Cape, winelands and Kruger; twelve adding the Garden Route. Cape Town deserves three to four nights minimum."},
 @{"q"="Sabi Sand or Timbavati?";"a"="Sabi Sand for peak leopard density and lodge pedigree; Timbavati for value with full traversing rights. Both allow the off-road, night and walking privileges that define luxury here."},
 @{"q"="Is South Africa safe for tourists?";"a"="On standard tourist circuits with normal precautions, yes: door-to-door transfers, vetted lodges, guides all day. Cities need big-city sense - we brief every arrival and route around no-go areas."},
 @{"q"="What does it cost?";"a"="Strong value against dollar, euro and pound: mid-range bush-city combos from about 550 dollars per day; Sabi Sand suites push higher. Self-drive Kruger undercuts everything."},
 @{"q"="Best family setup?";"a"="Malaria-free Madikwe or Eastern Cape lodges with cubs clubs and interconnecting suites, plus Cape Town penguins and beaches. The easiest family safari on earth."},
 @{"q"="Can we add an island?";"a"="Mauritius for ease and value, Seychelles for splurge - both one direct flight from Johannesburg. Honeymooners routinely finish offshore."})
Boost-Hub "ethiopia-safari" "Ethiopia" @() "Ethiopia is culture-plus-endemics, not Big Five: geladas, walia ibex and Ethiopian wolves with rock churches and living cultures. Fly into Addis Ababa; October to March dry season; eight days for the historic north plus Simien, twelve-plus with Omo. Start: <a href=""/ethiopia-safari/packages/"">tours</a>." @(
 @{"q"="Is Ethiopia safe right now?";"a"="Conditions vary by region and year - we monitor advisories route by route and only operate where local partners confirm safe passage. Ask about your specific dates and we give a straight answer, including when to wait."},
 @{"q"="Historic north or Omo Valley?";"a"="North (Lalibela, Gondar, Simien) for culture plus light trekking; Omo for respectful, well-briefed cultural travel with community-origin guides; Danakil for the hardy. Twelve days combines north and Omo by air."},
 @{"q"="How hard is Simien trekking?";"a"="Moderate: 3,200 to 4,400m altitude, 4 to 6 hours daily. Mules carry gear, one acclimatisation day suffices for most hill-fit travelers. Geladas and lammergeiers reward every step."},
 @{"q"="When should we go?";"a"="October to March dry season. Timkat (January 19) and Meskel (September 27) festivals are worth planning entire trips around - book festival lodging early."},
 @{"q"="What wildlife will we see?";"a"="Endemics: gelada troops, walia ibex, Ethiopian wolf (rarest canid on earth), mountain nyala in Bale. Set expectations on highland species, not savanna herds."},
 @{"q"="How many days?";"a"="Eight for Lalibela, Gondar and Simien; seven for the Omo loop; twelve for both; fourteen adding Danakil or Bale."},
 @{"q"="Is the altitude a problem?";"a"="Addis sits at 2,400m; Simien camps reach 3,600m-plus. Most travelers acclimatise with one easy day. Heart or respiratory conditions: consult your doctor first."},
 @{"q"="How do Omo visits stay respectful?";"a"="Community-origin guides, small groups, asked-not-staged photography with agreed fees, market-day timing. We brief protocols before every village visit and cap group sizes."},
 @{"q"="Can Ethiopia combine with safari elsewhere?";"a"="Yes via Addis hub links: Simien plus Serengeti, or Omo plus Uganda primates. Ask for multi-country routings."})
