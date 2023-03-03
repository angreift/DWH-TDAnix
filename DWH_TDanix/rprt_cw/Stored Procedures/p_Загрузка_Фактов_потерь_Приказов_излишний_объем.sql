CREATE PROCEDURE [rprt_cw].[p_Загрузка_Фактов_потерь_Приказов_излишний_объем]

AS BEGIN

declare @dateStart date, @dateEnd date
set @dateStart=dateadd(d, -8, getdate())
set @dateEnd=dateadd(d,-1,getdate())

delete from  rprt_cw.t_fact_Факты_потерь where Дата between @dateStart and @dateEnd --очистка Фактов потерь за неделю

insert into rprt_cw.t_fact_Факты_потерь(Дата, Код_магазина, Код_товара, Сумма, Количество, Списание) --загрузка Фактов потерь за неделю
select тд.Дата, тд.[Код_магазина], тд.Код_товара, sum(тд.СуммаЗакупаСоСклада), sum(Количество), 1
FROM td.v_fact_Товародвижение as ТД	
where (тд.Дата between @dateStart and @dateEnd) and Количество!=0 and  Количество is not null and Код_причины in(9,10,12,13,21,26,32,81,143)
group by тд.Дата, тд.[Код_магазина], тд.Код_товара
having sum(тд.СуммаЗакупаСоСклада)!=0 and sum(тд.Количество)!=0

insert into rprt_cw.t_fact_Факты_потерь(Дата, Код_магазина, Код_товара, Сумма, Количество, Списание) --загрузка Фактов потерь за неделю
select тд.Дата, тд.[Код_магазина], тд.Код_товара, sum(тд.СуммаЗакупаСоСклада), sum(Количество),0
FROM td.v_fact_Товародвижение ТД	
where (тд.Дата between @dateStart and @dateEnd) and Количество!=0 and  Количество is not null and Код_причины in(42,19,17)
group by тд.Дата, тд.[Код_магазина], тд.Код_товара
having sum(тд.СуммаЗакупаСоСклада)!=0 and sum(тд.Количество)!=0


truncate table rprt_cw.t_fact_Приказы_Излишний_объем --удаление Приказов излишний объем

insert into rprt_cw.t_fact_Приказы_Излишний_объем --загрука Приказов излишний объем из ОТБРС
select cast(sp1760 as date), sp1761, sp65 from Rozn.rozn.dbo.DH1769 where SP1764='     P   '

END