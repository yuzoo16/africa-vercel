# gen-hubs2.ps1 — East/Southern Africa hubs, Group hubs. Pure ASCII.
. "$PSScriptRoot/gen-hubs.ps1" | Out-Null

New-Global "east-africa-safari" "East Africa Safari: Tanzania, Kenya, Uganda & Ethiopia (2026/27)" "East Africa safaris - Migration herds, gorilla forests, Kilimanjaro and the Indian Ocean coast in one region." "East Africa holds the densest concentration of classic safari experiences on earth: the Serengeti-Mara Migration ecosystem, the Ngorongoro Crater, half the world's mountain gorillas, Kilimanjaro, and Zanzibar and Diani beaches a short flight away. Tanzania and Kenya anchor big-game viewing, Uganda adds primates, Ethiopia adds culture and highlands. Combine countries freely - border logistics are routine." "MIG" @(
 @("Tanzania","/tanzania-safari/","Serengeti, crater, Kilimanjaro, Zanzibar - the complete safari."),
 @("Kenya","/kenya-safari/","Mara, Amboseli, lakes - the easiest fly-in safari."),
 @("Uganda","/uganda-safari/","Gorillas, chimps and savanna at half Rwanda's permit price."),
 @("Ethiopia","/ethiopia-safari/","Simien trekking, Lalibela, Omo cultures."),
 @("Kenya + Tanzania","/kenya-tanzania-safari/","Mara plus Serengeti in one trip."),
 @("Great Migration","/great-migration/","Herd timing, crossings and calving.")) @(
 @("/tanzania-safari/7-day-tanzania-safari/","7-Day Tanzania Safari","7 days | Migration","From $3,450","The most-requested East Africa week."),
 @("/kenya-safari/7-day-kenya-safari/","7-Day Kenya Safari","7 days | Classic","From $3,100","Mara, Amboseli and lakes."),
 @("/uganda-safari/7-day-uganda-safari/","7-Day Uganda Safari","7 days | Primates","From $4,100","Chimps, lions, gorillas."),
 @("/kenya-tanzania-safari/10-day-kenya-tanzania/","10-Day Kenya + Tanzania","10 days | Combo","From $5,200","Two countries, zero repeats.")) @(
 @("One country, 7 days","Tanzania or Kenya classic","From $3,100"),
 @("Primates + savanna","Uganda 7-10 days","From $4,100"),
 @("Two countries, 10-14 days","Kenya + Tanzania","From $5,200"),
 @("Trek + safari","Kilimanjaro + 5-day safari","From $5,800")) @(
 @{"q"="Which East African country should we pick?";"a"="Tanzania for the complete big-game circuit plus Zanzibar; Kenya for easier logistics and beach pairing; Uganda for gorillas and chimps; Ethiopia for culture and trekking. First-timers default to Tanzania or Kenya."},
 @{"q"="Can we combine Kenya and Tanzania?";"a"="Yes - the Mara-Serengeti ecosystem straddles the border. Isebania and Namanga crossings are routine with our drivers handling both sides, or fly across to save a day."},
 @{"q"="How much does East Africa cost?";"a"="Mid-range private circuits run 350 to 600 dollars per person per day; Uganda adds 800-dollar gorilla permits; Kilimanjaro climbs run 2,800 to 5,500. See the cost guide for line items."}) '<a href="/tanzania-safari/">Tanzania</a> | <a href="/kenya-safari/">Kenya</a> | <a href="/uganda-safari/">Uganda</a> | <a href="/great-migration/">Migration</a> | <a href="/kilimanjaro/">Kilimanjaro</a> | <a href="/travel-guide/african-safari-cost/">East Africa cost</a>'

New-Global "southern-africa-safari" "Southern Africa Safari: Botswana, Namibia & South Africa (2026/27)" "Southern Africa safaris - Okavango water wilderness, Namib dunes, Kruger leopards, Cape Town and Victoria Falls." "Southern Africa trades Migration herds for exclusivity and variety: Botswana's low-volume Delta concessions, Namibia's desert road journey, South Africa's bush-city-coast combination, and Victoria Falls within reach of all three. Fly-in camps, self-drives and malaria-free family reserves all live here." "SA" @(
 @("Botswana","/botswana-safari/","Okavango, Chobe, wild dogs - exclusive by policy."),
 @("Namibia","/namibia-safari/","Etosha, Sossusvlei, desert rhinos - the road journey."),
 @("South Africa","/south-africa-safari/","Kruger, Cape Town, Garden Route - bush plus city."),
 @("Victoria Falls add-on","/botswana-safari/10-day-botswana-safari/","Two nights from Kasane or Victoria Falls town.")) @(
 @("/botswana-safari/8-day-botswana-safari/","8-Day Okavango & Chobe","8 days | Water camps","From $7,400","Three camps, three ecosystems."),
 @("/namibia-safari/10-day-namibia-safari/","10-Day Namibia Loop","10 days | Guided/self-drive","From $4,200","Dunes, coast, rhinos, Etosha."),
 @("/south-africa-safari/9-day-south-africa/","9-Day Cape & Kruger","9 days | City + bush","From $4,900","The definitive first trip.")) @(
 @("Water wilderness","Botswana 7-10 days","From $6,300"),
 @("Desert loop","Namibia 7-12 days","From $2,900"),
 @("Bush + city","South Africa 9-12 days","From $4,900")) @(
 @{"q"="Which southern country fits us?";"a"="Botswana for exclusive water wilderness and predators; Namibia for self-drive freedom and desert drama; South Africa for families, value and city pairing. Combine Botswana with the Falls most easily."},
 @{"q"="Is Southern Africa good for families?";"a"="The best region for young families: malaria-free reserves in South Africa, easy logistics in Namibia, short activity bursts everywhere."},
 @{"q"="When should we go?";"a"="May to October dry season region-wide for game viewing; November to March for Cape Town, birding and green-season value."}) '<a href="/botswana-safari/">Botswana</a> | <a href="/namibia-safari/">Namibia</a> | <a href="/south-africa-safari/">South Africa</a> | <a href="/travel-guide/best-time-for-african-safari/">Best time</a>'

