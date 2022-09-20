-- =============================================
-- Author:		kma1860
-- Create date: 24/08/2022
-- Description:	Создает подключение MySQL ODBC
-- =============================================
CREATE PROCEDURE [dbo].[p_Регистрация_ODBC_подключения]
	@КодКассы int,
	@IPАдрес nvarchar(15),
	@R bit output
AS
BEGIN
	SET NOCOUNT ON;

	declare @cmd_exp                  nvarchar(max);
	declare @MySQL_connector_location nvarchar(max);
	declare @cmdshell_result          bit;
	declare @linkedServerName         nvarchar(15);
	declare @object_name              nvarchar(128);
	declare @msg                      nvarchar(max);

	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid);

	set @linkedServerName = concat('pos_', @КодКассы);

	set @R = 0;

	exec [dbo].[p_Получить_значение_переменной_string] 'Путь к MYSQL ODBC Connector', @MySQL_connector_location output;

	print(
		concat(
			'Каталог MySQL ODBC Connector: "',
			trim(@MySQL_connector_location),
			'"',
			char(13)
		)
	);

	-- На входе IP адрес содержит нулевые разряды, избавимся от них 
	while charindex('.0', @IPАдрес) > 0 
		set @IPАдрес = replace(@IPАдрес, '.0', '.')

	set @cmd_exp = concat(
		'', trim(@MySQL_connector_location), ' ',
		'-s -a -n "',
		@linkedServerName,
		'" -t "DRIVER=MySQL ODBC 8.0 Unicode Driver;Server=',
		trim(@IPАдрес),
		';DATABASE=documents;UID=netroot;PWD=netroot"'
	);

	print(
		concat(
			'Команда CMD: ', char(13),
			trim(@cmd_exp),	char(13)
		)
	);

	declare @q nvarchar(max);
	set @q = concat(
		'exec xp_cmdshell ''',
		@cmd_exp, ''''
	);
	print(@q);

	exec(@q);

	--Создание связанного сервера

	--Попытка удаления текущего сервера
	begin try
		EXEC master.dbo.sp_dropserver @server=@linkedServerName, @droplogins='droplogins'
	end try
	begin catch
	end catch

	begin try
		EXEC master.dbo.sp_addlinkedserver @server = @linkedServerName, @srvproduct=@linkedServerName, @provider=N'MSDASQL', @datasrc=@linkedServerName, @catalog=N'DictionariesALL'
		EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=@linkedServerName,@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'collation compatible', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'data access', @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'dist', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'pub', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'rpc', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'rpc out', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'sub', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'connect timeout', @optvalue=N'0'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'collation name', @optvalue=null
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'lazy schema validation', @optvalue=N'false'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'query timeout', @optvalue=N'0'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'use remote collation', @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=@linkedServerName, @optname=N'remote proc transaction promotion', @optvalue=N'true'
	end try
	begin catch 
		set @msg = concat(
			'Не удалось создать связанный сервер. Сообщение об ошибке: ', ERROR_MESSAGE()
		);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		return
	end catch

	set @R = 1;
	Return;
END
