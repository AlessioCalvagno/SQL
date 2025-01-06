/*

	ESERCIZIO
	
	1 - Estrarre gli identificativi dei contatti che hanno almeno un recapito di qualsiasi tipo


*/

SELECT 
DISTINCT contatto.id_contatto
FROM contatto
JOIN recapito
ON contatto.id_contatto = recapito.id_contatto;

/* subquery???*/

-- con subquery (che secondo me non ha senso)
SELECT 
DISTINCT contatto.id_contatto
FROM contatto
INNER JOIN (SELECT id_contatto FROM recapito) AS rec
ON contatto.id_contatto = rec.id_contatto;

-- si fa la join con la subquery

-- oppure mettere subquery dentro il WHERE
SELECT 
DISTINCT id_contatto
FROM contatto
WHERE id_contatto in (SELECT id_contatto FROM recapito);