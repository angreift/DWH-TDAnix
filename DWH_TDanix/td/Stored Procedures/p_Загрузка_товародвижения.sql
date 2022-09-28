﻿-- =============================================
-- Author:		kma1860
-- Create date: 27/09/2022
-- Description:	Загрузка данных о товародвижении из CS
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_товародвижения]
@Количество_дней int = 60
AS
BEGIN
	set noCount on;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для заиписи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	-- 1. АКТЫ СПИСАНИЯ

	drop table if exists [td].t_raw_Товародвижение_АС;
	create table [td].t_raw_Товародвижение_АС (
		Склад               nvarchar(100),
		Код_причины         tinyint,
		Сумма               decimal(14, 2),
		СуммаЗакупа         decimal(14, 2),
		СуммаЗакупаСоСклада decimal(14, 2),
		Цена                decimal(14, 2),
		ЦенаЗакупа          decimal(14, 2),
		ЦенаЗакупаСоСклада  decimal(14, 2),
		Количество          decimal(14, 3),
		КодТовара           bigint,
		Дата                date,
		Код_магазина        int,
		Номер               int
	) ON RAW

	declare @dateStart date, @dateEnd date, @Query nvarchar(max);
	set @dateEnd   = cast(getDate() as date);
	set @dateStart = dateAdd(day, -@Количество_дней, @dateEnd);
	set @Query = '
		SELECT 
			[Склад],[КодПричины], [СуммаЗакупаСоСклада], [СуммаЗакупа], [Сумма], [ЦенаЗакупаСоСклада], [ЦенаЗакупа], [Цена], [Ед], [КодТовара], [Дата], [КодМагазина], [Номер]
		FROM OPENQUERY ([S19-STORAGE-SQL], ''
			SELECT
				[Склад],[КодПричины], [СуммаЗакупаСоСклада], [СуммаЗакупа], [Сумма], [ЦенаЗакупаСоСклада], [ЦенаЗакупа], [Цена], [Ед], [КодТовара], [Дата], [КодМагазина], [Номер]
			FROM
				[CS].[dbo].[Факт_АктСписания]
			WHERE
				ДАТА BETWEEN ''''' + format(@dateStart, 'yyyyMMdd') + ''''' and ''''' + format(@dateEnd, 'yyyyMMdd') + ''''''')
	';

	
	insert into [td].t_raw_Товародвижение_АС exec(@Query); -- Получаем локальную копию сырых данных на наш сервер

	begin tran td_load_AS
	begin try
		merge 
			[td].t_dim_Склад_в_магазине a
		using
			(select distinct Склад from [td].t_raw_Товародвижение_АС) [raw] on a.Наименование_склада = b.Склад
		when not matched then 
			insert (Наименование_склада) values ([raw].Склад);

		delete from [td].t_fact_Товародвижение where Дата between @dateStart and @dateEnd and ВидДвижения = 1

		insert into [td].t_fact_Товародвижение (
			[Составной_код_документа], [Дата], [Код_магазина], [Склад_в_магазине], [ВидДвижения], [Код_товара], [Сумма], [СуммаЗакупа], [СуммаЗакупаСоСклада], 
			[Цена], [ЦенаЗакупа], [ЦенаЗакупаСоСклада], [Количество], [Код_причины]
		) select
			cast([Код_магазина] as nvarchar) + '[АС]' + cast([Номер] as nvarchar),
			[Дата], [Код_магазина], (select Код_склада from [td].t_dim_Склад_в_магазине where Наименование_склада = [Склад]), 1, [КодТовара], [Сумма], [СуммаЗакупа], 
			[СуммаЗакупаСоСклада], [Цена], [ЦенаЗакупа], [ЦенаЗакупаСоСклада], [Количество], [Код_причины]
		from
			[td].t_raw_Товародвижение_АС
	end try
	begin catch
		rollback tran td_load_AS
		set @msg = concat('[Товародвижение] Не удалось загрузить акты списания. Ошибка: ', error_message());
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
	end catch

	-- 2. ИНВЕНТАРИЗАЦИИ

	drop table if exists [td].t_raw_Товародвижение_ИНВ;
	create table [td].t_raw_Товародвижение_ИНВ (
		Склад               nvarchar(100),
		Код_причины         int,
		Сумма               decimal(14, 2),
		СуммаЗакупа         decimal(14, 2),
		СуммаЗакупаСоСклада decimal(14, 2),
		Цена                decimal(14, 2),
		ЦенаЗакупа          decimal(14, 2),
		ЦенаЗакупаСоСклада  decimal(14, 2),
		Количество          decimal(14, 3),
		КодТовара           bigint,
		Дата                date,
		Код_магазина        int,
		Номер               int
	) ON RAW

	set @Query = '
		SELECT 
			[Склад], [КодПричины], [СуммаЗакупаСоСклада], [СуммаЗакупа], [Сумма], [ЦенаЗакупаСоСклада], [ЦенаЗакупа], [Цена], [Ед], [КодТовара], [Дата], [КодМагазина], [Номер]
		FROM OPENQUERY ([S19-STORAGE-SQL], ''
			SELECT
				[Склад], [Причина] as [КодПричины], [Р_СуммаЗакупаСоСклада] as [СуммаЗакупаСоСклада], [Р_СуммаЗакупа] as [СуммаЗакупа], [СР] as [Сумма], 
				[Р_СуммаЗакупаСоСклада] / [Разница] as [ЦенаЗакупаСоСклада], [ЦенаЗакупа], [Цена], [Разница], [КодТовара], [Дата], [КодМагазина], [Номер]
			FROM
				[CS].[dbo].[Факт_Инвентаризация]
			WHERE
				ДАТА BETWEEN ''''' + format(@dateStart, 'yyyyMMdd') + ''''' and ''''' + format(@dateEnd, 'yyyyMMdd') + ''''''')
	';

	
	insert into [td].t_raw_Товародвижение_ИНВ exec(@Query); -- Получаем локальную копию сырых данных на наш сервер

	begin tran td_load_AS
	begin try
		merge 
			[td].t_dim_Склад_в_магазине a
		using
			(select distinct Склад from [td].t_raw_Товародвижение_ИНВ) [raw] on a.Наименование_склада = b.Склад
		when not matched then 
			insert (Наименование_склада) values ([raw].Склад);

		delete from [td].t_fact_Товародвижение where Дата between @dateStart and @dateEnd and ВидДвижения = 2

		insert into [td].t_fact_Товародвижение (
			[Составной_код_документа], [Дата], [Код_магазина], [Склад_в_магазине], [ВидДвижения], [Код_товара], [Сумма], [СуммаЗакупа], [СуммаЗакупаСоСклада], 
			[Цена], [ЦенаЗакупа], [ЦенаЗакупаСоСклада], [Количество], [Код_причины]
		) select
			cast([Код_магазина] as nvarchar) + '[ИНВ]' + cast([Номер] as nvarchar),
			[Дата], [Код_магазина], (select Код_склада from [td].t_dim_Склад_в_магазине where Наименование_склада = [Склад]), 2, [КодТовара], [Сумма], [СуммаЗакупа], 
			[СуммаЗакупаСоСклада], [Цена], [ЦенаЗакупа], [ЦенаЗакупаСоСклада], [Количество], [Код_причины]
		from
			[td].t_raw_Товародвижение_ИНВ
	end try
	begin catch
		rollback tran td_load_AS
		set @msg = concat('[Товародвижение] Не удалось загрузить Инвентаризации. Ошибка: ', error_message());
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
	end catch
END