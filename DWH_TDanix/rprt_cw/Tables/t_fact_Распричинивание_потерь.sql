CREATE TABLE [rprt_cw].[t_fact_Распричинивание_потерь](
	[Дата] [date] NOT NULL,
	[Код_магазина] [int] NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Код_причины] [tinyint] NOT NULL,
	[Влияние] [decimal](14, 2) NULL,
	[Флаг] [bit] NOT NULL,
	[Списание] [bit] NULL
) ON [REPORTS]
GO


CREATE NONCLUSTERED INDEX [ix_uncl_КодТовара_КодМагазина] ON [rprt_cw].[t_fact_Распричинивание_потерь]
(
	[Код_товара] ASC,
	[Код_магазина] ASC
)
go

CREATE CLUSTERED INDEX [ix_cl_Дата] ON [rprt_cw].[t_fact_Распричинивание_потерь]
(
	[Дата] desc
) on [REPORTS]
GO