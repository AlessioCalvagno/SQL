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
 * 1. nella prima parte sono definite delle tabelle temporanee che servono da supporto per il caricamento dei record nella tabella finale;
 * vi è una tabella per indicatore.
 * 2. nella seconda parte si crea la tabella finale (tab_finale) che contiene le fetaures richieste, e si caricano i dati
 * utilizzando le tabelle create nella parte 1; dopo l'inserimento dei valori tali tabelle di appoggio sono eliminate automaticamente.
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
 * Parte 1 - creazione delle tabelle di supporto
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

drop temporary table if exists cliente_tmp;
create temporary table cliente_tmp as 
select *,FLOOR(DATEDIFF(CURRENT_DATE(),data_nascita)/365) as eta from cliente;

-- Numero di transazioni in uscita su tutti i conti.

drop temporary table if exists num_trans_out_all;
create temporary table num_trans_out_all as (
select 
	c.id_cliente as id_cliente,
	count(*) as value
from cliente c
left join conto con on con.id_cliente = c.id_cliente
left join transazioni t on t.id_conto = con.id_conto 
left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans 
where tipo_t.segno = '-'
group by c.id_cliente
order by id_cliente asc
);

-- Numero di transazioni in entrata su tutti i conti.
drop temporary table if exists num_trans_in_all;
create temporary table num_trans_in_all as (
	select 
	c.id_cliente as id_cliente,
	count(*) as value
from cliente c
left join conto con on con.id_cliente = c.id_cliente
left join transazioni t on t.id_conto = con.id_conto 
left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans 
where tipo_t.segno = '+'
group by c.id_cliente
order by id_cliente asc
);




-- Importo totale transato in uscita su tutti i conti.
drop temporary table if exists importo_out_all;
create temporary table importo_out_all as (
	select 
		c.id_cliente as id_cliente,
		sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans 
	where tipo_t.segno = '-'
	group by c.id_cliente
	order by id_cliente asc
);



-- Importo totale transato in entrata su tutti i conti.

drop temporary table if exists importo_in_all;
create temporary table importo_in_all as (
	select 
		c.id_cliente as id_cliente,
		sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans 
	where tipo_t.segno = '+'
	group by c.id_cliente
	order by id_cliente asc
);

-- Numero totale di conti posseduti.

drop temporary table if exists num_conti_tot;
create temporary table num_conti_tot as (
	select 
		c.id_cliente as id_cliente,
		COUNT(distinct c.id_conto) as num_accounts
	from conto c
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	group by id_cliente
	order by id_cliente asc
);


-- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto).

/**
 * Questa tabella è simile a quella appena precedente, ma si inserisce un ulteriore raggruppamento per tipo di conto.
 */

drop temporary table if exists num_conti_base;
create temporary table num_conti_base as (
	select
	c.id_cliente,
	COUNT(con.id_conto) as num_accounts
	from cliente c 
	left join conto con on con.id_cliente = c.id_cliente
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tc.desc_tipo_conto like '%Base%'
	group by c.id_cliente
);

drop temporary table if exists num_conti_business;
create temporary table num_conti_business as (
	select
	c.id_cliente,
	COUNT(con.id_conto) as num_accounts
	from cliente c 
	left join conto con on con.id_cliente = c.id_cliente
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tc.desc_tipo_conto like '%Business%'
	group by c.id_cliente
);

drop temporary table if exists num_conti_privati;
create temporary table num_conti_privati as (
	select
	c.id_cliente,
	COUNT(con.id_conto) as num_accounts
	from cliente c 
	left join conto con on con.id_cliente = c.id_cliente
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tc.desc_tipo_conto like '%Privati%'
	group by c.id_cliente
);

drop temporary table if exists num_conti_famiglie;
create temporary table num_conti_famiglie as (
	select
	c.id_cliente,
	COUNT(con.id_conto) as num_accounts
	from cliente c 
	left join conto con on con.id_cliente = c.id_cliente
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tc.desc_tipo_conto like '%Famiglie%'
	group by c.id_cliente
);

-- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto).

drop temporary table if exists num_trans_out_base;
create temporary table num_trans_out_base as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Base%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_out_business;
create temporary table num_trans_out_business as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Business%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_out_privati;
create temporary table num_trans_out_privati as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Privati%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_out_famiglie;
create temporary table num_trans_out_famiglie as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Famiglie%'
	group by c.id_cliente
	order by id_cliente asc
);



-- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto).

drop temporary table if exists num_trans_in_base;
create temporary table num_trans_in_base as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Base%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_in_business;
create temporary table num_trans_in_business as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Business%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_in_privati;
create temporary table num_trans_in_privati as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Privati%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists num_trans_in_famiglie;
create temporary table num_trans_in_famiglie as (
	select
	c.id_cliente,
	count(*) as num_transazioni
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Famiglie%'
	group by c.id_cliente
	order by id_cliente asc
);


-- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto).

