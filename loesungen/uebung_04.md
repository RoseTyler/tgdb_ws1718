# Tutorium - Grundlagen Datenbanken - Blatt 4

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
Um genauere Informationen und Prognosen mit Data Mining Werkzeugen zu schöpfen, ist es notwendig mehr Informationen über die registrierten Benutzer zu sammeln und zu speichern. Die in Zukunft gesammelten Informationen sollen in neuen Tabellen des bestehenden Datenbankmodells gespeichert werden. Dazu soll jedem Benutzer einen Erst- und Zweitwohnsitz zugeordnet werden. Jeder Wohnsitz besitzt eine eigene Adresse. Integriere in das bestehende Datenbankmodell Tabellen die den genauen Erst- und Zweitwohnsitz abbilden können. Beachte dazu die Normalisierungsformen bis 3NF - [Dokumentation](https://de.wikipedia.org/wiki/Normalisierung_(Datenbank)). Wie lautet deine SQL-Syntax um deine Erweiterung des Datenbankmodells zu implementieren?

#### Lösung
```sql
CREATE TABLE RESIDENCE 
  (
    RESIDENCE_ID NUMBER(38) NOT NULL,
    ADDRESS_ID NUMBER(38) NOT NULL,
	ACCOUNT_ID NUMBER(38) NOT NULL,
	COUNTRY_ID NUMBER(38) NOT NULL,
    FIRST_STREET VARCHAR(32) NOT NULL,
	SECOND_STREET VARCHAR(32) NOT NULL,
    CONSTRAINT PK_RESIDENCE PRIMARY KEY (RESIDENCE_ID),
    CONSTRAINT FK_ADDRESS FOREIGN KEY (ADDRESS_ID) REFERENCES ADDRESS(ADDRESS_ID)
	CONSTRAINT FK_ACCOUNT FOREIGN KEY (ACCOUNT_ID) REFERENCES ACCOUNT(ACCOUNT_ID)
	CONSTRAINT FK_COUNTRY FOREIGN KEY (COUNTRY_ID) REFERENCES COUNTRY(COUNTRY_ID)
  );
```

### Aufgabe 2
Als App Entwickler/in für Android und iOS möchtest du dich nicht darauf verlassen, dass die Adresse exakt richtig ist und überlegst in dem Datenbankmodell noch zwei zusätzliche Attribute (X und Y Koordinate) zur genauen GPS Lokalisierung einer Tankstelle aufzunehmen. Wie lautet deine SQL-Syntax um das Datenbankmodell auf die zwei Attribute zu erweitern?

#### Lösung
```sql
ALTER TABLE GAS_STATION
   ADD (GPS_POS_X NUMBER(10,5),
        GPS_POS_Y NUMBER(10,5));
```

### Aufgabe 3
Welche Kunden haben im Jahr 2017 mehr als den Durchschnitt getank?

#### Lösung
```sql
SELECT r.account_id
FROM receipt r 
Group BY r.account_id
HAVING AVG (r.price_l * r.liter) *r.duty_amount) 
> ( SELECT AVG ((price_l * liter) * duty_amount)
FROM receipt
WHERE TO_CHAR (receipt_date, 'YYYY') =  '2017');
```

### Aufgabe 4
Ermittle, warum du INSERT-Rechte auf die Tabelle `SCOTT.EMP` und UPDATE-Rechte auf die Tabelle `SCOTT.DEPT` besitzt. Beantworte dazu schrittweise die Aufgaben von 4.1 bis 4.4.

#### Aufgabe 4.1
Wurden die Tabellen-Rechte direkt an dich bzw. an `PUBLIC` vergeben?

##### Lösung
```sql
SELECT * 
FROM all_tab_privs
WHERE table_schema = 'SCOTT';

UPDATE Rechte von Scott tabelle: DEPT an PUBLIC vergeben
SELECT Rechte von Scott tabelle:Salgrade an PUBLIC vergeben
INSERT Rechte von Scott tabelle:Bonus an mich vergeben
```

#### Aufgabe 4.2
Welche Rollen besitzt du direkt?

##### Lösung
```sql
SELECT granted_role, default_role
FROM user_role_privs;
```

#### Aufgabe 4.3
Welche Rollen haben die Rollen?

##### Lösung
```sql
SELECT granted_role, default_role
FROM role_role_privs 
WHERE role IN (SELECT granted_role FROM user_role_privs);
```

#### Aufgabe 4.4
Haben die Rollen Rechte an `SCOTT.EMP` oder `SCOTT.DEPT`?

##### Lösung
```sql
SELECT  *
FROM role_tab_privs
WHERE table_name IN ('EMP', 'DEPT')
AND role IN ('FH_TRIER', 'STUDENT','BA_STUDENT','BW_STUDENT') 
AND owner = 'SCOTT';
```

### Aufgabe 5
Es soll für jede Tankstelle der Umsatz einzelner Jahre aufgelistet werden auf Basis der Daten, die Benutzer durch ihre Quittungen eingegeben haben. Sortiere erst nach Jahr und anschließend nach der Tankstelle. Beispiel:

| Jahr  | Anbieter  | Straße            | PLZ   | Stadt | Land          | Umsatz    |
| ----- | --------- | ----------------- | ----- | ----- | --------------| --------- |
| 2017  | Esso      | Triererstraße 15  | 54292 | Trier | Deutschland   | 54784.14  |
| 2017  | Shell     | Zurmainerstraße 1 | 54292 | Trier | Deutschland   | 67874.78  |
| 2016  | Esso      | Triererstraße 15  | 54292 | Trier | Deutschland   | 57412.66  |
| 2016  | Shell     | Zurmainerstraße 1 | 54292 | Trier | Deutschland   | 72478.42  |

#### Lösung
```sql
SELECT TO_CHAR( r.receipt_date, 'YYYY') "JAHR",
p.provider_name "Anbieter",
gs.street "Straße",
a.plz "PLZ",
a.city "Stadt",
c.country_name  "Land",
SUM (r.price_liter * r.liter 1 + r.duty_amount))"Umsatz"
FROM receipt r 
INNER JOIN  gas_station gs ON (r.gas_station_id = gs.gas_station_id)
INNER JOIN  provider p ON (p.provider_id = gs.provider_id)
INNER JOIN  country c ON (c.country_id = gs.country_id)
INNER JOIN  address a ON (a.address_id = gs.address_id)
GROUP BY 
r.receipt_date,
p.provider_name,
gs.street,
a.plz,
a.city,
c.country_name
ORDER BY "Jahr", "Anbieter", "Straße", "PLZ", "Stadt", "Land";
```


