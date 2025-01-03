/*

	ESERCIZIO
	
	1 - Affiancare, a ogni contatto, la fascia di età così costituita:
	'Under 30'
	'30-40'
	'40-50'
	'Over 50'

PS: usare tabella 'contatto' e campo 'eta'
*/

SELECT *,
	CASE
		WHEN eta < 30 THEN 'Under 30'
		WHEN eta <= 40 THEN '30-40'
		WHEN eta <= 50 THEN '40-50'
		ELSE 'Over 50'	
	END AS fascia
FROM contatto;