# hubfaq-fix.ps1 — re-insert 9 FAQs into BW/NA/SA/ET hubs. Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"
function Add-Faqs($file,$faqs){
  $t=[IO.File]::ReadAllText($file)
  if($t -match '<div class="faq">'){ "skip-has-faq: $file"; return }
  $sec=Faq-List $faqs
  $sch=Faq-Schema $faqs
  $anchor='<div class="cta-band"'
  $i=$t.IndexOf($anchor)
  if($i -gt 0){ $t=$t.Substring(0,$i)+$sec+$t.Substring($i) }
  $t=$t -replace '</body>', ($sch+'</body>')
  [IO.File]::WriteAllText($file,$t)
  "faq-fixed: $file"
}
Add-Faqs "botswana-safari/index.html" @(
 @{"q"="Why is Botswana more expensive?";"a"="Remoteness plus deliberate low-volume policy: camps fly in supplies and staff and pay high concession fees for huge private areas. Mobile tented safaris moderate the bill without cutting wildlife."},
 @{"q"="When is the Delta flooded?";"a"="Angolan rains arrive May to August - peak water and mokoro season is June to September, even though local rains ended months earlier."},
 @{"q"="What is a mokoro safari?";"a"="A silent poled dugout canoe gliding reed channels past hippos and elephants, with walks on palm islands after. No engine, no rush."},
 @{"q"="Chobe or Moremi for a short trip?";"a"="Chobe for riverfront herd masses by boat; Moremi and Khwai for predators, wild dogs and concession freedoms."},
 @{"q"="How many days does Botswana need?";"a"="Five for Delta plus Chobe; eight for three camps; ten to twelve with Victoria Falls or Makgadikgadi pans."},
 @{"q"="Can we combine Victoria Falls?";"a"="Easily: Kasane to the Falls is a 90-minute transfer. Two nights covers the Falls walk, sunset cruise and optional helicopter."},
 @{"q"="Is Botswana a family destination?";"a"="For older children, superb: mokoro safaris and walks (minimum ages usually 12-plus). Malaria prophylaxis required."},
 @{"q"="What about green season?";"a"="November to April brings the zebra migration, dramatic skies and lower rates - a connoisseur's season."},
 @{"q"="How do internal flights work?";"a"="Light aircraft hop camp to camp with strict 20kg soft-bag limits. Camp availability, not price, is the constraint."})
Add-Faqs "namibia-safari/index.html" @(
 @{"q"="Self-drive or guided in Namibia?";"a"="Guided for wildlife depth and zero logistics; self-drive for freedom and budget on excellent roads. Hybrids work well."},
 @{"q"="How many days does Namibia need?";"a"="Seven for dunes, coast and Damaraland; ten adding Etosha; twelve-plus with the Skeleton Coast fly-in."},
 @{"q"="When is Etosha best?";"a"="May to October dry season for waterhole concentrations and floodlit night holes. Wet months bring birds and babies."},
 @{"q"="Is Sossusvlei worth the drive?";"a"="Unreservedly: Big Daddy at dawn, Deadvlei, Sesriem Canyon. Dune lodges with gate access beat the sunrise queues."},
 @{"q"="How bad is malaria?";"a"="Low in the south and center, moderate in Etosha and Caprivi in wet months. Lighter burden than East Africa."},
 @{"q"="Is Namibia good for families?";"a"="Superb: short activity bursts, guest farms, low malaria in the south. Kids rate dunes, seals and waterholes above almost any Big Five park."},
 @{"q"="What is desert rhino tracking?";"a"="On-foot tracking of desert-adapted black rhino with Save the Rhino community trackers - wild, ethical, unforgettable."},
 @{"q"="Skeleton Coast: day or overnight?";"a"="Fly-in day covers shipwrecks and seals; overnight adds remoteness and light. Budget two days with the flight."},
 @{"q"="What does Namibia cost?";"a"="Guided loops from about 430 dollars per day mid-range; briefed self-drives from about 300."})
Add-Faqs "south-africa-safari/index.html" @(
 @{"q"="Kruger self-drive or private lodge?";"a"="Self-drive Kruger is cheap and fun; Sabi Sand concessions cost more but deliver off-road leopards, night drives and walks. We quote both."},
 @{"q"="Where is malaria-free?";"a"="Madikwe, Pilanesberg and Eastern Cape reserves. Kruger carries low-to-moderate risk; prophylaxis advised."},
 @{"q"="When should we go?";"a"="May to September dry winter for game (freezing dawns); November to March for Cape Town beaches and winelands."},
 @{"q"="How many days?";"a"="Five for Kruger; nine for Cape, winelands and Kruger; twelve adding the Garden Route."},
 @{"q"="Sabi Sand or Timbavati?";"a"="Sabi Sand for peak leopard density; Timbavati for value with traversing rights."},
 @{"q"="Is South Africa safe for tourists?";"a"="On standard circuits with normal precautions, yes: door-to-door transfers, vetted lodges. Cities need big-city sense."},
 @{"q"="What does it cost?";"a"="Strong value: bush-city combos from about 550 dollars per day; Sabi suites higher; self-drive Kruger undercuts everything."},
 @{"q"="Best family setup?";"a"="Malaria-free Madikwe or Eastern Cape lodges with cubs clubs, plus Cape Town beaches and penguins."},
 @{"q"="Can we add an island?";"a"="Mauritius for ease, Seychelles for splurge - both direct from Johannesburg."})
Add-Faqs "ethiopia-safari/index.html" @(
 @{"q"="Is Ethiopia safe right now?";"a"="Conditions vary by region and year - we monitor advisories route by route and only operate where partners confirm safe passage."},
 @{"q"="Historic north or Omo Valley?";"a"="North for culture plus light trekking; Omo for respectful cultural travel; Danakil for the hardy. Twelve days combines north and Omo."},
 @{"q"="How hard is Simien trekking?";"a"="Moderate: 3,200 to 4,400m, 4 to 6 hours daily. Mules carry gear; one acclimatisation day suffices for most."},
 @{"q"="When should we go?";"a"="October to March dry season. Timkat (January 19) and Meskel (September 27) festivals are worth planning around."},
 @{"q"="What wildlife will we see?";"a"="Endemics: geladas, walia ibex, Ethiopian wolf, mountain nyala. Expect highland species, not savanna herds."},
 @{"q"="How many days?";"a"="Eight for the historic north plus Simien; seven for Omo; twelve for both; fourteen adding Danakil or Bale."},
 @{"q"="Is the altitude a problem?";"a"="Addis sits at 2,400m; Simien camps reach 3,600m-plus. Most acclimatise with one easy day."},
 @{"q"="How do Omo visits stay respectful?";"a"="Community-origin guides, small groups, agreed photo fees, market-day timing. Protocols briefed before every visit."},
 @{"q"="Can Ethiopia combine with safari elsewhere?";"a"="Yes via Addis links: Simien plus Serengeti, or Omo plus Uganda primates."})
"hubfaq-fix done"
