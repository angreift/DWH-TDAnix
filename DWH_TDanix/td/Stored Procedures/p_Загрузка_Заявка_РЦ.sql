-- =============================================
-- Author:		kma1860
-- Create date: 17/01/2023
-- Description:	Загрузка данных шапок и строк документов Заявка РЦ
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_Заявка_РЦ]
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
	Declare @Составной_код_заявки_РЦ nvarchar(15),
		@Дата_заявки_РЦ date

	-- Переменные для строк
	Declare @Код_товара bigint,
		@Остаток decimal(14,3),
		@Остаток_цех decimal(10,3),
		@Прогноз decimal(14,3),
		@План decimal(12,3),
		@Заказ decimal(14,3),
		@Заказ_выпечка decimal(14,3),
		@В_пути decimal(14,3),
		@Цена decimal(12,2),
		@Единиц_в_упаковке decimal(14,3),
		@Минимальная_норма decimal(14,3),
		@Средние_продажи decimal(14,3),
		@Период_заказа smallInt,
		@Страховой_запас decimal(14,3),
		@Неснижаемый_остаток decimal(14,3),
		@Спец_заказ decimal(6,2),
		-- Ккрит
		@Критический_остаток decimal(3,1),
		-- Кдн
		@Дневной_коэффициент decimal(10,3),
		-- Кнед
		@Недельный_коэффициент decimal(10,3),
		-- Kt
		@Температурный_коэффициент decimal(10,2),
		@Категория_РЦ smallint,
		@Приказ_с_планом int,
		@Категория_ABC nvarchar(10),
		@Не_заказывать tinyint,
		@Неснижаемый_остаток_в_матрице nvarchar(10);

	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		SubCode, DateExec, TimeStamp, DateStart, DateEnd
	from
		[td].[t_raw_Данные_Заявка_РЦ_шапки] with (nolock)

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

		if (select count(*) from [td].[t_raw_Данные_Заявка_РЦ_шапки] with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 or (select count(*) from [td].[t_raw_Данные_Заявка_РЦ_строки] with (nolock) where
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
				delete from td.t_raw_Данные_Заявка_РЦ_строки  where DateExec = @_дата_выгрузки and
																	SubCode = @_код_магазина and
																	TimeStamp = @_отпечаток_времени and
																	DateStart = @_дата_начала_выгрузки and
																	DateEnd = @_дата_конца_выгрузки;
				delete from td.t_raw_Данные_Заявка_РЦ_шапки   where DateExec = @_дата_выгрузки and
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

		begin tran td_bm_load_rc

		-- Удалили старые данные
		delete from td.t_fact_Заявка_РЦ_шапки where Дата_заявки_РЦ >= @_дата_начала_выгрузки and Дата_заявки_РЦ <= @_дата_конца_выгрузки and Код_магазина = @_код_магазина
		set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		delete from @Данные
		delete from @Данные_строки

		insert into @Данные ([data]) 
		select [Data] from [td].t_raw_Данные_Заявка_РЦ_шапки where DateExec = @_дата_выгрузки and
																   SubCode = @_код_магазина and
																   TimeStamp = @_отпечаток_времени and
																   DateStart = @_дата_начала_выгрузки and
																   DateEnd = @_дата_конца_выгрузки;
		insert into @Данные_строки ([data]) 
		select [Data] from [td].t_raw_Данные_Заявка_РЦ_строки where DateExec = @_дата_выгрузки and
																	SubCode = @_код_магазина and
																	TimeStamp = @_отпечаток_времени and
																	DateStart = @_дата_начала_выгрузки and
																	DateEnd = @_дата_конца_выгрузки;

		delete from [td].t_raw_Данные_Заявка_РЦ_шапки where DateExec = @_дата_выгрузки and
															SubCode = @_код_магазина and
															TimeStamp = @_отпечаток_времени and
															DateStart = @_дата_начала_выгрузки and
															DateEnd = @_дата_конца_выгрузки;
		delete from [td].t_raw_Данные_Заявка_РЦ_строки where DateExec = @_дата_выгрузки and
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

				set @Дата_заявки_РЦ = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Составной_код_заявки_РЦ = concat(@_код_магазина, '~', left(@currStr, charindex(';', @currStr) - 1));
					
			insert into
				td.t_fact_Заявка_РЦ_шапки(
					Составной_код_заявки_РЦ,
					Дата_заявки_РЦ,
					Код_магазина
				) values (
					@Составной_код_заявки_РЦ,
					@Дата_заявки_РЦ,
					@_код_магазина
				)
			end
		end
		
		-- Обходим данные в сырой таблице строк
		while (select count(*) from @Данные_строки where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные_строки where Флаг_загрузки is null);
			update @Данные_строки set Флаг_загрузки = 1 where [data] = @strData

			while len(@strData) > 0 begin
				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				set @Составной_код_заявки_РЦ = concat(@_код_магазина, '~', left(@currStr, charindex('&', @currStr) - 1));
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_товара = cast(left(@currStr, charindex('&', @currStr) - 1) as bigint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Остаток = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Остаток_цех = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Прогноз = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @План = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Заказ = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Заказ_выпечка = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @В_пути = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Цена = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Единиц_в_упаковке = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Минимальная_норма = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Средние_продажи = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Период_заказа = cast(left(@currStr, charindex('&', @currStr) - 1) as smallint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Страховой_запас = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Неснижаемый_остаток = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Спец_заказ = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Критический_остаток = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 10;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Дневной_коэффициент = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Недельный_коэффициент = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 1000;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Температурный_коэффициент = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Категория_РЦ = cast(left(@currStr, charindex('&', @currStr) - 1) as smallint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Приказ_с_планом = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Категория_ABC = left(@currStr, charindex('&', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Не_заказывать = cast(left(@currStr, charindex('&', @currStr) - 1) as tinyint);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Неснижаемый_остаток_в_матрице = left(@currStr, charindex(';', @currStr) - 1);

			insert into
				td.t_fact_Заявка_РЦ_строки(
					Составной_код_заявки_РЦ,
					Код_товара,
					Остаток,
					Остаток_цех,
					Прогноз,
					План,
					Заказ,
					Заказ_выпечка,
					В_пути,
					Цена,
					Единиц_в_упаковке,
					Минимальная_норма,
					Средние_продажи,
					Период_заказа,
					Страховой_запас,
					Неснижаемый_остаток,
					Спец_заказ,
					Критический_остаток,
					Дневной_коэффициент,
					Недельный_коэффициент,
					Температурный_коэффициент,
					Категория_РЦ,
					Приказ_с_планом,
					Категория_ABC,
					Не_заказывать,
					Неснижаемый_остаток_в_матрице
				) values (
					@Составной_код_заявки_РЦ,
					@Код_товара,
					@Остаток,
					@Остаток_цех,
					@Прогноз,
					@План,
					@Заказ,
					@Заказ_выпечка,
					@В_пути,
					@Цена,
					@Единиц_в_упаковке,
					@Минимальная_норма,
					@Средние_продажи,
					@Период_заказа,
					@Страховой_запас,
					@Неснижаемый_остаток,
					@Спец_заказ,
					@Критический_остаток,
					@Дневной_коэффициент,
					@Недельный_коэффициент,
					@Температурный_коэффициент,
					@Категория_РЦ,
					@Приказ_с_планом,
					@Категория_ABC,
					@Не_заказывать,
					@Неснижаемый_остаток_в_матрице
				)
			end
		end

		begin try
			commit tran td_bm_load_rc
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			print(@msg);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran td_bm_load_rc
			set @msg = concat('Не удалось загрузить Заявки РЦ: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch
	end
END