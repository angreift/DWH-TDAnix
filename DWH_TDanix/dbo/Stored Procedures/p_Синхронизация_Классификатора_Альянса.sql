-- =============================================
-- Author:		kma1860
-- Create date: 23/01/2023
-- Description:	Загружает данные о классификаторе Альянса в промежуточную таблицу
-- =============================================
CREATE PROCEDURE [dbo].[p_Синхронизация_Классификатора_Альянса]
	@Str nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	if cast(left(@str, 2) as int) < 1 begin
		print('Too old exchange version. Need at least 01');
		return 0;
	end;
	Declare @ДатаВыгрузки date, @Отпечаток_времени int;

	set @ДатаВыгрузки = '20' + substring(@Str, 3, 6);
	set @Отпечаток_времени = cast(substring(@Str, 9, 6) as int);
	Insert into [dbo].[t_raw_Классификатор_Альянс] (
		[Дата_время], [Дата_выгрузки], [Data], [Отпечаток_времени]
	) values (
		getDate(), @ДатаВыгрузки, @Str, @Отпечаток_времени
	)
END
GO