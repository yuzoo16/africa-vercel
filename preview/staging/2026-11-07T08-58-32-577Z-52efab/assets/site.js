/* Adventure Safari Africa — global config. Edit these values only. */
window.SITE_CONFIG = {
  siteName: "Adventure Safari Africa",
  domain: "https://www.adventuresafariafrica.com",
  defaultLang: "en",
  whatsappNumber: "+255746328326",
  whatsappBase: "https://wa.me/",
  calendlyUrl: "",
  contactEmail: "info@adventuresafariafrica.com",
  gaId: "", gtmId: "", metaPixelId: "",
  formEndpoint: "info@adventuresafariafrica.com"
};
(function(){
  const REQUIRED_FORM_EMAIL="info@adventuresafariafrica.com";
  const configured=(window.SITE_CONFIG.formEndpoint||"").trim();
  const normalized=configured.replace(/^https?:\/\/formsubmit\.co\/(?:ajax\/)?/i,"").replace(/[/?]/g,"");
  window.SITE_CONFIG.formEndpoint=(normalized.toLowerCase()===REQUIRED_FORM_EMAIL || normalized==="")
    ? REQUIRED_FORM_EMAIL
    : REQUIRED_FORM_EMAIL;
})();
(function(){
  const C = window.SITE_CONFIG;
  function waLink(msg){ const num=(C.whatsappNumber||"").replace(/[^0-9]/g,"");
    const base = num ? C.whatsappBase + num : C.whatsappBase;
    const t = msg ? "?text="+encodeURIComponent(msg) : ""; return base+t; }
  window.waLink = waLink;
  document.addEventListener("DOMContentLoaded", ()=>{
    // Hide the shared header while moving down the page, and reveal it again
    // immediately when the visitor scrolls up. Inline home headers and every
    // localized partial use the same behavior.
    let headerScrollBound=false;
    const bindHeaderScroll=()=>{
      const header=document.querySelector("header.site");
      if(!header || headerScrollBound)return;
      headerScrollBound=true;
      let lastY=window.scrollY, ticking=false;
      const updateHeader=()=>{
        const y=Math.max(0,window.scrollY);
        const delta=y-lastY;
        if(y<24 || delta<0){
          header.classList.remove("header-hidden");
        }else if(delta>7 && y>header.offsetHeight){
          header.classList.add("header-hidden");
        }
        lastY=y;
        ticking=false;
      };
      window.addEventListener("scroll",()=>{
        if(ticking)return;
        ticking=true;
        window.requestAnimationFrame(updateHeader);
      },{passive:true});
    };
    bindHeaderScroll();
    const headerObserver=new MutationObserver(bindHeaderScroll);
    headerObserver.observe(document.documentElement,{childList:true,subtree:true});
    // year
    document.querySelectorAll("[data-year]").forEach(e=>e.textContent=new Date().getFullYear());
    // burger
    document.addEventListener("click",function(e){
      const b=e.target.closest(".burger"); if(!b)return;
      const m=document.querySelector("nav.main"); if(!m)return;
      const o=m.classList.toggle("open");
      b.setAttribute("aria-expanded",o);
      document.body.classList.toggle("mobile-menu-open",o);
      // closing the menu also collapses any open mega accordion, so a panel
      // left expanded is not still open the next time the menu is opened
      if(!o) m.querySelectorAll(".has-mega.open").forEach(w=>{
        w.classList.remove("open");
        const t=w.querySelector(".mega-toggle"); if(t) t.setAttribute("aria-expanded","false");
      });
    });
    // Mega panels. Desktop reveals them with CSS alone (:hover/:focus-within,
    // scoped to min-width:961px). Touch devices do not hover - a tap navigates
    // - so at <=960px each hub carries a disclosure button, wired here, and CSS
    // shows the panel only for .has-mega.open inside max-width:960px. The
    // trigger stays a plain <a>, so tapping the label still navigates and a
    // visitor without JS simply lands on the hub page. Note this flips a class
    // rather than style.display: an inline style would outrank the
    // max-width:960px media query and leak the panels onto desktop.
    // Delegated on document instead of bound per button. The four language
    // trees inject their header from partials-*.js inside their own
    // DOMContentLoaded handler, which can run after this file - so at this
    // point the toggles are not in the DOM yet and a per-button binding finds
    // nothing to attach to. Delegation catches them whenever they appear, on
    // the inline-header homepage and the injected trees alike.
    document.addEventListener("click",function(e){
      const btn=(e.target&&e.target.closest)?e.target.closest(".mega-toggle"):null;
      if(!btn)return;
      if(window.innerWidth>960)return;
      const w=btn.closest(".has-mega"); if(!w)return;
      e.preventDefault();
      e.stopPropagation();
      const open=w.classList.toggle("open");
      btn.setAttribute("aria-expanded",open?"true":"false");
      const panel=w.querySelector(":scope > .mega");
      if(panel)panel.setAttribute("aria-hidden",open?"false":"true");
      if(open){
        w.parentElement.querySelectorAll(":scope > .has-mega.open").forEach(function(sibling){
          if(sibling===w)return;
          sibling.classList.remove("open");
          const siblingButton=sibling.querySelector(".mega-toggle");
          if(siblingButton)siblingButton.setAttribute("aria-expanded","false");
          const siblingPanel=sibling.querySelector(":scope > .mega");
          if(siblingPanel)siblingPanel.setAttribute("aria-hidden","true");
        });
      }
    },true);
    document.addEventListener("click",function(e){
      if(e.target.closest(".has-mega"))return;
      document.querySelectorAll(".has-mega.open").forEach(function(wrapper){
        wrapper.classList.remove("open");
        const link=wrapper.querySelector(":scope > .navlink");
        if(link)link.setAttribute("aria-expanded","false");
      });
    });
    // Same reasoning for collapsing on burger close: on the language trees the
    // binding above never attaches, and those pages bind their own burger
    // handler. Deferred a tick so it reads the state after whichever handler
    // toggled .open has finished.
    document.addEventListener("click",function(e){
      if(!(e.target&&e.target.closest))return;
      if(!e.target.closest(".burger"))return;
      const nm=document.querySelector("nav.main"); if(!nm)return;
      setTimeout(function(){
        if(nm.classList.contains("open"))return;
        document.body.classList.remove("mobile-menu-open");
        nm.querySelectorAll(".has-mega.open").forEach(function(w){
          w.classList.remove("open");
          const t=w.querySelector(".mega-toggle"); if(t)t.setAttribute("aria-expanded","false");
        });
      },0);
    });
    // Escape closes an open panel and hands focus back to its button, so a
    // keyboard user is never stranded inside a panel they cannot dismiss.
    document.addEventListener("keydown",function(e){
      if(e.key!=="Escape") return;
      const w=document.querySelector(".has-mega.open");
      if(w){
        w.classList.remove("open");
        const t=w.querySelector(".mega-toggle"); if(t){ t.setAttribute("aria-expanded","false"); t.focus(); }
        return;
      }
      const nav=document.querySelector("nav.main.open");
      if(nav){
        nav.classList.remove("open");
        document.body.classList.remove("mobile-menu-open");
        const burger=document.querySelector(".burger");
        if(burger){burger.setAttribute("aria-expanded","false");burger.focus();}
      }
    });
    // whatsapp auto-links
    document.querySelectorAll("[data-wa]").forEach(a=>{
      const pkg=a.getAttribute("data-wa-pkg")||"", dest=a.getAttribute("data-wa-dest")||"", dur=a.getAttribute("data-wa-dur")||"";
      let msg=a.getAttribute("data-wa-msg")||"Hello Adventure Safari Africa, I would like to plan a safari.";
      if(pkg) msg=`Hello Adventure Safari Africa, I am interested in the ${pkg}.`;
      else if(dest) msg=`Hello Adventure Safari Africa, I am interested in a ${dur?dur+" ":""}safari in ${dest}.`;
      a.href=waLink(msg); a.target="_blank"; a.rel="noopener";
      a.addEventListener("click",()=>track("whatsapp_click",{label:a.textContent.trim().slice(0,60)}));
    });
    // lazy images
    const io=("IntersectionObserver" in window)?new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting){const i=e.target;if(i.dataset.src){i.src=i.dataset.src;i.removeAttribute("data-src")}i.classList.add("loaded");io.unobserve(i)}})) : null;
    document.querySelectorAll("img[data-src]").forEach(i=>{if(io)io.observe(i);else{i.src=i.dataset.src;i.classList.add("loaded")}});
    // proposal forms
    document.querySelectorAll("form[data-proposal]").forEach(f=>f.addEventListener("submit",async(ev)=>{
      ev.preventDefault();
      const err=f.querySelector("[data-form-err]"),ok=f.querySelector("[data-form-ok]");
      if(err)err.hidden=true; if(ok)ok.hidden=true;
      const fd=new FormData(f);
      const name=(fd.get("name")||"").toString().trim(), email=(fd.get("email")||"").toString().trim();
      if(!name||!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)){ if(err){err.hidden=false;err.textContent="Please add your name and a valid email.";} return; }
      // honeypot
      if((fd.get("company")||"").toString()){ if(ok){ok.hidden=false} f.reset(); return; }
      track("proposal_submit",{dest:(fd.get("destination")||"").toString()});
      const ep=(C.formEndpoint||"").trim();
      const btn=f.querySelector('button[type="submit"]'); if(btn){btn.disabled=true;btn.textContent="Sending...";}
      const done=(msg)=>{ if(ok){ok.hidden=false;ok.textContent=msg;} f.reset(); if(btn){btn.disabled=false;btn.textContent="Submit request";} };
      const fail=()=>{ if(err){err.hidden=false;err.textContent="Could not send just now - please WhatsApp us instead.";} if(btn){btn.disabled=false;btn.textContent="Submit request";} };
      const lines=[]; fd.forEach((v,k)=>{ if(k==="company")return; lines.push(k+": "+v); });
      const payload={name:name,email:email,message:lines.join("\n"),_subject:"Safari proposal request - "+(fd.get("destination")||"Africa")+" / "+(fd.get("dates")||"dates TBC"),_template:"table"};
      try{
        const r=await fetch("/assets/send-proposal.php?v=20261030",{method:"POST",body:fd,headers:{"Accept":"application/json"}});
        let result={};
        try{result=await r.json();}catch{}
        if(r.ok&&result.ok){
          try{const k="asa_leads";const arr=JSON.parse(localStorage.getItem(k)||"[]");arr.push({t:Date.now(),sent:true});localStorage.setItem(k,JSON.stringify(arr));}catch{}
          done("Thank you For Choosing Adventure Safari Africa");
          return;
        }
        if(result.message && err){err.hidden=false;err.textContent=result.message;}
      }catch{}
      // Namecheap delivery uses the same-host PHP mail handler above.
      try{const k="asa_leads";const arr=JSON.parse(localStorage.getItem(k)||"[]");arr.push({t:Date.now(),...Object.fromEntries(fd)});localStorage.setItem(k,JSON.stringify(arr));}catch{}
      if(!err || !err.textContent.trim())fail();
    }));
    // calendly placeholder
    document.querySelectorAll("[data-calendly]").forEach(el=>{
      if(C.calendlyUrl){ el.innerHTML='<iframe title="Book a safari consultation" src="'+C.calendlyUrl+'" style="width:100%;height:640px;border:0;border-radius:12px" loading="lazy"></iframe>'; }
      else{ el.innerHTML='<p class="meta">Consultation calendar loads here once the Calendly URL is added in <code>assets/site.js</code> (SITE_CONFIG.calendlyUrl). Meanwhile, <a href="/request-proposal/">request a proposal</a> or chat on WhatsApp.</p>'; }
    });
  });
  window.track=function(ev,params){ try{ if(window.gtag&&C.gaId)gtag("event",ev,params||{});
    if(window.fbq&&C.metaPixelId)fbq("trackCustom",ev,params||{});}catch{} };
})();

