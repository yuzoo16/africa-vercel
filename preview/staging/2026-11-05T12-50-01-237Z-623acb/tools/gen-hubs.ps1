# gen-hubs.ps1 - Africa-wide hubs + country-category hubs. Run: powershell -File tools/gen-hubs.ps1
. "$PSScriptRoot/gen-common.ps1"

$HL = @{ # dir -> "label|parentUrl|parentLabel"
 "africa-safaris"="Africa Safaris|/|Home";"africa-honeymoon-safaris"="Africa Honeymoon Safaris|/africa-safaris/|Africa Safaris";
 "africa-family-safaris"="Africa Family Safaris|/africa-safaris/|Africa Safaris";"africa-luxury-safaris"="Africa Luxury Safaris|/africa-safaris/|Africa Safaris";
 "africa-migration-safaris"="Africa Migration Safaris|/africa-safaris/|Africa Safaris";"private-african-safaris"="Private African Safaris|/africa-safaris/|Africa Safaris";
 "tailor-made-african-safaris"="Tailor-Made African Safaris|/africa-safaris/|Africa Safaris";"africa-safari-packages"="Africa Safari Packages|/africa-safaris/|Africa Safaris";
 "kenya-tanzania-safari"="Kenya & Tanzania Safari|/africa-safaris/|Africa Safaris";"africa-safari-from-zanzibar"="Safari from Zanzibar|/africa-safaris/|Africa Safaris";
 "africa-gorilla-safaris"="Africa Gorilla Safaris|/africa-safaris/|Africa Safaris";"africa-photographic-safaris"="Africa Photographic Safaris|/africa-safaris/|Africa Safaris";
 "africa-budget-safaris"="Budget African Safaris|/africa-safaris/|Africa Safaris";
 "tanzania-safari-from-zanzibar"="Safari from Zanzibar|/tanzania-safari/|Tanzania Safari";"tanzania-migration-safari"="Tanzania Migration Safari|/tanzania-safari/|Tanzania Safari";
 "southern-tanzania-safari"="Southern Tanzania Safari|/tanzania-safari/|Tanzania Safari";"tanzania-honeymoon-safari"="Tanzania Honeymoon Safari|/tanzania-safari/|Tanzania Safari";
 "tanzania-luxury-safari"="Tanzania Luxury Safari|/tanzania-safari/|Tanzania Safari";"tanzania-family-safari"="Tanzania Family Safari|/tanzania-safari/|Tanzania Safari";
 "tanzania-private-safari"="Tanzania Private Safari|/tanzania-safari/|Tanzania Safari";"tanzania-photographic-safari"="Tanzania Photographic Safari|/tanzania-safari/|Tanzania Safari";
 "tanzania-budget-safari"="Tanzania Budget Safari|/tanzania-safari/|Tanzania Safari";"tanzania-beach-and-safari"="Tanzania Beach & Safari|/tanzania-safari/|Tanzania Safari";
 "kenya-safari-from-nairobi"="Kenya Safari from Nairobi|/kenya-safari/|Kenya Safari";"masai-mara-safari"="Masai Mara Safari|/kenya-safari/|Kenya Safari";
 "kenya-honeymoon-safari"="Kenya Honeymoon Safari|/kenya-safari/|Kenya Safari";"kenya-luxury-safari"="Kenya Luxury Safari|/kenya-safari/|Kenya Safari";
 "kenya-family-safari"="Kenya Family Safari|/kenya-safari/|Kenya Safari";"kenya-private-safari"="Kenya Private Safari|/kenya-safari/|Kenya Safari";
 "kenya-photographic-safari"="Kenya Photographic Safari|/kenya-safari/|Kenya Safari";"kenya-beach-safari"="Kenya Beach & Safari|/kenya-safari/|Kenya Safari";
 "uganda-gorilla-trekking"="Uganda Gorilla Trekking|/uganda-safari/|Uganda Safari";"uganda-wildlife-safari"="Uganda Wildlife Safari|/uganda-safari/|Uganda Safari";
 "uganda-honeymoon-safari"="Uganda Honeymoon Safari|/uganda-safari/|Uganda Safari";"uganda-luxury-safari"="Uganda Luxury Safari|/uganda-safari/|Uganda Safari";
 "botswana-luxury-safari"="Botswana Luxury Safari|/botswana-safari/|Botswana Safari";"botswana-honeymoon-safari"="Botswana Honeymoon Safari|/botswana-safari/|Botswana Safari";
 "botswana-family-safari"="Botswana Family Safari|/botswana-safari/|Botswana Safari";
 "namibia-luxury-safari"="Namibia Luxury Safari|/namibia-safari/|Namibia Safari";"namibia-honeymoon-safari"="Namibia Honeymoon Safari|/namibia-safari/|Namibia Safari";
 "namibia-family-safari"="Namibia Family Safari|/namibia-safari/|Namibia Safari";"namibia-self-drive"="Namibia Self-Drive|/namibia-safari/|Namibia Safari";
 "south-africa-luxury-safari"="South Africa Luxury Safari|/south-africa-safari/|South Africa Safari";"south-africa-honeymoon-safari"="South Africa Honeymoon Safari|/south-africa-safari/|South Africa Safari";
 "south-africa-family-safari"="South Africa Family Safari|/south-africa-safari/|South Africa Safari";
 "east-africa-safari"="East Africa Safari|/africa-safaris/|Africa Safaris";
 "southern-africa-safari"="Southern Africa Safari|/africa-safaris/|Africa Safaris";
 "group-african-safaris"="Group African Safaris|/africa-safaris/|Africa Safaris";
 "tanzania-group-safari"="Tanzania Group Safari|/tanzania-safari/|Tanzania Safari"
}
function Hub-Head($dir,$title){
  $p=$HL[$dir].Split("|"); return @($p[0],$p[1],$p[2])
}
function Img-ForUrl($url){
  $d=$url.Trim("/").Split("/")[0]
  $k=$DIRIMG[$d]; if(-not $k){$k="TZ"}
  return $k
}
function New-Global($slug,$title,$desc,$intro,$imgk,$countries,$pkgs,$compares,$faqs,$related){
  if($countries.Count -gt 0 -and $countries[0] -is [string]){ $countries = ,$countries }
  if($pkgs.Count -gt 0 -and $pkgs[0] -is [string]){ $pkgs = ,$pkgs }
  if($compares.Count -gt 0 -and $compares[0] -is [string]){ $compares = ,$compares }
  $im=$IMG[$imgk]
  $cards=""; foreach($c in $countries){ $cards+=Card-Dest $c[1] $c[0] $c[2] (Img-ForUrl $c[1]) }
  $pcards=""; foreach($p in $pkgs){ $pcards+=Card-Pkg $p[0] $p[1] $p[2] $p[3] $p[4] (Img-ForUrl $p[0]) }
  $cmp="<table class=`"cmp`"><tr><th>Option</th><th>Best for</th><th>Guide price</th></tr>"; foreach($r in $compares){ $cmp+="<tr><td>$($r[0])</td><td>$($r[1])</td><td>$($r[2])</td></tr>" }; $cmp+="</table>"
  $optLines=@(); foreach($c in $countries){ $optLines+="<strong>$($c[0]):</strong> $($c[2])" }
  $priceLines=@(); foreach($r in $compares){ $priceLines+="$($r[0]) ($($r[1])) - $($r[2])" }
  $faqs=$faqs+@(
   @{"q"="How do we choose between the options above?";"a"="Match the country to your priority: "+($optLines -join " ")+" Tell us your month and party and a specialist narrows it to one route."},
   @{"q"="What do the guide prices on this page include?";"a"="Guide prices such as "+($priceLines -join "; ")+" are mid-range baselines per person (two travelers), including private vehicle and guide, accommodation, park fees and listed transfers. Peak season and luxury tiers quote higher - every proposal is line-itemed."}
  )
  while($faqs.Count -lt 9){ $faqs+=Faq-Pick ($slug.Length+$faqs.Count*3) 1 }
  $body=Crumb @('<a href="/">Home</a>',$title)
  $body+="<div class=`"hero`"><img class=`"bg`" src=`"$($im[0])`" alt=`"$($im[1])`"><div class=`"hero-in`"><p class=`"eyebrow`">Africa-wide safari hub</p><h1>$title</h1><p class=`"sub`">$desc</p><div class=`"hero-ctas`"><a class=`"btn btn-g`" href=`"/request-proposal/`">Plan my safari</a><a class=`"btn btn-wa`" data-wa href=`"#`">WhatsApp an expert</a></div></div></div>"
  $body+="<section class=`"block`"><div class=`"wrap`"><h2>Introduction</h2><p class=`"lead`">$intro</p>"
  $body+="<h2>Best countries for this safari</h2><div class=`"grid g3`">$cards</div>"
  $body+="<h2>Featured safari packages</h2><div class=`"grid g3`">$pcards</div>"
  $body+="<h2>Compare your options</h2>$cmp"
  $body+=(Faq-List $faqs)+"<h2>Related guides</h2><p>$related</p>"
  $body+=(CTA-Band "Plan this exact trip" "One specialist, line-item pricing, reply within 24 hours." $title)+"</div></section></main>"
  $canon="https://www.adventuresafariafrica.com/$slug/"
  $html=Shell $title $desc $canon $body (Faq-Schema $faqs)
  New-Item -ItemType Directory -Path "$slug" -Force | Out-Null
  $html | Out-File -FilePath "$slug/index.html" -Encoding utf8
  "hub: $slug"
}
$CATWHO = @{
 "honeymoon"="Couples wanting privacy, suite upgrades, bush dinners and a beach finale - private vehicle throughout.";
 "family"="Families needing pools at every stop, pacing that respects children, and private-vehicle flexibility.";
 "luxury"="Travelers wanting fly-in ease, private concessions, night drives and suite-level stays.";
 "migration"="Travelers timing their trip to herds, crossings or calving - camp location beats luck.";
 "private"="Everyone who wants their own vehicle, guide and schedule - no group compromises.";
 "photographic"="Photographers needing private vehicles, extra seat rows and light-chasing days.";
 "budget"="Value-focused travelers trading thread counts for park time - never guide quality.";
 "beach"="Bush-plus-beach travelers - safari first, sand after, flights linked.";
 "gorilla"="Primate-focused travelers - permits secured before lodges, fitness briefed honestly.";
 "wildlife"="Travelers wanting the full ecological arc - primates plus savanna, rivers and forests.";
 "self-drive"="Confident drivers wanting freedom with backup - vetted 4x4s, realistic distances.";
 "nairobi"="Travelers starting in Nairobi - fly-in expresses or full road loops from the capital.";
 "mara"="Travelers going deep in one reserve - minimum three nights, river time in season.";
 "zanzibar"="Beach-based travelers adding safari by scheduled flight - island logistics handled."
}
function New-Cat($dir,$title,$desc,$imgk,$intro,$pkgs,$dur,$time,$acc,$faqEx,$related){
  if($pkgs.Count -gt 0 -and $pkgs[0] -is [string]){ $pkgs = ,$pkgs }
  $hh=Hub-Head $dir $title; $im=$IMG[$imgk]
  $pcards=""; foreach($p in $pkgs){ $pcards+=Card-Pkg $p[0] $p[1] $p[2] $p[3] $p[4] $DIRIMG[$dir] }
  $cat=$dir.Split("-")[-1]; if($dir -match "from-"){$cat="zanzibar"}; if($dir -match "gorilla"){$cat="gorilla"}; if($dir -match "wildlife"){$cat="wildlife"}; if($dir -match "self-drive"){$cat="self-drive"}; if($dir -match "nairobi"){$cat="nairobi"}; if($dir -match "^masai"){$cat="mara"}
  $who=$CATWHO[$cat]; if(-not $who){$who=$CATWHO["private"]}
  $priceEx="rates in this cluster start at "+$pkgs[0][3]+", rising with season and camp tier - see the cards above"
  $faqs=$faqEx+(Faq-Cat $title $who $time $dur $priceEx)
  $body=Crumb @('<a href="/">Home</a>','<a href="'+$hh[1]+'">'+$hh[2]+'</a>',$hh[0])
  $body+="<div class=`"hero`"><img class=`"bg`" src=`"$($im[0])`" alt=`"$($im[1])`"><div class=`"hero-in`"><p class=`"eyebrow`">$($hh[2])</p><h1>$title</h1><p class=`"sub`">$desc</p><div class=`"hero-ctas`"><a class=`"btn btn-g`" href=`"/request-proposal/`">Plan this safari</a><a class=`"btn btn-wa`" data-wa data-wa-dest=`"$title`" href=`"#`">WhatsApp</a></div></div></div>"
  $body+="<section class=`"block`"><div class=`"wrap`"><p class=`"lead`">$intro</p>"
  $body+="<h2>Recommended itineraries</h2><div class=`"grid g3`">$pcards</div>"
  $body+="<h2>Durations, season & stays</h2><p><strong>Durations:</strong> $dur</p><p><strong>Best time:</strong> $time</p><p><strong>Stays:</strong> $acc</p>"
  $body+=(Faq-List $faqs)+"<h2>Related</h2><p>$related</p>"
  $body+=(CTA-Band "Get a tailored proposal" "Your dates, your pace, your camp tier." $title)+"</div></section></main>"
  $canon="https://www.adventuresafariafrica.com/$dir/"
  $html=Shell $title $desc $canon $body (Faq-Schema $faqs)
  New-Item -ItemType Directory -Path "$dir" -Force | Out-Null
  $html | Out-File -FilePath "$dir/index.html" -Encoding utf8
  "cat: $dir"
}

# ============ 13 GLOBAL HUBS ============
New-Global "africa-safaris" "African safaris: tours, packages & expert planning (2026/27)" "Private, tailor-made African safaris across 7 countries - destinations, styles and honest planning advice in one hub." "Every African safari starts with three decisions: where, when and how deep. This hub maps all three - seven destination silos, six travel styles and combination routes - so you can move from `I want an African safari` to a priced, tailored itinerary without guesswork. Start with a destination, a style, or tell us your month and let a specialist place you." "MIG" @(
 @("Tanzania","/tanzania-safari/","Serengeti, Ngorongoro, Kilimanjaro and Zanzibar - the complete safari."),
 @("Kenya","/kenya-safari/","Masai Mara, Amboseli and beach finishes - the easiest fly-in safari."),
 @("Uganda","/uganda-safari/","Gorillas, chimps and savanna at half Rwanda's permit price."),
 @("Botswana","/botswana-safari/","Okavango water wilderness - exclusive by policy."),
 @("Namibia","/namibia-safari/","Dunes, desert rhinos and the great road journey."),
 @("South Africa","/south-africa-safari/","Kruger plus Cape Town - bush, city and coast.")) @(
 @("/tanzania-safari/7-day-tanzania-safari/","7-Day Tanzania Safari","7 days | Migration","From `$3,450","Serengeti, Ngorongoro and Tarangire with herd positioning."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya Safari","7 days | Classic","From `$3,100","Mara, Amboseli and Rift Valley lakes."),
 @("/uganda-safari/3-day-gorilla-trekking/","3-Day Gorilla Trek","3 days | Primates","From `$2,650","Fly-in Bwindi trek with permits handled.")) @(
 @("First safari, 7 days","Tanzania or Kenya classic","From `$3,100"),
 @("Migration priority","Tanzania north or Mara, Jul-Oct","From `$3,600"),
 @("Primates plus savanna","Uganda 7-10 days","From `$4,100"),
 @("Bush plus beach","Kenya-Diani or Tanzania-Zanzibar","From `$4,600")) @(
 @{"q"="Where should a first-time safari go?";"a"="Tanzania or Kenya for classic game viewing, South Africa for easy family logistics, Uganda for primates. Five to seven days covers one country well."},
 @{"q"="How much does an African safari cost?";"a"="Mid-range private safaris run 350 to 600 dollars per person per day; luxury 800 to 1,500 plus. See our cost guide for line-item breakdowns."},
 @{"q"="When should we book?";"a"="Six to twelve months ahead for Migration season and gorilla permits; two to four months for green-season value trips."}) '<a href="/africa-honeymoon-safaris/">Honeymoons</a> | <a href="/africa-family-safaris/">Family</a> | <a href="/africa-luxury-safaris/">Luxury</a> | <a href="/africa-migration-safaris/">Migration</a> | <a href="/travel-guide/african-safari-cost/">Cost guide</a>'

