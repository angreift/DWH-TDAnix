-- =============================================
-- Author:		kma1860
-- Create date: 24/03/2023
-- Description:	Загрузка справочника Показатели для срафнительного анализа из таблицы сырых данных
-- =============================================
CREATE PROCEDURE [plan].[p_Загрузка_справочника_Показатели_для_сравнительного_анализа]
AS
BEGIN
	set noCount on;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для записи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	Declare @_дата_выгрузки date, @_отпечаток_времени int;

	declare @load_pr table (
		Дата_выгрузки date,
		Отпечаток_времени int
	)
	declare @Данные table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)

	declare @_дата_прошлый_месяц date, @exVer int, @strData nvarchar(max), @currStr nvarchar(max);
	-- Переменные для вставки в таблицу
	declare @Наименование nvarchar(50),
			@Вид_показателя nvarchar(50),
			@Наименование_в_отчете nvarchar(50)

	-- Так как всегда выгружается справочник полностью, оставим только самую свежу выгрузку, остальные удалим
	-- Перезаписываем справочник целиком
	-- Проверим есть ли данные в таблице сырых данных

	if (select count(*) from [plan].[t_raw_Показатели_для_сравнительного_анализа] where EndFlag = 1) = 0 return;
	
	begin tran load_cl_plan_sap

	select top 1
		@_дата_выгрузки = [DateExec], @_отпечаток_времени = [TimeStamp]
	from
		[plan].[t_raw_Показатели_для_сравнительного_анализа]
	order by DateExec desc, TimeStamp desc

	delete from [plan].[t_raw_Показатели_для_сравнительного_анализа] where DateExec <> @_дата_выгрузки or [TimeStamp] <> @_отпечаток_времени

	-- Распарсим рав дата и инсёртним в дименшн таблицу

	-- Обходим данные в сырой таблице
	while (select count(*) from [plan].[t_raw_Показатели_для_сравнительного_анализа] where Loaded is null) > 0 begin
		select top 1
			@strData = [data],
			@exVer   = [Version]
		from
			[plan].[t_raw_Показатели_для_сравнительного_анализа]
		Where
			Loaded is null

		update [plan].[t_raw_Показатели_для_сравнительного_анализа] set Loaded = 1 where [data] = @strData and [Version] = @exVer
			
		if @exVer = 1 begin 

			while len(@strData) > 0 begin

				-- Струткура сообщения: [Наименование]&[Вид_показателя]&[Наименование_в_отчете];

				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				set @Наименование = left(@currStr, charindex('&', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Вид_показателя = left(@currStr, charindex('&', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Наименование_в_отчете = left(@currStr, charindex(';', @currStr) - 1);

				begin try
					if (select count(*) from [plan].[t_dim_Показатели_для_сравнительного_анализа] where Наименование = @Наименование) > 0 begin
						update 
							[plan].[t_dim_Показатели_для_сравнительного_анализа] 
						set
							Вид_показателя = @Вид_показателя,
							@Наименование_в_отчете = @Наименование_в_отчете
						where
							Наименование = @Наименование
					end else begin
						insert into [plan].[t_dim_Показатели_для_сравнительного_анализа] 
							(Наименование, Вид_показателя, Наименование_в_отчете)
						values (@Наименование, @Вид_показателя, @Наименование_в_отчете)
					end
				end try
				begin catch
					rollback tran load_cl_Aliance
					set @msg = concat('Не удалось загрузить справочник Показатели для сравнительного анализа: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
					exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;	
					return;
				end catch
			end
		end
	end

	-- Очистим таблицу полностью
	Delete from [plan].[t_raw_Показатели_для_сравнительного_анализа]

	begin try
		commit tran load_cl_plan_sap
		set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
	end try
	begin catch
		rollback tran load_cl_plan_sap
		set @msg = concat('Не удалось загрузить справочник Показатели для сравнительного анализа: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
	end catch

END