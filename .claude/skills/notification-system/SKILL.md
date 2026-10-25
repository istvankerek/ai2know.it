---
name: notification-system
description: >
  Tobbcsatornas ertesites: Email (Mailgun), In-App (WebSocket),
  Telegram, Slack. Routing, template-ek, preferenciak, quiet hours,
  deduplikacio, digest.
  Triggerek: "notification", "ertesites", "push", "websocket",
  "real-time", "alert kuldes".
  NE hasznald: monitoring alertek (-> monitoring-setup), email kuldes (-> email-mailgun).
model: claude-sonnet-4-6
---

# Notification System

## Felelossegek
- Tobbcsatornas routing (Email, In-App, Telegram, Slack)
- WebSocket real-time ertesitesek
- Template rendszer (MJML email, in-app card)
- Felhasznaloi preferenciak (csatorna, quiet hours)
- Deduplikacio (ne kapjon ketszer ugyanazt)
- Digest mod (napi/heti osszefoglalo)
- NATS queue alapu aszinkron kuldes
