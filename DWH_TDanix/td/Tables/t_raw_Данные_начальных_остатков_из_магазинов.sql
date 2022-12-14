CREATE TABLE [td].[t_raw_Данные_начальных_остатков_из_магазинов]
(
	[Дата_время] datetime not null,
	[Дата_выгрузки] date not null,
	[Отпечаток_времени] int null,
	[Код_магазина] int not null,
	[Data] nvarchar(max) not null
) on RAW
GO

create clustered index [ix_cl_Дата_время] on [td].[t_raw_Данные_начальных_остатков_из_магазинов] (Дата_время ASC) on [RAW]