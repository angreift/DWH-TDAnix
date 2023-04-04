﻿CREATE TABLE [plan].[t_raw_Показатели_для_сравнительного_анализа]
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
    [Loaded] BIT NULL
) on [RAW]
GO

create clustered index [ix_cl_Дата_время] on [plan].[t_raw_Показатели_для_сравнительного_анализа] (Дата_время ASC) on [RAW]
GO