/* Shared premium navigation. The page partials own the initial HTML; this
   enhancement supplies the richer panels consistently on all five locales. */
(function(){
  var copy={
    en:{home:"Home",dest:"Destinations",safaris:"Safaris",discover:"Discover Africa",blog:"Blog",about:"About",plan:"Plan My Safari",
      countries:"Countries",featured:"Featured destination",more:"Explore more",viewDest:"View all destinations",styles:"Safari styles",
      journeys:"Popular journeys",featuredSafari:"Featured safari",explore:"Explore Africa",experiences:"Safari experiences",planTitle:"Plan your safari",
      allPackages:"View all safari packages",exploreTanzania:"Explore Tanzania",accommodation:"Accommodation",travel:"Travel guide",national:"National parks",
      activities:"Activities",kilimanjaro:"Kilimanjaro",contact:"Contact us"},
    fr:{home:"Accueil",dest:"Destinations",safaris:"Safaris",discover:"Découvrir l’Afrique",blog:"Blog",about:"À propos",plan:"Planifier mon safari",
      countries:"Pays",featured:"Destination vedette",more:"Explorer davantage",viewDest:"Toutes les destinations",styles:"Styles de safari",
      journeys:"Voyages populaires",featuredSafari:"Safari vedette",explore:"Explorer l’Afrique",experiences:"Expériences safari",planTitle:"Préparez votre safari",
      allPackages:"Tous les forfaits safari",exploreTanzania:"Explorer la Tanzanie",accommodation:"Hébergement",travel:"Guide de voyage",national:"Parcs nationaux",
      activities:"Activités",kilimanjaro:"Kilimandjaro",contact:"Nous contacter"},
    de:{home:"Startseite",dest:"Destinationen",safaris:"Safaris",discover:"Afrika entdecken",blog:"Blog",about:"Über uns",plan:"Meine Safari planen",
      countries:"Länder",featured:"Destination im Fokus",more:"Mehr entdecken",viewDest:"Alle Destinationen",styles:"Safari-Stile",
      journeys:"Beliebte Reisen",featuredSafari:"Safari im Fokus",explore:"Afrika entdecken",experiences:"Safari-Erlebnisse",planTitle:"Safari planen",
      allPackages:"Alle Safari-Pakete",exploreTanzania:"Tansania entdecken",accommodation:"Unterkünfte",travel:"Reiseführer",national:"Nationalparks",
      activities:"Aktivitäten",kilimanjaro:"Kilimandscharo",contact:"Kontakt"},
    it:{home:"Home",dest:"Destinazioni",safaris:"Safari",discover:"Scopri l’Africa",blog:"Blog",about:"Chi siamo",plan:"Pianifica il safari",
      countries:"Paesi",featured:"Destinazione in evidenza",more:"Esplora altro",viewDest:"Tutte le destinazioni",styles:"Tipi di safari",
      journeys:"Viaggi popolari",featuredSafari:"Safari in evidenza",explore:"Esplora l’Africa",experiences:"Esperienze safari",planTitle:"Organizza il safari",
      allPackages:"Tutti i pacchetti safari",exploreTanzania:"Scopri la Tanzania",accommodation:"Alloggi",travel:"Guida di viaggio",national:"Parchi nazionali",
      activities:"Attività",kilimanjaro:"Kilimangiaro",contact:"Contattaci"},
    es:{home:"Inicio",dest:"Destinos",safaris:"Safaris",discover:"Descubre África",blog:"Blog",about:"Nosotros",plan:"Planifica tu safari",
      countries:"Países",featured:"Destino destacado",more:"Explorar más",viewDest:"Todos los destinos",styles:"Estilos de safari",
      journeys:"Viajes populares",featuredSafari:"Safari destacado",explore:"Explora África",experiences:"Experiencias de safari",planTitle:"Planifica tu safari",
      allPackages:"Todos los paquetes de safari",exploreTanzania:"Explora Tanzania",accommodation:"Alojamiento",travel:"Guía de viaje",national:"Parques nacionales",
      activities:"Actividades",kilimanjaro:"Kilimanjaro",contact:"Contáctanos"}
  };
  function locale(){ var p=location.pathname.match(/^\/(fr|de|it|es)(?:\/|$)/); return p?p[1]: "en"; }
  function prefix(){ var l=locale(); return l==="en"?"":"/"+l; }
  function link(path){ return prefix()+path+(path.endsWith("/")?"":"/"); }
  function enhance(){
    var l=locale(), t=copy[l], p=prefix(), nav=document.querySelector("nav.main"), shells=nav?nav.querySelectorAll(".has-mega"):[];
    if(!nav||shells.length<3)return;
    var labels=nav.querySelectorAll(".navlink");
    for(var i=1;i<labels.length;i++){
      if(i===1)labels[i].textContent=t.dest;
      if(i===2)labels[i].textContent=t.safaris;
      if(i===3)labels[i].textContent=t.discover;
    }
    var countries=[
      ["Tanzania","/tanzania-safari/"],["Kenya","/kenya-safari/"],["Botswana","/botswana-safari/"],
      ["Namibia","/namibia-safari/"],["South Africa","/south-africa-safari/"],["Ethiopia","/ethiopia-safari/"]
    ];
    var countryLinks=countries.map(function(c){return '<a href="'+link(c[1])+'">'+c[0]+'</a>';}).join("");
    shells[0].querySelector(".mega").innerHTML=
      '<div class="mega-layout mega-destinations"><section class="mega-column"><p class="mega-kicker">'+t.countries+'</p><div class="mega-country-grid">'+countryLinks+'</div><a class="mega-view-all" href="'+link("/africa-safaris/")+'">'+t.viewDest+' <span aria-hidden="true">→</span></a></section>'+
      '<section class="mega-feature"><p class="mega-kicker">'+t.featured+'</p><a class="mega-image-card" href="'+link("/tanzania-safari/")+'"><img src="https://images.unsplash.com/photo-1516426122078-c23e76319801?w=640&q=80&auto=format&fit=crop" alt="Wildlife in Tanzania" loading="lazy"><span><b>Tanzania</b><small>'+t.exploreTanzania+'</small></span></a></section>'+
      '<section class="mega-column"><p class="mega-kicker">'+t.more+'</p><div class="mega-links"><a href="'+link("/national-parks/")+'">'+t.national+'</a><a href="'+link("/kilimanjaro/")+'">'+t.kilimanjaro+'</a><a href="'+link("/travel-guide/")+'">'+t.travel+'</a><a href="'+link("/east-africa-safari/")+'">East Africa</a></div></section></div>';

    var styles=[["Luxury","/africa-luxury-safaris/"],["Family","/africa-family-safaris/"],["Honeymoon","/africa-honeymoon-safaris/"],["Private","/private-african-safaris/"],["Group","/group-african-safaris/"],["Tailor-made","/tailor-made-african-safaris/"],["Great Migration","/great-migration/"]];
    var styleLinks=styles.map(function(s){return '<a href="'+link(s[1])+'">'+s[0]+'</a>';}).join("");
    shells[1].querySelector(".mega").innerHTML=
      '<div class="mega-layout mega-safaris"><section class="mega-column"><p class="mega-kicker">'+t.styles+'</p><div class="mega-links">'+styleLinks+'</div></section>'+
      '<section class="mega-column"><p class="mega-kicker">'+t.journeys+'</p><div class="mega-links"><a href="'+link("/tanzania-safari/")+'">Tanzania Safari</a><a href="'+link("/kenya-safari/")+'">Kenya Safari</a><a href="'+link("/kenya-tanzania-safari/")+'">Kenya &amp; Tanzania</a><a href="'+link("/africa-safari-from-zanzibar/")+'">Safari &amp; Zanzibar</a><a href="'+link("/africa-safari-packages/")+'" class="mega-view-all">'+t.allPackages+' →</a></div></section>'+
      '<section class="mega-feature"><p class="mega-kicker">'+t.featuredSafari+'</p><a class="mega-image-card" href="'+link("/tanzania-safari/")+'"><img src="https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=640&q=80&auto=format&fit=crop" alt="Safari in Tanzania" loading="lazy"><span><b>Classic Tanzania Safari</b><small>'+t.exploreTanzania+'</small></span></a></section></div>';

    shells[2].querySelector(".mega").innerHTML=
      '<div class="mega-layout mega-discover"><section class="mega-column"><p class="mega-kicker">'+t.explore+'</p><div class="mega-links"><a href="'+link("/africa-safaris/")+'">Africa Safaris</a><a href="'+link("/east-africa-safari/")+'">East Africa</a><a href="'+link("/southern-africa-safari/")+'">Southern Africa</a><a href="'+link("/national-parks/")+'">'+t.national+'</a></div></section>'+
      '<section class="mega-column"><p class="mega-kicker">'+t.experiences+'</p><div class="mega-links"><a href="'+link("/activities/")+'">'+t.activities+'</a><a href="'+link("/activities/hot-air-balloon-safari/")+'">Hot-Air Balloon Safari</a><a href="'+link("/africa-photographic-safaris/")+'">Photographic Safaris</a><a href="'+link("/kilimanjaro/")+'">'+t.kilimanjaro+'</a></div></section>'+
      '<section class="mega-column"><p class="mega-kicker">'+t.planTitle+'</p><div class="mega-links"><a href="'+link("/accommodation/")+'">'+t.accommodation+'</a><a href="'+link("/travel-guide/")+'">'+t.travel+'</a><a href="'+link("/blog/")+'">'+t.blog+'</a><a href="'+link("/request-proposal/")+'">'+t.plan+'</a></div></section></div>';
    var cta=document.querySelector(".cta-row .btn"); if(cta){cta.textContent=t.plan;cta.href=link("/request-proposal/");}
    var footer=document.querySelector("footer .fgrid");
    if(footer) footer.innerHTML='<div><a class="brand" href="'+(p||"/")+'" style="color:#fff">Adventure Safari Africa</a><p>Private, tailor-made safaris across Africa — designed by specialists, led by expert local guides.</p></div>'+
      '<div><h2>'+t.dest+'</h2><p><a href="'+link("/tanzania-safari/")+'">Tanzania</a><br><a href="'+link("/kenya-safari/")+'">Kenya</a><br><a href="'+link("/botswana-safari/")+'">Botswana</a><br><a href="'+link("/namibia-safari/")+'">Namibia</a><br><a href="'+link("/south-africa-safari/")+'">South Africa</a></p></div>'+
      '<div><h2>'+t.safaris+'</h2><p><a href="'+link("/africa-luxury-safaris/")+'">Luxury Safaris</a><br><a href="'+link("/africa-family-safaris/")+'">Family Safaris</a><br><a href="'+link("/private-african-safaris/")+'">Private Safaris</a><br><a href="'+link("/tailor-made-african-safaris/")+'">Tailor-made Safaris</a><br><a href="'+link("/africa-safari-packages/")+'">Safari Packages</a></p></div>'+
      '<div><h2>'+t.discover+'</h2><p><a href="'+link("/national-parks/")+'">'+t.national+'</a><br><a href="'+link("/activities/")+'">'+t.activities+'</a><br><a href="'+link("/accommodation/")+'">'+t.accommodation+'</a><br><a href="'+link("/travel-guide/")+'">'+t.travel+'</a><br><a href="'+link("/about/")+'">'+t.about+'</a><br><a href="'+link("/request-proposal/")+'">'+t.plan+'</a></p></div>';

    document.querySelectorAll(".has-mega").forEach(function(w){
      var trigger=w.querySelector(".mega-toggle");
      if(trigger){trigger.addEventListener("click",function(e){e.preventDefault();e.stopPropagation();var open=w.classList.toggle("open");trigger.setAttribute("aria-expanded",open?"true":"false");});}
    });
  }
  document.addEventListener("DOMContentLoaded",function(){setTimeout(enhance,0);setTimeout(enhance,100);});
  document.addEventListener("click",function(e){if(!e.target.closest(".has-mega"))document.querySelectorAll(".has-mega.open").forEach(function(w){w.classList.remove("open");var b=w.querySelector(".mega-toggle");if(b)b.setAttribute("aria-expanded","false");});});
})();

