# Kurzspiel-Längen

Eine kleine Web-App fürs Handy: Für jeden Kurzspiel-Schläger im Bag (z. B. LW, SW, GW, PW, 9er) stehen die Längen bei einer Ausholbewegung bis **7:30**, **9:00** und **11:00 Uhr** in einer Tabelle, gut ablesbar auf dem Platz.

## Benutzen

- Oben rechts auf **Bearbeiten** tippen, Längen in Metern eintragen (Komma geht auch, z. B. `25,5`), dann **Fertig**.
- Schläger hinzufügen, umbenennen, verschieben (▲ ▼) oder löschen (✕).
- Die Daten bleiben nur auf deinem Gerät gespeichert. Unter **Bearbeiten → Sichern & Wiederherstellen** kannst du eine Sicherungsdatei speichern und wieder laden.
- Auf dem iPhone in Safari: Teilen → **Zum Home-Bildschirm**. Dann startet die App wie eine normale App und funktioniert auch ohne Netz.

## Online stellen (einmalig)

Im Repository auf GitHub: **Settings → Pages → Build and deployment → Source: „Deploy from a branch“**, Branch **main**, Ordner **/ (root)**, **Save**. Nach ein bis zwei Minuten ist die App unter
`https://kingzulu.github.io/golf-kurzspiel-laengen/` erreichbar.

## Technik

Reines HTML, CSS und JavaScript ohne Build-Schritt und ohne Server. Speicherung im `localStorage` des Browsers, Offline-Unterstützung über einen Service Worker.
