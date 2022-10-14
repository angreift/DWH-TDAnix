-- =============================================
-- Author:		kma1860
-- Create date: 22/08/2022
-- Description:	Загрузка справочника магазинов из s19-storage-sql
-- =============================================
CREATE PROCEDURE dbo.p_Загрузка_справочника_магазинов

AS
BEGIN

	SET NOCOUNT ON;

    -- 1. Создание временной таблицы
	drop table if exists #dwh_temp_магазины

	create table #dwh_temp_магазины (
		Код                       int           NOT NULL, 
		Группа                    nvarchar(50)  NOT NULL,
		Наименование              nvarchar(100) NOT NULL, 
		Адрес                     nvarchar(300) NULL,
		Город                     nvarchar(50)  NULL, 
		График_ПРАЙД              tinyint       NULL,
		Дата_Закрытия             datetime      NULL, 
		Дата_Открытия             datetime      NULL,
		ИНН                       nvarchar(30)  NULL, 
		Категория_По_Площади      tinyint       NULL,
		КПП                       nvarchar(30)  NULL, 
		Куст                      nvarchar(50)  NULL,
		Ответственный             nvarchar(50)  NULL,
		Отчёт                     bit           NULL,
		Регион                    nvarchar(50)  NULL,
		Дата_Начала_Реконструкции datetime      NULL,
		Дата_Конца_Реконструкции  datetime      NULL, 
		Бренд_Магазина            nvarchar(50)  NULL,
		Технолог_СП               nvarchar(50)  NULL
);


	-- 2. Загрузка из serv-term
	insert into #dwh_temp_магазины (
		Код, Группа, Наименование, Адрес, Город, График_ПРАЙД, Дата_Закрытия, Дата_Открытия, ИНН, Категория_По_Площади, КПП, Куст, Ответственный, Отчёт,
		Регион, Дата_Начала_Реконструкции, Дата_Конца_Реконструкции, Бренд_Магазина, Технолог_СП
	) select
		Магазины.[CODE]         as Код,
		Магазины_2.[DESCR]      as Группа,
		Магазины.[DESCR]        as Наименование,
		case when ltrim(rtrim(Магазины.[SP40])) = '' then NULL else Магазины.[SP40] end as Адрес,
		Города.[DESCR]          as Город,
		Магазины.[SP2009]       as График_ПРАЙД,
		Магазины.[SP4225]       as Дата_Закрытия,
		Магазины.[SP2843]       as Дата_Открытия,
		Магазины.[SP44]         as ИНН,
		Магазины.[SP2424]       as Категория_По_Площади,
		case when cast(Магазины.[SP2160] as int) = 0 then NULL else cast(Магазины.[SP2160] as int) end as КПП,
		Кусты.[DESCR]           as Куст,
		Магазины.[SP38]         as Ответственный,
		Магазины.[SP1155]       as Отчёт,
		Регионы.[DESCR]         as Регион,
		Магазины.[SP4570]       as Дата_Начала_Реконструкции,
		Магазины.[SP4571]       as Дата_Конца_Реконструкции,
		Брэнды_Магазина.[DESCR] as Бренд_Магазина,
		case when ltrim(rtrim(Магазины.[SP6401])) = '' then NULL else Магазины.[SP6401] end as Технолог_СП
	FROM 
		[Rozn].[rozn].[dbo].[SC36]   as Магазины        (nolock)
	left join 
		[Rozn].[rozn].[dbo].[SC36]   as Магазины_2      (nolock) on Магазины_2.[ID]      = Магазины.[PARENTID]
	left join 
		[Rozn].[rozn].[dbo].[SC26]   as Города          (nolock) on Магазины.[SP39]      = Города.[ID]
	left join 
		[Rozn].[rozn].[dbo].[SC3651] as Кусты           (nolock) on Кусты.[ID]           = Магазины.[SP3654]
	left join 
		[Rozn].[rozn].[dbo].[SC2400] as Регионы         (nolock) on Регионы.[ID]         = Магазины.[SP2222]
	left join 
		[Rozn].[rozn].[dbo].[SC4948] as Брэнды_Магазина (nolock) on Брэнды_Магазина.[ID] = Магазины.[SP4935]
	where 
		Магазины_2.[ID] in ('     1   ', '    EP   ', '  1FBI   ', '  1FBH   ');

	-- 3. Слияние таблиц
	merge 
		[dbo].t_dim_Магазины
	using 
		#dwh_temp_магазины
	on 
		[dbo].t_dim_Магазины.Код = #dwh_temp_магазины.Код
	when 
		matched 
	then 
		update 
	set 
		[dbo].t_dim_Магазины.Группа                    = #dwh_temp_магазины.Группа,
		[dbo].t_dim_Магазины.Наименование              = #dwh_temp_магазины.Наименование,
		[dbo].t_dim_Магазины.Адрес                     = #dwh_temp_магазины.Адрес,
		[dbo].t_dim_Магазины.Город                     = #dwh_temp_магазины.Город,
		[dbo].t_dim_Магазины.График_ПРАЙД              = #dwh_temp_магазины.График_ПРАЙД,
		[dbo].t_dim_Магазины.Дата_Закрытия             = #dwh_temp_магазины.Дата_Закрытия,
		[dbo].t_dim_Магазины.Дата_Открытия             = #dwh_temp_магазины.Дата_Открытия,
		[dbo].t_dim_Магазины.ИНН                       = #dwh_temp_магазины.ИНН,
		[dbo].t_dim_Магазины.Категория_По_Площади      = #dwh_temp_магазины.Категория_По_Площади,
		[dbo].t_dim_Магазины.КПП                       = #dwh_temp_магазины.КПП,
		[dbo].t_dim_Магазины.Куст                      = #dwh_temp_магазины.Куст,
		[dbo].t_dim_Магазины.Ответственный             = #dwh_temp_магазины.Ответственный,
		[dbo].t_dim_Магазины.Отчёт                     = #dwh_temp_магазины.Отчёт,
		[dbo].t_dim_Магазины.Регион                    = #dwh_temp_магазины.Регион,
		[dbo].t_dim_Магазины.Дата_Начала_Реконструкции = #dwh_temp_магазины.Дата_Начала_Реконструкции,
		[dbo].t_dim_Магазины.Дата_Конца_Реконструкции  = #dwh_temp_магазины.Дата_Конца_Реконструкции,
		[dbo].t_dim_Магазины.Бренд_Магазина            = #dwh_temp_магазины.Бренд_Магазина,
		[dbo].t_dim_Магазины.Технолог_СП               = #dwh_temp_магазины.Технолог_СП
	when 
		not matched
	then 
		insert values(
			#dwh_temp_магазины.Код, 
			#dwh_temp_магазины.Группа,
			#dwh_temp_магазины.Наименование, 
			#dwh_temp_магазины.Адрес,
			#dwh_temp_магазины.Город, 
			#dwh_temp_магазины.График_ПРАЙД,
			#dwh_temp_магазины.Дата_Закрытия, 
			#dwh_temp_магазины.Дата_Открытия,
			#dwh_temp_магазины.ИНН, 
			#dwh_temp_магазины.Категория_По_Площади,
			#dwh_temp_магазины.КПП, 
			#dwh_temp_магазины.Куст,
			#dwh_temp_магазины.Ответственный, 
			#dwh_temp_магазины.Отчёт,
			#dwh_temp_магазины.Регион,
			#dwh_temp_магазины.Дата_Начала_Реконструкции,
			#dwh_temp_магазины.Дата_Конца_Реконструкции, 
			#dwh_temp_магазины.Бренд_Магазина,
			#dwh_temp_магазины.Технолог_СП
		);

END