New-Global "africa-honeymoon-safaris" "Africa Honeymoon Safaris: Romantic, Private & Bush-to-Beach (2026/27)" "Honeymoon safaris across Africa - private suites, bush dinners, Migration backdrops and Zanzibar, Diani or Seychelles finishes." "A safari honeymoon works because it is private by default: your vehicle, your guide, your pace - plus suites with plunge pools, lantern-lit bush dinners and a beach finale. Tanzania pairs Migration drama with Zanzibar; Kenya pairs the Mara with Diani; Botswana and Sabi Sand sell seclusion itself; South Africa bundles city, winelands and bush. Tell us your month and we match vows to herds." "BEACH" @(
 @("Tanzania honeymoons","/tanzania-honeymoon-safari/","Migration camps plus Zanzibar barefoot luxury."),
 @("Kenya honeymoons","/kenya-honeymoon-safari/","Mara conservancy tents plus Diani beach."),
 @("Botswana honeymoons","/botswana-honeymoon-safari/","Delta suites and total seclusion."),
 @("South Africa honeymoons","/south-africa-honeymoon-safari/","Cape Town, winelands and Sabi Sand."),
 @("Namibia honeymoons","/namibia-honeymoon-safari/","Dune lodges and desert solitude."),
 @("Uganda honeymoons","/uganda-honeymoon-safari/","Forest suites and gorilla magic.")) @(
 @("/tanzania-honeymoon-safari/7-day-tanzania-honeymoon/","7-Day Tanzania Honeymoon","7 days | Bush + Zanzibar option","From `$4,300","Migration camp, crater day, beach-ready finish."),
 @("/kenya-honeymoon-safari/7-day-kenya-honeymoon/","7-Day Kenya Honeymoon","7 days | Mara + beach option","From `$4,100","Conservancy tent plus Diani."),
 @("/south-africa-safari/9-day-south-africa/","9-Day Cape & Kruger","9 days | City + bush","From `$4,900","The classic honeymoon circuit.")) @(
 @("Tanzania + Zanzibar, 10-12 days","Migration plus beach","From `$5,200"),
 @("Kenya + Diani, 10 days","Mara plus beach","From `$4,600"),
 @("Sabi Sand + Mauritius","Leopards plus island","From `$7,500")) @(
 @{"q"="How long should a honeymoon safari be?";"a"="Ten to fourteen days covers safari plus beach without rushing. Seven works for bush-only trips."},
 @{"q"="When is the most romantic season?";"a"="Dry months for game drama; green months for flowers, babies, fewer vehicles and lower suite rates - many couples prefer November or March."},
 @{"q"="Can you keep it fully private?";"a"="Yes - private vehicle, private dinners and in most camps private plunge pools. Ask for the honeymoon extras list."}) '<a href="/tanzania-honeymoon-safari/">Tanzania</a> | <a href="/kenya-honeymoon-safari/">Kenya</a> | <a href="/safaris/honeymoon/">Honeymoon style guide</a> | <a href="/accommodation/tanzania/">Stays</a>'

