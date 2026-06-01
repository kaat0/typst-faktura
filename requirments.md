# Requirements für Typst Invoice Package

## Funktionale Requirements

### 1. Dokumenttypen
- [ ] **REQ-DOC-001**: Das Package muss Rechnungen erstellen können
- [ ] **REQ-DOC-002**: Das Package muss Angebote erstellen können
- [ ] **REQ-DOC-003**: Das Package muss zwischen Rechnungen und Angeboten über einen Parameter unterscheiden können
- [ ] **REQ-DOC-004**: Optional: Gutschriften, Mahnungen, Lieferscheine

### 2. Mehrsprachigkeit & Regionalisierung
- [ ] **REQ-LOC-001**: Unterstützung für mindestens Deutsch (DE, AT, CH), Englisch (US, GB)
- [ ] **REQ-LOC-002**: Alle UI-Texte (Labels, Überschriften) müssen übersetzbar sein
- [ ] **REQ-LOC-003**: Datumsformate müssen regionalspezifisch sein (TT.MM.JJJJ vs. MM/DD/YYYY)
- [ ] **REQ-LOC-004**: Dezimal- und Tausendertrennzeichen müssen regionalspezifisch sein (, vs .)
- [ ] **REQ-LOC-005**: Währungssymbole und -positionen müssen regionalspezifisch sein (EUR, USD, CHF)
- [ ] **REQ-LOC-006**: Locale-Dateien müssen einfach erweiterbar sein (YAML/JSON/TOML)

### 3. Steuersätze
- [ ] **REQ-TAX-001**: Jede Position muss einen individuellen Steuersatz haben können
- [ ] **REQ-TAX-002**: Unterstützung für mindestens: 0%, 7%, 19% (DE), 10%/20% (AT), 2.5%/7.7% (CH)
- [ ] **REQ-TAX-003**: Mehrere verschiedene Steuersätze müssen in einem Dokument möglich sein
- [ ] **REQ-TAX-004**: Steuerbeträge müssen nach Steuersatz gruppiert angezeigt werden
- [ ] **REQ-TAX-005**: Reverse-Charge-Verfahren muss unterstützt werden (§13b UStG)
- [ ] **REQ-TAX-006**: Kleinunternehmerregelung muss unterstützt werden (§19 UStG - keine MwSt.)
- [ ] **REQ-TAX-007**: andere Steuerregelungen müssen als Hinweistext Konfigurierbar sein (z. B. Hebammen)

### 4. Adressfeld (DIN 5008/DIN 676)
- [ ] **REQ-ADDR-001**: Adressfeld muss DIN 5008 konform sein
- [ ] **REQ-ADDR-002**: Absenderzeile (Rücksendeangabe) bei 17.7mm von oben
- [ ] **REQ-ADDR-003**: Empfängeradresse bei 27mm von oben, 20mm von links
- [ ] **REQ-ADDR-004**: Sichtfenster für C6/C5/C4 Umschläge (85mm × 45mm)
- [ ] **REQ-ADDR-005**: Rücksendeangabe muss optional abschaltbar sein
- [ ] **REQ-ADDR-006**: Internationale Adressformate müssen unterstützt werden

### 5. Positionstabelle
- [ ] **REQ-POS-001**: Spalten: Position, Beschreibung, Menge, Einheit, Einzelpreis, MwSt., Gesamtpreis
- [ ] **REQ-POS-002**: Mehrzeilige Positionsbeschreibungen müssen möglich sein
- [ ] **REQ-POS-003**: Verschiedene Einheiten (Stk, Std, m², kg, Pauschale, etc.)
- [ ] **REQ-POS-004**: Optionale Spalten (z.B. MwSt. ausblenden bei Kleinunternehmer)
- [ ] **REQ-POS-005**: Automatische Seitenumbrüche bei vielen Positionen
- [ ] **REQ-POS-006**: Positionsnummerierung (1, 2, 3... oder 1.1, 1.2...)

### 6. Summenberechnung
- [ ] **REQ-SUM-001**: Nettosumme berechnen
- [ ] **REQ-SUM-002**: Steuern nach Steuersatz gruppiert berechnen und anzeigen
- [ ] **REQ-SUM-003**: Bruttosumme berechnen
- [ ] **REQ-SUM-004**: Skonto berechnen (wenn aktiviert)
- [ ] **REQ-SUM-005**: Gesamtrabatt auf Endsumme möglich
- [ ] **REQ-SUM-006**: Rundungsregeln konfigurierbar (kaufmännisch, auf 5 Cent, etc.)
- [ ] **REQ-SUM-007**: Vorauszahlungen/Anzahlungen abziehen können

