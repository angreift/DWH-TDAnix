
-- =============================================
-- Author:		kma1860
-- Create date: 14/09/2022
-- Description:	Обработка оперативных секций группы мер Смены_На_Кассах
-- =============================================
CREATE PROCEDURE [cass].[p_ssas_process_Смены_На_Кассах]
AS
BEGIN
	SET NOCOUNT ON;
	SET DATEFIRST 1;

	declare @command nvarchar(max);
	declare @currDate datetime, @prevDate datetime, @nextDate datetime;
	declare @prevPartitionName nvarchar(10), @currPartitionName nvarchar(10), @nextPartitionName nvarchar(10);

	set @currDate = getDate();
	set @currDate = dateAdd(day, (datePart(dw, @currDate) - 1) * -1, @currDate);
	set @currPartitionName = cast(datepart(year, @currDate) as nvarchar) + '_' + 
	                         right('0' + cast(datepart(month, @currDate) as nvarchar), 2) + '_' +
	                         right('0' + cast(datepart(day, @currDate) as nvarchar), 2);

	set @prevDate = dateAdd(day, -7, @currDate);
	set @prevPartitionName = cast(datepart(year, @prevDate) as nvarchar) + '_' + 
	                         right('0' + cast(datepart(month, @prevDate) as nvarchar), 2) + '_' +
	                         right('0' + cast(datepart(day, @prevDate) as nvarchar), 2);

	set @nextDate = dateAdd(day, 7, @currDate);
	set @nextPartitionName = cast(datepart(year, @nextDate) as nvarchar) + '_' + 
	                         right('0' + cast(datepart(month, @nextDate) as nvarchar), 2) + '_' +
	                         right('0' + cast(datepart(day, @nextDate) as nvarchar), 2);
	
	set @command = '
		<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
		  <Parallel>
			<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
			  <Object>
				<DatabaseID>Холдинг ТД Аникс</DatabaseID>
				<CubeID>Холдинг ТД Аникс</CubeID>
				<MeasureGroupID>v Fact Смены На Кассах</MeasureGroupID>
				<PartitionID>Смены_На_Кассах_%prevPartitionName%</PartitionID>
			  </Object>
			  <Type>ProcessFull</Type>
			  <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
			</Process>
			<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
			  <Object>
				<DatabaseID>Холдинг ТД Аникс</DatabaseID>
				<CubeID>Холдинг ТД Аникс</CubeID>
				<MeasureGroupID>v Fact Смены На Кассах</MeasureGroupID>
				<PartitionID>Смены_На_Кассах_%currPartitionName%</PartitionID>
			  </Object>
			  <Type>ProcessFull</Type>
			  <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
			</Process>
			<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
			  <Object>
				<DatabaseID>Холдинг ТД Аникс</DatabaseID>
				<CubeID>Холдинг ТД Аникс</CubeID>
				<MeasureGroupID>v Fact Смены На Кассах</MeasureGroupID>
				<PartitionID>Смены_На_Кассах_%nextPartitionName%</PartitionID>
			  </Object>
			  <Type>ProcessFull</Type>
			  <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
			</Process>
		  </Parallel>
		</Batch>
	';
	set @command = replace(@command, '%prevPartitionName%', @prevPartitionName);
	set @command = replace(@command, '%currPartitionName%', @currPartitionName);
	set @command = replace(@command, '%nextPartitionName%', @nextPartitionName);

	print(
		concat(
			'Начинается выполнениу SSAS команды на сервере SSAS_S19-OLAP. Текст команды: ', char(13), @command
		)
	);

	exec(@command) at [SSAS_S19-OLAP];
END
