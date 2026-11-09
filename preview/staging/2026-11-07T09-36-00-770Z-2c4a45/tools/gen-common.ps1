# gen-common.ps1 - shared data + builders for the marketplace expansion.
$root = "C:\Users\HP\OneDrive\Documents\Default Project"
Set-Location $root
$DB = New-Object System.Collections.ArrayList

$IMG = @{
 TZ=@("https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=1800&q=70&auto=format&fit=crop","Lion on the Serengeti plains at sunrise, Tanzania");
 KE=@("https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=1800&q=70&auto=format&fit=crop","Giraffes with Mount Kilimanjaro behind, Amboseli, Kenya");
 UG=@("https://images.unsplash.com/photo-1547721064-da6cfb341d50?w=1800&q=70&auto=format&fit=crop","Mountain gorilla in Bwindi forest, Uganda");
 BW=@("https://images.unsplash.com/photo-1551009175-8a68da93d5f9?w=1800&q=70&auto=format&fit=crop","Elephant wading in the Okavango Delta, Botswana");
 NA=@("https://images.unsplash.com/photo-1547235001-d703406d3f17?w=1800&q=70&auto=format&fit=crop","Red dunes of Sossusvlei, Namibia");
 SA=@("https://images.unsplash.com/photo-1535941339077-2dd1c7963098?w=1800&q=70&auto=format&fit=crop","Leopard in Kruger National Park, South Africa");
 ET=@("https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=1800&q=70&auto=format&fit=crop","Simien Mountains escarpment, Ethiopia");
 MIG=@("https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1800&q=70&auto=format&fit=crop","Wildebeest crossing the Mara River during the Great Migration");
 BEACH=@("https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1800&q=70&auto=format&fit=crop","White-sand beach with palms, Indian Ocean coast");
 KILI=@("https://images.unsplash.com/photo-1551632811-561732d1e306?w=1800&q=70&auto=format&fit=crop","Mount Kilimanjaro above the clouds");
 CAPE=@("https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=1800&q=70&auto=format&fit=crop","Table Mountain above Cape Town, South Africa")
}
$CGATE = @{Tanzania="Arusha";Kenya="Nairobi";Uganda="Entebbe";Botswana="Maun";Namibia="Windhoek";"South Africa"="Johannesburg";Ethiopia="Addis Ababa";"Kenya & Tanzania"="Nairobi"}
$CBASE = @{Tanzania=450;Kenya=440;Uganda=450;Botswana=980;Namibia=430;"South Africa"=580;Ethiopia=460;"Kenya & Tanzania"=460}
$CHUB = @{Tanzania="/tanzania-safari/";Kenya="/kenya-safari/";Uganda="/uganda-safari/";Botswana="/botswana-safari/";Namibia="/namibia-safari/";"South Africa"="/south-africa-safari/";Ethiopia="/ethiopia-safari/";"Kenya & Tanzania"="/kenya-tanzania-safari/"}
$CIMG = @{Tanzania="TZ";Kenya="KE";Uganda="UG";Botswana="BW";Namibia="NA";"South Africa"="SA";Ethiopia="ET";"Kenya & Tanzania"="KE"}

