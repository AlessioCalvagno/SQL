/*
	ESTRAZIONE DI SOTTOSTRINGHE
	
	Dalla tabella 'contatto':
	
	1 - Estrarre i primi 2 caratteri dal campo 'nome'
	2 - Estrarre i caratteri dal secondo al quarto (compresi) dal campo 'nome'
*/

--1
SELECT LEFT(nome,2) FROM contatto;

--2
SELECT SUBSTR(nome,2,3), nome FROM contatto;