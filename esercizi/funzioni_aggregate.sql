/*

	ESERCIZIO
	
	1 - Contare tutti gli indirizzi e-mail (anche PEC) contenuti nei recapiti
	2 - Calcolare l'età media, l'età massima e l'età minima dei contatti

*/

--1
SELECT
COUNT(*) as conteggio
FROM recapito
WHERE LOCATE('@',recapito);

--2
SELECT
MIN(eta) AS minimo,
MAX(eta) AS massimo,
AVG(eta) AS media
FROM contatto;