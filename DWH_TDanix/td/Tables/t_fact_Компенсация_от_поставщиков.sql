CREATE TABLE [td].[t_fact_Компенсация_от_поставщиков](
	[Код_магазина] [int] NOT NULL,
	[Код_товара] [int] NOT NULL,
	[Код_поставщика] [int] NOT NULL,
	[Дата] [date] NOT NULL,
	[Сумма] [money] NOT NULL
) ON [FACTS]
GO

