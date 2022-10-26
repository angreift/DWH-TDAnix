-- =============================================
-- Author:		kma1860
-- Create date: 11/10/2022
-- Description:	Загружает движения регистра из базы магазина в промежуточную таблицу
-- =============================================
CREATE PROCEDURE [td].[p_Синхронизация_начальных_остатков]
	@Str nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	if cast(left(@str, 2) as int) < 1 begin
		print('Too old exchange version. Need at least 02');
		return 0;
	end;
	Declare @ДатаВыгрузки date, @Код_магазина int, @Отпечаток_времени int;

	set @ДатаВыгрузки = '20' + substring(@Str, 3, 6);
	set @Код_магазина = cast(substring(@Str, 9, 4) as int);
	set @Отпечаток_времени = cast(substring(@Str, 13, 6) as int);
	Insert into [td].[t_raw_Данные_начальных_остатков_из_магазинов] (
		[Дата_время], [Дата_выгрузки], [Data], [Код_магазина], [Отпечаток_времени]
	) values (
		getDate(), @ДатаВыгрузки, @Str, @Код_магазина, @Отпечаток_времени
	)
END
GO


