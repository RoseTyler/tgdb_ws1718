# Tutorium - Grundlagen Datenbanken - Blatt 6

## Vorbereitungen
* Für dieses Aufgabenblatt wird die SQL-Dump-Datei `schema_default.sql` benötigt, die sich im Verzeichnis `sql` befindet.
* Die SQL-Dump-Datei wird in SQL-Plus mittels `start <Dateipfad/zur/sql-dump-datei.sql>` in die Datenbank importiert.
* Beispiele
  * Linux `start ~/Tutorium.sql`
  * Windows `start C:\Users\max.mustermann\Desktop\Tutorium.sql`

## Datenbankmodell
![Datenbankmodell](./img/schema_default.png)

## Data-Dictionary-Views
![Data-Dictionary-Views](./img/constraint_schema.png)

## Aufgaben

### Aufgabe 1
Wie heißt der Primary Key Contraint der Tabelle `VEHICLE` und für welche Spalten wurde er angelegt?

#### Lösung
```sql
SELECT ucc.constraint_name, ucc_column_name, ucc.position
FROM user_cons_columns ucc
WHERE ucc.constraint_name IN 
(Select uc.constraint_name
FROM user_costraints uc
WHERE uc.table_name LIKE 'ACC_VEHIC' 
AND uc.CONSTRAINT_type = 'P');
 --oder
SELECT ucc.constraint_name, ucc_column_name, ucc.position
FROM user_cons_columns ucc
INNER JOIN ucc.constraint_name ON (ucc.constraint_name = uc.constraint_name)
WHERE uc.table_name LIKE 'ACC_VEHC' 
AND uc.CONSTRAINT_type = 'P');
```

### Aufgabe 2
Für welche Spalte**n** der Tabelle `ACC_VEHIC` wurde ein Foreign Key angelegt und auf welche Spalte/n in welcher Tabelle wird er referenziert?

#### Lösung
```sql
SELECT uc.Constraint_TYPE AS "Typ", uc.CONSTRAINT_NAME AS "constraint", uc.TABLE_NAME as "H-Tablle", ucc.TABLE_NAME AS "R-Tablle", ucc.COLUMN_NAME AS "Spalte"
FROM user_constraints uc
LEFT JOIN user_cons_columns ucc ON (ucc.CONSTRAINT_NAME = uc.R_CONSTRAINT_NAME)
WHERE uc.TABLE_NAME = 'ACC_VEHIC';


SELECT ucc.constraint_name, ucc_column_name, ucc.table_name
FROM user_cons_columns ucc
WHERE ucc.constraint_name IN 
(Select uc.constraint_name
FROM user_costraints uc
WHERE uc.table_name LIKE 'ACC_VEHIC' 
AND uc.CONSTRAINT_type = 'R');
```

### Aufgabe 3
Erstelle einen Check Constraint für die Tabelle `ACCOUNT`, dass der Wert der Spalte `U_DATE` nicht älter sein kann als `C_DATE`.

#### Lösung
```sql
--Constraint
ALTER TABLE ACCOUNT ADD CONSTRAINT c_date
CHECK (U_DATE >= C_DATE);
--Überprüfung
UPDATE ACCOUNT
SET u_date = T_DATE('2014-11-13', 'YYYY-MM-DD')
WHERE account_id = 1;
```

### Aufgabe 4
Erstelle einen Check Constraint der überprüft, ob der erste Buchstabe der Spalte `GAS_NAME` der Tabelle `GAS` groß geschrieben ist.

#### Lösung
```sql
ALTER TABLE gas
ADD CONSTRAINT u_gas_name
CHECK (gas_name = INITCAP (gas_name));

ALTER TABLE gas
ADD CONSTRAINT u_gas_name
CHECK (REGEXP_LIKE(gas_name, '^[A-Z].*$'));
```

### Aufgabe 5
Erstelle einen Check Contraint der überprüft, ob der Wert der Spalte `IDENTICATOR` der Tabelle `ACC_VEHIC` eins von diesen möglichen Fahrzeugkennzeichenmustern entspricht. Nutze Reguläre Ausdrücke.

