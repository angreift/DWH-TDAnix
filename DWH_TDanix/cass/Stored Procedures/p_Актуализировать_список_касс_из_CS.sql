-- =============================================
-- Author:		kma1860
-- Create date: 23/09/2022
-- Description:	Актуализация списка касс
-- =============================================
CREATE PROCEDURE [cass].[p_Актуализировать_список_касс_из_CS]
AS
BEGIN
	merge
		cass.t_dim_Кассы as к1
	using
		[S19-STORAGE-SQL].[CS].[dbo].[v_Измерение_кассы] as к2
	on 
		к1.Код_кассы = к2.Код_кассы
	when matched then
		update set к1.IP_Адрес = к2.IP_Адрес,
				   к1.Включена = к2.Включена,
				   к1.Код_магазина = к2.Код_магазина,
				   к1.UserBind = 'Auto update'
	when not matched then
		insert (Код_кассы,    IP_Адрес,    Включена,    Код_магазина,    UserBind)
		values (к2.Код_кассы, к2.IP_Адрес, к2.Включена, к2.Код_магазина, 'Auto update');
END