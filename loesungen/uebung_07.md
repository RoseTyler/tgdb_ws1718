# Tutorium - Grundlagen Datenbanken - Blatt 7

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

Analyse den untenstehenden anonymen PL/SQL-Codeblock. Was macht er?
Passe den Codeblock so an, dass nicht nur die ID des Benutzers ausgegeben wird, sondern auch der Vor- und Nachname, als auch die Anzahl seiner Fahrzeuge.

```sql
DECLARE
  v_account_id account.account_id%TYPE;

BEGIN
  SELECT MAX(a.account_id) INTO v_account_id
  FROM account a
  WHERE a.surname LIKE 'P%';

  DBMS_OUTPUT.PUT_LINE('Der neuste Benutzer mit dem Anfangsbuchstaben P im Nachnamen hat die ID ' || v_account_id);

EXCEPTION
  WHEN NO_DATA_FOUND
    THEN RAISE_APPLICATION_ERROR(-20001, 'Es wurde kein Benutzer gefunden');
  WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE ('Folgender unerwarteter Fehler ist aufgetreten: ');
  RAISE;
END;
/
```

#### Lösung
```sql
DECLARE
  v_account_id account.account_id%TYPE;
  v_surname	 account.surname%TYPE;
  v_forename account.forename%TYPE;
  v_anzahl NUMBER(38);

  BEGIN
  SELECT a.surname, a.forename, COUNT(av.vehicle_id), MAX(a.account_id) INTO v_surname, v_forename,v_anzahl, v_account_id
  FROM acc_vehic av
  INNER JOIN account a ON (a.account_id = av.account_id)
  WHERE a.surname LIKE 'P%'
  GROUP BY a.surname, a.forename,av.account_id, a.account_id;

  
  DBMS_OUTPUT.PUT_LINE('Der neuste Benutzer mit dem Anfangsbuchstaben P im Nachnamen hat die ID ' || v_account_id);
  DBMS_OUTPUT.PUT_LINE(' Der Nachname des Benutzers: ' || v_surname);
  DBMS_OUTPUT.PUT_LINE('Der Vorname des Benutzers: ' || v_forename);
  DBMS_OUTPUT.PUT_LINE('Anzahl der Fahrzeuge: ' || v_anzahl);
  
EXCEPTION
  WHEN NO_DATA_FOUND
    THEN RAISE_APPLICATION_ERROR(-20001, 'Es wurde kein Benutzer gefunden');
  WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE ('Folgender unerwarteter Fehler ist aufgetreten: ');
  RAISE;
END;
/
```

### Aufgabe 2
Schreibe einen anonymen PL/SQL-Codeblock, der die Tankstelle mit der kleinsten ID auflistet mit Informationen über den Anbieter und der Addresse. Implementiere ein `IF-ELSE` Konstrukt, dass wenn eine Tankstelle mehr Kundenbesuch erziehlt hat, als alle anderen im Durchschnitt, die Tankstelle als gut Besucht gekennzeichnet wird in der Ausgabe. Andernfalls wird die Tankstelle als schlecht Besucht gekennzeichnet.

#### Lösung
```sql
DECLARE
  v_provider		 provider.provider_name%TYPE;
  v_tankstelle_id		 gas_station.gas_station_id%TYPE;
  v_street			 gas_station.street%TYPE;
  v_city			 address.city%TYPE;
  v_plz				 address.plz%TYPE; 
  v_liter			 receipt.liter%TYPE;
  v_schnitt			 NUMBER(7,2); 



BEGIN
	select p.provider_name, a.plz, a.city, gs.street, gs.gas_station_id INTO v_provider, v_plz, v_city, v_street, v_tankstelle_id
	from gas_station gs
	INNER JOIN provider p ON (p.provider_id = gs.provider_id)
	INNER JOIN address a ON (a.address_id = gs.address_id)
	WHERE gs.gas_station_id = (Select min(gas_station_id) from gas_station);

  
  DBMS_OUTPUT.PUT_LINE('Tankstellen ID: ' || v_tankstelle_id);
  DBMS_OUTPUT.PUT_LINE(' Provider: ' || v_provider);
  DBMS_OUTPUT.PUT_LINE('Strasse: ' || v_street);
  DBMS_OUTPUT.PUT_LINE('Stadt: ' || v_city);
  DBMS_OUTPUT.PUT_LINE('Postleitzahl: ' || v_plz);
  
	SELECT SUM(liter) INTO v_liter
	FROM RECEIPT
	WHERE gas_station_id = (Select min(gas_station_id) from gas_station);
	
	SELECT AVG(liter) INTO v_schnitt
	FROM receipt;
	
	IF v_liter > v_schnitt THEN
	DBMS_OUTPUT.PUT_LINE('Liter Tankstelle: ' || v_liter);
	DBMS_OUTPUT.PUT_LINE('Liter Schnitt: ' || v_schnitt);
	DBMS_OUTPUT.PUT_LINE('Die Tankstelle wird als gut besucht gekennzeichnet');
	ELSE
	DBMS_OUTPUT.PUT_LINE('Liter Tankstelle: ' || v_liter);
	DBMS_OUTPUT.PUT_LINE('Liter Schnitt: ' || v_schnitt);
	DBMS_OUTPUT.PUT_LINE('Die Tankstelle wird als schlecht besucht gekennzeichnet, da: ' || v_liter || ' < ' || v_schnitt );
	END IF;
  
EXCEPTION
  WHEN NO_DATA_FOUND
    THEN RAISE_APPLICATION_ERROR(-20001, 'Es wurde kein Tankstelle gefunden');
  WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE ('Folgender unerwarteter Fehler ist aufgetreten: ');
  RAISE;
END;
/
```

