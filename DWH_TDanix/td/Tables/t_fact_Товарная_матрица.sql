﻿CREATE TABLE [td].[t_fact_Товарная_матрица](
	[Дата] [date] NOT NULL ,
	[Код_магазина] [int] NOT NULL,
	[Код_товара] BIGINT NOT NULL,
	[Код_поставщика] [int],
	[Признак] [tinyint] NOT NULL
) ON [FACTS]
go

CREATE NONCLUSTERED INDEX [ix_uncl_КодТовара_КодМагазина] ON [td].[t_fact_Товарная_матрица]
(
	[Код_товара] ASC,
	[Код_магазина] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FACTS]
GO

CREATE CLUSTERED INDEX [ix_cl_Дата] ON [td].[t_fact_Товарная_матрица]
(
	[Дата] ASC
) ON [FACTS]
GO