### 7. Textbausteine
- [ ] **REQ-TEXT-001**: Begrüßung (förmlich, persönlich, neutral)
- [ ] **REQ-TEXT-002**: Einleitungstext (Danke für Anfrage, Bezug auf Gespräch, etc.)
- [ ] **REQ-TEXT-003**: Zahlungsbedingungen (sofort, 7/14/30 Tage)
- [ ] **REQ-TEXT-004**: Lieferbedingungen (Lieferzeit, Versandkosten, Abholung)
- [ ] **REQ-TEXT-005**: Rechtliche Hinweise (Kleinunternehmer, Reverse-Charge, Eigentumsvorbehalt)
- [ ] **REQ-TEXT-006**: Gültigkeitsangaben für Angebote (14/30 Tage)
- [ ] **REQ-TEXT-007**: Abschlussformeln (Grüße, Dank, Rückfragen)
- [ ] **REQ-TEXT-008**: Fußnoten/Hinweise
- [ ] **REQ-TEXT-009**: Textbausteine müssen über Parameter aktiviert/deaktiviert werden können
- [ ] **REQ-TEXT-010**: Platzhalter in Textbausteinen ({name}, {date}, {amount}, etc.)
- [ ] **REQ-TEXT-011**: Benutzerdefinierte Textbausteine ergänzbar

### 8. EPC QR-Code
- [ ] **REQ-QR-001**: EPC QR-Code für SEPA-Überweisungen generieren
- [ ] **REQ-QR-002**: QR-Code muss EPC069-12 Standard entsprechen
- [ ] **REQ-QR-003**: Enthält: Empfänger, IBAN, BIC, Betrag, Verwendungszweck
- [ ] **REQ-QR-004**: QR-Code Position konfigurierbar (Fußzeile, separate Seite)
- [ ] **REQ-QR-005**: QR-Code Größe anpassbar
- [ ] **REQ-QR-006**: QR-Code optional aktivierbar/deaktivierbar

### 9. Unterschrift
- [ ] **REQ-SIG-001**: PNG-Bilddatei als Unterschrift einbindbar
- [ ] **REQ-SIG-002**: Unterschrift optional (leer lassen möglich)
- [ ] **REQ-SIG-003**: Position der Unterschrift konfigurierbar
- [ ] **REQ-SIG-004**: Größe der Unterschrift anpassbar
- [ ] **REQ-SIG-005**: Text unter Unterschrift (Name, Funktion) anpassbar
- [ ] **REQ-SIG-006**: Unterschriftenfeld mit Linie für manuelle Unterschrift optional

### 10. Firmendaten
- [ ] **REQ-COMP-001**: Firmenname, Adresse (Straße, PLZ, Ort, Land)
- [ ] **REQ-COMP-002**: Kontaktdaten (Telefon, Fax, E-Mail, Website)
- [ ] **REQ-COMP-003**: Logo einbindbar (PNG, JPG, SVG)
- [ ] **REQ-COMP-004**: Logo-Position und -Größe konfigurierbar
- [ ] **REQ-COMP-005**: Steuernummer, USt-IdNr.
- [ ] **REQ-COMP-006**: Bankverbindung (Bank, IBAN, BIC)
- [ ] **REQ-COMP-007**: Handelsregisternummer, Geschäftsführer

### 11. Dokumentmetadaten
- [ ] **REQ-META-001**: Rechnungsnummer/Angebotsnummer
- [ ] **REQ-META-002**: Rechnungsdatum/Angebotsdatum
- [ ] **REQ-META-003**: Leistungsdatum/-zeitraum
- [ ] **REQ-META-004**: Kundennummer
- [ ] **REQ-META-005**: Bestellnummer/Auftragsnummer
- [ ] **REQ-META-006**: Lieferscheinnummer (Referenz)
- [ ] **REQ-META-007**: Bearbeiter/Ersteller
- [ ] **REQ-META-008**: Seitennummerierung (Seite X von Y)

## Nicht-funktionale Requirements

### 12. Usability
- [ ] **REQ-USE-001**: Einfache API für Standardfälle (< 20 Zeilen Code)
- [ ] **REQ-USE-002**: Sinnvolle Defaults für alle Parameter
- [ ] **REQ-USE-003**: Aussagekräftige Fehlermeldungen bei falschen Eingaben
- [ ] **REQ-USE-004**: Umfangreiche Dokumentation mit Beispielen
- [ ] **REQ-USE-005**: Beispiel-Templates für gängige Anwendungsfälle

### 13. Anpassbarkeit
- [ ] **REQ-CUST-001**: Schriftarten konfigurierbar
- [ ] **REQ-CUST-002**: Kopf- und Fußzeile anpassbar

### 14. Validierung
- [ ] **REQ-VAL-001**: IBAN-Format validieren
- [ ] **REQ-VAL-002**: BIC-Format validieren (optional bei SEPA)
- [ ] **REQ-VAL-003**: Steuernummer-Format prüfen (länderspezifisch)
- [ ] **REQ-VAL-004**: USt-IdNr.-Format prüfen (EU-Format)
- [ ] **REQ-VAL-005**: Pflichtfelder prüfen und Warnung ausgeben
- [ ] **REQ-VAL-006**: Negative Beträge warnen
- [ ] **REQ-VAL-007**: Plausibilitätsprüfung (Summen > 0, Menge > 0)

### 15. Erweiterte Features
- [ ] **REQ-EXT-001**: Optional: ZUGFeRD/XRechnung Metadaten (für elektronische Rechnungen)
- [ ] **REQ-EXT-002**: Export als ZUGFeRD/XRechnung XML
- [ ] **REQ-EXT-003**: Wasserzeichen ("ENTWURF", "KOPIE", "BEZAHLT")
- [ ] **REQ-EXT-004**: Anhänge (AGB, Leistungsverzeichnis) als weitere Seiten
