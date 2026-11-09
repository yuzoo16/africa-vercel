import { useEffect, useState, type FormEvent } from "react";
import {
  Activity, Archive, BookOpen, ChevronDown, ChevronLeft, Compass, FileText,
  Gauge, Globe2, History, Image, Languages, LayoutDashboard, Leaf, LogOut,
  Menu as MenuIcon, Package, Route, Search, Settings, ShieldCheck, Users,
  Waypoints, X
} from "lucide-react";
import { api } from "./api";

type Summary = {
  pages: { total: number; published: number; draft: number; inReview: number };
  languages: { code: string; name: string; published: number; drafts: number; missing: number }[];
  missingTranslations: number;
  outdatedTranslations: number;
  seoIssues: number;
  recentEdits: { id: string; title: string; language: string; status: string; updatedAt: string }[];
  recentPublishing: { id: string; label: string; status: string; createdAt: string }[];
};

const navigation = [
  { label: "Overview", icon: LayoutDashboard },
  { label: "Content", icon: FileText, children: ["Website Pages", "Safari Packages", "Destinations", "National Parks", "Safari Experiences", "Accommodation", "Travel Guides", "Blog Management"] },
  { label: "Localization", icon: Languages, children: ["Translation Centre", "SEO Management"] },
  { label: "Site", icon: Globe2, children: ["Media Library", "Navigation Management", "Revision History"] },
  { label: "Operations", icon: Activity, children: ["Publishing Centre", "Settings"] }
];

export function App() {
  const [active, setActive] = useState("Overview");
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [summary, setSummary] = useState<Summary | null>(null);
  const [error, setError] = useState("");
  const [authenticated, setAuthenticated] = useState(false);
  const [authChecking, setAuthChecking] = useState(true);
  const [currentUser, setCurrentUser] = useState<{ name?: string; email?: string; role?: string } | null>(null);

  useEffect(() => {
    api<{ user: { name?: string; email?: string; role?: string } }>("/api/auth/me")
      .then((result) => {
        setCurrentUser(result.user);
        setAuthenticated(true);
      })
      .catch(() => {
        setAuthenticated(false);
        sessionStorage.removeItem("cms_csrf_token");
      })
      .finally(() => setAuthChecking(false));
  }, []);

  useEffect(() => {
    if (!authenticated) return;
    api<Summary>("/api/dashboard/summary")
      .then(setSummary)
      .catch((reason) => setError(reason instanceof Error ? reason.message : "Unable to load dashboard"));
  }, [authenticated]);

  if (!authenticated && active !== "Overview" && active) {
    // Protected modules still render the overview shell, with login handled below.
  }

  if (authChecking) return <div className="login-screen"><div className="loading-panel">Checking secure session…</div></div>;
  if (!authenticated) return <Login onLogin={(user) => { setCurrentUser(user); setAuthenticated(true); }} />;

  const logout = async () => {
    try {
      await api("/api/auth/logout", { method: "POST" });
    } finally {
      sessionStorage.removeItem("cms_csrf_token");
      setAuthenticated(false);
      setCurrentUser(null);
      window.location.replace("/");
    }
  };

  const select = (label: string) => {
    setActive(label);
    setMobileOpen(false);
  };

  return (
    <div className="app-shell">
      <aside className={`sidebar ${collapsed ? "collapsed" : ""} ${mobileOpen ? "mobile-open" : ""}`}>
        <div className="brand">
          <div className="brand-mark"><Leaf size={20} /></div>
          {!collapsed && <div><strong>Adventure Safari</strong><span>Content Centre</span></div>}
          <button className="mobile-close" onClick={() => setMobileOpen(false)}><X /></button>
        </div>
        <nav>
          {navigation.map((group) => (
            <div key={group.label} className="nav-group">
              {group.children ? (
                <>
                  <div className="nav-heading"><group.icon size={18} /><span>{group.label}</span><ChevronDown size={15} /></div>
                  {group.children.map((child) => <NavItem key={child} label={child} active={active === child} collapsed={collapsed} icon={GroupIcon(child)} onClick={() => select(child)} />)}
                </>
              ) : (
                <NavItem label={group.label} active={active === group.label} collapsed={collapsed} icon={group.icon} onClick={() => select(group.label)} />
              )}
            </div>
          ))}
        </nav>
        <div className="sidebar-user">
          <div className="avatar">AA</div>
          {!collapsed && (
            <div className="sidebar-user-details">
              <strong>{currentUser?.name || "CMS user"}</strong>
              <span>{currentUser?.role || "User"}</span>
              <button className="logout-button" type="button" onClick={logout}>
                <LogOut size={15} />
                Logout
              </button>
            </div>
          )}
          {collapsed && (
            <button className="logout-icon-button" type="button" onClick={logout} title="Logout" aria-label="Logout">
              <LogOut size={18} />
            </button>
          )}
        </div>
      </aside>

      <main>
        <header className="topbar">
          <button className="icon-button menu-button" onClick={() => setMobileOpen(true)}><MenuIcon /></button>
          <button className="collapse-button" onClick={() => setCollapsed(!collapsed)}><ChevronLeft size={17} /></button>
          <div className="search"><Search size={17} /><input aria-label="Search CMS" placeholder="Search pages, packages, media..." /></div>
          <div className="top-actions"><a className="preview-button" href={`${window.location.protocol}//${window.location.hostname}:3001/Africa-Safari/`} target="_blank" rel="noreferrer">View website</a><div className="avatar small">AA</div></div>
        </header>

        <section className="page">
          {error && <div className="alert">{error}</div>}
          {active === "Overview" ? <Overview summary={summary} /> : <ModulePlaceholder name={active} />}
        </section>
      </main>
    </div>
  );
}

