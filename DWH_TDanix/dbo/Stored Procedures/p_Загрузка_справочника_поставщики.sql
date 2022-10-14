-- =============================================
-- Author:		vae1860
-- Create date: 15/10/2022
-- Description:	Загрузка справочника Поставщики из serv-term
-- =============================================
CREATE PROCEDURE [dbo].[p_Загрузка_справочника_поставщики]
AS
BEGIN

	SET NOCOUNT ON;
	-- 1. Создание временной таблицы
	drop table if exists #dwh_temp_поставщики;

	create table #dwh_temp_поставщики (
		Код INT NOT NULL PRIMARY KEY, 
		Наименование nvarchar(100) NOT NULL,
		ИНН BIGINT NULL, 
		КПП BIGINT NULL, 
		Адрес nvarchar(200) NULL, 
		Ответственное_лицо nvarchar(100) NULL, 
		Автозаявка BIT NULL
	);

	-- 2. Загрузка из serv-term
	insert into #dwh_temp_поставщики (Код, Наименование, ИНН, КПП, Адрес, Ответственное_лицо, Автозаявка)
	select
		Поставщики.[CODE] as Код,
		Поставщики.[DESCR] as Наименование,
		Поставщики.[SP44] as ИНН,
		Поставщики.[SP2160] as КПП,
		Поставщики.[SP40] as Адрес,
		Поставщики.[SP38] as Ответственное_лицо,
		Поставщики.[SP1593] as Автозаявка
	from [Rozn].[rozn].[dbo].[SC36] as Поставщики
	where Поставщики.[ISFOLDER] = 2 and Поставщики.[PARENTID] = '     4   ';

	-- 3. Слияние таблиц
	merge
		[dbo].t_dim_Поставщики
	using
		#dwh_temp_поставщики
	on
		[dbo].t_dim_Поставщики.Код = #dwh_temp_поставщики.Код
	when matched 
		then update 
			set
				[dbo].t_dim_Поставщики.Код = #dwh_temp_поставщики.Код,
				[dbo].t_dim_Поставщики.Наименование = #dwh_temp_поставщики.Наименование,
				[dbo].t_dim_Поставщики.ИНН = #dwh_temp_поставщики.ИНН,
				[dbo].t_dim_Поставщики.КПП = #dwh_temp_поставщики.КПП,
				[dbo].t_dim_Поставщики.Адрес = #dwh_temp_поставщики.Адрес,
				[dbo].t_dim_Поставщики.Ответственное_лицо = #dwh_temp_поставщики.Ответственное_лицо,
				[dbo].t_dim_Поставщики.Автозаявка = #dwh_temp_поставщики.Автозаявка
	when not matched
		then insert
			values(
				#dwh_temp_поставщики.Код,
				#dwh_temp_поставщики.Наименование,
				#dwh_temp_поставщики.ИНН,
				#dwh_temp_поставщики.КПП,
				#dwh_temp_поставщики.Адрес,
				#dwh_temp_поставщики.Ответственное_лицо,
				#dwh_temp_поставщики.Автозаявка
			);
END;