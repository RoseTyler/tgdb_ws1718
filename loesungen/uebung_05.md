# Tutorium - Grundlagen Datenbanken - Blatt 5

## Vorbereitungen
* Für dieses Aufgabenblatt wird die SQL-Dump-Datei `schema_default.sql` benötigt, die sich im Verzeichnis `sql` befindet.
* Die SQL-Dump-Datei wird in SQL-Plus mittels `start <Dateipfad/zur/sql-dump-datei.sql>` in die Datenbank importiert.
* Beispiele
  * Linux `start ~/Tutorium.sql`
  * Windows `start C:\Users\max.mustermann\Desktop\Tutorium.sql`

## Datenbankmodell
![Datenbankmodell](./img/schema_default.png)

## Aufgaben

### Aufgabe 1
Erstelle mit Dia oder einem anderen Werkzeug eine Abbilung der Mengen, die durch `INNER JOIN`, `RIGHT JOIN`, `LEFT JOIN` und `OUTER JOIN` gemeint sind.

#### Lösung
Inner Join: Liefert die Schnittmenge aus zwei Tabellen

Left Join: Liefert die Schnittmenge aus zwei Tabellen inkl. der Menge A

Right Join: Liefert die Schnittmenge aus zwei Tabellen inkl. der Menge B

Outer Join: Liefert Mengen A und Mengen B

### Aufgabe 2
Welche Personen haben kein Fahrzeug? Löse dies einmal mit `LEFT JOIN` und `RIGHT JOIN`.

#### Lösung
```sql
SELECT surname, forename
FROM account 
LEFT JOIN acc_vehic 
ON (account.account_id = acc_vehic.account_id)
WHERE vehicle_id IS NULL;

SELECT surname, forename, vehicle_id
FROM acc_vehic 
RIGHT JOIN account 
ON (acc_vehic.account_id = account.account_id)
WHERE vehicle_id IS NULL;
```
