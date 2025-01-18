/*
 * 
Obiettivo
Il nostro obiettivo è creare una tabella di feature per il training di modelli di machine learning,
arricchendo i dati dei clienti con vari indicatori calcolati a partire dalle loro transazioni e dai conti posseduti.
La tabella finale sarà riferita all'ID cliente e conterrà informazioni sia di tipo quantitativo che qualitativo.

Indicatori Comportamentali da Calcolare
Gli indicatori saranno calcolati per ogni singolo cliente (riferiti a id_cliente) e includono:

Indicatori di base
- Età del cliente (da tabella cliente).
Indicatori sulle transazioni
- Numero di transazioni in uscita su tutti i conti.
- Numero di transazioni in entrata su tutti i conti.
- Importo totale transato in uscita su tutti i conti.
- Importo totale transato in entrata su tutti i conti.
Indicatori sui conti
- Numero totale di conti posseduti.
- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto).
Indicatori sulle transazioni per tipologia di conto
- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto).
- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto).
- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto).
- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto).

*/

/**
 * Lo script è suddiviso in due parti:
 * 1. nella prima parte sono definite delle tabelle che servono da supporto per il caricamento dei record nella tabella finale
 * 	orientativamente vi è una tabella per indicatore.
 * 2. nella seconda parte si crea la tabella finale (tab_finale) che contiene le fetaures richieste, e si caricano i dati
 * utilizzando le tabelle create nella parte 1; dopo l'inserimento dei valori tali tabelle di appoggio sono eliminate.
 * 
 * In ogni caso si rimanda ai commenti delle varie sezioni per ulteriori dettagli.
 * 
 * Lo script può essere lanciato più volte, producendo sempre gli stessi risultati, in quanto all'inizio del codice tutte le tabelle di appoggio e quella finale 
 * sono ricreate da zero.
 */

use banca;

/**
 * 
 * 
 * Parte 1 - creazione delle viste di supporto
 * 
 * 
 */

-- età del cliente

/*
 *  Per il calcolo dell'età si usa DATEDIFF che dà la differenza tra data corrente e data di nascita in giorni.
 *  Da giorni ad anno: 1 y = 365 d -> 1 d = 1/365 y e poi si arrotonda verso lo 0 (non si considerano anni bisestili).
 * 
 * 	Per comodità nella tabella si includono anche gli altri campi dei clienti (utile per ispezione tramite client).
 */

drop table if exists cliente_tmp;
create table cliente_tmp as 
select *,FLOOR(DATEDIFF(CURRENT_DATE(),data_nascita)/365) as eta from cliente;

-- check
select * from cliente_tmp limit 10;

-- Numero di transazioni in uscita su tutti i conti.
-- Numero di transazioni in entrata su tutti i conti.

/**
 * Si costruisce unica tabella dove le transazioni in uscita sono identificate dal campo tipo = 'spesa' 
 * e quelle in entrata con tipo = 'accredito'.
 */

drop table if exists num_trans;
create table num_trans as (
	select
	 clien.id_cliente as id_cliente,
		CASE
		when tipo_t.segno = '+' then 'accredito'
		else 'spesa'
	end as tipo,
	COUNT(*) as value
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	group by clien.id_cliente, tipo_t.segno
	order by id_cliente asc
);

-- check
select * from num_trans limit 10;



-- Importo totale transato in uscita su tutti i conti.
-- Importo totale transato in entrata su tutti i conti.

/**
 * Anche qui si costruisce un'unica tabella con la stessa logica della vista precedente 
 * (in uscita -> tipo = 'spesa', in entrata -> tipo = 'accredito').
 */

drop table if exists tot_trans;
create table tot_trans as (
select
	clien.id_cliente as id_cliente,
	CASE
		when tipo_t.segno = '+' then 'accredito'
		else 'spesa'
	end as tipo,
	sum(importo) as totale
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	group by clien.id_cliente, tipo_t.segno
	order by id_cliente asc
);

-- check
select * from tot_trans limit 10;

-- Numero totale di conti posseduti.

drop table if exists num_tot_conti;
create table num_tot_conti as (
	select 
		c.id_cliente as id_cliente,
		COUNT(distinct c.id_conto) as num_accounts
	from conto c
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	group by id_cliente
	order by id_cliente asc
);

