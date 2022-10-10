


CREATE TABLE [td].[t_fact_Товарная_матрица](
	[Дата] [date] ,
	[Код_магазина] [int],
	[Код_товара] [int],
	[Код_поставщика] [int],
	[Признак] [tinyint]
) ON [FACTS]

GO

Create clustered index ix_cl_дата_товар_магазин on [td].[t_fact_Товарная_матрица] (Дата, Код_товара, Код_магазина)