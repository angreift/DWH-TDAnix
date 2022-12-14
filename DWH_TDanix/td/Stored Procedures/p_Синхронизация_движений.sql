-- =============================================
-- Author:		kma1860
-- Create date: 11/10/2022
-- Description:	Загружает движения регистра из базы магазина в промежуточную таблицу
-- =============================================
CREATE PROCEDURE [td].[p_Синхронизация_движений]
	@Str nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	if cast(left(@str, 2) as int) < 2 begin
		print('Too old exchange version. Need at least 02');
		return 0;
	end;
	Declare @ДатаВыгрузки date, @Выгрузка_при_ЗОД bit, @Код_магазина int, @Отпечаток_времени int;

	set @ДатаВыгрузки = '20' + substring(@Str, 3, 6);
	if substring(@Str, 9, 1) = 'Z' set @Выгрузка_при_ЗОД = 1 else set @Выгрузка_при_ЗОД = 0;
	set @Код_магазина = cast(substring(@Str, 10, 4) as int);
	set @Отпечаток_времени = cast(substring(@Str, 14, 6) as int);
	Insert into [td].[t_raw_Данные_товародвижения_из_магазинов] (
		[Дата_время], [Дата_выгрузки], [Выгрузка_из_ЗОД], [Data], [Код_магазина], [Отпечаток_времени]
	) values (
		getDate(), @ДатаВыгрузки, @Выгрузка_при_ЗОД, @Str, @Код_магазина, @Отпечаток_времени
	)
END
GO


