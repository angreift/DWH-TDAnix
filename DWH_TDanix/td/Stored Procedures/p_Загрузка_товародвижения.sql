-- =============================================
-- Author:		kma1860
-- Create date: 27/09/2022
-- Description:	Загрузка данных о товародвижении из CS
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_товародвижения]
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

	declare @_дата_прошлый_месяц date, @exVer int, @strData nvarchar(max), @currStr nvarchar(max);
	declare @Вид_документа tinyint, @Дата_документа date, @Код_товара bigint, @Код_склада tinyint,
		@Сумма decimal(15,2), @СуммаЗакупа decimal(15,2), @СуммаЗакупаСоСклада decimal(15,2), 
		@Количество decimal(15, 3), @Код_причины smallint;

	-- Сначала получаем все выгрузки, которые есть в таблице сырых данных
	insert into @load_pr
	select distinct 
		Код_магазина, Дата_выгрузки, Отпечаток_времени, Выгрузка_из_ЗОД
	from
		[td].[t_raw_Данные_товародвижения_из_магазинов]

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

		--Проверим финишировала ли выгрузка. Если нет, то удалим эти данные

		Print('02' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish');

		if (select count(*) from [td].t_raw_Данные_товародвижения_из_магазинов where
				Дата_выгрузки = @_дата_выгрузки and
				Код_магазина = @_код_магазина and
				Выгрузка_из_ЗОД = @_выгрузка_зод and
				Отпечаток_времени = @_отпечаток_времени and
				[Data] = '02' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish'
				) = 0 begin
			Print('Не найден флаг завершения выгрузки');
			--Если это позавчерашняя выгрузка, то удалим ее, а если более новая, то не трогаем. Вдруг догрузится
			if @_дата_выгрузки < (dateAdd(day, - 2, getDate())) begin
				delete from td.t_raw_Данные_товародвижения_из_магазинов where Дата_выгрузки = @_дата_выгрузки and
																			  Код_магазина = @_код_магазина and
																			  Выгрузка_из_ЗОД = @_выгрузка_зод and
																			  Отпечаток_времени = @_отпечаток_времени;
				Print('Данные выгрузки удалены');
			end
			Continue
		end	else begin
			begin tran
			Delete from [td].t_raw_Данные_товародвижения_из_магазинов where
				Дата_выгрузки = @_дата_выгрузки and
				Код_магазина = @_код_магазина and
				Выгрузка_из_ЗОД = @_выгрузка_зод and
				Отпечаток_времени = @_отпечаток_времени and
				[Data] = '02' + format(@_дата_выгрузки, 'yyMMdd') + case when @_выгрузка_зод = 1 then 'Z' else 'D' end + right('0000' + cast(@_код_магазина as nvarchar), 4) + right('000000' + cast(@_отпечаток_времени as nvarchar), 6) + 'finish';
		end

		-- Удалили старые данные
		if @_выгрузка_зод = 1 
			delete from td.t_fact_Товародвижение where Дата >= dateFromParts(year(@_дата_прошлый_месяц), month(@_дата_прошлый_месяц), 1) and Дата <= @_дата_выгрузки
		else
			delete from td.t_fact_Товародвижение where Дата = @_дата_выгрузки

		-- Обходим данные в сырой таблице
		while (select count(*) from td.t_raw_Данные_товародвижения_из_магазинов 
				where Код_магазина = @_код_магазина and Дата_выгрузки = @_дата_выгрузки and Выгрузка_из_ЗОД = @_выгрузка_зод) > 0 begin
			set @strData = (select top 1 [data] from td.t_raw_Данные_товародвижения_из_магазинов where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени);

			delete from td.t_raw_Данные_товародвижения_из_магазинов where Код_магазина = @_код_магазина and
		                           Дата_выгрузки = @_дата_выгрузки and
								   Выгрузка_из_ЗОД = @_выгрузка_зод and
								   Отпечаток_времени = @_отпечаток_времени and
								   [Data] = @strData;

			set @exVer = cast(left(@strData, 2) as int);
			
			if @exVer = 2 begin 

				-- 1. Обрезаем метаифнормацию в началае
				set @strData = substring(@strData, 20, len(@strData) - 19);

				while len(@strData) > 0 begin
					set @currStr = left(@strData, charindex(';', @strData));
					set @strData = right(@strData, len(@strData) - charindex(';', @strData));

					set @Вид_документа = cast(left(@currStr, charindex('&', @currStr) - 1) as tinyint);
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @Дата_документа = cast(left(@currStr, charindex('&', @currStr) - 1) as date);
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
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
					set @Количество = cast(left(@currStr, charindex('&', @currStr) - 1) as decimal(15)) / 1000;
					set @currStr = right(@currStr, len(@currStr) - charindex('&', @currStr));
					set @Код_причины = cast(left(@currStr, charindex(';', @currStr) - 1) as smallint);

				insert into
					td.t_fact_Товародвижение (
						Дата,
						Код_магазина,
						Склад_в_магазине,
						ВидДвижения,
						Код_причины,
						Код_товара,
						Сумма,
						СуммаЗакупа,
						СуммаЗакупаСоСклада,
						Количество
					) values (
						@Дата_документа,
						@_код_магазина,
						@Код_склада,
						@Вид_документа,
						@Код_причины,
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
			commit tran
		end try
		begin catch
			rollback tran
			set @msg = concat('Не удалось загрузить товародвижение: ', error_message());
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
		end catch
	end

END