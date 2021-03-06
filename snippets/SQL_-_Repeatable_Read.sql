/*
  @author:  Markus Pesch
  @date:    29.11.2015
  @email:   peschm@fh-trier.de
*/

/*
  Repeatable Read bedeutet,
  dass wenn ein SELECT ausgeführt wird, der Zustand bei einem Update derselbe ist wie bei der, der bei dem SELECT angezeigt wurde.
  Es könnte ja sein, dass sonst in einer anderen Transaktion eine Spalte geändert wurde.
*/

SELECT a.Note
FROM Anmeldung a
FOR UPDATE        -- Schlüsselwort für Repeatable Read Shared Lock wird gesetzt L(S)
