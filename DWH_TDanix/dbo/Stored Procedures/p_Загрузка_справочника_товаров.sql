﻿CREATE PROCEDURE [dbo].[p_Загрузка_справочника_товаров]

AS
BEGIN

	SET NOCOUNT ON;

    -- 1. Создание временной таблицы
	drop table if exists #dwh_temp_товары

	create table #dwh_temp_товары (
		Код_товара                    bigint      not null,
		Менеджер_группы				  varchar(100)	  null,
		Наименование                  varchar(55) not null,
		Акцизный_Объём                float       null,
		Ассортимент                   int         null,
		Бренд                         varchar(45) null,
		Вид_Упаковки                  varchar(50) null,
		Главный_Код                   bigint      null,
		Главный_Аналог_Для_Автозаказа bigint      null,
		Дней_Годности                 int         null,
		Единиц_В_Упаковке             float       null,
		Единица_Измерения             varchar(10) null,
		Марка                         varchar(50) null,
		Собственная_Торговая_Марка    bit         null,
		Страна                        varchar(50) null,
		Страна_Производитель          varchar(50) null,
		Маркировка                    bit         null,
		Период_Грин                   bit         null,
		Гастрономия                   bit         null,
		Вид_Маркированной_Продукции   varchar(50) null,
		Категория_группы			  varchar(50) null,
		Код_Группы                    bigint      not null,
		Наименование_Группы           varchar(55) not null,
		Код_Подгруппы                 bigint      null,
		Наименование_Подгруппы        varchar(55) null,
		Торговый_зал				  bit         null,
		Производитель				  varchar(60) null
);
	
	-- 2. Загрузка из serv-term
	insert into 
		#dwh_temp_товары (
			Код_товара,
			Менеджер_группы,
			Категория_группы,
			Наименование,
			Акцизный_Объём,
			Ассортимент,
			Бренд,
			Вид_Упаковки,
			Главный_Код,
			Главный_Аналог_Для_Автозаказа,
			Дней_Годности,
			Единиц_В_Упаковке,
			Единица_Измерения,
			Марка,
			Собственная_Торговая_Марка,
			Страна,
			Страна_Производитель,
			Маркировка,
			Период_Грин,
			Гастрономия,
			Вид_Маркированной_Продукции,
			Код_Группы,
			Наименование_Группы,
			Код_Подгруппы,
			Наименование_Подгруппы,
			Торговый_зал,
			Производитель
	)select distinct 
		Товары.CODE    as Код_товара,
		
		Менеджер.Descr  as Менеджер_группы, 
		Категории.descr as Категория_группы,
		Товары.DESCR   as Наименование,
		Товары.SP3234  as Акцизный_Объём,
		Товары.SP1059  as Ассортимент,
		Бренд.DESCR    as Бренд,
		Вид_упак.DESCR as Вид_Упаковки,
		Товары.SP1678  as Главный_Код,
		Товары.CODE    as Главный_Аналог_Для_Автозаказа,
		Товары.SP1324  as Дней_Годности,
		Товары.SP886   as Единиц_В_Упаковке,
		Товары.SP15    as Единица_Измерения,
		Марка.DESCR    as Марка,
		Товары.SP2729  as Собственная_Торговая_Марка,
		Товары.SP746   as Страна,
		Страна.DESCR   as Страна_Производитель,
		Товары.SP5757  as Маркировка,
		Товары.SP6283  as Период_Грин,
		Товары.SP6320  as Гастрономия,
		Товары.SP6388  as Вид_Маркированной_Продукции,
		
		cast(
			case
				when Товары_4.CODE is not null
				then Товары_4.CODE
				else Товары_3.CODE
			end as bigint) as Код_Группы,
		cast(
			case
				when Товары_4.CODE is not null
				then Товары_4.DESCR
				else Товары_3.DESCR
			end as varchar(55)) as Наименование_Группы,
		cast(
			case
				when Товары_4.CODE is not null
				then Товары_3.CODE
				else Товары_4.CODE
			end as bigint) as Код_Подгруппы,
		cast(
			case 
				when Товары_4.DESCR is not null
				then Товары_3.DESCR
				else NULL
			end as varchar(55)) as Наименование_Подгруппы,
			Товары.SP3095 as Торговый_зал,
			Производители.DESCR as Производитель
		from 
			[Rozn].[rozn].[dbo].[SC11]   as Товары   (nolock)
		left join 
			[Rozn].[rozn].[dbo].[SC2722] as Бренд    (nolock) on Бренд.ID      = Товары.SP2724
		
		left join 
			[Rozn].[rozn].[dbo].[SC1341] as Вид_упак (nolock) on Вид_упак.ID   = Товары.SP1344
		left join 
			[Rozn].[rozn].[dbo].[SC11]   as Товары_2 (nolock) on Товары_2.ID   = Товары.SP2938
		left join 
			[Rozn].[rozn].[dbo].[SC1626] as Марка    (nolock) on Марка.ID      = Товары.SP1624
		left join 
			[Rozn].[rozn].[dbo].[SC3366] as Страна   (nolock) on Страна.ID     = Товары.SP3368
		left join 
			[Rozn].[rozn].[dbo].[SC11]   as Товары_3 (nolock) on Товары_3.[ID] = Товары.[PARENTID]
		left join 
			[Rozn].[rozn].[dbo].[SC11]   as Товары_4 (nolock) on Товары_4.[ID] = Товары_3.[PARENTID]
		left join
			Rozn.rozn.dbo.SC36 as Менеджер (nolock) on Менеджер.ID=case
				when Товары_4.CODE is not null
				then Товары_4.SP1404
				else Товары_3.SP1404
			end 
		left join 
			[Rozn].[rozn].[dbo].[SC5818] as Группы (nolock) on Группы.SP5816=
			case
				when Товары_4.CODE is not null
				then Товары_4.ID
				else Товары_3.ID
			end 
				and Группы.ismark=0 
		left join
			[Rozn].[rozn].[dbo].[SC5815] as Категории (nolock) on Категории.id=Группы.parentext
		left join [Rozn].[rozn].[dbo].SC1337 Производители (nolock) on Производители.id=Товары.SP1343
			where 
			Товары.ISFOLDER = 2 and Товары.[PARENTID] is not null and cast(Товары.CODE as bigint) between 1 and     999999998;

	-- 3. Слияние таблиц
	merge 
		dbo.t_dim_Товары
	using 
		#dwh_temp_товары
	on 
		dbo.t_dim_Товары.Код_товара = #dwh_temp_товары.Код_товара
	when 
		matched 
	then 
		update 
	set 
		dbo.t_dim_Товары.Наименование                  = #dwh_temp_товары.Наименование,
		dbo.t_dim_Товары.Акцизный_Объём                = #dwh_temp_товары.Акцизный_Объём,
		dbo.t_dim_Товары.Ассортимент                   = #dwh_temp_товары.Ассортимент,
		dbo.t_dim_Товары.Бренд                         = #dwh_temp_товары.Бренд,
		dbo.t_dim_Товары.Вид_Упаковки                  = #dwh_temp_товары.Вид_Упаковки,
		dbo.t_dim_Товары.Главный_Код                   = #dwh_temp_товары.Главный_Код,
		dbo.t_dim_Товары.Главный_Аналог_Для_Автозаказа = #dwh_temp_товары.Главный_Аналог_Для_Автозаказа,
		dbo.t_dim_Товары.Дней_Годности                 = #dwh_temp_товары.Дней_Годности,
		dbo.t_dim_Товары.Единиц_В_Упаковке             = #dwh_temp_товары.Единиц_В_Упаковке,
		dbo.t_dim_Товары.Единица_Измерения             = #dwh_temp_товары.Единица_Измерения,
		dbo.t_dim_Товары.Марка                         = #dwh_temp_товары.Марка,
		dbo.t_dim_Товары.Собственная_Торговая_Марка    = #dwh_temp_товары.Собственная_Торговая_Марка,
		dbo.t_dim_Товары.Страна                        = #dwh_temp_товары.Страна,
		dbo.t_dim_Товары.Страна_Производитель          = #dwh_temp_товары.Страна_Производитель,
		dbo.t_dim_Товары.Маркировка                    = #dwh_temp_товары.Маркировка,
		dbo.t_dim_Товары.Период_Грин                   = #dwh_temp_товары.Период_Грин,
		dbo.t_dim_Товары.Гастрономия                   = #dwh_temp_товары.Гастрономия,
		dbo.t_dim_Товары.Вид_Маркированной_Продукции   = #dwh_temp_товары.Вид_Маркированной_Продукции,
		dbo.t_dim_Товары.Категория_группы			   = #dwh_temp_товары.Категория_группы,
		dbo.t_dim_Товары.Код_Группы                    = #dwh_temp_товары.Код_Группы,
		dbo.t_dim_Товары.Наименование_Группы           = #dwh_temp_товары.Наименование_Группы,
		dbo.t_dim_Товары.Код_Подгруппы                 = #dwh_temp_товары.Код_Подгруппы,
		dbo.t_dim_Товары.Наименование_Подгруппы        = #dwh_temp_товары.Наименование_Подгруппы,
		dbo.t_dim_Товары.Менеджер_группы			   = #dwh_temp_товары.Менеджер_группы,
		dbo.t_dim_Товары.Торговый_зал				   = #dwh_temp_товары.Торговый_зал,
		dbo.t_dim_Товары.Производитель				   = #dwh_temp_товары.Производитель
	when 
		not matched
	then 
		insert values(
			#dwh_temp_товары.Код_товара, 
			#dwh_temp_товары.Наименование,
			#dwh_temp_товары.Акцизный_Объём, 
			#dwh_temp_товары.Ассортимент,
			#dwh_temp_товары.Бренд, 
			#dwh_temp_товары.Вид_Упаковки,
			#dwh_temp_товары.Главный_Код,
			#dwh_temp_товары.Главный_Аналог_Для_Автозаказа,
			#dwh_temp_товары.Дней_Годности,
			#dwh_temp_товары.Единиц_В_Упаковке,
			#dwh_temp_товары.Единица_Измерения,
			#dwh_temp_товары.Марка,
			#dwh_temp_товары.Собственная_Торговая_Марка,
			#dwh_temp_товары.Страна,
			#dwh_temp_товары.Страна_Производитель, 
			#dwh_temp_товары.Маркировка,
			#dwh_temp_товары.Период_Грин,
			#dwh_temp_товары.Гастрономия,
			#dwh_temp_товары.Вид_Маркированной_Продукции,
			#dwh_temp_товары.Категория_группы,
			#dwh_temp_товары.Код_Группы,
			#dwh_temp_товары.Наименование_Группы,
			#dwh_temp_товары.Код_Подгруппы,
			#dwh_temp_товары.Наименование_Подгруппы,
			#dwh_temp_товары.Менеджер_группы,
			#dwh_temp_товары.Торговый_зал,
			#dwh_temp_товары.Производитель
		);
END