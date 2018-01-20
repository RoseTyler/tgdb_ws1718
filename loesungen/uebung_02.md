# Tutorium - Grundlagen Datenbanken - Blatt 2

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
Schaue dir das Datenbankmodell an. Wofür steht hinter dem Datentyp `NUMBER` die Zahlen in den runden Klammern?
Nehme dir die Oracle [Dokumentation](https://docs.oracle.com/cd/B28359_01/server.111/b28318/datatype.htm#CNCPT012) zu Hilfe.

#### Lösung
NUMBER (p,s): p von 1 bis 38 (Gesamtzahl der Stellen) und s von -84 bis 127 (Vor- bzw. Nachkommastellen).

### Aufgabe 2
Was bedeuten die durchgezogenen Linien, die zwischen einigen Tabellen abgebildet sind?

#### Lösung
Es muss eine Beziehung zwischen den Tabellen bestehen!
1:n Beziehung -> Ein Auto kann nur einen bestimmten Kraftstoff fahren z.B. Diesel
n:1 Beziehung -> Ein Kraftstoff kann aber von mehreren Autos gefahren werden z.B. Benzin 95


### Aufgabe 3
Was bedeutet die gestrichelte Linie, die zwischen der Tabelle `ACC_VEHIC` und `GAS_STATION` abgebildet ist?

#### Lösung
Zwischen den Tabellen herrscht eine optionale Verbindung, da der Fremdschlüssel den Wert NULL annehmen kann und somit kann keine Verbindung hergestellt werden.

### Aufgabe 4
Die folgende Abbildung beschreibt eine Beziehung zwischen Tabellen. Sie wird auch `n` zu `m` Beziehung genannt. Beschreibe kurz die Bedeutung dieser Beziehung.
Nehme dir diesen [Artikel](https://glossar.hs-augsburg.de/Beziehungstypen) zu Hilfe.

![n-to-m-relationship](./img/n-to-m-relationship.png)

Bei Tabellen mit einer m:n-Beziehung kann jedem Datensatz in Tabelle X mehreren passenden Datensätzen in Tabelle Y zugeordnet sein und umgekehrt. Da bei dieser Beziehungsart, keine eindeutige Zuordnung mehr vorhanden ist, können sie nur über eine Verbindungstabelle definiert werden. In dieser dritten Tabelle sind in der Regel nur die Fremdschlüssel der beiden anderen Tabellen als Primärschlüssel enthalten. Eine m:n-Beziehung besteht also eigentlich aus zwei 1:n Beziehungen, die über eine dritte Tabelle verknüpft sind. 
Eine Person kann mehrere Hobbies ausüben und ein Hobby kann von mehreren Personen ausgeübt werden.

### Aufgabe 5
Was bedeutet der Buchstabe `P` und `F` neben den Attributen von Tabellen?

#### Lösung
 P = Primärschlüssel  
 F = Fremdschlüssel

### Aufgabe 6
Importiere die SQL-Dump-Datei in dein eigenes Schema. Wie lautet dazu der Befehl um dem import zu starten?

#### Lösung
```sql
@C:\Users\User\workspace\github.com\RoseTyler\tgdb_ws1718\sql\tutorium.sql
--Oder durch start + Link
```

### Aufgabe 7
Gebe alle Datensätze der Tabelle `ACCOUNT` aus.

#### Lösung
```sql
SELECT * 
FROM ACCOUNT;
```

### Aufgabe 8
Modifiziere Aufgabe 7 so, dass nur die Spalte `ACCOUNT_ID` ausgegeben wird.

#### Lösung
```sql
SELECT ACCOUNT_ID 
FROM ACCOUNT;
```

### Aufgabe 9
Gebe alle Spalten der Tabelle `VEHICLE` aus.

#### Lösung
```sql
DESC VEHICLE;

SELECT *
FROM VEHICLE
```

### Aufgabe 10
Kombiniere Aufgabe 7 und 9 so, dass nur Personen (`ACCOUNT`) angezeigt werden, die ein Auto (`VEHICLE`) besitzen.

#### Lösung
```sql
SELECT DISTINCT ACCOUNT.ACCOUNT_ID, SURNAME, FORENAME 
FROM ACCOUNT, ACC_VEHIC 
WHERE ACCOUNT.ACCOUNT_ID = ACC_VEHIC.ACCOUNT_ID;

SELECT DISTINCT ACCOUNT.ACCOUNT_ID, SURNAME, FORENAME 
FROM ACCOUNT 
INNER JOIN ACC_VEHIC ON ACC_VEHIC.ACCOUNT_ID = ACCOUNT.ACCOUNT_ID;
```

### Aufgabe 11
Modifizierde die Aufgabe 10 so, dass nur die Person mit der `ACCOUNT_ID` = `7` angezeigt wird.

#### Lösung
```sql
SELECT DISTINCT ACCOUNT.ACCOUNT_ID, SURNAME, FORENAME 
FROM ACCOUNT, ACC_VEHIC 
WHERE ACCOUNT.ACCOUNT_ID = '7';
```

### Aufgabe 12
Erstelle für dich einen neuen Benutzer.
> Achtung, nutze für die Spalten `C_DATE` und `U_DATE` vorerst die Syntax `SYSDATE` - [Dokumentation](https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions172.htm)

#### Lösung
```sql
INSERT INTO ACCOUNT 
VALUES((SELECT MAX (ACCOUNT_ID) FROM ACCOUNT) + 1, 'Wein', 'Anne', 'weina@hochschule-trier.de', SYSDATE, SYSDATE);
```

### Aufgabe 13
Erstelle für deinen neuen Benutzer ein neues Auto. Dieses Auto dient als Vorlage für die nächten Aufgaben.

#### Lösung
```sql
INSERT INTO VEHICLE
VALUES (
  (SELECT MAX(VEHICLE_ID)+1 FROM VEHICLE),
   1, 2, '3', NULL, 300,'15-SEP-17', 4, SYSDATE, SYSDATE);
```

### Aufgabe 14
Verknüpfe das aus Aufgabe 13 erstellte neue Auto mit deinem neuen Benutzer aus Aufgabe 12 in der Tabelle `ACC_VEHIC` und erstelle den ersten Rechnungsbeleg.

#### Lösung
```sql
INSERT INTO ACC_VEHIC
  VALUES (
    (SELECT MAX(ACC_VEHIC_ID)+1 FROM ACC_VEHIC),
    10,
    14,
    'GTD',
    NULL,
    10532,
    105,
    7452,
    200,
    '04-SEP-12',
    '05-OCT-111',
    NULL,
    SYSDATE,
    SYSDATE
  );

INSERT INTO receipt
VALUES( (SELECT MAX(receipt_id)+1 FROM receipt)
		(SELECT account_id FROM account WHERE email = 'weina@hochschule-trier'),
		(SELECT MAX(acc_vehic_id)+1 FROM acc_vehic),
		0.18,
		(SELECT gas_id FROM gas WHERE gas_name = 'Benzin 95'),
		(SELECT MAX(gas_station_id)+1 FROM gas_station),
		1.32,
		657.2,
		45.78,
		SYSDATE,
		SYSDATE,
		SYSDATE);
```

### Aufgabe 15
Ändere den Vorname `SURNAME` des Datensatzes mit der ID `7` in der Tabelle `ACCOUNT` auf `Zimmermann`.

#### Lösung
```sql
UPDATE ACCOUNT 
SET SURNAME = 'Zimmermann' 
WHERE ACCOUNT_ID = 7;
```

### Aufgabe 16
Speichere alle Änderungen deiner offenen Transaktion. Wie lautet der SQL-Befehl dazu?

#### Lösung
```sql
COMMIT;
```
