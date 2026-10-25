import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import {
  Search, Star, X, ChevronRight, ChevronDown,
  LayoutDashboard, FileText, Users, Settings, MessageSquare,
  Bell, Menu, ArrowLeft, Plus, List,
  Clock, CreditCard, DollarSign, Target, Award,
  Package, ShoppingCart, Truck, Clipboard,
  Download, Shield, Upload, Archive,
  Inbox, Calendar, Zap, Bookmark,
  Send, BarChart2, Grid, Heart, Folder, Box,
  Eye, Edit, AlertCircle,
  TrendingUp, Activity, Database, Globe,
  Mail, Phone, Layers,
  FileCheck, Pen,
  Building, Briefcase, GraduationCap, UserPlus,
  Link, GitBranch, HardDrive, Sliders,
  PieChart, LineChart, ArrowUpRight, BookOpen,
  Sun, Moon, ChevronsLeft, ChevronsRight,
  FilePlus, UserCheck, FolderPlus, BarChart, FileSearch,
  Tag, Percent, Receipt, Hash
} from "lucide-react";

// ══════════════════════════════════════════
// AI ENGINE
// ══════════════════════════════════════════
class MenuAI {
  constructor(){this.usage={};this.log=[];this.seq=[];this.tm={};this.ready=false}
  async init(){await new Promise(r=>setTimeout(r,400));this.ready=true}
  record(id){const h=new Date().getHours();this.usage[id]=(this.usage[id]||0)+1;this.log.push({id,t:Date.now(),h});this.seq.push(id);if(this.seq.length>30)this.seq.shift();this.tm[`${id}_${h}`]=(this.tm[`${id}_${h}`]||0)+1}
  predict(items,n=6){if(this.log.length<2)return items.slice(0,n).map(i=>({...i,score:.3,conf:.3}));const now=Date.now(),h=new Date().getHours();return items.map(m=>{const f=this.usage[m.id]||0;const tb=this.tm[`${m.id}_${h}`]||0;const rec=this.log.filter(l=>l.id===m.id).reduce((a,l)=>a+Math.exp(-(now-l.t)/864e5),0);let sq=0;if(this.seq.length>1){const last=this.seq[this.seq.length-1];sq=this.log.reduce((a,l,i)=>i>0&&this.log[i-1].id===last&&l.id===m.id?a+1:a,0)*2}return{...m,score:f+tb*2.5+rec*3+sq*1.5,conf:Math.min(.97,.25+f*.04+tb*.08)}}).sort((a,b)=>b.score-a.score).slice(0,n)}
  stats(){return{total:this.log.length,unique:new Set(this.log.map(l=>l.id)).size}}
  chatSearch(query,items){const q=query.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");const kws=q.split(/\s+/).filter(w=>w.length>1);if(!kws.length)return[];return items.map(item=>{const txt=`${item.name} ${item.desc} ${item.catName}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");let sc=0;kws.forEach(k=>{if(txt.includes(k))sc+=3;txt.split(/\s+/).forEach(w=>{if(w.startsWith(k.slice(0,3)))sc+=1})});return{...item,matchScore:sc+(this.usage[item.id]||0)*.5}}).filter(i=>i.matchScore>0).sort((a,b)=>b.matchScore-a.matchScore).slice(0,5)}
}

