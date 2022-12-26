
CREATE PROCEDURE [td].[p_Загрузка_Товарной_матрицы] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @str nvarchar(max), @date varchar(8), @date1 varchar(8);
set @date = format(getdate(), 'yyyyMMdd');
set @date1 = format(dateadd(d, -90, getdate()), 'yyyyMMdd');

set @str = '
select 
	 дата, Код_магазина,	Код_поставщика,		Код_товара,		cast(Признак as tinyint) признак
from openquery (rozn,
	
''
select 

c1721_vv.date дата,
		cast(c1721_vv.value as numeric(1,0)) Признак,
	cast(СпрПоставщики.Code as bigint) Код_поставщика,
	cast(спрТовары.Code as bigint) Код_товара,
	cast(спрМагазины.Code as bigint) Код_магазина
	
from 
	_1sconst as c1721_vv (nolock) left join
		sc1725 СпрТоварМатрица (NoLock) on СпрТоварМатрица.ID=c1721_vv.objid
	Left Join
		sc11 спрТовары (NoLock) On спрТовары.ID = спрТоварМатрица.ParentExt
	Left Join
		sc1718 спрАссМатрицы (NoLock) On спрАссМатрицы.ID = спрТоварМатрица.sp3600 
	Left Join
		sc36 спрМагазины (NoLock) On спрМагазины.ID = спрАссМатрицы.sp1746 
	Left Join
		sc36 СпрПоставщики (NoLock) On СпрПоставщики.ID = СпрТоварМатрица.sp1816 
		
where	
		(c1721_vv.date between '''''+@date1+''''' and '''''+@date+''''') and
		c1721_vv.id = 1721 and
		cast(СпрТовары.Code as bigint)< 2000000000 and
		cast(СпрТовары.Code as bigint)>0 and
		спрТовары.Code is not null and
		спрМагазины.Code is not null and
		c1721_vv.value is not null and
		c1721_vv.objid = спрТоварМатрица.ID
		order by c1721_vv.date desc, c1721_vv.time desc, c1721_vv.docid desc, c1721_vv.row_id desc
'') 
';
begin tran
	delete from td.t_fact_Товарная_матрица
		where Дата >=@date1
	insert into td.t_fact_Товарная_матрица (дата, Код_магазина,	Код_поставщика,		Код_товара,		Признак)
	exec(@str);
commit tran
END