/* =============================================================================
   CONDITIONAL PROPOSAL-FORM SECTIONS   (6 lead forms: en / de / fr / es / it + home)
   -----------------------------------------------------------------------------
   1. The "which countries are you combining?" multi-select (#dest-multi) only
      exists for the client once "Multiple countries" is picked in Destination.
      Picking anything else hides it and clears the selection, so a stale choice
      can never be submitted behind the client's back.
   2. The four flight fields (arrival airport / arrival date / departure date /
      departure airport) only appear once the client answers "Yes, booked" to the
      international-flight question, and are cleared when it collapses again.
   Deliberately independent of the submit handler above: every field - visible or
   not - is already collected through FormData, so no wiring is needed there.
   ========================================================================== */
(function(){
  function syncMulti(f){
    var s=f.querySelector('[name="destination"]'),
        box=f.querySelector('#dest-multi'),
        c=f.querySelector('#dest-countries');
    if(!s||!box) return;
    var o=s.options[s.selectedIndex];
    var on=!!(o&&o.getAttribute('data-multi')==='1');
    box.hidden=!on;
    if(!on&&c){ for(var i=0;i<c.options.length;i++){ c.options[i].selected=false; } }
  }
  function syncFlight(f){
    var s=f.querySelector('[name="flight_booked"]'), d=f.querySelector('#flight-details');
    if(!s||!d) return;
    var o=s.options[s.selectedIndex];
    var on=!!(o&&o.getAttribute('data-yes')==='1');
    d.hidden=!on;
    if(!on){ var ins=d.querySelectorAll('input'); for(var i=0;i<ins.length;i++){ ins[i].value=''; } }
  }
  function wire(){
    var forms=document.querySelectorAll('form[data-proposal]');
    for(var n=0;n<forms.length;n++){
      (function(f){
        var d=f.querySelector('[name="destination"]'), fl=f.querySelector('[name="flight_booked"]');
        if(d){ d.addEventListener('change',function(){ syncMulti(f); }); }
        if(fl){ fl.addEventListener('change',function(){ syncFlight(f); }); }
        f.addEventListener('reset',function(){ setTimeout(function(){ syncMulti(f); syncFlight(f); },0); });
        syncMulti(f); syncFlight(f);
      })(forms[n]);
    }
  }
  if(document.readyState==='loading'){ document.addEventListener('DOMContentLoaded',wire); }
  else{ wire(); }
})();
