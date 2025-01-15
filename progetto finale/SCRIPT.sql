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

use banca;

-- First of all let's inspect tables, wich columns they have and fields' type (use the queries below or a db-client UI):

/*
show columns from cliente;

show columns from conto;

show columns from tipo_conto;

show columns from tipo_transazione;

show columns from transazioni;
*/


-- Temporary queries:
-- customer age
/*
 *  DATEDIFF da differenza in GIORNI.
 *  Da giorni ad anno: 1 y = 365 d -> 1 d = 1/365 y e poi si arrotonda verso lo 0 (no anni bisestili)
 */

-- TODO: convertire tutte le view in temporary table (in modo da non salvarle definitivamente nel db).
-- fai questo solo come ultimo step, quando hai finito tutto (le view sono comode per ispezione tramite dbeaver).

-- TODO: rivedere le join (ad es. su id_cliente deve esserci una right join con cliente)

drop view if exists cliente_tmp;
create view cliente_tmp as 
select *,FLOOR(DATEDIFF(CURRENT_DATE(),data_nascita)/365) as eta from cliente;

select * from cliente_tmp limit 10;

-- Numero di transazioni in uscita su tutti i conti.
/**
 * qui non importa il tipo di conto, quindi le tabelle interessate sono:
 * transazioni e tipo_transazione. 
 * transazione in uscita = spesa, quindi dove tipo_transazione ha segno -
 */

drop view if exists num_trans_out;
/*
create view num_trans_out as (
	select 
	clien.id_cliente as id_cliente,
	COUNT(*) as value
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	where tipo_t.segno = '-'
	group by clien.id_cliente
	order by id_cliente asc
);
select * from num_trans_out limit 10;
*/

-- Numero di transazioni in entrata su tutti i conti.
/**
 * lo stesso di sopra ma dove segno = '+'
 */

drop view if exists num_trans_in;
/*
create view num_trans_in as (
	select
	clien.id_cliente as id_cliente,
	COUNT(*) as value
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	where tipo_t.segno = '+'
	group by clien.id_cliente
	order by id_cliente asc
);
select * from num_trans_in limit 10;
*/

-- check: if everything is fine then, in below query, same_total = 1
/*
select (
	(select value from num_trans_in) + (select value from num_trans_out)
) = (select count(*) from transazioni) as same_total;

select 12340 + 2345; -- 14685
select count(*) from transazioni t; -- 14685
*/


-- 	OPPURE UNICA VIEW
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
select * from num_trans limit 10;



-- Importo totale transato in uscita su tutti i conti.
/**
 * Qui bisogna fare sum dell'importo (tab. transazione) invece del count.
 *  
 */

drop view if exists tot_trans_out;
/*
create view tot_trans_out as (
	select
	clien.id_cliente as id_cliente,
	sum(importo) as totale
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	where tipo_t.segno = '-'
	group by clien.id_cliente
	order by id_cliente asc
);
select * from tot_trans_out limit 10;
*/

-- Importo totale transato in entrata su tutti i conti.
/**
 * Qui bisogna fare sum dell'importo (tab. transazione) invece del count.
 *  
 */

drop view if exists tot_trans_in;
/*
create view tot_trans_in as (
	select
	clien.id_cliente as id_cliente,
	sum(importo) as totale
	from transazioni t
	inner join tipo_transazione tipo_t on t.id_tipo_trans = tipo_t.id_tipo_transazione 
	inner join conto c on t.id_conto = c.id_conto 
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	where tipo_t.segno = '+'
	group by clien.id_cliente
	order by id_cliente asc
);
select * from tot_trans_in limit 10;

*/

-- 	OPPURE UNICA VIEW

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

select * from tot_trans limit 10;

-- come tabella temporanea 
/*

create temporary table tot_trans_table as (
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

select * from tot_trans_table limit 10;

*/

-- Numero totale di conti posseduti.
-- qui non importa la tipologia di conto

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

select * from num_tot_conti limit 10;


-- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto).
-- lo stesso appena fatto, ma diviso per tipo di conto

