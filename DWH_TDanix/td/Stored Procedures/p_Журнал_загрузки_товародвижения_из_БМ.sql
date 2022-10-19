CREATE PROCEDURE [td].[p_Журнал_загрузки_товародвижения_из_БМ]
	@Только_ошибки bit = 0
AS BEGIN
	select 
		* 
	from 
		dbo.t_j_Общий_журнал with (nolock)
	where 
		((@Только_ошибки = 1 and Тип_события = 1) or (@Только_ошибки = 0)) and 
		Наименование_объекта = 'td.p_Загрузка_товародвижения' 
	order by Код_события desc
END
