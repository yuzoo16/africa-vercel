# gen-pkgs.ps1 — package page builder (deep template). Pure ASCII.
. "$PSScriptRoot/gen-common.ps1"

$PL = @{
 "tanzania-safari"="/tanzania-safari/|Tanzania Safari";"kenya-safari"="/kenya-safari/|Kenya Safari";
 "uganda-safari"="/uganda-safari/|Uganda Safari";"botswana-safari"="/botswana-safari/|Botswana Safari";
 "namibia-safari"="/namibia-safari/|Namibia Safari";"south-africa-safari"="/south-africa-safari/|South Africa Safari";
 "ethiopia-safari"="/ethiopia-safari/|Ethiopia Safari";"tanzania-safari-from-zanzibar"="/tanzania-safari-from-zanzibar/|Safari from Zanzibar";
 "tanzania-migration-safari"="/tanzania-migration-safari/|Tanzania Migration Safari";"southern-tanzania-safari"="/southern-tanzania-safari/|Southern Tanzania Safari";
 "tanzania-honeymoon-safari"="/tanzania-honeymoon-safari/|Tanzania Honeymoon Safari";"tanzania-luxury-safari"="/tanzania-luxury-safari/|Tanzania Luxury Safari";
 "tanzania-family-safari"="/tanzania-family-safari/|Tanzania Family Safari";"tanzania-photographic-safari"="/tanzania-photographic-safari/|Tanzania Photographic Safari";
 "tanzania-budget-safari"="/tanzania-budget-safari/|Tanzania Budget Safari";"tanzania-beach-and-safari"="/tanzania-beach-and-safari/|Tanzania Beach and Safari";
 "tanzania-group-safari"="/tanzania-group-safari/|Tanzania Group Safari";
 "kenya-safari-from-nairobi"="/kenya-safari-from-nairobi/|Kenya Safari from Nairobi";"masai-mara-safari"="/masai-mara-safari/|Masai Mara Safari";
 "kenya-honeymoon-safari"="/kenya-honeymoon-safari/|Kenya Honeymoon Safari";"kenya-luxury-safari"="/kenya-luxury-safari/|Kenya Luxury Safari";
 "kenya-family-safari"="/kenya-family-safari/|Kenya Family Safari";"kenya-beach-safari"="/kenya-beach-safari/|Kenya Beach and Safari";
 "kenya-tanzania-safari"="/kenya-tanzania-safari/|Kenya and Tanzania Safari";"uganda-gorilla-trekking"="/uganda-gorilla-trekking/|Uganda Gorilla Trekking";
 "uganda-wildlife-safari"="/uganda-wildlife-safari/|Uganda Wildlife Safari"}
$STYLEHUB = @{honeymoon="/africa-honeymoon-safaris/|Africa Honeymoon Safaris";family="/africa-family-safaris/|Africa Family Safaris";
 luxury="/africa-luxury-safaris/|Africa Luxury Safaris";migration="/africa-migration-safaris/|Africa Migration Safaris";
 photographic="/africa-photographic-safaris/|Africa Photographic Safaris";private="/private-african-safaris/|Private African Safaris";
 "tailor-made"="/tailor-made-african-safaris/|Tailor-Made Safaris";budget="/africa-budget-safaris/|Budget African Safaris";
 gorilla="/africa-gorilla-safaris/|Africa Gorilla Safaris";beach="/africa-safari-from-zanzibar/|Safari from Zanzibar";
 combo="/kenya-tanzania-safari/|Kenya and Tanzania Safari";trekking="/uganda-gorilla-trekking/|Uganda Gorilla Trekking";
 classic="/africa-safari-packages/|Africa Safari Packages";group="/group-african-safaris/|Group African Safaris"}
$SEASON = @{Tanzania="June-October dry season and January-March calving; camp zone follows the herds.";
 Kenya="July-October Migration herds; January-March clear skies and Kilimanjaro views.";
 Uganda="June-September and December-February dry windows for firm trekking trails.";
 Botswana="May-October dry season; Delta flood peaks June-August.";
 Namibia="May-October dry season for Etosha; dunes year-round.";
 "South Africa"="May-September for game; November-March for Cape Town.";
 Ethiopia="October-March dry season.";
 "Kenya and Tanzania"="July-October for cross-border herds; January-March for calving plus Mara cats."}
