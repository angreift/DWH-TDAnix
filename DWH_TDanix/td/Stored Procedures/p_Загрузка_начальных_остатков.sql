-- =============================================
-- Author:		kma1860
-- Create date: 27/09/2022
-- Description:	Загрузка данных о товародвижении из CS
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_начальных_остатков]
AS
BEGIN
	set noCount on;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для записи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	declare @_код_магазина int, @_дата_выгрузки date, @_отпечаток_времени int;

	declare @load_pr table (
		Код_магазина int,
		Дата_выгрузки date,
		Отпечаток_времени int
	)
	declare @Данные table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)

	declare @_дата_прошлый_месяц date, @exVer int, @strData nvarchar(max), @currStr nvarchar(max);
	declare @Дата_документа date, @Код_товара bigint, @Код_склада tinyint,
		@Сумма decimal(15,2), @СуммаЗакупа decimal(15,2), @СуммаЗакупаСоСклада decimal(15,2), 
		@Количество decimal(15, 3);

	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		Код_магазина, Дата_выгрузки, Отпечаток_времени
	from
		[td].[t_raw_Данные_начальных_остатков_из_магазинов]

	-- Преобразуем по циклу
	while (select count(*) from @load_pr) > 0 begin
		Set @_код_магазина = (Select top 1 Код_магазина from @load_pr order by Код_магазина asc, Дата_выгрузки asc, Отпечаток_времени asc);
		Set @_дата_выгрузки = (Select top 1 Дата_выгрузки from @load_pr where Код_магазина = @_код_магазина order by Код_магазина asc, Дата_выгрузки asc, Отпечаток_времени asc);
		Set @_отпечаток_времени = (Select top 1 Отпечаток_времени from @load_pr where Код_магазина = @_код_магазина and Дата_выгрузки = @_дата_выгрузки order by Код_магазина asc, Дата_выгрузки asc, Отпечаток_времени asc)
		Delete from @load_pr where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Отпечаток_времени = @_отпечаток_времени
		
		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные
		Print('01' + format(@_дата_выгрузки, 'yyMMdd') + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish');

		if (select count(*) from [td].[t_raw_Данные_начальных_остатков_из_магазинов] where
				Дата_выгрузки = @_дата_выгрузки and
				Код_магазина = @_код_магазина and
				Отпечаток_времени = @_отпечаток_времени and
				[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish'
				) = 0 begin
			set @msg = concat('Не найден флаг завершения выгрузки! Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', 'Отпечаток времени: ', @_отпечаток_времени);
			
			--Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from td.[t_raw_Данные_начальных_остатков_из_магазинов] where Дата_выгрузки = @_дата_выгрузки and
																			  Код_магазина = @_код_магазина and
																			  Отпечаток_времени = @_отпечаток_времени;
			set @msg = concat('Данные выгрузки удалены, так как дата выгрузки менее, чем ', cast(dateAdd(day, - 2, getDate()) as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;

			end
			Continue
		end
		set @msg = concat('Начало загрузки данных о фактах из сырых таблиц. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		begin tran td_bm_st_load
		Delete from [td].[t_raw_Данные_начальных_остатков_из_магазинов] where
			Дата_выгрузки = @_дата_выгрузки and
			Код_магазина = @_код_магазина and
			Отпечаток_времени = @_отпечаток_времени and
			[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish';

		-- Удалили старые данные
		delete from td.t_fact_Начальные_остатки where Дата = @_дата_выгрузки and Код_магазина = @_код_магазина
		set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		delete from @Данные

		insert into @Данные ([data]) select [Data] from [td].[t_raw_Данные_начальных_остатков_из_магазинов] where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Отпечаток_времени = @_отпечаток_времени;

		delete from [td].[t_raw_Данные_начальных_остатков_из_магазинов] where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Отпечаток_времени = @_отпечаток_времени; 

		-- Обходим данные в сырой таблице
		while (select count(*) from @Данные where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные where Флаг_загрузки is null);
			update @Данные set Флаг_загрузки = 1 where [data] = @strData

			set @exVer = cast(left(@strData, 2) as int);
			
			if @exVer = 1 begin 
				print('load -> ' + @strData);

				-- 1. Обрезаем метаифнормацию в началае
				set @strData = substring(@strData, 19, len(@strData) - 18);

				while len(@strData) > 0 begin
					set @currStr = left(@strData, charindex(';', @strData));
					set @strData = right(@strData, len(@strData) - charindex(';', @strData));

					set @Код_товара = cast(left(@currStr, charindex('&', @currStr) - 1) as bigint);
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @Код_склада = cast(left(@currStr, charindex('&', @currStr) - 1) as tinyint);
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @Сумма = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal(15)) / 100;
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr) );
					set @СуммаЗакупа = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal(15)) / 100;
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @СуммаЗакупаСоСклада = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal(15)) / 100;
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @Количество = cast(left(@currStr, charindex(';', @currStr) - 1) as decimal(15)) / 1000;

					insert into
						td.t_fact_Начальные_остатки(
							Дата,
							Код_магазина,
							Код_склада_в_магазине,
							Код_товара,
							Сумма,
							Сумма_закупа,
							Сумма_закупа_со_склада,
							Остаток
						) values (
							@_дата_выгрузки,
							@_код_магазина,
							@Код_склада,
							@Код_товара,
							@Сумма,
							@СуммаЗакупа,
							@СуммаЗакупаСоСклада,
							@Количество
					)
				end
			end
		end
		begin try
			commit tran td_bm_st_load
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran td_bm_st_load
			set @msg = concat('Не удалось загрузить товародвижение: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end catch
	end

END