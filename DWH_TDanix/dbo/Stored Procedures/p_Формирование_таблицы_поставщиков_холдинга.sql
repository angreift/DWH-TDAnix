-- =============================================
-- Author:		kma1860
-- Create date: 03/02/2023
-- Description:	Формирование таблицы поставщиков холдинга на основе ПД из магазинов, 
--              заполнение поля Поставщик холдинга в t_fact
-- =============================================
CREATE PROCEDURE [dbo].[p_Формирование_таблицы_поставщиков_холдинга]
	@DateStart date = null, @DateEnd date = null, @OnlyFact bit = null
AS BEGIN

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для записи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	-- Если даты не указаны, то формируем с начала прошлого месяца по текущее число включительно
	if @DateStart is null set @DateStart = dateadd(day, 1, eomonth(getdate(), -2));
	if @DateEnd   is null set @DateEnd   = getdate();

	begin tran load_pr_pr

	-- Удалим данные за период выгрузки
	Delete from dbo.t_fact_Поставщики_холдинга where Дата >= @DateStart and Дата <= @DateEnd;

	-- Вставляем новые данные
	insert into 
		dbo.t_fact_Поставщики_холдинга (Дата, Код_магазина, Код_товара, Поставщик_холдинга) 
	select 
		min(Дата_ПД) Дата, Код_магазина, Код_товара, Поставщик_холдинга
	from 
		td.t_fact_ПД_шапки ш join td.t_fact_ПД_строки с on ш.Составной_код_ПД = с.Составной_код_ПД
	where Дата_ПД >= @DateStart	and Дата_ПД <= @DateEnd
	group by Код_магазина, Код_товара, Поставщик_холдинга

	begin try
		commit tran load_pr_pr
		set @msg = concat('Формирование таблицы поставщиков холдинга завершено. Выгрузка с ', @DateStart, '  по ', @DateEnd); 
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
	end try
	begin catch
		rollback tran load_pr_pr
		set @msg = concat('Не удалось сформировать таблицу поставщиков холдинга. Ошибка: ', error_message(), '. Выгрузка с ', @DateStart, '  по ', @DateEnd);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		return 0;
	end catch

	if @OnlyFact = 1 return;

	-- Обновляем cass.t_fact_Детализация_чеков
	update cass.t_fact_Детализация_чеков
	set Поставщик_холдинга = (SELECT TOP (1) Поставщик_холдинга
            FROM            dbo.t_fact_Поставщики_холдинга
            WHERE        (Код_магазина = cass.t_dim_Кассы.Код_магазина) AND (Код_товара = cass.t_fact_Детализация_чеков.Код_товара) 
						AND (Дата <= cass.t_fact_Детализация_чеков.Дата_добавления_позиции)
            ORDER BY Дата DESC)
	from cass.t_fact_Детализация_чеков join cass.t_dim_Кассы on cass.t_fact_Детализация_чеков.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Детализация_чеков.Дата_добавления_позиции >= @DateStart and cass.t_fact_Детализация_чеков.Дата_добавления_позиции <= @DateEnd

	-- Обновляем cass.t_fact_Скидки
	update cass.t_fact_Скидки
	set Поставщик_холдинга = (SELECT TOP (1) Поставщик_холдинга
            FROM            dbo.t_fact_Поставщики_холдинга
            WHERE        (Код_магазина = cass.t_dim_Кассы.Код_магазина) AND (Код_товара = cass.t_fact_Скидки.Код_товара) 
						AND (Дата <= cass.t_fact_Скидки.Дата_применения_скидки)
            ORDER BY Дата DESC)
	from cass.t_fact_Скидки join cass.t_dim_Кассы on cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Скидки.Дата_применения_скидки >= @DateStart and cass.t_fact_Скидки.Дата_применения_скидки <= @DateEnd

	-- Обновляем cass.t_fact_Сторнированные_позиции
	update cass.t_fact_Сторнированные_позиции
	set Поставщик_холдинга = (SELECT TOP (1) Поставщик_холдинга
            FROM            dbo.t_fact_Поставщики_холдинга
            WHERE        (Код_магазина = cass.t_dim_Кассы.Код_магазина) AND (Код_товара = cass.t_fact_Сторнированные_позиции.Код_товара) 
						AND (Дата <= cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции)
            ORDER BY Дата DESC)
	from cass.t_fact_Сторнированные_позиции join cass.t_dim_Кассы on cass.t_fact_Сторнированные_позиции.Код_кассы = cass.t_dim_Кассы.Код_кассы
	where cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции >= @DateStart and cass.t_fact_Сторнированные_позиции.Дата_сторнирования_позиции <= @DateEnd

	-- Обновляем td.t_fact_Товародвижение
	update td.t_fact_Товародвижение
	set Поставщик_холдинга = (SELECT TOP (1) Поставщик_холдинга
            FROM            dbo.t_fact_Поставщики_холдинга
            WHERE        (Код_магазина = td.t_fact_Товародвижение.Код_магазина) AND (Код_товара = td.t_fact_Товародвижение.Код_товара) 
						AND (Дата <= td.t_fact_Товародвижение.Дата)
            ORDER BY Дата DESC)
	where td.t_fact_Товародвижение.Дата >= @DateStart and td.t_fact_Товародвижение.Дата <= @DateEnd

	-- Обновляем td.t_fact_Продажи_ТСД
	update td.t_fact_Продажи_ТСД
	set Поставщик_холдинга = (SELECT TOP (1) Поставщик_холдинга
            FROM            dbo.t_fact_Поставщики_холдинга
            WHERE        (Код_магазина = td.t_fact_Продажи_ТСД.Код_магазина) AND (Код_товара = td.t_fact_Продажи_ТСД.Код_товара) 
						AND (Дата <= td.t_fact_Продажи_ТСД.Дата)
            ORDER BY Дата DESC)
	Where td.t_fact_Продажи_ТСД.Дата >= @DateStart and td.t_fact_Продажи_ТСД.Дата <= @DateEnd

END
