-- =============================================
-- Author:		kma1860
-- Create date: 23/03/2023
-- Description:	Загрузка плановых показателей из ОТБРС 
-- =============================================
CREATE PROCEDURE [plan].[p_Загрузка_плановых_показателей_по_группам]
	@DateStart date = null, @DateEnd date = null
AS BEGIN

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для записи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры
	declare @query        nvarchar(max);

	-- Если даты не указаны, то формируем с начала прошлого месяца по текущее число включительно
	if @DateStart is null set @DateStart = dateadd(day, 1, eomonth(getdate(), -2));
	if @DateEnd   is null set @DateEnd   = getdate();

	-- Загрузим новые данные

	set @query = '
		Select 
			Дата, Код_магазина, Код_группы, Код_показателя_планирования, Значение
			from openquery([rozn], ''
		select
			CAST(LEFT(Жур.Date_Time_IDDoc, 8) as DateTime) as Дата,
			cast(СпрК.Code as int) Код_магазина,
			СпрТ.Code Код_группы,
			СпрПоказатели.Code Код_показателя_планирования,
			ДокС.SP5897 Значение
		from
			dt5069 ДокС (nolock)
		inner join 
			dh5069 Док (nolock) on ДокС.IDDoc = Док.IDDoc
		inner join 
			_1SJourn Жур (nolock) on Жур.IDDoc = Док.IDDoc and Жур.IsMark = 0
		join 
			sc11 СпрТ (nolock) on ДокС.sp5898 = СпрТ.ID
		join
			sc36 СпрК (nolock) on Док.sp5065 = СпрК.ID
		join
			sc5895 СпрПоказатели (nolock) on ДокС.sp5896 = СпрПоказатели.ID
		where Жур.Date_Time_IDDoc between ''''' + format(@DateStart, 'yyyyMMdd') + ''''' and ''''' + format(@DateEnd, 'yyyyMMddZ') + ''''' '') ';

	Drop table if exists #t_raw_Плановые_показатели_по_группам

	Create table #t_raw_Плановые_показатели_по_группам (
		[Дата] date not null,
		[Код_магазина] int not null,
		[Код_группы] bigint not null,
		[Код_показателя_планирования] int not null,
		[Значение] decimal(15,4) null  
	)

	Insert into #t_raw_Плановые_показатели_по_группам (
		Дата, Код_магазина, Код_группы, Код_показателя_планирования, Значение
	) exec(@query);

	begin tran load_plan_otbrs

	-- Удалим данные за период выгрузки
	Delete from [plan].[t_fact_Плановые_показатели_по_группам] where Дата >= @DateStart and Дата <= @DateEnd;

	-- Полученные данные сохраним в основной таблице
	insert into [plan].[t_fact_Плановые_показатели_по_группам]
		(Дата, Код_магазина, Код_группы, Код_показателя_планирования, Значение) 
	select Дата, Код_магазина, Код_группы, Код_показателя_планирования, Значение from #t_raw_Плановые_показатели_по_группам

	begin try
		commit tran load_plan_otbrs
		set @msg = concat('Загрузка планов по группам завершена. Выгрузка с ', @DateStart, '  по ', @DateEnd); 
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
	end try
	begin catch
		rollback tran load_plan_otbrs
		set @msg = concat('Не удалось загрузить планы по группам. Ошибка: ', error_message(), '. Выгрузка с ', @DateStart, '  по ', @DateEnd);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		return 0;
	end catch

END
GO