CREATE PROCEDURE [rprt_cw].p_Распричинивание_потерь

AS
BEGIN

	SET NOCOUNT ON;

declare @date date, @date1 date
set @date=dateadd(d,-8,getdate())

delete from rprt_cw.t_fact_Распричинивание_потерь where Дата>=@date -- очистка таблицы Распричинивание потерь

drop table if exists #temp

create table #temp(Дата date, код_магазина int, код_товара bigint, Дата_пд date, Признак tinyint,Списание bit)

------------------------ Загрузка Фактов Потерь во временную таблицу------------------------ 
while @date<=dateadd(d,-1,getdate())
begin
insert into #temp 
select distinct  fp.Дата,fp.Код_магазина, fp.Код_товара, pd.Дата_пд, td.Признак, 1 Списание
from rprt_cw.t_fact_Факты_потерь fp 
left join (select max(Дата_пд) Дата_пд,Код_магазина,Код_товара
	from td.v_fact_ПД where Дата_ПД<@date group by Код_магазина,Код_товара) pd 
		on pd.Код_товара = fp.код_товара and pd.Код_магазина=fp.код_магазина
left join td.v_fact_Товародвижение td on fp.Дата=td.Дата and fp.Код_товара=td.Код_товара and td.Код_магазина=fp.Код_магазина
where fp.Дата=@date and Списание=1

------------------------ Причина - Недостача------------------------ 

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 17 Код_Причины, null Влияние,  1 Флаг, 0 Списание from rprt_cw.t_fact_Факты_потерь fp
where Списание=0 and fp.Дата=@date
set @date=dateadd(day,+1,@date)
end

------------------------ Причина - Нет ПД------------------------ 

drop table if exists #temp2

create table #temp2(Дата date, код_магазина int, код_товара bigint, Флаг bit)

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
where Дата_пд is null
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1-- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 16 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Не по заявке------------------------ 

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
inner join  td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
where pd.Составной_код_заявки_СТ is null and pd.Составной_код_заявки_РЦ is null
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1-- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 16 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Излишний объем------------------------ 

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_РЦ_строки rc on rc.Составной_код_заявки_РЦ=pd.Составной_код_заявки_РЦ and rc.Код_товара=pd.Код_товара
inner join rprt_cw.t_fact_Приказы_Излишний_объем pib on pib.Номер_приказа=rc.Приказ_с_планом 
where rc.Приказ_с_планом!=0 and pib.Дата<=t.Дата_пд
group by t.Дата, t.код_магазина, t.код_товара

union

select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_СТ_строки st on st.Составной_код_заявки_СТ=pd.Составной_код_заявки_СТ and st.Код_товара=pd.Код_товара
inner join rprt_cw.t_fact_Приказы_Излишний_объем pib on pib.Номер_приказа=st.Приказ_с_планом
where st.Приказ_с_планом!=0 and pib.Дата<=t.Дата_пд
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 1 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причины - Ассортимент ------------------------ 

------------------------ Причина - Инаут -----------------------------

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
inner join td.t_fact_Товарная_матрица tm on tm.Дата between  dateAdd(YEAR, -1, t.Дата) and t.Дата and
	                                 tm.Код_магазина = t.Код_магазина and
									 tm.Код_товара   = t.Код_товара and t.Признак=7
where t.Признак=5 or tm.Признак=5
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 2 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Внематричный ассортимент -----------------------------

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
inner join td.t_fact_Товарная_матрица tm on tm.Дата between  dateAdd(YEAR, -1, t.Дата) and t.Дата and
	                                 tm.Код_магазина = t.Код_магазина and
									 tm.Код_товара   = t.Код_товара and t.Признак=7
where t.Признак=7 and tm.Признак<>5
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 3 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2


------------------------ Причина - Новинка -----------------------------

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t
where Признак=4

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 4 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Промо -----------------------------

truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_СТ_строки st on st.Составной_код_заявки_СТ=pd.Составной_код_заявки_СТ and st.Код_товара=pd.Код_товара
where st.План!=0
group by t.Дата, t.код_магазина, t.код_товара