function NavItem({ label, icon: Icon, active, collapsed, onClick }: { label: string; icon: typeof FileText; active: boolean; collapsed: boolean; onClick: () => void }) {
  return <button className={`nav-item ${active ? "active" : ""}`} title={collapsed ? label : undefined} onClick={onClick}><Icon size={18} /><span>{label}</span></button>;
}

function GroupIcon(label: string) {
  const icons: Record<string, typeof FileText> = {
    "Website Pages": FileText, "Safari Packages": Package, Destinations: Compass, "National Parks": Route,
    "Safari Experiences": Activity, Accommodation: ShieldCheck, "Travel Guides": BookOpen, "Blog Management": BookOpen,
    "Translation Centre": Languages, "SEO Management": Gauge, "Media Library": Image, "Navigation Management": Waypoints,
    "Revision History": History, "Publishing Centre": Archive, Settings
  };
  return icons[label] || FileText;
}

function Overview({ summary }: { summary: Summary | null }) {
  if (!summary) return <div className="loading-panel">Loading CMS overview…</div>;
  const cards = [
    ["Total pages", summary.pages.total, "All imported routes"],
    ["Published", summary.pages.published, "Live content versions"],
    ["Draft pages", summary.pages.draft, "Not ready for publishing"],
    ["Awaiting review", summary.pages.inReview, "Pending editorial approval"]
  ];
  return <>
    <div className="page-heading">
      <div><p className="eyebrow">Dashboard</p><h1>Good morning</h1><p>Here is what is happening across your website today.</p></div>
    </div>
    <div className="stat-grid">
      {cards.map(([label, value, note]) => <article className="stat-card" key={String(label)}><span>{String(label)}</span><strong>{String(value)}</strong><small>{String(note)}</small></article>)}
    </div>
    <div className="dashboard-grid">
      <article className="panel language-panel">
        <div className="panel-heading"><div><h2>Content by language</h2><p>Published and missing translations</p></div><button>View report</button></div>
        <div className="language-list">{summary.languages.map((language) => <div className="language-row" key={language.code}><span className="language-code">{language.code.toUpperCase()}</span><div><strong>{language.name}</strong><small>{language.published} published · {language.drafts} drafts</small></div><div className="progress"><i style={{ width: `${Math.max(0, 100 - language.missing)}%` }} /></div><span className="missing">{language.missing} missing</span></div>)}</div>
      </article>
      <article className="panel health-panel">
        <div className="panel-heading"><div><h2>Content health</h2><p>Items needing attention</p></div></div>
        <HealthRow label="Missing translations" count={summary.missingTranslations} />
        <HealthRow label="Outdated translations" count={summary.outdatedTranslations} />
        <HealthRow label="SEO issues" count={summary.seoIssues} />
      </article>
      <article className="panel activity-panel">
        <div className="panel-heading"><div><h2>Recent activity</h2><p>Latest page changes</p></div></div>
        {summary.recentEdits.length ? summary.recentEdits.map((item) => <div className="activity-row" key={item.id}><div className="activity-icon"><FileText size={16} /></div><div><strong>{item.title}</strong><span>{item.language.toUpperCase()} · {item.status}</span></div><time>{new Date(item.updatedAt).toLocaleDateString()}</time></div>) : <div className="empty">No recent edits</div>}
      </article>
      <article className="panel publish-panel">
        <div className="panel-heading"><div><h2>Publishing</h2><p>Recent deployment activity</p></div></div>
        {summary.recentPublishing.length ? summary.recentPublishing.map((item) => <div className="activity-row" key={item.id}><div className="activity-icon"><Archive size={16} /></div><div><strong>{item.label}</strong><span>{item.status}</span></div></div>) : <div className="empty">No publishing activity</div>}
      </article>
    </div>
  </>;
}

