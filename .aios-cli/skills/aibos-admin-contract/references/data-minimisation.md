# Adatminimalizálás — aibos nem tárol ügyfél shop-adatot

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `specification/plan-v25/`, `specification/plan-v3/00_baseline_es_dontesek.md`

---

## Az alapelv

> **aibos NEM tárol ügyféladat-példányokat.**  
> A partner forrásrendszer állapotgépe az autoritatív.  
> Az aibos konzol csak kivételkezelési műveleteket végez.

---

## Mit jelent ez a gyakorlatban?

| Adat | Hol él autoritatívan | aibos szerepe |
|------|----------------------|---------------|
| Kurzus adatok (leírás, tartalom) | `aibootcamp.hu` adatbázis | Olvasás (API hívás), esetleg szerkesztési trigger |
| Rendelési adatok | `aibootcamp.hu` rendelési tábla | Nem tárolja, csak hivatkozás `order_id`-vel |
| Ügyfél előfizetési státusz | Partner `subscription` tábla | Állapotot a partnertől kéri le, nem cache-eli |
| Fizetési adatok | `pay.aibos.space` | aibos nem lát bankkártyaadatot |
| Kurzus elvégzési állapot | Partner LMS | Lekérdezés, nem másolás |

---

## Mi kerülhet az aibos adatbázisba?

Megengedett:
- Audit log bejegyzések (operátor műveletek, nem ügyféladat)
- Operátori munkamenet adatok
- Kivétel-kezelési jegyek hivatkozása (`entity_id`, `entity_type`, reason)
- Partner rendszer metaadatok (URL, version, health státusz)

Tilos:
- Ügyfél személyes adatok (név, email, telefon) partner rendszerből átmásolva
- Tranzakciós adatok
- Tartalom (kurzusleírások, videók)
- Bármilyen adat, amelynek a partner az autoritatív forrása

---

## Állapotgép és kivételek

A partner forrásrendszer állapotgépe meghatározza, mi lehetséges. Az aibos
konzol **csak akkor avatkozik be**, ha:

1. A normál workflow elakad (pl. fizetési hiba után manuális jóváhagyás szükséges)
2. Operátori felülbírálás szükséges (pl. ügyfélszolgálati kérés alapján)
3. Bulk admin művelet, amely a partner rendszer kapacitásán túl van

Minden ilyen beavatkozás:
- Actor assertion-nel hitelesített
- Kötelező `reason` mezővel ellátott
- Audit naplóba kerül

---

## Miért fontos ez az OpenAPI tervezésnél?

Az admin API endpointok tervezésekor:

### Rossz minta (ne így):
```
POST /api/admin/v1/courses
Body: { title, description, content, author, ... }  ← teljes kurzus adat
```

### Helyes minta:
```
POST /api/admin/v1/courses/{id}/override-status
Body: { status: "published", reason: "Manuális jóváhagyás #TICKET-123" }
```

Az aibos csak a kivétel-kezelési szándékot (és indokát) közli — a tényleges
tartalom és állapot a partnerré marad.

---

## GDPR vonatkozások

Mivel az aibos nem tárol ügyfél személyes adatot, a GDPR törlési jog ("right
to be forgotten") a partnernél érvényesítendő. Az aibos audit logban csak az
operátor azonosítója és a `entity_id` hivatkozás él (pl. kurzus UUID) — maga
az ügyfél nincs névvel az audit logban.

Ha GDPR törlési igény érkezik a partner ügyfelétől:
1. A partner törli saját adatbázisából
2. Az aibos audit logban a `entity_id` marad (de üres hivatkozás lesz)
3. Az aibos nem módosítja a naplót (append-only garancia)

Ez elfogadható: a napló az operátori műveletet dokumentálja, nem az ügyfél
személyes adatait.
