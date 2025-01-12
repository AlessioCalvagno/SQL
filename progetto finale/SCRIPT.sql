/*

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
		c.id_cliente as id_cliente,
		tc.desc_tipo_conto as tipo,
		COUNT(distinct c.id_conto) as num_accounts
	from conto c
	inner join cliente clien on c.id_cliente = clien.id_cliente 
	inner join tipo_conto tc on c.id_tipo_conto = tc.id_tipo_conto 
	group by id_cliente, tc.desc_tipo_conto
	order by id_cliente asc
);

select * from num_tot_conti_tipologia limit 20;

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
	end as tipo_transzione,
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









