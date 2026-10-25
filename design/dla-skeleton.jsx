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
  Sun, Moon, FilePlus, UserCheck, FileSearch,
  Tag, Percent, LogOut, HelpCircle, User, Keyboard, ExternalLink,
  Home, PanelLeft, Terminal, Code, Cpu, Lock, Cog,
  Play, RefreshCw, Wrench, Server, Monitor,
  FolderTree, FileCode, Bot, Plug, Hash,
  TestTube, Bug, Rocket, Cloud, Key, Wifi,
  Image, Type, Languages, CheckCircle, XCircle,
  AlertTriangle, Info, Sparkles, Brain,
  GitCommit, GitPullRequest, FolderOpen, Blocks
} from "lucide-react";

// ═══════════════════════════════════════════════════════════════════════════
// EVERENGINE CLAUDE CODE v2.3 — SKELETON ADMIN
// Specifikáció: everengine-claude-code-v2.3-master.md
//               everengine-v2.2-skill-catalog-skeleton.md
//               everengine-v2.2-list-view-spec.md
// Design:       DLA Skeleton UI rendszer (shadcn/ui stílus)
// Struktúra:    12 fő kategória, 67 skill, 7 rule, 7 hook, 5 agent, 7 command
// ═══════════════════════════════════════════════════════════════════════════

// ═══ AI PREDIKCIÓ MOTOR (TF.js admin intelligence) ═══
class MenuAI {
  constructor(){this.usage={};this.log=[];this.seq=[];this.tm={};this.ready=false}
  async init(){await new Promise(r=>setTimeout(r,400));this.ready=true}
  record(id){const h=new Date().getHours();this.usage[id]=(this.usage[id]||0)+1;this.log.push({id,t:Date.now(),h});this.seq.push(id);if(this.seq.length>30)this.seq.shift();this.tm[`${id}_${h}`]=(this.tm[`${id}_${h}`]||0)+1}
  predict(items,n=6){if(this.log.length<2)return items.slice(0,n).map(i=>({...i,score:.3,conf:.3}));const now=Date.now(),h=new Date().getHours();return items.map(m=>{const f=this.usage[m.id]||0;const tb=this.tm[`${m.id}_${h}`]||0;const rec=this.log.filter(l=>l.id===m.id).reduce((a,l)=>a+Math.exp(-(now-l.t)/864e5),0);let sq=0;if(this.seq.length>1){const last=this.seq[this.seq.length-1];sq=this.log.reduce((a,l,i)=>i>0&&this.log[i-1].id===last&&l.id===m.id?a+1:a,0)*2}return{...m,score:f+tb*2.5+rec*3+sq*1.5,conf:Math.min(.97,.25+f*.04+tb*.08)}}).sort((a,b)=>b.score-a.score).slice(0,n)}
  stats(){return{total:this.log.length,unique:new Set(this.log.map(l=>l.id)).size}}
  chatSearch(q,items){const s=q.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");const kws=s.split(/\s+/).filter(w=>w.length>1);if(!kws.length)return[];return items.map(item=>{const txt=`${item.name} ${item.desc} ${item.catName}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");let sc=0;kws.forEach(k=>{if(txt.includes(k))sc+=3;txt.split(/\s+/).forEach(w=>{if(w.startsWith(k.slice(0,3)))sc+=1})});return{...item,matchScore:sc+(this.usage[item.id]||0)*.5}}).filter(i=>i.matchScore>0).sort((a,b)=>b.matchScore-a.matchScore).slice(0,5)}
}