function HealthRow({ label, count }: { label: string; count: number }) {
  return <div className="health-row"><span>{label}</span><strong className={count ? "warn" : ""}>{count}</strong></div>;
}

function Login({ onLogin }: { onLogin: (user: { name?: string; email?: string; role?: string }) => void }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const submit = async (event: FormEvent) => {
    event.preventDefault();
    try {
      const result = await api<{ user: { name?: string; email?: string; role?: string }; csrfToken?: string }>("/api/auth/login", { method: "POST", body: JSON.stringify({ email, password }) });
      if (result.csrfToken) sessionStorage.setItem("cms_csrf_token", result.csrfToken);
      onLogin(result.user);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Sign in failed");
    }
  };
  return <div className="login-screen"><form className="login-card" onSubmit={submit}><div className="brand-mark"><Leaf size={24} /></div><p className="eyebrow">Adventure Safari Africa</p><h1>CMS sign in</h1><label>Email<input type="email" autoComplete="username" value={email} onChange={(event) => setEmail(event.target.value)} required autoFocus /></label><label>Password<input type="password" autoComplete="current-password" value={password} onChange={(event) => setPassword(event.target.value)} required /></label>{error && <div className="alert">{error}</div>}<button className="primary-button" type="submit">Sign in securely</button></form></div>;
}

function ModulePlaceholder({ name }: { name: string }) {
  const endpointMap: Record<string, string> = {
    "Website Pages": "pages", "Safari Packages": "packages", Destinations: "destinations", "National Parks": "parks",
    "Safari Experiences": "experiences", Accommodation: "accommodation", "Travel Guides": "guides", "Blog Management": "blogs",
    "Translation Centre": "translations", "SEO Management": "pages", "Media Library": "media",
    "Navigation Management": "navigation", "Revision History": "revisions", "Publishing Centre": "publishing", Settings: "users"
  };
  const endpoint = endpointMap[name] || "pages";
  if (name === "Website Pages") return <WebsitePageModule />;
  if (name === "Publishing Centre") return <PublishingCentre />;
  if (name === "Media Library") return <MediaLibrary />;
  return <DataModule name={name} endpoint={endpoint} />;
}

function MediaLibrary() {
  const [rows, setRows] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [message, setMessage] = useState("");
  const load = () => api<{ rows: any[] }>(`/api/media?search=${encodeURIComponent(search)}&limit=100`)
    .then((result) => setRows(result.rows))
    .catch((error) => setMessage(error instanceof Error ? error.message : "Unable to load media"));
  useEffect(() => { void load(); }, [search]);
  const upload = async (files: FileList | null) => {
    if (!files?.length) return;
    try {
      for (const file of Array.from(files)) {
        const form = new FormData();
        form.append("file", file);
        form.append("folder", "uploads");
        await api("/api/media/upload", { method: "POST", body: form });
      }
      setMessage(`${files.length} file${files.length === 1 ? "" : "s"} uploaded.`);
      await load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Upload failed");
    }
  };
  return <>
    <div className="page-heading"><div><p className="eyebrow">Site assets</p><h1>Media Library</h1><p>Uploaded images and website assets</p></div><label className="primary-button upload-button">Upload media<input type="file" multiple accept="image/*" onChange={(event) => { void upload(event.currentTarget.files); event.currentTarget.value = ""; }} /></label></div>
    <div className="panel data-panel">
      <div className="table-toolbar"><div className="search"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search media..." /></div></div>
      {message && <div className="notice">{message}</div>}
      <div className="media-grid">{rows.map((item) => <article className="media-card" key={item.id}>{item.mimeType?.startsWith("image/") && item.storageKey ? <img src={`/cms-media/${item.storageKey}`} alt={item.altText || item.fileName || ""} /> : <div className="media-file"><Image size={28} /></div>}<strong>{item.fileName || item.storageKey}</strong><small>{item.mimeType || "file"} · {item.byteSize ? `${Math.round(item.byteSize / 1024)} KB` : ""}</small></article>)}</div>
      {!rows.length && <div className="empty-state"><Image size={28} /><h2>No media uploaded</h2><p>Upload an image to add it to the library.</p></div>}
    </div>
  </>;
}

