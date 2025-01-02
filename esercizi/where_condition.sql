/*

	ESERCIZIO
	
	1 - Selezionare tutti i contatti di età superiore ai 30 anni
	2 - Selezionare tutti i contatti il cui nome comincia con la lettera "A"
	3 - Selezionare tutti i contatti il cui anno di inserimento è 2020 o 2018
	4 - Selezionare tutti i contatti il cui anno di inserimento è successivo
		 al 2013 (compreso), escludendo però il 2018	

*/

--1
SELECT * FROM contatto WHERE eta >= 30;

--2
SELECT * FROM contatto WHERE nome LIKE 'A%';

--3
SELECT * FROM contatto WHERE YEAR(data_creazione) IN (2020,2018);
--oppure
SELECT * FROM contatto WHERE YEAR(data_creazione) = 2020 OR YEAR(data_creazione) = 2018;

--4
SELECT * FROM contatto WHERE YEAR(data_creazione) >= 2013 AND YEAR(data_creazione) != 2018;
-- il diverso si può fare anche con <>

