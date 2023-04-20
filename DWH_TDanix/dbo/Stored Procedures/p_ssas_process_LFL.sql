-- =============================================
-- Author:		kes1878
-- Create date: 20/04/2023
-- Description:	Обработка оперативных секций группы мер LFL
-- =============================================
CREATE PROCEDURE [dbo].[p_ssas_process_LFL]
AS
BEGIN
	SET NOCOUNT ON;

	declare @command nvarchar(max);


	set @command = '
		<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
		  <Parallel>
			<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
			  <Object>
				<DatabaseID>Холдинг ТД Аникс</DatabaseID>
				<CubeID>Холдинг ТД Аникс</CubeID>
				<MeasureGroupID>v Fact LFL</MeasureGroupID>
				<PartitionID>v Fact LFL</PartitionID>
			  </Object>
			  <Type>ProcessFull</Type>
			  <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
			</Process>
		  </Parallel>
		</Batch>
	';
	print(
		concat(
			'Начинается выполнение SSAS команды на сервере SSAS_S19-OLAP. Текст команды: ', char(13), @command
		)
	);

	exec(@command) at [SSAS_S19-OLAP];

END