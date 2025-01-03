/*
	SOSTITUZIONE
	
	Dalla tabella 'recapito':
	1 - Nel campo 'recapito' sostituire la stringa '.com' con '.it'
	2 - Nel campo 'tipo_recapito' la stringa 'PEC' con 'Posta Elettronica Certificata'
*/

--1
SELECT REPLACE(recapito, '.com', '.it') FROM recapito;

--2
SELECT REPLACE(tipo_recapito, 'PEC', 'Posta Elettronica Certificata') FROM recapito;
