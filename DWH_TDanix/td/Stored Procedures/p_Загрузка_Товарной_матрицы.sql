

CREATE PROCEDURE [td].[p_Загрузка_Товарной_матрицы] 
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN
declare @str nvarchar(max), @date varchar(8), @date1 varchar(8);
set @date =concat( cast(DATEPART(YEAR, getdate()) as varchar),
					right('0' + cast(DATEPART(MONTH, getdate())as varchar), 2),
					right('0' + cast(DATEPART(day, getdate()) as varchar), 2));

set @date1 =concat( cast(DATEPART(YEAR, dateadd(d, -30, getdate())) as varchar),
					right('0' + cast(DATEPART(MONTH, dateadd(d, -30, getdate())) as varchar), 2),
					right('0' + cast(DATEPART(day, dateadd(d, -30, getdate())) as varchar), 2));

set @str = '
select 
	 дата, Код_магазина,	Код_поставщика,		Код_товара,		cast(Признак as tinyint) признак
from openquery (rozn,
	
''
select СпрТоварМатрица.SP1723 дата,
		cast(c1721_vv.value as numeric(1,0)) Признак,
	cast(СпрПоставщики.Code as int) Код_поставщика,
	cast(спрТовары.Code as int) Код_товара,
	cast(спрМагазины.Code as int) Код_магазина
	

from 
	_1sconst as c1721_vv (nolock) left join
		sc1725 СпрТоварМатрица (NoLock) on СпрТоварМатрица.SP1723=c1721_vv.date
	Left Join
		sc11 спрТовары (NoLock) On спрТовары.ID = спрТоварМатрица.ParentExt
	Left Join
		sc1718 спрАссМатрицы (NoLock) On спрАссМатрицы.ID = спрТоварМатрица.sp3600 
	Left Join
		sc36 спрМагазины (NoLock) On спрМагазины.ID = спрАссМатрицы.sp1746 
	Left Join
		sc36 СпрПоставщики (NoLock) On СпрПоставщики.ID = СпрТоварМатрица.sp1816 
		
where(
		(СпрТоварМатрица.SP1723 between '''''+@date1+''''' and '''''+@date+''''') and 
		c1721_vv.id = 1721 and
		cast(СпрТовары.Code as bigint)< 2000000000 and
		cast(СпрТовары.Code as bigint)>0 and
		спрТовары.Code is not null and
		спрМагазины.Code is not null and
		c1721_vv.value is not null and
		c1721_vv.objid = спрТоварМатрица.ID and
		c1721_vv.date =СпрТоварМатрица.SP1723)
		order by c1721_vv.date desc, c1721_vv.time desc, c1721_vv.docid desc, c1721_vv.row_id desc
'') 
';
delete from td.t_fact_Товарная_матрица
	where Дата >=@date1
insert into td.t_fact_Товарная_матрица (
дата, Код_магазина,	Код_поставщика,		Код_товара,		Признак)
	
exec(@str);

END
