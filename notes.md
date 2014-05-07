# Was muss enthalten sein, damit ich die erste Version installieren kann?

- Datenbank muss konsistent sein, d.h. Focus auf validierungen (eindeutigkeit, kontrolle pdf, etc.)
- JSON-Parse sollte funktionieren

- Fax-Ausgaben müssen gespeichert werden (lp-output, vielleicht auch stderr?)

- keine doppelten Faxe, d.h. Faxe mit dem selben Dokument, Empfänger und Patieten
- 

# Wie kann ich das System umstellen

- Neues System installieren (one-click deployment!)
- Das alte System anhalten (kurzfristig)
- Das neue System starten (werden die Faxe korrekt importiert?)

- Dann einzelne Faxe versenden per console (werden die Faxe korrekt übertragen)
- Ist der versand-status sichtbar

# PoC: Kann man ein Fax einfacher per cups-lib versenden und überprüfen?
