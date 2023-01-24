CREATE TABLE [dbo].[t_raw_Классификатор_Альянс]
(
	[Дата_время] datetime not null,
	[Дата_выгрузки] date not null,
	[Отпечаток_времени] int null,
	[Data] nvarchar(max) not null, 
    [Флаг_загрузки] BIT NULL
) on RAW
GO

create clustered index [ix_cl_Дата_время] on [dbo].[t_raw_Классификатор_Альянс] (Дата_время ASC) on [RAW]