// ═══════════════════════════════════════════════════════════════════════════
// CLAUDE CODE PROJEKT STRUKTÚRA – v2.3 SPECIFIKÁCIÓ ALAPJÁN
// 12 fő kategória a .claude/ könyvtár és projekt struktúra szerint
// ═══════════════════════════════════════════════════════════════════════════
const CATS=[
  // ── 1. IRÁNYÍTÓPULT ──────────────────────────────────────────────────────
  {id:"dashboard",name:"Irányítópult",Ic:LayoutDashboard,color:"#6366f1",items:[
    {id:"dash-main",name:"Projekt Áttekintés",Ic:LayoutDashboard,desc:"Claude Code projekt státusz és metrikák",subs:[{id:"dash-main-view",name:"Megtekintés",Ic:Eye},{id:"dash-main-kpi",name:"KPI-k",Ic:Target}]},
    {id:"dash-cost",name:"Költség Monitor",Ic:DollarSign,desc:"$6/fejlesztő/nap – Sonnet/Opus/Haiku költségek",subs:[{id:"dash-cost-view",name:"Áttekintés",Ic:Eye},{id:"dash-cost-limits",name:"Limitek",Ic:AlertTriangle}]},
    {id:"dash-health",name:"Rendszer Egészség",Ic:Activity,desc:"Docker szolgáltatások, DB, queue állapot",subs:[{id:"dash-health-live",name:"Élő státusz",Ic:Zap},{id:"dash-health-hist",name:"Előzmények",Ic:Clock}]},
    {id:"dash-sessions",name:"Session Napló",Ic:Terminal,desc:"Claude Code session-ök és prompt log",subs:[{id:"dash-sessions-list",name:"Session-ök",Ic:List},{id:"dash-sessions-coord",name:"COORDINATION.md",Ic:FileText}]},
  ]},

  // ── 2. CLAUDE KONFIGURÁCIÓ (.claude/ könyvtár) ───────────────────────────
  {id:"claude-config",name:"Claude Konfig",Ic:Cog,color:"#8b5cf6",items:[
    {id:"cfg-claudemd",name:"CLAUDE.md",Ic:FileText,desc:"< 200 sor – WHY-WHAT-HOW keretrendszer",subs:[{id:"cfg-claudemd-edit",name:"Szerkesztés",Ic:Edit},{id:"cfg-claudemd-preview",name:"Előnézet",Ic:Eye}]},
    {id:"cfg-settings",name:"settings.json",Ic:Settings,desc:"Permissions, hooks, env – csapattal megosztott",subs:[{id:"cfg-settings-perm",name:"Engedélyek",Ic:Shield},{id:"cfg-settings-hooks",name:"Hook-ok",Ic:GitBranch},{id:"cfg-settings-env",name:"Környezet",Ic:Sliders}]},
    {id:"cfg-mcp",name:".mcp.json",Ic:Plug,desc:"MCP szerverek (max 10!)",subs:[{id:"cfg-mcp-list",name:"Szerverek",Ic:List},{id:"cfg-mcp-add",name:"Új szerver",Ic:Plus}]},
    {id:"cfg-local",name:"Lokális beállítások",Ic:Lock,desc:"settings.local.json – gitignored, személyes",subs:[{id:"cfg-local-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"cfg-output",name:"Output Stílusok",Ic:Type,desc:"Magyar konzisztencia – v2.3",subs:[{id:"cfg-output-hu",name:"Magyar stílus",Ic:Languages}]},
  ]},

  // ── 3. SKILLS (67 skill, 14 kategória) ───────────────────────────────────
  {id:"skills",name:"Skills (67)",Ic:Sparkles,color:"#0891b2",items:[
    {id:"sk-infra",name:"Infrastruktúra (9)",Ic:Server,desc:"Docker, Caddy, backup, monitoring, worker, CDN, S3, auto-scale",subs:[{id:"sk-infra-docker",name:"docker-setup",Ic:Box},{id:"sk-infra-caddy",name:"caddy-gateway",Ic:Globe},{id:"sk-infra-backup",name:"backup-strategy",Ic:HardDrive},{id:"sk-infra-monitor",name:"monitoring-setup",Ic:Activity},{id:"sk-infra-worker",name:"worker-management",Ic:Cpu}]},
    {id:"sk-security",name:"Biztonság & Auth (7)",Ic:Shield,desc:"Security audit, SkillPass.ID, roles, API keys, maintenance, safedata",subs:[{id:"sk-sec-audit",name:"security-audit",Ic:Shield},{id:"sk-sec-skillpass",name:"skillpass-auth",Ic:Key},{id:"sk-sec-roles",name:"roles-permissions",Ic:Users},{id:"sk-sec-apikey",name:"api-keys-management",Ic:Key}]},
    {id:"sk-crud",name:"CRUD & UI (8)",Ic:Layers,desc:"crud-generator, list-view, dashboard-widgets, form-builder, profile",subs:[{id:"sk-crud-gen",name:"crud-generator",Ic:Code},{id:"sk-crud-list",name:"list-view",Ic:List},{id:"sk-crud-dash",name:"dashboard-widgets",Ic:BarChart2},{id:"sk-crud-form",name:"form-builder",Ic:Edit},{id:"sk-crud-profile",name:"profile-system",Ic:User}]},
    {id:"sk-i18n",name:"Lokalizáció (2)",Ic:Languages,desc:"i18n-setup, hungarian-docs – HU/EN/DE",subs:[{id:"sk-i18n-setup",name:"i18n-setup",Ic:Globe},{id:"sk-i18n-hu",name:"hungarian-docs",Ic:FileText}]},
    {id:"sk-comm",name:"Kommunikáció (4)",Ic:Bell,desc:"Notification, email-mailgun, alert, coming-soon",subs:[{id:"sk-comm-notif",name:"notification-system",Ic:Bell},{id:"sk-comm-email",name:"email-mailgun",Ic:Mail},{id:"sk-comm-alert",name:"alert-system",Ic:AlertCircle}]},
    {id:"sk-ai",name:"AI & Intelligencia (3)",Ic:Brain,desc:"AI chat admin, TF.js intelligent menu, vector search (Qdrant)",subs:[{id:"sk-ai-chat",name:"ai-chat-admin",Ic:MessageSquare},{id:"sk-ai-tf",name:"tf-intelligent-menu",Ic:Zap},{id:"sk-ai-vec",name:"vector-search",Ic:Search}]},
    {id:"sk-analytics",name:"Analitika (3)",Ic:PieChart,desc:"Activity log, analytics dashboard, login history",subs:[{id:"sk-an-log",name:"activity-log",Ic:BookOpen},{id:"sk-an-dash",name:"analytics-dashboard",Ic:LineChart},{id:"sk-an-login",name:"login-history",Ic:Clock}]},
    {id:"sk-content",name:"Tartalom & Fájlok (3)",Ic:FolderOpen,desc:"File upload (MinIO), backup manager UI, taxonomy system",subs:[{id:"sk-con-upload",name:"file-upload",Ic:Upload},{id:"sk-con-backup",name:"backup-manager-ui",Ic:Archive},{id:"sk-con-tax",name:"taxonomy-system",Ic:Tag}]},
    {id:"sk-docs",name:"Dokumentáció (4)",Ic:BookOpen,desc:"Docs generator, API docs, support FAQ, changelog",subs:[{id:"sk-doc-gen",name:"docs-generator",Ic:FilePlus},{id:"sk-doc-api",name:"api-documentation",Ic:Code},{id:"sk-doc-faq",name:"support-faq",Ic:HelpCircle},{id:"sk-doc-cl",name:"changelog-generator",Ic:GitCommit}]},
    {id:"sk-test",name:"Tesztelés (3)",Ic:TestTube,desc:"Unit test writer, integration test, E2E test",subs:[{id:"sk-test-unit",name:"unit-test-writer",Ic:CheckCircle},{id:"sk-test-int",name:"integration-test",Ic:Link},{id:"sk-test-e2e",name:"e2e-test",Ic:Play}]},
    {id:"sk-quality",name:"Kód Minőség (3)",Ic:Award,desc:"Code review, code style, refactor",subs:[{id:"sk-q-review",name:"code-review",Ic:Eye},{id:"sk-q-style",name:"code-style",Ic:FileCheck},{id:"sk-q-refactor",name:"refactor",Ic:RefreshCw}]},
    {id:"sk-deploy",name:"Deploy & Ops (3)",Ic:Rocket,desc:"Deploy pipeline, DB migration, CI/CD setup",subs:[{id:"sk-dep-pipe",name:"deploy-pipeline",Ic:Rocket},{id:"sk-dep-migrate",name:"db-migration",Ic:Database},{id:"sk-dep-cicd",name:"ci-cd-setup",Ic:GitPullRequest}]},
  ]},

  // ── 4. RULES (7 scope-olt szabályfájl) ───────────────────────────────────
  {id:"rules",name:"Rules (7)",Ic:FileCheck,color:"#d97706",items:[
    {id:"rule-code",name:"code-style.md",Ic:Code,desc:"TypeScript strict, no any, Zod validáció, JSDoc magyarul",subs:[{id:"rule-code-edit",name:"Szerkesztés",Ic:Edit},{id:"rule-code-view",name:"Megtekintés",Ic:Eye}]},
    {id:"rule-test",name:"testing.md",Ic:TestTube,desc:"Unit/integration/E2E követelmények, coverage szabályok",subs:[{id:"rule-test-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"rule-api",name:"api-conventions.md",Ic:Globe,desc:"REST szabványok, RFC 7807 hibák, Zod, verzioning",subs:[{id:"rule-api-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"rule-sec",name:"security.md",Ic:Shield,desc:"CORS whitelist, parameterized query, secret kezelés",subs:[{id:"rule-sec-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"rule-db",name:"database.md",Ic:Database,desc:"Schema-per-service, migráció szabályok, indexek",subs:[{id:"rule-db-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"rule-fe",name:"frontend.md",Ic:Monitor,desc:"Next.js 14, Tailwind, shadcn/ui, TF.js konvenciók",subs:[{id:"rule-fe-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"rule-scraper",name:"scraper.md",Ic:Globe,desc:"Proxy pool, robots.txt tisztelet, rate limit szabályok",subs:[{id:"rule-scraper-edit",name:"Szerkesztés",Ic:Edit}]},
  ]},

  // ── 5. HOOKS (7 script, 12 esemény) ──────────────────────────────────────
  {id:"hooks",name:"Hooks (7)",Ic:GitBranch,color:"#db2777",items:[
    {id:"hook-safety",name:"check-safety.sh",Ic:Shield,desc:"PreToolUse: secret + védett fájl ellenőrzés",subs:[{id:"hook-safety-edit",name:"Szerkesztés",Ic:Edit},{id:"hook-safety-test",name:"Tesztelés",Ic:Play}]},
    {id:"hook-bash",name:"check-bash-safety.sh",Ic:Terminal,desc:"PreToolUse: veszélyes parancsok szűrése (rm -rf, DROP)",subs:[{id:"hook-bash-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"hook-inject",name:"check-injection.sh",Ic:Lock,desc:"PreToolUse: prompt injection scan [v2.3]",subs:[{id:"hook-inject-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"hook-lint",name:"auto-lint.sh",Ic:CheckCircle,desc:"PostToolUse: automatikus lint + format (Prettier, ESLint)",subs:[{id:"hook-lint-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"hook-prompt",name:"save-prompt-log.sh",Ic:BookOpen,desc:"SessionEnd: prompt dokumentáció Git-ben",subs:[{id:"hook-prompt-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"hook-notify",name:"notify.sh",Ic:Bell,desc:"Notification: Telegram (critical) / Slack (warning)",subs:[{id:"hook-notify-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"hook-router",name:"skill-router.sh",Ic:Zap,desc:"PreToolUse: intelligens skill aktiválás [v2.3]",subs:[{id:"hook-router-edit",name:"Szerkesztés",Ic:Edit}]},
  ]},

  // ── 6. COMMANDS (7 slash command) ────────────────────────────────────────
  {id:"commands",name:"Commands (7)",Ic:Terminal,color:"#059669",items:[
    {id:"cmd-review",name:"/project:review",Ic:Eye,desc:"Kód review – teljes projekt átnézés",subs:[{id:"cmd-review-run",name:"Futtatás",Ic:Play}]},
    {id:"cmd-deploy",name:"/project:deploy",Ic:Rocket,desc:"Deploy – ENV paraméterrel (local/test/prod)",subs:[{id:"cmd-deploy-run",name:"Futtatás",Ic:Play},{id:"cmd-deploy-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"cmd-testall",name:"/project:test-all",Ic:TestTube,desc:"Minden teszt futtatása (unit + integration + E2E)",subs:[{id:"cmd-testall-run",name:"Futtatás",Ic:Play}]},
    {id:"cmd-bootstrap",name:"/project:bootstrap",Ic:Plus,desc:"Modul scaffold – új modul generálás ModuleConfig-ból",subs:[{id:"cmd-bootstrap-run",name:"Futtatás",Ic:Play},{id:"cmd-bootstrap-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"cmd-bootproj",name:"/project:bootstrap-project",Ic:FolderTree,desc:"Teljes projekt váz generálás – összes skill, hook, rule",subs:[{id:"cmd-bootproj-run",name:"Futtatás",Ic:Play}]},
    {id:"cmd-secscan",name:"/project:security-scan",Ic:Shield,desc:"Biztonsági audit – OWASP, secret scan, dependency check",subs:[{id:"cmd-secscan-run",name:"Futtatás",Ic:Play}]},
    {id:"cmd-migrate",name:"/project:db-migrate",Ic:Database,desc:"DB migráció – PostgreSQL + MongoDB séma módosítás",subs:[{id:"cmd-migrate-run",name:"Futtatás",Ic:Play}]},
  ]},

  // ── 7. AGENTS (5 subagent – Haiku default!) ──────────────────────────────
  {id:"agents",name:"Agents (5)",Ic:Bot,color:"#ea580c",items:[
    {id:"agent-haiku",name:"Haiku Subagent",Ic:Cpu,desc:"Alapértelmezett – fájlkeresés, formázás (~$1.25/Mt output)",subs:[{id:"agent-haiku-cfg",name:"Konfiguráció",Ic:Settings}]},
    {id:"agent-sonnet",name:"Sonnet Worker",Ic:Code,desc:"Kód generálás, review (~$15/Mt output)",subs:[{id:"agent-sonnet-cfg",name:"Konfiguráció",Ic:Settings}]},
    {id:"agent-opus",name:"Opus Architekt",Ic:Building,desc:"Architektúra, audit – L1 jóváhagyás kell (~$75/Mt)",subs:[{id:"agent-opus-cfg",name:"Konfiguráció",Ic:Settings}]},
    {id:"agent-worktree",name:"Git Worktree Agent",Ic:GitBranch,desc:"Multi-agent izolált fejlesztés [v2.3]",subs:[{id:"agent-worktree-cfg",name:"Konfiguráció",Ic:Settings}]},
    {id:"agent-iterate",name:"Auto-Iterate (Ralph)",Ic:RefreshCw,desc:"Ralph Loop – budget limittel iteratív fejlesztés [v2.3]",subs:[{id:"agent-iterate-cfg",name:"Konfiguráció",Ic:Settings},{id:"agent-iterate-budget",name:"Budget limit",Ic:DollarSign}]},
  ]},

  // ── 8. ALKALMAZÁSOK (4 app) ──────────────────────────────────────────────
  {id:"apps",name:"Alkalmazások",Ic:Blocks,color:"#0d9488",items:[
    {id:"app-frontend",name:"Frontend (Next.js 14)",Ic:Monitor,desc:"Publikus felület – TypeScript strict, Tailwind, shadcn/ui, TF.js",subs:[{id:"app-fe-src",name:"src/",Ic:FolderOpen},{id:"app-fe-comp",name:"Komponensek",Ic:Layers},{id:"app-fe-i18n",name:"i18n (HU/EN/DE)",Ic:Languages}]},
    {id:"app-admin",name:"Admin Panel",Ic:LayoutDashboard,desc:"CRUD/DLA modulok, List View (AG Grid + shadcn), Settings, Analytics",subs:[{id:"app-admin-modules",name:"Modulok [module]",Ic:Grid},{id:"app-admin-list",name:"List View (12 komp.)",Ic:List},{id:"app-admin-settings",name:"Settings (6 oldal)",Ic:Settings},{id:"app-admin-analytics",name:"Analytics (4 nézet)",Ic:PieChart}]},
    {id:"app-backend",name:"Backend (Rust/Axum)",Ic:Server,desc:"Feature-based modulok, middleware (5), workers, scraper, spider",subs:[{id:"app-be-modules",name:"Modulok",Ic:FolderOpen},{id:"app-be-middleware",name:"Middleware (5)",Ic:Layers},{id:"app-be-workers",name:"Workers (NATS)",Ic:Cpu}]},
    {id:"app-aichat",name:"AI Chat Service",Ic:Brain,desc:"AI asszisztens szolgáltatás, Qdrant vector DB, cost tracker",subs:[{id:"app-ai-src",name:"Forráskód",Ic:Code},{id:"app-ai-models",name:"Modellek",Ic:Database}]},
  ]},

  // ── 9. DOCKER ÖKOSZISZTÉMA (7 compose fájl, 16+ service) ────────────────
  {id:"docker",name:"Docker (16+ svc)",Ic:Box,color:"#7c3aed",items:[
    {id:"dock-base",name:"docker-compose.yml",Ic:FileText,desc:"Base – 16+ szolgáltatás: DB, Redis, NATS, MinIO, app-ok",subs:[{id:"dock-base-edit",name:"Szerkesztés",Ic:Edit},{id:"dock-base-view",name:"Szolgáltatások",Ic:List}]},
    {id:"dock-local",name:"docker-compose.local.yml",Ic:Monitor,desc:"Lokális fejlesztői környezet override – hot reload",subs:[{id:"dock-local-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"dock-prod",name:"docker-compose.prod.yml",Ic:Rocket,desc:"Prod konfig – VÉDETT fájl (L1 Approve szükséges!)",subs:[{id:"dock-prod-view",name:"Megtekintés",Ic:Eye}]},
    {id:"dock-monitor",name:"docker-compose.monitoring.yml",Ic:Activity,desc:"Prometheus, Grafana, Loki, Jaeger, exporterek",subs:[{id:"dock-mon-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"dock-workers",name:"docker-compose.workers.yml",Ic:Cpu,desc:"Worker-ek auto-scale szabályokkal (NATS JetStream)",subs:[{id:"dock-work-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"dock-scraper",name:"docker-compose.scraper.yml",Ic:Globe,desc:"Scraper + Spider + Playwright konténerek",subs:[{id:"dock-scr-edit",name:"Szerkesztés",Ic:Edit}]},
    {id:"dock-makefile",name:"Makefile",Ic:Terminal,desc:"make local | make prod | make deploy | make backup",subs:[{id:"dock-make-edit",name:"Szerkesztés",Ic:Edit}]},
  ]},

  // ── 10. GUARDRAILS & BIZTONSÁG (L0-L3 négyszintű rendszer) ───────────────
  {id:"guardrails",name:"Guardrails L0-L3",Ic:Shield,color:"#dc2626",items:[
    {id:"guard-l0",name:"L0 BLOCK",Ic:XCircle,desc:"Nincs override – secret, .env commit, saját auth, rm -rf, prod DB törlés",subs:[{id:"guard-l0-rules",name:"Szabályok",Ic:List}]},
    {id:"guard-l1",name:"L1 APPROVE",Ic:AlertTriangle,desc:"Jóváhagyás kell – delete, migráció, prod deploy, Opus, új dependency",subs:[{id:"guard-l1-rules",name:"Szabályok",Ic:List}]},
    {id:"guard-l2",name:"L2 AUTO-FIX",Ic:RefreshCw,desc:"PostToolUse hook javít – lint, format, import sorrend",subs:[{id:"guard-l2-rules",name:"Szabályok",Ic:List}]},
    {id:"guard-l3",name:"L3 AUTO-ACCEPT",Ic:CheckCircle,desc:"Szabad – fájl olvasás, kód generálás (src/**), teszt, lint, docs",subs:[{id:"guard-l3-rules",name:"Szabályok",Ic:List}]},
    {id:"guard-halluc",name:"Hallucináció Megelőzés",Ic:Brain,desc:"10 stratégia – kontextus = királyság, < 150-200 instrukció",subs:[{id:"guard-halluc-list",name:"Stratégiák",Ic:List}]},
    {id:"guard-threat",name:"Threat Database",Ic:AlertCircle,desc:"Ismert fenyegetések és védekezési minták [v2.3]",subs:[{id:"guard-threat-list",name:"Fenyegetések",Ic:List}]},
  ]},

  // ── 11. DOKUMENTÁCIÓ & RUNBOOKS ──────────────────────────────────────────
  {id:"docs",name:"Dokumentáció",Ic:BookOpen,color:"#64748b",items:[
    {id:"doc-arch",name:"architecture.md",Ic:Building,desc:"Teljes rendszer architektúra – feature-based szervezés",subs:[{id:"doc-arch-view",name:"Megtekintés",Ic:Eye}]},
    {id:"doc-api",name:"api-reference.md",Ic:Code,desc:"REST API referencia – endpoint-ok, Zod sémák",subs:[{id:"doc-api-view",name:"Megtekintés",Ic:Eye}]},
    {id:"doc-eco",name:"ECOSYSTEM.md",Ic:Globe,desc:"Adatréteg definíciók – SkillPass.ID, aibos.space, aio.broker",subs:[{id:"doc-eco-view",name:"Megtekintés",Ic:Eye}]},
    {id:"doc-adr",name:"ADR Döntések",Ic:FileCheck,desc:"Architecture Decision Records (001-nextjs, 002-schema, 003-caddy)",subs:[{id:"doc-adr-list",name:"Lista",Ic:List},{id:"doc-adr-add",name:"Új ADR",Ic:Plus}]},
    {id:"doc-runbooks",name:"Runbooks (7)",Ic:AlertTriangle,desc:"Incident kezelés – DB recovery, deploy rollback, security [v2.3]",subs:[{id:"doc-rb-db",name:"DB Recovery",Ic:Database},{id:"doc-rb-deploy",name:"Deploy Rollback",Ic:RefreshCw},{id:"doc-rb-sec",name:"Security Incident",Ic:Shield},{id:"doc-rb-cpu",name:"High CPU Alert",Ic:Cpu}]},
    {id:"doc-prompts",name:"Prompt Templates (5)",Ic:FileText,desc:"Újrafelhasználható sablonok – feature, bug, arch review [v2.3]",subs:[{id:"doc-pt-feature",name:"Feature Request",Ic:Plus},{id:"doc-pt-bug",name:"Bug Report",Ic:Bug},{id:"doc-pt-arch",name:"Arch Review",Ic:Building}]},
    {id:"doc-onboard",name:"Onboarding",Ic:GraduationCap,desc:"Szerepkör-specifikus guides – dev, tech lead, CTO",subs:[{id:"doc-on-dev",name:"Fejlesztőknek",Ic:Code},{id:"doc-on-lead",name:"Tech Lead-eknek",Ic:Users},{id:"doc-on-cto",name:"CTO-nak",Ic:Building}]},
  ]},

  // ── 12. INFRASTRUKTÚRA ───────────────────────────────────────────────────
  {id:"infra",name:"Infrastruktúra",Ic:Server,color:"#9333ea",items:[
    {id:"infra-caddy",name:"Caddy Gateway",Ic:Globe,desc:"Reverse proxy, aio.broker, domain routing, rate limit, error pages",subs:[{id:"infra-caddy-file",name:"Caddyfile",Ic:FileText},{id:"infra-caddy-errors",name:"Error Pages (4)",Ic:AlertCircle}]},
    {id:"infra-cf",name:"Cloudflare",Ic:Cloud,desc:"Tunnel, CDN cache, WAF, DDoS védelem, Zero Trust access",subs:[{id:"infra-cf-tunnel",name:"Tunnel Config",Ic:Wifi},{id:"infra-cf-waf",name:"WAF Szabályok",Ic:Shield}]},
    {id:"infra-db",name:"Adatbázisok",Ic:Database,desc:"PostgreSQL (schema-per-service, 7 init SQL), MongoDB, Redis",subs:[{id:"infra-db-pg",name:"PostgreSQL",Ic:Database},{id:"infra-db-mongo",name:"MongoDB",Ic:Database},{id:"infra-db-redis",name:"Redis",Ic:Zap}]},
    {id:"infra-monitor",name:"Monitoring Stack",Ic:Activity,desc:"Prometheus, Grafana (10 dashboard), Loki, Jaeger, Alertmanager",subs:[{id:"infra-mon-prom",name:"Prometheus",Ic:BarChart2},{id:"infra-mon-graf",name:"Grafana (10 dash)",Ic:PieChart},{id:"infra-mon-alerts",name:"Alert Rules (7)",Ic:Bell}]},
    {id:"infra-queue",name:"NATS JetStream",Ic:Wifi,desc:"Message queue – 6 worker típus, auto-scale",subs:[{id:"infra-nats-cfg",name:"Konfiguráció",Ic:Settings}]},
    {id:"infra-storage",name:"MinIO / Hetzner S3",Ic:HardDrive,desc:"Object storage, WORM backup (write-only!), presigned URL",subs:[{id:"infra-s3-minio",name:"MinIO (lokális)",Ic:HardDrive},{id:"infra-s3-hetzner",name:"Hetzner WORM",Ic:Lock}]},
  ]},
];

const ALL=CATS.flatMap(c=>c.items.map(i=>({...i,catId:c.id,catName:c.name,catColor:c.color})));
const ADD_ACTIONS=CATS.flatMap(c=>c.items.flatMap(i=>(i.subs||[]).filter(s=>s.name.startsWith("Új")||s.name==="Futtatás"||s.name==="Szerkesztés"||s.name==="Tesztelés").map(s=>({...s,parentName:i.name,catName:c.name,catColor:c.color}))));
const pick=a=>a[Math.floor(Math.random()*a.length)];

// ═══ TÉMA (shadcn/ui design tokens) ═══
const TH={
  light:{bg:"#fafafa",card:"#fff",sb:"#fff",sbBdr:"#e4e4e7",bdr:"#e4e4e7",bdrS:"#f4f4f5",mut:"#f4f4f5",tx:"#09090b",tx2:"#71717a",tx3:"#a1a1aa",pri:"#18181b",priFg:"#fafafa",sbTx:"#3f3f46",sbHov:"#f4f4f5",sbAct:"#ede9fe",sbCat:"#f4f4f5"},
  dark:{bg:"#09090b",card:"#18181b",sb:"#0f0f12",sbBdr:"#27272a",bdr:"#27272a",bdrS:"#1e1e22",mut:"#1e1e22",tx:"#fafafa",tx2:"#a1a1aa",tx3:"#71717a",pri:"#fafafa",priFg:"#09090b",sbTx:"#d4d4d8",sbHov:"#1e1e22",sbAct:"#1e1b4b",sbCat:"#18181b"},
};

// ═══ MENÜ KÁRTYA KOMPONENS ═══
function MCard({item,onSelect,isFav,onFav,rank,conf,t}){const Ico=item.Ic;return(
  <div style={{display:"flex",alignItems:"center",gap:10,padding:"8px 10px",borderRadius:8,cursor:"pointer",border:"1px solid transparent",transition:".12s"}}
    onMouseEnter={e=>{e.currentTarget.style.background=t.mut;e.currentTarget.style.borderColor=t.bdr}}
    onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.borderColor="transparent"}}
    onClick={()=>onSelect(item)}>
    <div style={{width:34,height:34,borderRadius:8,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,background:`${item.catColor||"#6366f1"}12`,color:item.catColor}}><Ico size={16}/></div>
    <div style={{flex:1,minWidth:0}}>
      <div style={{fontSize:13,fontWeight:500,color:t.tx}}>{item.name}</div>
      <div style={{fontSize:11,color:t.tx3,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{item.desc}</div>
    </div>
    <div style={{display:"flex",alignItems:"center",gap:4}}>
      {rank!=null&&<span style={{fontFamily:"monospace",fontSize:9,fontWeight:600,padding:"2px 4px",borderRadius:4,color:"#fff",background:rank<=2?"#18181b":"#71717a"}}>#{rank}</span>}
      {conf>0&&<span style={{fontFamily:"monospace",fontSize:9,color:t.tx3}}>{(conf*100).toFixed(0)}%</span>}
      <button onClick={e=>{e.stopPropagation();onFav(item.id)}} style={{background:"none",border:"none",cursor:"pointer",padding:2,display:"flex",alignItems:"center",color:isFav?"#eab308":t.tx3}}><Star size={14} fill={isFav?"#eab308":"none"}/></button>
    </div>
  </div>
)}

// ═══════════════════════════════════════════════════════════════════════════
// FŐ ALKALMAZÁS
// ═══════════════════════════════════════════════════════════════════════════
export default function App(){
  const [ai]=useState(()=>new MenuAI());
  const [ready,setReady]=useState(false);
  const [dark,setDark]=useState(false);
  const [sideOpen,setSideOpen]=useState(false);
  const [collapsed,setCollapsed]=useState(true);
  const [popOpen,setPopOpen]=useState(false);
  const [chatOpen,setChatOpen]=useState(false);
  const [avatarOpen,setAvatarOpen]=useState(false);
  const [userMenuOpen,setUserMenuOpen]=useState(false);
  const [quickAddOpen,setQuickAddOpen]=useState(false);
  const [addQ,setAddQ]=useState("");
  const [q,setQ]=useState("");
  const [sideQ,setSideQ]=useState("");
  const [tab,setTab]=useState("ai");
  const [favs,setFavs]=useState(["dash-main","cfg-claudemd","sk-crud","cmd-review","hook-safety","guard-l0"]);
  const [preds,setPreds]=useState([]);
  const [sel,setSel]=useState(null);
  const [openCats,setOpenCats]=useState(new Set(["dashboard"]));
  const [openItems,setOpenItems]=useState(new Set());
  const [toast,setToast]=useState(null);
  const [msgs,setMsgs]=useState([]);
  const [chatIn,setChatIn]=useState("");
  const [typing,setTyping]=useState(false);
  const popRef=useRef(null);const searchRef=useRef(null);const chatEnd=useRef(null);const chatIRef=useRef(null);const avatarRef=useRef(null);const userRef=useRef(null);
  const t=dark?TH.dark:TH.light;
  const isMob=typeof window!=="undefined"&&window.innerWidth<768;
  const isC=collapsed&&!isMob;

  // Inicializálás – AI betanítás szimulált használati adatokkal
  useEffect(()=>{ai.init().then(()=>{setReady(true);["dash-main","cfg-claudemd","sk-crud","cmd-review","hook-safety","guard-l0","cfg-settings","sk-infra","dock-base","app-admin","infra-caddy","doc-runbooks","agent-sonnet","sk-security","dash-cost","rule-code"].forEach((id,i)=>setTimeout(()=>ai.record(id),i*30));setTimeout(()=>setPreds(ai.predict(ALL,6)),600)})},[]);
  useEffect(()=>{if(popOpen&&searchRef.current)setTimeout(()=>searchRef.current.focus(),80)},[popOpen]);
  useEffect(()=>{if(chatOpen&&msgs.length===0)setMsgs([{r:"ai",t:pick(["Szia! Kérdezz a Claude Code projekt struktúráról!","Üdv! Segítek a skills, hooks és rules konfigurálásában.","Claude Code v2.3 asszisztens vagyok. Miben segíthetek?"]),res:[]}]);if(chatOpen)setTimeout(()=>chatIRef.current?.focus(),100)},[chatOpen]);
  useEffect(()=>{chatEnd.current?.scrollIntoView({behavior:"smooth"})},[msgs]);
  useEffect(()=>{const h=e=>{if((e.metaKey||e.ctrlKey)&&e.key==="k"){e.preventDefault();setPopOpen(true);setQ("")}if(e.key==="Escape"){setPopOpen(false);setChatOpen(false);setAvatarOpen(false);setUserMenuOpen(false);setQuickAddOpen(false)}};window.addEventListener("keydown",h);return()=>window.removeEventListener("keydown",h)},[]);
  useEffect(()=>{const h=e=>{if(avatarRef.current&&!avatarRef.current.contains(e.target))setAvatarOpen(false);if(userRef.current&&!userRef.current.contains(e.target))setUserMenuOpen(false)};document.addEventListener("mousedown",h);return()=>document.removeEventListener("mousedown",h)},[]);

  const sToast=msg=>{setToast(msg);setTimeout(()=>setToast(null),2000)};
  const doOpen=useCallback(item=>{ai.record(item.id);setSel(item);setPreds(ai.predict(ALL,6));setPopOpen(false);setSideOpen(false)},[ai]);
  const togFav=useCallback(id=>{setFavs(p=>{if(p.includes(id)){sToast("Eltávolítva");return p.filter(x=>x!==id)}if(p.length>=12){sToast("Max 12");return p}sToast("Kedvenc ★");return[...p,id]})},[]);
  const togCat=id=>setOpenCats(p=>{const n=new Set(p);n.has(id)?n.delete(id):n.add(id);return n});
  const togItem=id=>setOpenItems(p=>{const n=new Set(p);n.has(id)?n.delete(id):n.add(id);return n});
  const sendChat=useCallback(()=>{const v=chatIn.trim();if(!v)return;setMsgs(p=>[...p,{r:"user",t:v,res:[]}]);setChatIn("");setTyping(true);setTimeout(()=>{const res=ai.chatSearch(v,ALL);setMsgs(p=>[...p,{r:"ai",t:res.length>0?pick(["Ezeket találtam a projektben:","Íme a releváns elemek:","Szerintem ezeket keresed:"]):pick(["Nem találtam releváns elemet.","Nincs találat a projekt struktúrában."]),res}]);setTyping(false)},500+Math.random()*400)},[chatIn,ai]);
  const filtered=useMemo(()=>{if(!q.trim())return[];const s=q.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");return ALL.filter(i=>`${i.name} ${i.desc} ${i.catName}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s))},[q]);
  const favItems=useMemo(()=>ALL.filter(i=>favs.includes(i.id)),[favs]);
  const sideFiltered=useMemo(()=>{if(!sideQ.trim())return CATS;const s=sideQ.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");return CATS.map(c=>{const fi=c.items.filter(i=>`${i.name} ${i.desc}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s));if(fi.length>0||c.name.toLowerCase().includes(s))return{...c,items:fi.length>0?fi:c.items};return null}).filter(Boolean)},[sideQ]);
  const filteredAdds=useMemo(()=>{if(!addQ.trim())return ADD_ACTIONS.slice(0,15);const s=addQ.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"");return ADD_ACTIONS.filter(a=>`${a.name} ${a.parentName} ${a.catName}`.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").includes(s))},[addQ]);

  const SB_H = 48;

  return(
    <div style={{fontFamily:'-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif',display:"flex",height:"100vh",width:"100vw",background:t.bg,color:t.tx,overflow:"hidden",position:"relative",fontSize:14}}>
      {sideOpen&&isMob&&<div onClick={()=>setSideOpen(false)} style={{position:"fixed",inset:0,background:"rgba(0,0,0,.4)",zIndex:40}}/>}

      {/* ═══ SIDEBAR ═══ */}
      <aside style={{width:isMob?"280px":`${isC?56:260}px`,background:t.sb,display:"flex",flexDirection:"column",flexShrink:0,borderRight:`1px solid ${t.sbBdr}`,zIndex:50,transition:"width .2s ease",...(isMob?{position:"fixed",left:0,top:0,bottom:0,transform:sideOpen?"translateX(0)":"translateX(-100%)",transition:"transform .2s"}:{})}}>

        {/* HEADER — fix magasság, nincs ugrálás */}
        <div style={{display:"flex",alignItems:"center",height:SB_H,padding:"0 10px",borderBottom:`1px solid ${t.sbBdr}`,gap:8,flexShrink:0}}>
          {!isMob&&<button onClick={()=>setCollapsed(!collapsed)} style={{width:28,height:28,borderRadius:6,border:"none",background:"transparent",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,flexShrink:0,transition:".15s"}}
            onMouseEnter={e=>{e.currentTarget.style.background=t.sbHov;e.currentTarget.style.color=t.tx}}
            onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.color=t.tx2}}
            title={isC?"Sidebar kinyitása":"Sidebar összecsukása"}>
            <PanelLeft size={18}/>
          </button>}
          {isMob&&<button onClick={()=>setSideOpen(false)} style={{width:28,height:28,borderRadius:6,border:"none",background:"transparent",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,flexShrink:0}}><X size={18}/></button>}

          {/* Logo — csak kinyitott állapotban */}
          {!isC&&<div style={{display:"flex",alignItems:"center",gap:7,flex:1,minWidth:0}}>
            <div style={{width:24,height:24,borderRadius:5,background:"linear-gradient(135deg,#6366f1,#818cf8)",color:"#fff",display:"flex",alignItems:"center",justifyContent:"center",fontWeight:700,fontSize:12,flexShrink:0}}>C</div>
            <span style={{fontWeight:700,fontSize:14,color:t.tx,letterSpacing:".04em"}}>Claude v2.3</span>
          </div>}
        </div>

        {/* AI státusz badge */}
        {!isC&&<div style={{display:"flex",alignItems:"center",gap:7,margin:"8px 10px 4px",padding:"5px 9px",borderRadius:6,background:t.mut,border:`1px solid ${t.bdr}`,fontSize:11}}>
          <div style={{width:5,height:5,borderRadius:"50%",background:ready?"#22c55e":"#a1a1aa",boxShadow:ready?"0 0 6px #22c55e88":"none"}}/>
          <span style={{flex:1,color:t.tx2}}>{ready?"AI aktív – 67 skill":"Inicializálás..."}</span>
          <span style={{fontFamily:"monospace",fontSize:9,color:"#6366f1",background:"#6366f118",padding:"1px 4px",borderRadius:3}}>v2.3</span>
        </div>}

        {/* Menü keresés */}
        {!isC&&<div style={{padding:"6px 10px"}}><div style={{display:"flex",alignItems:"center",gap:6,padding:"5px 8px",borderRadius:6,border:`1px solid ${t.bdr}`,background:t.mut}}>
          <Search size={13} color={t.tx3}/><input value={sideQ} onChange={e=>setSideQ(e.target.value)} placeholder="Menü szűrés..." style={{flex:1,border:"none",outline:"none",fontSize:12,color:t.tx,background:"transparent",fontFamily:"inherit"}}/>
          {sideQ&&<button onClick={()=>setSideQ("")} style={{background:"none",border:"none",cursor:"pointer",display:"flex",color:t.tx3}}><X size={12}/></button>}
        </div></div>}

        {/* Navigáció – kategóriák és elemek */}
        <nav style={{flex:1,overflowY:"auto",padding:"4px 0"}}>
          {sideFiltered.map(cat=>{const CI=cat.Ic;const isO=openCats.has(cat.id);return(
            <div key={cat.id}>
              <button onClick={()=>togCat(cat.id)} style={{display:"flex",alignItems:"center",gap:isC?0:8,width:"100%",padding:isC?"8px 0":"6px 12px",border:"none",background:isO?t.sbCat:"transparent",color:isO?t.tx:t.sbTx,fontSize:12,fontWeight:600,cursor:"pointer",textAlign:"left",justifyContent:isC?"center":"flex-start",fontFamily:"inherit",transition:".12s"}}>
                <CI size={15} style={{color:cat.color,flexShrink:0}}/>{!isC&&<span style={{flex:1}}>{cat.name}</span>}
                {!isC&&<ChevronRight size={12} style={{color:t.tx3,transition:"transform .15s",transform:isO?"rotate(90deg)":"none"}}/>}
              </button>
              {isO&&!isC&&<div style={{padding:"2px 0 4px"}}>{cat.items.map(it=>{const II=it.Ic;const hasSubs=it.subs&&it.subs.length>0;const itO=openItems.has(it.id);return(
                <div key={it.id}>
                  <div style={{display:"flex",alignItems:"center",gap:6,padding:"5px 12px 5px 28px",cursor:"pointer",transition:".1s",background:sel?.id===it.id?t.sbAct:"transparent"}}
                    onMouseEnter={e=>{if(sel?.id!==it.id)e.currentTarget.style.background=t.sbHov}}onMouseLeave={e=>{if(sel?.id!==it.id)e.currentTarget.style.background="transparent"}}>
                    {hasSubs?<button onClick={e=>{e.stopPropagation();togItem(it.id)}} style={{background:"none",border:"none",cursor:"pointer",display:"flex",padding:0,color:t.tx3}}><ChevronRight size={11} style={{transition:"transform .15s",transform:itO?"rotate(90deg)":"none"}}/></button>:<span style={{width:11}}/>}
                    <button onClick={()=>doOpen({...it,catName:cat.name,catColor:cat.color})} style={{display:"flex",alignItems:"center",gap:6,flex:1,background:"none",border:"none",cursor:"pointer",color:sel?.id===it.id?t.tx:t.sbTx,fontSize:12,textAlign:"left",padding:0,fontFamily:"inherit"}}>
                      <II size={13} style={{color:cat.color,opacity:.7}}/><span style={{flex:1}}>{it.name}</span>{favs.includes(it.id)&&<Star size={9} fill="#eab308" color="#eab308"/>}
                    </button>
                  </div>
                  {hasSubs&&itO&&<div style={{padding:"1px 0"}}>{it.subs.map(sub=>{const SI=sub.Ic;return(
                    <button key={sub.id} onClick={()=>{doOpen({...it,catName:cat.name,catColor:cat.color});sToast(sub.name)}}
                      style={{display:"flex",alignItems:"center",gap:6,width:"100%",padding:"3px 12px 3px 56px",border:"none",background:"transparent",color:t.tx3,fontSize:11,cursor:"pointer",textAlign:"left",fontFamily:"inherit",transition:".1s"}}
                      onMouseEnter={e=>{e.currentTarget.style.background=t.sbHov;e.currentTarget.style.color=t.tx}}onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.color=t.tx3}}>
                      <SI size={11}/><span>{sub.name}</span>
                    </button>)})}</div>}
                </div>)})}</div>}
            </div>)})}
        </nav>

        {/* Felhasználó footer (SkillPass.ID auth) */}
        <div ref={userRef} style={{position:"relative",borderTop:`1px solid ${t.sbBdr}`}}>
          <button onClick={()=>setUserMenuOpen(!userMenuOpen)} style={{display:"flex",alignItems:"center",gap:isC?0:8,width:"100%",padding:isC?"10px 0":"8px 12px",border:"none",background:userMenuOpen?t.sbHov:"transparent",cursor:"pointer",fontFamily:"inherit",justifyContent:isC?"center":"flex-start",transition:".1s"}}
            onMouseEnter={e=>{if(!userMenuOpen)e.currentTarget.style.background=t.sbHov}}onMouseLeave={e=>{if(!userMenuOpen)e.currentTarget.style.background="transparent"}}>
            <div style={{width:28,height:28,borderRadius:7,background:"linear-gradient(135deg,#6366f1,#a78bfa)",color:"#fff",display:"flex",alignItems:"center",justifyContent:"center",fontSize:11,fontWeight:600,flexShrink:0}}>KI</div>
            {!isC&&<><div style={{flex:1,minWidth:0,textAlign:"left"}}><div style={{fontSize:12,fontWeight:500,color:t.tx,lineHeight:1.2}}>Kerek István</div><div style={{fontSize:10,color:t.tx3}}>istvan.kerek@gmail.com</div></div><ChevronDown size={14} style={{color:t.tx3,transform:userMenuOpen?"rotate(180deg)":"none",transition:"transform .15s"}}/></>}
          </button>
          {userMenuOpen&&<div style={{position:"absolute",bottom:"100%",left:isC?4:8,right:isC?"auto":8,width:isC?220:"auto",marginBottom:4,background:t.card,border:`1px solid ${t.bdr}`,borderRadius:10,boxShadow:"0 -10px 30px -8px rgba(0,0,0,.12)",padding:4,zIndex:200}}>
            <div style={{padding:"10px 10px 8px",borderBottom:`1px solid ${t.bdrS}`,marginBottom:4}}><div style={{fontSize:13,fontWeight:600,color:t.tx}}>Kerek István</div><div style={{fontSize:12,color:t.tx3}}>istvan.kerek@gmail.com</div><div style={{fontSize:10,color:t.tx3,marginTop:2}}>Super Admin · SkillPass.ID OIDC</div></div>
            {[{Ic:User,l:"Profil"},{Ic:Settings,l:"Fiók beállítások"},{Ic:Keyboard,l:"Billentyűparancsok"},{Ic:HelpCircle,l:"Súgó & Dokumentáció"}].map((m,i)=>(
              <button key={i} onClick={()=>{sToast(m.l);setUserMenuOpen(false)}} style={{display:"flex",alignItems:"center",gap:8,width:"100%",padding:"7px 10px",border:"none",borderRadius:6,background:"transparent",cursor:"pointer",fontSize:13,color:t.tx,textAlign:"left",fontFamily:"inherit"}}
                onMouseEnter={e=>{e.currentTarget.style.background=t.mut}}onMouseLeave={e=>{e.currentTarget.style.background="transparent"}}><m.Ic size={14} color={t.tx2}/><span>{m.l}</span></button>))}
            <div style={{borderTop:`1px solid ${t.bdrS}`,paddingTop:4,marginTop:4}}>
              <button onClick={()=>{sToast("Kijelentkezés – SkillPass.ID OIDC");setUserMenuOpen(false)}} style={{display:"flex",alignItems:"center",gap:8,width:"100%",padding:"7px 10px",border:"none",borderRadius:6,background:"transparent",cursor:"pointer",fontSize:13,color:"#ef4444",textAlign:"left",fontFamily:"inherit"}}
                onMouseEnter={e=>{e.currentTarget.style.background=dark?"#1c1c1c":"#fef2f2"}}onMouseLeave={e=>{e.currentTarget.style.background="transparent"}}><LogOut size={14}/><span>Kijelentkezés</span></button>
            </div>
          </div>}
        </div>
      </aside>

      {/* ═══ MAIN CONTENT ═══ */}
      <main style={{flex:1,display:"flex",flexDirection:"column",overflow:"hidden",minWidth:0,paddingBottom:isMob?56:0}}>

        {/* Top header bar */}
        <header style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"0 12px",borderBottom:`1px solid ${t.bdr}`,background:t.card,gap:6,height:SB_H,flexShrink:0}}>
          <div style={{display:"flex",alignItems:"center",gap:6,minWidth:0}}>
            {isMob&&<button onClick={()=>setSideOpen(true)} style={{background:"none",border:"none",color:t.tx2,cursor:"pointer",display:"flex",padding:4}}><Menu size={20}/></button>}
            <h1 style={{fontSize:15,fontWeight:600,whiteSpace:"nowrap"}}>{sel?sel.name:"Claude Code Projekt"}</h1>
            {sel&&!isMob&&<span style={{fontSize:12,color:t.tx3}}>{sel.catName}</span>}
          </div>
          <div style={{display:"flex",alignItems:"center",gap:5,flexShrink:0}}>
            {/* Gyors művelet gomb */}
            <button onClick={()=>setQuickAddOpen(true)} style={{height:32,display:"flex",alignItems:"center",gap:4,padding:"0 10px",border:`1px solid ${t.bdr}`,borderRadius:7,background:t.card,cursor:"pointer",fontSize:12,fontWeight:500,color:t.tx2,fontFamily:"inherit",transition:".12s"}}
              onMouseEnter={e=>{e.currentTarget.style.borderColor="#6366f1";e.currentTarget.style.color="#6366f1"}}
              onMouseLeave={e=>{e.currentTarget.style.borderColor=t.bdr;e.currentTarget.style.color=t.tx2}}>
              <Plus size={15}/>{!isMob&&<span>Művelet</span>}
            </button>

            {/* Kereső */}
            <button onClick={()=>{setPopOpen(true);setQ("")}} style={{display:"flex",alignItems:"center",gap:5,padding:"0 9px",height:32,border:`1px solid ${t.bdr}`,borderRadius:7,background:t.bg,cursor:"pointer",fontSize:13,color:t.tx3}}>
              <Search size={14}/>{!isMob&&<><span style={{flex:1,textAlign:"left"}}>Keresés...</span><kbd style={{padding:"1px 4px",borderRadius:3,background:t.mut,fontFamily:"monospace",fontSize:10,color:t.tx3,border:`1px solid ${t.bdr}`}}>⌘K</kbd></>}
            </button>
            <button onClick={()=>setPopOpen(!popOpen)} style={{width:32,height:32,border:`1px solid ${t.bdr}`,borderRadius:7,background:popOpen?t.mut:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:popOpen?t.tx:t.tx2}}><Grid size={17}/></button>
            <button onClick={()=>setChatOpen(!chatOpen)} style={{width:32,height:32,border:`1px solid ${t.bdr}`,borderRadius:7,background:chatOpen?t.mut:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:chatOpen?t.tx:t.tx2,position:"relative"}}><MessageSquare size={17}/><div style={{position:"absolute",bottom:3,right:3,width:6,height:6,borderRadius:"50%",background:"#22c55e",border:`1.5px solid ${t.card}`}}/></button>
            {!isMob&&<button style={{width:32,height:32,border:`1px solid ${t.bdr}`,borderRadius:7,background:t.card,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,position:"relative"}}><Bell size={17}/><div style={{position:"absolute",top:4,right:4,width:5,height:5,borderRadius:"50%",background:"#ef4444",border:`1.5px solid ${t.card}`}}/></button>}

            {/* Avatar + megjelenés váltó */}
            <div ref={avatarRef} style={{position:"relative"}}>
              <button onClick={()=>setAvatarOpen(!avatarOpen)} style={{width:32,height:32,borderRadius:7,background:dark?"#27272a":"#18181b",color:"#fafafa",display:"flex",alignItems:"center",justifyContent:"center",fontSize:11,fontWeight:600,border:"none",cursor:"pointer"}}>KI</button>
              {avatarOpen&&<div style={{position:"absolute",top:"calc(100% + 6px)",right:0,width:220,background:t.card,border:`1px solid ${t.bdr}`,borderRadius:10,boxShadow:"0 10px 30px -8px rgba(0,0,0,.15)",padding:4,zIndex:200}}>
                <div style={{padding:"8px 10px"}}><span style={{fontSize:13,color:t.tx,fontWeight:500}}>Megjelenés</span></div>
                <div style={{display:"flex",gap:3,padding:"0 10px 8px"}}>{[{v:false,l:"Világos",I:Sun},{v:true,l:"Sötét",I:Moon}].map(m=>(
                  <button key={m.l} onClick={()=>{setDark(m.v);setAvatarOpen(false)}} style={{flex:1,display:"flex",alignItems:"center",justifyContent:"center",gap:5,padding:"6px 0",borderRadius:6,border:`1px solid ${dark===m.v?"#6366f1":t.bdr}`,background:dark===m.v?"#6366f110":"transparent",cursor:"pointer",fontSize:12,color:dark===m.v?"#6366f1":t.tx2,fontWeight:dark===m.v?600:400,fontFamily:"inherit"}}><m.I size={13}/>{m.l}</button>))}</div>
                <div style={{borderTop:`1px solid ${t.bdrS}`,paddingTop:4}}>{[{Ic:User,l:"Profil"},{Ic:Settings,l:"Beállítások"}].map((m,i)=>(
                  <button key={i} onClick={()=>{sToast(m.l);setAvatarOpen(false)}} style={{display:"flex",alignItems:"center",gap:8,width:"100%",padding:"7px 10px",border:"none",borderRadius:6,background:"transparent",cursor:"pointer",fontSize:13,color:t.tx,textAlign:"left",fontFamily:"inherit"}}
                    onMouseEnter={e=>{e.currentTarget.style.background=t.mut}}onMouseLeave={e=>{e.currentTarget.style.background="transparent"}}><m.Ic size={14} color={t.tx2}/><span>{m.l}</span></button>))}</div>
                <div style={{borderTop:`1px solid ${t.bdrS}`,paddingTop:4,marginTop:4}}>
                  <button onClick={()=>{sToast("Kijelentkezés");setAvatarOpen(false)}} style={{display:"flex",alignItems:"center",gap:8,width:"100%",padding:"7px 10px",border:"none",borderRadius:6,background:"transparent",cursor:"pointer",fontSize:13,color:"#ef4444",textAlign:"left",fontFamily:"inherit"}}
                    onMouseEnter={e=>{e.currentTarget.style.background=dark?"#1c1c1c":"#fef2f2"}}onMouseLeave={e=>{e.currentTarget.style.background="transparent"}}><LogOut size={14}/><span>Kijelentkezés</span></button>
                </div>
              </div>}
            </div>
          </div>
        </header>

        {/* AI predikciós sáv */}
        {!isMob&&<div style={{display:"flex",alignItems:"center",gap:8,padding:"6px 14px",background:t.card,borderBottom:`1px solid ${t.bdrS}`,overflow:"hidden"}}>
          <div style={{display:"flex",alignItems:"center",gap:4,fontSize:11,color:t.tx3,fontWeight:500,flexShrink:0}}><Zap size={12}/><span>AI</span></div>
          <div style={{display:"flex",gap:3,overflowX:"auto"}}>{preds.slice(0,6).map(p=>{const PI=p.Ic;return(<button key={p.id} onClick={()=>doOpen(p)} style={{display:"flex",alignItems:"center",gap:4,padding:"3px 8px",borderRadius:5,border:`1px solid ${t.bdr}`,background:t.card,cursor:"pointer",fontSize:11,color:t.tx2,whiteSpace:"nowrap",fontFamily:"inherit",position:"relative",overflow:"hidden"}}><PI size={12}/><span>{p.name}</span>{p.conf>0&&<div style={{position:"absolute",bottom:0,left:0,height:2,width:`${p.conf*100}%`,background:"#6366f1",borderRadius:1,opacity:.4}}/>}</button>)})}</div>
        </div>}

        {/* Tartalom terület */}
        <div style={{flex:1,overflowY:"auto",padding:isMob?12:20}}>
          {sel?<div>
            {/* Kiválasztott elem fejléc */}
            <div style={{display:"flex",alignItems:"center",gap:12,padding:14,background:t.card,borderRadius:10,border:`1px solid ${t.bdr}`,marginBottom:14}}>
              <div style={{width:48,height:48,borderRadius:9,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,background:`${sel.catColor}14`,color:sel.catColor}}>{sel.Ic&&<sel.Ic size={26}/>}</div>
              <div style={{flex:1}}><h2 style={{fontSize:17,fontWeight:600}}>{sel.name}</h2><p style={{fontSize:13,color:t.tx2,marginTop:1}}>{sel.desc}</p></div>
              <button onClick={()=>togFav(sel.id)} style={{background:"none",border:`1px solid ${favs.includes(sel.id)?"#eab30844":t.bdr}`,borderRadius:7,width:34,height:34,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:favs.includes(sel.id)?"#eab308":t.tx3}}><Bookmark size={17} fill={favs.includes(sel.id)?"#eab308":"none"}/></button>
            </div>
            {/* Sub-akciók */}
            {sel.subs&&sel.subs.length>0&&<div style={{display:"flex",gap:6,marginBottom:14,flexWrap:"wrap"}}>{sel.subs.map(sub=>{const SI=sub.Ic;return(<button key={sub.id} onClick={()=>sToast(sub.name)} style={{display:"flex",alignItems:"center",gap:5,padding:"7px 12px",borderRadius:7,border:`1px solid ${t.bdr}`,background:t.card,cursor:"pointer",fontSize:12,fontWeight:500,color:t.tx2,fontFamily:"inherit"}}
              onMouseEnter={e=>{e.currentTarget.style.borderColor=sel.catColor;e.currentTarget.style.color=t.tx}}onMouseLeave={e=>{e.currentTarget.style.borderColor=t.bdr;e.currentTarget.style.color=t.tx2}}><SI size={14} style={{color:sel.catColor}}/>{sub.name}</button>)})}</div>}
            {/* Skeleton placeholder kártyák */}
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(200px,1fr))",gap:8}}>{[1,2,3,4,5,6].map(i=>(<div key={i} style={{background:t.card,borderRadius:10,border:`1px solid ${t.bdr}`,padding:14,display:"flex",flexDirection:"column",gap:7}}><div style={{height:7,borderRadius:4,background:t.mut,width:"90%"}}/><div style={{height:7,borderRadius:4,background:t.mut,width:"60%"}}/><div style={{height:24,borderRadius:5,background:t.mut,marginTop:3,opacity:.5}}/></div>))}</div>
          </div>:
          /* Kezdőlap – Everengine Claude Code v2.3 összefoglaló */
          <div style={{display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",minHeight:"50vh",textAlign:"center",padding:14}}>
            <div style={{width:56,height:56,borderRadius:12,background:t.mut,border:`1px solid ${t.bdr}`,display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,marginBottom:14}}><Terminal size={32} strokeWidth={1.5}/></div>
            <h2 style={{fontSize:20,fontWeight:700,marginBottom:5}}>Everengine Claude Code v2.3</h2>
            <p style={{fontSize:13,color:t.tx2,maxWidth:440,lineHeight:1.6}}>67 skill · 7 rule · 7 hook · 5 agent · 7 command · L0-L3 guardrails<br/>Használd a <strong>menü gombot</strong>, a <strong>⌘K</strong> keresőt, vagy az <strong>AI Chat</strong>-et.</p>
            {/* Statisztika badge-ek */}
            <div style={{display:"flex",gap:6,marginTop:16,flexWrap:"wrap",justifyContent:"center"}}>
              {[{l:"Skills",c:"#0891b2",n:"67"},{l:"Rules",c:"#d97706",n:"7"},{l:"Hooks",c:"#db2777",n:"7"},{l:"Agents",c:"#ea580c",n:"5"},{l:"Commands",c:"#059669",n:"7"},{l:"Guardrails",c:"#dc2626",n:"L0-L3"}].map(b=>(
                <div key={b.l} style={{padding:"8px 14px",borderRadius:8,border:`1px solid ${t.bdr}`,background:t.card,textAlign:"center"}}>
                  <div style={{fontSize:16,fontWeight:700,color:b.c,fontFamily:"monospace"}}>{b.n}</div>
                  <div style={{fontSize:10,color:t.tx3,marginTop:2}}>{b.l}</div>
                </div>
              ))}
            </div>
          </div>}
        </div>
      </main>

      {/* ═══ FULLSCREEN KERESŐ POPUP ═══ */}
      {popOpen&&<div style={{position:"fixed",inset:0,zIndex:100,background:t.card,display:"flex",flexDirection:"column"}}>
        <div style={{display:"flex",alignItems:"center",gap:8,padding:"12px 16px",borderBottom:`1px solid ${t.bdr}`}}>
          <Search size={18} color={t.tx3}/>
          <input ref={searchRef} value={q} onChange={e=>setQ(e.target.value)} placeholder="Skills, hooks, rules, commands keresése..." style={{flex:1,border:"none",outline:"none",fontSize:16,color:t.tx,background:"transparent",fontFamily:"inherit"}}/>
          <button onClick={()=>setPopOpen(false)} style={{width:32,height:32,borderRadius:7,border:`1px solid ${t.bdr}`,background:t.mut,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2}}><X size={16}/></button>
        </div>
        <div style={{display:"flex",borderBottom:`1px solid ${t.bdrS}`,padding:"0 16px"}}>
          {[{k:"ai",l:"AI Ajánlott",I:Zap,n:preds.length},{k:"favs",l:"Kedvencek",I:Star,n:favs.length},{k:"all",l:"Összes",I:Grid}].map(x=>(
            <button key={x.k} onClick={()=>{setTab(x.k);setQ("")}} style={{padding:"8px 12px",border:"none",background:"none",fontSize:13,fontWeight:500,cursor:"pointer",color:tab===x.k?t.tx:t.tx3,borderBottom:tab===x.k?`2px solid ${t.tx}`:"2px solid transparent",display:"flex",alignItems:"center",gap:5,fontFamily:"inherit"}}><x.I size={13}/>{x.l}{x.n!=null&&<span style={{fontSize:10,fontWeight:600,padding:"0 5px",borderRadius:8,background:t.mut,color:t.tx2}}>{x.n}</span>}</button>))}
        </div>
        <div style={{flex:1,overflowY:"auto",padding:16,maxWidth:720,width:"100%",margin:"0 auto"}}>
          {q.trim()?<div><div style={{fontSize:11,fontWeight:600,color:t.tx3,textTransform:"uppercase",letterSpacing:".04em",marginBottom:8}}>Találatok ({filtered.length})</div>{filtered.length===0?<div style={{textAlign:"center",padding:40,color:t.tx3}}>Nincs találat</div>:<div style={{display:"grid",gridTemplateColumns:isMob?"1fr":"1fr 1fr",gap:4}}>{filtered.map(i=><MCard key={i.id} item={i} onSelect={doOpen} isFav={favs.includes(i.id)} onFav={togFav} t={t}/>)}</div>}</div>
          :tab==="ai"?<div><div style={{display:"flex",alignItems:"center",gap:6,fontSize:11,fontWeight:600,color:t.tx3,textTransform:"uppercase",letterSpacing:".04em",marginBottom:8}}><span>Neked ajánljuk</span><span style={{fontFamily:"monospace",fontSize:9,fontWeight:600,color:"#6366f1",background:"#6366f110",padding:"2px 5px",borderRadius:3}}>TF.js</span></div>
            <div style={{display:"grid",gridTemplateColumns:isMob?"1fr":"1fr 1fr",gap:4}}>{preds.map((i,idx)=><MCard key={i.id} item={i} onSelect={doOpen} isFav={favs.includes(i.id)} onFav={togFav} rank={idx+1} conf={i.conf} t={t}/>)}</div>
            <div style={{display:"flex",gap:6,marginTop:12,paddingTop:10,borderTop:`1px solid ${t.bdrS}`}}>{[{v:ai.stats().total,l:"Interakció"},{v:ai.stats().unique,l:"Elem típus"},{v:(preds[0]?.conf*100||0).toFixed(0)+"%",l:"Konfidencia"}].map((s,i)=>(<div key={i} style={{flex:1,textAlign:"center",padding:8,borderRadius:8,background:t.mut}}><div style={{fontSize:18,fontWeight:700,fontFamily:"monospace",color:t.tx}}>{s.v}</div><div style={{fontSize:10,color:t.tx3,marginTop:2}}>{s.l}</div></div>))}</div></div>
          :tab==="favs"?<div><div style={{fontSize:11,fontWeight:600,color:t.tx3,textTransform:"uppercase",letterSpacing:".04em",marginBottom:8}}>Kedvenceid ({favs.length}/12)</div>{favItems.length===0?<div style={{textAlign:"center",padding:40,color:t.tx3}}>Nincs kedvenc</div>:<div style={{display:"grid",gridTemplateColumns:isMob?"1fr":"1fr 1fr",gap:4}}>{favItems.map(i=><MCard key={i.id} item={i} onSelect={doOpen} isFav onFav={togFav} t={t}/>)}</div>}</div>
          :<div>{CATS.map(c=>(<div key={c.id} style={{marginBottom:14}}><div style={{display:"flex",alignItems:"center",gap:6,marginBottom:6}}><div style={{width:7,height:7,borderRadius:"50%",background:c.color}}/><span style={{fontSize:13,fontWeight:600,color:t.tx2}}>{c.name}</span><span style={{fontSize:10,color:t.tx3,background:t.mut,padding:"1px 5px",borderRadius:6}}>{c.items.length}</span></div><div style={{display:"grid",gridTemplateColumns:isMob?"1fr":"1fr 1fr",gap:4}}>{c.items.map(i=><MCard key={i.id} item={{...i,catName:c.name,catColor:c.color}} onSelect={doOpen} isFav={favs.includes(i.id)} onFav={togFav} t={t}/>)}</div></div>))}</div>}
        </div>
      </div>}

      {/* ═══ GYORS MŰVELET POPUP ═══ */}
      {quickAddOpen&&<div style={{position:"fixed",inset:0,zIndex:110,background:t.card,display:"flex",flexDirection:"column"}}>
        <div style={{display:"flex",alignItems:"center",gap:8,padding:"12px 16px",borderBottom:`1px solid ${t.bdr}`}}>
          <Plus size={18} color="#6366f1"/>
          <input value={addQ} onChange={e=>setAddQ(e.target.value)} placeholder="Gyors művelet keresés..." autoFocus style={{flex:1,border:"none",outline:"none",fontSize:16,color:t.tx,background:"transparent",fontFamily:"inherit"}}/>
          <button onClick={()=>{setQuickAddOpen(false);setAddQ("")}} style={{width:32,height:32,borderRadius:7,border:`1px solid ${t.bdr}`,background:t.mut,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2}}><X size={16}/></button>
        </div>
        <div style={{flex:1,overflowY:"auto",padding:16,maxWidth:720,width:"100%",margin:"0 auto"}}>
          <div style={{fontSize:11,fontWeight:600,color:t.tx3,textTransform:"uppercase",letterSpacing:".04em",marginBottom:10}}>Műveletek ({filteredAdds.length})</div>
          <div style={{display:"grid",gridTemplateColumns:isMob?"1fr":"1fr 1fr",gap:4}}>
            {filteredAdds.map(a=>{const AI=a.Ic;return(
              <button key={a.id} onClick={()=>{sToast(a.name);setQuickAddOpen(false);setAddQ("")}}
                style={{display:"flex",alignItems:"center",gap:10,padding:"10px 12px",borderRadius:8,border:"1px solid transparent",background:"transparent",cursor:"pointer",fontSize:13,color:t.tx,textAlign:"left",fontFamily:"inherit",transition:".12s"}}
                onMouseEnter={e=>{e.currentTarget.style.background=t.mut;e.currentTarget.style.borderColor=t.bdr}}onMouseLeave={e=>{e.currentTarget.style.background="transparent";e.currentTarget.style.borderColor="transparent"}}>
                <div style={{width:34,height:34,borderRadius:8,display:"flex",alignItems:"center",justifyContent:"center",background:`${a.catColor}12`,color:a.catColor}}><AI size={15}/></div>
                <div><div style={{fontWeight:500}}>{a.name}</div><div style={{fontSize:11,color:t.tx3}}>{a.parentName} · {a.catName}</div></div>
              </button>)})}
          </div>
        </div>
      </div>}

      {/* ═══ AI CHAT PANEL ═══ */}
      {chatOpen&&<>{isMob&&<div onClick={()=>setChatOpen(false)} style={{position:"fixed",inset:0,background:"rgba(0,0,0,.4)",zIndex:60}}/>}
        <div style={{position:"fixed",zIndex:70,background:t.card,display:"flex",flexDirection:"column",border:`1px solid ${t.bdr}`,boxShadow:"0 20px 40px -8px rgba(0,0,0,.15)",...(isMob?{inset:0,borderRadius:0,border:"none"}:{bottom:14,right:14,width:360,height:500,borderRadius:10})}}>
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"10px 12px",borderBottom:`1px solid ${t.bdr}`}}>
            <div style={{display:"flex",alignItems:"center",gap:8,color:t.tx}}><MessageSquare size={16}/><div><div style={{fontSize:13,fontWeight:600}}>Claude Code Asszisztens</div><div style={{fontSize:10,color:t.tx3,fontFamily:"monospace"}}>v2.3 — {ai.stats().total} interakció</div></div></div>
            <button onClick={()=>setChatOpen(false)} style={{background:"none",border:"none",color:t.tx3,cursor:"pointer",display:"flex",padding:4}}><X size={15}/></button>
          </div>
          <div style={{flex:1,overflowY:"auto",padding:10,display:"flex",flexDirection:"column",gap:8}}>
            {msgs.map((m,i)=>(<div key={i} style={{display:"flex",gap:6,...(m.r==="user"?{justifyContent:"flex-end"}:{alignItems:"flex-start"})}}>
              {m.r==="ai"&&<div style={{width:24,height:24,borderRadius:5,background:t.mut,display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,flexShrink:0,border:`1px solid ${t.bdr}`}}><MessageSquare size={12}/></div>}
              <div style={{maxWidth:"85%",padding:"8px 10px",borderRadius:8,fontSize:13,lineHeight:1.5,...(m.r==="user"?{background:t.pri,color:t.priFg,borderBottomRightRadius:2}:{background:t.mut,color:t.tx,borderBottomLeftRadius:2})}}>
                <p style={{margin:0}}>{m.t}</p>
                {m.res?.length>0&&<div style={{display:"flex",flexDirection:"column",gap:3,marginTop:6}}>{m.res.map(r=>{const RI=r.Ic;return(<button key={r.id} onClick={()=>{doOpen(r);setChatOpen(false)}} style={{display:"flex",alignItems:"center",gap:7,padding:"6px 8px",borderRadius:5,background:t.card,border:`1px solid ${t.bdr}`,cursor:"pointer",fontSize:12,color:t.tx,fontFamily:"inherit",textAlign:"left"}}><RI size={14} style={{color:r.catColor}}/><div style={{flex:1,display:"flex",flexDirection:"column"}}><span style={{fontWeight:500}}>{r.name}</span><span style={{fontSize:10,color:t.tx3}}>{r.catName}</span></div><ArrowUpRight size={12}/></button>)})}</div>}
              </div>
            </div>))}
            {typing&&<div style={{display:"flex",gap:6,alignItems:"flex-start"}}><div style={{width:24,height:24,borderRadius:5,background:t.mut,display:"flex",alignItems:"center",justifyContent:"center",color:t.tx2,border:`1px solid ${t.bdr}`}}><MessageSquare size={12}/></div><div style={{background:t.mut,padding:"10px 14px",borderRadius:8,display:"flex",gap:5}}><span className="td"/><span className="td"/><span className="td"/></div></div>}
            <div ref={chatEnd}/>
          </div>
          <div style={{display:"flex",alignItems:"center",gap:6,padding:"8px 10px",borderTop:`1px solid ${t.bdr}`}}>
            <input ref={chatIRef} value={chatIn} onChange={e=>setChatIn(e.target.value)} onKeyDown={e=>e.key==="Enter"&&sendChat()} placeholder="Pl: crud-generator, hooks, guardrails..." style={{flex:1,border:`1px solid ${t.bdr}`,borderRadius:7,padding:"7px 10px",fontSize:13,color:t.tx,background:t.bg,outline:"none",fontFamily:"inherit"}}/>
            <button onClick={sendChat} disabled={!chatIn.trim()} style={{width:32,height:32,borderRadius:7,background:t.pri,color:t.priFg,border:"none",cursor:chatIn.trim()?"pointer":"not-allowed",display:"flex",alignItems:"center",justifyContent:"center",opacity:chatIn.trim()?1:.25}}><Send size={15}/></button>
          </div>
        </div>
      </>}

      {/* ═══ MOBIL ALSÓ NAVIGÁCIÓ ═══ */}
      {isMob&&<div style={{position:"fixed",bottom:0,left:0,right:0,zIndex:30,background:t.card,borderTop:`1px solid ${t.bdr}`,display:"flex",alignItems:"stretch",height:56}}>
        {[{Ic:Home,l:"Főoldal",action:()=>setSel(null),active:!sel&&!popOpen&&!chatOpen},
          {Ic:Grid,l:"Struktúra",action:()=>setPopOpen(true),active:popOpen},
          {Ic:Plus,l:"",action:()=>setQuickAddOpen(true),active:quickAddOpen,special:true},
          {Ic:MessageSquare,l:"Chat",action:()=>setChatOpen(true),active:chatOpen},
          {Ic:Bell,l:"Értesítés",action:()=>sToast("Értesítések"),active:false},
        ].map((b,i)=>(
          <button key={i} onClick={b.action} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",gap:2,border:"none",background:"transparent",cursor:"pointer",color:b.active?"#6366f1":t.tx3,fontFamily:"inherit",fontSize:10}}>
            {b.special?<div style={{width:40,height:40,borderRadius:12,background:"linear-gradient(135deg,#6366f1,#818cf8)",color:"#fff",display:"flex",alignItems:"center",justifyContent:"center",marginTop:-14,boxShadow:"0 2px 8px #6366f144"}}><b.Ic size={20}/></div>
            :<><b.Ic size={20}/><span>{b.l}</span></>}
          </button>
        ))}
      </div>}

      {/* Toast értesítés */}
      {toast&&<div style={{position:"fixed",bottom:isMob?72:16,left:"50%",transform:"translateX(-50%)",background:t.pri,color:t.priFg,padding:"7px 14px",borderRadius:7,fontSize:13,fontWeight:500,boxShadow:"0 8px 20px rgba(0,0,0,.15)",zIndex:9999}}>{toast}</div>}

      {/* Globális stílusok */}
      <style>{`*{box-sizing:border-box;margin:0;padding:0}::-webkit-scrollbar{width:4px}::-webkit-scrollbar-thumb{background:${t.bdr};border-radius:2px}.td{display:inline-block;width:5px;height:5px;border-radius:50%;background:${t.tx3};animation:b 1.2s ease infinite}.td:nth-child(2){animation-delay:.15s}.td:nth-child(3){animation-delay:.3s}@keyframes b{0%,60%,100%{transform:translateY(0)}30%{transform:translateY(-3px)}}`}</style>
    </div>
  );
}