+ B:AB:5000
+ TR:MP:1
+ Y:123456
+ THW:98765
+ MZG:XZ:96

#### Lösung
```sql
--Constraint
ALTER TABLE  acc_vehic
add constraint c_kennzeichen_etspricht
check (regexp_like(indenticator, '^[A-Z] {1,3} : [A-Z] {1,2} : [1-9] [0-9]{0,3}|[1-9] [0-9]{0,5)$'. 'C'));
--Tests durch Falscheingabe
UPDATE acc_vehic
SET identicater = '8:ß:I'
WHERE vehicle_id = 1;

UPDATE acc_vehic
SET identicater = 'ZF:53:833'
WHERE vehicle_id = 1;

UPDATE acc_vehic
SET identicater = '10:MP:783'
WHERE vehicle_id = 1;

UPDATE acc_vehic
SET identicater = '10: :783'
WHERE vehicle_id = 1;
--Update funktioniert
UPDATE acc_vehic
SET identicater = 'TR:WS:52'
WHERE vehicle_id = 1;
```

### Aufgabe 6 - Wiederholung
Liste für alle Personen den Verbrauch an Kraftstoff auf (Missachte hier die unterschiedlichen Kraftstoffe). Dabei ist interessant, wie viel Liter die einzelne Person getankt hat und wie viel Euro sie für Kraftstoffe ausgegeben hat.

#### Lösung
```sql
SELECT 
a.surname, 
a.forename,
(
SELECT SUM(price_l*r.Liter*1+r.duty_amount)
FROM receipt r
WHERE account_id = a.account_id
GROUP BY r.account_id) "Ausgaben",
(
SELECT SUM (r.Liter)
FROM receipt r
WHERE account_id = a.account_id
) "Getankte Liter"
FROM account a;
```

### Aufgabe 7 - Wiederholung
Liste die Tankstellen absteigend sortiert nach der Kundenanzahl über alle Jahre.

#### Lösung
```sql
SELECT TO_CHAR (r.c_date, 'YYYY') "Jahr",
p.provider_name "Provider",
gs.street "Straße",
a.plz "PLZ",
a.city "Stadt",
COUNT(r.account_id) "Anzahl"
FROM gs_station gs
INNER JOIN provider p ON (p.provider_id = gs.provider_id)
INNER JOIN address a  ON (a.address_id = gs.address_id)
INNER JOIN receipt r ON (r.gas_station_id = gs.gas_station_id)
GROUP BY r.c_date, p.provider_name, gs.street, a.plz, a.city;
```

### Aufgabe 8 - Wiederholung
Erweitere das Datenbankmodell um ein Fahrtenbuch, sowie es Unternehmen für ihren Fuhrpark führen. Dabei ist relevant, welche Person an welchem Tag ab wie viel Uhr ein Fahrzeug für die Reise belegt, wie viele Kilometer zurück gelegt wurden und wann die Person das Fahrzeug wieder abgibt.

Berücksichtige bitte jegliche Constraints!

#### Lösung
```sql
CREATE TABLE LBOOK (
LBOOK_ID NUMBER (38) NOT NULL,--PK
ACCLUNT-ID NUMBER (38) NOT NULL, -- FK
ACC_VEHIC_ID NUMBER (38) NOT NULL, --FK
B_DATE DATE NOT NULL,
KILOMETER NUMBER (7,3) NOT NULL,
S_DATE DATE NOT NULL);

--CONSTRAINTS
ALTER TABLE LBOOK
ADD CONSTRAINT LBOOK_PK
PRIMARY KEY (LBOOK_ID);

ALTER TABLE LBOOK
ADD CONSTRAINT ANDERERNAME
FOREIGN KEY (ACCOUNT_ID) REFERENCES ACCOUNT (ACCOUNT_ID);

ALTER TABLE LBOOK
ADD CONSTRAINT LBOOK_PK
FOREIGN KEY (ACC_VEHIC_ID)REFERENCES ACC_VEHIC_ID (ACC_VEHIC_ID);

ALTER TABLE LBOOK 
ADD CONSTRAINT check_date
CHECK (S_DATE >= B_DATE);
CHECK (S_DATE >= B_DATE);
```






