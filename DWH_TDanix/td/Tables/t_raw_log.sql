/* 
	В эту таблицу будут складываться данные из универсального загрузчика для отладки
*/
CREATE TABLE [td].[t_raw_log]
(
	[Дата_время] datetime null,
	[Data] nvarchar(max) null,
	[Version] int null,
	[SubCode] int null,
	[DateExec] date null,
	[TimeStamp] int null,
	[DateStart] date null,
	[DateEnd] date null, 
    [EndFlag] BIT NULL,
	[TableName] nvarchar(100) not null
) on [RAW]
GO

create clustered index [ix_cl_Дата_время] on [td].[t_raw_log] (Дата_время ASC) on [RAW]
GO

create nonclustered index [ix_uncl_TableName] on [td].[t_raw_log] (TableName) on [RAW]
GO