// ══════════════════════════════════════════
// MENU DATA — 3 LEVELS DEEP
// ══════════════════════════════════════════
const CATS = [
  { id:"dashboard", name:"Irányítópult", Ic:LayoutDashboard, color:"#6366f1", items:[
    { id:"dash-main", name:"Fő Dashboard", Ic:LayoutDashboard, desc:"Átfogó üzleti metrikák", subs:[
      {id:"dash-main-view",name:"Megtekintés",Ic:Eye},{id:"dash-main-edit",name:"Szerkesztés",Ic:Edit}
    ]},
    { id:"dash-kpi", name:"KPI Monitor", Ic:Target, desc:"Kulcs teljesítménymutatók", subs:[
      {id:"dash-kpi-list",name:"KPI Lista",Ic:List},{id:"dash-kpi-add",name:"Új KPI",Ic:Plus}
    ]},
    { id:"dash-rt", name:"Valós idejű", Ic:Zap, desc:"Élő adatfolyamok", subs:[] },
    { id:"dash-custom", name:"Egyéni nézet", Ic:Sliders, desc:"Személyre szabott dashboard", subs:[
      {id:"dash-custom-list",name:"Nézetek",Ic:List},{id:"dash-custom-add",name:"Új nézet",Ic:Plus}
    ]},
  ]},
  { id:"documents", name:"Dokumentumok", Ic:FileText, color:"#8b5cf6", items:[
    { id:"doc-in", name:"Bejövő", Ic:Inbox, desc:"Bejövő dokumentumok", subs:[
      {id:"doc-in-list",name:"Lista",Ic:List},{id:"doc-in-add",name:"Új dokumentum",Ic:FilePlus},{id:"doc-in-search",name:"Keresés",Ic:FileSearch}
    ]},
    { id:"doc-out", name:"Kimenő", Ic:Upload, desc:"Kimenő dokumentumok", subs:[
      {id:"doc-out-list",name:"Lista",Ic:List},{id:"doc-out-add",name:"Új kimenő",Ic:FilePlus}
    ]},
    { id:"doc-arch", name:"Archívum", Ic:Archive, desc:"Archivált dokumentumok", subs:[
      {id:"doc-arch-list",name:"Archívum böngészés",Ic:List},{id:"doc-arch-search",name:"Keresés",Ic:FileSearch}
    ]},
    { id:"doc-tpl", name:"Sablonok", Ic:Layers, desc:"Dokumentum sablonok", subs:[
      {id:"doc-tpl-list",name:"Sablon lista",Ic:List},{id:"doc-tpl-add",name:"Új sablon",Ic:Plus}
    ]},
    { id:"doc-sign", name:"Aláírásra vár", Ic:Pen, desc:"Aláírásra váró dokumentumok", subs:[
      {id:"doc-sign-list",name:"Várakozó lista",Ic:List}
    ]},
    { id:"doc-scan", name:"Szkennelés", Ic:Eye, desc:"Dokumentum szkennelés OCR", subs:[
      {id:"doc-scan-new",name:"Új szkennelés",Ic:Plus},{id:"doc-scan-list",name:"Előzmények",Ic:List}
    ]},
  ]},
  { id:"finance", name:"Pénzügy", Ic:CreditCard, color:"#0891b2", items:[
    { id:"fin-inv", name:"Számlák", Ic:FileCheck, desc:"Számla kezelés", subs:[
      {id:"fin-inv-list",name:"Számla lista",Ic:List},{id:"fin-inv-add",name:"Új számla",Ic:Plus},{id:"fin-inv-draft",name:"Piszkozatok",Ic:Edit},{id:"fin-inv-recurring",name:"Ismétlődő",Ic:Clock}
    ]},
    { id:"fin-pay", name:"Kifizetések", Ic:CreditCard, desc:"Fizetési műveletek", subs:[
      {id:"fin-pay-list",name:"Tranzakciók",Ic:List},{id:"fin-pay-new",name:"Új kifizetés",Ic:Plus},{id:"fin-pay-pending",name:"Függőben",Ic:Clock}
    ]},
    { id:"fin-bud", name:"Költségvetés", Ic:PieChart, desc:"Költségvetés tervezés", subs:[
      {id:"fin-bud-view",name:"Áttekintés",Ic:Eye},{id:"fin-bud-plan",name:"Tervezés",Ic:Edit}
    ]},
    { id:"fin-tax", name:"Adóügyek", Ic:Building, desc:"Adóbevallás és nyilvántartás", subs:[
      {id:"fin-tax-list",name:"Bevallások",Ic:List},{id:"fin-tax-calc",name:"Kalkulátor",Ic:Percent}
    ]},
    { id:"fin-cf", name:"Cash Flow", Ic:TrendingUp, desc:"Pénzforgalom elemzés", subs:[
      {id:"fin-cf-view",name:"Áttekintés",Ic:Eye},{id:"fin-cf-forecast",name:"Előrejelzés",Ic:TrendingUp}
    ]},
    { id:"fin-rep", name:"Pénzügyi riportok", Ic:BarChart2, desc:"Pénzügyi jelentések", subs:[
      {id:"fin-rep-list",name:"Riportok",Ic:List},{id:"fin-rep-new",name:"Új riport",Ic:Plus}
    ]},
    { id:"fin-bank", name:"Banki műveletek", Ic:Building, desc:"Banki integráció", subs:[
      {id:"fin-bank-list",name:"Műveletek",Ic:List},{id:"fin-bank-sync",name:"Szinkronizálás",Ic:Link}
    ]},
  ]},
  { id:"hr", name:"HR & Személyzet", Ic:Users, color:"#d97706", items:[
    { id:"hr-emp", name:"Dolgozók", Ic:Users, desc:"Munkavállalói adatbázis", subs:[
      {id:"hr-emp-list",name:"Dolgozó lista",Ic:List},{id:"hr-emp-add",name:"Új dolgozó",Ic:UserPlus},{id:"hr-emp-org",name:"Szervezeti ábra",Ic:GitBranch}
    ]},
    { id:"hr-att", name:"Jelenlét", Ic:Clock, desc:"Jelenléti ívek", subs:[
      {id:"hr-att-today",name:"Mai jelenlét",Ic:Eye},{id:"hr-att-list",name:"Előzmények",Ic:List},{id:"hr-att-report",name:"Riport",Ic:BarChart2}
    ]},
    { id:"hr-leave", name:"Szabadságok", Ic:Calendar, desc:"Szabadság kezelés", subs:[
      {id:"hr-leave-list",name:"Kérelmek",Ic:List},{id:"hr-leave-add",name:"Új kérelem",Ic:Plus},{id:"hr-leave-calendar",name:"Naptár nézet",Ic:Calendar}
    ]},
    { id:"hr-pay", name:"Bérszámfejtés", Ic:DollarSign, desc:"Bérszámfejtés és juttatások", subs:[
      {id:"hr-pay-run",name:"Futtatás",Ic:Zap},{id:"hr-pay-history",name:"Előzmények",Ic:List},{id:"hr-pay-slips",name:"Bérlap nyomtatás",Ic:FileText}
    ]},
    { id:"hr-rec", name:"Toborzás", Ic:UserPlus, desc:"Álláshirdetések és pályázók", subs:[
      {id:"hr-rec-jobs",name:"Pozíciók",Ic:List},{id:"hr-rec-add",name:"Új pozíció",Ic:Plus},{id:"hr-rec-apps",name:"Pályázók",Ic:Users}
    ]},
    { id:"hr-perf", name:"Teljesítmény", Ic:Award, desc:"Értékelések és célok", subs:[
      {id:"hr-perf-reviews",name:"Értékelések",Ic:List},{id:"hr-perf-goals",name:"Célok",Ic:Target}
    ]},
    { id:"hr-train", name:"Képzések", Ic:GraduationCap, desc:"Oktatás és fejlesztés", subs:[
      {id:"hr-train-list",name:"Képzés lista",Ic:List},{id:"hr-train-add",name:"Új képzés",Ic:Plus},{id:"hr-train-enroll",name:"Beiratkozás",Ic:UserCheck}
    ]},
  ]},
  { id:"crm", name:"CRM & Ügyfelek", Ic:Heart, color:"#db2777", items:[
    { id:"crm-con", name:"Kapcsolatok", Ic:Phone, desc:"Kapcsolattartók", subs:[
      {id:"crm-con-list",name:"Lista",Ic:List},{id:"crm-con-add",name:"Új kapcsolat",Ic:Plus},{id:"crm-con-import",name:"Importálás",Ic:Upload}
    ]},
    { id:"crm-deal", name:"Üzletek", Ic:Briefcase, desc:"Értékesítési pipeline", subs:[
      {id:"crm-deal-board",name:"Pipeline nézet",Ic:Layers},{id:"crm-deal-list",name:"Lista",Ic:List},{id:"crm-deal-add",name:"Új üzlet",Ic:Plus}
    ]},
    { id:"crm-tick", name:"Jegyek", Ic:AlertCircle, desc:"Ügyfélszolgálati jegyek", subs:[
      {id:"crm-tick-list",name:"Nyitott jegyek",Ic:List},{id:"crm-tick-add",name:"Új jegy",Ic:Plus},{id:"crm-tick-closed",name:"Lezárt",Ic:Archive}
    ]},
    { id:"crm-camp", name:"Kampányok", Ic:Globe, desc:"Marketing kampányok", subs:[
      {id:"crm-camp-list",name:"Kampány lista",Ic:List},{id:"crm-camp-add",name:"Új kampány",Ic:Plus},{id:"crm-camp-stats",name:"Statisztikák",Ic:BarChart2}
    ]},
    { id:"crm-anal", name:"Ügyfél analitika", Ic:LineChart, desc:"Ügyfél viselkedés elemzés", subs:[
      {id:"crm-anal-dash",name:"Dashboard",Ic:LayoutDashboard},{id:"crm-anal-segments",name:"Szegmensek",Ic:Tag}
    ]},
  ]},
  { id:"projects", name:"Projektek", Ic:Folder, color:"#059669", items:[
    { id:"proj-board", name:"Kanban tábla", Ic:Layers, desc:"Projekt feladatok kezelése", subs:[
      {id:"proj-board-view",name:"Tábla nézet",Ic:Grid},{id:"proj-board-add",name:"Új feladat",Ic:Plus}
    ]},
    { id:"proj-gantt", name:"Gantt diagram", Ic:BarChart2, desc:"Idővonalas tervezés", subs:[] },
    { id:"proj-tasks", name:"Feladatok", Ic:Clipboard, desc:"Feladat lista", subs:[
      {id:"proj-tasks-list",name:"Lista",Ic:List},{id:"proj-tasks-add",name:"Új feladat",Ic:Plus},{id:"proj-tasks-my",name:"Saját feladatok",Ic:UserCheck}
    ]},
    { id:"proj-mile", name:"Mérföldkövek", Ic:Target, desc:"Projekt mérföldkövek", subs:[
      {id:"proj-mile-list",name:"Lista",Ic:List},{id:"proj-mile-add",name:"Új mérföldkő",Ic:Plus}
    ]},
    { id:"proj-res", name:"Erőforrások", Ic:Settings, desc:"Erőforrás allokáció", subs:[] },
    { id:"proj-time", name:"Időkövetés", Ic:Clock, desc:"Munkaidő nyilvántartás", subs:[
      {id:"proj-time-log",name:"Naplózás",Ic:Plus},{id:"proj-time-list",name:"Előzmények",Ic:List},{id:"proj-time-report",name:"Riport",Ic:BarChart2}
    ]},
  ]},
  { id:"warehouse", name:"Raktár & Logisztika", Ic:Box, color:"#ea580c", items:[
    { id:"wh-stock", name:"Készlet", Ic:Package, desc:"Aktuális készlet állapot", subs:[
      {id:"wh-stock-list",name:"Készlet lista",Ic:List},{id:"wh-stock-add",name:"Bevételezés",Ic:Plus},{id:"wh-stock-adjust",name:"Korrekció",Ic:Edit}
    ]},
    { id:"wh-ord", name:"Rendelések", Ic:ShoppingCart, desc:"Beszerzési rendelések", subs:[
      {id:"wh-ord-list",name:"Rendelés lista",Ic:List},{id:"wh-ord-add",name:"Új rendelés",Ic:Plus},{id:"wh-ord-pending",name:"Függőben",Ic:Clock}
    ]},
    { id:"wh-ship", name:"Szállítás", Ic:Truck, desc:"Szállítmányok követése", subs:[
      {id:"wh-ship-active",name:"Aktív szállítások",Ic:List},{id:"wh-ship-new",name:"Új szállítmány",Ic:Plus}
    ]},
    { id:"wh-inv", name:"Leltár", Ic:Clipboard, desc:"Leltár kezelés", subs:[
      {id:"wh-inv-start",name:"Leltár indítás",Ic:Plus},{id:"wh-inv-list",name:"Előzmények",Ic:List}
    ]},
    { id:"wh-sup", name:"Beszállítók", Ic:Building, desc:"Beszállítói adatbázis", subs:[
      {id:"wh-sup-list",name:"Lista",Ic:List},{id:"wh-sup-add",name:"Új beszállító",Ic:Plus}
    ]},
  ]},
  { id:"reports", name:"Riportok & BI", Ic:BarChart2, color:"#0d9488", items:[
    { id:"rep-build", name:"Riport készítő", Ic:Edit, desc:"Egyéni riport szerkesztő", subs:[
      {id:"rep-build-new",name:"Új riport",Ic:Plus},{id:"rep-build-saved",name:"Mentett riportok",Ic:List}
    ]},
    { id:"rep-sched", name:"Ütemezett", Ic:Mail, desc:"Automatikus riportok", subs:[
      {id:"rep-sched-list",name:"Ütemezések",Ic:List},{id:"rep-sched-add",name:"Új ütemezés",Ic:Plus}
    ]},
    { id:"rep-pivot", name:"Pivot táblák", Ic:Database, desc:"Interaktív pivot elemzés", subs:[] },
    { id:"rep-exp", name:"Exportálás", Ic:Download, desc:"Adatok exportálása", subs:[] },
    { id:"rep-bi", name:"BI Dashboard", Ic:Activity, desc:"Üzleti intelligencia", subs:[
      {id:"rep-bi-view",name:"Dashboard",Ic:LayoutDashboard},{id:"rep-bi-config",name:"Konfiguráció",Ic:Settings}
    ]},
  ]},
  { id:"settings", name:"Rendszer", Ic:Settings, color:"#64748b", items:[
    { id:"set-usr", name:"Felhasználók", Ic:Users, desc:"Felhasználó kezelés", subs:[
      {id:"set-usr-list",name:"Lista",Ic:List},{id:"set-usr-add",name:"Meghívás",Ic:UserPlus},{id:"set-usr-groups",name:"Csoportok",Ic:Users}
    ]},
    { id:"set-role", name:"Jogosultságok", Ic:Shield, desc:"Szerepkörök és jogok", subs:[
      {id:"set-role-list",name:"Szerepkörök",Ic:List},{id:"set-role-add",name:"Új szerepkör",Ic:Plus}
    ]},
    { id:"set-wf", name:"Munkafolyamatok", Ic:GitBranch, desc:"Automatizálási szabályok", subs:[
      {id:"set-wf-list",name:"Folyamatok",Ic:List},{id:"set-wf-add",name:"Új folyamat",Ic:Plus}
    ]},
    { id:"set-int", name:"Integrációk", Ic:Link, desc:"Külső rendszer csatlakozások", subs:[
      {id:"set-int-list",name:"Aktív",Ic:List},{id:"set-int-browse",name:"Böngészés",Ic:Globe}
    ]},
    { id:"set-audit", name:"Audit napló", Ic:BookOpen, desc:"Rendszer események", subs:[] },
    { id:"set-back", name:"Mentések", Ic:HardDrive, desc:"Adatmentés és visszaállítás", subs:[
      {id:"set-back-list",name:"Mentések",Ic:List},{id:"set-back-new",name:"Új mentés",Ic:Plus}
    ]},
    { id:"set-gen", name:"Általános", Ic:Sliders, desc:"Rendszer beállítások", subs:[] },
  ]},
  { id:"comm", name:"Kommunikáció", Ic:MessageSquare, color:"#7c3aed", items:[
    { id:"com-inbox", name:"Beérkező", Ic:Inbox, desc:"Belső üzenetek", subs:[
      {id:"com-inbox-list",name:"Üzenetek",Ic:List},{id:"com-inbox-new",name:"Új üzenet",Ic:Plus},{id:"com-inbox-sent",name:"Elküldött",Ic:Send}
    ]},
    { id:"com-notif", name:"Értesítések", Ic:Bell, desc:"Rendszerértesítések", subs:[
      {id:"com-notif-list",name:"Összes",Ic:List},{id:"com-notif-settings",name:"Beállítások",Ic:Settings}
    ]},
    { id:"com-cal", name:"Naptár", Ic:Calendar, desc:"Esemény naptár", subs:[
      {id:"com-cal-view",name:"Naptár nézet",Ic:Calendar},{id:"com-cal-add",name:"Új esemény",Ic:Plus}
    ]},
    { id:"com-chat", name:"Csevegés", Ic:MessageSquare, desc:"Belső chat", subs:[] },
  ]},
];

