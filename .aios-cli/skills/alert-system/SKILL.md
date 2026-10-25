---
name: alert-system
description: >
  Felhasznaloi alertek az admin feluleten: info, warning, error, success
  banner-ek, toast-ok, system-wide announcements, scheduled alerts.
  Triggerek: "alert", "figyelmeztetes", "banner", "toast", "announcement",
  "rendszer uzenet".
  NE hasznald: monitoring alert (-> monitoring-setup), notification (-> notification-system).
model: claude-haiku-4-5-20251001
---

# Alert System

## Felelossegek
- Toast komponens (shadcn/ui toast)
- System-wide banner (pl. "Tervezett karbantartas holnap 22:00-kor")
- Alert CRUD admin (/admin/settings/alerts)
- Utemezett alertek (megjelenes idoablak)
- Dismissable / nem dismissable
- Alert priority (info, warning, error, success)
- Celzas: mindenki / role / egyedi felhasznalo