$PB = @{
 "Tarangire"="Elephant herds along the Tarangire River, ancient baobabs and 500-plus bird species.";
 "Ngorongoro Crater"="Gate-open descent for lions, black rhino, hyena clans and flamingo lakes on the crater floor.";
 "Central Serengeti"="Resident big cats around Seronera - lions, leopards and cheetahs at close range.";
 "Northern Serengeti"="Mara River crossing points; picnic lunches and patient waiting July to October.";
 "Ndutu / Southern Serengeti"="Calving-season plains January to March: newborn wildebeest and every predator watching.";
 "Western Serengeti"="Grumeti River frontage and big-cat territories, superb in June.";
 "Lake Manyara"="Groundwater forest, tree-climbing lions and flamingo shoreline.";
 "Ruaha"="Wild southern circuit: huge lion prides, wild dogs and 570 bird species, almost no crowds.";
 "Nyerere"="Rufiji River boat safaris, walking safaris and wild-dog country.";
 "Mikumi"="Accessible southern savanna: lions, elephants and hippo pools, ideal from Dar es Salaam.";
 "Udzungwa"="Forest hiking, waterfalls and endemic primates for active add-on days.";
 "Zanzibar"="Spice farms, Stone Town and white-sand beach days to close the trip.";
 "Masai Mara"="Marsh Pride lions, river crossings in season and big-cat density at its peak.";
 "Amboseli"="Great-tusker elephants with Kilimanjaro looming - clearest at dawn.";
 "Lake Naivasha"="Boat safaris past hippos plus Crescent Island walking with wildlife.";
 "Lake Nakuru"="Black and white rhinos and flamingo-fringed shores.";
 "Samburu"="The Special Five: Grevy zebra, reticulated giraffe, gerenuk, Beisa oryx, Somali ostrich.";
 "Tsavo"="Red-dust elephants, Mzima Springs and crowd-free savanna.";
 "Bwindi"="Steep forest trails to a habituated gorilla family; one hour at eight metres.";
 "Kibale"="Chimpanzee tracking with near-certain success plus Bigodi swamp walk.";
 "Queen Elizabeth"="Tree-climbing lions of Ishasha and the Kazinga Channel boat safari.";
 "Murchison Falls"="Nile boat to the falls foot, top-of-falls walk and north-bank game drives.";
 "Okavango Delta"="Mokoro dugout safari, palm-island walks and predator drives from a water camp.";
 "Chobe"="Riverfront boat safaris among elephant and buffalo masses.";
 "Moremi / Khwai"="Predators, wild dogs and concession freedoms: off-road, night drives, walks.";
 "Makgadikgadi"="Meerkat mornings, quad-bike vastness and zebra migration in the rains.";
 "Etosha"="Waterhole circuits and floodlit night holes: lions, black rhino, vast herds.";
 "Sossusvlei"="Dawn Big Daddy climb, Deadvlei pan and Sesriem Canyon.";
 "Damaraland"="Twyfelfontein engravings and desert-rhino tracking on foot with community trackers.";
 "Swakopmund"="Seal kayaking, Sandwich Harbour 4x4 and a coastal breather.";
 "Skeleton Coast"="Fly-in shipwrecks, seal colonies and dunes meeting ocean.";
 "Kruger"="Classic Big Five self-drive or guided circuits from rest camps.";
 "Sabi Sand"="Off-road private traversing, night drives and walks - the best leopard viewing on earth.";
 "Cape Town"="Table Mountain, Cape Peninsula penguins and waterfront evenings.";
 "Winelands"="Stellenbosch tastings and Cape Dutch estates.";
 "Garden Route"="Hermanus whales in season, Knysna lagoon and Tsitsikamma forest.";
 "Diani Beach"="Kitesurfing, Wasini dhow snorkelling and Colobus forest walks.";
 "Lalibela"="Eleven rock-hewn churches with a specialist guide.";
 "Simien Mountains"="Gelada troops, lammergeier vultures and 4,500-metre escarpments.";
 "Omo Valley"="Hamar, Mursi and Karo communities with community-origin guides.";
 "Victoria Falls"="Falls walk, Zambezi sunset cruise and optional helicopter flight."
}
$PNPARK = @{ # park name -> guide url (where a guide exists)
 "Tarangire"="/national-parks/tarangire/";"Ngorongoro Crater"="/national-parks/ngorongoro/";
 "Central Serengeti"="/national-parks/serengeti/";"Northern Serengeti"="/national-parks/serengeti/";
 "Ndutu / Southern Serengeti"="/national-parks/serengeti/";"Western Serengeti"="/national-parks/serengeti/";
 "Lake Manyara"="/national-parks/lake-manyara/";"Ruaha"="/national-parks/ruaha/";"Nyerere"="/national-parks/nyerere/";
 "Mikumi"="/national-parks/savanna-parks/";"Masai Mara"="/national-parks/masai-mara/";"Amboseli"="/national-parks/amboseli/";
 "Lake Naivasha"="/national-parks/lake-naivasha/";"Lake Nakuru"="/national-parks/lake-naivasha/";"Samburu"="/national-parks/samburu/";
 "Bwindi"="/national-parks/bwindi/";"Kibale"="/national-parks/kibale/";"Okavango Delta"="/national-parks/okavango-delta/";
 "Chobe"="/national-parks/chobe/";"Etosha"="/national-parks/etosha/";"Sossusvlei"="/national-parks/sossusvlei/";
 "Sabi Sand"="/national-parks/kruger/";"Kruger"="/national-parks/kruger/"
}
$TT = @{"Tarangire|Ngorongoro Crater"="3-hr drive via Karatu";"Ngorongoro Crater|Central Serengeti"="4-5 hr game drive via Olduvai";
 "Central Serengeti|Northern Serengeti"="4-5 hr northbound game drive";"Nairobi|Amboseli"="4-hr drive south";
 "Amboseli|Lake Naivasha"="5-6 hr Rift Valley drive";"Lake Naivasha|Masai Mara"="5-hr drive via Narok";
 "Maun|Okavango Delta"="25-min light-aircraft hop";"Okavango Delta|Moremi / Khwai"="short charter hop";
 "Moremi / Khwai|Chobe"="charter to Kasane";"Windhoek|Sossusvlei"="5-hr desert drive";
 "Sossusvlei|Swakopmund"="coastal drive via Kuiseb";"Swakopmund|Damaraland"="4-hr northbound drive";
 "Damaraland|Etosha"="3-4 hr drive to Anderson Gate";"Johannesburg|Sabi Sand"="5-hr drive or 1-hr flight plus transfer";
 "Cape Town|Sabi Sand"="2-hr flight via Johannesburg";"Entebbe|Kibale"="5-6 hr drive west";
 "Kibale|Queen Elizabeth"="3-hr drive south";"Queen Elizabeth|Bwindi"="5-6 hr drive via Ishasha";
 "Entebbe|Murchison Falls"="5-6 hr drive via Ziwa rhinos";"Addis Ababa|Lalibela"="1-hr flight north";
 "Lalibela|Simien Mountains"="flight plus 2-hr mountain drive"}

