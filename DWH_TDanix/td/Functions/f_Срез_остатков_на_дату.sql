﻿-- =============================================
-- Author:		kma1860
-- Create date: 27/10/2022
-- Description:	Возвращает срез остатков на выбранную дату
-- =============================================
CREATE FUNCTION [td].[f_Срез_остатков_на_дату]
(	
	@Дата date 
)
RETURNS TABLE 
AS
RETURN 
(
	select
		@Дата дата, Код_магазина, Код_склада_в_магазине, Код_товара, sum(Сумма) Сумма, sum(Сумма_закупа) Сумма_закупа, sum(Сумма_закупа_со_склада) Сумма_закупа_со_склада, sum(Остаток) Остаток,
		sum(Сумма) - sum(Сумма_пред) as Сумма_на_начало_дня, sum(Сумма_закупа) - sum(Сумма_закупа_пред) as Сумма_закупа_на_начало_дня,
		sum(Сумма_закупа_со_склада) - sum(Сумма_закупа_со_склада_пред) as Сумма_закупа_со_склада_на_начало_дня,
		sum(Остаток) - sum(Количество_пред) as Остаток_на_начало_дня,
        -- Не будем выводить null, чтобы не генерировать ошибку при обработке куба
        Coalesce((select top 1 Поставщик_холдинга from dbo.t_fact_Поставщики_холдинга 
	        where dbo.t_fact_Поставщики_холдинга.Код_магазина = Код_магазина 
		        and dbo.t_fact_Поставщики_холдинга.Код_товара = Код_товара 
		        and dbo.t_fact_Поставщики_холдинга.Дата <= @Дата order by dbo.t_fact_Поставщики_холдинга.Дата desc
	    ), '(Не задан)') Поставщик_холдинга,
		-- Временная заглушка
		cast(0 as bit) Важный_товар
	from (
		select
			ib_f.Код_магазина, ib_f.Код_склада_в_магазине, ib_f.Код_товара, ib.Сумма, ib.Сумма_закупа, ib.Сумма_закупа_со_склада, ib.Остаток,
			0 Сумма_пред, 0 Сумма_закупа_пред, 0 Сумма_закупа_со_склада_пред, 0 Количество_пред
		from
			td.t_fact_Начальные_остатки ib
		right join (
			select
				max(ib_f.Дата) Дата,
				ib_f.Код_Товара,
				ib_f.Код_магазина,
				ib_f.Код_склада_в_магазине
			from
				td.t_fact_Начальные_остатки ib_f
			where
				ib_f.Дата = dateadd(day, -1, dateFromParts(year(@Дата), month(@Дата), 1))
			group by 
				ib_f.Код_товара, ib_f.Код_магазина, ib_f.Код_склада_в_магазине
		) ib_f on ib.Дата = ib_f.Дата and ib.Код_товара = ib_f.Код_товара and ib.Код_магазина = ib_f.Код_магазина and ib.Код_склада_в_магазине = ib_f.Код_склада_в_магазине
		union all
		select
			Код_магазина, Склад_в_магазине, Код_товара, Сумма, СуммаЗакупа, СуммаЗакупаСоСклада, Количество,
			0 Сумма_пред, 0 Сумма_закупа_пред, 0 Сумма_закупа_со_склада_пред, 0 Количество_пред
		from
			td.t_fact_Товародвижение
		where
			Дата <= @Дата and Дата > dateadd(day, -1, dateFromParts(year(@Дата), month(@Дата), 1))
		union all
		Select
			Код_магазина, Склад_в_магазине, Код_товара, 0 Сумма, 0 СуммаЗакупа, 0 СуммаЗакупаСоСклада, 0 Количество,
			Сумма Сумма_пред, СуммаЗакупа Сумма_закупа_пред, СуммаЗакупаСоСклада Сумма_закупа_со_склада_пред, Количество Количество_пред
		from
			td.t_fact_Товародвижение
		where
			Дата = @Дата
	) о
	group by Код_магазина, Код_склада_в_магазине, Код_товара
)
