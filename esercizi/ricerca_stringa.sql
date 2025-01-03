/*
	RICERCA IN UNA STRINGA
	
	Nel campo 'recapito' della tabella 'recapito':
	
	1 - Calcolare la posizione del simbolo '@'
	2 - Calcolare la posizione del simbolo '3'

*/

--1 
SELECT LOCATE('@',recapito) FROM recapito;

--2
SELECT LOCATE('3',recapito) FROM recapito;