function PublishingCentre() {
  const [builds, setBuilds] = useState<any[]>([]);
  const [languages, setLanguages] = useState(["en", "de", "fr", "es", "it"]);
  const [message, setMessage] = useState("");
  const [exporting, setExporting] = useState("");
  const load = () => api<{ builds: any[] }>("/api/publisher/builds").then((result) => setBuilds(result.builds)).catch((error) => setMessage(error.message));
  useEffect(() => { void load(); }, []);
  const createBuild = async () => {
    try {
      const result = await api<{ buildId: string; pageCount: number; issueCount: number }>("/api/publisher/build", {
        method: "POST",
        body: JSON.stringify({ languages, label: "dashboard-build" })
      });
      setMessage(`Staging build ${result.buildId} created with ${result.pageCount} pages and ${result.issueCount} validation issues.`);
      load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Build failed");
    }
  };
  const toggleLanguage = (language: string) => setLanguages((current) => current.includes(language) ? current.filter((code) => code !== language) : [...current, language]);
  const exportBuild = async (buildId: string) => {
    const csrfToken = sessionStorage.getItem("cms_csrf_token");
    try {
      setExporting(buildId);
      const response = await fetch("/api/publisher/export", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json", ...(csrfToken ? { "X-CSRF-Token": csrfToken } : {}) },
        body: JSON.stringify({ buildId })
      });
      if (!response.ok) throw new Error((await response.json()).error || "Export failed");
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `${buildId}.zip`;
      link.click();
      URL.revokeObjectURL(url);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Export failed");
    } finally {
      setExporting("");
    }
  };
  return <>
    <div className="page-heading"><div><p className="eyebrow">Publishing</p><h1>Publishing Centre</h1><p>Build the published static website for local preview and hosting export.</p></div><button className="primary-button" disabled={!languages.length} onClick={createBuild}>Build website</button></div>
    <div className="dashboard-grid"><article className="panel"><div className="panel-heading"><div><h2>Languages</h2><p>Select languages included in the next build</p></div></div>{["en", "de", "fr", "es", "it"].map((language) => <label className="language-checkbox" key={language}><input type="checkbox" checked={languages.includes(language)} onChange={() => toggleLanguage(language)} />{language.toUpperCase()}</label>)}</article><article className="panel"><div className="panel-heading"><div><h2>Website builds</h2><p>Builds are also available for local preview and ZIP export</p></div></div>{message && <div className="notice">{message}</div>}{builds.length ? builds.map((build) => <div className="activity-row" key={build.buildId}><div className="activity-icon"><Archive size={16} /></div><div><strong>{build.buildId}</strong><span>{build.pageCount || 0} pages · {build.issueCount || 0} issues</span></div><button className="secondary-button" disabled={exporting === build.buildId} onClick={() => exportBuild(build.buildId)}>{exporting === build.buildId ? "Creating ZIP…" : "Export ZIP"}</button></div>) : <div className="empty">No builds yet</div>}</article></div>
  </>;
}

const BLOCK_TYPES = [
  "Hero section", "Rich text", "Heading and paragraph", "Image section", "Image gallery",
  "Destination cards", "Safari package cards", "Call to action", "Table", "FAQs",
  "Table of contents", "Itinerary", "Wildlife information", "Accommodation section",
  "Related articles", "Related destinations", "Custom HTML"
];

function escapePreview(value: string) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function resolveWebsiteImage(value?: string) {
  if (!value) return "";
  if (/^(https?:|data:|blob:)/i.test(value)) return value;
  const normalized = value.startsWith("/") ? value : `/${value}`;
  return `${window.location.protocol}//${window.location.hostname}:3001${normalized}`;
}

function pageCategory(row: any) {
  const path = String(row.fullPath || row.sourcePath || "").toLowerCase().replace(/^\/+/, "");
  if (/\bblog\b/.test(path)) return "Blog articles";
  if (path.includes("national-parks")) return "National parks and reserves";
  if (path.includes("/packages") || /-(safari|tour)/.test(path)) return "Safari packages";
  if (path.includes("accommodation")) return "Accommodation";
  if (path.includes("travel-guide")) return "Travel guides";
  if (path.includes("activities")) return "Safari activities";
  if (/(safari|safaris)\b/.test(path)) return "Safari destinations";
  return row.pageType === "category" ? "Categories" : "Website pages";
}

