﻿-- =============================================
-- Author:		kma1860
-- Create date: 23/09/2022
-- Description:	Получает последние 1000 записей по кассе с ошибками
-- =============================================
CREATE PROCEDURE [cass].[p_Ошибки_по_кассе]
	@Код_кассы int
AS BEGIN
    SELECT TOP (1000) [Код_события]
          ,[Дата_время_события]
          ,[Тип_события]
          ,[Наименование_объекта]
          ,[Сообщение]
          ,[Имя_пользователя]
      FROM [dbo].[v_j_Общий_журнал_ошибки]
      WHERE Сообщение like '%Код кассы: ' + cast(@Код_кассы as nvarchar) + '%'
      ORDER BY Код_события DESC
END