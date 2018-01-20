# Tutorium - Grundlagen Datenbanken - Blatt 9

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
Wo liegen die Vor- und Nachteile eines Trigger in Vergleich zu einer Prozedur?

#### Lösung
Vorteile:

    automatische Ausführung vor oder nach dem Event. Er muss nicht explizit gestartet werden.
    können nach belieben ein- und ausgeschaltet werden
    Es sind keine zusätzlichen Berechtigungen notwendig

Nachteile:

    Gravierende Fehler beim falschen Erstellen (z.B. Ändern des Primäarschlüssles oder Fremdschlüssels)
    Triggerkette oft schwer nachzuvollziehen
    Festlegen ob der Trigger pro verändertem Datensatz oder pro Anweisungsaufruf ausgelöst werden soll. (z.B.UPDATE auf 100 Sätze,im ersten Fall wird der Trigger 100 Mal aktiviert, im zweiten Fall nur einmal.
    kann keinen Rückgabewert liefern
    kann keine Parameter übergeben bekommen

### Aufgabe 2
Wo drin unterscheidet sich der `Row Level Trigger` von einem `Statement Trigger`?

#### Lösung

    Row Level Trigger: Der Trigger wird für jede veränderte Zeile ausgeführt
    Statement Trigger: Der Trigger wird für jedes SQL-Statement ausgeführt


### Aufgabe 3
Schaue dir den folgenden PL/SQL-Code an. Was macht er?

```sql
CREATE SEQUENCE seq_account_id
START WITH 1000
INCREMENT BY 1
MAXVALUE 99999999
CYCLE
CACHE 20;

CREATE OR REPLACE TRIGGER BIU_ACCOUNT
BEFORE INSERT OR UPDATE OF account_id ON account
FOR EACH ROW
DECLARE

BEGIN
  IF UPDATING('account_id') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Die Account-ID darf nicht verändert oder frei gewählt werden!');
  END IF;

  IF INSERTING THEN
    :NEW.account_id := seq_account_id.NEXTVAL;
  END IF;
END;
/
```

#### Lösung
Dieser Trigger verhindert, dass die Account_ID verändert & damit selbst gewählt wird. 
Wenn eine Account_ID erstellt wird, wird diese automatisch mit einem Wert gefüllt(seq_account_id).

### Aufgabe 4
Verbessere den Trigger aus Aufgabe 2 so, dass
+ wenn versucht wird einen Datensatz mit `NULL` Werten zu füllen, die alten Wert für alle Spalten, die als `NOT NULL` gekennzeichnet sind, behalten bleiben.
+ es nicht möglich ist, das die Werte für `C_DATE` und `U_DATE` in der Zukunkt liegen
+ `U_DATE` >= `C_DATE` sein muss
+ der erste Buchstabe jedes Wortes im Vor- und Nachnamen groß geschrieben wird
+ die Account-ID aus einer `SEQUENCE` entnommen wird

Nutze die Lösung der Aufgabe 2, Aufgabenblatt 8 um die Aufgabe zu lösen. Dort solltest du einige Hilfestellungen finden.

#### Lösung
```sql
CREATE SEQUENCE seq_account_id
START WITH 1000
INCREMENT BY 1
MAXVALUE 99999999
CYCLE
CACHE 20;

CREATE OR REPLACE TRIGGER BIU_ACCOUNT
BEFORE INSERT OR UPDATE OF account_id ON account
FOR EACH ROW
DECLARE

BEGIN
  IF UPDATING('account_id') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Die Account-ID kann nicht verändert werden!');
  END IF;
  

  IF INSERTING THEN
    :NEW.account_id := seq_account_id.NEXTVAL;
  END IF;
END;
/
```

### Aufgabe 5
Angenommen der Steuersatz in Deutschland sinkt von 19% auf 17%.
+ Aktualisiere den Steuersatz von Deutschland und
+ alle Quittungen die nach dem `01.10.2017` gespeichert wurden.

#### Lösung
```sql
UPDATE county
SET duty_amount = 0.17
WHERE UPPER (county_name) = 'Deutschland';

UPDATE receipt
SET duty_amount = 
(SELECT Duty_amount
FROM county
WHERE UPPER (county_name)= 'Deutschland'
)
WHERE receipt_date > TO_DATE ('01.10.2017', 'dd.mm.yyyy');
```

### Aufgabe 6
Liste alle Hersteller auf, die LKW's produzieren und verknüpfe diese ggfl. mit den Eigentümern.

#### Lösung ?????
```sql
SELECT p.producer_ID "Hersteller_ID: ",
p.producer_name "Hersteller: ",
vt.vehicle_type_name "Fahrzeugtyp: "
FROM producer p
INNER JOIN   vehicle v ON (p.producer_ID = v.producer_ID)
INNER JOIN  vehicle_type vt ON (vt.vehicle_type_ID = v.vehicle_type_ID)
WHERE vehicle_type_name = 'LKW';
```


























