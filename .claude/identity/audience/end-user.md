# Audience: End-User (alkalmazás-felhasználó)

> **Template** – fejlesztő tölti ki / finomítja.

## Profil
- **Szerep:** A termék napi használója (pl. ügyfélszolgálatos, marketinges, irodai dolgozó)
- **Korosztály:** [pl. "20-65"]
- **Technikai jártasság:** [pl. "Alacsony - közepes; nem fejlesztő"]
- **Pain point:** [pl. "Bonyolult UI, sok kattintás, kevés Visszajelzés"]

## Mit értékel
- Egyértelmű, magyar nyelvű UI
- Gyors visszajelzés (loading state, success message, error explanation)
- Keyboard shortcut (gyakori akciókhoz)
- Undo (megfordítható döntések)
- "Hogyan csináljam?" inline help

## Mit utál
- Angol terminológia magyar UI-ban (pl. "Submit" gomb)
- Technikai hibaüzenetek ("500 Internal Server Error")
- Nem világos hogy mit várunk tőle a következő lépésnél
- Modal pop-up amit nem lehet egyértelműen bezárni
- Adatvesztés mentés nélküli oldalváltáskor

## Hogyan kommunikálunk vele
- **Hangnem:** Tegezős, barátságos, türelmes
- **Hossz:** Mondatonként max 12-15 szó
- **Format:** Plain language, példák, képek/icon-ok ahol segít
- **Hibaüzenet:** Mi történt + Mit tehet + Hova fordulhat (3 mondat)
- **Magyar terminológia:** Mentés (nem Save), Bejelentkezés (nem Login), Beállítások (nem Settings)

## Példa: jó vs rossz hibaüzenet

❌ "Error: 500 Internal Server Error. Request ID: a8f3c2"
✅ "Most nem tudtuk elmenteni a változtatásaidat. Próbáld újra egy perc múlva. Ha továbbra is gond van, írj nekünk: support@example.com (hibaazonosító: a8f3c2)."

---

**Mikor olvassa a Claude:**
- UI string, label, hibaüzenet írás
- In-app help, onboarding tooltip
- Email értesítés (transaction email, password reset)
- Knowledge base / FAQ cikk