function pageCountry(row: any) {
  const path = String(row.fullPath || "").toLowerCase();
  return ["tanzania", "kenya", "uganda", "botswana", "namibia", "south-africa", "ethiopia"].find((country) => path.includes(country))?.replace("south-africa", "South Africa")
    .replace(/^(.)/, (letter) => letter.toUpperCase()) || "";
}

function VisualContentEditor({ value, onChange }: { value: string; onChange: (value: string) => void }) {
  const [element, setElement] = useState<HTMLDivElement | null>(null);
  useEffect(() => {
    if (element && element.innerHTML !== value) element.innerHTML = value;
  }, [value, element]);
  const format = (command: string, commandValue?: string) => {
    element?.focus();
    document.execCommand(command, false, commandValue);
    if (element) onChange(element.innerHTML);
  };
  const addLink = () => {
    const url = window.prompt("Enter the link URL");
    if (url) format("createLink", url);
  };
  return <div className="visual-editor">
    <div className="editor-toolbar" role="toolbar" aria-label="Formatting controls">
      <button type="button" onClick={() => format("formatBlock", "h2")}>H2</button>
      <button type="button" onClick={() => format("formatBlock", "h3")}>H3</button>
      <button type="button" onClick={() => format("bold")}><strong>B</strong></button>
      <button type="button" onClick={() => format("italic")}><em>I</em></button>
      <button type="button" onClick={() => format("insertUnorderedList")}>List</button>
      <button type="button" onClick={() => format("insertOrderedList")}>Numbered list</button>
      <button type="button" onClick={addLink}>Link</button>
      <button type="button" onClick={() => format("insertHorizontalRule")}>Divider</button>
    </div>
    <div ref={setElement} className="visual-editor-content" contentEditable suppressContentEditableWarning
      onInput={(event) => onChange(event.currentTarget.innerHTML)} aria-label="Page content editor" />
  </div>;
}

