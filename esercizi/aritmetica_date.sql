/*

	ESERCIZIO
	
	1 - Sommare 7 giorni alla data di creazione nella tabella contatti, creando il campo "nuova_data"
	2 - Dalla nuova data, estrarre anno, mese e giorno come campi separati

*/

-- 1
SELECT data_creazione, DATE_ADD(data_creazione, INTERVAL +7 DAY) AS nuova_data FROM contatto LIMIT 5;
 
--2
SELECT data_creazione, DATE_ADD(data_creazione, INTERVAL +7 DAY) AS nuova_data,
YEAR(DATE_ADD(data_creazione, INTERVAL +7 DAY)) AS nuovo_anno,
MONTH(DATE_ADD(data_creazione, INTERVAL +7 DAY)) AS nuovo_mese,
DAY(DATE_ADD(data_creazione, INTERVAL +7 DAY)) AS nuovo_giorno FROM contatto LIMIT 5;

-- lo stesso usando una select annidata (subquery)
 SELECT DAY(nuova_data) as nuovo_giorno,
 MONTH(nuova_data) AS nuovo_mese,
 YEAR(nuova_data) AS nuovo_anno
 FROM (
 SELECT data_creazione, DATE_ADD(data_creazione, INTERVAL +7 DAY) AS nuova_data FROM contatto LIMIT 5
 ) AS subtable;
 
 