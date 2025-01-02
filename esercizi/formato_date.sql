/*
	FORMATO DELLE DATE
	
	Dalla tabella 'contatto':
	
	1 - formattare il campo 'data_creazione' nel formato 'DD/MM/YYYY'
	2 - formattare il campo 'data_creazione' nel formato 'Mese DD, YYYY (es. April 13, 2021)'
	
*/

--1
SELECT data_creazione, 
DATE_FORMAT(data_creazione, '%d/%m/%Y') AS data_formattata
FROM contatto; 

--2
SELECT data_creazione, 
DATE_FORMAT(data_creazione, '%M %d, %Y') AS data_formattata
FROM contatto; 
