﻿-- =============================================
-- Author:		kma1860
-- Create date: 24/08/2022
-- Description:	Инициализирует и задает значение переменной определенного типа
-- =============================================
CREATE PROCEDURE [dbo].[p_Установить_значение_переменной]
	@ИмяПеременной nvarchar(50),
	@ТипПеременной nvarchar(50),
	@ЗначениеПеременной nvarchar(4000)
AS
BEGIN
	SET NOCOUNT ON;

	declare @ТипПеременнойОпределен bit;
	set @ТипПеременнойОпределен = 0;

	-- Если в таблице с переменными нет строки с таким названием переменной, то добавим ее

	if (select count(*) from t_Переменные where Наименование_переменной like @ИмяПеременной) = 0 
		insert into t_Переменные (Наименование_переменной) values (@ИмяПеременной)

	-- Типы переменных принимаются string, int, datetime
	if lower(@ТипПеременной) like 'string'
		begin
			update t_переменные set Значение_string = @ЗначениеПеременной where lower(Наименование_переменной) like lower(@ИмяПеременной);
			set @ТипПеременнойОпределен = 1;
		end
	if lower(@ТипПеременной) like 'int'
		begin
			update t_переменные set Значение_int = cast(@ЗначениеПеременной as int) where lower(Наименование_переменной) like lower(@ИмяПеременной)
			set @ТипПеременнойОпределен = 1;
		end
	if lower(@ТипПеременной) like 'datetime'
		begin
			update t_переменные set Значение_datetime = cast(@ЗначениеПеременной as datetime) where lower(Наименование_переменной) like lower(@ИмяПеременной)
			set @ТипПеременнойОпределен = 1;
		end

	-- Если переменная не была установлена, то был принят неизвестный тип
	if @ТипПеременнойОпределен = 0 print(
		concat(
			'Не удалось определить тип "',
			trim(@ТипПеременной),
			'". Ожидается: string, int, datetime'
		)
	) else print(
		concat(
			'Значение переменной "',
			trim(@ИмяПеременной),
			'" типа "',
			trim(@ТипПеременной),
			'" успешно задано.'
		)
	)
	Return @ТипПеременнойОпределен
END
