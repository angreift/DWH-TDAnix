-- =============================================
-- Author:		kma1860
-- Create date: 27/03/2023
-- Description:	Загрузка планов для Сравнительного анализа из RSC
-- =============================================
CREATE PROCEDURE [plan].[p_Загрузка_планов_для_СА]
AS
BEGIN
	set noCount on;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для заиписи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	declare @_код_магазина int, @_дата_выгрузки date, @_дата_начала_выгрузки date, @_дата_конца_выгрузки date, @_отпечаток_времени int;

	-- Удалим выгрузки, содержащие в важных полях нули
	delete from td.[t_raw_Данные_ПД_шапки] where SubCode is null or 
												 DateExec is null or 
												 TimeStamp is null or 
												 DateStart is null or 
												 DateEnd is null

	delete from td.[t_raw_Данные_ПД_строки] where SubCode is null or 
												  DateExec is null or 
												  TimeStamp is null or 
												  DateStart is null or 
												  DateEnd is null

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

	declare @Version int, @strData nvarchar(max), @currStr nvarchar(max);

	-- Переменные для шапок (по магазинам)
	Declare @Дата date,
		@Код_магазина int,
		@Товарооборот decimal(12,2),
		@Количество_чеков int,
		@Валовый_доход decimal(12,2),
		@Товарооборот_СТМ decimal(12,2),
		@Производительность decimal(12,2),
		@Потребление_ЭЭ_без_ГВ_и_субаренды decimal(12,2),
		@Потери decimal(12,2),
		@Производительность_ГВ decimal(12,2)

	-- Переменные для строк (по группам)
	Declare @Код_группы bigint,
		@Показатель nvarchar(50),
		@Код_показателя_для_сравнительного_анализа int,
		@Список_групп nvarchar(500),
		@Значение decimal(12,2),
		@id int

	-- Раздельно загрузим строки, шапки. Начнем с шапок:
	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		SubCode, DateExec, TimeStamp, DateStart, DateEnd
	from
		[plan].[t_raw_Планы_СА_по_магазинам] with (nolock)

	-- Преобразуем по циклу
	while (select count(*) from @load_pr) > 0 begin
		Select top 1 
			@_дата_выгрузки = Дата_выгрузки,
			@_отпечаток_времени = Отпечаток_времени, 
			@_дата_начала_выгрузки = Дата_начала_выгрузки, 
			@_дата_конца_выгрузки = Дата_конца_выгрузки 
		from @load_pr 
		order by Дата_выгрузки asc, Дата_начала_выгрузки asc

		Delete from @load_pr where Дата_выгрузки = @_дата_выгрузки and
								   Отпечаток_времени = @_отпечаток_времени and
								   Дата_начала_выгрузки = @_дата_начала_выгрузки and
								   Дата_конца_выгрузки = @_дата_конца_выгрузки

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные

		if (select count(*) from [plan].[t_raw_Планы_СА_по_магазинам] with (nolock) where
				DateExec = @_дата_выгрузки and
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
				delete from [plan].[t_raw_Планы_СА_по_магазинам]  where DateExec = @_дата_выгрузки and
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

		begin tran load_plan_rsc_heads

		-- Удалили старые данные
		delete from [plan].[t_fact_Планы_СА_по_магазинам] where Дата >= @_дата_начала_выгрузки and Дата <= @_дата_конца_выгрузки;
		set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		delete from @Данные

		insert into @Данные ([data]) 
		select [Data] from [plan].[t_raw_Планы_СА_по_магазинам] where DateExec = @_дата_выгрузки and
																	   TimeStamp = @_отпечаток_времени and
																	   DateStart = @_дата_начала_выгрузки and
																	   DateEnd = @_дата_конца_выгрузки;


		delete from [plan].[t_raw_Планы_СА_по_магазинам] where DateExec = @_дата_выгрузки and
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

				set @Дата = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_магазина = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Товарооборот = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Количество_чеков = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Валовый_доход = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Товарооборот_СТМ = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Производительность = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Потребление_ЭЭ_без_ГВ_и_субаренды = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Потери = cast(cast(left(@currStr, charindex('&', @currStr) - 1) as int) as decimal) / 100;
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Производительность_ГВ = cast(cast(left(@currStr, charindex(';', @currStr) - 1) as int) as decimal) / 100;
					
				insert into
					[plan].[t_fact_Планы_СА_по_магазинам] (
						Дата,
						Код_магазина,
						Товарооборот,
						Количество_чеков,
						Валовый_доход,
						Товарооборот_СТМ,
						Производительность,
						Потребление_ЭЭ_без_ГВ_и_субаренды,
						Потери,
						Производительность_ГВ
					) values (
						@Дата,
						@Код_магазина,
						@Товарооборот,
						@Количество_чеков,
						@Валовый_доход,
						@Товарооборот_СТМ,
						@Производительность,
						@Потребление_ЭЭ_без_ГВ_и_субаренды,
						@Потери,
						@Производительность_ГВ
					)
			end
		end

		begin try
			commit tran load_plan_rsc_heads
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			print(@msg);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran load_plan_rsc_heads
			set @msg = concat('Не удалось загрузить: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch
	end

	---------------------------------------------------------------------
	-- СТРОКИ:
	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	delete from @load_pr
	insert into @load_pr
	select distinct 
		SubCode, DateExec, TimeStamp, DateStart, DateEnd
	from
		[plan].[t_raw_Планы_СА_по_группам] with (nolock)

	-- Преобразуем по циклу
	while (select count(*) from @load_pr) > 0 begin
		Select top 1 
			@_дата_выгрузки = Дата_выгрузки,
			@_отпечаток_времени = Отпечаток_времени, 
			@_дата_начала_выгрузки = Дата_начала_выгрузки, 
			@_дата_конца_выгрузки = Дата_конца_выгрузки 
		from @load_pr 
		order by Дата_выгрузки asc, Дата_начала_выгрузки asc

		Delete from @load_pr where Дата_выгрузки        = @_дата_выгрузки and
								   Отпечаток_времени    = @_отпечаток_времени and
								   Дата_начала_выгрузки = @_дата_начала_выгрузки and
								   Дата_конца_выгрузки  = @_дата_конца_выгрузки

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные

		if (select count(*) from [plan].[t_raw_Планы_СА_по_группам] with (nolock) where
				DateExec  = @_дата_выгрузки and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd   = @_дата_конца_выгрузки and
				EndFlag   = 1
				) = 0 begin
			set @msg = concat('Не найден флаг завершения выгрузки! Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;

			-- Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from [plan].[t_raw_Планы_СА_по_группам]  where DateExec  = @_дата_выгрузки and
																	  TimeStamp = @_отпечаток_времени and
																	  DateStart = @_дата_начала_выгрузки and
																	  DateEnd   = @_дата_конца_выгрузки;

				set @msg = concat('Данные выгрузки удалены, так как дата выгрузки менее, чем ', cast(dateAdd(day, - 2, getDate()) as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
				exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;
			end
			Continue
		end
		set @msg = concat('Начало загрузки данных о фактах из сырых таблиц. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		begin tran load_plan_rsc_rows

		-- Удалили старые данные
		delete from [plan].[t_fact_Планы_СА_по_группам] where Дата >= @_дата_начала_выгрузки and Дата <= @_дата_конца_выгрузки;
		set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		delete from @Данные

		insert into @Данные ([data]) 
		select [Data] from [plan].[t_raw_Планы_СА_по_группам] where DateExec  = @_дата_выгрузки and
																	TimeStamp = @_отпечаток_времени and
																	DateStart = @_дата_начала_выгрузки and
																	DateEnd   = @_дата_конца_выгрузки;


		delete from [plan].[t_raw_Планы_СА_по_группам] where DateExec  = @_дата_выгрузки and
															 TimeStamp = @_отпечаток_времени and
															 DateStart = @_дата_начала_выгрузки and
															 DateEnd   = @_дата_конца_выгрузки;

		-- Обходим данные в сырой таблице шапок

		while (select count(*) from @Данные where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные where Флаг_загрузки is null);
			update @Данные set Флаг_загрузки = 1 where [data] = @strData

			while len(@strData) > 0 begin
				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				set @Дата = cast('20' + left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Код_магазина = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Показатель = left(@currStr, charindex('&', @currStr) - 1);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Список_групп = replace(left(@currStr, charindex('&', @currStr) - 1) + ',', ' ', '');
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));

				set @Значение = cast(cast(left(@currStr, charindex(';', @currStr) - 1) as int) as decimal) / 100;
					
				insert into
					[plan].[t_fact_Планы_СА_по_группам] (
						Дата,
						Код_магазина,
						Код_показателя_для_сравнительного_анализа,
						Значение
					) values (
						@Дата,
						@Код_магазина,
						(Select Код_показателя_для_сравнительного_анализа 
						from [plan].[t_dim_Показатели_для_сравнительного_анализа] where Наименование = @Показатель),
						@Значение
					)

				set @id = @@IDENTITY

				while len(@Список_групп) > 0 begin
					begin try
						set @Код_группы = left(@Список_групп, charindex(',', @Список_групп) - 1)
					end try
					begin catch
						select @Список_групп
						select * from [plan].[t_fact_Планы_СА_по_группам] where id = @@IDENTITY
						rollback tran load_plan_rsc_rows
						return
					end catch
					set @Список_групп = right(@Список_групп, len(@Список_групп) - charindex(',', @Список_групп))
					insert into [plan].[t_fact_Планы_СА_по_группам_детализация] (id_плана, Код_группы) values (@id, @Код_группы)
				end
			end
		end

		begin try
			commit tran load_plan_rsc_rows
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			print(@msg);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran load_plan_rsc_rows
			set @msg = concat('Не удалось загрузить: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, 
				', Отпечаток времени: ', @_отпечаток_времени, ', Дата начала выгрузки: ', @_дата_начала_выгрузки, ', Дата конца выгрузки: ', @_дата_конца_выгрузки);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch
	end

END