function WebsitePageModule() {
  const [data, setData] = useState<{ rows: any[]; total?: number }>({ rows: [] });
  const [search, setSearch] = useState("");
  const [type, setType] = useState("");
  const [draft, setDraft] = useState<any | null>(null);
  const [message, setMessage] = useState("");
  const [language, setLanguage] = useState("");
  const [showPreview, setShowPreview] = useState(false);
  const [category, setCategory] = useState("");
  const [country, setCountry] = useState("");
  const [page, setPage] = useState(1);
  const [pageSize] = useState(24);
  const load = () => api<{ rows: any[]; total?: number }>(`/api/pages?search=${encodeURIComponent(search)}&limit=2000${type ? `&type=${encodeURIComponent(type)}` : ""}${language ? `&language=${encodeURIComponent(language)}` : ""}`)
    .then(setData)
    .catch((error) => setMessage(error.message));
  useEffect(() => { void load(); }, [search, type, language]);
  const save = async () => {
    if (!draft?.id) return;
    try {
      await api(`/api/pages/${draft.id}`, { method: "PATCH", body: JSON.stringify({
        title: draft.title,
        h1: draft.h1,
        description: draft.description,
        contentHtml: draft.contentHtml,
        status: draft.status,
        canonicalUrl: draft.canonicalUrl,
        ogTitle: draft.ogTitle,
        ogDescription: draft.ogDescription,
        ogImage: draft.ogImage,
        robots: draft.robots,
        featuredImage: draft.featuredImage,
      }) });
      setMessage("Page saved to PostgreSQL.");
      await load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Unable to save page");
    }
  };
  const publish = async () => {
    if (!draft?.id) return;
    try {
      await api(`/api/pages/${draft.id}`, { method: "PATCH", body: JSON.stringify({
        title: draft.title,
        h1: draft.h1,
        description: draft.description,
        contentHtml: draft.contentHtml,
        status: "published",
        canonicalUrl: draft.canonicalUrl,
        ogTitle: draft.ogTitle,
        ogDescription: draft.ogDescription,
        ogImage: draft.ogImage,
        robots: draft.robots,
        featuredImage: draft.featuredImage,
      }) });
      setDraft({ ...draft, status: "published" });
      setMessage("Page published in PostgreSQL.");
      await load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Unable to publish page");
    }
  };
  const remove = async (id: string) => {
    if (!window.confirm("Delete this page translation? The original website file will not be modified.")) return;
    await api(`/api/pages/${id}`, { method: "DELETE" });
    setDraft(null);
    await load();
  };
  const filteredRows = data.rows.filter((row) => (!category || pageCategory(row) === category) && (!country || pageCountry(row) === country));
  const pageCount = Math.max(1, Math.ceil(filteredRows.length / pageSize));
  const visibleRows = filteredRows.slice((Math.min(page, pageCount) - 1) * pageSize, Math.min(page, pageCount) * pageSize);
  const categories = Array.from(new Set(data.rows.map(pageCategory))).sort();
  const countries = Array.from(new Set(data.rows.map(pageCountry).filter(Boolean))).sort();
  const previewHtml = draft ? `<!doctype html><html><head><base href="http://localhost:3001/"><meta charset="utf-8"><title>${escapePreview(draft.title || "")}</title><meta name="description" content="${escapePreview(draft.description || "")}"><style>body{margin:0;font-family:Arial,sans-serif;color:#18352f}.preview-header{padding:18px 24px;background:#16362f;color:white}.preview-content{max-width:980px;margin:0 auto;padding:32px 24px}.preview-content img{max-width:100%;height:auto}h1{font-family:Georgia,serif;font-size:42px}a{color:#a77a27}</style></head><body><header class="preview-header">Adventure Safari Africa - Draft preview</header><main class="preview-content"><h1>${escapePreview(draft.h1 || draft.title || "")}</h1>${draft.contentHtml || ""}</main></body></html>` : "";
  return <>
    <div className="page-heading"><div><p className="eyebrow">Content management</p><h1>Website Pages</h1><p>{data.total ?? data.rows.length} imported page translations</p></div></div>
    <div className="panel data-panel"><div className="table-toolbar">
      <div className="search"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search imported pages..." /></div>
      <select value={type} onChange={(event) => setType(event.target.value)}><option value="">All types</option><option value="blog">Blog articles</option><option value="page">Pages</option><option value="destination">Destinations</option><option value="category">Categories</option><option value="error">System pages</option></select>
      <select value={language} onChange={(event) => setLanguage(event.target.value)} aria-label="Filter by language"><option value="">All languages</option>{["en", "de", "fr", "es", "it"].map((code) => <option key={code} value={code}>{code.toUpperCase()}</option>)}</select>
      <select value={category} onChange={(event) => { setCategory(event.target.value); setPage(1); }} aria-label="Filter by category"><option value="">All categories</option>{categories.map((item) => <option key={item} value={item}>{item}</option>)}</select>
      <select value={country} onChange={(event) => { setCountry(event.target.value); setPage(1); }} aria-label="Filter by country"><option value="">All countries</option>{countries.map((item) => <option key={item} value={item}>{item}</option>)}</select>
    </div>{message && <div className="notice">{message}</div>}
      <div className="page-list">{visibleRows.map((row: any) => <article className="page-list-row" key={row.id}>
        <div className="page-thumbnail">{resolveWebsiteImage(row.featuredImage) ? <img src={resolveWebsiteImage(row.featuredImage)} alt="" onError={(event) => { event.currentTarget.style.display = "none"; }} /> : <FileText size={22} />}</div>
        <div className="page-list-main"><strong>{row.title || row.fullPath}</strong><small>{pageCategory(row)}{pageCountry(row) ? ` · ${pageCountry(row)}` : ""} · {row.language?.toUpperCase()}</small><a href={`${window.location.protocol}//${window.location.hostname}:3001${row.fullPath || "/"}`} target="_blank" rel="noreferrer">{row.fullPath}</a></div>
        <span className={`status-badge status-${String(row.status || "draft").replace("_", "-")}`}>{row.status || "draft"}</span>
        <div className="row-actions"><button onClick={() => setDraft(row)}>Quick edit</button><button onClick={() => setDraft(row)}>Full editor</button><button className="danger" onClick={() => remove(row.id)}>Delete</button></div>
      </article>)}</div>
      {filteredRows.length > pageSize && <div className="pagination"><button disabled={page <= 1} onClick={() => setPage((current) => Math.max(1, current - 1))}>Previous</button><span>Page {Math.min(page, pageCount)} of {pageCount}</span><button disabled={page >= pageCount} onClick={() => setPage((current) => Math.min(pageCount, current + 1))}>Next</button></div>}
      {!data.rows.length && <div className="empty-state"><FileText size={28} /><h2>No matching pages</h2></div>}
    </div>
    {draft && <div className="modal-backdrop" onMouseDown={() => setDraft(null)}><form className="modal page-editor-modal" onSubmit={(event) => { event.preventDefault(); void save(); }} onMouseDown={(event) => event.stopPropagation()}>
      <div className="panel-heading"><h2>Edit imported page</h2><button type="button" className="icon-button" onClick={() => setDraft(null)}><X /></button></div>
      <label>URL<input value={draft.fullPath || ""} readOnly /></label>
      <label>Title<input value={draft.title || ""} onChange={(event) => setDraft({ ...draft, title: event.target.value })} /></label>
      <label>H1<input value={draft.h1 || ""} onChange={(event) => setDraft({ ...draft, h1: event.target.value })} /></label>
      <label>Meta description<textarea rows={3} value={draft.description || ""} onChange={(event) => setDraft({ ...draft, description: event.target.value })} /></label>
      <label>Status<select value={draft.status || "draft"} onChange={(event) => setDraft({ ...draft, status: event.target.value })}><option value="draft">Draft</option><option value="in_review">In review</option><option value="approved">Approved</option><option value="published">Published</option><option value="archived">Archived</option></select></label>
      <label>Canonical URL<input value={draft.canonicalUrl || ""} onChange={(event) => setDraft({ ...draft, canonicalUrl: event.target.value })} /></label>
      <label>Featured image<input value={draft.featuredImage || ""} onChange={(event) => setDraft({ ...draft, featuredImage: event.target.value })} /></label>
      <label>Visual content</label>
      <VisualContentEditor value={draft.contentHtml || ""} onChange={(contentHtml) => setDraft({ ...draft, contentHtml })} />
      <details className="advanced-source"><summary>Advanced HTML</summary><textarea className="content-html-editor" rows={12} value={draft.contentHtml || ""} onChange={(event) => setDraft({ ...draft, contentHtml: event.target.value })} /></details>
      <div className="editor-actions"><button className="secondary-button" type="button" onClick={() => setShowPreview(true)}>Preview</button><button className="secondary-button" type="button" onClick={() => void publish()}>Publish</button><button className="primary-button" type="submit">Save page</button></div>
    </form></div>}
    {draft && showPreview && <div className="modal-backdrop" onMouseDown={() => setShowPreview(false)}><div className="preview-modal" onMouseDown={(event) => event.stopPropagation()}><div className="panel-heading"><h2>Draft preview</h2><button className="icon-button" type="button" onClick={() => setShowPreview(false)}><X /></button></div><iframe title="Page draft preview" srcDoc={previewHtml} /></div></div>}
  </>;
}

