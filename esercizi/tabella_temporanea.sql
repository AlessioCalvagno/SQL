/*
	ESERCIZIO
	
	1 - Creare una tabella temporanea con i campi ragione_sociale (testo), partita_iva (testo),
	data_creazione (data), fatturato (numero in vigrola mobile)

*/

CREATE TEMPORARY TABLE rubrica.tmp (
	ragione_sociale TEXT,
	partita_iva TEXT,
	data_creazione DATE,
	fatturato DECIMAL
);