﻿-- =============================================
-- Author:		kma1860
-- Create date: 23/09/2022
-- Description:	Актуализация списка касс
-- =============================================
CREATE PROCEDURE [cass].[p_Актуализировать_список_касс_из_CS]
AS
BEGIN
	drop table if exists #cass_list_from_CS

	create table #cass_list_from_CS (
		IP_Адрес nvarchar(15),
		Код_магазина int,
		Код_кассы int,
		Код_типа_кассы nvarchar(7)
	)
	
	insert into #cass_list_from_CS
	select 
		pos_addr as IP_Адрес,
		cashcode / 100 as Код_магазина,
		cashcode as Код_кассы,
		postype as Код_типа_кассы
	from openquery(
		[SERV-ARTIX],
		'select cashcode, pos_addr, postype from rs_pos_sales.status where ping = 1 or sshport = 1'
	)
	update cass.t_dim_Кассы set Включена = 0;
	merge
		cass.t_dim_Кассы as к1
	using
		#cass_list_from_CS as к2
	on 
		к1.Код_кассы = к2.Код_кассы
	when matched then
		update set к1.IP_Адрес = к2.IP_Адрес,
				   к1.Включена = 1,
				   к1.Код_магазина = к2.Код_магазина,
				   к1.UserBind = 'Auto update',
				   к1.Код_типа_кассы = к2.Код_типа_кассы
	when not matched then
		insert (Код_кассы,    IP_Адрес,    Включена,    Код_магазина,    UserBind,      Код_типа_кассы)
		values (к2.Код_кассы, к2.IP_Адрес, 1,           к2.Код_магазина, 'Auto update', к2.Код_типа_кассы);

	declare cur cursor local for select Код_кассы from cass.t_dim_Кассы
	declare @cid int, @r bit, @IP_Адрес nvarchar(15);
	open cur
	fetch next from cur into @cid
	while @@fetch_status = 0 begin
	set @IP_Адрес = (select IP_Адрес from cass.t_dim_Кассы where Код_кассы = @cid);
		exec [dbo].[p_Регистрация_ODBC_подключения] @cid, @IP_Адрес, @R output;
		fetch next from cur into @cid
	end
END