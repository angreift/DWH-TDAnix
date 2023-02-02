-- =============================================
-- Author:		kma1860
-- Create date: 01/02/2023
-- Description:	Объединение однородных процедур в одну: загружает сырые данные в таблицы RAW
-- =============================================
CREATE PROCEDURE [dbo].[p_Загрузить_данные_в_RAW]
	@Table nvarchar(max), @Version int, @SubCode int, @DateExecStr nvarchar(6), @TimeStamp int, @DateStartStr nvarchar(6),
	@DateEndStr nvarchar(6), @Data nvarchar(max), @EndFlag bit null
AS BEGIN
	Declare @DateExec date, @DateStart date, @DateEnd date, @SQL nvarchar(max), @ParamDef nvarchar(max);

	-- Преобразуем текстовые даты к date 
	Set @DateExec  = cast('20' + @DateExecStr  as date);
	Set @DateStart = cast('20' + @DateStartStr as date);
	Set @DateEnd   = cast('20' + @DateEndStr   as date);

	Set @SQL = 'Insert into ' + @Table + ' (Дата_время, Version, Subcode, DateExec, TimeStamp, DateStart, DateEnd, Data, EndFlag) 
				values (GetDate(), @Version, @Subcode, @DateExec, @TimeStamp, @DateStart, @DateEnd, @Data, @EndFlag)';
	Set @ParamDef = '@Version int, @SubCode int, @DateExec date, @TimeStamp int, @DateStart date,
					 @DateEnd date, @Data nvarchar(max), @EndFlag bit';
	
	exec sp_executesql @SQL, @ParamDef, @Version = @Version, @SubCode = @SubCode, @DateExec = @DateExec, @TimeStamp = @TimeStamp,
					   @DateStart = @DateStart, @DateEnd = @DateEnd, @Data = @Data, @EndFlag = @EndFlag;
END
GO