$AN = @{
 "tz-general"="Mainland northern-circuit itinerary from Arusha: Tarangire, Ngorongoro and the Serengeti in cooker-cutter-free order - camp zone set by your month, not a template.";
 "znz"="Zanzibar-origin fly-in safari: scheduled island-mainland flights both ends, guide waiting at arrivals, beach hotel holding your big bags. Safari first, sand after.";
 "znz-tarangire"="Zanzibar to Tarangire runs via Arusha (morning flight, two-hour drive): elephants and baobabs by afternoon. The most wildlife per hour of any Zanzibar add-on.";
 "znz-serengeti"="Zanzibar to the Serengeti flies direct to Seronera strips or via Arusha: big cats and Migration herds with zero mainland overnights wasted in transit towns.";
 "znz-ngorongoro"="Zanzibar to Ngorongoro pairs an Arusha flight with a highlands overnight for a gate-open crater descent - the densest Big Five day in Africa, from the beach.";
 "znz-nyerere"="Zanzibar to Nyerere is the shortest full safari from the island: 30-minute hop, river boats, game drives and walking country in Africa's largest reserve.";
 "znz-mikumi"="Zanzibar to Mikumi is the classic beach-plus-bush add-on: 30-minute flight, lions and elephants by lunch, back for sunset cocktails.";
 "mig-tz"="Season-placed Migration safari camping inside the herd zone of your month - mobile camps near the action, full-day picnic drives, crossings or calving focus.";
 "south-mikumi"="Dar es Salaam-gateway southern taste: road or short hop to Mikumi's lions, elephants and hippo pools. Ideal bolted to beach days.";
 "south-nyerere"="Nyerere immersion: Rufiji boats, 4x4 drives and walking safaris in Africa's largest reserve - wild dogs possible, crowds impossible.";
 "south-ruaha"="Fly-in Ruaha expedition: huge lion prides, wild-dog packs and 570 bird species with a fraction of northern visitors.";
 "south-grand"="The complete wild south: Ruaha plus Nyerere by light aircraft - predators, rivers, walks and boats in one remote arc.";
 "tz-honey"="Honeymoon-paced northern circuit: private vehicle, plunge-pool suites where they count, bush dinner arranged, and beach-ready finish options.";
 "tz-lux"="Fly-in luxury across the north: light aircraft between camps, Migration-zone positioning, crater-rim suite, Zanzibar royalty on the long format.";
 "tz-fam"="Kid-paced northern circuit: pools at every stop, shortened drive days, private vehicle for nap-and-snack flexibility.";
 "tz-photo"="Camera-first Serengeti: private vehicle, extra seat row, beanbags, full-day light-chasing drives in calving or crossing season.";
 "tz-budget"="Public-campsite camping circuit: same parks, same drives, same crater descent - canvas, cook crew and green-season rates halving bed costs.";
 "tz-beach"="Bush-to-beach classic: northern icons then a direct Serengeti-Zanzibar flight. No backtracking, no wasted nights.";
 "group"="Join-in group departure on set dates: shared 4x4 and guide, per-seat pricing, small groups of four to seven - the social, value way to safari.";
 "ke-nairobi"="Nairobi-gateway loop mixing road and fly-in legs: Rift Valley lakes, Amboseli tuskers and Mara depth in one coherent circuit.";
 "mara"="Mara-depth itinerary: minimum three nights in the reserve or conservancy, river time in season, full-day picnic drives for crossings.";
 "ke-amboseli"="Amboseli-focused loop: great-tusker elephants and dawn Kilimanjaro views, paired with Rift lakes or the Mara.";
 "ke-honey"="Honeymoon Kenya: conservancy tent seclusion plus optional Diani finish, balloon dawns and private sundowners.";
 "ke-lux"="Conservancy-level Kenya: off-road rights, night drives, walking and helicopter options from a Mara North or Naboisho base.";
 "ke-fam"="Family Kenya: Naivasha boats and walks breaking up drive days, Mara by air, pools throughout.";
 "ke-beach"="Kenya bush-to-beach: classic loop then direct Mara-to-Diani flights - no Nairobi backtrack.";
 "ketz"="Two-country East Africa: Mara plus Serengeti with Isebania/Namanga border handling, crater included from seven days, Amboseli and Zanzibar on longer formats.";
 "ug-gorilla"="Permit-first gorilla itinerary: availability checked before lodges, porter arranged, fitness briefing honest, forest finale done right.";
 "ug-wild"="Grand Uganda arc: rhinos, falls, chimps, lions, channel boats and gorillas - every ecosystem in one trip.";
 "bw"="Fly-in Botswana circuit: light-aircraft hops between water, predator and riverfront camps - low beds, huge concessions, no crowds.";
 "na"="Grand Namibia loop: dunes, coast, Damaraland rhinos and Etosha waterholes at self-drive or guided pace.";
 "sa"="Bush-city-coast South Africa: Sabi Sand leopards plus Cape Town, winelands and optional Garden Route.";
 "et"="Historic-and-highland Ethiopia: rock churches, castles, Simien trekking and valley cultures matched to current conditions."}
