﻿CREATE VIEW [td].[v_fact_Остатки]
AS select 
	Дата, Код_товара, Код_магазина, Код_склада_в_магазине, sum(Сумма) Сумма, sum(Сумма_закупа) Сумма_закупа, 
	sum(Сумма_закупа_со_склада) Сумма_закупа_со_склада, sum(Остаток) Остаток,
sum(Сумма) - sum(Сумма_пред) as Сумма_на_начало_дня, sum(Сумма_закупа) - sum(Сумма_закупа_пред) as Сумма_закупа_на_начало_дня,
		sum(Сумма_закупа_со_склада) - sum(Сумма_закупа_со_склада_пред) as Сумма_закупа_со_склада_на_начало_дня,
		sum(Остаток) - sum(Количество_пред) as Остаток_на_начало_дня,

	Coalesce((select top 1 Поставщик_холдинга  from dbo.t_fact_Поставщики_холдинга 
	        where dbo.t_fact_Поставщики_холдинга.Дата <= a.Дата and dbo.t_fact_Поставщики_холдинга.Код_товара = a.Код_товара  and
				dbo.t_fact_Поставщики_холдинга.Код_магазина = a.Код_магазина   
		        order by dbo.t_fact_Поставщики_холдинга.Дата desc
	    ), -1) Поставщик_холдинга,
	coalesce((select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where dbo.t_fact_Важный_товар.Код_магазина = a.Код_магазина and
				dbo.t_fact_Важный_товар.Код_товара = a.Код_товара and 
				dbo.t_fact_Важный_товар.Начало_действия >= a.Дата and dbo.t_fact_Важный_товар.Конец_действия <= a.Дата), cast(0 as bit)) Важный_товар,
	coalesce((select top 1 Сценарий from dbo.t_fact_Важный_товар where dbo.t_fact_Важный_товар.Код_магазина = a.Код_магазина and
				dbo.t_fact_Важный_товар.Код_товара = a.Код_товара and 
				dbo.t_fact_Важный_товар.Начало_действия <= a.Дата and dbo.t_fact_Важный_товар.Конец_действия >= a.Дата
				order by dbo.t_fact_Важный_товар.Начало_действия desc), -1) Сценарий_важного_товара,
    COALESCE ((SELECT TOP (1) Признак FROM td.t_fact_Товарная_матрица AS м WHERE (Дата <= a.Дата) AND 
                                                                                 (Код_товара = a.Код_товара) AND 
                                                                                 (Код_магазина = a.Код_магазина) ORDER BY Дата desc), 0) AS Признак,
     COALESCE((SELECT TOP (1) Код_поставщика FROM td.t_fact_Товарная_матрица AS м WHERE (Дата <= a.Дата) AND 
                                                                                        (Код_магазина = a.Код_магазина) AND 
                                                                                        (Код_товара = a.Код_товара) ORDER BY Дата DESC), -1) AS Код_поставщика
from 
	(select ИД_дата Дата, Начальные_остатки.Код_товара, Начальные_остатки.Код_магазина, Начальные_остатки.Код_склада_в_магазине, 
			Начальные_остатки.Сумма, Начальные_остатки.Сумма_закупа,Начальные_остатки.Сумма_закупа_со_склада, Начальные_остатки.Остаток,
			0 Сумма_пред, 0 Сумма_закупа_пред, 0 Сумма_закупа_со_склада_пред, 0 Количество_пред
	 from dbo.t_dim_Календарь
	 join td.t_fact_Начальные_остатки Начальные_остатки on eomonth(ИД_дата, -1) = Начальные_остатки.Дата 
	union all
	select ИД_дата Дата, Товародвижение.Код_товара, Товародвижение.Код_магазина, Товародвижение.Склад_в_магазине, Товародвижение.Сумма, 
			Товародвижение.СуммаЗакупа,Товародвижение.СуммаЗакупаСоСклада, Товародвижение.Количество, 
			0 Сумма_пред, 0 Сумма_закупа_пред, 0 Сумма_закупа_со_склада_пред, 0 Количество_пред
	from dbo.t_dim_Календарь
	join td.t_fact_Товародвижение Товародвижение on eomonth(ИД_дата, -1) < Товародвижение.Дата and Товародвижение.Дата <= ИД_дата
	union all
	select ИД_дата Дата, Товародвижение.Код_товара, Товародвижение.Код_магазина, Товародвижение.Склад_в_магазине, 0 Сумма, 
			0 СуммаЗакупа, 0 СуммаЗакупаСоСклада, 0 Количество, 
			Сумма Сумма_пред, СуммаЗакупа Сумма_закупа_пред, СуммаЗакупаСоСклада Сумма_закупа_со_склада_пред, Количество Количество_пред
	from dbo.t_dim_Календарь
	join td.t_fact_Товародвижение Товародвижение on Товародвижение.Дата = ИД_дата) a
group by Дата, Код_товара, Код_магазина, Код_склада_в_магазине