New-Global "group-african-safaris" "Group African Safaris: Small Join-In Departures (2026/27)" "Small-group safaris with set departures - shared costs, expert guides, maximum four to seven travelers." "Group safaris cut the biggest fixed cost - the private vehicle - by sharing it with like-minded travelers. Our groups cap at seven with window seats for all, run on published dates, and keep the same camps and guides as private trips. Ideal for solo travelers and value-focused couples; private upgrades available on any departure." "TZ" @(
 @("Tanzania group safaris","/tanzania-group-safari/","Northern circuit join-in departures."),
 @("7-day group safari","/tanzania-group-safari/7-day-tanzania-group/","Serengeti, crater, Tarangire from $2,900."),
 @("5-day group safari","/tanzania-group-safari/5-day-tanzania-group/","Essential circuit from $1,950."),
 @("Prefer private?","/private-african-safaris/","Same routes, own vehicle.")) @(
 @("/tanzania-group-safari/7-day-tanzania-group/","7-Day Tanzania Group","7 days | Max 7","From $2,900","The classic circuit, shared."),
 @("/tanzania-group-safari/5-day-tanzania-group/","5-Day Tanzania Group","5 days | Max 7","From $1,950","Essential parks, shared."),
 @("/tanzania-safari/7-day-tanzania-safari/","7-Day Private Version","7 days | Private","From $3,450","Same route, own 4x4.")) @(
 @("5-day group","Essential north","From $1,950"),
 @("7-day group","Full Migration circuit","From $2,900"),
 @("Private upgrade","Any departure","On request")) @(
 @{"q"="How small are the groups?";"a"="Four to seven travelers maximum, window seat guaranteed. Fewer than four confirmed and we offer a private upgrade or date shift - never a minibus crowd."},
 @{"q"="Group or private - what changes?";"a"="Only the vehicle sharing and fixed dates. Same parks, same camps tier, same guide quality. Private costs more for two, converges at four plus."},
 @{"q"="Can solo travelers join?";"a"="Yes - groups are the most social and economical solo option, with single supplements disclosed per departure."}) '<a href="/tanzania-group-safari/">Tanzania groups</a> | <a href="/private-african-safaris/">Private alternative</a> | <a href="/africa-budget-safaris/">Budget hub</a>'

New-Cat "tanzania-group-safari" "Tanzania Group Safaris: Join-In Northern Circuit" "Set-departure group safaris - Tarangire, crater and Serengeti shared with max seven." "TZ" "Our Tanzania groups run the classic northern circuit on published monthly departures: shared extended Land Cruiser, window seats for all, same lodges and tented camps as private trips, one expert guide. Solo travelers welcome; private vehicle upgrades fit any seat." @(
 @("/tanzania-group-safari/7-day-tanzania-group/","7-Day Tanzania Group","7 days | Max 7","From $2,900","Migration circuit, shared costs."),
 @("/tanzania-group-safari/5-day-tanzania-group/","5-Day Tanzania Group","5 days | Max 7","From $1,950","Essential parks, shared costs."),
 @("/tanzania-safari/7-day-tanzania-safari/","7-Day Private Version","7 days | Private","From $3,450","Same route, own vehicle.")) "5 days essential | 7 days full circuit" "Monthly departures, dry season priority" "Lodges and tented camps, same tier as private" @(@{"q"="What if minimum numbers are not met?";"a"="We confirm departures at four travelers. Below that we offer a small private supplement, a date shift, or a full refund - your choice, in writing."}) '<a href="/group-african-safaris/">Group hub</a> | <a href="/tanzania-safari/">Tanzania hub</a> | <a href="/tanzania-safari/packages/">All TZ packages</a>'
"hubs2 done"