### Aufgabe 3
Analysiere den untenstehenden anonymen PL/SQL-Code. Was macht er?
Passe den Codeblock so an, dass für jede Tankstelle alle Kunden die dort einmal tanken, waren ausgegeben werden.

```sql
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('Liste alle Tankstellen aus Deutschland');
  DBMS_OUTPUT.PUT_LINE('____________________________________________');
  FOR rec_gs IN (  SELECT p.provider_name, gs.street, a.plz, a.city, c.country_name
                    FROM gas_station gs
                      INNER JOIN address a ON (a.address_id = gs.address_id)
                      INNER JOIN provider p ON (gs.provider_id = p.provider_id)
                      INNER JOIN country c ON (gs.country_id = c.country_id)
                    WHERE c.country_name LIKE 'Deutschland') LOOP
    DBMS_OUTPUT.PUT_LINE('++ ' || rec_gs.provider_name || ' ++ ' || rec_gs.street || ' ++ ' || rec_gs.plz || ' ++ ' || rec_gs.city || ' ++ ' || rec_gs.country_name);
  END LOOP;
END;
/
```

#### Lösung
```sql
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('Liste alle Tankstellen aus Deutschland');
  DBMS_OUTPUT.PUT_LINE('____________________________________________');
  FOR rec_gs IN (  SELECT p.provider_name, gs.street, a.plz, a.city, c.country_name, gs.gas_station_id
                    FROM gas_station gs
                      INNER JOIN address a ON (a.address_id = gs.address_id)
                      INNER JOIN provider p ON (gs.provider_id = p.provider_id)
                      INNER JOIN country c ON (gs.country_id = c.country_id)
                    WHERE c.country_name LIKE 'Deutschland') LOOP
    DBMS_OUTPUT.PUT_LINE('++ ' || rec_gs.provider_name || ' ++ ' || rec_gs.street || ' ++ ' || rec_gs.plz || ' ++ ' || rec_gs.city || ' ++ ' || rec_gs.country_name);
	
	
	FOR cur_kud IN (  SELECT a.account_id, a.surname, a.forename
					  FROM receipt r
                      INNER JOIN account a ON (a.account_id = r.account_id)
					  WHERE r.gas_station_id = rec_gs.gas_station_id
					)LOOP
					  DBMS_OUTPUT.PUT_LINE('____________________________________________');
    DBMS_OUTPUT.PUT_LINE('++ ' || cur_kud.account_id || ' ++ ' || cur_kud.surname || ' ++ ' || cur_kud.forename);
	END LOOP;
	
  END LOOP;
END;
/
```

### Aufgabe 4
Schreibe einen anonymen PL/SQL-Codeblock, der alle deine Fahrzeuge auflistet und die dazugehörigen Belege inkl. Betrag, der ausgegeben wurde für jeden Tankvorgang.

#### Lösung
```sql
DECLARE
	v_account_id	 acc_vehic.account_id%TYPE;
	v_surname		 account.surname%TYPE;
	v_forname		 account.forename%TYPE;
	v_vehicle_id	 vehicle.vehicle_id%TYPE;
	v_version		 vehicle.version%TYPE;
	v_receipt_id	 receipt.receipt_id%TYPE;
	v_preis			 receipt.price_l%TYPE;
	v_kilometer		 receipt.kilometer%TYPE;
	v_betrag		 double precision;



BEGIN
	v_betrag := v_preis*v_kilometer;
	select av.account_id AS "Account", a.surname AS "Nachname", a.forename AS "Vorname", v.vehicle_id AS "Fahrzeugnummer", v.version AS "Fahrzeug", r.receipt_id AS "Rechnungsnummer", r.price_l * r.kilometer AS "Betrag insgesamt"
	INTO v_account_id, v_surname, v_forname, v_vehicle_id, v_version, v_receipt_id, v_betrag
	from vehicle v
	INNER JOIN acc_vehic av on (v.vehicle_id = av.vehicle_id) 
	INNER JOIN receipt r on (av.acc_vehic_id = r.acc_vehic_id)
	INNER JOIN account a on (a.account_id = r.account_id)
	WHERE a.surname LIKE 'Roth';

  
  DBMS_OUTPUT.PUT_LINE('Account: ' || v_account_id);
  DBMS_OUTPUT.PUT_LINE('nachname: ' || v_surname);
  DBMS_OUTPUT.PUT_LINE('vorname: ' || v_forname);
  DBMS_OUTPUT.PUT_LINE('fahrzeugnummer: ' || v_vehicle_id);
  DBMS_OUTPUT.PUT_LINE('fahrzeug: ' || v_version);
  DBMS_OUTPUT.PUT_LINE('rechnungsnummer: ' || v_receipt_id);
  DBMS_OUTPUT.PUT_LINE('Betrag insgesamt: ' || v_betrag);
  
 
  
EXCEPTION
  WHEN NO_DATA_FOUND
    THEN RAISE_APPLICATION_ERROR(-20001, 'Es wurde kein Beleg gefunden');
  WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE ('Folgender unerwarteter Fehler ist aufgetreten: ');
  RAISE;
END;
/
