/*

	ESERCIZIO
	
	1 - Calcolare l'età media degli utenti che hanno un indirizzo e-mail (non PEC)
	2 - Calcolare, per ogni utente, il numero di recapiti che ha (se non ne ha, specificare 0)


*/


--1
SELECT 
AVG( DISTINCT contatto.eta) AS eta_media
FROM contatto 
INNER JOIN recapito
ON contatto.id_contatto = recapito.id_contatto
WHERE recapito.tipo_recapito NOT LIKE '%PEC%';
-- WHERE recapito.tipo_recapito ='e-mail'; -- per utenti con solo e-mail base
/*
Ci vuole il DISTINCT dentro AVG perchè nella join ci sono dei record di contatto che sono duplicati
(perchè la join è 1:N e non 1:1)
*/

-- verifica duplicati
SELECT 
*
FROM contatto 
INNER JOIN recapito
ON contatto.id_contatto = recapito.id_contatto
WHERE recapito.tipo_recapito NOT LIKE '%PEC%';

-- 2
SELECT 
contatto.nome,contatto.cognome,
COUNT(recapito.tipo_recapito)
FROM contatto 
LEFT JOIN recapito
ON contatto.id_contatto = recapito.id_contatto
GROUP BY nome,cognome;

/*
Ci vuole left join in modo che se il record non ha recapiti, le colonne dell'altra tab sono NULL
e così il count dà automaticamente 0 (come richiesto).
*/
 