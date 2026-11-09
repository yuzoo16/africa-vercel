/* Analytics loader — reads SITE_CONFIG, injects nothing until IDs are set. */
(function(){
  const C = window.SITE_CONFIG || {};
  function load(src, cb){ const s=document.createElement("script"); s.async=true; s.src=src; if(cb)s.onload=cb; document.head.appendChild(s); }
  document.addEventListener("DOMContentLoaded", ()=>{
    // Proposal/WhatsApp/consultation/quiz events are fired via window.track() in site.js
    document.querySelectorAll("[data-wa]").forEach(a=>a.addEventListener("click",()=>{}, {once:false}));
    if (C.gtmId) { (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({"gtm.start":Date.now(),event:"gtm.js"});const f=d.getElementsByTagName(s)[0],j=d.createElement(s);j.async=true;j.src="https://www.googletagmanager.com/gtm.js?id="+i;f.parentNode.insertBefore(j,f);})(window,document,"script","dataLayer",C.gtmId); }
    else if (C.gaId) { load("https://www.googletagmanager.com/gtag/js?id="+C.gaId, ()=>{
      window.dataLayer=window.dataLayer||[]; window.gtag=function(){dataLayer.push(arguments)}; gtag("js",new Date()); gtag("config",C.gaId);
    });}
    if (C.metaPixelId) { load("https://connect.facebook.net/en_US/fbevents.js", ()=>{ try{ fbq("init",C.metaPixelId); fbq("track","PageView"); }catch(e){} }); }
  });
})();