const ALL = CATS.flatMap(c => c.items.map(i => ({ ...i, catId:c.id, catName:c.name, catColor:c.color })));
const pick = a => a[Math.floor(Math.random()*a.length)];

// ══════════════════════════════════════════
// THEMES
// ══════════════════════════════════════════
const themes = {
  light: {
    bg:"#fafafa", card:"#ffffff", sidebar:"#ffffff", sidebarBorder:"#e4e4e7",
    border:"#e4e4e7", borderSubtle:"#f4f4f5", muted:"#f4f4f5",
    text:"#09090b", textSec:"#71717a", textMuted:"#a1a1aa",
    primary:"#18181b", primaryFg:"#fafafa",
    sidebarText:"#3f3f46", sidebarMuted:"#a1a1aa", sidebarHover:"#f4f4f5", sidebarActive:"#ede9fe",
    sidebarCatActive:"#f4f4f5",
  },
  dark: {
    bg:"#09090b", card:"#18181b", sidebar:"#0f0f12", sidebarBorder:"#27272a",
    border:"#27272a", borderSubtle:"#1e1e22", muted:"#1e1e22",
    text:"#fafafa", textSec:"#a1a1aa", textMuted:"#71717a",
    primary:"#fafafa", primaryFg:"#09090b",
    sidebarText:"#d4d4d8", sidebarMuted:"#71717a", sidebarHover:"#1e1e22", sidebarActive:"#1e1b4b",
    sidebarCatActive:"#18181b",
  },
};

