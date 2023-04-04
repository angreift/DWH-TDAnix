CREATE TABLE [dbo].[t_raw_Мониторинг_печати_ценников](
	[Дата_выгрузки] [date] NULL,
	[Отпечаток_времени] [int] NULL,
	[Выгрузка_из_ЗОД] [bit] NULL,
	[Код_магазина] [int] NULL,
	[Дата_время] [datetime] NULL,
	[Data] [nvarchar](max) NULL,
	[Version] [int] NULL,
	[SubCode] [int] NULL,
	[DateExec] [date] NULL,
	[TimeStamp] [int] NULL,
	[DateStart] [date] NULL,
	[DateEnd] [date] NULL,
	[EndFlag] [bit] NULL
) ON [RAW] TEXTIMAGE_ON [RAW]
GO
