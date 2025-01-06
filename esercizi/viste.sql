/*
	ESERCIZIO
	
	1 - Creare una vista che contenga solo i contatti di età maggiore o uguale a 35 anni

*/

CREATE VIEW vista AS
SELECT * FROM contatto WHERE eta >=35;