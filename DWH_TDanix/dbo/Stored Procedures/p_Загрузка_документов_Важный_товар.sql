-- =============================================
-- Author:		kma1860
-- Create date: 06/02/2023
-- Description:	Формируем таблицу фактов из документа ВажныйТовар в ОТБРС
-- =============================================
CREATE PROCEDURE [dbo].[p_Загрузка_документов_Важный_товар]
	@DateStart date = null, @DateEnd date = null, @OnlyFact bit = null
AS BEGIN

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для записи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры
	declare @query        nvarchar(max);

	-- Если даты не указаны, то формируем с начала прошлого месяца по текущее число включительно
	if @DateStart is null set @DateStart = dateadd(day, 1, eomonth(getdate(), -2));
	if @DateEnd   is null set @DateEnd   = getdate();

	begin tran load_important_goods

	-- Удалим данные за период выгрузки
	Delete from dbo.t_fact_Важный_товар where Начало_действия >= @DateStart and Начало_действия <= @DateEnd;

	-- Загрузим новые данные

	set @query = '
		Select Код_магазина, Начало_действия, Конец_действия, Код_товара, Сценарий from openquery([rozn], ''
		select
			cast(СпрК.Code as int) Код_магазина,
			Док.sp6601 Начало_действия,
			Док.sp6602 Конец_действия,
			cast(СпрТ.Code as bigint) Код_товара,
			ДокС.sp6609 Сценарий
		from
			dt6600 ДокС
		inner join 
			dh6600 Док on ДокС.IDDoc = Док.IDDoc
		inner join 
			_1SJourn Жур on Жур.IDDoc = Док.IDDoc and Жур.Closed &1 = 1
		join 
			sc11 СпрТ on ДокС.sp6605 = СпрТ.ID
		left join 
			dt3312 СМДокС on Док.sp6603 = СМДокС.IDDoc
		left join
			sc36 СпрК on СМДокС.sp3310 = СпрК.ID
		where Док.sp6601 >= ''''' + format(@DateStart, 'yyyyMMdd') + ''''' and Док.sp6601 <= ''''' + format(@DateEnd, 'yyyyMMdd') + ''''' '') ';

	Drop table if exists #t_raw_Важный_товар

	Insert into #t_raw_Важный_товар (
		Код_магазина, Начало_действия, Конец_действия, Код_товара, Сценарий
	) exec(@query);

	-- Сохраним новые сценарии
	Insert into dbo.t_dim_Сценарии_важного_товара (Сценарий_важного_товара) 
	select distinct Сценарий from #t_raw_Важный_товар where Сценарий not in 
	(select Сценарий_важного_товара from t_dim_Сценарии_важного_товара)

	-- Приджойним коды сценариев в новую таблицу
	alter table #t_raw_Важный_товар add [Код_сценария] int null

	update #t_raw_Важный_товар set [Код_сценария] = (Select [Код_сценария] from t_fact_Важный_товар where Сценарий = #t_raw_Важный_товар.Сценарий) 

	-- Полученные данные сохраним в основной таблице
	insert into dbo.t_fact_Важный_товар (Код_магазина, Начало_действия, Конец_действия, Код_товара, Сценарий) 
	select Код_магазина, Начало_действия, Конец_действия, Код_товара, Код_сценария from #t_raw_Важный_товар

	begin try
		commit tran load_important_goods
		set @msg = concat('Формирование таблицы важного товара завершено. Выгрузка с ', @DateStart, '  по ', @DateEnd); 
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
	end try
	begin catch
		rollback tran load_important_goods
		set @msg = concat('Не удалось сформировать таблицу важного товара. Ошибка: ', error_message(), '. Выгрузка с ', @DateStart, '  по ', @DateEnd);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		return 0;
	end catch

	if @OnlyFact = 1 return;

	-- Обновляем cass.t_fact_Детализация_чеков
	update cass.t_fact_Детализация_чеков
	set Важный_товар = (select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Детализация_чеков.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Детализация_чеков.Дата_добавления_позиции 
					and Конец_действия <= cass.t_fact_Детализация_чеков.Дата_добавления_позиции),
	    Сценарий_важного_товара = (select top 1 Сценарий from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Детализация_чеков.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Детализация_чеков.Дата_добавления_позиции 
					and Конец_действия <= cass.t_fact_Детализация_чеков.Дата_добавления_позиции order by Начало_действия desc)
	from cass.t_fact_Детализация_чеков join cass.t_dim_Кассы on cass.t_fact_Детализация_чеков.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Детализация_чеков.Дата_добавления_позиции >= @DateStart and cass.t_fact_Детализация_чеков.Дата_добавления_позиции >= @DateEnd

	-- Обновляем cass.t_fact_Скидки
	update cass.t_fact_Скидки
	set Важный_товар = (select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Скидки.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Скидки.Дата_применения_скидки 
					and Конец_действия <= cass.t_fact_Скидки.Дата_применения_скидки),
	    Сценарий_важного_товара = (select top 1 Сценарий from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Скидки.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Скидки.Дата_применения_скидки 
					and Конец_действия <= cass.t_fact_Скидки.Дата_применения_скидки order by Начало_действия desc)
	from cass.t_fact_Скидки join cass.t_dim_Кассы on cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Скидки.Дата_применения_скидки >= @DateStart and cass.t_fact_Скидки.Дата_применения_скидки <= @DateEnd

	-- Обновляем cass.t_fact_Сторнированные_позиции
	update cass.t_fact_Сторнированные_позиции
	set Важный_товар = (select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Сторнированные_позиции.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции 
					and Конец_действия <= cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции),
	    Сценарий_важного_товара = (select top 1 Сценарий from dbo.t_fact_Важный_товар where Код_магазина = cass.t_dim_Кассы.Код_магазина and
					cass.t_fact_Сторнированные_позиции.Код_товара = Код_товара and 
					Начало_действия >= cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции 
					and Конец_действия <= cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции order by Начало_действия desc)
	from cass.t_fact_Сторнированные_позиции join cass.t_dim_Кассы on cass.t_fact_Сторнированные_позиции.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции >= @DateStart and cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции <= @DateEnd

	-- Обновляем td.t_fact_Товародвижение
	update td.t_fact_Товародвижение
	set Важный_товар = (select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where Код_магазина = td.t_fact_Товародвижение.Код_магазина and
					td.t_fact_Товародвижение.Код_товара = Код_товара and 
					Начало_действия >= td.t_fact_Товародвижение.Дата 
					and Конец_действия <= td.t_fact_Товародвижение.Дата),
	    Сценарий_важного_товара = (select top 1 Сценарий from dbo.t_fact_Важный_товар where Код_магазина = td.t_fact_Товародвижение.Код_магазина and
					td.t_fact_Товародвижение.Код_товара = Код_товара and 
					Начало_действия >= td.t_fact_Товародвижение.Дата 
					and Конец_действия <= td.t_fact_Товародвижение.Дата order by Начало_действия desc)
	where td.t_fact_Товародвижение.Дата >= @DateStart and td.t_fact_Товародвижение.Дата <= @DateEnd

	-- Обновляем td.t_fact_Продажи_ТСД
	update td.t_fact_Продажи_ТСД
	set Важный_товар = (select top 1 cast(1 as bit) from dbo.t_fact_Важный_товар where Код_магазина = td.t_fact_Продажи_ТСД.Код_магазина and
					td.t_fact_Продажи_ТСД.Код_товара = Код_товара and 
					Начало_действия >= td.t_fact_Продажи_ТСД.Дата 
					and Конец_действия <= td.t_fact_Продажи_ТСД.Дата),
	    Сценарий_важного_товара = (select top 1 Сценарий from dbo.t_fact_Важный_товар where Код_магазина = td.t_fact_Продажи_ТСД.Код_магазина and
					td.t_fact_Продажи_ТСД.Код_товара = Код_товара and 
					Начало_действия >= td.t_fact_Продажи_ТСД.Дата 
					and Конец_действия <= td.t_fact_Продажи_ТСД.Дата order by Начало_действия desc)
	Where td.t_fact_Продажи_ТСД.Дата >= @DateStart and td.t_fact_Продажи_ТСД.Дата <= @DateEnd

END
GO