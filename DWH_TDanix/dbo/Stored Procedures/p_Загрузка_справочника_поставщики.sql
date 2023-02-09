-- =============================================
-- Author:		vae1860
-- Create date: 15/10/2022
-- Description:	Загрузка справочника Поставщики из serv-term и RSF
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
		Автозаявка BIT NULL,
		Код_РСФ INT NULL
	);

	-- 2. Загрузка из serv-term и RSF
	insert into #dwh_temp_поставщики
	select
		Поставщики.[CODE] as Код,
		Поставщики.[DESCR] as Наименование,
		Поставщики.[SP44] as ИНН,
		Поставщики.[SP2160] as КПП,
		Поставщики.[SP40] as Адрес,
		Поставщики.[SP38] as Ответственное_лицо,
		Поставщики.[SP1593] as Автозаявка,
		cast(Поставщики_РСФ._Code as int) as Код_РСФ
	from [Rozn].[rozn].[dbo].[SC36] as Поставщики
	left join [S19-RDSAPP-PROD].[RSF].[dbo].[_Reference61] as Поставщики_РСФ on cast(Поставщики_РСФ._Code as int) = Поставщики.[SP4153] and Поставщики_РСФ._Marked = 0x00
	where Поставщики.[ISFOLDER] = 2 and Поставщики.[PARENTID] = '     4   ' and Поставщики.[ISMARK] = 0;

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
				[dbo].t_dim_Поставщики.Автозаявка = #dwh_temp_поставщики.Автозаявка,
				[dbo].t_dim_Поставщики.Код_РСФ = #dwh_temp_поставщики.Код_РСФ
	when not matched
		then insert
			values(
				#dwh_temp_поставщики.Код,
				#dwh_temp_поставщики.Наименование,
				#dwh_temp_поставщики.ИНН,
				#dwh_temp_поставщики.КПП,
				#dwh_temp_поставщики.Адрес,
				#dwh_temp_поставщики.Ответственное_лицо,
				#dwh_temp_поставщики.Автозаявка,
				#dwh_temp_поставщики.Код_РСФ
			);
END;
GO


