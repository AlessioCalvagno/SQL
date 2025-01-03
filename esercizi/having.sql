/*
	ISTRUZIONE HAVING
	
	1 - Estrarre tutti i tipi di recapito che hanno almeno 2 record nella tabella 'recapito'

*/

SELECT 
tipo_recapito,
COUNT(*) AS conteggio
FROM recapito
GROUP BY tipo_recapito
HAVING COUNT(*) >= 2;