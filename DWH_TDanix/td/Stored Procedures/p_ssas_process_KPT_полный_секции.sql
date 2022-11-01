CREATE PROCEDURE [td].[p_ssas_process_KPT_полный_секции] AS
BEGIN
    SET NOCOUNT ON;
	SET DATEFIRST 1;

	declare @cur_day int,
		@next_mounth varchar(7),
		@prev_mounth varchar(7),
		@command_to_process_kpt nvarchar(max);

    set @cur_day = DATEPART(dd, getdate());

    set @next_mounth = case 
	    when @cur_day <= 15
	    then format(getdate(), 'yyyy_MM')
	    else format(dateadd(MM, 1, getdate()), 'yyyy_MM')
    end;

    set @prev_mounth = case 
	    when @cur_day <= 15
	    then format(dateadd(MM, -1, getdate()), 'yyyy_MM')
	    else format(getdate(), 'yyyy_MM')
    end;

    set @command_to_process_kpt = '
    <Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
      <Parallel>
        <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
          <Object>
            <DatabaseID>KPT_prod</DatabaseID>
            <CubeID>KPT</CubeID>
            <MeasureGroupID>View Свод</MeasureGroupID>
            <PartitionID>kpt_%prev_mounth%</PartitionID>
          </Object>
          <Type>ProcessFull</Type>
          <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
        </Process>
        <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
          <Object>
            <DatabaseID>KPT_prod</DatabaseID>
            <CubeID>KPT</CubeID>
            <MeasureGroupID>View Свод</MeasureGroupID>
            <PartitionID>kpt_%next_mounth%</PartitionID>
          </Object>
          <Type>ProcessFull</Type>
          <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
        </Process>
        <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
          <Object>
            <DatabaseID>KPT_prod</DatabaseID>
            <CubeID>KPT</CubeID>
            <MeasureGroupID>Карта Причин Падения КПТ</MeasureGroupID>
            <PartitionID>kpt_reasons_%prev_mounth%</PartitionID>
          </Object>
          <Type>ProcessFull</Type>
          <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
        </Process>
        <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
          <Object>
            <DatabaseID>KPT_prod</DatabaseID>
            <CubeID>KPT</CubeID>
            <MeasureGroupID>Карта Причин Падения КПТ</MeasureGroupID>
            <PartitionID>kpt_reasons_%next_mounth%</PartitionID>
          </Object>
          <Type>ProcessFull</Type>
          <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
        </Process>
      </Parallel>
    </Batch>
    ';

    set @command_to_process_kpt = replace(@command_to_process_kpt, '%prev_mounth%', @prev_mounth);
    set @command_to_process_kpt = replace(@command_to_process_kpt, '%next_mounth%', @next_mounth);


    print(
	    concat(
		    'Начинается выполнениу SSAS команды на сервере SSAS_S19-OLAP. Текст команды: ', char(13), @command_to_process_kpt
	    )
    );
    exec(@command_to_process_kpt) at [SSAS_S19-OLAP];
    insert into [S19-STORAGE-SQL].[CS].[dbo].[t_fact_ProcessingReport](object,TimeProcessed, remark) values(6, getdate(), 'SSIS');
END