type ContentBlock = { id: string; type: string; content: string; hidden: boolean };

function BlockPageModule() {
  const [blocks, setBlocks] = useState<ContentBlock[]>([]);
  const [type, setType] = useState(BLOCK_TYPES[0]);
  const [language, setLanguage] = useState("en");
  const addBlock = () => setBlocks((current) => [...current, { id: crypto.randomUUID(), type, content: "", hidden: false }]);
  const move = (index: number, direction: -1 | 1) => setBlocks((current) => {
    const target = index + direction;
    if (target < 0 || target >= current.length) return current;
    const next = [...current];
    [next[index], next[target]] = [next[target], next[index]];
    return next;
  });
  const save = async () => {
    await Promise.all(blocks.map((block, position) => api("/api/blocks", { method: "POST", body: JSON.stringify({
      language,
      type: block.type,
      position,
      hidden: block.hidden,
      content: block.content
    }) })));
  };
  return <>
    <div className="page-heading"><div><p className="eyebrow">Visual editor</p><h1>Website Pages</h1><p>Build page content with independently editable content blocks.</p></div><div className="editor-actions"><select value={language} onChange={(event) => setLanguage(event.target.value)}>{["en", "de", "fr", "es", "it"].map((code) => <option key={code} value={code}>{code.toUpperCase()}</option>)}</select><button className="primary-button" onClick={save}>Save blocks</button></div></div>
    <div className="editor-layout">
      <aside className="panel block-library"><h2>Add block</h2><select value={type} onChange={(event) => setType(event.target.value)}>{BLOCK_TYPES.map((blockType) => <option key={blockType}>{blockType}</option>)}</select><button className="primary-button" onClick={addBlock}>+ Add block</button></aside>
      <section className="panel block-canvas"><h2>{language.toUpperCase()} page blocks</h2>{blocks.length === 0 ? <div className="empty-state">Add a block to begin editing this language.</div> : blocks.map((block, index) => <article className="content-block" key={block.id}><div className="block-heading"><strong>{block.type}</strong><div><button onClick={() => move(index, -1)}>Up</button><button onClick={() => move(index, 1)}>Down</button><button onClick={() => setBlocks((current) => current.map((row) => row.id === block.id ? { ...row, hidden: !row.hidden } : row))}>{block.hidden ? "Show" : "Hide"}</button><button onClick={() => setBlocks((current) => [...current, { ...block, id: crypto.randomUUID() }])}>Duplicate</button><button className="danger" onClick={() => setBlocks((current) => current.filter((row) => row.id !== block.id))}>Delete</button></div></div>{block.hidden ? <em>Hidden from published page</em> : <textarea value={block.content} onChange={(event) => setBlocks((current) => current.map((row) => row.id === block.id ? { ...row, content: event.target.value } : row))} rows={5} />}</article>)}</section>
    </div>
  </>;
}