$TREKPARKS = @("Bwindi","Kibale","Simien Mountains","Omo Valley","Udzungwa")

function DaySegs($park,$blurb,$phase,$isTrek){
  if($isTrek){
    return @(
     @{"h"="Morning";"t"="Briefing and trek: meet trackers, draw walking sticks, hire a porter, and hike forest trails to the habituated group."},
     @{"h"="Midday";"t"="The wildlife hour plus packed lunch on the trail: one regulated hour with the group, then the walk out."},
     @{"h"="Afternoon";"t"="Return to the lodge: hot lunch or late picnic, rest, optional community walk. "+$blurb},
     @{"h"="Evening";"t"="Certificates, hot shower, early dinner and an early night - trek days start before dawn."}
    )
  }
  $m="Early departure for a dawn game drive when predators are still active, returning for brunch."
  if($phase -eq "first"){$m="Meet your guide and transfer into the park with a game drive en route - first sightings before lunch."}
  if($phase -eq "last"){$m="Sunrise game drive and bush breakfast, then the onward transfer."}
  return @(
   @{"h"="Morning";"t"=$m},
   @{"h"="Midday";"t"="Picnic lunch at a designated site or lodge lunch, then rest through the midday heat while wildlife dozes."},
   @{"h"="Afternoon";"t"="Afternoon game drive in "+$park+": "+$blurb},
   @{"h"="Evening";"t"="Sundowner at a scenic stop, dinner and overnight at the lodge or camp."}
  )
}
function Route($parksStr,$days,$gate,$mode,$imgk){
  $parks=$parksStr -split "\|"
  $items=@()
  if($days -eq 1){
    $p=$parks[0]; $pi=$PIMG[$p]; if(-not $pi){$pi=$imgk}
    $im=$IMG[$pi]
    $items+=@{"t"="Day 1 - "+$p+" day trip";"img"=$im[0];"alt"=$im[1];"segs"=@(
     @{"h"="Morning";"t"="Early flight Zanzibar to the mainland and straight into a full-day game drive with picnic lunch."},
     @{"h"="Midday";"t"="Picnic at a designated site inside the park; rest while the guide repositions for afternoon light."},
     @{"h"="Afternoon";"t"="Afternoon drive: "+$PB[$p]},
     @{"h"="Evening";"t"="Transfer to the airstrip for the evening flight back to Zanzibar."})}
    return $items
  }
  if($mode -eq "znz"){
    $p0=$parks[0]; $pi=$PIMG[$p0]; if(-not $pi){$pi=$imgk}; $im=$IMG[$pi]
    $items+=@{"t"="Day 1 - Fly Zanzibar to "+$gate;"img"=$im[0];"alt"=$im[1];"segs"=@(
     @{"h"="Morning";"t"="Scheduled flight Zanzibar to "+$gate+"; meet your private guide at arrivals. Island logistics handled: beach hotel stores big bags, soft duffel only (15-20kg)."},
     @{"h"="Midday";"t"="Transfer into safari with lunch en route."},
     @{"h"="Afternoon";"t"="Afternoon game drive in "+$p0+". "+$PB[$p0]},
     @{"h"="Evening";"t"="Dinner and overnight near the park gate."})}
  } else {
    $p0=$parks[0]; $pi=$PIMG[$p0]; if(-not $pi){$pi=$imgk}; $im=$IMG[$pi]
    $items+=@{"t"="Day 1 - Arrive "+$gate;"img"=$im[0];"alt"=$im[1];"segs"=@(
     @{"h"="Morning";"t"="Land at "+$gate+"; meet your private guide for a full safari briefing."},
     @{"h"="Midday";"t"="Lunch and gear check; rest after the flight."},
     @{"h"="Afternoon";"t"="Introductory game drive in "+$p0+" where routing allows, else lodge pool and early rest."},
     @{"h"="Evening";"t"="Dinner and overnight near "+$gate+". (Add a pre-night after long-haul arrivals.)"})}
  }
  $midN=$days-2; $seq=@()
  if($midN -ge 1){
    if($midN -le $parks.Count){ $seq=$parks[0..($midN-1)] }
    else { $seq=@()+$parks; for($i=$parks.Count;$i -lt $midN;$i++){ $seq+=$parks[-1] } }
    $prev=$null
    for($i=0;$i -lt $seq.Count;$i++){
      $p=$seq[$i]; $dn=$i+2; $bl=$PB[$p]; if(-not $bl){$bl="Full-day exploration with your private guide."}
      $isT=$TREKPARKS -contains $p
      $phase="mid"; if($dn -eq $days-1 -and $midN -eq 1){$phase="mid"}
      $tr=""; if($prev -and $prev -ne $p){ $t=$TT["$prev|$p"]; if(-not $t){$t="a scenic road transfer"}; $tr=" Transfer from "+$prev+" ("+$t+")." }
      $pi=$PIMG[$p]; if(-not $pi){$pi=$imgk}; $im=$IMG[$pi]
      $segs=DaySegs $p ($bl+$tr) $phase $isT
      if($i -gt 0 -and $seq[$i-1] -eq $p){ $segs[2].t="Second full day for deeper territories with picnic lunch out: "+$bl }
      $items+=@{"t"="Day "+$dn+" - "+$p;"img"=$im[0];"alt"=$im[1];"segs"=$segs}
      $prev=$p
    }
    $prev=$seq[-1]
  } else { $prev=$parks[0] }
  if($mode -eq "znz"){
    $pi=$PIMG[$prev]; if(-not $pi){$pi=$imgk}; $im=$IMG[$pi]
    $items+=@{"t"="Day "+$days+" - Fly back to Zanzibar";"img"=$im[0];"alt"=$im[1];"segs"=@(
     @{"h"="Morning";"t"="Sunrise game drive around "+$prev+" and bush breakfast."},
     @{"h"="Midday";"t"="Transfer to the airstrip for the scheduled flight to Zanzibar."},
     @{"h"="Afternoon";"t"="Beach transfer on arrival - sand by sunset."},
     @{"h"="Evening";"t"="Overnight at your Zanzibar hotel (booked separately or in your proposal)."})}
  } else {
    $last=$prev; if(-not $last){$last=$parks[-1]}
    $pi=$PIMG[$last]; if(-not $pi){$pi=$imgk}; $im=$IMG[$pi]
    $items+=@{"t"="Day "+$days+" - Depart";"img"=$im[0];"alt"=$im[1];"segs"=@(
     @{"h"="Morning";"t"="Final sunrise activity around "+$last+" with bush breakfast."},
     @{"h"="Midday";"t"="Brunch, then transfer to "+$gate+" for onward connections."},
     @{"h"="Afternoon";"t"="Day rooms available on late flights; souvenir stop if time allows."},
     @{"h"="Evening";"t"="End of safari services at "+$gate+" airport."})}
  }
  return $items
}
function Duration-Line($days){
  if($days -le 1){return "A dawn-to-dusk strike: maximum wildlife per hour, honest about what fits."}
  if($days -eq 2){return "A long-weekend format: tight, well-paced, and clear about what it skips."}
  if($days -le 4){return "A focused taste: one region done properly rather than three rushed."}
  if($days -le 6){return "The classic length for one region - full days without filler."}
  if($days -le 8){return "The sweet spot: depth plus a buffer day for weather, herds and rest."}
  if($days -le 11){return "Grand-tour depth: two regions or bush-plus-beach without rushing."}
  return "The ultimate unhurried format: everything, slowly, with contingency days built in."
}
function New-Package($d){
  $dir=$d.dir;$slug=$d.slug;$title=$d.title;$country=$d.country;$days=$d.days
  $gate=$CGATE[$country]; $imgk=$d.img; if(-not $imgk){$imgk=$CIMG[$country]}
  $im=$IMG[$imgk]
  $pr=Price-Pair $country $days $d.mult $d.flat
  $gstr=Fmt-Money $pr[0]; $pstr=Fmt-Money $pr[1]
  if($d.price){ $gstr=$d.price }
  $pl=$PL[$dir].Split("|")
  $styles=$d.styles -split ","
  $shub=$STYLEHUB[$styles[0]].Split("|")
  $st=$styles -join ", "
  $route=Route $d.parks $days $gate $d.mode $imgk
  $itinh=""; $open=" open"
  foreach($r in $route){
    $thumb=$r.img -replace "w=1800","w=900"
    $segs=""; foreach($s in $r.segs){ $segs+="<p><strong>$($s.h):</strong> $($s.t)</p>" }
    $itinh+="<details$open><summary>$($r.t)</summary><img loading=`"lazy`" decoding=`"async`" width=`"900`" height=`"560`" src=`"$thumb`" alt=`"$($r.alt)`" style=`"border-radius:10px;margin:10px 0`">$segs</details>"; $open=""
  }
  $parks=$d.parks -split "\|"
  $parklinks=@(); foreach($p in $parks){ if($PNPARK[$p]){$parklinks+="<a href=`"$($PNPARK[$p])`">$p</a>"} }
  $routeNote="Route: "+($parks -join " - ")+" over "+$days+" days."
  $overview=$AN[$d.angle]+" "+(Duration-Line $days)+" "+$routeNote+" Season logic: "+$SEASON[$country]
  $pace=""; if($parks.Count -ge $days -and $days -gt 1){$pace=" <strong>Pace note:</strong> fast by design - each stop earns its night; ask for the slower variant if you prefer two-night stays."}
  $hl="<li><strong>Private throughout:</strong> own vehicle and guide, departures on your dates.</li><li><strong>Parks covered:</strong> "+($parks -join ", ")+".</li><li><strong>Season-smart:</strong> camp zone set by your month, not a template.</li><li><strong>Honest pricing:</strong> park fees and permits line-itemed in every quote.</li>"
  $best=$BESTFOR[$styles[0]]; if(-not $best){$best=$BESTFOR["classic"]}
  $faqs=Faq-Pick ($days*7+$dir.Length) 9
  $cous=@(); foreach($c in ($d.cousins -split ";")){ $u=$c.Split("|"); $cous+="<a href=`"$($u[0])`">$($u[1])</a>" }
  $body=Crumb @('<a href="/">Home</a>','<a href="'+$pl[0]+'">'+$pl[1]+'</a>',$title)
  $body+="<div class=`"hero`"><img class=`"bg`" src=`"$($im[0])`" alt=`"$($im[1])`" fetchpriority=`"high`"><div class=`"hero-in`"><p class=`"eyebrow`">$country | $days days | $st</p><h1>$($d.h1)</h1><p class=`"sub`">$($d.tag)</p><div class=`"hero-ctas`"><a class=`"btn btn-g`" href=`"/request-proposal/`">Request this safari</a><a class=`"btn btn-wa`" data-wa data-wa-pkg=`"$title`" href=`"#`">WhatsApp</a><a class=`"btn btn-o`" style=`"border-color:#fff;color:#fff`" href=`"/request-proposal/`">Customize</a></div><div class=`"hero-meta`"><span class=`"pill`">$days days</span><span class=`"pill`">From $gstr pp</span><span class=`"pill`">Private</span><span class=`"pill`">Start/end: $gate</span></div></div></div>"
  $body+="<section class=`"block`"><div class=`"wrap`"><div class=`"facts`"><div><b>Duration</b>$days days</div><div><b>Style</b>$st</div><div><b>Starts</b>$gate</div><div><b>Ends</b>$gate</div><div><b>Green season from</b>$gstr pp</div><div><b>Peak season from</b>$pstr pp</div></div>"
  $body+="<h2>Overview</h2><p class=`"lead`">$overview</p><p>$pace</p>"
  $body+="<h2>Highlights</h2><ul>$hl</ul>"
  $body+="<h2>Day-by-day itinerary</h2><div class=`"itin`">$itinh</div>"
  $body+="<h2>Accommodation</h2><p>Hand-picked lodges and tented camps matched to your tier - mid-range comfort or luxury suites, always positioned for short game-drive starts. Family rooms, honeymoon suites and triple options on request.</p>"
  $body+="<h2>Safari vehicle and guide</h2><p>Extended 4x4 Land Cruiser with pop-up roof, fridge, charging ports and window seats for all. Your English-speaking driver-guide averages a decade in these parks and is assigned by specialty - Migration positioning, photography, birding or family pacing.</p>"
  $body+="<h2>Who this safari is best for</h2><p>$best</p>"
  $body+="<h2>Pricing</h2><table class=`"cmp`"><tr><th>Season</th><th>Per person (2 travelers)</th></tr><tr><td>Green season</td><td>from $gstr</td></tr><tr><td>Peak season</td><td>from $pstr</td></tr></table>"
  $body+="<h2>What is included and excluded</h2><p><strong>Included:</strong> private vehicle and driver-guide, accommodation, park and concession fees, listed transfers, most meals. <strong>Excluded:</strong> international flights, visas, travel insurance (required), premium drinks, tips. <strong>Upgrades:</strong> balloon flight, extra nights, luxury camp tier, beach or trekking extensions.</p>"
  if($parklinks.Count -gt 0){ $body+="<h2>Parks and guides</h2><p>"+($parklinks -join " | ")+"</p>" }
  $body+="<h2>Related safaris</h2><p>"+($cous -join " | ")+" | <a href=`"$($pl[0])`">$($pl[1])</a> | <a href=`"$($shub[0])`">$($shub[1])</a></p>"
  $body+=(Faq-List $faqs)+(CTA-Band "Request this safari" "Your dates, your camp tier - reply within 24 hours." $title)+"</div></section></main>"
  $canon="https://www.adventuresafariafrica.com/$dir/$slug/"
  $tripSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"TouristTrip","name":"'+$title+'","description":"'+$d.tag+'","touristType":"Private safari"}</script>'
  $crumbSchema='<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Home","item":"https://www.adventuresafariafrica.com/"},{"@type":"ListItem","position":2,"name":"'+$pl[1]+'","item":"https://www.adventuresafariafrica.com'+$pl[0]+'"},{"@type":"ListItem","position":3,"name":"'+$title+'","item":"'+$canon+'"}]}</script>'
  $html=Shell $title "$($d.h1). $routeNote From $gstr per person." $canon $body ($tripSchema+$crumbSchema+(Faq-Schema $faqs))
  New-Item -ItemType Directory -Path "$dir/$slug" -Force | Out-Null
  $html | Out-File -FilePath "$dir/$slug/index.html" -Encoding utf8
  $rec=@{name=$title;slug="$dir/$slug";country=$country;region=$pl[1];startingPoint=$gate;endingPoint=$gate;duration_days=$days;
    safariType=$styles[0];safariCategory=$pl[1];parks=$parks;accommodationLevel="mid-range to luxury";price_from=$pr[0];currency="USD";
    imgkey=$imgk;excerpt=$d.tag;overview=$overview;relatedHubs=@($pl[0],$shub[0]);seoTitle=$title;metaDescription="$($d.h1). $routeNote";
    canonical=$canon;published=$true}
  $DB.Add($rec) | Out-Null
}
