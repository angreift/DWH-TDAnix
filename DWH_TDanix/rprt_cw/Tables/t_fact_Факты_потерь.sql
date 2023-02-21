CREATE TABLE [rprt_cw].[t_fact_Факты_потерь](
	[Дата] [date] NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Код_магазина] [int] NOT NULL,
	[Сумма] [decimal](14, 2) NOT NULL,
	[Количество] [decimal](14, 2) NOT NULL,
	[Списание] [bit] NOT NULL
) ON [REPORTS]
GO

