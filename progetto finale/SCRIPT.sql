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
 * 1. nella prima parte sono definite delle viste (view) che servono da supporto per il caricamento dei record nella tabella finale
 * 	orientativamente vi è una vista per indicatore.
 * 2. nella seconda parte si crea la tabella finale (tab_finale) che contiene le fetaures richieste.
 * 
 * In ogni caso si rimanda ai commenti delle varie sezioni per ulteriori dettagli.
 * 
 * Nonostante le viste siano preservate nel database, anche dopo la disconnessione, questo script può essere lanciato diverse volte,
 * producendo sempre lo stesso risultato in quanto ad ogni run le viste precedentemente ottenute verranno eliminate (tramite drop) e create nuovamente.
 * Si adottano delle viste piuttosto che delle tabelle temporanee, in modo che i risultati parziali siano conservati anche in riconnessioni successive,
 * per eventuali analisi parziali aggiuntive (le tabelle temporanee verrebbero eliminate alla disconnessione dal database).
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
 * 	Per comodità nella vista si includono anche gli altri campi dei clienti (utile per ispezione tramite client).
 */

drop view if exists cliente_tmp;
create view cliente_tmp as 
select *,FLOOR(DATEDIFF(CURRENT_DATE(),data_nascita)/365) as eta from cliente;

-- check
select * from cliente_tmp limit 10;

-- Numero di transazioni in uscita su tutti i conti.
-- Numero di transazioni in entrata su tutti i conti.

/**
 * Si costruisce unica vista dove le transazioni in uscita sono identificate dal campo tipo = 'spesa' 
 * e quelle in entrata con tipo = 'accredito'.
 */

