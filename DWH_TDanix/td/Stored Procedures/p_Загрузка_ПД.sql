-- =============================================
-- Author:		kma1860
-- Create date: 13/01/2023
-- Description:	Загрузка данных шапок и строк документов ПД
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_ПД]
AS
BEGIN
	set noCount on;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для заиписи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	declare @_код_магазина int, @_дата_выгрузки date, @_дата_начала_выгрузки date, @_дата_конца_выгрузки date, @_отпечаток_времени int;

	declare @load_pr table (
		Код_магазина int,
		Дата_выгрузки date,
		Отпечаток_времени int,
		Дата_начала_выгрузки date,
		Дата_конца_выгрузки date
	)
	declare @Данные table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)
	declare @Данные_строки table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)

	declare @Version int, @strData nvarchar(max), @currStr nvarchar(max);

	-- Переменные для шапок
	Declare @Составной_код_ПД nvarchar(25),
		@Дата_ПД date,
		@Форма_оплаты nvarchar(30),
		@Код_поставщика_RSF int,
		@Код_магазина_отправителя int,
		@Составной_код_заявки_РЦ nvarchar(15),
		@Составной_код_заявки_СТ nvarchar(15),
		@Номер_фактуры nvarchar(20),
		@Дата_фактуры date,
		@Основание nvarchar(120),
		@Дата_ТТН date,
		@Номер_ТТН nvarchar(20);

	-- Переменные для строк
	Declare @Код_товара bigint,
		@Количество_факт decimal(19,3),
		@Количество_план decimal(19,3),
		@Количество_по_документу decimal(13,3),
		@Цена_закупа decimal(15,2),
		@Сумма_закупа decimal(19,2),
		@Процент_наценки int,
		@Цена decimal(19,2),
		@Сумма decimal(19,2),
		@Процент_НДС tinyint,
		@Сумма_НДС_закупочная decimal(12,2),
		@Сумма_НДС_розничная decimal(12,2),
		@Срок_годности date,
		@Штрихкод nvarchar(13),
		@Код_поставщика_холдинга int;

	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		SubCode, DateExec, TimeStamp, DateStart, DateEnd
	from
		[td].[t_raw_Данные_ПД_шапки] with (nolock)

	-- Преобразуем по циклу
	while (select count(*) from @load_pr) > 0 begin
		Select top 1 
			@_код_магазина = Код_магазина, 
			@_дата_выгрузки = Дата_выгрузки,
			@_отпечаток_времени = Отпечаток_времени, 
			@_дата_начала_выгрузки = Дата_начала_выгрузки, 
			@_дата_конца_выгрузки = Дата_конца_выгрузки 
		from @load_pr 
		order by Код_магазина asc, Дата_выгрузки asc, Дата_начала_выгрузки asc

		Delete from @load_pr where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Отпечаток_времени = @_отпечаток_времени and
								   Дата_начала_выгрузки = @_дата_начала_выгрузки and
								   Дата_конца_выгрузки = @_дата_конца_выгрузки

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные. Флаг должен быть и в таблице строк и в таблице шапок

		if (select count(*) from [td].t_raw_Данные_ПД_шапки with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 or (select count(*) from [td].t_raw_Данные_ПД_строки with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 begin
			set @msg = concat('Не найден флаг завершения выгрузки! Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;
		end;

		if (select count(*) from [td].t_raw_Данные_ПД_шапки with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 or (select count(*) from [td].t_raw_Данные_ПД_строки with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 begin
			set @msg = concat('Не найден флаг завершения выгрузки! Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;

			--Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from td.t_raw_Данные_ПД_шапки  where DateExec = @_дата_выгрузки and
															SubCode = @_код_магазина and
															TimeStamp = @_отпечаток_времени and
															DateStart = @_дата_начала_выгрузки and
															DateEnd = @_дата_конца_выгрузки;
				delete from td.t_raw_Данные_ПД_строки where DateExec = @_дата_выгрузки and
															SubCode = @_код_магазина and
															TimeStamp = @_отпечаток_времени and
															DateStart = @_дата_начала_выгрузки and
															DateEnd = @_дата_конца_выгрузки;
				set @msg = concat('Данные выгрузки удалены, так как дата выгрузки менее, чем ', cast(dateAdd(day, - 2, getDate()) as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
				exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;
			end
			Continue
		end
		set @msg = concat('Начало загрузки данных о фактах из сырых таблиц. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		begin tran td_bm_load_pd

		-- Удалили старые данные
		delete from td.t_fact_ПД_шапки where Дата_ПД >= @_дата_начала_выгрузки and Дата_ПД <= @_дата_конца_выгрузки and Код_магазина = @_код_магазина;
		set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		delete from @Данные
		delete from @Данные_строки

		insert into @Данные ([data]) 
		select [Data] from [td].t_raw_Данные_ПД_шапки where DateExec = @_дата_выгрузки and
															SubCode = @_код_магазина and
															TimeStamp = @_отпечаток_времени and
															DateStart = @_дата_начала_выгрузки and
															DateEnd = @_дата_конца_выгрузки;
		insert into @Данные_строки ([data]) 
		select [Data] from [td].t_raw_Данные_ПД_строки where DateExec = @_дата_выгрузки and
															 SubCode = @_код_магазина and
															 TimeStamp = @_отпечаток_времени and
															 DateStart = @_дата_начала_выгрузки and
															 DateEnd = @_дата_конца_выгрузки;

		delete from [td].t_raw_Данные_ПД_шапки where DateExec = @_дата_выгрузки and
													 SubCode = @_код_магазина and
													 TimeStamp = @_отпечаток_времени and
													 DateStart = @_дата_начала_выгрузки and
													 DateEnd = @_дата_конца_выгрузки;
		delete from [td].t_raw_Данные_ПД_строки where DateExec = @_дата_выгрузки and
													  SubCode = @_код_магазина and
													  TimeStamp = @_отпечаток_времени and
													  DateStart = @_дата_начала_выгрузки and
													  DateEnd = @_дата_конца_выгрузки;

		-- Обходим данные в сырой таблице шапок
		while (select count(*) from @Данные where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные where Флаг_загрузки is null);
			update @Данные set Флаг_загрузки = 1 where [data] = @strData

			while len(@strData) > 0 begin
				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				--print(@currStr);

				set @Дата_ПД = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				-- Номер приходника уникален только в передлах года
				set @Составной_код_ПД = concat(@_код_магазина, '~', format(@Дата_ПД, 'yyMMdd'), '~', left(@currStr, charindex('&', @currStr) - 1));
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Форма_оплаты = left(@currStr, charindex('&', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_поставщика_RSF = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				if @Код_поставщика_RSF = 0 set @Код_поставщика_RSF = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_магазина_отправителя = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				if @Код_магазина_отправителя = 0 set @Код_магазина_отправителя = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				if left(@currStr, charindex('&', @currStr) - 1) = '' 
					set @Составной_код_заявки_РЦ = null 
					else set @Составной_код_заявки_РЦ = concat(@_код_магазина, '~', left(@currStr, charindex('&', @currStr) - 1));
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				if left(@currStr, charindex('&', @currStr) - 1) = '' 
					set @Составной_код_заявки_СТ = null 
					else set @Составной_код_заявки_СТ = concat(@_код_магазина, '~', left(@currStr, charindex('&', @currStr) - 1));
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Номер_фактуры = left(@currStr, charindex('&', @currStr) - 1);
				if @Номер_фактуры = '' set @Номер_фактуры = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				if LEN(left(@currStr, charindex('&', @currStr) - 1)) = 6 begin
					set @Дата_фактуры = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				end else set @Дата_фактуры = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Основание = left(@currStr, charindex('&', @currStr) - 1);
				if @Основание = '' set @Основание = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				if LEN(left(@currStr, charindex('&', @currStr) - 1)) = 6 begin
					set @Дата_ТТН = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				end else set @Дата_ТТН = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Номер_ТТН = left(@currStr, charindex(';', @currStr) - 1);
				if @Номер_ТТН = '' set @Номер_ТТН = null;
					
			insert into
				td.t_fact_ПД_шапки(
					Составной_код_ПД,
					Дата_ПД,
					Код_магазина,
					Форма_оплаты,
					Код_поставщика_RSF,
					Код_магазина_отправителя,
					Составной_код_заявки_РЦ,
					Составной_код_заявки_СТ,
					Номер_фактуры, 
					Дата_фактуры,
					Основание,
					Дата_ТТН,
					Номер_ТТН
				) values (
					@Составной_код_ПД,
					@Дата_ПД,
					@_код_магазина,
					@Форма_оплаты,
					@Код_поставщика_RSF,
					@Код_магазина_отправителя,
					@Составной_код_заявки_РЦ,
					@Составной_код_заявки_СТ,
					@Номер_фактуры,
					@Дата_фактуры,
					@Основание,
					@Дата_ТТН,
					@Номер_ТТН
				)
			end
		end
		
		-- Обходим данные в сырой таблице строк
		while (select count(*) from @Данные_строки where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные_строки where Флаг_загрузки is null);
			update @Данные_строки set Флаг_загрузки = 1 where [data] = @strData

			-- 1. Обрезаем метаифнормацию в началае
			set @strData = substring(@strData, 20, len(@strData) - 19);

			while len(@strData) > 0 begin
				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				set @Дата_ПД = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				-- Номер приходника уникален только в передлах года
				set @Составной_код_ПД = concat(@_код_магазина, '~', format(@Дата_ПД, 'yyMMdd'), '~', left(@currStr, charindex('&', @currStr) - 1));
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_товара = cast(left(@currStr, charindex('&', @currStr) - 1) as bigint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Количество_факт = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Количество_план = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Количество_по_документу = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Цена_закупа = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Сумма_закупа = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Процент_наценки = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Цена = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Сумма = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Сумма_НДС_закупочная = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Сумма_НДС_розничная = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				if LEN(left(@currStr, charindex('&', @currStr) - 1)) = 6 begin
					set @Срок_годности = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				end else set @Срок_годности = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Процент_НДС = cast(left(@currStr, charindex('&', @currStr) - 1) as tinyint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Штрихкод = left(@currStr, charindex('&', @currStr) - 1);
				if @Штрихкод = '' set @Штрихкод = null;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_поставщика_холдинга = left(@currStr, charindex(';', @currStr) - 1);

			insert into
				td.t_fact_ПД_Строки(
					Составной_код_ПД,
					Код_товара,
					Количество_факт,
					Количество_план,
					Количество_по_документу,
					Цена_закупа,
					Сумма_закупа,
					Процент_наценки,
					Цена,
					Сумма,
					Процент_НДС,
					Сумма_НДС_закупочная,
					Сумма_НДС_розничная,
					Срок_годности,
					Штрихкод,
					Код_поставщика_холдинга
				) values (
					@Составной_код_ПД,
					@Код_товара,
					@Количество_факт,
					@Количество_план,
					@Количество_по_документу,
					@Цена_закупа,
					@Сумма_закупа,
					@Процент_наценки,
					@Цена,
					@Сумма,
					@Процент_НДС,
					@Сумма_НДС_закупочная,
					@Сумма_НДС_розничная,
					@Срок_годности,
					@Штрихкод,
					@Код_поставщика_холдинга
				)
			end
		end

		begin try
			commit tran td_bm_load_pd
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			print(@msg);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran td_bm_load_pd
			set @msg = concat('Не удалось загрузить товародвижение: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch
	end

END