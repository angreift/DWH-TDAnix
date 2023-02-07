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

	-- Если даты не указаны, то формируем с начала прошлого месяца по текущее число включительно
	if @DateStart is null set @DateStart = dateadd(day, 1, eomonth(getdate(), -2));
	if @DateEnd   is null set @DateEnd   = getdate();

	begin tran load_important_goods

	-- Удалим данные за период выгрузки
	Delete from dbo.t_fact_Поставщики_холдинга where Дата >= @DateStart and Дата <= @DateEnd;

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
END
GO