drop view if exists num_tot_conti_tipologia;
create view num_tot_conti_tipologia as (
	select 
		clien.id_cliente as id_cliente,
		tc.desc_tipo_conto as tipo,
		COUNT(c.id_conto) as num_accounts
	from conto c
	inner join tipo_conto tc on c.id_tipo_conto = tc.id_tipo_conto -- prima inner join
	inner join cliente clien on c.id_cliente = clien.id_cliente
	group by clien.id_cliente, tc.desc_tipo_conto
	order by clien.id_cliente asc
);

select * from num_tot_conti_tipologia limit 50;

-- nella view di qui sopra NON serve fare join con tipo_conto. Posso sfruttare la colonna id_tipo_conto di conto che è lo stesso della join alla fine.
select 
clien.id_cliente,
c.id_tipo_conto,
count(c.id_conto) as num_accounts
from conto c
right join cliente clien on c.id_cliente = clien.id_cliente
group by clien.id_cliente,c.id_tipo_conto
order by clien.id_cliente asc;

-- forse ci sono
select 
count(*)
from conto c
right join cliente clien on c.id_cliente = clien.id_cliente
where clien.id_cliente = 2 and c.id_tipo_conto = 1;


select 
clien.id_cliente,
count(*) as num
from conto c
right join cliente clien on c.id_cliente = clien.id_cliente
where c.id_tipo_conto = 0 -- replicare pure per gli altri valori di id_conto
group by clien.id_cliente
order by clien.id_cliente asc;

/*
 * nella tabella finale inizializzo i contatori a 0 (quando creo la tabella metto un default value a 0, oppure faccio poi un primo update)
 * POI
 * faccio un update prendendo i valori dalla select di qui sopra e così il contatore si aggiorna solo dove c'è un record.
 */



-- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto).
-- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto).
-- faccio questi due indicatori in unica view (come per il caso generale senza suddivisione per tipo conto)


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
select * from num_trans_tipologia limit 50;


-- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto).
-- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto).
-- faccio questi due indicatori in unica view (come per il caso generale senza suddivisione per tipo conto)

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

select * from tot_trans_tipologia limit 50;


/**
 * 
 * 
 * TABELLA FINALE
 * 
 * 
 */

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

insert into tab_finale (id_cliente, eta) 
	select
		id_cliente,eta
	from cliente_tmp;



-- in MySql non funziona l'update ... from (funziona in sql server)...
-- https://stackoverflow.com/questions/65877833/is-update-set-from-syntax-supported-in-mysql?noredirect=1&lq=1
/*
update tab_finale tf set tf.num_trans_out_all = t.value
from 
(	
	select n.id_cliente, n.value
	from num_trans n
	where n.tipo = 'spesa'
) as t
where tf.id_cliente = t.id_cliente; 
*/

-- si deve far un workaround tramite join
UPDATE tab_finale tf
JOIN (
    SELECT n.id_cliente, n.value
    FROM num_trans n
    WHERE n.tipo = 'spesa'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.num_trans_out_all = t.value;


UPDATE tab_finale tf
JOIN (
    SELECT n.id_cliente, n.value
    FROM num_trans n
    WHERE n.tipo = 'accredito'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.num_trans_in_all = t.value;

-- totale transazioni (importo)

UPDATE tab_finale tf
JOIN (
    SELECT tot.id_cliente, tot.totale
    FROM tot_trans tot
    WHERE tot.tipo = 'spesa'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.importo_out_all = round(t.totale,2);

UPDATE tab_finale tf
JOIN (
    SELECT tot.id_cliente, tot.totale
    FROM tot_trans tot
    WHERE tot.tipo = 'accredito'
) AS t ON tf.id_cliente = t.id_cliente
SET tf.importo_in_all = round(t.totale,2);


-- numero conti
update tab_finale tf
join (
	select id_cliente, num_accounts
	from num_tot_conti
) as t on tf.id_cliente = t.id_cliente
set tf.num_conti_tot = t.num_accounts;

-- numero conti per tipologia  num_tot_conti_tipologia

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

-- Numero di transazioni in uscita per tipologia di conto num_trans_tipologia

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

-- Numero di transazioni in entrata per tipologia di conto [num_trans_tipologia]

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

-- Importo transato in uscita per tipologia di conto [tot_trans_tipologia]

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


-- Importo transato in entrata per tipologia di conto 

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