drop view if exists num_trans;
create view num_trans as (
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
 * Anche qui si costruisce un'unica vista con la stessa logica della vista precedente 
 * (in uscita -> tipo = 'spesa', in entrata -> tipo = 'accredito').
 */

drop view if exists tot_trans;
create view tot_trans as (
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

drop view if exists num_tot_conti;
create view num_tot_conti as (
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
 * Questa vista è simile a quella appena precedente, ma si inserisce un ulteriore raggruppamento per tipo di conto.
 */

drop view if exists num_tot_conti_tipologia;
create view num_tot_conti_tipologia as (
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

drop view if exists num_trans_tipologia;
create view num_trans_tipologia as (
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
 * Basandosi sulla stessa logica delle altre viste, anche qui si fa un'unica vista per questi due contatori,
 * sfruttando il raggruppamento dei record in base alla tipologia di conto e di transazione 
 * (in uscita ->  tipo_transazione = 'spesa', in entrata -> tipo_transazione = 'accredito').
 */

drop view if exists tot_trans_tipologia;
create view tot_trans_tipologia as (
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
 * In termini tecnici inizialmente si esegue una insert pescando i dati dalla prima view calcolata, in modo che le colonne dalla terza in poi siano 
 * inizializzate con i valori di default, e successivamente si eseguono una serie di update, dove in ogni update si aggiorna il valore di una colonna
 * specifica usando la vista appropriata. 
 * 
 * Nota importante:
 * Ispezionando le viste create nella parte 1, si può vedere come non tutti gli id_cliente siano presenti:
 * ad esempio nella vista 'num_tot_conti' non è presente id_cliente = 0, in quanto tale cliente non ha conti associati e pertanto viene filtrato
 * dalle (inner) join eseguite nella definizione della vista. 
 * 
 * Poichè è richiesto di fornire un record per ogni cliente registrato (anche senza conti e transazioni associati), si usa questo workaround: 
 * nella tabella finale si inizializzano i contatori a 0 e poi con i successivi update i contatori si aggiorneranno solo dove c'è un valore diverso da 0.
 * Il risultato finale sarà che nella tabella sono presenti tutti i clienti, ma quelli non presenti nelle viste manterranno il valore di default 0 
 * (che corrisponde con il valore atteso in questi casi per la natura dei contatori), mentre tutti gli altri avranno il valore assegnato dall'update.
 * Questo discorso NON si applica all'età del cliente, che invece prevede sempre un valore inserito.
 */

-- per il significato delle singole colonne si rimanda agli update sottostanti dove viene sempre indicato con un commento quale indicatore si sta calcolando.
drop table if exists tab_finale;
create table tab_finale (
id_cliente int not null,
eta int,
num_trans_out_all int default 0,
num_trans_in_all int default 0,
importo_out_all double default 0.0,
importo_in_all double default 0.0,
num_conti_tot int default 0,
num_conti_base int default 0,
num_conti_business int default 0,
num_conti_privati int default 0,
num_conti_famiglie int default 0,
num_trans_out_base int default 0,
num_trans_out_business int default 0,
num_trans_out_privati int default 0,
num_trans_out_famiglie int default 0,
num_trans_in_base int default 0,
num_trans_in_business int default 0,
num_trans_in_privati int default 0,
num_trans_in_famiglie int default 0,
importo_out_base double default 0.0,
importo_out_business double default 0.0,
importo_out_privati double default 0.0,
importo_out_famiglie double default 0.0,
importo_in_base double default 0.0,
importo_in_business double default 0.0,
importo_in_privati double default 0.0,
importo_in_famiglie double default 0.0
);

-- Età del cliente e id_cliente

/**
 * Tramite questa insert vengono creati i record per la prima volta e quindi vengono anche inizializzati gli altri contatori al valore di default.
 */
insert into tab_finale (id_cliente, eta) 
	select
		id_cliente,eta
	from cliente_tmp;

/**
 * NOTA TECNICA
 * Gli update sottostanti dovrebbero essere eseguiti con la logica dell' UPDATE ... SET ... FROM in modo da prendere i valori da 
 * una suquery eseguita nel from. 
 * Esempio:
 *
 *	update tab_finale tf set tf.num_trans_out_all = t.value
 *	from 
 *	(	
 *		select n.id_cliente, n.value
 *		from num_trans n
 *		where n.tipo = 'spesa'
 *	) as t
 *	where tf.id_cliente = t.id_cliente; 
 * 
 * Tuttavia questa sintassi non è supportata dall'engine MySql qui utilizzato (funziona invece in SQL server).
 * In MySql è possibile ottenere lo stesso risultato utilizzando un workaround facendo l'update su una join.
 * Per altri dettagli si veda: https://stackoverflow.com/questions/65877833/is-update-set-from-syntax-supported-in-mysql?noredirect=1&lq=1
 * 
 * NOTA SU POSSIBILI WARNING DA PARTE DEL CLIENT
 * Alcuni client (come DBeaver) possono presentare un warning poichè si esegue un update senza clausola where; si possono eseguire le query
 * senza problemi in quanto qui il filtro sull'update è applicato implicitamente dalla (inner) join.
 * 
 */

-- le join sottostanti sono da intendersi come inner join (default di MySql)

--  Numero di transazioni in uscita su tutti i conti

UPDATE tab_finale tf
JOIN (
    SELECT n.id_cliente, n.value
    FROM num_trans n
    WHERE n.tipo = 'spesa'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.num_trans_out_all = t.value;

-- Numero di transazioni in entrata su tutti i conti

UPDATE tab_finale tf
JOIN (
    SELECT n.id_cliente, n.value
    FROM num_trans n
    WHERE n.tipo = 'accredito'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.num_trans_in_all = t.value;

-- Importo totale transato in uscita su tutti i conti

UPDATE tab_finale tf
JOIN (
    SELECT tot.id_cliente, tot.totale
    FROM tot_trans tot
    WHERE tot.tipo = 'spesa'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.importo_out_all = round(t.totale,2);

-- Importo totale transato in entrata su tutti i conti

UPDATE tab_finale tf
JOIN (
    SELECT tot.id_cliente, tot.totale
    FROM tot_trans tot
    WHERE tot.tipo = 'accredito'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.importo_in_all = round(t.totale,2);

-- Numero totale di conti posseduti

update tab_finale tf
join (
	select id_cliente, num_accounts
	from num_tot_conti
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_tot = t.num_accounts;

--  Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto)

-- base
update tab_finale tf 
join (
	select n.id_cliente, n.num_accounts
	from num_tot_conti_tipologia n
	where n.tipo like '%Base%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_base = t.num_accounts;

-- business
update tab_finale tf 
join (
	select n.id_cliente, n.num_accounts
	from num_tot_conti_tipologia n
	where n.tipo like '%Business%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_business = t.num_accounts;

-- privati
update tab_finale tf 
join (
	select n.id_cliente, n.num_accounts
	from num_tot_conti_tipologia n
	where n.tipo like '%Privati%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_privati = t.num_accounts;

-- famiglie
update tab_finale tf 
join (
	select n.id_cliente, n.num_accounts
	from num_tot_conti_tipologia n
	where n.tipo like '%Famiglie%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_famiglie = t.num_accounts;

-- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto)

-- base
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'spesa' and n.tipo_conto like '%Base%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_out_base = t.num_transazioni;

-- business
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'spesa' and n.tipo_conto like '%Business%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_out_business = t.num_transazioni;

-- privati
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'spesa' and n.tipo_conto like '%Privati%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_out_privati = t.num_transazioni;


-- famiglie
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'spesa' and n.tipo_conto like '%Famiglie%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_out_famiglie = t.num_transazioni;

-- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto)

-- base
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'accredito' and n.tipo_conto like '%Base%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_in_base = t.num_transazioni;

-- business
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'accredito' and n.tipo_conto like '%Business%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_in_business = t.num_transazioni;

-- privati
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'accredito' and n.tipo_conto like '%Privati%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_in_privati = t.num_transazioni;


-- famiglie
update tab_finale tf
join (
	select n.id_cliente, n.num_transazioni
	from num_trans_tipologia n
	where n.tipo_transazione = 'accredito' and n.tipo_conto like '%Famiglie%'
) as t on tf.id_cliente = t.id_cliente
set tf.num_trans_in_famiglie = t.num_transazioni;

-- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto)

-- base
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'spesa' and tot.tipo_conto like '%Base%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_out_base  = round(t.totale,2);

-- business
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'spesa' and tot.tipo_conto like '%Business%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_out_business = round(t.totale,2);

-- privati
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'spesa' and tot.tipo_conto like '%Privati%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_out_privati  = round(t.totale,2);

-- famiglie
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'spesa' and tot.tipo_conto like '%Famiglie%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_out_famiglie = round(t.totale,2);


-- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto)

-- base
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'accredito' and tot.tipo_conto like '%Base%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_in_base  = round(t.totale,2);

-- business
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'accredito' and tot.tipo_conto like '%Business%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_in_business = round(t.totale,2);

-- privati
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'accredito' and tot.tipo_conto like '%Privati%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_in_privati  = round(t.totale,2);

-- famiglie
update tab_finale tf
join (
	select tot.id_cliente, tot.totale
	from tot_trans_tipologia tot
	where tot.tipo_transazione = 'accredito' and tot.tipo_conto like '%Famiglie%'
) as t on tf.id_cliente = t.id_cliente
set tf.importo_in_famiglie = round(t.totale,2);
