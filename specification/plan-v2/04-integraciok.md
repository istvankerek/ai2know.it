# 04 – Integrációk

## 1. skillpass.id

| Cél | Megoldás | Állapot a skillpass-on |
|-----|----------|------------------------|
| Belépés, profil, nyelv | OIDC BFF (v0 F2/1), `locale` trait | megvan |
| **Elvégzés a profilon** | M2M `POST /api/v1/profile/trainings` – `external_id = ai2know:{curve_code}`, `title`, `provider = "ai2know.it"`, `entity_ref = ai2know:curve:{code}`, `status` (`enrolled` → `in_progress` → `completed`), `completed_at`, `certificate_url` = ai2know igazolás oldal | **megvan** (`trainings:write`) |
| **Visszajelzés a skillpass-on** | az `entity_ref` miatt a felhasználó „ellenőrzött" értékelést írhat a skillpass-on; az ai2know a saját visszajelzéseit is mutatja | **megvan** |
| **„Készítette" a készítő profilján** | passport-api `community_contribution` rekord (plan-v28) M2M push-sal: curve címe, link, elvégzők száma, átlagértékelés | **új scope kell** (Q-V2-01) |
| Összesítő (hányan végezték, visszajelzések) a skillpass curve-kártyán | a skillpass az ai2know publikus összesítő végpontjából olvas (`GET /api/v1/public/curves/{code}/summary`, cache-elhető), vagy az ai2know napi push-sal frissíti a contribution rekordot | egyeztetés (Q-V2-01) |
| Munkatér shell | `status_line` „2 folyamatban lévő curve", `progress` | megvan (`shell:read`, manifest) |
| Hozzáférés jogosultságból | `entitlements:read` a felhasználó jogosultságaihoz (fizetős képzés → curve) | megvan |
| Haladás szinkron (opcionális) | partner dokumentumtár (`documents:write`) nem kell – a haladás az ai2know-ban él | – |

Adatvédelem: a skillpass felé csak a felhasználó saját elvégzése megy (a felhasználó `sub`-jával);
a „Készítette" összesítő személyes adat nélkül (darabszám, átlag).

## 2. superskiller.com (összehangolás, D-V2-07)

**Elv:** mindkét rendszer a saját objektumainak gazdája; nincs adatmásolás, csak hivatkozás és
pillanatkép-metaadat. Közös identitás: skillpass.id (SSO), közös admin: aibos.space.

| Irány | Mit | Hogyan |
|-------|-----|--------|
| ai2know → superskiller | tudáselemek a superskiller leckékben, kurzusokban | oEmbed / beágyazott kártya, partner API (M2M + felhasználói token), a láthatóság az ai2know szabályai szerint |
| superskiller → ai2know | e-learning (kurzus, lecke), csoport, poszt, tartalom mint **curve lépés** (`kind = external`, `provider = superskiller`) | superskiller partner API: `GET /v1/partner/objects/{type}/{id}` (cím, típus, leírás, kép, hozzáférési állapot a felhasználóra, mélylink) – **a superskiller oldalon új contract** (Q-V2-02) |
| superskiller → ai2know | lépés elvégzése (lecke kész, kvíz megvan) | aláírt webhook / outbox esemény `superskiller.lesson.completed` → `step_progress.signal = external_webhook` |
| közös | curve a superskiller csoportban kiajánlva | a superskiller poszt egy ai2know curve-öt ágyaz be |

**Fogalmi összehangolás (kötelező):**

| Fogalom | ai2know.it | superskiller.com | Döntés |
|---------|-----------|------------------|--------|
| „skill" | AI agent skill (SKILL.md) | emberi kompetencia (skill passport) | UI-ban: „AI skill" vs. „Kompetencia"; a curve megjelölhet cél-kompetenciákat (superskiller kódokkal) |
| „út" / „curve" | learning curve (`/lc`) | `/utak` tanulási utak | az ai2know „Learning curve", a superskiller „Út" – a superskiller út is behozható lépésként |
| tudástár | `ai2know.it` | `/tudastar` (üres) | a superskiller tudástár az ai2know tartalmát mutatja (beágyazás / API) |

Közös tervezés: egy közös integrációs contract mindkét repóban (`contracts/partner/ai2know-superskiller.yaml`),
a superskiller saját plan-jában ütemezve.

## 3. aibos.space

- Admin konzol az ai2know admin contracton át (v0 F5 minta): elemek (típus-specifikus űrlapok),
  láthatóság és nyilvános minta-arány, curve moderáció (nyilvános curve-ök, visszajelzések),
  `curve_author` képesség kiosztása, kérések, link-ellenőrzés, riportok.
- Események/workshopok: ha az esemény az aibos-ban él, a curve `origin_ref`-je az esemény;
  a résztvevőlista alapján **kohorsz meghívó** küldhető (aibos notify) – Q-V2-03.
- Az aibos többé **nem tárolja** a prompt könyvtárat: a meglévő 461 elem, a ~300 szócikk és a
  statisztikák/értékelések/kommentek átköltöznek az ai2know-ba (F1), az aibos-public megfelelő
  végpontjai az ai2know-ra mutatnak, majd kivezetésre kerülnek (az aibos repóban külön plan).

## 4. aiagentekagyakorlatban.hu és aibootcamp.hu

- Az aiagentek könyvoldal a könyvtár listáit és elemeit az ai2know API-ból / beágyazással mutatja,
  vagy 301-gyel az ai2know-ra irányít (nyomtatott URL-ek: `../plan-v1/03-tartalom-forrasok-atvetel.md` 2.1).
- A könyv olvasóinak saját curve: „A könyv eszköztára 7 lépésben" (a 7 pillér mentén), kohorsz =
  könyvaktivációs entitlement.
- aibootcamp képzések: tréning végén automatikusan létrejöhet a curve-vázlat (aibootcamp → ai2know
  M2M: résztvevők entitlementje + oktató szerkesztő jog).

## 5. Videóforrások

- oEmbed / Open Graph alapú felvétel: YouTube, Vimeo, Loom, Wistia, TED, Facebook/LinkedIn videó
  (ha oEmbed elérhető), saját tár (MinIO, később HLS).
- Lejátszás: „lite" beágyazás (kép + kattintásra betöltés), YouTube `youtube-nocookie` mód; a
  hozzájárulás nélküli harmadik féltől származó sütik elkerülése.
- Link-ellenőrzés hetente (törölt / privát videó → konzol feladat, a curve-ökben „nem elérhető" jelzés).
