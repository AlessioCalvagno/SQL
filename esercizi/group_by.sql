/*

	ESERCIZIO
	
	1 - Creare le fasce di età "over 31" e "under 30" e contare i contatti che vi ricadono


*/

SELECT 
COUNT(*),
CASE 
	WHEN eta <= 30 THEN 'under 30'
	ELSE 'over 30'
END as fascia 

FROM contatto
GROUP BY fascia;
