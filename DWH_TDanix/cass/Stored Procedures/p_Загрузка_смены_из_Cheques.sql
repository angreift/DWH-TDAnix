CREATE PROCEDURE [cass].[p_Загрузка_смены_из_Cheques]
	@Дата date, @КодКассы int
AS

SET NOCOUNT ON;

begin tran;
delete from cass.t_fact_Смены_на_кассах where Код_кассы = @КодКассы and Дата_начала_смены = @Дата;
insert into cass.t_fact_Смены_на_кассах ([Код_кассы],[Номер_смены],[Дата_начала_смены],[Дата_время_начала_смены],[Дата_время_окончания_смены]
	,[Номер_первого_чека_в_смене],[Номер_последнего_чека_в_смене],[Сумма_продажи],[Сумма_выручки],[Сумма_в_денежном_ящике]
	,[Признак_изменения_данных],[Дата_время_открытия_первого_чека],[Сумма_продажи_наличные],[Сумма_продажи_безналичные]
	,[Сумма_продажи_прочие],[Сумма_выручки_наличные],[Сумма_выручки_безналичные],[Сумма_возвратов],[Сумма_возвратов_наличные]
	,[Сумма_возвратов_безналичные],[Количество_чеков_продажи],[Количество_чеков_возврата],[Составной_код_смены],[Составной_код_кассира]
) values (
	@КодКассы,0,@Дата,@Дата,@Дата,0,0,0,0,0,0,@Дата,0,0,0,0,0,0,0,0,0,0,
	concat('x', format(@Дата, 'yyMMdd'), '~', @КодКассы),concat(@КодКассы, '~x')
)

insert into cass.t_fact_Чеки ([Код_кассы],[Номер_чека],[Дата_закрытия_чека],[Дата_время_открытия_чека],[Дата_время_закрытия_чека]
	,[Сумма_без_скидок],[Итоговая_сумма_со_скидками],[Печать_чека],[Возврат],[Сумма_оплаты_Наличные],[Сумма_оплаты_Терминал]
	,[Сумма_оплаты_СБП_Сбербанк],[Сумма_оплаты_Неинтегрированный_терминал_СБ],[Сумма_оплаты_Накопительные_карты],[Составной_код_смены]
	,[Составной_код_документа],[Составной_код_кассира],[Флаг_закрытия_чека]) 
select 
	@КодКассы,CHEQUE_NUM,cast(DATE_TIME_END as date),DATE_TIME_BEGIN,DATE_TIME_END,CHEQUE_SUM - DISCOUNT,CHEQUE_SUM,
	0, case when CHEQUE_SUM < 0 then 1 else 0 end,case when CHEQUE_SUM < 0 then (PAY_TYPE1 + PAY_TYPE2)*-1 else (PAY_TYPE1 + PAY_TYPE2) end ,
	case when CHEQUE_SUM < 0 then (PAY_TYPE3 + PAY_TYPE4)*-1 else (PAY_TYPE3 + PAY_TYPE4) end,0,0,0,concat('x', format(@Дата, 'yyMMdd'),
	'~', @КодКассы),concat('x', CHEQUE_ID),concat(@КодКассы, '~x'),1
from [olap-rozn].dbo.cheques c
where pos = @КодКассы and cast(DATE_TIME_END as date) = @Дата

insert into cass.t_fact_Детализация_чеков ([Код_кассы],[Код_товара],[Дата_добавления_позиции],[Дата_время_добавления_позиции]
	,[Способ_добавления_позиции],[Количество],[Способ_ввода_количества],[Цена],[Минимальная_цена],[Цена_позиции],[Способ_ввода_цены]
	,[Сумма_скидки],[Начальная_сумма_до_применения_скидок],[Итоговая_сумма_после_применения_скидок],[Номер_позиции_в_чеке]
	,[Сумма_Наличные],[Сумма_Терминал],[Сумма_СБП_Сбербанк],[Сумма_оплаты_Неинтегрированный_терминал_СБ],[Сумма_оплаты_Накопительные_карты]
	,[Возврат],[Составной_код_позиции],[Составной_код_документа],[Составной_код_кассира],[Составной_код_смены])
select
	@КодКассы,GOODS_ID,cast(DATE_TIME_SALE as date),DATE_TIME_SALE,1,QUANTITY,1,coalesce(s.SUM_RESULT/QUANTITY, 0),
	coalesce(s.SUM_RESULT/QUANTITY, 0),coalesce(s.SUM_RESULT/QUANTITY,0),1,SUM_DISCOUNT,case when (s.SUM_RESULT-SUM_DISCOUNT)<0 then  (s.SUM_RESULT-SUM_DISCOUNT)*-1 else (s.SUM_RESULT-SUM_DISCOUNT)end ,
	case when (s.SUM_RESULT-SUM_DISCOUNT)<0 then SUM_RESULT*-1 else SUM_RESULT end,CHEQUE_POSITION, SUM_RESULT, 0,0,0,0, case when s.SUM_RESULT < 0 then 1 else 0 end, 
	concat('x', CHEQUE_POSITION, '~', s.CHEQUE_ID),concat('x', s.CHEQUE_ID), concat(@КодКассы, '~x'),
	concat('x', format(@Дата, 'yyMMdd'), '~', @КодКассы)
from [olap-rozn].dbo.sales s join [olap-rozn].dbo.CHEQUES c on s.CHEQUE_ID = c.CHEQUE_ID 
where (c.POS = @КодКассы and cast(c.DATE_TIME_END as date) = @Дата) and s.SUM_RESULT is not null and s.QUANTITY is not null and s.QUANTITY <> 0

insert into cass.t_fact_Скидки ([Код_кассы],[ИД_скидки],[Код_товара],[Номер_позиции],[Дата_применения_скидки],[Дата_время_применения_скидки]
	,[Объект_скидки],[Номер_скидки],[Режим_скидки],[Тип_скидки],[Ставка_скидки],[Сумма_скидки],[Сумма_чека],[Номер_дисконтной_карты]
	,[Название_дисконтной_карты],[ИД_карты],[Составной_код_позиции],[Составной_код_кассира])
select
	@КодКассы,concat('x', d.CHEQUE_POSITION, '~', d.CHEQUE_ID),s.GOODS_ID,d.CHEQUE_POSITION,cast(s.DATE_TIME_SALE as date),
	s.DATE_TIME_SALE,1,1,2,DISCOUNT_TYPE, PERCENT_DISCOUNT, d.SUM_DISCOUNT, c.CHEQUE_SUM, d.[card], null, null, 
	concat('x', d.CHEQUE_POSITION, '~', s.CHEQUE_ID), concat(@КодКассы, '~x')
from [olap-rozn].dbo.DISCOUNT d
join [olap-rozn].dbo.cheques c on d.CHEQUE_ID = c.CHEQUE_ID
join [olap-rozn].dbo.SALES s on d.CHEQUE_ID = s.CHEQUE_ID and d.CHEQUE_POSITION = s.CHEQUE_POSITION
where c.POS = @КодКассы and cast(c.DATE_TIME_END as date) = @Дата

-- Сразу очистка от дублей

delete from cass.t_fact_Чеки where Составной_код_документа in (
select Составной_код_документа from(select dense_rank() over (partition by Номер_чека, Дата_время_закрытия_чека order by [Составной_код_документа]) [rank], * 
from cass.t_fact_Чеки where Код_кассы = @КодКассы and Дата_закрытия_чека = @Дата) a 
where [rank] >= 2)

commit tran;
RETURN 0