union

select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_РЦ_строки rc on rc.Составной_код_заявки_РЦ=pd.Составной_код_заявки_РЦ and rc.Код_товара=pd.Код_товара
where rc.План!=0
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 5 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Корректировка УМ -----------------------------

truncate table  #temp2

insert into #temp2
select  t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_СТ_строки st on st.Составной_код_заявки_СТ=pd.Составной_код_заявки_СТ and st.Код_товара=pd.Код_товара
where st.Корректировка!=0
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 6 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причина - Сверхпоставка -----------------------------
truncate table  #temp2

insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
where pd.Количество_план<pd.Количество_факт
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 7 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2

------------------------ Причины - Автозаказ -----------------------------
------------------------ Причина - Критический коэфициент -----------------------------
/*
drop table if exists #temp3

create table #temp3(Дата date, код_магазина int, код_товара bigint, Влияние int, Код_причины tinyint, Флаг bit)

insert into #temp3
select  t.Дата, t.код_магазина, t.код_товара,(st.Заказ*(st.Критический_остаток-1)) Влияние, 13 Код_причины, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_СТ_строки st on st.Составной_код_заявки_СТ=pd.Составной_код_заявки_СТ and st.Код_товара=pd.Код_товара
where st.Критический_остаток>1
group by t.Дата, t.код_магазина, t.код_товара, (st.Заказ*(st.Критический_остаток-1))

union

select t.Дата, t.код_магазина, t.код_товара, (rc.Заказ*(rc.Критический_остаток-1)) Влияние, 12 Код_причины, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_РЦ_строки rc on rc.Составной_код_заявки_РЦ=pd.Составной_код_заявки_РЦ and rc.Код_товара=pd.Код_товара
where rc.Критический_остаток>1
group by t.Дата, t.код_магазина, t.код_товара,(rc.Заказ*(rc.Критический_остаток-1))

insert into #temp3
select  t.Дата, t.код_магазина, t.код_товара,st.Неснижаемый_остаток Влияние, 12 Код_причины, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_СТ_строки st on st.Составной_код_заявки_СТ=pd.Составной_код_заявки_СТ and st.Код_товара=pd.Код_товара
where st.Неснижаемый_остаток>0
group by t.Дата, t.код_магазина, t.код_товара, st.Неснижаемый_остаток

union

select t.Дата, t.код_магазина, t.код_товара, rc.Неснижаемый_остаток Влияние, 12 Код_причины, 1 Флаг from #temp t  
inner join td.v_fact_ПД pd on pd.Код_товара = t.код_товара and pd.Код_магазина=t.код_магазина and t.Дата_Пд=pd.Дата_ПД
inner join td.t_fact_Заявка_РЦ_строки rc on rc.Составной_код_заявки_РЦ=pd.Составной_код_заявки_РЦ and rc.Код_товара=pd.Код_товара
where rc.Неснижаемый_остаток>0
group by t.Дата, t.код_магазина, t.код_товара, rc.Неснижаемый_остаток



delete t from #temp t 
inner join #temp3 t3 on t.Дата=t3.Дата and t.код_магазина=t3.код_магазина and t.код_товара=t3.код_товара 
where t3.Флаг=1-- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, Код_причины,  max(Влияние), Флаг from #temp3 t
group by t.Дата, t.код_магазина, t.код_товара, Код_причины, Флаг*/
truncate table #temp2
insert into #temp2
select t.Дата, t.код_магазина, t.код_товара, 1 Флаг from #temp t  
group by t.Дата, t.код_магазина, t.код_товара

delete t from #temp t 
inner join #temp2 t2 on t.Дата=t2.Дата and t.код_магазина=t2.код_магазина and t.код_товара=t2.код_товара 
where t2.Флаг=1 -- удаляем факты потерь, где нашли причину

insert into [rprt_cw].[t_fact_Распричинивание_потерь]
select Дата, Код_магазина, Код_товара, 14 Код_Причины, null Влияние, Флаг, 1 Списание from #temp2
END
GO
