/* browse.js - package finder for listing pages: instant search + section chip map.
   Progressive enhancement: builds its own UI from the page's h2[id] structure.
   No content edits, no dependencies; safe to load on any page with a .wrap + h2[id]. */
(function () {
  'use strict';

  var DICT = {
    en: { nav:'Page sections', label:'Search this page', ph:'Search - e.g. Serengeti, gorilla, 7-day', res:'Showing {x} of {y} options', none:'No options match', clear:'Clear', top:'Top', n:'{n} options' },
    it: { nav:'Sezioni della pagina', label:'Cerca in questa pagina', ph:'Cerca - es. Serengeti, gorilla, 7 giorni', res:'{x} di {y} opzioni', none:'Nessuna opzione corrisponde', clear:'Cancella', top:'In alto', n:'{n} opzioni' },
    fr: { nav:'Sections de la page', label:'Rechercher dans cette page', ph:'Rechercher - ex. Serengeti, gorille, 7 jours', res:'{x} options sur {y}', none:'Aucune option ne correspond', clear:'Effacer', top:'Haut', n:'{n} options' },
    de: { nav:'Seitenabschnitte', label:'Seite durchsuchen', ph:'Suchen - z. B. Serengeti, Gorilla, 7 Tage', res:'{x} von {y} Optionen', none:'Keine Optionen gefunden', clear:'Löschen', top:'Nach oben', n:'{n} Optionen' },
    es: { nav:'Secciones de la página', label:'Buscar en esta página', ph:'Buscar - ej. Serengeti, gorila, 7 días', res:'{x} de {y} opciones', none:'Ninguna opción coincide', clear:'Borrar', top:'Arriba', n:'{n} opciones' }
  };
  var lang = (document.documentElement.lang || 'en').slice(0, 2).toLowerCase();
  var T = DICT[lang] || DICT.en;

  function norm(s) {
    s = (s || '').toLowerCase();
    if (s.normalize) s = s.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    return s.replace(/\s+/g, ' ').trim();
  }
  function mk(tag, cls, txt) { var e = document.createElement(tag); if (cls) e.className = cls; if (txt != null) e.textContent = txt; return e; }
  function txt(nodes) { var s = ''; for (var i = 0; i < nodes.length; i++) s += ' ' + nodes[i].textContent; return s; }
  function hid(nodes, on) { for (var i = 0; i < nodes.length; i++) nodes[i].classList.toggle('pkg-h', !!on); }
  function isHid(n) { return n.classList.contains('pkg-h'); }

  function init() {
    if (document.getElementById('pkg-q')) return;
    var scope = document.querySelector('main') || document;
    var first = scope.querySelector('h2[id]');
    var autoId = false, plan = [], anchor = null;

    if (first) {
      // established mode: the wrap that holds the first h2[id] (+ any other wrap
      // that carries its own h2[id] sections); identical to the original single-wrap
      // behaviour on pages whose content lives in one wrap
      var w0 = first.closest ? first.closest('.wrap') : null;
      if (!w0) return;
      plan = [{ wrap: w0, from: first }];
      anchor = first;
      var ws0 = scope.querySelectorAll('.wrap');
      for (var a0 = 0; a0 < ws0.length; a0++) {
        if (ws0[a0] === w0) continue;
        var f0 = ws0[a0].querySelector('h2[id]');
        if (f0) plan.push({ wrap: ws0[a0], from: f0 });
      }
    } else {
      // fallback mode for hubs whose h2s carry no ids: every wrap with an h2
      // becomes a section, and ids are generated client-side for the chip anchors
      autoId = true;
      var ws1 = scope.querySelectorAll('.wrap');
      for (var a1 = 0; a1 < ws1.length; a1++) {
        if (ws1[a1].querySelector('h2')) plan.push({ wrap: ws1[a1], from: null });
      }
      if (!plan.length) return;
      var k0 = [].slice.call(plan[0].wrap.children);
      for (var b0 = 0; b0 < k0.length; b0++) { if (k0[b0].tagName === 'H2') { anchor = k0[b0]; break; } }
      if (!anchor) return;
    }

    function makeId(text) {
      var s = (text || '').toLowerCase();
      if (s.normalize) s = s.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
      s = s.replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'section';
      var base = s, n = 2;
      while (document.getElementById(s)) { s = base + '-' + n; n++; }
      return s;
    }

    /* ---- model: sections (h2) > groups (h3 over h4) > items (h3/h4/.card) ---- */
    var sections = [], cur = null, lastItem = null, lastGroup = null;
    for (var pi = 0; pi < plan.length; pi++) {
      var wrap = plan[pi].wrap;
      var kids = [].slice.call(wrap.children);
      var start;
      if (plan[pi].from) { start = kids.indexOf(plan[pi].from); }
      else {
        start = -1;
        for (var s1 = 0; s1 < kids.length; s1++) { if (kids[s1].tagName === 'H2') { start = s1; break; } }
      }
      if (start < 0) continue;
      var end = kids.length;
      var faq = wrap.querySelector('.faq');
      if (faq) {
        for (var i = start; i < kids.length; i++) { if (kids[i] === faq || kids[i].contains(faq)) { end = i; break; } }
      }
      cur = null; lastItem = null; lastGroup = null;
      for (var k = start; k < end; k++) {
        var el = kids[k], tag = el.tagName;
        if (tag === 'H2') {
          if (autoId && !el.id) el.id = makeId(el.textContent);
          cur = { el: el, fixed: [el], items: [] }; sections.push(cur); lastItem = null; lastGroup = null; continue;
        }
        if (!cur) continue;
        if (tag === 'H3') {
          var nx = el.nextElementSibling;
          if (nx && nx.tagName === 'H4') {
            var g = { el: el, nodes: [el], children: [], isGroup: true };
            cur.items.push(g); lastGroup = g; lastItem = null; continue;
          }
          var it = { el: el, nodes: [el], parent: null };
          cur.items.push(it); lastItem = it; lastGroup = null; continue;
        }
        if (tag === 'H4') {
          var c4 = { el: el, nodes: [el], parent: lastGroup || null };
          if (lastGroup) lastGroup.children.push(c4); else cur.items.push(c4);
          lastItem = c4; continue;
        }
        var cards = [];
        if (el.classList.contains('card')) cards.push(el);
        if (el.querySelectorAll) { var qq = el.querySelectorAll('.card'); for (var q = 0; q < qq.length; q++) cards.push(qq[q]); }
        if (cards.length) {
          cur.fixed.push(el);
          for (var c = 0; c < cards.length; c++) cur.items.push({ el: cards[c], nodes: [cards[c]], parent: null });
          lastItem = null; lastGroup = null; continue;
        }
        if (lastItem) lastItem.nodes.push(el); else cur.fixed.push(el);
      }
    }

    function leaves(sec) {
      var out = [];
      for (var i = 0; i < sec.items.length; i++) {
        var it = sec.items[i];
        if (it.isGroup) { for (var j = 0; j < it.children.length; j++) out.push(it.children[j]); }
        else out.push(it);
      }
      return out;
    }

    var total = 0;
    sections.forEach(function (sec) {
      var sh = norm(sec.el.textContent);
      sec.isStatic = sec.items.length === 0;
      sec.staticHay = sec.isStatic ? norm(txt(sec.fixed)) : '';
      if (!sec.isStatic) {
        var lv = leaves(sec);
        total += lv.length;
        lv.forEach(function (it) {
          it.hay = sh + ' ' + (it.parent ? norm(it.parent.el.textContent) + ' ' : '') + norm(txt(it.nodes));
        });
      }
    });
    if (!sections.length) return;

    /* ---- UI ---- */
    var bar = mk('div', 'pbar');
    var inner = mk('div', 'pbar-in');
    var find = mk('div', 'pfind');
    find.setAttribute('role', 'search');
    var input = mk('input');
    input.type = 'search'; input.id = 'pkg-q'; input.autocomplete = 'off';
    input.setAttribute('aria-label', T.label); input.placeholder = T.ph;
    var hint = mk('span', 'phint', '/'); hint.setAttribute('aria-hidden', 'true');
    var clr = mk('button', 'pclr', T.clear); clr.type = 'button'; clr.hidden = true;
    find.appendChild(input); find.appendChild(hint); find.appendChild(clr);
    var res = mk('div', 'pres'); res.setAttribute('role', 'status'); res.hidden = true;
    var chips = mk('nav', 'pchips'); chips.setAttribute('aria-label', T.nav);
    inner.appendChild(find); inner.appendChild(res); inner.appendChild(chips);
    bar.appendChild(inner);

    var none = mk('div', 'pnone'); none.setAttribute('role', 'status'); none.hidden = true;
    var noneTxt = mk('span', 'pnone-t');
    var noneBtn = mk('button', 'btn btn-o btn-sm', T.clear); noneBtn.type = 'button';
    none.appendChild(noneTxt); none.appendChild(noneBtn);
    bar.appendChild(none);
    anchor.parentNode.insertBefore(bar, anchor);

    /* ---- chips from the page's own section headings (auto-localised) ---- */
    var chipMap = {};
    sections.forEach(function (sec) {
      if (!sec.el.id) return;
      var a = mk('a', 'pchip'); a.href = '#' + sec.el.id;
      var head = sec.el.textContent.replace(/\s+/g, ' ').trim();
      a.appendChild(document.createTextNode(head));
      var n = sec.isStatic ? 0 : leaves(sec).length;
      if (n >= 2) {
        a.appendChild(mk('span', 'pnum', String(n)));
        // title-only (not aria-label): keeps the accessible name identical to the
        // visible text (label-content-name-mismatch) while explaining the count
        a.title = head + ' - ' + T.n.replace('{n}', n);
      }
      chips.appendChild(a);
      chipMap[sec.el.id] = a;
    });
    var topBtn = mk('button', 'pchip ptop', '\u2191 ' + T.top); topBtn.type = 'button';
    chips.appendChild(topBtn);

    /* ---- filtering ---- */
    function apply() {
      var q = norm(input.value);
      var shown = 0;
      for (var i = 0; i < sections.length; i++) {
        var sec = sections[i];
        if (sec.isStatic) { hid(sec.fixed, !!q && sec.staticHay.indexOf(q) < 0); continue; }
        var lv = leaves(sec), vis = 0;
        for (var j = 0; j < lv.length; j++) {
          var ok = !q || lv[j].hay.indexOf(q) >= 0;
          hid(lv[j].nodes, !ok);
          if (ok) vis++;
        }
        for (var g = 0; g < sec.items.length; g++) {
          var grp = sec.items[g];
          if (!grp.isGroup) continue;
          var any = false;
          for (var m = 0; m < grp.children.length; m++) if (!isHid(grp.children[m].nodes[0])) { any = true; break; }
          hid([grp.el], !any);
        }
        hid(sec.fixed, vis === 0);
        shown += vis;
      }
      find.classList.toggle('has-q', !!q);
      clr.hidden = !q;
      if (q) { res.hidden = false; res.textContent = T.res.replace('{x}', shown).replace('{y}', total); }
      else res.hidden = true;
      if (q && shown === 0) { none.hidden = false; noneTxt.textContent = T.none + ' \u201C' + input.value.trim() + '\u201D'; }
      else none.hidden = true;
      update();
    }
    function clearQ() { input.value = ''; apply(); }

    input.addEventListener('input', apply);
    clr.addEventListener('click', function () { clearQ(); input.focus(); });
    noneBtn.addEventListener('click', function () { clearQ(); input.focus(); });
    document.addEventListener('keydown', function (e) {
      var ae = document.activeElement, tag = ae ? ae.tagName : '';
      if (e.key === '/' && ae !== input && !/^(INPUT|TEXTAREA|SELECT)$/.test(tag)) { e.preventDefault(); input.focus(); input.select(); }
      else if (e.key === 'Escape' && (ae === input || e.target === input) && input.value) { clearQ(); }
    });
    chips.addEventListener('click', function (e) {
      var a = e.target.closest ? e.target.closest('a.pchip') : null;
      if (!a) return;
      if (input.value) {
        e.preventDefault();
        input.value = ''; apply();
        var id = a.getAttribute('href').slice(1), t = document.getElementById(id);
        if (t) t.scrollIntoView();
        if (history.replaceState) history.replaceState(null, '', '#' + id);
        onScroll();
      }
    });
    topBtn.addEventListener('click', function () {
      var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' });
    });

    /* ---- scrollspy + anchor offsets ---- */
    var hdrEl = document.querySelector('header.site');
    var hdrH = 0, lastActive = '';
    function setVars() {
      if (!hdrEl) hdrEl = document.querySelector('header.site');
      hdrH = hdrEl ? hdrEl.offsetHeight : 0;
      var s = document.documentElement.style;
      s.setProperty('--hdr', hdrH + 'px');
      s.setProperty('--anchor', (hdrH + (bar.offsetHeight || 0) + 16) + 'px');
    }
    function update() {
      // self-heal: header may render (or change height) after init
      if (!hdrEl || (hdrEl.offsetHeight && hdrEl.offsetHeight !== hdrH)) setVars();
      var off = (bar.offsetHeight || 0) + hdrH + 48, activeId = '';
      for (var i = 0; i < sections.length; i++) {
        var s = sections[i];
        if (!s.el.id || isHid(s.el)) continue;
        if (s.el.getBoundingClientRect().top <= off) activeId = s.el.id;
      }
      if (activeId === lastActive) return;
      lastActive = activeId;
      for (var id in chipMap) {
        var on = id === activeId, a = chipMap[id];
        a.classList.toggle('active', on);
        if (on) a.setAttribute('aria-current', 'true'); else a.removeAttribute('aria-current');
      }
      var act = activeId ? chipMap[activeId] : null;
      if (act) {
        var r = act.getBoundingClientRect(), cr = chips.getBoundingClientRect();
        if (r.left < cr.left + 4) chips.scrollLeft += r.left - cr.left - 4;
        else if (r.right > cr.right - 4) chips.scrollLeft += r.right - cr.right + 4;
      }
    }
    function onScroll() { update(); }
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', function () { setVars(); lastActive = '\u0000'; onScroll(); });
    window.addEventListener('load', function () { setVars(); lastActive = '\u0000'; onScroll(); });
    setTimeout(function () { setVars(); lastActive = '\u0000'; onScroll(); }, 900);
    if (window.ResizeObserver && hdrEl) new ResizeObserver(function () { setVars(); }).observe(hdrEl);

    setVars();
    update();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
