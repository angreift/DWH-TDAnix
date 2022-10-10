
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [td].[p_Загрузка_Товарной_матрицы] 
	-- Add the parameters for the stored procedure here
	
	@dateInput datetime
AS
BEGIN
	declare @str nvarchar(max), @dateSQL2000 varchar(8);

set @dateSQL2000 = concat( cast(DATEPART(YEAR, @dateInput) as varchar),
					right('0' + cast(DATEPART(MONTH, @dateInput)as varchar), 2),
					right('0' + cast(DATEPART(day, @dateInput) as varchar), 2));
set @str = '
select 
	 ''' + @dateSQL2000 + ''' дата, Код_магазина,	Код_поставщика,		Код_товара,		cast(Признак as tinyint) признак
from openquery (rozn,
	
''
select (
	select top 1
		cast(c1721_vv.value as numeric(1, 0))
	from
		_1sconst as c1721_vv (nolock)
	where
		
		c1721_vv.id = 1721 and
		c1721_vv.objid = спрТоварМатрица.ID and
		c1721_vv.date <= ''''' + @dateSQL2000 + '''''
		order by c1721_vv.date desc, c1721_vv.time desc, c1721_vv.docid desc, c1721_vv.row_id desc
		)  Признак,
	cast(СпрПоставщики.Code as int) Код_поставщика,
	спрТовары.Code Код_товара,
	спрМагазины.Code Код_магазина
	

from 
		sc1725 СпрТоварМатрица (NoLock)
	Left Join
		sc11 спрТовары (NoLock) On спрТовары.ID = спрТоварМатрица.ParentExt
	Left Join
		sc1718 спрАссМатрицы (NoLock) On спрАссМатрицы.ID = спрТоварМатрица.sp3600 
	Left Join
		sc36 спрМагазины (NoLock) On спрМагазины.ID = спрАссМатрицы.sp1746 
	Left Join
		sc36 СпрПоставщики (NoLock) On СпрПоставщики.ID = СпрТоварМатрица.sp1816 
		

Where (
	(select top 1
		cast(c1721_vv.value as numeric(1, 0))
	from
		_1sconst as c1721_vv (nolock) 
	where
		c1721_vv.id = 1721 and
		c1721_vv.value is not null and
		c1721_vv.objid = спрТоварМатрица.ID and
		c1721_vv.date<= ''''' + @dateSQL2000 + '''''

		order by c1721_vv.date desc, c1721_vv.time desc, c1721_vv.docid desc, c1721_vv.row_id desc
) 

		IN (''''2'''',''''3'''',''''4'''',''''6'''',''''9''''))
		
'') 
';
delete from td.t_fact_Товарная_матрица
	where Дата = cast(@dateInput as date)
insert into td.t_fact_Товарная_матрица (
	дата, Код_магазина,	Код_поставщика,		Код_товара,		Признак
) 
exec(@str);

END
