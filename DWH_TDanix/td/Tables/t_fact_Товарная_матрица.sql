CREATE TABLE [td].[t_fact_Товарная_матрица](
	[Дата] [date] NOT NULL ,
	[Код_магазина] [int] NOT NULL,
	[Код_товара] BIGINT NOT NULL,
	[Код_поставщика] [int],
	[Признак] [tinyint] NOT NULL
) ON [FACTS]
go

CREATE CLUSTERED INDEX [ix_cl_Дата] ON [td].[t_fact_Товарная_матрица]
(
	[Дата] ASC
) on [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_КодТовара_КодМагазина] ON [td].[t_fact_Товарная_матрица]
(
	[Код_товара] ASC,
	[Код_магазина] ASC
)
INCLUDE([Код_поставщика],[Признак]) ON [FACTS]