$FQ = @(
 @{"q"="How far ahead should we book?";"a"="Peak Migration and gorilla-permit months need 6 to 12 months. Green season often works with 2 to 4 months notice."},
 @{"q"="Is this trip private?";"a"="Yes - every itinerary here runs with your own vehicle and guide. No Mixed-group compromises unless you ask for a join-in price."},
 @{"q"="What is included in the from-price?";"a"="Private 4x4 and driver-guide, accommodation, park and concession fees, listed transfers and most meals. International flights, visas, insurance and tips are excluded."},
 @{"q"="Can we customise the route?";"a"="Freely - add nights, upgrade camps, swap parks or append beach and trekking. Request a proposal and we re-quote line by line."},
 @{"q"="What is the best month for this trip?";"a"="Dry-season months give the easiest wildlife viewing; green-season months cut cost 20 to 35 percent. Tell us your window and we confirm the wildlife logic."},
 @{"q"="Is this trip suitable for children?";"a"="With a private vehicle and pools at stops, yes for most routes. Gorilla trekking has a strict minimum age of 15."},
 @{"q"="How fit do we need to be?";"a"="Game-drive safaris need no fitness. Trekking trips state their grade honestly - ask for the training notes."},
 @{"q"="Can we add a beach extension?";"a"="Yes - Zanzibar, Diani and Mozambique links are routine. Say the word and the flights slot into your proposal."},
 @{"q"="Do we need a visa?";"a"="Most visitors need one: Tanzania offers visas on arrival for many nationalities, Kenya uses an eTA applied for online before travel, Uganda an e-visa. We confirm the current rule for your passport before you fly."},
 @{"q"="What vaccinations and malaria prevention do we need?";"a"="Yellow fever certificates are required when arriving from endemic countries; malaria prophylaxis is recommended for most safari regions - discuss options with your doctor 6 to 8 weeks out. We brief every trip on water, sun and insect precautions."},
 @{"q"="How much should we tip?";"a"="As a guideline: 15 to 25 dollars per day for your driver-guide (per group, not per person), 10 to 15 dollars per day into camp communal tip boxes, and 20 to 30 dollars for a gorilla porter. Restaurants 10 percent where service is not included."},
 @{"q"="What is NOT included that surprises first-timers?";"a"="International flights, visas, travel insurance (required), premium drinks, the balloon flight where offered, and tips. Our quotes line-item park fees and permits so the total you compare is the total you pay."},
 @{"q"="How do deposits and payments work?";"a"="A deposit of 20 to 30 percent confirms camps, permits and flights; the balance is due 60 days before travel. We accept bank transfer and major cards (card fees disclosed upfront). Full terms arrive in writing before you pay anything."},
 @{"q"="Traveling solo - how do single supplements work?";"a"="All itineraries run solo. Expect a 20 to 50 percent supplement where lodges charge per room; vehicles cost the same whether one or six ride. Ask for the honest supplement math per trip."},
 @{"q"="What photography gear should we bring?";"a"="A 100 to 400mm zoom covers 90 percent of sightings; add a wide second body for landscapes. Beanbags beat tripods in vehicles. We provide charging setups and dust management briefings - tell us your kit and targets."},
 @{"q"="Can dietary needs be handled in bush camps?";"a"="Yes - vegetarian, vegan, gluten-free and most allergies are routinely catered with advance notice. Remote camps need 30 days notice for specialist supplies; tell us at proposal stage."},
 @{"q"="What happens if it rains?";"a"="Game drives run rain or shine - vehicles have roofs and ponchos, animals remain active, and green-season light is superb for photography. Only true downpours pause activity, and camps flex schedules around them."},
 @{"q"="Are your guides qualified?";"a"="Our driver-guides average a decade in their parks, hold national guiding licenses plus first-aid certification, and are assigned by specialty - Migration positioning, photography, birding or family pacing."},
 @{"q"="Is a balloon flight worth adding?";"a"="Once, yes: a dawn flight over the Serengeti or Mara with a bush breakfast runs 550 to 600 dollars and minimum ages apply. Book at proposal stage - seats sell out months ahead in season."},
 @{"q"="How do internal flights and luggage limits work?";"a"="Bush flights allow 15 to 20kg in soft duffels; lodges store hard cases free. We route connections with realistic margins and meet you at every airstrip - missed-connection cover is built into fly-in trips."},
 @{"q"="Can older travelers or limited mobility join?";"a"="Often yes: game drives are vehicle-based, many lodges have ground-floor rooms with walk-in showers, and we grade walking and trekking honestly. Tell us constraints and we design around them - except gorilla trekking, which demands real hill fitness."},
 @{"q"="What insurance do we need?";"a"="Comprehensive travel insurance is required, including medical evacuation (AMREF/Flying Doctors cover, about 30 dollars, is recommended for remote circuits). Bring policy details - camps and operators ask for them."},
 @{"q"="How do we get the best price without hurting the trip?";"a"="Travel green season, bring four or more travelers to split the vehicle, choose tented camps over lodges, and drive where flying saves little. Never cut guide quality, Migration-zone positioning or insurance."}
)

