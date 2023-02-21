-- =============================================
-- Author:		kma1860
-- Create date: 21/02/2023
-- Description:	Возвращает сумму скидки на товары (Запрос от Лизы Чернцовой)
-- =============================================
CREATE FUNCTION cass.f_rsc_Получить_сумму_скидок_на_период 
(	
	@DateStart date, @DateEnd date
)
RETURNS TABLE 
AS
RETURN 
(
	select
		sum(Сумма_скидки) SummDiscount,
		м.Код CodeMag,
		т.Код_группы CodeGroup
	from cass.t_fact_Детализация_чеков д
	join cass.t_dim_Кассы к on д.Код_кассы = к.Код_кассы
	join dbo.t_dim_Магазины м on к.Код_магазина = м.Код
	join dbo.t_dim_Товары т on д.Код_товара = т.Код_товара
	where д.Дата_добавления_позиции >= @DateStart and д.Дата_добавления_позиции <= @DateEnd and м.Группа in ('Розница', 'РС Закрытые')
	group by м.Код, т.Код_группы
)
GO
