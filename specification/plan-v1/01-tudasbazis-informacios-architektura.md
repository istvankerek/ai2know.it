# 01 – Információs architektúra: az ai2know.it mint AI tudásbázis

## 1. Pozicionálás

**ai2know.it = a magyar AI tudásbázis**: eszközök, appok, promptok, skillek, agent-építőelemek,
fogalmak, videók, tananyagok és kedvezmények egy helyen, egy keresővel. Nem hírportál és nem
közösségi háló (az üres feed/fórum/csoport modulok nem térnek vissza).

## 2. Fő szekciók (felső szint)

| Szekció | Tartalom (típusok) | Régi URL(ek) – megmaradnak | Új kanonikus URL |
|---------|-------------------|---------------------------|------------------|
| **Eszközök** | AI appok és szolgáltatások (ChatGPT, Claude, Gemini, Midjourney…), böngésző-bővítmények | `/appok`, `/bovitmenyek`, `/aitools` | `/eszkozok`, `/eszkozok/{slug}` |
| **Agent eszköztár** | 7 pillér + prompt, skill, MCP, guardrail, eval könyvtár | aiagentek: `/eszkoztar`, `/promptok`, `/skillek`, `/mcp-k`, `/guardrailek`, `/evalok`, `/promptok-es-skillek/{code}`; régi ai2know: `/promptok` | `/eszkoztar`, `/eszkoztar/{pillér}`, `/promptok`, `/skillek`, `/mcp-k`, `/guardrailek`, `/evalok`, `/elem/{code}` |
| **Tanulás** | videók, segédanyagok (cheat sheet, PDF), interaktív magyarázók (LLM működése, Doodle AI), AI érettségi felmérés | `/videok`, `/segedanyagok`, aiagentek `/llm-mukodes`, `/doodle-ai`; `/ai-erettsegi-szint-felmeres` | `/videok`, `/segedanyagok`, `/interaktiv/{slug}`, `/felmeres` |
| **Szótár** | ~300 szócikk | `/szotar`, aiagentek `/szotar/{slug}` | `/szotar`, `/szotar/{slug}` |
| **Linkek** | kurált külső források (kutatás, oktatás, közösségek) | `/linkek` | `/linkek` |
| **Kérdések** | kérdés-válasz tudásbázis (publikus, moderált) | `/ai-kerdesek-es-valaszok` | `/kerdesek`, `/kerdesek/{slug}` |
| **Kedvezmények** | partner kuponok, akciók | `/kedvezmenyek` | `/kedvezmenyek` |
| **Közösség** | Facebook/Telegram/Discord/WhatsApp/Viber, Vasárnap esti promptolás, események, partnerek | `/facebook-groups`, `/telegram`, … `/esemenyek`, `/partnereink` | `/kozosseg` + a régi aloldalak |
| **Eszközeim** (belépve) | kedvencek, gyűjtemények, mentett QR kódok, kéréseim | `/kedvencek`, `/qrcode` | `/kedvencek`, `/qr-generator` |

Szabály: ha egy régi URL más kanonikus címre kerül (pl. `/appok` → `/eszkozok`), a régi cím 301-et
ad – egy ugrás, követéssel (v0/03 mechanizmus). A régi menü minden pontja működik.

## 3. Navigáció

- **Desktop:** felső sáv – logó, globális kereső (mindig látható), Eszközök, Agent eszköztár,
  Tanulás, Szótár, „Még" (Linkek, Kérdések, Kedvezmények, Közösség), belépés/avatar.
- **Mobil:** felső sáv csak logó + kereső ikon + avatar; **alsó tab sáv** 5 ponttal: Kezdőlap,
  Keresés, Eszközök, Eszköztár, Menü (teljes képernyős lap a többi szekcióval).
- Kenyérmorzsa minden részletoldalon; „kapcsolódó elemek" blokk (azonos címke/kategória).

## 4. Kezdőlap

1. Nagy kereső („Mit szeretnél megtudni az AI-ról?") + népszerű keresések chipjei.
2. Szekció-csempék darabszámmal (pl. „Skillek – 339").
3. Friss és népszerű elemek (megtekintés/másolás statisztikából).
4. Kezdőknek útvonal: ChatGPT első lépések → promptolás alapjai → AI felmérés.
5. Kedvezmények kiemelés, közösségi csatlakozás, partnerek.

## 5. Globális kereső

- Egy mező minden típusra; találatok típus szerint csoportosítva, típus-chippel szűkíthető.
- `Cmd/Ctrl+K` paletta desktopon, teljes képernyős kereső mobilon (fókusz, előzmények, javaslatok).
- Találati oldal: `/kereses?q=…&tipus=…` – megosztható, indexelés tiltva (`noindex`).
- „Nincs találat" esetén: elírás-javaslat + „Kérj új elemet" gomb (a meglévő kérés-folyamat).

## 6. URL-szabályok

- Magyar, kisbetűs, ékezet nélküli slugok; elemkód (`PRM-MKT-CNT-001`) stabil, a `/elem/{code}`
  mindig a kanonikus részletoldalra visz (a könyv kódjai miatt).
- Szűrők query paraméterben: `?q=&kategoria=&cimke=&szint=&rendezes=&oldal=`; a facetta-oldalak
  közül csak a kurált kategória-oldalak indexelhetők (`/eszkozok/kategoria/kepgeneralas`).
- Nincs nyelvi előtag (D-V0-05).
