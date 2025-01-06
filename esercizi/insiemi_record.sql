/*

	ESERCIZIO
	
	1 - Intersecare l'insieme di contatti creati dopo il 2010 con l'insieme di contatti di età maggiore
	di 35 anni
	2 - Ripetere l'esercizio con union, union all e minus


*/

-- 1
SELECT * FROM contatto WHERE YEAR(data_creazione) > 2010
INTERSECT 
SELECT * FROM over35;
-- si poteva fare con un semplice where sull'età

--versione 2
SELECT * FROM contatto WHERE YEAR(data_creazione) > 2010
INTERSECT 
SELECT * FROM contatto WHERE eta > 35;

-- 2
SELECT * FROM contatto WHERE YEAR(data_creazione) > 2010
UNION 
SELECT * FROM contatto WHERE eta > 35;

SELECT * FROM contatto WHERE YEAR(data_creazione) > 2010
EXCEPT 
SELECT * FROM contatto WHERE eta > 35;