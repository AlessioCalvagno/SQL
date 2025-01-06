/*

	ESERCIZIO INSERT
	
	1 - Creare una tabella temporanea con la stessa struttura della tabella "contatto"
	2 - Inserire il seguente record: id_contatto=6, nome=John, cognome=Morris, data_creazione=(40 giorni fa), eta=56
	3 - Creare una tabella temporanea con la stessa struttura della tabella "contatto" e chiamarla "clienti"
	4 - Inserire, nella tabella "clienti", tutti i contatti di età inferiore a 40 anni


*/

--1
CREATE TEMPORARY TABLE temporanea2 AS
SELECT * FROM contatto;

--2 
INSERT INTO temporanea2 (id_contatto, nome, cognome, data_creazione, eta)
VALUES (6, 'John', 'Morris', DATE_ADD(CURRENT_DATE(), INTERVAL -40 DAY), 56);

SELECT * FROM temporanea2;

-- 3
CREATE TEMPORARY TABLE clienti AS
SELECT * FROM contatto WHERE eta < 40;

SELECT * FROM clienti;

-- oppure 
CREATE TEMPORARY TABLE clienti AS
SELECT * FROM contatto;

DELETE FROM clienti WHERE eta >=40;