-- check
select * from num_tot_conti limit 10;


-- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto).

/**
 * Questa tabella è simile a quella appena precedente, ma si inserisce un ulteriore raggruppamento per tipo di conto.
 */

drop table if exists num_tot_conti_tipologia;
create table num_tot_conti_tipologia as (
	select 
		clien.id_cliente as id_cliente,
		tc.desc_tipo_conto as tipo,
		COUNT(c.id_conto) as num_accounts
	from conto c
	inner join tipo_conto tc on c.id_tipo_conto = tc.id_tipo_conto
	inner join cliente clien on c.id_cliente = clien.id_cliente
	group by clien.id_cliente, tc.desc_tipo_conto
	order by clien.id_cliente asc
);

-- check
select * from num_tot_conti_tipologia limit 50;

-- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto).
-- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto).

/**
 * Basandosi sulla stessa logica delle altre viste, anche qui si fa un'unica vista per questi due contatori,
 * sfruttando il raggruppamento dei record in base alla tipologia di conto e di transazione 
 * (in uscita ->  tipo_transazione = 'spesa', in entrata -> tipo_transazione = 'accredito').
 */

drop table if exists num_trans_tipologia;
create table num_trans_tipologia as (
	select
	 clien.id_cliente as id_cliente,
		CASE
		when tipo_t.segno = '+' then 'accredito'
		else 'spesa'
	end as tipo_transazione,
	tc.desc_tipo_conto as tipo_conto,
	COUNT(*) as num_transazioni
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	inner join tipo_conto tc on c.id_tipo_conto = tc.id_tipo_conto 
	group by clien.id_cliente, tipo_t.segno, tc.desc_tipo_conto
	order by id_cliente asc
);

-- check
select * from num_trans_tipologia limit 50;


-- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto).
-- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto).

/**
 * Basandosi sulla stessa logica delle altre tabelle, anche qui si fa un'unica tabella per questi due contatori,
 * sfruttando il raggruppamento dei record in base alla tipologia di conto e di transazione 
 * (in uscita ->  tipo_transazione = 'spesa', in entrata -> tipo_transazione = 'accredito').
 */

drop table if exists tot_trans_tipologia;
create table tot_trans_tipologia as (
select
	clien.id_cliente as id_cliente,
	CASE
		when tipo_t.segno = '+' then 'accredito'
		else 'spesa'
	end as tipo_transazione,
	tc.desc_tipo_conto as tipo_conto,
	sum(t.importo) as totale
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	inner join tipo_conto tc on c.id_tipo_conto = tc.id_tipo_conto 
	group by clien.id_cliente, tipo_t.segno, tc.desc_tipo_conto
	order by id_cliente asc
);

-- check
select * from tot_trans_tipologia limit 50;


/**
 * 
 * 
 * Parte 2 - creazione della tabella finale e caricamento dei record nella stessa.
 * 
 * 
 */


/*
 * In questa parte la strategia seguita consiste prima nel creare la tabella vuota e successivamente inserire i valori colonna per colonna 
 * (ogni colonna rappresenta una feature richiesta).
 * 
 * In termini tecnici inizialmente si esegue una insert pescando i dati da una grande join tra la tabella 'cliente_tmp' e delle subquery di select
 * dalle altre tabelle definite nella prima parte.
 * 
 * Nota importante:
 * Ispezionando le tabelle create nella parte 1, si può vedere come non tutti gli id_cliente siano presenti:
 * ad esempio nella vista 'num_tot_conti' non è presente id_cliente = 0, in quanto tale cliente non ha conti associati e pertanto viene filtrato
 * dalle (inner) join eseguite nella definizione della tabella. 
 * 
 * Poichè è richiesto di fornire un record per ogni cliente registrato (anche senza conti e transazioni associati), si usa questo workaround: 
 * nella insert finale si utilizzano delle LEFT JOIN tra 'cliente_tmp' e le vaire subquery, in modo da selezionare tutti gli id_cliente a disposizione,
 * e dove le join producono un NULL, questo viene sostituito con il valore di default 0 tramite la funzione COALESCE. 
 * Questo discorso NON si applica all'età del cliente, che invece prevede sempre un valore inserito.
 */

