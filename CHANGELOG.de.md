## Änderungen (Changelog)

### v0.2.3 (2018-02-07)
Vollständige Portierung des Backends von Rails 4.2 auf 5.1.

### v0.2.2 (2015-05-24)
Fehlerbehebungen:

* Login-Routen können nun auch durch E-Mail-Adressen genutzt werden, die aus komplexeren Symbolen als reinen Wortsymbolen bestehen (also z.B. auch Bindestriche).
* Das Vorkompilieren von Assets enthält nun auch das Stylesheet für die Generierung von PDF-Dokumenten.

### v0.2.1 (18.05.2015)
* Es wurden Favicons verschiedenster Größen hinzugefügt.
* Automatische Bots dürfen die Applikation nun nicht mehr durchsuchen.

### v0.2.0 (18.05.2015)
Neue Funktionen:

* Messdiener können nun anhand eines eindeutigen Kurznamens identifiziert werden.
* Alle Nachrichtenversandzentralen wurden in externe, asynchrone Jobs ausgelagert.
* Datensätze im Administrationsinterface können nun durchsucht und sortiert werden.
* Die komplette Benutzeroberfläche wurde für mobile Endgeräte angepasst.
* Diese lokalisierte Versionsinformationsseite wurde eingerichtet, damit der Benutzer alle Änderungen verfolgen kann.
* Login-Pfade innerhalb der E-Mails sind nun deutlich intelligenter.
* Globale Einstellungen werden nun durch die Applikation selbst auf Dateibasis verwaltet.
* Ein Setup-Assistent führt neue Administratoren nun durch den Vorgang der Vorbereitung für die Benutzer.
* Nachrichten können nun an ausgewählte Gruppen gesendet werden.
* Die Oberfläche ist deutlich reicher an Hilfs- und Bestätigungsnachrichten.
* Administratoren können sich als Messdiener ausgeben.
* Die Administrationsoberfläche ist deutlich freundlicher.
* Es wird nun separat gespeichert, welcher Messdiener sich bereits für welchen Plan eingetragen hat. Dies erlaubt bspw., den Messdienern mitzuteilen, an welchen Plänen sie noch nicht teilgenommen haben; aber auch dem Administrator, einzusehen, wie viele und welche Messdiener in einem Plan noch fehlen.
* Eine neue Benutzerrolle, Root, ein Super-Duper-Administrator, wurde eingerichtet.
* Die Applikation ist nun in der Lage, mit der aktuellen Zeitzone umzugehen.
* Alle Pläne können als PDF exportiert und automagisch per Nachricht versandt werden.
* Tapeinos hat sein eigenes Icon.

Fehlerbehebungen:

* Auslösen der Login-Funktion innerhalb einer administrativen Seite stellte ein falsches Layout dar.
* Die Navigationsleiste weiß nun genau, welcher Controller aktiv ist und kann somit die aktuelle Position im System richtig anzeigen.

### v0.1.0 (17.03.2015)
* Erste Veröffentlichung mit Basisfunktionalität.
