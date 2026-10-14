# Kurzspiel-Längen

Eine kleine App fürs Handy: Für jeden Kurzspiel-Schläger im Bag (z. B. LW, SW, GW, PW, 9er) stehen die Längen bei einer Ausholbewegung bis **7:30**, **9:00** und **11:00 Uhr** in einer Tabelle, gut ablesbar auf dem Platz.

Es gibt zwei Varianten mit derselben Funktion:

- **iPhone-App** im Ordner `iPhone-App/Kurzspiel.swiftpm` (Swift, SwiftUI, ab iOS 16)
- **Web-App** im Hauptordner (läuft im Browser, auch auf Android)

## iPhone-App aufs iPhone bringen

Du brauchst einen Mac und dein iPhone mit Kabel.

1. Auf dem Mac **Xcode** aus dem App Store installieren (kostenlos) und einmal starten.
2. Dieses Repository herunterladen: auf GitHub **Code → Download ZIP**, ZIP entpacken.
3. Den Ordner `iPhone-App/Kurzspiel.swiftpm` doppelklicken. Er öffnet sich in Xcode.
4. In Xcode: **Xcode → Settings → Accounts** und mit deiner Apple-ID anmelden.
5. Links oben auf **Kurzspiel** klicken, unter **Signing & Capabilities** bei „Team“ deine Apple-ID wählen.
6. iPhone per Kabel anschließen, entsperren und „Vertrauen“ tippen. Oben in Xcode dein iPhone als Ziel auswählen.
7. Auf dem iPhone: **Einstellungen → Datenschutz & Sicherheit → Entwicklermodus** einschalten (iPhone startet neu).
8. In Xcode auf den **Play-Knopf ▶︎** klicken. Die App wird installiert.
9. Beim ersten Start auf dem iPhone: **Einstellungen → Allgemein → VPN & Geräteverwaltung**, deine Apple-ID antippen und „Vertrauen“.

Mit einer normalen Apple-ID läuft die App 7 Tage, danach einfach Schritt 8 wiederholen. Deine eingetragenen Längen bleiben dabei erhalten. Mit dem Apple-Entwicklerprogramm (99 € pro Jahr) hält sie ein Jahr und kann über TestFlight oder den App Store verteilt werden.

Alternativ geht es auf einem **iPad** oder Mac mit der kostenlosen App **Swift Playgrounds**: den Ordner `Kurzspiel.swiftpm` dort öffnen und auf ▶︎ tippen.

## Web-App benutzen

- Oben rechts auf **Bearbeiten** tippen, Längen in Metern eintragen (Komma geht auch, z. B. `25,5`), dann **Fertig**.
- Schläger hinzufügen, umbenennen, verschieben (▲ ▼) oder löschen (✕).
- Die Daten bleiben nur auf deinem Gerät gespeichert. Unter **Bearbeiten → Sichern & Wiederherstellen** kannst du eine Sicherungsdatei speichern und wieder laden.
- Auf dem iPhone in Safari: Teilen → **Zum Home-Bildschirm**. Dann startet die App wie eine normale App und funktioniert auch ohne Netz.

## Web-App online stellen (einmalig)

Im Repository auf GitHub: **Settings → Pages → Build and deployment → Source: „Deploy from a branch“**, Branch **main**, Ordner **/ (root)**, **Save**. Nach ein bis zwei Minuten ist die App unter
`https://kingzulu.github.io/golf-kurzspiel-laengen/` erreichbar.

## Technik

iPhone-App: SwiftUI-App als Swift-Playgrounds-Paket, Daten in den `UserDefaults` (sind im iCloud-Backup des iPhones enthalten).

Web-App: reines HTML, CSS und JavaScript ohne Build-Schritt und ohne Server. Speicherung im `localStorage` des Browsers, Offline-Unterstützung über einen Service Worker.