function Fmt-Money($n){ return "$" + ('{0:N0}' -f $n) }
function Price-Pair($country,$days,$mult,$flatAdd){
  $b=$CBASE[$country]*$days*$mult+$flatAdd
  $g=[math]::Round($b*0.92/50)*50; $p=[math]::Round($b*1.12/50)*50
  return @($g,$p)
}
function Shell($title,$desc,$canon,$body,$headExtra){
  $h1 = @"
<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title | Adventure Safari Africa</title>
<meta name="description" content="$desc">
<link rel="canonical" href="$canon">
<link rel="alternate" hreflang="en" href="$canon"><link rel="alternate" hreflang="x-default" href="$canon">
<link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script><script src="/assets/partials.js" defer></script>
$headExtra</head><body><a class="skip" href="#main">Skip to content</a><div id="site-header"></div>
$body<div id="site-footer"></div></body></html>
"@
  return $h1
}
function CTA-Band($h,$p,$pkg){
  return "<div class=`"cta-band`" style=`"margin-top:28px`"><div><h2>$h</h2><p>$p</p></div><div style=`"display:grid;gap:10px`"><a class=`"btn btn-g`" href=`"/request-proposal/`">Request a proposal</a><a class=`"btn btn-wa`" data-wa data-wa-pkg=`"$pkg`" href=`"#`">WhatsApp about this safari</a><a href=`"/safari-consultation/`" style=`"color:#fff`">Book a consultation</a></div></div>"
}
function Card-Pkg($url,$name,$meta,$price,$blurb,$imgk){
  if(-not $imgk){$imgk="TZ"}
  $im=$IMG[$imgk]; if(-not $im){$im=$IMG["TZ"]}
  $thumb=$im[0] -replace "w=1800","w=800"
  return "<article class=`"card`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$thumb`" alt=`"$name`"><div class=`"pad`"><p class=`"meta`">$meta</p><h3><a href=`"$url`">$name</a></h3><p>$blurb</p><p><span class=`"price`">$price</span></p><p><a class=`"btn btn-o btn-sm`" href=`"$url`">View safari</a> <a class=`"btn btn-p btn-sm`" href=`"/request-proposal/`">Customize</a> <a class=`"btn btn-wa btn-sm`" data-wa data-wa-pkg=`"$name`" href=`"#`">WhatsApp</a></p></div></article>"
}
function Card-Dest($url,$name,$blurb,$imgk){
  $im=$IMG[$imgk]; if(-not $im){$im=$IMG["TZ"]}
  $thumb=$im[0] -replace "w=1800","w=800"
  return "<a class=`"card`" href=`"$url`"><img loading=`"lazy`" decoding=`"async`" width=`"800`" height=`"500`" src=`"$thumb`" alt=`"$name`"><div class=`"pad`"><h3>$name</h3><p>$blurb</p></div></a>"
}
function Faq-List($faqs){
  $s="<div class=`"faq`"><h2>FAQs</h2>"; $i=0
  foreach($f in $faqs){ $o=""; if($i -eq 0){$o=" open"}; $s+="<details$o><summary>$($f.q)</summary><p>$($f.a)</p></details>"; $i++ }
  return $s+"</div>"
}
function Faq-Schema($faqs){
  $ents=@(); foreach($f in $faqs){ $q=$f.q -replace '"',"'"; $a=$f.a -replace '"',"'"; $ents+="{`"@type`":`"Question`",`"name`":`"$q`",`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":`"$a`"}}" }
  return '<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":['+($ents -join ",")+"]}</script>"
}
function Crumb($items){ return '<main id="main"><nav class="wrap crumbs">'+($items -join " > ")+"</nav>" }
$PIMG = @{
 "Tarangire"="TZ";"Ngorongoro Crater"="TZ";"Central Serengeti"="TZ";"Northern Serengeti"="MIG";"Ndutu / Southern Serengeti"="TZ";
 "Western Serengeti"="MIG";"Lake Manyara"="TZ";"Ruaha"="TZ";"Nyerere"="TZ";"Mikumi"="TZ";"Udzungwa"="TZ";"Zanzibar"="BEACH";
 "Masai Mara"="KE";"Amboseli"="KE";"Lake Naivasha"="KE";"Lake Nakuru"="KE";"Samburu"="KE";"Tsavo West"="KE";
 "Bwindi"="UG";"Kibale"="UG";"Queen Elizabeth"="UG";"Murchison Falls"="UG";
 "Okavango Delta"="BW";"Chobe"="BW";"Moremi / Khwai"="BW";"Makgadikgadi"="BW";"Linyanti"="BW";
 "Etosha"="NA";"Sossusvlei"="NA";"Damaraland"="NA";"Swakopmund"="NA";"Skeleton Coast"="NA";
 "Kruger"="SA";"Sabi Sand"="SA";"Cape Town"="CAPE";"Winelands"="CAPE";"Garden Route"="CAPE";"Diani Beach"="BEACH";
 "Lalibela"="ET";"Simien Mountains"="ET";"Omo Valley"="ET";"Victoria Falls"="BW"
}
$DIRIMG = @{
 "tanzania-safari"="TZ";"kenya-safari"="KE";"uganda-safari"="UG";"botswana-safari"="BW";"namibia-safari"="NA";
 "south-africa-safari"="SA";"ethiopia-safari"="ET";"tanzania-safari-from-zanzibar"="BEACH";"tanzania-migration-safari"="MIG";
 "southern-tanzania-safari"="TZ";"tanzania-honeymoon-safari"="BEACH";"tanzania-luxury-safari"="TZ";"tanzania-family-safari"="KE";
 "tanzania-private-safari"="TZ";"tanzania-photographic-safari"="MIG";"tanzania-budget-safari"="TZ";"tanzania-beach-and-safari"="BEACH";
 "kenya-safari-from-nairobi"="KE";"masai-mara-safari"="KE";"kenya-honeymoon-safari"="BEACH";"kenya-luxury-safari"="KE";
 "kenya-family-safari"="KE";"kenya-private-safari"="KE";"kenya-photographic-safari"="KE";"kenya-beach-safari"="BEACH";
 "kenya-tanzania-safari"="MIG";"uganda-gorilla-trekking"="UG";"uganda-wildlife-safari"="UG";"uganda-honeymoon-safari"="UG";
 "uganda-luxury-safari"="UG";"africa-safaris"="MIG";"africa-honeymoon-safaris"="BEACH";"africa-family-safaris"="KE";
 "africa-luxury-safaris"="TZ";"africa-migration-safaris"="MIG";"private-african-safaris"="KE";"tailor-made-african-safaris"="TZ";
 "africa-safari-packages"="MIG";"africa-safari-from-zanzibar"="BEACH";"africa-gorilla-safaris"="UG";"africa-photographic-safaris"="MIG";
 "africa-budget-safaris"="NA";"east-africa-safari"="MIG";"southern-africa-safari"="SA";"group-african-safaris"="TZ";
 "tanzania-group-safari"="TZ"
}
$BESTFOR = @{
 "classic"="First-time safari travelers and anyone wanting the essential parks done properly.";
 "migration"="Travelers timing their trip to herds, crossings or calving - patience rewarded.";
 "honeymoon"="Couples wanting privacy, suite upgrades and bush-to-beach romance.";
 "family"="Families needing pools, pacing and private-vehicle flexibility.";
 "luxury"="Travelers wanting fly-in ease, concessions and suite-level stays.";
 "budget"="Value-focused travelers happy to trade thread counts for park time.";
 "photographic"="Photographers needing private vehicles, light-chasing days and positioning.";
 "private"="Everyone who wants their own vehicle, guide and schedule - our default.";
 "trekking"="Active travelers meeting fitness notes honestly - porters included in planning.";
 "gorilla"="Primate-focused travelers - permits secured before lodges, always.";
 "beach"="Bush-plus-beach travelers - safari first, sand after, flights linked.";
 "combo"="Two-country travelers - one ecosystem, zero repeated parks.";
 "tailor-made"="Travelers reshaping any sketch into something unmistakably theirs."
}
function Faq-Pick($seed,$n){
  $out=@(); for($i=0;$i -lt $n;$i++){ $out+=$FQ[($seed+$i*5)%$FQ.Count] }
  return $out
}
function Faq-Cat($title,$catWho,$time,$dur,$priceEx){
  return @(
   @{"q"="What is the best month for this trip?";"a"="Timing decides everything: "+$time+" Tell us your exact window and we confirm the wildlife logic before quoting camps."},
   @{"q"="How many days should we allow?";"a"=$dur+" Shorter formats move daily; longer formats add buffer days for weather, herds and rest - the days most travelers later call the best."},
   @{"q"="What does it cost?";"a"="As a baseline, "+$priceEx+" Final pricing depends on season, camp tier and group size - every proposal is line-itemed so you can trade choices up or down per night."},
   @{"q"="Who is this trip best for?";"a"=$catWho}
  ) + (Faq-Pick ($title.Length) 5)
}
function Faq-Global($title,$seasonLine,$priceLine,$durLine,$fitLine){
  return @(
   @{"q"="When should we travel?";"a"=$seasonLine},
   @{"q"="What should we budget?";"a"=$priceLine},
   @{"q"="How long do we need?";"a"=$durLine},
   @{"q"="Who is this style best for?";"a"=$fitLine}
  ) + (Faq-Pick ($title.Length*2) 5)
}
function Faq-Park($park,$country,$time,$days,$combo){
  return @(
   @{"q"="How many days do we need in "+$park+"?";"a"=$days},
   @{"q"="When is the best time to visit "+$park+"?";"a"=$time},
   @{"q"="What pairs well with "+$park+"?";"a"=$combo}
  ) + (Faq-Pick ($park.Length*3) 6)
}
function Faq-Activity($act,$where,$costLine,$fitLine){
  return @(
   @{"q"="What exactly is "+$act+"?";"a"=$where},
   @{"q"="What does it cost?";"a"=$costLine},
   @{"q"="Who is it suitable for?";"a"=$fitLine}
  ) + (Faq-Pick ($act.Length*7) 6)
}
