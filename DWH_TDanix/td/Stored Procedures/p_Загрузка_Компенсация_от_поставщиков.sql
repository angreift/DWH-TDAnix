CREATE PROCEDURE [td].[p_Загрузка_Компенсация_от_поставщиков]

AS
BEGIN

declare @dateChar as char(8)
declare @date as datetime

set @date = dateadd(d,-7,getdate())
set @dateChar = format(@Date, 'yyyyMMdd')
    
delete from td.t_fact_Компенсация_от_поставщиков where Дата>=@datechar -- удаление данных за неделю

declare @str varchar(MAX)

-- ЗАГРУЗКА НОВЫХ ЗАПИСЕЙ
set @str='
insert into td.t_fact_Компенсация_от_поставщиков
select [Код_магазина]
      ,[Код_товара]
      ,[Код_поставщика]
	  ,[Дата]
      ,[Сумма]
from
OpenQuery(rozn,
''SELECT
 case
	when (kompenc.SP6207 is null) 
		or (kompenc.SP6207 = ''''     0   '''') 
			then ''''      999''''
	else klienti.code
 end Код_Магазина, 
 case
	when (kompenc.SP6208 is null) 
		or (kompenc.SP6208 = ''''     0   '''') 
			then ''''      999''''
	else спрТовары.code
 end Код_Товара,
 case
	when (kompenc_Шапка.SP66 is null) 
		or (kompenc_Шапка.SP66 = ''''     0   '''') 
			then ''''      999''''
	else klienti.code
 end [Код_Поставщика],
 CAST(LEFT( Жур.Date_Time_IDDoc,8) as datetime) Дата,
 kompenc.SP6209*(-1) as Сумма
FROM 
  [dt6211] as kompenc (NoLock)
INNER JOIN
  [_1SJourn] as Жур (NoLock) ON Жур.IDDoc=kompenc.IDDoc AND
             Жур.Date_Time_IDDoc >= '''''+ @dateChar+''''' AND Жур.IsMark & 1 = 0   
LEFT JOIN  sc11 спрТовары (NoLock) On спрТовары.ID = kompenc.SP6208
LEFT JOIN  dh6211 as kompenc_Шапка (NoLock) 
			ON kompenc_Шапка.IDDoc=kompenc.IDDoc
left join [SC36] klienti on klienti.id=kompenc.SP6207
'')'

exec(@str)

END
GO