New-Global "africa-family-safaris" "Africa Family Safaris: Best Countries, Ages & Itineraries" "Family safaris by age and pace - malaria-free reserves, pools at every stop, private vehicles and kid-paced days." "Kids remember safaris forever if the pacing respects them: pools at every stop, walking and boating breaks between drives, private vehicles for snack-and-nap flexibility, and honest age advice (gorilla trekking is strictly 15-plus). South Africa and Namibia lead for young families; East Africa shines from age six up with the right routing." "KE" @(
 @("Tanzania family","/tanzania-family-safari/","Short-hop circuits plus Zanzibar."),
 @("Kenya family","/kenya-family-safari/","Naivasha activity breaks plus Mara."),
 @("South Africa family","/south-africa-family-safari/","Malaria-free Big Five - the easiest start."),
 @("Namibia family","/namibia-family-safari/","Low malaria, dunes and coast variety."),
 @("Botswana family","/botswana-family-safari/","Older kids; water-camp magic."),
 @("Uganda family","/uganda-honeymoon-safari/","Teens-plus: chimps and savanna (gorillas at 15+).")) @(
 @("/tanzania-family-safari/6-day-tanzania-family/","6-Day Tanzania Family","6 days | Kid-paced","From `$2,900","Pools, short drives, Zanzibar option."),
 @("/south-africa-safari/5-day-kruger-safari/","5-Day Kruger Family","5 days | Malaria-free option","From `$2,800","Big Five without prophylaxis debates."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya Family","7 days | Lakes + Mara","From `$3,100","Boating breaks between drives.")) @(
 @("Ages 4-7","South Africa malaria-free, 5-7 days","From `$2,800"),
 @("Ages 8-14","Tanzania/Kenya private circuit","From `$2,900"),
 @("Teens","Uganda primates or walking add-ons","From `$4,100")) @(
 @{"q"="What is the best age for a first safari?";"a"="Six plus for East Africa fly-drive circuits; four plus works in malaria-free South African reserves with pools and short drives."},
 @{"q"="Which parks are malaria-free?";"a"="Madikwe, Pilanesberg and Eastern Cape reserves in South Africa. East Africa and Botswana need prophylaxis per your doctor."},
 @{"q"="Can teens trek gorillas?";"a"="At fifteen and above, yes - a superb older-teen milestone on a Uganda family trip."}) '<a href="/travel-guide/family-safari-guide/">Family guide</a> | <a href="/safaris/family/">Family style</a> | <a href="/travel-guide/safari-safety/">Safety</a>'

New-Global "africa-luxury-safaris" "Luxury African Safaris: Concessions, Flying & Icon Suites (2026/27)" "True luxury means private traversing, night drives, fly-in camps and suites - not just thread counts. Country by country." "Luxury changes sightings, not just sheets: private concessions allow off-road positioning, night drives and walking that national-park rules forbid; flying between camps buys game time; 1-to-4 staff ratios buy calm. Tanzania Migration camps, Mara conservancies, Sabi Sand suites and Delta water camps each deliver a different luxury - match the country to the privilege you value." "TZ" @(
 @("Tanzania luxury","/tanzania-luxury-safari/","Migration camps and crater-view suites."),
 @("Kenya luxury","/kenya-luxury-safari/","Mara conservancy exclusivity."),
 @("Botswana luxury","/botswana-luxury-safari/","The default tier - water camps."),
 @("South Africa luxury","/south-africa-luxury-safari/","Sabi Sand suites plus Cape royalty."),
 @("Namibia luxury","/namibia-luxury-safari/","Desert design lodges and flying."),
 @("Uganda luxury","/uganda-luxury-safari/","Clouds Mountain forest suites.")) @(
 @("/tanzania-luxury-safari/7-day-luxury-serengeti/","7-Day Luxury Serengeti","7 days | Flying + concessions","From `$7,200","Migration camp plus crater lodge."),
 @("/botswana-safari/8-day-botswana-safari/","8-Day Okavango & Chobe","8 days | Water camps","From `$7,400","Three camps, three ecosystems."),
 @("/south-africa-safari/9-day-south-africa/","9-Day Cape & Kruger","9 days | City + Sabi Sand","From `$4,900","Suite life, both halves.")) @(
 @("Fly-in Migration","Tanzania, Jul-Oct","From `$7,200"),
 @("Conservancy Mara","Kenya, off-road + night","From `$6,800"),
 @("Sabi Sand suite","South Africa leopards","From `$5,500")) @(
 @{"q"="What does luxury actually buy on safari?";"a"="Off-road and night-drive rights in private concessions, prime Migration positioning, flying over driving, and space - fewer beds per hectare."},
 @{"q"="Is luxury worth it in Botswana?";"a"="Botswana is mid-luxury by default due to fly-in logistics; true ultra-luxury there buys iconic water camps and private traversing."},
 @{"q"="Can luxury and kids mix?";"a"="Yes - many luxury lodges run superb cubs programs with private activities. Ask for family-suite inventory."}) '<a href="/safaris/luxury/">Luxury style</a> | <a href="/accommodation/">Stays</a> | <a href="/travel-guide/african-safari-cost/">Cost</a>'

New-Global "africa-migration-safaris" "Africa Migration Safaris: Serengeti & Masai Mara, Timed Right" "Migration safaris in Tanzania and Kenya - calving, Grumeti and Mara crossings placed by month, not brochure." "The herds move with rain, not calendars: calving in Ndutu January to March, Grumeti June, Mara crossings July to October. Tanzania holds herds ten months a year; Kenya concentrates them July to October. Camp location beats luck on both sides - mobile camps near the herds see ten times the action of lodges two hours away." "MIG" @(
 @("Tanzania Migration","/tanzania-migration-safari/","Ten-month season, three river systems."),
 @("Kenya Migration","/great-migration/masai-mara/","Peak crossing density Aug-Oct."),
 @("Serengeti zones","/great-migration/serengeti/","Ndutu, Seronera, west, north."),
 @("Calving season","/great-migration/calving-season/","Jan-Mar predator action.")) @(
 @("/tanzania-migration-safari/7-day-migration-safari/","7-Day Migration Safari","7 days | Season-placed","From `$3,800","Camp follows the herds."),
 @("/tanzania-migration-safari/5-day-migration-safari/","5-Day Migration Safari","5 days | Focused","From `$2,750","Crossing or calving focus."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya + Mara herds","7 days | Jul-Oct","From `$3,600","Mara positioning plus Amboseli.")) @(
 @("Calving Jan-Mar","Ndutu, predators, value","From `$3,400"),
 @("Grumeti Jun","Western corridor, few vehicles","From `$3,600"),
 @("Mara crossings Jul-Oct","North/Mara, peak drama","From `$3,800")) @(
 @{"q"="Which month is best for the Migration?";"a"="January to March for calving, June for Grumeti, July to October for Mara crossings. Pick the spectacle first, month second."},
 @{"q"="Tanzania or Kenya for the Migration?";"a"="Same herds: Tanzania holds them longer with more variety; Kenya concentrates them with easier logistics in season."},
 @{"q"="Are crossings guaranteed?";"a"="Never on a given day. Three-plus nights near the river with picnic lunches maximises odds - that is the honest math."}) '<a href="/great-migration/">Migration hub</a> | <a href="/great-migration/month-by-month/">Month by month</a> | <a href="/blog/serengeti-vs-masai-mara/">Serengeti vs Mara</a>'

New-Global "private-african-safaris" "Private African Safaris: Your Vehicle, Guide & Pace" "Every journey private: own 4x4, own guide, own schedule - across all seven countries." "Private means sightings on your rhythm: wait forty minutes on a leopard without a vote, skip a sighting that bores the kids, start at dawn because you want to. It roughly doubles productive sightings per hour and halves group friction - the single highest-value upgrade in safaris, available on every itinerary we sell." "KE" @(
 @("Tanzania private","/tanzania-private-safari/","Northern and southern circuits."),
 @("Kenya private","/kenya-private-safari/","Mara, Amboseli, Samburu."),
 @("Botswana private","/botswana-safari/8-day-botswana-safari/","Concession camps."),
 @("Namibia private","/namibia-safari/10-day-namibia-safari/","Guided or self-drive.")) @(
 @("/tanzania-safari/7-day-tanzania-safari/","7-Day Tanzania Private","7 days","From `$3,450","The classic, privately."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya Private","7 days","From `$3,100","Own vehicle throughout."),
 @("/botswana-safari/5-day-botswana-safari/","5-Day Botswana Private","5 days","From `$3,900","Water and herds privately.")) @(
 @("Private 4x4, 2 pax","Own guide, all parks","Standard"),
 @("Private 4x4, 4+ pax","Cost per person falls 12-18%","Best value"),
 @("Private + photographer guide","For serious shooters","On request")) @(
 @{"q"="How much more does private cost?";"a"="Versus join-in groups, typically 20 to 40 percent for two travelers - shrinking fast at four plus. Against shared-lodge game drives, often nothing extra."},
 @{"q"="Is private better for photography?";"a"="Decisively - positioning for light without a group vote, plus beanbags and door-removal options on request."}) '<a href="/safaris/private/">Private style</a> | <a href="/tailor-made-african-safaris/">Tailor-made</a> | <a href="/request-proposal/">Quote</a>'

New-Global "tailor-made-african-safaris" "Tailor-Made African Safaris: Designed Around You" "Custom itinerary planning: dates, budget, wildlife goals - one specialist, line-item quote in 24 hours." "Tailor-made is our default, not an upgrade: every package on this site is a starting sketch. You bring dates, budget and dreams; your specialist returns named camps, honest seasonal calls and line-item pricing - then revises until it is unmistakably yours. No departures, no compromises, no brochure." "TZ" @(
 @("Start from Tanzania","/tanzania-safari/packages/","2-14 day sketches."),
 @("Start from Kenya","/kenya-safari/packages/","3-10 day sketches."),
 @("Start from a style","/africa-honeymoon-safaris/","Honeymoon, family, luxury.")) @(
 @("/tanzania-safari/7-day-tanzania-safari/","Example: 7-Day Tanzania","Sketch","From `$3,450","Reshape freely."),
 @("/kenya-tanzania-safari/10-day-kenya-tanzania/","Example: 10-Day KE+TZ","Sketch","From `$5,200","Combine countries."),
 @("/uganda-safari/7-day-uganda-safari/","Example: 7-Day Uganda","Sketch","From `$4,100","Primates plus savanna.")) @(
 @("Reshape a package","Any duration, tier, park","Free"),
 @("Blank-page design","Tell us month + budget","Free"),
 @("Multi-country","Bush, beach, trekking","Free")) @(
 @{"q"="How does tailor-made pricing work?";"a"="Line-itemed: camps, fees, vehicle, flights. You see what each choice costs and can trade down or up per night."},
 @{"q"="How many revisions?";"a"="Unlimited until you are happy. Most trips settle in two to three rounds."}) '<a href="/safari-quiz/">Quiz</a> | <a href="/safari-consultation/">Consultation</a> | <a href="/request-proposal/">Start</a>'

New-Global "africa-safari-packages" "Africa Safari Packages: Browse by Destination, Duration & Style" "The full package library - every country, duration and style with honest from-prices. Filters refine in-page only." "Start here if you know roughly what you want: pick a destination silo for depth, a style hub for curation, or a duration below for structure. Everything is private and customisable; from-prices are real mid-range baselines for two travelers, not teaser rates." "MIG" @(
 @("Tanzania packages","/tanzania-safari/packages/","2-14 days, north and south."),
 @("Kenya packages","/kenya-safari/packages/","3-10 days plus beach."),
 @("Uganda packages","/uganda-safari/packages/","3-14 days, permits handled."),
 @("Botswana packages","/botswana-safari/packages/","5-12 days fly-in."),
 @("Namibia itineraries","/namibia-safari/packages/","7-14 days guided/self-drive."),
 @("South Africa packages","/south-africa-safari/packages/","5-14 days bush-city-coast.")) @(
 @("/tanzania-safari/5-day-tanzania-safari/","5-Day Tanzania","Classic","From `$2,150","The essential circuit."),
 @("/kenya-safari/3-day-masai-mara-safari/","3-Day Mara Express","Fly-in","From `$1,450","Maximum Mara, minimum transit."),
 @("/uganda-safari/3-day-gorilla-trekking/","3-Day Gorilla Trek","Primates","From `$2,650","Permits secured first.")) @(
 @("3-5 days","Express taste","From `$1,450"),
 @("6-8 days","The sweet spot","From `$2,900"),
 @("9-14 days","Grand + beach/trek","From `$4,600")) @(
 @{"q"="Are from-prices real?";"a"="Yes - mid-range baselines for two travelers in green season, park fees included. Peak season and luxury tiers quote higher, line by line."},
 @{"q"="Can packages combine countries?";"a"="Routinely - Kenya plus Tanzania, safari plus Zanzibar or Diani, Uganda plus Kenya. See combination safaris."}) '<a href="/kenya-tanzania-safari/">KE+TZ combos</a> | <a href="/africa-safari-from-zanzibar/">From Zanzibar</a> | <a href="/travel-guide/african-safari-cost/">Cost guide</a>'

New-Global "kenya-tanzania-safari" "Kenya & Tanzania Combined Safaris: Mara + Serengeti (7-14 Days)" "The ultimate East Africa loop - Masai Mara and Serengeti in one trip, plus crater, Amboseli and Zanzibar options." "One ecosystem, two countries, zero repeats: the Mara's crossing density plus the Serengeti's scale, the crater's Big Five day, optionally Amboseli's tuskers and a Zanzibar finale. Border crossings at Isebania or Namanga are routine with our drivers handling both sides - or fly across and skip the lines." "MIG" @(
 @("7-8 day combos","/kenya-tanzania-safari/7-day-kenya-tanzania/","Mara + Serengeti + crater."),
 @("10-day combos","/kenya-tanzania-safari/10-day-kenya-tanzania/","Add Amboseli or extra Migration days."),
 @("12-14 day grands","/kenya-tanzania-safari/12-day-kenya-tanzania/","Plus Zanzibar or Samburu.")) @(
 @("/kenya-tanzania-safari/7-day-kenya-tanzania/","7-Day Kenya & Tanzania","Mara + Serengeti","From `$3,900","The essential two-country week."),
 @("/kenya-tanzania-safari/10-day-kenya-tanzania/","10-Day Kenya & Tanzania","Adds Amboseli","From `$5,200","Tuskers plus crossings."),
 @("/kenya-tanzania-safari/12-day-kenya-tanzania/","12-Day + Zanzibar","Bush + beach","From `$6,800","Finish on sand.")) @(
 @("7-8 days","Mara + Serengeti + crater","From `$3,900"),
 @("10 days","Add Amboseli or Tarangire","From `$5,200"),
 @("12-14 days","Add Zanzibar or Samburu","From `$6,800")) @(
 @{"q"="Is combining Kenya and Tanzania worth it?";"a"="For Migration season, yes - you follow herds across the border. Off-season, going deep in one country usually beats splitting."},
 @{"q"="How do border crossings work?";"a"="Isebania (Mara-Serengeti) or Namanga (Amboseli-Arusha). Visas per country; our teams handle both sides."},
 @{"q"="Road or fly between countries?";"a"="Road for scenery and cost on the Mara-Serengeti leg; fly when adding Zanzibar or saving a day."}) '<a href="/tanzania-safari/">Tanzania</a> | <a href="/kenya-safari/">Kenya</a> | <a href="/blog/serengeti-vs-masai-mara/">Serengeti vs Mara</a>'

New-Global "africa-safari-from-zanzibar" "Safari from Zanzibar: Day Trips to 7-Day Fly-In Safaris" "On Zanzibar and want safari? Fly to the mainland for Mikumi, Nyerere, Serengeti and more - logistics explained honestly." "Zanzibar is an island: every mainland safari starts with a flight, never a road transfer. Day trips reach Mikumi and Nyerere; two-plus days open the full north (Serengeti, crater, Tarangire). Multi-country extensions to Kenya run via Arusha or Nairobi links. Below: the Tanzania cluster in full, plus honest flight times and what each duration unlocks." "BEACH" @(
 @("Tanzania from Zanzibar hub","/tanzania-safari-from-zanzibar/","1-7 day packages plus park combos."),
 @("3-day fly-in safari","/tanzania-safari-from-zanzibar/3-day-safari-from-zanzibar/","Nyerere or Mikumi long weekend."),
 @("5-day fly-in safari","/tanzania-safari-from-zanzibar/5-day-safari-from-zanzibar/","Serengeti + crater."),
 @("Serengeti from Zanzibar","/tanzania-safari-from-zanzibar/safari-zanzibar-to-serengeti/","Logistics and timing.")) @(
 @("/tanzania-safari-from-zanzibar/2-day-safari-from-zanzibar/","2-Day from Zanzibar","Mikumi/Nyerere","From `$1,150","The classic add-on."),
 @("/tanzania-safari-from-zanzibar/5-day-safari-from-zanzibar/","5-Day from Zanzibar","Serengeti + crater","From `$2,900","The real northern circuit."),
 @("/tanzania-safari-from-zanzibar/1-day-safari-from-zanzibar/","1-Day from Zanzibar","Mikumi","From `$550","Dawn-to-dusk taste.")) @(
 @("1 day","Mikumi or Nyerere day trip","From `$550"),
 @("2-3 days","Nyerere/Mikumi + boat + walk","From `$1,150"),
 @("4-7 days","Full northern circuit","From `$2,400")) @(
 @{"q"="Can you drive from Zanzibar to safari?";"a"="No - it is an island. All mainland safaris begin with a 30 to 80-minute flight. Anyone selling a road trip from Zanzibar is confused."},
 @{"q"="Which parks work as day trips?";"a"="Mikumi and Nyerere only - early flight out, game drive, evening flight back. Serengeti needs at least two days."},
 @{"q"="Should we safari before or after beach?";"a"="Safari first, beach after. You will appreciate the rest more, and flight delays risk less."}) '<a href="/tanzania-safari-from-zanzibar/">TZ from Zanzibar hub</a> | <a href="/tanzania-safari/">Tanzania</a> | <a href="/accommodation/tanzania/">Stays</a>'

New-Global "africa-gorilla-safaris" "Africa Gorilla Safaris: Uganda & Rwanda Trekking Compared" "Mountain gorilla trekking in Uganda and Rwanda - permits, fitness, costs and primate-plus-savanna combinations." "Uganda permits cost 800 dollars, Rwanda 1,500 - same species, different logistics. Uganda pairs gorillas with chimps and savanna in one trip; Rwanda suits short premium add-ons from Kigali. We secure permits before lodges, brief fitness honestly, and insist on porters." "UG" @(
 @("Uganda gorilla trekking","/uganda-gorilla-trekking/","Bwindi + Mgahinga, permits handled."),
 @("Uganda wildlife combos","/uganda-wildlife-safari/","Chimps, lions, Nile falls."),
 @("3-day fly-in trek","/uganda-safari/3-day-gorilla-trekking/","Permits-first long weekend."),
 @("7-day primates + savanna","/uganda-safari/7-day-uganda-safari/","The complete week.")) @(
 @("/uganda-safari/3-day-gorilla-trekking/","3-Day Gorilla Trek","Fly-in","From `$2,650","Permits included."),
 @("/uganda-safari/7-day-uganda-safari/","7-Day Primates + Wildlife","Chimps + lions + gorillas","From `$4,100","Uganda entire."),
 @("/uganda-safari/10-day-uganda-safari/","10-Day Grand Uganda","Adds Murchison","From `$5,800","Everything, slowly.")) @(
 @("3 days","Gorillas only, fly-in","From `$2,650"),
 @("5-7 days","Plus chimps and savanna","From `$3,200"),
 @("10-14 days","Grand tour","From `$5,800")) @(
 @{"q"="Uganda or Rwanda for gorillas?";"a"="Uganda for cost and combinations; Rwanda for speed and luxury lodges. Most first-timers choose Uganda."},
 @{"q"="How fit must we be?";"a"="Moderate - one to five hours on steep slopes. Porters carry packs and steady you; take one."},
 @{"q"="Minimum age?";"a"="Fifteen, strictly enforced in both countries."}) '<a href="/activities/gorilla-trekking/">Trekking guide</a> | <a href="/national-parks/bwindi/">Bwindi</a> | <a href="/uganda-safari/">Uganda</a>'

New-Global "africa-photographic-safaris" "Africa Photographic Safaris: Hides, Light & Low-Mileage Days" "Serious photography travel: private vehicles, photographer-guides, water hides and unhurried single-sighting days." "Photography safaris trade mileage for light: one sighting held through golden hour beats five rushed stops. Private vehicles position for sun angle; beanbags and door configurations replace tripods; water-level hides in Mashatu and Kwara put lenses at eye level. Tell us your kit and targets - we match concession, season and guide." "TZ" @(
 @("Tanzania photographic","/tanzania-photographic-safari/","Calving and crossings."),
 @("Kenya photographic","/kenya-photographic-safari/","Mara conservancies off-road."),
 @("Botswana photographic","/botswana-safari/8-day-botswana-safari/","Hides and water light.")) @(
 @("/tanzania-photographic-safari/8-day-photographic-serengeti/","8-Day Photographic Serengeti","Hides + herds","From `$5,400","Low-mileage, light-chasing."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya Photo Base","Private vehicle","From `$3,100","Add photographer-guide."),
 @("/botswana-safari/8-day-botswana-safari/","8-Day Botswana Photo","Water hides","From `$7,400","Eye-level elephants.")) @(
 @("Vehicle + guide","Private, beanbags, charging","Essential"),
 @("Hides","Mashatu, Kwara water levels","Seasonal"),
 @("Full photo safari","Guide-photographer, 7+ days","On request")) @(
 @{"q"="What lens for a first photo safari?";"a"="A 100-400mm zoom covers ninety percent. Add a wide body for landscapes and camp life."},
 @{"q"="Which season photographs best?";"a"="Calving season for action and babies; crossings for drama; green season for skies and birds."}) '<a href="/activities/photographic-safaris/">Photo activity guide</a> | <a href="/travel-guide/photography/">Photography guide</a>'

New-Global "africa-budget-safaris" "Budget African Safaris: Real Value Without Regret (2026/27)" "Genuine ways to cut safari cost - green season, camping, groups, self-drive - and what never to cut." "Budget safaris work when you cut beds and season, never guide quality or Migration positioning. Green-season camping safaris, join-in departures, self-drive Namibia and South Africa, and four-plus travelers splitting a private vehicle all move the needle 20 to 40 percent. Below: honest value routes by country." "NA" @(
 @("Tanzania budget","/tanzania-budget-safari/","Camping northern circuit."),
 @("Namibia self-drive","/namibia-self-drive/","Freedom plus value."),
 @("South Africa value","/south-africa-safari/packages/","Self-drive Kruger options.")) @(
 @("/tanzania-budget-safari/6-day-budget-camping/","6-Day Budget Camping","Camping","From `$1,950","Full circuit, canvas."),
 @("/namibia-safari/7-day-namibia-safari/","7-Day Namibia Self-Drive","Self-drive","From `$2,200","Briefed 4x4 routes."),
 @("/tanzania-safari/4-day-tanzania-safari/","4-Day Value Safari","Lodges","From `$1,650","Short but complete.")) @(
 @("Camping safari","Tanzania/Kenya, green season","From `$300/day"),
 @("Self-drive","Namibia/SA","From `$250/day"),
 @("Join-in group","Set departures","On request")) @(
 @{"q"="What should we never cut?";"a"="Guide quality, Migration-zone camp location and insurance. Cut thread counts and travel dates instead."},
 @{"q"="Is green season actually good?";"a"="Yes - babies, birds, dramatic skies, empty sightings. April-May long rains are the only genuinely limiting window."}) '<a href="/travel-guide/african-safari-cost/">Cost guide</a> | <a href="/namibia-self-drive/">Self-drive</a>'
