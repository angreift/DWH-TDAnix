-- =============================================
-- Author:		kma1860
-- Create date: 31/10/2022
-- Description:	Обработка оперативных секций группы мер Остатки товара
-- =============================================
CREATE PROCEDURE [td].[p_ssas_process_Остатки_товара]
AS
BEGIN
	SET NOCOUNT ON;
	SET DATEFIRST 1;

	declare @command varchar(max), @currDate datetime, @i int, @lastDate date, @nextDate date;

	set @currDate = getDate();
	set @lastDate = dateadd(month, -1, @currDate);
	set @nextDate = dateadd(month,  1, @currDate);

	set @command = '
<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
	<Parallel>
		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2">
			<Object>
			<DatabaseID>Холдинг ТД Аникс</DatabaseID>
			<CubeID>Холдинг ТД Аникс</CubeID>
			<MeasureGroupID>f Fact Остатки</MeasureGroupID>
			<PartitionID>Остатки_товара_' + format(@currDate, 'yyyy') + '_' + format(@currDate, 'MM') + '</PartitionID>
			</Object>
			<Type>ProcessFull</Type>
			<WriteBackTableCreation>UseExisting</WriteBackTableCreation>
		</Process>
		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2">
			<Object>
			<DatabaseID>Холдинг ТД Аникс</DatabaseID>
			<CubeID>Холдинг ТД Аникс</CubeID>
			<MeasureGroupID>f Fact Остатки</MeasureGroupID>
			<PartitionID>Остатки_товара_' + format(@currDate, 'yyyy') + '_' + format(@lastDate, 'MM') + '</PartitionID>
			</Object>
			<Type>ProcessFull</Type>
			<WriteBackTableCreation>UseExisting</WriteBackTableCreation>
		</Process>
		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2">
			<Object>
			<DatabaseID>Холдинг ТД Аникс</DatabaseID>
			<CubeID>Холдинг ТД Аникс</CubeID>
			<MeasureGroupID>f Fact Остатки</MeasureGroupID>
			<PartitionID>Остатки_товара_' + format(@currDate, 'yyyy') + '_' + format(@nextDate, 'MM') + '</PartitionID>
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
	set @i = @i - 1;
END
GO


