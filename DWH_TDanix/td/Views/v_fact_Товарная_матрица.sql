CREATE VIEW [td].[v_fact_Товарная матрица]
	AS
	select
	ИД_дата Дата,
	t_m.Код_магазина,
	t_t.Код_товара,
	(
		select top 1 Признак
		from
			td.t_fact_Товарная_матрица ТовМат
		where
			ТовМат.Дата <= Дата and
			ТовМат.Код_магазина = t_m.Код_магазина and
			ТовМат.Код_товара = t_t.Код_товара 
			
			
	) Признак,
	(
		select top 1 Код_поставщика
		from
			td.t_fact_Товарная_матрица ТовМат
		where
			ТовМат.Дата <= Дата and
			ТовМат.Код_магазина = t_m.Код_магазина and
			ТовМат.Код_товара = t_t.Код_товара 
			
			
	) Код_поставщика
from
	dbo.t_dim_Календарь 
cross join
	(select distinct Код_магазина from td.t_fact_Товарная_матрица) as t_m
cross join
	(select distinct Код_товара from td.t_fact_Товарная_матрица) as t_t
		
