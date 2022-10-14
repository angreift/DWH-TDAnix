


CREATE TABLE [td].[t_fact_Товарная_матрица](
	[Дата] [date] NOT NULL ,
	[Код_магазина] [int] NOT NULL,
	[Код_товара] [int] NOT NULL,
	[Код_поставщика] [int],
	[Признак] [tinyint] NOT NULL
) ON [FACTS]
go

create clustered index ix_cl_дата_товар_магазин on [td].[t_fact_Товарная_матрица] (Дата, Код_товара, Код_магазина)  on [FACTS]