drop temporary table if exists importo_out_base;
create temporary table importo_out_base as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Base%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_out_business;
create temporary table importo_out_business as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Business%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_out_privati;
create temporary table importo_out_privati as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Privati%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_out_famiglie;
create temporary table importo_out_famiglie as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '-' and tc.desc_tipo_conto like '%Famiglie%'
	group by c.id_cliente
	order by id_cliente asc
);

-- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto).

drop temporary table if exists importo_in_base;
create temporary table importo_in_base as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Base%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_in_business;
create temporary table importo_in_business as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Business%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_in_privati;
create temporary table importo_in_privati as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Privati%'
	group by c.id_cliente
	order by id_cliente asc
);

drop temporary table if exists importo_in_famiglie;
create temporary table importo_in_famiglie as (
	select
	c.id_cliente,
	sum(t.importo) as totale
	from cliente c
	left join conto con on con.id_cliente = c.id_cliente
	left join transazioni t on t.id_conto = con.id_conto 
	left join tipo_transazione tipo_t on tipo_t.id_tipo_transazione = t.id_tipo_trans
	left join tipo_conto tc on con.id_tipo_conto = tc.id_tipo_conto
	where tipo_t.segno = '+' and tc.desc_tipo_conto like '%Famiglie%'
	group by c.id_cliente
	order by id_cliente asc
);


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
 * In termini tecnici si esegue una insert pescando i dati da una grande join tra la tabella 'cliente_tmp' e le altre tabelle temporanee 
 * definite nella prima parte.
 * 
 * Nota importante:
 * Ispezionando le tabelle create nella parte 1, si può vedere come non tutti gli id_cliente siano presenti:
 * ad esempio nella tabella 'num_conti_tot' non è presente id_cliente = 0, in quanto tale cliente non ha conti associati e pertanto viene filtrato
 * dalle join eseguite nella definizione della tabella. 
 * 
 * Poichè è richiesto di fornire un record per ogni cliente registrato (anche senza conti e transazioni associati), si usa questo workaround: 
 * nella insert finale si utilizzano delle LEFT JOIN tra 'cliente_tmp' e le vaire tabelle, in modo da selezionare tutti gli id_cliente a disposizione,
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

insert into tab_finale (
    id_cliente, eta, 
    num_trans_out_all, num_trans_in_all, 
    importo_out_all, importo_in_all, 
    num_conti_tot, num_conti_base, num_conti_business, num_conti_privati, num_conti_famiglie, 
    num_trans_out_base, num_trans_out_business, num_trans_out_privati, num_trans_out_famiglie, 
    num_trans_in_base, num_trans_in_business, num_trans_in_privati, num_trans_in_famiglie,
    importo_out_base, importo_out_business, importo_out_privati, importo_out_famiglie,
    importo_in_base, importo_in_business, importo_in_privati, importo_in_famiglie
)
select
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
from 
    cliente_tmp c
left join num_trans_out_all n_out_all on c.id_cliente = n_out_all.id_cliente 
left join num_trans_in_all n_in_all on c.id_cliente = n_in_all.id_cliente
left join importo_out_all t_out_all on c.id_cliente = t_out_all.id_cliente
left join importo_in_all t_in_all on c.id_cliente = t_in_all.id_cliente
left join num_conti_tot nt on c.id_cliente = nt.id_cliente
left join num_conti_base nt_base on c.id_cliente = nt_base.id_cliente
left join num_conti_business nt_business on c.id_cliente = nt_business.id_cliente
left join num_conti_privati nt_privati on c.id_cliente = nt_privati.id_cliente 
left join num_conti_famiglie nt_famiglie on c.id_cliente = nt_famiglie.id_cliente
left join num_trans_out_base nt_out_base on c.id_cliente = nt_out_base.id_cliente
left join num_trans_out_business nt_out_business on c.id_cliente = nt_out_business.id_cliente
left join num_trans_out_privati nt_out_privati on c.id_cliente = nt_out_privati.id_cliente 
left join num_trans_out_famiglie nt_out_famiglie on c.id_cliente = nt_out_famiglie.id_cliente
left join num_trans_in_base nt_in_base on c.id_cliente = nt_in_base.id_cliente
left join num_trans_in_business nt_in_business on c.id_cliente = nt_in_business.id_cliente
left join num_trans_in_privati nt_in_privati on c.id_cliente = nt_in_privati.id_cliente
left join num_trans_in_famiglie nt_in_famiglie on c.id_cliente = nt_in_famiglie.id_cliente
left join importo_out_base t_out_base on c.id_cliente = t_out_base.id_cliente
left join importo_out_business t_out_business on c.id_cliente = t_out_business.id_cliente
left join importo_out_privati t_out_privati on c.id_cliente = t_out_privati.id_cliente
left join importo_out_famiglie t_out_famiglie on c.id_cliente = t_out_famiglie.id_cliente
left join importo_in_base t_in_base on c.id_cliente = t_in_base.id_cliente
left join importo_in_business t_in_business on c.id_cliente = t_in_business.id_cliente
left join importo_in_privati t_in_privati on c.id_cliente = t_in_privati.id_cliente
left join importo_in_famiglie t_in_famiglie on c.id_cliente = t_in_famiglie.id_cliente;