function DataModule({ name, endpoint }: { name: string; endpoint: string }) {
  const [data, setData] = useState<{ rows: any[] }>({ rows: [] });
  const [search, setSearch] = useState("");
  const [formOpen, setFormOpen] = useState(false);
  const [draft, setDraft] = useState<Record<string, string>>({ title: "", status: "draft", language: "en" });
  const [message, setMessage] = useState("");

  const load = () => api<{ rows: any[] }>(`/api/${endpoint}?search=${encodeURIComponent(search)}`).then(setData).catch((error) => setMessage(error.message));
  useEffect(() => { void load(); }, [search]);

  const save = async (event: FormEvent) => {
    event.preventDefault();
    await api(`/api/${endpoint}${draft.id ? `/${draft.id}` : ""}`, { method: draft.id ? "PATCH" : "POST", body: JSON.stringify(draft) });
    setFormOpen(false);
    setDraft({ title: "", status: "draft", language: "en" });
    setMessage(`${name} created`);
    load();
  };
  const remove = async (id: string) => {
    if (!window.confirm("Delete this record? This action cannot be undone.")) return;
    await api(`/api/${endpoint}/${id}`, { method: "DELETE" });
    load();
  };
  return <>
    <div className="page-heading"><div><p className="eyebrow">Content management</p><h1>{name}</h1><p>Search, create, edit, archive and remove records.</p></div><button className="primary-button" onClick={() => setFormOpen(true)}>+ Add new</button></div>
    <div className="panel data-panel"><div className="table-toolbar"><div className="search"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder={`Search ${name.toLowerCase()}...`} /></div></div>
      {message && <div className="notice">{message}</div>}
      {data.rows.length === 0 ? <div className="empty-state"><FileText size={28} /><h2>No records yet</h2><p>Create the first item for this module.</p></div> : <div className="data-table">{data.rows.map((row) => <div className="data-row" key={row.id}><div><strong>{row.title || row.name || row.fileName || row.label || row.email || row.id}</strong><small>{row.language?.toUpperCase()} · {row.status || "active"}</small></div><div className="row-actions"><button onClick={() => { setDraft(row); setFormOpen(true); }}>Edit</button><button className="danger" onClick={() => remove(row.id)}>Delete</button></div></div>)}</div>}
    </div>
    {formOpen && <div className="modal-backdrop" onMouseDown={() => setFormOpen(false)}><form className="modal" onSubmit={save} onMouseDown={(event) => event.stopPropagation()}><div className="panel-heading"><h2>{draft.id ? "Edit" : "Create"} {name}</h2><button type="button" className="icon-button" onClick={() => setFormOpen(false)}><X /></button></div><label>Title / name<input required value={draft.title || draft.name || ""} onChange={(event) => setDraft({ ...draft, title: event.target.value })} /></label><label>Language<select value={draft.language || "en"} onChange={(event) => setDraft({ ...draft, language: event.target.value })}>{["en", "de", "fr", "es", "it"].map((code) => <option key={code} value={code}>{code.toUpperCase()}</option>)}</select></label><label>Status<select value={draft.status || "draft"} onChange={(event) => setDraft({ ...draft, status: event.target.value })}><option value="draft">Draft</option><option value="in_review">In review</option><option value="published">Published</option><option value="archived">Archived</option></select></label><button className="primary-button" type="submit">Save record</button></form></div>}
  </>;
}

const Icons: Record<string, boolean> = {};
