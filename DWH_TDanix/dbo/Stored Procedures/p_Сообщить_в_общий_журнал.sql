-- =============================================
-- Author:		kma1860
-- Create date: 24/08/2022
-- Description:	Добавляет информацию в общий журнал
-- =============================================
CREATE PROCEDURE [dbo].[p_Сообщить_в_общий_журнал]
	@ТипСобытия tinyint, 
	@НаименованиеОбъекта nvarchar(128),
	@Сообщение nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	begin try
		insert into	t_j_Общий_журнал (
			[Дата_время_события],
			[Тип_события],
			[Наименование_объекта],
			[Сообщение],
			[Имя_пользователя]
		) values (
			getdate(),
			@ТипСобытия,
			@НаименованиеОбъекта,
			@Сообщение,
			SYSTEM_USER
		)
	end try
	begin catch
		print(
			concat(
				'Не удалось добавить информацию в журнал. ',
				error_message()
			)
		)
	end catch
	if @ТипСобытия = 1 raiserror(@Сообщение, 11, 1);
END
