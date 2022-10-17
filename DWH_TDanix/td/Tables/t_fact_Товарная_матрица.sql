CREATE TABLE [td].[t_fact_Товарная_матрица](
	[Дата] [date] NOT NULL ,
	[Код_магазина] [int] NOT NULL,
	[Код_товара] [int] NOT NULL,
	[Код_поставщика] [int],
	[Признак] [tinyint] NOT NULL
) ON [FACTS]
go

create clustered index ix_cl_Дата on [td].[t_fact_Товарная_матрица] (Дата) on [FACTS]
GO

create index ix_uncl_Код_товара on [td].[t_fact_Товарная_матрица] (Код_товара) on [FACTS]
GO

create index ix_uncl_Код_магазина on [td].[t_fact_Товарная_матрица] (Код_магазина) on [FACTS]
GO