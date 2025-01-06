/*

	UPDATE

	1 - Creare una tabella temporanea con la stessa struttura e contenuto della tabella 'contatto'
	2 - Modificare la data di creazione fissandola a 30 giorni fa per tutti i contatti di età 
		inferiore a 40 anni.

*/

-- 1
CREATE TEMPORARY TABLE temporanea (
id_contatto INTEGER,
nome TEXT,
cognome TEXT,
data_creazione DATE,
eta INTEGER
);

INSERT INTO temporanea SELECT * FROM contatto;
SELECT * FROM temporanea;

-- oppure (in unico passaggio)
CREATE TEMPORARY TABLE temporanea AS
SELECT * FROM contatto;

-- 2
UPDATE temporanea 
SET data_creazione = DATE_ADD(CURRENT_DATE(),INTERVAL -30 DAY) 
WHERE eta < 40;

SELECT * FROM temporanea;