Create Procedure [dbo].[p_Условный_Вес_Единицы_Изделия]
as
begin

declare @str varchar(max)

set @str='
insert into dbo.t_fact_Условный_Вес_Единицы_Изделия
select Код_товара, Дата_изменения, Значение, Автор
from openquery(rozn, 
''select cast( Товары.Code as numeric(10,0)) Код_товара, SP6636 Дата_Изменения, cast(sp6637 as numeric(10,3)) Значение, sp6638 Автор
from sc6640 УслВес (nolock) 
left join sc11 Товары (nolock) on УслВес.ParentExt=Товары.id where sp6637!=0'') '

begin tran
	truncate table dbo.t_fact_Условный_Вес_Единицы_Изделия
	exec(@str);
commit tran

update cass.t_fact_Детализация_чеков
	set Условный_объем = (SELECT TOP (1) Значение
            FROM            dbo.t_fact_Условный_Вес_Единицы_Изделия
            WHERE       (Код_товара = cass.t_fact_Детализация_чеков.Код_товара) 
						AND (Дата_изменения <= cass.t_fact_Детализация_чеков.Дата_добавления_позиции)
            ORDER BY Дата_изменения DESC)
	from cass.t_fact_Детализация_чеков
	where cass.t_fact_Детализация_чеков.Дата_добавления_позиции >= dateadd(w,-1,getdate()) and cass.t_fact_Детализация_чеков.Дата_добавления_позиции <= dateadd(d,0,getdate())
end