drop table if exists tab_finale;
create table tab_finale (
id_cliente int not null, -- Id del cliente
eta int, -- Età del cliente
num_trans_out_all int default 0, -- Numero di transazioni in uscita su tutti i conti
num_trans_in_all int default 0, -- Numero di transazioni in entrata su tutti i conti
importo_out_all double default 0.0, -- Importo totale transato in uscita su tutti i conti
importo_in_all double default 0.0, -- Importo totale transato in entrata su tutti i conti
num_conti_tot int default 0, -- Numero totale di conti posseduti
num_conti_base int default 0, -- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto)
num_conti_business int default 0,
num_conti_privati int default 0,
num_conti_famiglie int default 0,
num_trans_out_base int default 0, -- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto)
num_trans_out_business int default 0,
num_trans_out_privati int default 0,
num_trans_out_famiglie int default 0,
num_trans_in_base int default 0, -- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto)
num_trans_in_business int default 0,
num_trans_in_privati int default 0,
num_trans_in_famiglie int default 0,
importo_out_base double default 0.0, -- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto)
importo_out_business double default 0.0,
importo_out_privati double default 0.0,
importo_out_famiglie double default 0.0,
importo_in_base double default 0.0, -- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto)
importo_in_business double default 0.0,
importo_in_privati double default 0.0,
importo_in_famiglie double default 0.0
);

INSERT INTO tab_finale (
    id_cliente, eta, 
    num_trans_out_all, num_trans_in_all, 
    importo_out_all, importo_in_all, 
    num_conti_tot, num_conti_base, num_conti_business, num_conti_privati, num_conti_famiglie, 
    num_trans_out_base, num_trans_out_business, num_trans_out_privati, num_trans_out_famiglie, 
    num_trans_in_base, num_trans_in_business, num_trans_in_privati, num_trans_in_famiglie,
    importo_out_base, importo_out_business, importo_out_privati, importo_out_famiglie,
    importo_in_base, importo_in_business, importo_in_privati, importo_in_famiglie
)
SELECT 
    c.id_cliente, c.eta,
    COALESCE(n_out_all.value, 0) AS num_trans_out_all,
    COALESCE(n_in_all.value, 0) AS num_trans_in_all,
    ROUND(COALESCE(t_out_all.totale, 0), 2) AS importo_out_all,
    ROUND(COALESCE(t_in_all.totale, 0), 2) AS importo_in_all,
    COALESCE(nt.num_accounts, 0) AS num_conti_tot,
    COALESCE(nt_base.num_accounts, 0) AS num_conti_base,
    COALESCE(nt_business.num_accounts, 0) AS num_conti_business,
    COALESCE(nt_privati.num_accounts, 0) AS num_conti_privati,
    COALESCE(nt_famiglie.num_accounts, 0) AS num_conti_famiglie,
    COALESCE(nt_out_base.num_transazioni, 0) AS num_trans_out_base,
    COALESCE(nt_out_business.num_transazioni, 0) AS num_trans_out_business,
    COALESCE(nt_out_privati.num_transazioni, 0) AS num_trans_out_privati,
    COALESCE(nt_out_famiglie.num_transazioni, 0) AS num_trans_out_famiglie,
    COALESCE(nt_in_base.num_transazioni, 0) AS num_trans_in_base,
    COALESCE(nt_in_business.num_transazioni, 0) AS num_trans_in_business,
    COALESCE(nt_in_privati.num_transazioni, 0) AS num_trans_in_privati,
    COALESCE(nt_in_famiglie.num_transazioni, 0) AS num_trans_in_famiglie,
    ROUND(COALESCE(t_out_base.totale, 0), 2) AS importo_out_base,
    ROUND(COALESCE(t_out_business.totale, 0), 2) AS importo_out_business,
    ROUND(COALESCE(t_out_privati.totale, 0), 2) AS importo_out_privati,
    ROUND(COALESCE(t_out_famiglie.totale, 0), 2) AS importo_out_famiglie,
    ROUND(COALESCE(t_in_base.totale, 0), 2) AS importo_in_base,
    ROUND(COALESCE(t_in_business.totale, 0), 2) AS importo_in_business,
    ROUND(COALESCE(t_in_privati.totale, 0), 2) AS importo_in_privati,
    ROUND(COALESCE(t_in_famiglie.totale, 0), 2) AS importo_in_famiglie