// ══════════════════════════════════════════
// MENU CARD
// ══════════════════════════════════════════
function MCard({ item, onSelect, isFav, onFav, rank, conf, t }) {
  const Ico = item.Ic;
  return (
    <div style={{display:"flex",alignItems:"center",gap:8,padding:"7px 8px",borderRadius:7,cursor:"pointer",border:`1px solid transparent`,transition:".12s"}}
      onMouseEnter={e=>{e.currentTarget.style.background=t.muted;e.currentTarget.style.borderColor=t.border}}
      onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.borderColor="transparent"}}
      onClick={()=>onSelect(item)}>
      <div style={{width:30,height:30,borderRadius:6,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,background:`${item.catColor||"#6366f1"}14`,color:item.catColor}}>
        <Ico size={15}/>
      </div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontSize:13,fontWeight:500,color:t.text}}>{item.name}</div>
        <div style={{fontSize:10,color:t.textMuted,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{item.desc}</div>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:3}}>
        {rank!=null&&<span style={{fontFamily:"monospace",fontSize:9,fontWeight:600,padding:"1px 3px",borderRadius:3,color:"#fff",background:rank<=2?"#18181b":"#71717a"}}>#{rank}</span>}
        {conf>0&&<span style={{fontFamily:"monospace",fontSize:9,color:t.textMuted}}>{(conf*100).toFixed(0)}%</span>}
        <button onClick={e=>{e.stopPropagation();onFav(item.id)}} style={{background:"none",border:"none",cursor:"pointer",padding:2,display:"flex",alignItems:"center",color:isFav?"#eab308":t.textMuted}}>
          <Star size={13} fill={isFav?"#eab308":"none"}/>
        </button>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════
// MAIN APP
// ══════════════════════════════════════════
export default function App() {
  const [ai] = useState(() => new MenuAI());
  const [ready, setReady] = useState(false);
  const [dark, setDark] = useState(false);
  const [sideOpen, setSideOpen] = useState(false);
  const [sideCollapsed, setSideCollapsed] = useState(false);
  const [popOpen, setPopOpen] = useState(false);
  const [chatOpen, setChatOpen] = useState(false);
  const [q, setQ] = useState("");
  const [sideQ, setSideQ] = useState("");
  const [tab, setTab] = useState("ai");
  const [favs, setFavs] = useState(["dash-main","fin-inv","doc-in","proj-tasks","hr-emp","com-inbox"]);
  const [preds, setPreds] = useState([]);
  const [sel, setSel] = useState(null);
  const [openCats, setOpenCats] = useState(new Set(["dashboard"]));
  const [openItems, setOpenItems] = useState(new Set());
  const [toast, setToast] = useState(null);
  const [msgs, setMsgs] = useState([]);
  const [chatIn, setChatIn] = useState("");
  const [typing, setTyping] = useState(false);
  const popRef = useRef(null);
  const searchRef = useRef(null);
  const chatEnd = useRef(null);
  const chatIRef = useRef(null);
  const t = dark ? themes.dark : themes.light;
  const isMob = typeof window!=="undefined" && window.innerWidth < 768;
  const sbW = sideCollapsed ? 56 : 260;

  useEffect(() => {
    ai.init().then(() => {
      setReady(true);
      ["dash-main","fin-inv","doc-in","proj-tasks","hr-emp","com-inbox","fin-inv","dash-main","proj-board","doc-in","fin-pay","crm-con","dash-kpi","fin-inv","wh-stock","rep-build"]
        .forEach((id,i) => setTimeout(() => ai.record(id), i*30));
      setTimeout(() => setPreds(ai.predict(ALL,6)), 600);
    });
  }, []);

  useEffect(() => { if(popOpen&&searchRef.current) setTimeout(()=>searchRef.current.focus(),80) }, [popOpen]);
  useEffect(() => { if(chatOpen&&msgs.length===0) setMsgs([{r:"ai",t:pick(["Szia! Miben segíthetek?","Üdv! Kérdezz bátran."]),res:[]}]); if(chatOpen) setTimeout(()=>chatIRef.current?.focus(),100) }, [chatOpen]);
  useEffect(() => { chatEnd.current?.scrollIntoView({behavior:"smooth"}) }, [msgs]);
  useEffect(() => { const h=e=>{if((e.metaKey||e.ctrlKey)&&e.key==="k"){e.preventDefault();setPopOpen(true);setQ("")}if(e.key==="Escape"){setPopOpen(false);setChatOpen(false)}}; window.addEventListener("keydown",h); return()=>window.removeEventListener("keydown",h) }, []);
  useEffect(() => { const h=e=>{if(popRef.current&&!popRef.current.contains(e.target))setPopOpen(false)}; document.addEventListener("mousedown",h); return()=>document.removeEventListener("mousedown",h) }, []);

  const sToast = msg => { setToast(msg); setTimeout(()=>setToast(null),2000) };
  const open = useCallback(item => { ai.record(item.id); setSel(item); setPreds(ai.predict(ALL,6)); setPopOpen(false); setSideOpen(false) }, [ai]);
  const togFav = useCallback(id => { setFavs(p => { if(p.includes(id)){sToast("Eltávolítva");return p.filter(x=>x!==id)} if(p.length>=12){sToast("Max 12");return p} sToast("Kedvenc ★");return[...p,id] }) }, []);
  const togCat = id => setOpenCats(p => { const n=new Set(p); n.has(id)?n.delete(id):n.add(id); return n });
  const togItem = id => setOpenItems(p => { const n=new Set(p); n.has(id)?n.delete(id):n.add(id); return n });

  const sendChat = useCallback(() => {
    const v=chatIn.trim();if(!v)return;setMsgs(p=>[...p,{r:"user",t:v,res:[]}]);setChatIn("");setTyping(true);
    setTimeout(()=>{const res=ai.chatSearch(v,ALL);setMsgs(p=>[...p,{r:"ai",t:res.length>0?pick(["Ezeket találtam:","Íme:","Szerintem ezeket keresed:"]):pick(["Nem találtam. Próbáld másképp!","Nincs találat."]),res}]);setTyping(false)},500+Math.random()*400);
  }, [chatIn,ai]);

  const filtered = useMemo(() => { if(!q.trim())return[]; const s=q.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,""); return ALL.filter(i=>`${i.name} ${i.desc} ${i.catName}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s)) }, [q]);
  const favItems = useMemo(() => ALL.filter(i=>favs.includes(i.id)), [favs]);

  // Sidebar filtered cats
  const sideFiltered = useMemo(() => {
    if (!sideQ.trim()) return CATS;
    const s = sideQ.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");
    return CATS.map(c => {
      const fi = c.items.filter(i => `${i.name} ${i.desc}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s));
      if (fi.length > 0 || c.name.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s)) return { ...c, items: fi.length > 0 ? fi : c.items };
      return null;
    }).filter(Boolean);
  }, [sideQ]);

  const collapsed = sideCollapsed && !isMob;

  return (
    <div style={{fontFamily:'-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif',display:"flex",height:"100vh",background:t.bg,color:t.text,overflow:"hidden",position:"relative",fontSize:14}}>
      {sideOpen&&isMob&&<div onClick={()=>setSideOpen(false)} style={{position:"fixed",inset:0,background:"rgba(0,0,0,.4)",zIndex:40}}/>}

      {/* ═══ SIDEBAR ═══ */}
      <aside style={{width:isMob?"260px":`${sbW}px`,background:t.sidebar,display:"flex",flexDirection:"column",flexShrink:0,borderRight:`1px solid ${t.sidebarBorder}`,zIndex:50,transition:"width .2s",...(isMob?{position:"fixed",left:0,top:0,bottom:0,transform:sideOpen?"translateX(0)":"translateX(-100%)",transition:"transform .2s"}:{})}}>
        {/* Header */}
        <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:collapsed?"10px 8px":"12px 14px 10px",borderBottom:`1px solid ${t.sidebarBorder}`,minHeight:48}}>
          {!collapsed&&<div style={{display:"flex",alignItems:"center",gap:8}}>
            <div style={{width:26,height:26,borderRadius:6,background:"linear-gradient(135deg,#6366f1,#818cf8)",color:"#fff",display:"flex",alignItems:"center",justifyContent:"center",fontWeight:700,fontSize:13}}>D</div>
            <span style={{fontWeight:700,fontSize:15,color:t.text,letterSpacing:".04em"}}>DLA</span>
          </div>}
          {collapsed&&<div style={{width:26,height:26,borderRadius:6,background:"linear-gradient(135deg,#6366f1,#818cf8)",color:"#fff",display:"flex",alignItems:"center",justifyContent:"center",fontWeight:700,fontSize:13,margin:"0 auto"}}>D</div>}
          <div style={{display:"flex",gap:2}}>
            {isMob&&<button onClick={()=>setSideOpen(false)} style={{background:"none",border:"none",color:t.textMuted,cursor:"pointer",display:"flex",padding:4}}><X size={16}/></button>}
            {!isMob&&<button onClick={()=>setSideCollapsed(!sideCollapsed)} style={{background:"none",border:"none",color:t.textMuted,cursor:"pointer",display:"flex",padding:4,borderRadius:4}} title={collapsed?"Kinyitás":"Összecsukás"}>
              {collapsed?<ChevronsRight size={16}/>:<ChevronsLeft size={16}/>}
            </button>}
          </div>
        </div>

        {/* AI pill */}
        {!collapsed&&<div style={{display:"flex",alignItems:"center",gap:7,margin:"8px 10px 4px",padding:"5px 9px",borderRadius:6,background:t.muted,border:`1px solid ${t.border}`,fontSize:11}}>
          <div style={{width:5,height:5,borderRadius:"50%",background:ready?"#22c55e":"#a1a1aa",boxShadow:ready?"0 0 6px #22c55e88":"none"}}/>
          <span style={{flex:1,color:t.textSec}}>{ready?"AI aktív":"..."}</span>
          <span style={{fontFamily:"monospace",fontSize:9,color:"#6366f1",background:"#6366f118",padding:"1px 4px",borderRadius:3}}>tf.js</span>
        </div>}

        {/* Sidebar search */}
        {!collapsed&&<div style={{padding:"6px 10px"}}>
          <div style={{display:"flex",alignItems:"center",gap:6,padding:"5px 8px",borderRadius:6,border:`1px solid ${t.border}`,background:t.muted}}>
            <Search size={13} color={t.textMuted}/>
            <input value={sideQ} onChange={e=>setSideQ(e.target.value)} placeholder="Menü szűrés..."
              style={{flex:1,border:"none",outline:"none",fontSize:12,color:t.text,background:"transparent",fontFamily:"inherit"}}/>
            {sideQ&&<button onClick={()=>setSideQ("")} style={{background:"none",border:"none",cursor:"pointer",display:"flex",color:t.textMuted}}><X size={12}/></button>}
          </div>
        </div>}

        {/* Nav */}
        <nav style={{flex:1,overflowY:"auto",padding:"4px 0"}}>
          {sideFiltered.map(cat => {
            const CI=cat.Ic; const isO=openCats.has(cat.id);
            return (
              <div key={cat.id}>
                {/* Category */}
                <button onClick={()=>togCat(cat.id)} style={{display:"flex",alignItems:"center",gap:collapsed?0:8,width:"100%",padding:collapsed?"8px 0":"6px 12px",border:"none",background:isO?t.sidebarCatActive:"transparent",color:isO?t.text:t.sidebarText,fontSize:12,fontWeight:600,cursor:"pointer",textAlign:"left",justifyContent:collapsed?"center":"flex-start",transition:".12s"}}>
                  <CI size={15} style={{color:cat.color,flexShrink:0}}/>
                  {!collapsed&&<span style={{flex:1}}>{cat.name}</span>}
                  {!collapsed&&<ChevronRight size={12} style={{color:t.textMuted,transition:"transform .15s",transform:isO?"rotate(90deg)":"none"}}/>}
                </button>

                {/* Items (level 2) */}
                {isO&&!collapsed&&<div style={{padding:"2px 0 4px"}}>
                  {cat.items.map(it => {
                    const II=it.Ic; const hasSubs=it.subs&&it.subs.length>0; const itemOpen=openItems.has(it.id);
                    return (
                      <div key={it.id}>
                        <div style={{display:"flex",alignItems:"center",gap:6,padding:"5px 12px 5px 30px",cursor:"pointer",transition:".1s",background:sel?.id===it.id?t.sidebarActive:"transparent",borderRadius:0}}
                          onMouseEnter={e=>{if(sel?.id!==it.id)e.currentTarget.style.background=t.sidebarHover}}
                          onMouseLeave={e=>{if(sel?.id!==it.id)e.currentTarget.style.background="transparent"}}
                        >
                          {hasSubs&&<button onClick={e=>{e.stopPropagation();togItem(it.id)}} style={{background:"none",border:"none",cursor:"pointer",display:"flex",padding:0,color:t.textMuted}}>
                            <ChevronRight size={11} style={{transition:"transform .15s",transform:itemOpen?"rotate(90deg)":"none"}}/>
                          </button>}
                          {!hasSubs&&<span style={{width:11}}/>}
                          <button onClick={()=>open({...it,catName:cat.name,catColor:cat.color})} style={{display:"flex",alignItems:"center",gap:6,flex:1,background:"none",border:"none",cursor:"pointer",color:sel?.id===it.id?t.text:t.sidebarText,fontSize:12,textAlign:"left",padding:0,fontFamily:"inherit"}}>
                            <II size={13} style={{color:cat.color,opacity:.7}}/><span style={{flex:1}}>{it.name}</span>
                            {favs.includes(it.id)&&<Star size={9} fill="#eab308" color="#eab308"/>}
                          </button>
                        </div>

                        {/* Sub-actions (level 3) */}
                        {hasSubs&&itemOpen&&<div style={{padding:"2px 0"}}>
                          {it.subs.map(sub => {
                            const SI=sub.Ic;
                            return (
                              <button key={sub.id} onClick={()=>{open({...it,catName:cat.name,catColor:cat.color});sToast(sub.name)}}
                                style={{display:"flex",alignItems:"center",gap:6,width:"100%",padding:"4px 12px 4px 58px",border:"none",background:"transparent",color:t.sidebarMuted,fontSize:11,cursor:"pointer",textAlign:"left",fontFamily:"inherit",transition:".1s"}}
                                onMouseEnter={e=>{e.currentTarget.style.background=t.sidebarHover;e.currentTarget.style.color=t.text}}
                                onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.color=t.sidebarMuted}}>
                                <SI size={11}/><span>{sub.name}</span>
                              </button>
                            );
                          })}
                        </div>}
                      </div>
                    );
                  })}
                </div>}
              </div>
            );
          })}
        </nav>

        {/* Sidebar footer */}
        {!collapsed&&<div style={{padding:"8px 10px",borderTop:`1px solid ${t.sidebarBorder}`,display:"flex",alignItems:"center",gap:6}}>
          <button onClick={()=>setDark(!dark)} style={{display:"flex",alignItems:"center",gap:6,flex:1,padding:"6px 8px",borderRadius:6,border:`1px solid ${t.border}`,background:t.muted,cursor:"pointer",fontSize:11,color:t.textSec,fontFamily:"inherit"}}>
            {dark?<Sun size={13}/>:<Moon size={13}/>}
            <span>{dark?"Világos mód":"Sötét mód"}</span>
          </button>
        </div>}
        {collapsed&&<div style={{padding:"8px 0",borderTop:`1px solid ${t.sidebarBorder}`,display:"flex",justifyContent:"center"}}>
          <button onClick={()=>setDark(!dark)} style={{background:"none",border:"none",cursor:"pointer",color:t.textMuted,display:"flex",padding:4}}>
            {dark?<Sun size={15}/>:<Moon size={15}/>}
          </button>
        </div>}
      </aside>

      {/* ═══ MAIN ═══ */}
      <main style={{flex:1,display:"flex",flexDirection:"column",overflow:"hidden",minWidth:0}}>
        {/* Topbar */}
        <header style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"8px 14px",borderBottom:`1px solid ${t.border}`,background:t.card,gap:6,minHeight:48}}>
          <div style={{display:"flex",alignItems:"center",gap:6,minWidth:0}}>
            {isMob&&<button onClick={()=>setSideOpen(true)} style={{background:"none",border:"none",color:t.textSec,cursor:"pointer",display:"flex",padding:4}}><Menu size={20}/></button>}
            {sel?<div style={{display:"flex",alignItems:"center",gap:6}}>
              {isMob&&<button onClick={()=>setSel(null)} style={{background:"none",border:"none",color:t.textSec,cursor:"pointer",display:"flex",padding:4}}><ArrowLeft size={16}/></button>}
              <h1 style={{fontSize:15,fontWeight:600,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{sel.name}</h1>
              {!isMob&&<span style={{fontSize:12,color:t.textMuted}}>{sel.catName}</span>}
            </div>:<h1 style={{fontSize:15,fontWeight:600}}>Kezdőlap</h1>}
          </div>
          <div style={{display:"flex",alignItems:"center",gap:5,flexShrink:0}}>
            <button onClick={()=>{setPopOpen(true);setQ("")}} style={{display:"flex",alignItems:"center",gap:5,padding:"5px 9px",border:`1px solid ${t.border}`,borderRadius:7,background:t.bg,cursor:"pointer",fontSize:13,color:t.textMuted}}>
              <Search size={14}/>
              {!isMob&&<><span style={{flex:1,textAlign:"left"}}>Keresés...</span><kbd style={{padding:"1px 4px",borderRadius:3,background:t.muted,fontFamily:"monospace",fontSize:10,color:t.textMuted,border:`1px solid ${t.border}`}}>⌘K</kbd></>}
            </button>
            <div ref={popRef} style={{position:"relative"}}>
              <button onClick={()=>setPopOpen(!popOpen)} style={{width:34,height:34,border:`1px solid ${t.border}`,borderRadius:7,background:popOpen?t.muted:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:popOpen?t.text:t.textSec}}>
                <Grid size={17}/>
              </button>
              {popOpen&&<div style={{position:isMob?"fixed":"absolute",inset:isMob?0:"auto",top:!isMob?"calc(100% + 5px)":"auto",right:!isMob?0:"auto",width:!isMob?460:"auto",maxHeight:!isMob?"68vh":"100vh",background:t.card,borderRadius:!isMob?10:0,border:!isMob?`1px solid ${t.border}`:"none",boxShadow:"0 20px 40px -8px rgba(0,0,0,.15)",overflow:"hidden",display:"flex",flexDirection:"column",zIndex:100}}>
                <div style={{display:"flex",alignItems:"center",gap:7,padding:"10px 12px",borderBottom:`1px solid ${t.borderSubtle}`}}>
                  <Search size={15} color={t.textMuted}/>
                  <input ref={searchRef} value={q} onChange={e=>setQ(e.target.value)} placeholder="Menü keresése..." style={{flex:1,border:"none",outline:"none",fontSize:14,color:t.text,background:"transparent",fontFamily:"inherit"}}/>
                  {q&&<button onClick={()=>setQ("")} style={{width:20,height:20,borderRadius:"50%",background:t.muted,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.textMuted}}><X size={11}/></button>}
                </div>
                <div style={{display:"flex",borderBottom:`1px solid ${t.borderSubtle}`,padding:"0 12px"}}>
                  {[{k:"ai",l:"AI Ajánlott",I:Zap,n:preds.length},{k:"favs",l:"Kedvencek",I:Star,n:favs.length},{k:"all",l:"Összes",I:Grid}].map(x=>(
                    <button key={x.k} onClick={()=>{setTab(x.k);setQ("")}} style={{padding:"7px 8px",border:"none",background:"none",fontSize:12,fontWeight:500,cursor:"pointer",color:tab===x.k?t.text:t.textMuted,borderBottom:tab===x.k?`2px solid ${t.text}`:"2px solid transparent",display:"flex",alignItems:"center",gap:4,fontFamily:"inherit"}}>
                      <x.I size={12}/>{x.l}{x.n!=null&&<span style={{fontSize:10,fontWeight:600,padding:"0 4px",borderRadius:8,background:t.muted,color:t.textSec}}>{x.n}</span>}
                    </button>
                  ))}
                </div>
                <div style={{flex:1,overflowY:"auto",padding:"8px 12px 12px"}}>
                  {q.trim()?<div>
                    <div style={{fontSize:11,fontWeight:600,color:t.textMuted,textTransform:"uppercase",letterSpacing:".04em",marginBottom:6}}>Találatok ({filtered.length})</div>
                    {filtered.length===0?<div style={{textAlign:"center",padding:24,color:t.textMuted,fontSize:13}}>Nincs találat</div>:
                    <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:2}}>{filtered.map(i=><MCard key={i.id} item={i} onSelect={open} isFav={favs.includes(i.id)} onFav={togFav} t={t}/>)}</div>}
                  </div>:tab==="ai"?<div>
                    <div style={{display:"flex",alignItems:"center",gap:5,fontSize:11,fontWeight:600,color:t.textMuted,textTransform:"uppercase",letterSpacing:".04em",marginBottom:6}}>
                      <span>Neked ajánljuk</span><span style={{fontFamily:"monospace",fontSize:9,fontWeight:600,color:"#6366f1",background:"#6366f110",padding:"1px 4px",borderRadius:3}}>TF.js</span>
                    </div>
                    <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:2}}>{preds.map((i,idx)=><MCard key={i.id} item={i} onSelect={open} isFav={favs.includes(i.id)} onFav={togFav} rank={idx+1} conf={i.conf} t={t}/>)}</div>
                    <div style={{display:"flex",gap:4,marginTop:4,paddingTop:6,borderTop:`1px solid ${t.borderSubtle}`}}>
                      {[{v:ai.stats().total,l:"Interakció"},{v:ai.stats().unique,l:"Menü típus"},{v:(preds[0]?.conf*100||0).toFixed(0)+"%",l:"Konfidencia"}].map((s,i)=>(
                        <div key={i} style={{flex:1,textAlign:"center",padding:6,borderRadius:6,background:t.muted}}>
                          <div style={{fontSize:15,fontWeight:700,fontFamily:"monospace",color:t.text}}>{s.v}</div>
                          <div style={{fontSize:9,color:t.textMuted}}>{s.l}</div>
                        </div>
                      ))}
                    </div>
                  </div>:tab==="favs"?<div>
                    <div style={{fontSize:11,fontWeight:600,color:t.textMuted,textTransform:"uppercase",letterSpacing:".04em",marginBottom:6}}>Kedvenceid ({favs.length}/12)</div>
                    {favItems.length===0?<div style={{textAlign:"center",padding:24,color:t.textMuted,fontSize:13}}>Még nincs kedvenced.</div>:
                    <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:2}}>{favItems.map(i=><MCard key={i.id} item={i} onSelect={open} isFav onFav={togFav} t={t}/>)}</div>}
                  </div>:<div>{CATS.map(c=>(
                    <div key={c.id} style={{marginBottom:10}}>
                      <div style={{display:"flex",alignItems:"center",gap:5,marginBottom:4}}>
                        <div style={{width:6,height:6,borderRadius:"50%",background:c.color}}/><span style={{fontSize:12,fontWeight:600,color:t.textSec}}>{c.name}</span>
                        <span style={{fontSize:10,color:t.textMuted,background:t.muted,padding:"0 4px",borderRadius:6}}>{c.items.length}</span>
                      </div>
                      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:2}}>{c.items.map(i=><MCard key={i.id} item={{...i,catName:c.name,catColor:c.color}} onSelect={open} isFav={favs.includes(i.id)} onFav={togFav} t={t}/>)}</div>
                    </div>
                  ))}</div>}
                </div>
              </div>}
            </div>
            <button onClick={()=>setChatOpen(!chatOpen)} style={{width:34,height:34,border:`1px solid ${t.border}`,borderRadius:7,background:chatOpen?t.muted:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:chatOpen?t.text:t.textSec,position:"relative"}}>
              <MessageSquare size={17}/><div style={{position:"absolute",bottom:4,right:4,width:6,height:6,borderRadius:"50%",background:"#22c55e",border:`1.5px solid ${t.card}`}}/>
            </button>
            <button style={{width:34,height:34,border:`1px solid ${t.border}`,borderRadius:7,background:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.textSec,position:"relative"}}>
              <Bell size={17}/><div style={{position:"absolute",top:5,right:5,width:5,height:5,borderRadius:"50%",background:"#ef4444",border:`1.5px solid ${t.card}`}}/>
            </button>
            <div style={{width:30,height:30,borderRadius:7,background:t.primary,color:t.primaryFg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:11,fontWeight:600}}>BT</div>
          </div>
        </header>

        {/* Quick bar */}
        <div style={{display:"flex",alignItems:"center",gap:8,padding:"6px 14px",background:t.card,borderBottom:`1px solid ${t.borderSubtle}`,overflow:"hidden"}}>
          <div style={{display:"flex",alignItems:"center",gap:4,fontSize:11,color:t.textMuted,fontWeight:500,flexShrink:0}}><Zap size={12}/><span>AI Ajánlott</span></div>
          <div style={{display:"flex",gap:3,overflowX:"auto"}}>
            {preds.slice(0,5).map(p=>{const PI=p.Ic;return(
              <button key={p.id} onClick={()=>open(p)} style={{display:"flex",alignItems:"center",gap:4,padding:"3px 8px",borderRadius:5,border:`1px solid ${t.border}`,background:t.card,cursor:"pointer",fontSize:11,color:t.textSec,whiteSpace:"nowrap",fontFamily:"inherit",position:"relative",overflow:"hidden"}}>
                <PI size={12}/><span>{p.name}</span>{p.conf>0&&<div style={{position:"absolute",bottom:0,left:0,height:2,width:`${p.conf*100}%`,background:"#6366f1",borderRadius:1,opacity:.4}}/>}
              </button>
            )})}
          </div>
        </div>

        {/* Content */}
        <div style={{flex:1,overflowY:"auto",padding:16}}>
          {sel?(
            <div>
              <div style={{display:"flex",alignItems:"center",gap:12,padding:14,background:t.card,borderRadius:10,border:`1px solid ${t.border}`,marginBottom:14}}>
                <div style={{width:48,height:48,borderRadius:9,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,background:`${sel.catColor}14`,color:sel.catColor}}>
                  {sel.Ic&&<sel.Ic size={26}/>}
                </div>
                <div style={{flex:1}}><h2 style={{fontSize:17,fontWeight:600}}>{sel.name}</h2><p style={{fontSize:13,color:t.textSec,marginTop:1}}>{sel.desc}</p></div>
                <button onClick={()=>togFav(sel.id)} style={{background:"none",border:`1px solid ${favs.includes(sel.id)?"#eab30844":t.border}`,borderRadius:7,width:34,height:34,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:favs.includes(sel.id)?"#eab308":t.textMuted}}>
                  <Bookmark size={17} fill={favs.includes(sel.id)?"#eab308":"none"}/>
                </button>
              </div>
              {/* Sub action buttons */}
              {sel.subs&&sel.subs.length>0&&<div style={{display:"flex",gap:6,marginBottom:14,flexWrap:"wrap"}}>
                {sel.subs.map(sub=>{const SI=sub.Ic;return(
                  <button key={sub.id} onClick={()=>sToast(sub.name)} style={{display:"flex",alignItems:"center",gap:5,padding:"7px 12px",borderRadius:7,border:`1px solid ${t.border}`,background:t.card,cursor:"pointer",fontSize:12,fontWeight:500,color:t.textSec,fontFamily:"inherit",transition:".12s"}}
                    onMouseEnter={e=>{e.currentTarget.style.borderColor=sel.catColor;e.currentTarget.style.color=t.text}}
                    onMouseLeave={e=>{e.currentTarget.style.borderColor=t.border;e.currentTarget.style.color=t.textSec}}>
                    <SI size={14} style={{color:sel.catColor}}/>{sub.name}
                  </button>
                )})}
              </div>}
              <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(200px,1fr))",gap:8}}>
                {[1,2,3,4,5,6].map(i=>(
                  <div key={i} style={{background:t.card,borderRadius:10,border:`1px solid ${t.border}`,padding:14,display:"flex",flexDirection:"column",gap:7}}>
                    <div style={{height:7,borderRadius:4,background:t.muted,width:"90%"}}/><div style={{height:7,borderRadius:4,background:t.muted,width:"60%"}}/>
                    <div style={{height:7,borderRadius:4,background:t.muted,width:"75%",opacity:.4}}/><div style={{height:24,borderRadius:5,background:t.muted,marginTop:3,opacity:.5}}/>
                  </div>
                ))}
              </div>
            </div>
          ):(
            <div style={{display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",minHeight:"50vh",textAlign:"center",padding:14}}>
              <div style={{width:56,height:56,borderRadius:12,background:t.muted,border:`1px solid ${t.border}`,display:"flex",alignItems:"center",justifyContent:"center",color:t.textSec,marginBottom:14}}>
                <LayoutDashboard size={32} strokeWidth={1.5}/>
              </div>
              <h2 style={{fontSize:20,fontWeight:700,marginBottom:5}}>DLA Menürendszer</h2>
              <p style={{fontSize:13,color:t.textSec,maxWidth:380,lineHeight:1.6,marginBottom:24}}>Használd a <strong>menü gombot</strong>, a <strong>⌘K</strong> keresőt, vagy az <strong>AI Chat</strong>-et.</p>
              <div style={{display:"flex",gap:8,flexWrap:"wrap",justifyContent:"center"}}>
                {[{I:Activity,tt:"AI Ajánlások",d:"TF.js személyre szabás"},{I:Star,tt:"Kedvencek",d:"Max 12 gyors hozzáférés"},{I:MessageSquare,tt:"AI Chat",d:"Kérdezd meg amit keresel"}].map((c,i)=>(
                  <div key={i} style={{padding:"16px 14px",borderRadius:10,border:`1px solid ${t.border}`,background:t.card,width:140,textAlign:"center",color:t.textSec}}>
                    <c.I size={20} strokeWidth={1.5}/><div style={{fontSize:12,fontWeight:600,color:t.text,margin:"7px 0 2px"}}>{c.tt}</div><div style={{fontSize:10,color:t.textMuted,lineHeight:1.4}}>{c.d}</div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>

      {/* ═══ CHAT ═══ */}
      {chatOpen&&<>
        {isMob&&<div onClick={()=>setChatOpen(false)} style={{position:"fixed",inset:0,background:"rgba(0,0,0,.4)",zIndex:60}}/>}
        <div style={{position:"fixed",zIndex:70,background:t.card,display:"flex",flexDirection:"column",border:`1px solid ${t.border}`,boxShadow:"0 20px 40px -8px rgba(0,0,0,.15)",...(isMob?{inset:0,borderRadius:0,border:"none"}:{bottom:14,right:14,width:360,height:500,borderRadius:10})}}>
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"10px 12px",borderBottom:`1px solid ${t.border}`}}>
            <div style={{display:"flex",alignItems:"center",gap:8,color:t.text}}>
              <MessageSquare size={16}/>
              <div><div style={{fontSize:13,fontWeight:600}}>DLA Asszisztens</div><div style={{fontSize:10,color:t.textMuted,fontFamily:"monospace"}}>TensorFlow.js — {ai.stats().total} pont</div></div>
            </div>
            <button onClick={()=>setChatOpen(false)} style={{background:"none",border:"none",color:t.textMuted,cursor:"pointer",display:"flex",padding:4}}><X size={15}/></button>
          </div>
          <div style={{flex:1,overflowY:"auto",padding:10,display:"flex",flexDirection:"column",gap:8}}>
            {msgs.map((m,i)=>(
              <div key={i} style={{display:"flex",gap:6,...(m.r==="user"?{justifyContent:"flex-end"}:{justifyContent:"flex-start",alignItems:"flex-start"})}}>
                {m.r==="ai"&&<div style={{width:24,height:24,borderRadius:5,background:t.muted,display:"flex",alignItems:"center",justifyContent:"center",color:t.textSec,flexShrink:0,border:`1px solid ${t.border}`}}><MessageSquare size={12}/></div>}
                <div style={{maxWidth:"85%",padding:"8px 10px",borderRadius:8,fontSize:13,lineHeight:1.5,...(m.r==="user"?{background:t.primary,color:t.primaryFg,borderBottomRightRadius:2}:{background:t.muted,color:t.text,borderBottomLeftRadius:2})}}>
                  <p style={{margin:0}}>{m.t}</p>
                  {m.res?.length>0&&<div style={{display:"flex",flexDirection:"column",gap:3,marginTop:6}}>
                    {m.res.map(r=>{const RI=r.Ic;return(
                      <button key={r.id} onClick={()=>{open(r);setChatOpen(false)}} style={{display:"flex",alignItems:"center",gap:7,padding:"6px 8px",borderRadius:5,background:t.card,border:`1px solid ${t.border}`,cursor:"pointer",fontSize:12,color:t.text,fontFamily:"inherit",textAlign:"left"}}>
                        <RI size={14} style={{color:r.catColor}}/><div style={{flex:1,display:"flex",flexDirection:"column"}}><span style={{fontWeight:500,fontSize:12}}>{r.name}</span><span style={{fontSize:10,color:t.textMuted}}>{r.catName}</span></div><ArrowUpRight size={12}/>
                      </button>
                    )})}
                  </div>}
                </div>
              </div>
            ))}
            {typing&&<div style={{display:"flex",gap:6,alignItems:"flex-start"}}>
              <div style={{width:24,height:24,borderRadius:5,background:t.muted,display:"flex",alignItems:"center",justifyContent:"center",color:t.textSec,flexShrink:0,border:`1px solid ${t.border}`}}><MessageSquare size={12}/></div>
              <div style={{background:t.muted,padding:"10px 14px",borderRadius:8,borderBottomLeftRadius:2,display:"flex",gap:5}}>
                <span className="tdot"/><span className="tdot"/><span className="tdot"/>
              </div>
            </div>}
            <div ref={chatEnd}/>
          </div>
          <div style={{display:"flex",alignItems:"center",gap:6,padding:"8px 10px",borderTop:`1px solid ${t.border}`}}>
            <input ref={chatIRef} value={chatIn} onChange={e=>setChatIn(e.target.value)} onKeyDown={e=>e.key==="Enter"&&sendChat()}
              placeholder="Pl: szeretnék számlát kiállítani..." style={{flex:1,border:`1px solid ${t.border}`,borderRadius:7,padding:"7px 10px",fontSize:13,color:t.text,background:t.bg,outline:"none",fontFamily:"inherit"}}/>
            <button onClick={sendChat} disabled={!chatIn.trim()} style={{width:32,height:32,borderRadius:7,background:t.primary,color:t.primaryFg,border:"none",cursor:chatIn.trim()?"pointer":"not-allowed",display:"flex",alignItems:"center",justifyContent:"center",opacity:chatIn.trim()?1:.25}}>
              <Send size={15}/>
            </button>
          </div>
        </div>
      </>}

      {toast&&<div style={{position:"fixed",bottom:16,left:"50%",transform:"translateX(-50%)",background:t.primary,color:t.primaryFg,padding:"7px 14px",borderRadius:7,fontSize:13,fontWeight:500,boxShadow:"0 8px 20px rgba(0,0,0,.15)",zIndex:9999}}>{toast}</div>}

      <style>{`
        * { box-sizing: border-box; margin: 0; padding: 0; }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-thumb { background: ${t.border}; border-radius: 2px; }
        .tdot { display:inline-block;width:5px;height:5px;border-radius:50%;background:${t.textMuted};animation:bounce 1.2s ease infinite; }
        .tdot:nth-child(2){animation-delay:.15s} .tdot:nth-child(3){animation-delay:.3s}
        @keyframes bounce{0%,60%,100%{transform:translateY(0)}30%{transform:translateY(-3px)}}
      `}</style>
    </div>
  );
}
