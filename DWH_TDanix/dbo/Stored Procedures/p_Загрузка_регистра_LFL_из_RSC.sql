CREATE PROCEDURE [dbo].[p_Загрузка_регистра_LFL_из_RSC]
as
begin
drop table if exists #lflRSC
create table #lflRSC (Дата varchar(10), Код_магазина int, LFL bit)

insert into #lflRSC
select format(Дата,'yyyyMM') Дата, Код_магазина, LFL
from openquery([S12-1C-RSC],'
select convert(date, convert(varchar, dateadd(yyyy,-2000, _Fld7929),112)) Дата, _Code Код_магазина, cast(_fld7931 as bit) LFL
from rsc.dbo._InfoRg7928 a left join rsc.dbo._Reference129 b on b._IDRref=a._Fld7930RRef')

merge 
		dbo.t_fact_LFL
	using 
		#LFLRSC
	on 
		dbo.t_fact_LFL.Дата = #lflRSC.Дата and
		dbo.t_fact_LFL.Код_магазина = #lflRSC.Код_магазина


	when 
		matched 
	then 
		update 
	set 
		dbo.t_fact_LFL.LFL = #lflRSC.LFL;
end