FROM 
    cliente_tmp c
LEFT JOIN (
    SELECT id_cliente, SUM(value) AS value
    FROM num_trans
    WHERE tipo = 'spesa'
    GROUP BY id_cliente
) n_out_all ON c.id_cliente = n_out_all.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(value) AS value
    FROM num_trans
    WHERE tipo = 'accredito'
    GROUP BY id_cliente
) n_in_all ON c.id_cliente = n_in_all.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans
    WHERE tipo = 'spesa'
    GROUP BY id_cliente
) t_out_all ON c.id_cliente = t_out_all.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans
    WHERE tipo = 'accredito'
    GROUP BY id_cliente
) t_in_all ON c.id_cliente = t_in_all.id_cliente
LEFT JOIN num_tot_conti nt ON c.id_cliente = nt.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_accounts) AS num_accounts
    FROM num_tot_conti_tipologia
    WHERE tipo LIKE '%Base%'
    GROUP BY id_cliente
) nt_base ON c.id_cliente = nt_base.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_accounts) AS num_accounts
    FROM num_tot_conti_tipologia
    WHERE tipo LIKE '%Business%'
    GROUP BY id_cliente
) nt_business ON c.id_cliente = nt_business.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_accounts) AS num_accounts
    FROM num_tot_conti_tipologia
    WHERE tipo LIKE '%Privati%'
    GROUP BY id_cliente
) nt_privati ON c.id_cliente = nt_privati.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_accounts) AS num_accounts
    FROM num_tot_conti_tipologia
    WHERE tipo LIKE '%Famiglie%'
    GROUP BY id_cliente
) nt_famiglie ON c.id_cliente = nt_famiglie.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Base%'
    GROUP BY id_cliente
) nt_out_base ON c.id_cliente = nt_out_base.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Business%'
    GROUP BY id_cliente
) nt_out_business ON c.id_cliente = nt_out_business.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Privati%'
    GROUP BY id_cliente
) nt_out_privati ON c.id_cliente = nt_out_privati.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Famiglie%'
    GROUP BY id_cliente
) nt_out_famiglie ON c.id_cliente = nt_out_famiglie.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Base%'
    GROUP BY id_cliente
) nt_in_base ON c.id_cliente = nt_in_base.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Business%'
    GROUP BY id_cliente
) nt_in_business ON c.id_cliente = nt_in_business.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Privati%'
    GROUP BY id_cliente
) nt_in_privati ON c.id_cliente = nt_in_privati.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(num_transazioni) AS num_transazioni
    FROM num_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Famiglie%'
    GROUP BY id_cliente
) nt_in_famiglie ON c.id_cliente = nt_in_famiglie.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Base%'
    GROUP BY id_cliente
) t_out_base ON c.id_cliente = t_out_base.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Business%'
    GROUP BY id_cliente
) t_out_business ON c.id_cliente = t_out_business.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Privati%'
    GROUP BY id_cliente
) t_out_privati ON c.id_cliente = t_out_privati.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'spesa' AND tipo_conto LIKE '%Famiglie%'
    GROUP BY id_cliente
) t_out_famiglie ON c.id_cliente = t_out_famiglie.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Base%'
    GROUP BY id_cliente
) t_in_base ON c.id_cliente = t_in_base.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Business%'
    GROUP BY id_cliente
) t_in_business ON c.id_cliente = t_in_business.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Privati%'
    GROUP BY id_cliente
) t_in_privati ON c.id_cliente = t_in_privati.id_cliente
LEFT JOIN (
    SELECT id_cliente, SUM(totale) AS totale
    FROM tot_trans_tipologia
    WHERE tipo_transazione = 'accredito' AND tipo_conto LIKE '%Famiglie%'
    GROUP BY id_cliente
) t_in_famiglie ON c.id_cliente = t_in_famiglie.id_cliente;


-- eliminazione delle tabelle non più necessarie

drop table if exists cliente_tmp;
drop table if exists num_trans;
drop table if exists tot_trans;
drop table if exists num_tot_conti;
drop table if exists num_tot_conti_tipologia;
drop table if exists num_trans_tipologia;
drop table if exists tot_trans_tipologia;

