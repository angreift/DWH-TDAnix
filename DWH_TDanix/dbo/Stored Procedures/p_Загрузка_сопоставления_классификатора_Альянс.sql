-- =============================================
-- Author:		kma1860
-- Create date: 24/01/2023
-- Description:	перезаписывает таблицу-сопоставление между кодмаи товаров и кодами Альянса
-- =============================================
CREATE PROCEDURE [dbo].[p_Загрузка_сопоставления_классификатора_Альянс]
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
	declare @КодТовара bigint,
	        @Составной_код_Альянс nvarchar(25)

	-- Так как всегда выгружается справочник полностью, оставим только самую свежу выгрузку, остальные удалим
	-- Перезаписываем справочник целиком
	-- Проверим есть ли данные в таблице сырых данных

	if (select count(*) from dbo.t_raw_Классификатор_Альянс where [Data] like '%finish%') = 0 return;
	
	begin tran load_cl_Aliance_comp
	
	set @_дата_выгрузки     = (select top 1 Дата_выгрузки     from dbo.t_raw_Сопоставление_Классификатора_Альянс where [Data] like '%finish%' order by Дата_выгрузки desc);
	set @_отпечаток_времени = (select top 1 Отпечаток_времени from dbo.t_raw_Сопоставление_Классификатора_Альянс where [Data] like '%finish%' and
								Дата_выгрузки = @_дата_выгрузки order by Отпечаток_времени desc);

	delete from dbo.t_raw_Сопоставление_Классификатора_Альянс where Дата_выгрузки <> @_дата_выгрузки or Отпечаток_времени <> @_отпечаток_времени
	
	-- Удалим флаг завершения выгрузки

	delete from dbo.t_raw_Сопоставление_Классификатора_Альянс where [data] like '%finish%'

	-- Удалим все строки из справочника

	delete from dbo.t_dim_Сопоставление_классификатора_Альянс

	-- Распарсим рав дата и инсёртним в дименшн таблицу

	-- Обходим данные в сырой таблице
	while (select count(*) from dbo.t_raw_Сопоставление_Классификатора_Альянс where Флаг_загрузки is null) > 0 begin
		set @strData = (select top 1 [data] from dbo.t_raw_Сопоставление_Классификатора_Альянс where Флаг_загрузки is null);
		update dbo.t_raw_Сопоставление_Классификатора_Альянс set Флаг_загрузки = 1 where [data] = @strData

		set @exVer = cast(left(@strData, 2) as int);
			
		if @exVer = 1 begin 

			-- 1. Обрезаем метаифнормацию в началае
			set @strData = substring(@strData, 15, len(@strData) - 14);

			while len(@strData) > 0 begin

				-- Струткура сообщения: [КодТовара]=[КодАльянс];

				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));
				set @КодТовара = left(@currStr, charindex('=', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('=', @currStr));

				set @Составной_код_Альянс = left(@currStr, charindex(';', @currStr) - 1);

				begin try
					insert into
						dbo.t_dim_Сопоставление_классификатора_Альянс(
							Код_товара,
							Составной_код_Альянс
						) values (
							@КодТовара,
							@Составной_код_Альянс
						)
				end try
				begin catch
					rollback tran load_cl_Aliance_comp
					set @msg = concat('Не удалось загрузить сопоставление классификатора Альянс: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
					exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;	
					return;
				end catch
			end
		end
	end

	delete from dbo.t_raw_Сопоставление_Классификатора_Альянс where Флаг_загрузки = 1;

	-- Подстраховка: если получился пустая таблица, то отменим транзакцию и создадим ошибку
	if (select count(*) from dbo.t_dim_Сопоставление_классификатора_Альянс) = 0 begin
		rollback tran load_cl_Aliance_comp
		set @msg = concat('Не удалось загрузить сопоставление классификатора Альянс: в результате загрузки получилась пустая таблица dbo.t_dim_Сопоставление_классификатора_Альянс. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;	
		return;
	end

	begin try
		commit tran load_cl_Aliance_comp
		set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
	end try
	begin catch
		rollback tran load_cl_Aliance_comp
		set @msg = concat('Не удалось загрузить сопоставление классификатора Альянс: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
	end catch

END