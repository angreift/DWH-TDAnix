CREATE TABLE [td].[t_fact_Компенсация_от_поставщиков](
	[Код_магазина] [int] NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Код_поставщика] [int] NOT NULL,
	[Дата] [date] NOT NULL,
	[Сумма] DECIMAL(14, 2) NOT NULL
) ON [FACTS]
GO

