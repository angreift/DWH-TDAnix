-- =============================================
-- Author:		kma1860
-- Create date: 24/08/2022
-- Description:	Получает значение переменной типа string
-- =============================================
CREATE PROCEDURE [dbo].[p_Получить_значение_переменной_string]
	@ИмяПеременной nvarchar(50),
	@ЗначениеПеременной nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;
	set @ЗначениеПеременной = (
		select
			Значение_string
		from
			t_Переменные
		where
			lower(Наименование_переменной) like lower(@ИмяПеременной)
	)
	return
END
