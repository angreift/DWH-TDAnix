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

	declare @_код_магазина int, @_дата_выгрузки date, @_выгрузка_зод bit, @_отпечаток_времени int;

	declare @load_pr table (
		Код_магазина int,
		Дата_выгрузки date,
		Отпечаток_времени int,
		выгрузка_ЗОД bit
	)
	declare @Данные table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)
	declare @Данные_строки table (
		[data] nvarchar(max),
		Флаг_загрузки bit
	)

	declare @_дата_прошлый_месяц date, @exVer int, @strData nvarchar(max), @currStr nvarchar(max);

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
		Код_магазина, Дата_выгрузки, Отпечаток_времени, Выгрузка_из_ЗОД
	from
		[td].[t_raw_Данные_Заявка_РЦ_шапки] with (nolock)

	-- Преобразуем по циклу
	while (select count(*) from @load_pr) > 0 begin
		Set @_код_магазина = (Select top 1 Код_магазина from @load_pr order by Код_магазина asc, Дата_выгрузки asc, выгрузка_ЗОД desc, Отпечаток_времени asc);
		Set @_дата_выгрузки = (Select top 1 Дата_выгрузки from @load_pr where Код_магазина = @_код_магазина order by Код_магазина asc, Дата_выгрузки asc, выгрузка_ЗОД desc, Отпечаток_времени asc);
		Set @_выгрузка_зод = (Select top 1 выгрузка_ЗОД from @load_pr where Код_магазина = @_код_магазина and Дата_выгрузки = @_дата_выгрузки order by Код_магазина asc, Дата_выгрузки asc, выгрузка_ЗОД desc, Отпечаток_времени asc)
		Set @_отпечаток_времени = (Select top 1 Отпечаток_времени from @load_pr where Код_магазина = @_код_магазина and Дата_выгрузки = @_дата_выгрузки order by Код_магазина asc, Дата_выгрузки asc, выгрузка_ЗОД desc, Отпечаток_времени asc)
		Delete from @load_pr where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   выгрузка_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени
		
		set @_дата_прошлый_месяц = dateAdd(month, -1, @_дата_выгрузки);

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные. Флаг должен быть и в таблице строк и в таблице шапок

		--Print('02' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish');

		if (select count(*) from [td].[t_raw_Данные_Заявка_РЦ_шапки] with (nolock) where
				Дата_выгрузки = @_дата_выгрузки and
				Код_магазина = @_код_магазина and
				Выгрузка_из_ЗОД = @_выгрузка_зод and
				Отпечаток_времени = @_отпечаток_времени and
				[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish'
				) = 0 or (select count(*) from [td].[t_raw_Данные_Заявка_РЦ_строки] with (nolock) where
				Дата_выгрузки = @_дата_выгрузки and
				Код_магазина = @_код_магазина and
				Выгрузка_из_ЗОД = @_выгрузка_зод and
				Отпечаток_времени = @_отпечаток_времени and
				[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish'
				) = 0 begin
			set @msg = concat('Не найден флаг завершения выгрузки! Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;

			--Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from td.t_raw_Данные_Заявка_РЦ_строки  where Дата_выгрузки = @_дата_выгрузки and
																			  Код_магазина = @_код_магазина and
																			  Выгрузка_из_ЗОД = @_выгрузка_зод and
																			  Отпечаток_времени = @_отпечаток_времени;
				delete from td.t_raw_Данные_Заявка_РЦ_шапки   where Дата_выгрузки = @_дата_выгрузки and
																			  Код_магазина = @_код_магазина and
																			  Выгрузка_из_ЗОД = @_выгрузка_зод and
																			  Отпечаток_времени = @_отпечаток_времени;
			set @msg = concat('Данные выгрузки удалены, так как дата выгрузки менее, чем ', cast(dateAdd(day, - 2, getDate()) as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 2, @object_name, @msg;

			end
			Continue
		end
		set @msg = concat('Начало загрузки данных о фактах из сырых таблиц. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		begin tran td_bm_load_rc
		Delete from [td].t_raw_Данные_Заявка_РЦ_шапки where
			Дата_выгрузки = @_дата_выгрузки and
			Код_магазина = @_код_магазина and
			Выгрузка_из_ЗОД = @_выгрузка_зод and
			Отпечаток_времени = @_отпечаток_времени and
			[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish';
		Delete from [td].t_raw_Данные_Заявка_РЦ_строки where
			Дата_выгрузки = @_дата_выгрузки and
			Код_магазина = @_код_магазина and
			Выгрузка_из_ЗОД = @_выгрузка_зод and
			Отпечаток_времени = @_отпечаток_времени and
			[Data] = '01' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish';

		-- Удалили старые данные
		if @_выгрузка_зод = 1 begin
			delete from td.t_fact_Заявка_РЦ_шапки where Дата_заявки_РЦ >= dateFromParts(year(@_дата_прошлый_месяц), month(@_дата_прошлый_месяц), 1) and Дата_заявки_РЦ <= @_дата_выгрузки and Код_магазина = @_код_магазина
			set @msg = concat('Удалены данные с', cast(@_дата_прошлый_месяц as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		end else begin
			delete from td.t_fact_Заявка_РЦ_шапки where Дата_заявки_РЦ = @_дата_выгрузки and Код_магазина = @_код_магазина
			set @msg = concat('Удалены данные за ', cast(@_дата_выгрузки as nvarchar), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end

		delete from @Данные
		delete from @Данные_строки

		insert into @Данные ([data]) select [Data] from [td].t_raw_Данные_Заявка_РЦ_шапки where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени;
		insert into @Данные_строки ([data]) select [Data] from [td].t_raw_Данные_Заявка_РЦ_строки where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени;

		delete from [td].t_raw_Данные_Заявка_РЦ_шапки where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени; 
		delete from [td].t_raw_Данные_Заявка_РЦ_строки where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени; 

		-- Обходим данные в сырой таблице шапок
		while (select count(*) from @Данные where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные where Флаг_загрузки is null);
			update @Данные set Флаг_загрузки = 1 where [data] = @strData

			set @exVer = cast(left(@strData, 2) as int);
			
			if @exVer = 1 begin 

				-- 1. Обрезаем метаифнормацию в началае
				set @strData = substring(@strData, 20, len(@strData) - 19);

				while len(@strData) > 0 begin
					set @currStr = left(@strData, charindex(';', @strData));
					set @strData = right(@strData, len(@strData) - charindex(';', @strData));

					--print(@currStr);

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
		end
		
		-- Обходим данные в сырой таблице строк
		while (select count(*) from @Данные_строки where Флаг_загрузки is null) > 0 begin
			set @strData = (select top 1 [data] from @Данные_строки where Флаг_загрузки is null);
			update @Данные_строки set Флаг_загрузки = 1 where [data] = @strData

			set @exVer = cast(left(@strData, 2) as int);
			
			if @exVer = 1 begin 
				--print('load -> ' + @strData);

				-- 1. Обрезаем метаифнормацию в началае
				set @strData = substring(@strData, 20, len(@strData) - 19);

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
		end

		begin try
			commit tran td_bm_load_rc
			set @msg = concat('Загрузка успешно завершена и зафиксирована. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			print(@msg);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end try
		begin catch
			rollback tran td_bm_load_rc
			set @msg = concat('Не удалось загрузить товародвижение: ', error_message(), '. Дата выгрузки: ', @_дата_выгрузки, ', Код магазина: ', @_код_магазина, ', Выгрузка из ЗОД: ', @_выгрузка_зод, ', Отпечаток времени: ', @_отпечаток_времени);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch
	end

END