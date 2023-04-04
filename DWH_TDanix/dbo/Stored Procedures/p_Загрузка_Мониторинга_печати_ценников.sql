CREATE PROCEDURE [dbo].[p_Загрузка_Мониторинга_печати_ценников]
AS
BEGIN
	set noCount on;


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
		declare @Version int, @strData nvarchar(max), @currStr nvarchar(max);
	declare  @Дата_документа date, @Количество int, @Тип tinyint;

	-- Удалим выгрузки, содержащие в важных полях нули
	delete from dbo.t_raw_Мониторинг_печати_ценников where SubCode is null or 
																  DateExec is null or 
																  TimeStamp is null or 
																  DateStart is null or 
																  DateEnd is null

	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		SubCode, DateExec, TimeStamp, DateStart, DateEnd
	from
		dbo.t_raw_Мониторинг_печати_ценников with (nolock)

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

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные

		if (select count(*) from dbo.t_raw_Мониторинг_печати_ценников with (nolock) where
				DateExec = @_дата_выгрузки and
				SubCode = @_код_магазина and
				TimeStamp = @_отпечаток_времени and
				DateStart = @_дата_начала_выгрузки and
				DateEnd = @_дата_конца_выгрузки and
				EndFlag = 1
				) = 0 begin

			--Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from td.t_raw_Данные_товародвижения_из_магазинов where DateExec = @_дата_выгрузки and
																			  SubCode = @_код_магазина and
																			  TimeStamp = @_отпечаток_времени and
																			  DateStart = @_дата_начала_выгрузки and
																			  DateEnd = @_дата_конца_выгрузки;

	

			end
			Continue
		end

		begin tran td_bm_load

		-- Удалили старые данные
		delete from dbo.t_fact_Мониторинг_печати_ценников where Дата >= @_дата_начала_выгрузки and Дата <= @_дата_конца_выгрузки and Код_магазина = @_код_магазина
	

		delete from @Данные

		insert into @Данные ([data]) 
		select [Data] from dbo.t_raw_Мониторинг_печати_ценников where DateExec = @_дата_выгрузки and
																		 	   SubCode = @_код_магазина and
																			   TimeStamp = @_отпечаток_времени and
																			   DateStart = @_дата_начала_выгрузки and
																			   DateEnd = @_дата_конца_выгрузки;

		delete from dbo.t_raw_Мониторинг_печати_ценников where DateExec = @_дата_выгрузки and
																		SubCode = @_код_магазина and
																		TimeStamp = @_отпечаток_времени and
																		DateStart = @_дата_начала_выгрузки and
																		DateEnd = @_дата_конца_выгрузки;

		-- Обходим данные в сырой таблице
		while (select count(*) from @Данные where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные where Флаг_загрузки is null);
			update @Данные set Флаг_загрузки = 1 where [data] = @strData

			while len(@strData) > 0 begin
				set @currStr = left(@strData, charindex(';', @strData));
				set @strData = right(@strData, len(@strData) - charindex(';', @strData));

				set @Дата_документа = cast(left(@currStr, charindex('&', @currStr) - 1) as date);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
				set @Количество = cast(left(@currStr, charindex('&', @currStr) - 1) as int);
				set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
				set @Тип = cast(left(@currStr, charindex(';', @currStr) - 1) as smallint);

			insert into
				dbo.t_fact_Мониторинг_печати_ценников (
					Дата,
					Код_магазина,
					Количество,
					Тип
				) values (
					@Дата_документа,
					@_код_магазина,
					@Количество,
					@Тип
				)
			end
		end
		begin try
			commit tran td_bm_load
			
		end try
		begin catch
			rollback tran td_bm_load
			
		end catch
	end

END