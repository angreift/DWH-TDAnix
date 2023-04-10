CREATE PROCEDURE [dbo].[p_Формирование_таблицы_LFL]

	@selectDate  date = '19900101'

AS
BEGIN

	SET NOCOUNT ON;

declare
	@date18m date, 
	@date1y date,
	@date date,
	@magaz int

if @selectDate='19900101'
 set @date=dateadd(d,0,getdate()) --текущая дата
else set @date=dateadd(d,0,@selectDate) 
 SET @date18m = dateadd(m,-18,@date) --дата 18мес назад

SET @date1y=dateadd(d,+1,EOMONTH(@date,-13)); -- дата год назад c начала месяца

drop table if exists #mag18m
create table #mag18m (Код_магазина int)


--1. Проверка были ли продажи 18 месяцев назад
insert into #mag18m 
	select Код_магазина
	from cass.v_fact_Детализация_чеков d left join dbo.t_dim_Магазины m on m.Код=d.Код_магазина
	where m.Группа in ('Розница') and Дата_добавления_позиции<=@date18m
	group by Код_магазина

drop table if exists #magTrue
create table #magTrue (Код_магазина int)

-- 2. Проверка продаж год назад (продажи должны быть каждый день)
while (select count(*) from #mag18m)!=0 

begin

set @magaz= (select top 1 Код_магазина from #mag18m)

insert into #magTrue
	select case when count(*)-1=DATEDIFF(d,@date1y,EOMONTH(@date1y)) then @magaz else 0 end
	from
		(select Код_магазина
		from cass.v_fact_Детализация_чеков
		where Код_магазина=@magaz and Дата_добавления_позиции between @date1y and EOMONTH(@date1y)
		group by Дата_добавления_позиции, Код_магазина
		having sum(Итоговая_сумма_после_применения_скидок_с_учетом_возвратов)!=0) as t


delete from #mag18m where Код_магазина=@magaz
end

drop table if exists #lfl
create table #lfl (Дата date, Код_магазина int, lfl bit)

if DATEDIFF(d,dateadd(d,+1,EOMONTH(@date,-1)),@date)>0 --проверка на первое числом месяца

-- 3. Проверка продаж текущего месяца
	while (select count(*) from #magTrue)!=0
	begin

			set @magaz= (select top 1 Код_магазина from #magTrue)

				insert into #lfl
				select @date, @magaz, case when count(*)=DATEDIFF(d,dateadd(d,+1,EOMONTH(@date,-1)),@date) then 1 else 0 end
					from
						(select Код_магазина
						from cass.v_fact_Детализация_чеков
						where Код_магазина=@magaz and Дата_добавления_позиции between dateadd(d,+1,EOMONTH(@date,-1)) and DATEADD(d,-1,@date)
						group by Дата_добавления_позиции, Код_магазина
						having sum(Итоговая_сумма_после_применения_скидок_с_учетом_возвратов)!=0) as t

			delete from #magTrue where Код_магазина=@magaz
	end

else 
	insert into #lfl
		select @date, Код_магазина, 1 from #magTrue

begin tran
	delete from dbo.t_fact_LFL where  Дата=format(@date,'yyyyMM')

	insert into dbo.t_fact_LFL 
		select format(@date,'yyyyMM'), Код_магазина,lfl from #lfl where lfl=1

	insert into dbo.t_fact_LFL 
		select format(@date,'yyyyMM'), Код, 0 
		from dbo.t_dim_Магазины m 
		where m.Группа in ('Розница')   AND Код NOT IN (SELECT КОД_МАГАЗИНА FROM DBO.t_fact_LFL WHERE дата=format(@date,'yyyyMM'))

commit tran
END